// ============================================================
//  WapForm REST API Server
//  Database: shopcloud (MariaDB 10.4 / MySQL)
//
//  Revision History:
//    2026-05-24  V1.0  Initial release
//    2026-05-24  V1.1  Full shopcloud schema, charset utf8mb4
//    2026-08-01  V1.2  dateStrings:true（修日期差一天）；DML 記錄影響列數
//    2026-08-01  V1.3  /query 也記錄 SQL 與筆數；新增 GET /columns 查欄位型別
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
  database:          'ag',
  user:              'xyz',
  password:          '123',
  charset:           'utf8mb4',
  timezone:          '+08:00',
  // @@@ DATE/DATETIME 直接以字串回傳，不經過 JS Date 物件。
  //     沒有這個設定時：mysql2 把 DATE 還原成 Date（本地 +08:00 午夜），
  //     Express 回應時 JSON.stringify 呼叫 toISOString() 轉成 UTC ——
  //       DB 2026-07-31 → "2026-07-30T16:00:00.000Z"
  //     前端取日期部分就變成 07-30，整個系統的日期都差一天。
  //     timezone: '+08:00' 只影響解讀，擋不住序列化這一步。
  dateStrings:       true,
  waitForConnections: true,
  connectionLimit:   10,
  queueLimit:        0,
});

// ── 診斷開關：DML 執行後印出 SQL 與影響列數 ──────────────────
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
// Returns list of all tables in shopcloud
app.get('/tables', async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT TABLE_NAME, TABLE_ROWS, TABLE_COMMENT " +
      "FROM information_schema.TABLES " +
      "WHERE TABLE_SCHEMA = 'ag' ORDER BY TABLE_NAME"
    );
    res.json({ tables: rows });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── GET /columns?table=sh ────────────────────────────────────
// @@@ 查欄位型別。日期查詢對不上時，第一件事就是確認欄位到底是
//     DATE 還是 VARCHAR —— 若是 VARCHAR 存 'YYYY-MM-DD'，用
//     '20260731' 去比就是字串比較（'-' 0x2D < '0' 0x30），永遠不相等。
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

    // @@@ 診斷：查詢也要記錄。原本只記 /transaction（DML），SELECT 完全沒印，
    //     「查不到資料」時看不到實際送出的 WHERE 條件，只能靠猜。
    if (SQL_LOG) {
      const n = Array.isArray(result) ? result.length : result.affectedRows;
      console.log(`[query] rows=${n}${n === 0 ? '  <-- 沒有任何資料' : ''}`);
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
      // @@@ 診斷：DML 影響 0 列時，前端不會收到任何錯誤（看起來存了、其實沒存）。
      //     把 SQL、參數與 affectedRows 印出來，才查得出 WHERE 條件對不對。
      //     不需要時把 SQL_LOG 設成 false。
      if (SQL_LOG && !Array.isArray(result)) {
        const n = result.affectedRows;
        console.log(`[dml] affected=${n}${n === 0 ? '  <-- 沒有任何一列被改到' : ''}`);
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
  console.log(`Database     →  shopcloud @ localhost:3306`);
  console.log(`Endpoints    →  GET /ping  GET /tables  POST /query  POST /transaction`);
});
