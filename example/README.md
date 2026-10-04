# wapform_flutter example — a WML → Dart reference gallery

A login screen, a fully data-driven main menu, and 12 real
generator-output pages, each a `.wml` source file sitting right next
to the `.dart` file [WapForm for Flutter](https://wapform.com/flutter.html)
(the commercial WML→Dart generator) produced from it — unmodified
apart from the import block (`wap/xxx.dart` → `package:wapform_flutter/xxx.dart`,
so it resolves as a normal pub dependency instead of a local copy).
Open a pair side by side to see what each WML tag actually compiles
down to, backed by the classes in this repo.

Every file lives flat in `lib/` (no `pages/` subfolder) — that's the
layout the generator itself produces and expects; `main.dart`'s
imports assume it.

## How it's wired together

`main.dart` is **login → a fully dynamic main menu**, not a flat list
of buttons. How many menu levels there are, which items appear, their
order and titles, and who's allowed to use them are all driven by the
`mnu`/`login`/`users` tables — the same way `wapform.wml`'s
`<mainmenu>` behaves on the desktop. Changing the menu means changing
data, not code.

| # | WML | Dart | Demonstrates |
|---|---|---|---|
| 1 | `app001.wml` | `app001.dart` | Single-table CRUD (`<dbtable>`), the simplest case |
| 2 | `app002.wml` | `app002.dart` | Product master — lookup fields, multiple `<fieldset>`s |
| 3 | `app003.wml` | `app003.dart` | Brand master — plain single-table CRUD |
| 4 | `app004.wml` | `app004.dart` | Customer master — plain single-table CRUD |
| 5 | `app005.wml` | `app005.dart` | Employee master — `<select>` dropdowns (`TRadioGroup`) |
| 6 | `app006.wml` | `app006.dart` | Master-detail (`masterfields=`), `<dbgrid>`/`TDBGrid`, a `WapReport` sub-card — the largest file here, 18 classes |
| 7 | `app007.wml` | `app007.dart` | A `WapReport` — customer list with print/preview |
| 8 | `app012.wml` | `app012.dart` | A grouped `WapReport` (`<group change=>`) — the AR-statement pattern from the main README |
| 9 | `app023.wml` | `app023.dart` | Payment receipt master — a filtered search screen (`<dbfilter>`/`WapFilter`) |
| 10 | `app037.wml` | `app037.dart` | Shipper master — the other plain single-table case |
| 11 | `app901.wml` | `app901.dart` | User account management |
| 12 | `app902.wml` | `app902.dart` | Password/permission data maintenance |

Each of the 12 corresponds to a row in `mnu` (`mnu.href` matching the
filename, `active=1`); `main.dart`'s `_pages` map is the
string-to-constructor lookup table Dart needs at compile time (no
runtime reflection in Flutter, so `"app006"` can't be turned into
`App006CardP` automatically — adding a page means adding a line
here). Tapping a menu entry opens the matching page as a modal
dialog, sharing the same `WapEvaluator`/`DataSetRegistry` instance the
login screen created — so a page reading `$username` sees the value
`setvar` wrote at login, not a fresh empty one.

### `function.wml` / `function.dart` — the primary test program

Not a business page — a **363-case self-test report for the WML
expression engine itself** (`wapform_expression.dart`'s built-in
function library). Each of the 363 cases runs one documented example
expression from Appendix B, "Complete Function Reference," of
WapForm's own manual for real and checks it against that same entry's
documented expected value, grouped into six categories (string, math,
date/time, conditional, encoding/conversion, other), with a pass/fail
count per category and overall. Appendix B documents 398 functions in
total, so this covers most of the library, not literally every entry.
It has a real, permanent `mnu` row (`href='function.wml'`, "Function
Self-Test") — any account with a matching `login` permission row can
open it through the normal login → menu path, the same as any
business page. `main.dart` additionally wires it to a
`[debug] Function self-test report` button, stripped out of release
builds via `kDebugMode`, as a faster shortcut while developing — not
the only way to reach it.

This file is what actually drove several real fixes in
`wapform_expression.dart` — cross-referencing the documented examples
against actual output surfaced two byte-order bugs in the
`Color2Hex`/`Hex2Color` conversions (Delphi's `TColor` is BGR, not
RGB), a sign-inversion bug in `ROUND`/`ROUNDTO` (Delphi's `RoundTo`
and the spreadsheet convention this engine follows use opposite signs
for "decimal places" vs "integer places"), and roughly 60 functions
that were referenced in the documentation but never actually
registered.

For the complete picture of WapForm's architecture — every WML tag,
every function, and how the pieces fit together — see
**wapform_manual**, the complete technical manual downloadable from
[wapform.com](https://wapform.com).

## Two supporting files

- **`lib/wapform.ini`** — a database-connection profile in the format
  the *desktop* WapForm designer tool reads, not something this
  Flutter app consumes. Included as a reference so that if you open
  any of these `.wml` files in the actual desktop tool, you have a
  connection profile already pointed at the same `sales` database
  this example's backend uses (see `INSTALL.md`).
- **`assets/wapform.htm`** — this one *is* read by the Flutter app, at
  startup: `WapColors.load()` (called in `main()`, before `runApp()`)
  parses this file's embedded CSS for the row/zebra-stripe background
  colors reports and grids use, falling back to built-in defaults if
  the asset is missing or fails to parse. Declared in
  `pubspec.yaml`'s `flutter.assets`.

## Database coverage

`server/sales.sql` is a real export of the production `sales`
database, trimmed to the 12 tables the 12 example pages (plus
`function.wml`'s menu entry) actually query — checked against every
`select ... from` in `lib/app*.dart` (see the table-to-page mapping
in `sales.sql`'s own header comment). Every table comes with real
seed data, not hand-written placeholder rows — including
`users`/`mnu`/`login`, which the login screen and data-driven main
menu depend on entirely (no seed data there means no menu items and
nobody who can log in). The only exception is `num`, which the app
populates itself for document numbering and doesn't need pre-seeded.
So every menu item should **open with real data already in it**, not
just avoid a "table doesn't exist" error.

## Setup

Full step-by-step instructions (installing Flutter, setting up the
database, starting the gateway, running the app, and troubleshooting)
live in [`INSTALL.md`](../INSTALL.md) at the repo root. Short version,
once everything from there is installed:

```bash
# 1. gateway
cd server && npm install && node server.js

# 2. app (in a second terminal, from example/)
flutter pub get
flutter run -d chrome
```

## What this demonstrates

- `TWapSQLConnection(null, const WapDbBridgeDriver())` — the same
  connection setup every generated page in a real app uses.
- `dbquery(id, sql, define: ...)` — the "declare a dataset, build its
  persistent fields" pattern every `<dbquery>` in WML compiles to (see
  `_fld`/`_key`/`_lkp`/`_cal` near the top of each page file — those
  four helpers are what `<field>`, `<field key="yes">`,
  `<dbtable>`/lookup fields, and `<field value="expression">`
  respectively become).
- `TDataSource` + `TDBNavigator` + `TDBEdit` — the data-binding chain
  from `<datasource>`/`<navigator/>`/`<input field=>` in the main
  README's ["From WML to this API"](../README.md#from-wml-to-this-api)
  section, now as real generator output rather than a hand-trimmed
  illustration.
- `TDBGrid` + `masterfields=` (`app006.dart`) and a grouped `WapReport`
  (`app012.dart`) — the same two patterns the main README's
  master-detail and report examples are based on, here in their full,
  unabridged, actually-generated form.
- `applyUpdatesAsync()`'s "no key field" fallback — `sys` has no field
  marked as a key (no `_key()` call in the define block), so saving
  exercises `lazarus_sqldb.dart`'s `_fallbackKeyWhere` safety net
  rather than a normal primary-key `WHERE` clause.
- A login screen (`wapform_login.dart`) and dynamic menu
  (`wapform_menu.dart`) reproduced from the desktop WapToolkit's own
  dialogs, backed by `wapform_session.dart`'s single shared
  `WapEvaluator`/`DataSetRegistry` — the same session state every page
  reads and writes `setvar`s against.
- `function.wml`/`function.dart` — see above; a real, runnable
  cross-check between documented function behavior and actual
  behavior, not just a list of examples.
