# wapform_flutter

A Flutter port of a Lazarus/Free Pascal (FPC) based WML form and report
engine — the open-source foundation underneath [WapForm for
Flutter](https://wapform.com/flutter.html).

## Why this exists

Porting Lazarus/LCL's desktop component model to Flutter — `TDataSet`
· `TDBGrid` · `TDBNavigator` · the field and event model — gets you a
data-aware widget library that behaves like the Windows original. But a
component library by itself doesn't make building an app any faster:
you'd still hand-write every screen, every dataset, every event handler
in Dart, one line at a time, same as building a Flutter app from
scratch on any other component library.

WapForm's WML is a plain-text, declarative application-definition
language — a form's datasources, fields, lookups, events, and reports
are *described*, not coded. A generator reads that description and
writes the Dart source for you. That's only useful if the Dart it
generates has somewhere solid to land: a component API that already
behaves like the Windows product the WML was originally written
against, so the same WML file that runs on Windows can be exported and
re-run on Flutter with no rewrite.

That's what this repository is. It's the direct, line-by-line port of
Lazarus/LCL onto Flutter — the landing surface. WapForm's generator
targets this API, which is what turns "write ten lines of WML" into "get
a running Flutter screen" — a rapid-validation loop that a hand port,
however faithful, doesn't give you on its own.

## Architecture

WapForm for Flutter is three layers, and (per WapForm's licensing) the
bottom two are what live in this repository:

| Layer | What it is | Where |
|---|---|---|
| **WapForm** | Declarative capabilities on top of layer 2: WML definitions, the generator, master-detail structures, banded group reports. | *this repo's `wapform_*.dart` files* |
| **Lazarus for Flutter** | Direct line-by-line translation of Lazarus/LCL's component model to Dart — `TDataSet` · `TSQLQuery` · `TDBGrid` · `TDBNavigator` · fields · events. | *this repo's `lazarus_*.dart` files* |
| **Lazarus / LCL** | The original Object Pascal desktop component library this port is translated from. | *upstream, not part of this repo* |

Each layer only depends on the one below it. `lazarus_*.dart` has no
knowledge that WapForm exists — it's a standalone, general-purpose
port of the Lazarus component model, usable on its own for any
Dart/Flutter project that wants data-aware widgets. `wapform_*.dart`
is what turns that generic component layer into the specific thing a
WML file's generated output expects to find: an expression evaluator,
a tag engine, a lookup-box widget, and a banded report builder — the
runtime that the generator's emitted Dart code calls into.

All three layers are open source. The two in this repo are LGPL-2.1
with the FPC static-linking exception ("Modified LGPL") — see
[License](#license) below.

## About the commercial generator

This repository — the two lower layers — is the complete open-source
community edition, not a trial or a limited version of anything. Use
it directly: write your own screens and datasets against it by hand,
the same way you'd depend on any other Flutter package.

WapForm separately sells a WML-to-Dart generator (the third, top layer
in the table above) that reads a `.wml` file and writes the Dart for
you instead of you writing it by hand — that's the commercial product.
It targets exactly this open-source API, so the code it generates is
ordinary Dart calling ordinary classes from this repo — no proprietary
runtime, and nothing it outputs depends on an active license to keep
running. The generator just trades "hand-write each screen" for
"describe it once in WML," for the kind of data-entry forms and
reports it's built for. Build without it, or use it where it saves you
time — either way, what you end up depending on and maintaining is the
code in this repo.

## From WML to this API

To make the two layers above concrete: this is the same WapForm
declarative pattern — [documented for the desktop
product](https://wapform.com/windows.html) — landing on the classes
this repo provides.

A WML screen declares a dataset and binds a form to it:

```xml
<dbtable name="em" tablename="employees" indexfieldnames="emp_no">
  <field fieldname="emp_no"   displaylabel="Employee ID"/>
  <field fieldname="emp_name" displaylabel="Name"/>
  <field fieldname="dept"     displaylabel="Department"/>
  <field fieldname="hired"    displaylabel="Start date" type="date"/>
</dbtable>

<card id="P" title="Employee master">
  <datasource dataset="em">
    <navigator/>
    <fieldset>
      Employee ID: <input field="emp_no"   size="8"/>
      Name:        <input field="emp_name" size="20"/>
      Department:  <input field="dept"     size="12"/>
      Start date:  <input field="hired"    type="date" size="12"/>
    </fieldset>
  </datasource>
</card>
```

Nothing here says how to build a cursor, wire up Save/Delete, or
validate a date field — `<dbtable>` declares the table and its fields,
`<datasource>` binds a form to them, and `<navigator/>` is the entire
CRUD button bar in one line. [WapForm for
Flutter](https://wapform.com/flutter.html) exports that declaration
into Dart calling exactly the classes in this repo:

```dart
// <dbquery id> / <dbtable> → TSQLQuery; fields created in <field> order
late final TSQLQuery _em = dbquery("em", r"select * from employees", define: (ds) {
  _key(ds, "emp_no",   "employee_id");
  _fld(ds, "emp_name", "name");
  _fld(ds, "dept",     "department");
  _fld(ds, "hired",    "start_date", dateOnly: true);
});

// <datasource> + <navigator> → TDataSource + TDBNavigator
final _dsEm = TDataSource()..dataSet = _em;
TDBNavigator(dataSource: _dsEm),          // First/Prev/Next/Last/New/Delete/Save/Cancel

// <input field="..."> → TDBEdit bound to the dataset
TDBEdit(dataSource: _dsEm, dataField: "employee_id"),
TDBEdit(dataSource: _dsEm, dataField: "name"),
```

A master-detail `<datasource>` nested inside another (linked by
`masterfields`) becomes a second `TSQLQuery` whose `beforeOpen`/events
filter by the parent's key; a `<dbgrid><item>` inside it becomes a
`TDBGrid` with matching `TColumn`s; an `<input lookup=>` field becomes
a `WapLookupBox` wired to the lookup dataset — each declarative WML tag
has exactly one landing spot in this repo's API, which is what lets
the generator's output be entirely mechanical.

The report engine works the same way. WML's `<group change="...">`
groups rows and accumulates subtotals with `setvar`, letting the
framework handle pagination and reprinted headers on page breaks —
that's `wapform_report.dart`'s `WapReport`, where `emitRow()` plays
the same role: callers never track row counts or page breaks
themselves, whether the row came from `<group>` in WML or a subclass's
`parseBlock()` in Dart.

## File reference

### Lazarus layer (`lazarus_*.dart`)

Direct translations of the corresponding FPC RTL / FCL-DB / LCL units.
Each file's header names the exact upstream source and marks every
place the translation deviates from it.

**`lazarus_db.dart`** — *`db.pas` · `dataset.inc` · `fields.inc` ·
`datasource.inc` · `database.inc` · `dsparams.inc` · `dbconst.pas`*
The data-access foundation everything else builds on: `TDataSet` ·
the full `TField` hierarchy · `TFieldDefs` · `TDataLink`/`TDataSource` ·
`TParams` · and the buffer-window mechanism that makes scrollable,
editable datasets possible.

**`lazarus_sqldb.dart`** — *`sqldb.pp`*
SQL-backed datasets: `TSQLConnection` · `TSQLQuery` · `TSQLTransaction`.
Also includes `TWapSQLConnection` — original bridging code (not a
translation) that implements the driver interface over HTTP, since a
browser can't open a raw TCP connection to a database.

**`lazarus_dbctrls.dart`** — *`dbctrls.pp`*
Single-field data-bound controls: `TFieldDataLink` (the data-binding
core every bound widget uses) · `TDBEdit` · `TDBMemo` · `TDBRadioGroup` ·
`TDBNavigator`.

**`lazarus_dbgrids.dart`** — *`dbgrids.pas`*
The editable data grid: `TComponentDataLink` · `TColumn`/`TDBGridColumns` ·
and a `TDBGrid` widget with Excel-style cell selection, keyboard
navigation, and inline editing.

**`lazarus_grids.dart`** — *`grids.pas` (column-model subset)*
The column data model (`TGridColumn` · `TGridColumnTitle` ·
`TGridColumns`) that `lazarus_dbgrids.dart` builds on. Grid
painting/selection itself isn't translated — LCL's is Canvas-based,
with no Flutter equivalent.

**`lazarus_stdctrls.dart`** — *`stdctrls.pp`*
Standard controls: `TEdit` · `TMemo` · `TLabel` · `TComboBox` ·
`TListBox` · `TCheckBox` · `TRadioButton` · `TButton` · `TGroupBox` ·
`TScrollBar`.

**`lazarus_extctrls.dart`** — *`extctrls.pp`*
Extended controls: `TRadioGroup` · `TCheckGroup` · `TPanel` · `TBevel` ·
`TShape` · `TImage` · `TTimer`/`TIdleTimer` · `TLabeledEdit` ·
`TFlowPanel` · `TSplitter`.

### WapForm layer (`wapform_*.dart`)

Original code (not translated from Lazarus/FPC) that depends on the
layer above and gives WML's generated output somewhere to run.

**`wapform_expression.dart`**
The WML expression engine (`MyParser`/`WapEvaluator`): the
lexer/parser/evaluator behind every `$(...)` expression in a WML
file, plus the full `tt_*` and COBOL-intrinsic-style built-in function
library. Data-layer agnostic — no dependency on the Lazarus layer.

**`wapform_lazarus.dart`**
The WML tag engine wired to the Lazarus data layer:
`expression()`/`condition()`/`setvar()`/`invoke()` · `DataSetRegistry` ·
and `DbQuery` — this is what a generated screen's `<onevent>` and
`<dbquery>` tags compile down to calling.

**`wapform_lookup_box.dart`**
`WapLookupBox` — the unified lookup-dropdown widget used both as a
standalone field and as a `TDBGrid` cell editor. What `<input
lookup=>`/`<dbtable>` lookups compile to.

**`wapform_report.dart`**
The banded report engine (`WapReport` · `WapPage`): pagination, nested
group headers/footers, and HTML/PDF/print output. What `<group
change>`/`<output>` compile to.

**`wapform_report_style.dart`**
The shared CSS for report screen-preview and print output, kept in one
place so every report looks consistent.

**`wapform_colors.dart`**
`WapColors` — resolves the row/zebra-stripe CSS classes reports and
grids use, loaded from a shared asset with built-in fallbacks.

**`lib/src/report_web*.dart`**
Platform-conditional support for `wapform_report.dart`: the
`dart:html`/`dart:ui_web` code needed for in-page report preview on
Flutter Web, isolated behind a conditional import so the package still
compiles on mobile/desktop.

## Install

```yaml
dependencies:
  wapform_flutter:
    git:
      url: https://github.com/wapform/wapform_flutter.git
```

(or `path: ../wapform_flutter` while developing locally, or via pub.dev
once published).

```dart
import 'package:wapform_flutter/wapform_flutter.dart';
```

Individual files can also be imported directly, e.g.
`package:wapform_flutter/lazarus_sqldb.dart`, if you only need part of
the package.

## Platform support

Everything compiles on mobile, desktop, and web — there's no
compile-time dependency on `dart:html` outside of Flutter Web builds
(see `lib/src/report_web.dart` for the conditional import that makes
this work). Data access · `TDBGrid` · `WapLookupBox` · the WML
expression engine · and on-screen report preview all behave the same
on every platform.

**Report PDF/print output is Web-only right now.** On Flutter Web,
`WapPage`'s print button opens the report's HTML in a new tab and
calls the browser's native `window.print()`, which works fully. On
mobile/desktop it calls `Printing.layoutPdf()`, but the `onLayout`
callback that's supposed to return real PDF bytes currently returns an
empty `Uint8List(0)` (see `wapform_report.dart`'s `buildPdf()` and
`WapPage._print()`) — so the native print/share dialog opens, but
there's nothing in it. Everything else in the report pipeline (data,
pagination, grouping, on-screen preview via `flutter_html`) is
unaffected; this gap is specifically "turn a `WapReport` into PDF
bytes on a non-browser platform," which isn't implemented yet. Doing
so would mean building the report as a `pw.Document` via the `pdf`
package instead of reusing the HTML output, since `printing`/`pdf`
have no built-in HTML-to-PDF conversion outside the browser. PRs
welcome.

## License

LGPL-2.1 with the FPC static-linking exception ("Modified LGPL") — see
[LICENSE](LICENSE), [COPYING.LGPL.txt](COPYING.LGPL.txt), and
[COPYING.modifiedLGPL.txt](COPYING.modifiedLGPL.txt). In short: you can
use this package in closed-source apps without restriction; only
modifications to the package's own source files need to be published
under the same license if you redistribute them.
