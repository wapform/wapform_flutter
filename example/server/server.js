// ============================================================
//  WapForm REST API Server
//  Database: sales (MariaDB 10.4 / MySQL)
//
//  Revision History:
//    2026-05-24  V1.0  Initial release
//    2026-05-24  V1.1  Full sales schema, charset utf8mb4
//    2026-08-01  V1.2  dateStrings:true (fixes a one-day date offset); DML now logs affected row count
//    2026-08-01  V1.3  /query now also logs SQL and row count; added GET /columns for column types
//
//  Setup:
//    npm install express mysql2 cors
//    node server.js
//
//  Endpoints:
//    GET  /ping            health check
//    GET  /tables          list all tables
//    POST /query           SELECT / INSERT / UPDATE / DELETE
//    POST /transaction     multiple SQL statements in one transaction
// ============================================================

const express = require('express');
const mysql   = require('mysql2/promise');
const cors    = require('cors');

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// ── DB connection pool (from wapform.ini) ───────────────────
const pool = mysql.createPool({
  host:              'localhost',
  port:              3306,
  database:          'sales',
  user:              'xyz',
  password:          '123',
  charset:           'utf8mb4',
  timezone:          '+08:00',
  // @@@ Return DATE/DATETIME as plain strings, bypassing the JS Date
  //     object entirely. Without this: mysql2 turns a DATE column back
  //     into a Date (midnight local time, +08:00), and when Express
  //     serializes the response, JSON.stringify calls toISOString(),
  //     which converts it to UTC --
  //       DB 2026-07-31 -> "2026-07-30T16:00:00.000Z"
  //     -- so the frontend's date-only slice ends up as 07-30, and every
  //     date in the whole system is off by one day. timezone: '+08:00'
  //     only affects how a value is *read*; it can't stop this
  //     serialization step from happening.
  dateStrings:       true,
  waitForConnections: true,
  connectionLimit:   10,
  queueLimit:        0,
});

// -- Diagnostic switch: prints the SQL and affected-row count after every DML --
const SQL_LOG = true;

// ── Allowed statement types ──────────────────────────────────
const ALLOWED = /^\s*(SELECT|INSERT|UPDATE|DELETE|CALL)\s/i;

function checkSql(sql) {
  if (!sql || typeof sql !== 'string') return 'sql is required';
  if (!ALLOWED.test(sql.trim())) return 'Only SELECT/INSERT/UPDATE/DELETE/CALL allowed';
  return null;
}

// ── GET /ping ────────────────────────────────────────────────
app.get('/ping', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT NOW() AS now, VERSION() AS ver');
    res.json({ ok: true, now: rows[0].now, version: rows[0].ver });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});

// ── GET /tables ──────────────────────────────────────────────
// Returns list of all tables in sales
app.get('/tables', async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT TABLE_NAME, TABLE_ROWS, TABLE_COMMENT " +
      "FROM information_schema.TABLES " +
      "WHERE TABLE_SCHEMA = 'sales' ORDER BY TABLE_NAME"
    );
    res.json({ tables: rows });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── GET /columns?table=sh ────────────────────────────────────
// @@@ Looks up column types. When a date query doesn't match anything,
//     the first thing to check is whether the column is actually a
//     DATE or a VARCHAR -- if it's a VARCHAR storing 'YYYY-MM-DD',
//     comparing against '20260731' is a plain string comparison
//     ('-' is 0x2D, '0' is 0x30), which never matches.
app.get('/columns', async (req, res) => {
  const table = req.query.table;
  if (!table) return res.status(400).json({ error: 'table is required' });
  try {
    const [rows] = await pool.query(
      "SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY " +
      "FROM information_schema.COLUMNS " +
      "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? ORDER BY ORDINAL_POSITION",
      [table]
    );
    res.json({ table, columns: rows });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── POST /query ──────────────────────────────────────────────
// Body: { sql: "...", params: [] }
// Returns: { rows: [...], affectedRows?, insertId? }
app.post('/query', async (req, res) => {
  const { sql, params = [] } = req.body;
  const err = checkSql(sql);
  if (err) return res.status(400).json({ error: err });

  try {
    const [result] = await pool.execute(sql, params);

    // @@@ Diagnostic: queries get logged too now. This used to only log
    //     /transaction (DML) -- SELECT was never printed at all, so
    //     when "nothing comes back," there was no way to see the actual
    //     WHERE clause that went out, only guesswork.
    if (SQL_LOG) {
      const n = Array.isArray(result) ? result.length : result.affectedRows;
      console.log(`[query] rows=${n}${n === 0 ? '  <-- no rows returned' : ''}`);
      console.log(`        sql: ${sql}`);
      if (params && params.length) {
        console.log(`        prm: ${JSON.stringify(params)}`);
      }
    }

    // SELECT → result is array of rows
    if (Array.isArray(result)) {
      return res.json({ rows: result });
    }

    // INSERT / UPDATE / DELETE → result is OkPacket
    return res.json({
      rows:         [],
      affectedRows: result.affectedRows,
      insertId:     result.insertId,
      changedRows:  result.changedRows,
    });
  } catch (e) {
    console.error('[query error]', e.message, '\nSQL:', sql);
    res.status(500).json({ error: e.message, sql });
  }
});

// ── POST /transaction ────────────────────────────────────────
// Body: { statements: [{ sql: "...", params: [] }, ...] }
// All statements run in one transaction; rollback on any error.
app.post('/transaction', async (req, res) => {
  const { statements = [] } = req.body;
  if (!Array.isArray(statements) || statements.length === 0) {
    return res.status(400).json({ error: 'statements array is required' });
  }

  for (const s of statements) {
    const err = checkSql(s.sql);
    if (err) return res.status(400).json({ error: `${err}: ${s.sql}` });
  }

  const conn = await pool.getConnection();
  await conn.beginTransaction();
  try {
    const results = [];
    for (const s of statements) {
      const [result] = await conn.execute(s.sql, s.params || []);
      // @@@ Diagnostic: when a DML statement affects 0 rows, the frontend
      //     never sees any error (it looks saved, but nothing actually
      //     changed). Printing the SQL, parameters, and affectedRows is
      //     what makes it possible to tell whether the WHERE clause was
      //     even right. Set SQL_LOG to false once this isn't needed.
      if (SQL_LOG && !Array.isArray(result)) {
        const n = result.affectedRows;
        console.log(`[dml] affected=${n}${n === 0 ? '  <-- no rows were affected' : ''}`);
        console.log(`      sql: ${s.sql}`);
        console.log(`      prm: ${JSON.stringify(s.params || [])}`);
      }
      results.push(Array.isArray(result)
        ? { rows: result }
        : { affectedRows: result.affectedRows, insertId: result.insertId });
    }
    await conn.commit();
    res.json({ ok: true, results });
  } catch (e) {
    await conn.rollback();
    console.error('[transaction error]', e.message);
    res.status(500).json({ error: e.message });
  } finally {
    conn.release();
  }
});

// ── Known tables (for reference / validation) ────────────────
// ab, bc, bk, counter, cp, cu, em, fm, log, login,
// maxitm, maxno, menu, mnu, num, od, pa, pwd, qno,
// rh, rn, sa, sh, sn, ss, sub, sys, topic, users,
// usr, ve, vp, wap, web, xn, xy, zp

// ── Start ────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`WapForm API  →  http://localhost:${PORT}`);
  console.log(`Database     →  sales @ localhost:3306`);
  console.log(`Endpoints    →  GET /ping  GET /tables  POST /query  POST /transaction`);
});
