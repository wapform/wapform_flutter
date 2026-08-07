# wapform_flutter example — 系統參數建檔

A single generator-style screen (`lib/pages/agp001.dart`, unmodified
apart from its import block) wired up against `wapform_flutter`: a
single-table CRUD form for the `sys` table, opened as a modal dialog
from `lib/main.dart`.

## 1. Start the backend

This example talks to a WapDb HTTP gateway (`TWapSQLConnection` +
`WapDbBridgeDriver` in `lazarus_sqldb.dart`), not the database
directly — see the [main README](../README.md#platform-support) for
why (a browser/mobile app can't open a raw TCP connection to
MariaDB/MySQL). `server/server.js` is that gateway.

```bash
cd server
npm install
```

Before running it, open `server.js` and check the pool config near the
top matches your own MariaDB/MySQL instance:

```js
const pool = mysql.createPool({
  host:     'localhost',
  port:     3306,
  database: 'ag',      // ← the schema this example's sys table lives in
  user:     'xyz',      // ← replace with your own credentials
  password: '123',
  ...
});
```

> **Note:** `server.js`'s header comment says `Database: shopcloud`,
> but the actual `pool` config connects to `database: 'ag'`. That's a
> pre-existing mismatch in the file as provided — the code (not the
> comment) is what actually runs, so `schema.sql` below targets `ag`.
> If your own database is really named `shopcloud`, change
> `database: 'ag'` in `server.js` to match.

Create the schema and a seed row:

```bash
mysql -u root -p < schema.sql
```

Then start the gateway:

```bash
node server.js
```

You should see:
```
WapForm API  →  http://localhost:3000
Database     →  shopcloud @ localhost:3306
Endpoints    →  GET /ping  GET /tables  POST /query  POST /transaction
```

(That startup banner also still says "shopcloud" — same pre-existing
mismatch, harmless, just a log line.)

Verify it's actually reachable and pointed at the right table:
```bash
curl http://localhost:3000/ping
curl http://localhost:3000/tables
```

## 2. Run the Flutter app

From this `example/` directory:

```bash
flutter pub get
flutter run -d chrome   # or any other device/target
```

The home screen pings the gateway on startup. Once it shows
"Connected to the WapDb gateway", tap **系統參數建檔** to open
`Agp001CardP` — it loads the single `sys` row, and you can edit and
Save it. `WapDb.rawQuery`/`WapDb.transaction` print every SQL
statement and its parameters to the console (`kWapSqlLog` in
`lazarus_sqldb.dart` — set it to `false` once you don't need the
diagnostic output).

## What this demonstrates

- `TWapSQLConnection(null, const WapDbBridgeDriver())` — the same
  connection setup every generated page in a real app uses.
- `dbquery(id, sql, define: ...)` — the "declare a dataset, build its
  persistent fields" pattern every `<dbquery>` in WML compiles to (see
  `_fld`/`_key`/`_lkp`/`_cal` near the top of `agp001.dart` — those
  four helpers are what `<field>`, `<field key="yes">`,
  `<dbtable>`/lookup fields, and `<field value="expression">`
  respectively become).
- `TDataSource` + `TDBNavigator` + `TDBEdit` — the data-binding chain
  from `<datasource>`/`<navigator/>`/`<input field=>` in the README's
  ["From WML to this API"](../README.md#from-wml-to-this-api) section,
  now running against a real backend instead of just described.
- `applyUpdatesAsync()`'s "no key field" fallback — `sys` has no field
  marked as a key (no `_key()` call in the define block), so saving
  exercises `lazarus_sqldb.dart`'s `_fallbackKeyWhere` safety net
  rather than a normal primary-key `WHERE` clause.

## Extending this example

The natural next screens to add here, in roughly the order a real app
would need them, all following the same pattern as `agp001.dart`:

1. A master-detail screen (nested `<datasource>`, `masterfields=`) —
   exercises `TDBGrid`/`TDBGridColumns`, not just `TDBEdit`.
2. A lookup field (`WapLookupBox`) — `agp001.dart` doesn't use one;
   any table with a foreign key to another table is a natural fit.
3. A `WapReport` — grouped/paginated output, per the report engine
   described in the main README.
