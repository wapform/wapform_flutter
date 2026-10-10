# wapform_flutter

[WapForm for Flutter](https://wapform.com/flutter.html) Community
Edition: an open-source Flutter port of a Lazarus/FPC WAP form and
report engine for Web and mobile.

> With WapForm, platform limits disappear.

## Manuals

The complete WapForm technical manual (WML cards, datasets, fields,
events, reports and the expression function library, with examples for
Windows, Web and Flutter) is included in three languages:

| Language | Manual |
|---|---|
| English | [doc/wapform_manual_en.md](https://github.com/wapform/wapform_flutter/blob/main/doc/wapform_manual_en.md) |
| 繁體中文 | [doc/wapform_manual_zh-TW.md](https://github.com/wapform/wapform_flutter/blob/main/doc/wapform_manual_zh-TW.md) |
| 日本語 | [doc/wapform_manual_ja.md](https://github.com/wapform/wapform_flutter/blob/main/doc/wapform_manual_ja.md) |

The API reference of this package is in [MANUAL.md](MANUAL.md) and on
pub.dev's API docs.

## Why this exists

Cross-platform was never really the expensive part — the real cost is
having to rebuild everything from scratch every time you switch
platforms.

Even with Lazarus/LCL's desktop components fully ported to Flutter —
familiar data-aware widgets like `TDataSet`, `TDBGrid`,
`TDBNavigator`, the field and event model — developers still have to
build every screen in Dart, bind every dataset, and hand-write every
event handler and piece of business logic. At bottom, that's still
rewriting the same application on a different platform.

What WapForm actually solves isn't the widgets — it's how the
application gets defined in the first place.

WML is a plain-text, declarative application-definition language.
Datasources, fields, lookups, events, forms, and reports are all
defined by *description* — not bound to Dart, Flutter, or any
specific platform.

Which means the real development flow becomes:

**Define once, land anywhere.**

WapForm is the single application definition; the generator expands it
into target-platform code; the runtime supplies the components and
behavior the code actually needs to run.

And this repository is Flutter's runtime.

It isn't another Flutter UI framework — it's the Lazarus/LCL component
model's counterpart implementation on Flutter. Every line of Dart
WapForm's generator produces targets this API, so the same WML that
originally ran on Windows can land on Flutter without changing its
definition at all.

That's why "write ten lines of WML" gets you a running Flutter screen.

Because what's actually being reused isn't the code — it's the
application's definition itself.

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
[License](#license) below. WapForm separately sells a WML-to-Dart
generator that targets exactly this open-source API — code it
generates is ordinary Dart calling ordinary classes from this repo, no
proprietary runtime involved. You can build against this repo entirely
by hand instead; either way, what you end up depending on and
maintaining is the code here.

## What WapForm Actually Is: Define Once, Land Anywhere

Porting Lazarus/LCL's desktop component model to Flutter gets you
familiar data-aware components — `TDataSet`, `TDBGrid`,
`TDBNavigator`, the field and event model — giving WapForm's existing
application model somewhere to run inside Flutter.

But a component library alone doesn't make app development faster.
Developers still have to build every screen, dataset, field, and event
handler in Dart, by hand, one line at a time.

**What WapForm actually solves is a level above that: how an
application should be defined.**

WML is WapForm's platform-agnostic, declarative application-definition
language. Datasources, fields, lookups, events, forms, and reports are
all described in WML — not bound directly to Dart, Flutter, or any
other specific language.

Which means:

> **WapForm is the application's source of truth.**

The generator's job is to expand that definition into target-platform
code; the runtime and component library are the landing surface where
that code actually runs.

That's this repository's role: the port of Lazarus/LCL's components
and behavior onto Flutter, serving as the stable target platform that
WapForm's generator produces Dart code against.

---

### What AI Actually Contributes: Not Freeform Generation

Handing an LLM the Lazarus/FCL-DB source and asking it to translate
file after file into Dart, even if it produces a large volume of code,
doesn't mean it can reliably complete a port of this scale.

The real difficulty is behavioral consistency, API correspondence, the
data model, the event model, and long-term maintainability.

WapForm takes a different approach:

**WML Definition → Generator → Stable Runtime/API → Target Code**

AI isn't asked to freely "write an app." It's doing large-scale,
mechanical, repeatable code expansion against a WML definition that's
already unambiguous, targeting a target API that's already stable.

This port of WapForm for Flutter was completed in about **two months
of AI-assisted development**, against an initial estimate of six to
twelve months for a hand port of the same scope. The real difference
isn't just that AI writes code faster — it's:

> **Establish the definition first, then let AI generate against it.**

So those two months aren't just a demonstration of AI development
speed — they're a real-world validation of this
"definition → generation → runtime → execution" engineering pattern.

---

### On COBOL: Not a Language Converter, and Not Starting From Zero

Plenty of AI tools today advertise converting COBOL into Java, C#, or
other modern languages. But:

> **Successfully converting code isn't the same as completing a system
> port.**

What actually makes COBOL enterprise systems hard is usually the data
structures, transaction flows, field semantics, batch jobs, reports,
exception handling, and behavior shaped by the original runtime — all
accumulated over years. So a plain **COBOL → Java** conversion easily
turns into **COBOL → AI → Java → Compile → Debug → Test → revise
again**, and even once it compiles, confirming the converted system
actually behaves the same as the original often still takes
substantial cross-platform debugging and verification.

WapForm takes a different direction: it doesn't treat "the original
source code" as the only source of truth — it lifts the application up
to WML, a platform-agnostic definition layer. A future **WapForm for
COBOL** wouldn't just "generate COBOL" — an existing COBOL system's
logic, data, fields, flows, events, and reports could convert *into*
WML (**Existing COBOL → WapForm for COBOL → WML**), and that path
isn't one-way: the same WML could land back on COBOL itself
(**COBOL → WapForm for COBOL → WML → COBOL**), making WapForm for
COBOL not just an exit ramp for legacy systems but a way to
regenerate and verify one — confirming the converted behavior matches
the original, or producing a cleaner COBOL version aligned with the
current runtime. Once inside WML, the application is no longer tied
to COBOL, and the same definition can go through the Flutter generator
and runtime that already exist: **Existing COBOL → WML → Flutter**,
not a fresh **COBOL → Flutter** translation each time. If WML already
fully describes the application, generating Flutter from it shouldn't
require re-understanding COBOL or a large-scale cross-language
translation — just adjustments for whatever platform differences
remain. That's what actually matters about WML as an intermediate
definition layer.

**WapForm for COBOL doesn't exist yet** — but Flutter has already
completed the first full validation of the engineering chain
**Definition → Generator → Runtime → Target Code**, so building the
runtime, component model, and generator COBOL needs later doesn't mean
reinventing all of WapForm from scratch. Later platforms may even land
in the same or a shorter cycle than Flutter did, because the hardest
part — the method, the architecture, the generation pipeline — already
exists:

> **The first platform already established and validated the hardest
> engineering method; later platforms can build on that foundation.**

Which means the future can look like:

**COBOL → WML → COBOL**

**COBOL → WML → Flutter**

and

**WML → other platforms: MicroPython, Node.js**

**WML → other domains: AI, EDA**

Different platforms and domains no longer each have to re-define the
same application from scratch.

---

### What Is WapForm Actually Building?

So WapForm's core isn't really

**WapForm for Flutter**

nor

**WapForm for COBOL**

— it's a layer above both:

> **Let the application be defined first, then realized on whichever
> platform.**

WapForm is the center. AI is the accelerator. The runtime is the landing
surface. The platform is just the final realized form.

That's also the biggest difference between WapForm and typical AI
code-conversion tools:

**AI Code Conversion**

`Source Code → AI → Another Source Code`

**WapForm**

`Application Definition → Target Runtime → Target Code`

The former moves code between languages. The latter frees the
application's definition from any platform at all.

So WapForm for Flutter isn't just one Flutter port — it's the first
full proof of WapForm's cross-platform architecture.

And WapForm for COBOL won't just be the next "language converter." It
can become the bridge that lets an existing COBOL system enter WML,
and from there land on Flutter or any other platform.

**One Definition. Any Platform. Every Domain.**

## From WML to this API

To make the two layers above concrete: this is the same WapForm
declarative pattern — [documented for the desktop
product](https://wapform.com/windows.html) — landing on the classes
this repo provides.

A WML screen declares a dataset and binds a form to it:

```xml
<card id="P" title="Employee master">
  <dbquery name="em">
  <![[select * from employees]]>
    <field fieldname="emp_no"   displaylabel="Employee ID"/>
    <field fieldname="emp_name" displaylabel="Name"/>
    <field fieldname="dept"     displaylabel="Department"/>
    <field fieldname="hired"    displaylabel="Start date" type="date"/>
  </dbquery>
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
validate a date field — `<dbquery>` declares the query and its fields
with an inline SQL block, `<datasource>` binds a form to them, and
`<navigator/>` is the entire CRUD button bar in one line. [WapForm for
Flutter](https://wapform.com/flutter.html) exports that declaration
into Dart calling exactly the classes in this repo:

```dart
// <dbquery id> → TSQLQuery; fields created in <field> order
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
the generator's output be entirely mechanical. A shipment order and
its line items, for example:

```xml
<datasource dataset="sh">
  <navigator/>
  <fieldset>
    Shipment No.: <input field="sno" size="14" readonly="true"/>
    Customer:     <input field="cno" size="14" lookup="cu;cno;cname"/>
  </fieldset>

  <datasource dataset="sn" masterfields="sno">
    <navigator/>
    <dbgrid height="200">
      <item field="pno"   size="14" lookup="pa;pno;des"/>
      <item field="qty"   size="8"/>
      <item field="price" size="9"/>
    </dbgrid>
  </datasource>
</datasource>
```

```dart
// <datasource dataset="sh"> — the master, a plain navigable list
late final TSQLQuery _sh = dbquery("sh", r"select * from sh");
final _dsSh = TDataSource()..dataSet = _sh;

// <datasource dataset="sn" masterfields="sno"> nested inside it — the
// detail. "masterfields" means: re-open _sn, filtered by the master's
// current "sno", every time the master's cursor moves.
late final TSQLQuery _sn = dbquery("sn", r"select * from sn where sno=:sno");
final _dsSn = TDataSource()..dataSet = _sn;

@override
void initState() {
  super.initState();
  _sh.afterScroll = (ds) {
    _sn.close();
    _sn.params[0].asString = ds.fieldByName("sno").asString;
    _sn.open();
  };
}

// <dbgrid><item field="pno" lookup="pa;pno;des"/>...</dbgrid>
// → one TColumn per <item>, added to a TDBGridColumns; a lookup=
// field is handled by the grid's lookupResolver, not the column itself
TColumn _column(TDBGridColumns cols, String field, String caption, num size) {
  final c = cols.add();
  c.fieldName = field;
  c.width = (size * 8).round();
  c.title.caption = caption;
  return c;
}

late final TDBGridColumns _snCols = () {
  final c = TDBGridColumns();
  _column(c, "pno", "Item No.", 14);
  _column(c, "qty", "Quantity", 8);
  _column(c, "price", "Unit Price", 9);
  return c;
}();

TDBGrid(
  dataSource: _dsSn,
  columns: _snCols,
  lookupResolver: (field) => field.toLowerCase() != "pno"
      ? null
      : TDBGridLookupSpec(rows: _paRows, colWidths: const [160]),
),
```

The report engine works the same way. WML's `<group change="...">`
groups rows and accumulates subtotals with `setvar`, letting the
framework handle pagination and reprinted headers on page breaks —
that's `wapform_report.dart`'s `WapReport`, where `emitRow()` plays
the same role, whether the row came from `<group>` in WML or a
hand-written report subclass. A statement grouped by customer, with a
running subtotal:

```xml
<report dataset="sh">
  <group change="sh.cno">
    <setvar name="AMOUNT_SUM" value="0"/>

    <page>
      <p>$(sh.cname) — statement</p>
      <table>
        <tr><th>Ship Date</th><th>Shipment No.</th><th>Amount</th></tr>

        <group>
          <setvar name="AMOUNT_SUM" value="AMOUNT_SUM+sh.amount"/>
          <tr>
            <td>$(sh.sdate)</td>
            <td>$(sh.sno)</td>
            <td>$(sh.amount)</td>
          </tr>
        </group>

      </table>
      <p align="right">Subtotal: $(AMOUNT_SUM)</p>
    </page>
  </group>
</report>
```

```dart
// <group change="sh.cno"> — a new group (and a fresh AMOUNT_SUM) every
// time sh.cno changes; a plain <group> with no change= is the RECORD
// block, one call per row
class ShStatement extends WapReport {
  @override
  void parseBlock(String id) {
    switch (id) {
      case 'G1_PREFIX':
        setvar("AMOUNT_SUM", "0");
        emitRow(expandText(
            r'''<p>$(sh.cname) — statement</p><table>'''
            r'''<tr><th>Ship Date</th><th>Shipment No.</th><th>Amount</th></tr>'''));
        break;

      case 'RECORD':
        setvar("AMOUNT_SUM", "AMOUNT_SUM+sh.amount");
        emitRow(expandText(
            r'''<tr><td>$(sh.sdate)</td><td>$(sh.sno)</td><td>$(sh.amount)</td></tr>'''));
        break;

      case 'G1_SUFFIX':
        emitRow(expandText(
            r'''</table><p align="right">Subtotal: $(AMOUNT_SUM)</p>'''));
        break;
    }
  }
}
```

`emitRow()` counts lines and breaks the page automatically once it's
full, reprinting the header on the next one — callers never track row
counts or page breaks themselves, whether the row came from `<group>`
in WML (compiled into `parseBlock()`'s `switch`, as above) or a
hand-written report subclass calling `emitRow()` directly.

## File reference

`wapform_flutter.dart` is the barrel file — `import
'package:wapform_flutter/wapform_flutter.dart'` pulls in every file
below. Every file it exports is also importable on its own (e.g.
`package:wapform_flutter/lazarus_sqldb.dart`), so a project that only
needs, say, `TDBGrid` isn't forced to pull in the report engine too.
That's also why these files live flat in `lib/` instead of behind
`lib/src/` — the usual Dart convention of hiding implementation behind
`src/` would block per-file imports, and each file here is meant to be
a usable unit on its own.

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
file, plus the full built-in function library (nearly 400 functions —
see [wapform.com](https://wapform.com) for the complete reference).
Data-layer agnostic — no dependency on the Lazarus layer.

**`wapform_lazarus.dart`**
The WML tag engine wired to the Lazarus data layer:
`expression()`/`condition()`/`setvar()`/`invoke()` · `DataSetRegistry` ·
and `DbQuery` — this is what a generated screen's `<onevent>` and
`<dbquery>` tags compile down to calling.

**`wapform_lookup_box.dart`**
`WapLookupBox` — the unified lookup-dropdown widget used both as a
standalone field and as a `TDBGrid` cell editor. What `<input
lookup=>`/`<dbtable>` lookups compile to.

**`wapform_filter.dart`**
`WapFilter` — the search-filter bar widget. What `<dbfilter
result=""><item field= size=/>...<onevent type="onfilter">` compiles
to. Field labels come from the dataset's `displaylabel` automatically;
the SQL template is taken verbatim from the `onfilter` handler's
`<dbquery>` text, which already contains the literal `$R` token this
widget's search logic substitutes (equals / range / starts-with /
ends-with / contains, based on what the user types).

**`wapform_report.dart`**
The banded report engine (`WapReport` · `WapPage`): pagination, nested
group headers/footers, and HTML/PDF/print output. What `<group
change>`/`<report>` compile to.

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

## Example pages (`example/lib/`)

The 12 `.dart` files in `example/lib/` are generator-output pages
produced by TWapFlutterWriter (the tool that translates WML
form-description files into Flutter code) — the Flutter front end of
one sales management system, sharing a single `WapProductionDB`
connection and this repo's own `package:wapform_flutter/` utility
library (dataset wrapping, `TDBGrid`, field mapping, lookup fields,
etc. — the raw generator output imports these as `wap/xxx.dart`
relative paths; they've been switched to proper package imports here).
Each file is one screen (a form card) in the system, and internally
they're all structured the same way: `dbquery()` to register a
dataset, `_fld`/`_key`/`_lkp` to build the field mapping, `TDataSource`
to bind the screen, and Search/Clear/Print/Close button logic. What
differs page to page is the underlying table and business purpose.
Login (`wapform_login.dart`) and a fully data-driven main menu
(`wapform_menu.dart`, its contents read entirely from the `mnu`/
`login`/`users` tables) sit in front of all 12 — see
[`example/README.md`](example/README.md) for how that's wired
together:

> **Each `.wml` file sitting in the same directory is the WapForm
> source program that produced the paired `.dart` file next to it,
> included specifically so you can compare the two and see the
> translation process** — every `.dart` is exactly what its `.wml`
> compiles down to.

* `app001.dart` — System parameters: company name, address, tax ID,
  tax rate, closing period, and similar settings (table `sys`).
* `app002.dart` — Product/inventory master: item number, barcode,
  category, brand, cost, and multiple price tiers, with nested
  sub-forms (subcategory, group) and print/report output (main table
  `pa`; `ve` is a lookup source table for brand, not the main table).
* `app003.dart` — Brand master: brand code, name, address, tax ID,
  contact info (table `ve`).
* `app004.dart` — Customer master: customer code, name, address, tax
  ID, delivery zone, contact info, email/password, plus print output
  (table `cu`).
* `app005.dart` — Employee records: national ID, birthday, hometown,
  gender, marital status, military service, education, start/leave
  dates, department/title, phone (table `em`).
* `app006.dart` — The largest file: combined shipment/purchase order
  workflow, including customer and employee masters, a price-editing
  sub-form, and both Shipment Order and Purchase Order report output,
  plus an external link via `url_launcher` (tables `cu`, `em`, and the
  shipment tables).
* `app007.dart` — Customer lookup/print page: simpler, mainly for
  browsing the customer list and printing a report (table `cu`).
* `app012.dart` — **A grouped report**: the Accounts Receivable
  Statement (`App012ReportP1 extends WapReport`), grouped by customer
  with a running subtotal per shipment — this is the actual page
  behind the grouped-report example in this README's ["From WML to
  this API"](#from-wml-to-this-api) section. It also queries `sys`,
  but only for the report header's company name/tax rate — that's
  supporting data, not what the page is for.
* `app023.dart` — Payment receipt maintenance: shipment number,
  customer, tax rate, amount (incl. tax), amount paid, tied to tax
  and company settings (tables `sys`, the shipment tables, `cu`,
  `fm`).
* `app037.dart` — Shipper master: shipper code and name (table `fm`).
* `app901.dart` — User account management: login credentials,
  password, email, last login time, auto-login, department (table
  `users`).
* `app902.dart` — Menu and permissions management: menu items (title,
  client/server target, active flag) and each user's per-menu
  read/write permissions (tables `mnu`, `login`, `users`).

Taken together, these pages form the data-maintenance layer of a
typical sales management system: master data (customers, brands,
employees, shippers, products), transaction documents (shipment
orders, purchase orders, payment receipts), a report (the AR
statement), and system administration (parameters, user accounts,
menu permissions) — all produced by the same WML→Flutter translation
engine.

### `function.wml` / `function.dart`

Sitting alongside the 12 business pages, `function.wml`/
`function.dart` isn't one of them — it's a 363-case self-test report
for the WML expression engine (`wapform_expression.dart`'s built-in
function library), cross-checking each documented example expression
against its documented expected value. It's what actually drove
several real fixes in `wapform_expression.dart`, including two
byte-order bugs in `Color2Hex`/`Hex2Color` and a sign-inversion bug in
`ROUND`/`ROUNDTO`. It has a real, permanent `mnu` row ("Function
Self-Test") — any account with a matching `login` permission row can
open it through the normal login → menu path, the same as any
business page; `main.dart` also wires it to a debug-only button as a
faster shortcut while developing. See
[`example/README.md`](example/README.md) for the details.

For the complete picture of WapForm's architecture — every WML tag,
every function, and how the pieces fit together — see
**wapform_manual**, the complete technical manual downloadable from
[wapform.com](https://wapform.com).

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

Want to see it running? [`example/`](example/) has 12 real
generator-output pages, each paired with its source `.wml` file — see
[`INSTALL.md`](INSTALL.md) for a full step-by-step setup (Flutter SDK,
the database, the gateway server) or
[`example/README.md`](example/README.md) for the short version.

## Platform Support & Web-First Architecture

WapForm's core focus and implementation are centered on the Web
platform, with Android now verified as well — the full example app
(the 12 business pages, login, the data-driven menu, and the
report/PDF pipeline) has been fully tested against real Android
hardware, not just the report path in isolation. iOS, desktop, and
further platform polish are still future work.

* **A lean, Web-native implementation**: outside of Flutter Web
  builds, there's no compile-time dependency on `dart:html` (see
  `lib/src/report_web.dart` for the conditional import that makes
  this work), keeping the core architecture clean and extensible.
* **Consistent behavior**: data access, `TDBGrid`, `WapLookupBox`,
  the WML expression engine, and on-screen report preview via
  `flutter_html` all behave highly consistently on the Web platform.
* **Native HTML reports and printing**: on Flutter Web, `WapPage`'s
  print button opens the report's HTML directly in a new tab and
  calls the browser's native `window.print()` smoothly — fully
  covering Web-side print and export needs. On Android, the same
  print button instead goes through a native WebView +
  `PrintDocumentAdapter` pipeline (`flutter_native_html_to_pdf`) to
  produce a real PDF — the fix that replaced an earlier
  `Printing.convertHtml()`-based approach after it turned out to hang
  indefinitely on some real devices (a known upstream bug, not
  something specific to this package).

## License

LGPL-2.1 with the FPC static-linking exception ("Modified LGPL") — see
[LICENSE](LICENSE), [COPYING.LGPL.txt](COPYING.LGPL.txt), and
[COPYING.modifiedLGPL.txt](COPYING.modifiedLGPL.txt). In short: you can
use this package in closed-source apps without restriction; only
modifications to the package's own source files need to be published
under the same license if you redistribute them.
