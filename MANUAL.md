# WapForm for Flutter Community Edition — Full Reference Manual

> This manual documents only the **public**, externally-usable
> component interface — the equivalent of Delphi/Lazarus `public`
> properties/methods, i.e. what you'd actually call from application
> code. Framework-internal or `protected`-style machinery (meant to be
> overridden by subclasses, not called directly by ordinary
> developers) is left out, so the genuinely useful public surface
> doesn't get buried under internal detail. Every property/method
> listed here has been checked against the actual source. The
> standard function library section follows the same format as
> WapForm's official technical manual (name → syntax → description →
> example → See also), so it can be merged back into that manual
> directly.

---

# Table of Contents

**Part 1: Component Reference**
- [Lazarus Layer](#lazarus-layer)
  - [TDataSet (abstract base)](#tdataset)
  - [The TField family](#the-tfield-family)
  - [TDataSource](#tdatasource)
  - [TSQLQuery](#tsqlquery)
  - [TWapSQLConnection](#twapsqlconnection)
  - [WapDb](#wapdb)
  - [TSQLTransaction](#tsqltransaction)
  - [TDBEdit / TDBMemo / TDBRadioGroup / TDBNavigator](#data-bound-controls)
  - [TColumn / TGridColumn / TDBGridColumns / TDBGrid](#grid-related-classes)
- [WapForm Layer](#wapform-layer)
  - [WapEvaluator](#wapevaluator)
  - [DataSetRegistry](#datasetregistry)
  - [DbQuery](#dbquery)
  - [WapLookupBox](#waplookupbox)
  - [WapFilter / FilterItem](#wapfilter--filteritem)
  - [WapReport (abstract base)](#wapreport)
  - [WapPage](#wappage)
  - [WapColors](#wapcolors)

**Part 2: Standard Function Library**
- [C.1 Math](#c1-math-22)
- [C.2 Aggregation](#c2-aggregation-1)
- [C.3 String handling](#c3-string-handling-45)
- [C.4 Value conversion](#c4-value-conversion-15)
- [C.5 Date and time](#c5-date-and-time-27)
- [C.6 Conditional and logic](#c6-conditional-and-logic-12)
- [C.7 Locale](#c7-locale-1)
- [C.8 Random](#c8-random-1)
- [C.9 Encryption and security](#c9-encryption-and-security-3)
- [C.10 System and environment](#c10-system-and-environment-11)
- [C.11 Path handling](#c11-path-handling-6)
- [C.12 Dynamic variables and arrays](#c12-dynamic-variables-and-arrays-6)
- [Summary: 150 functions, 100% coverage](#summary-150-functions-100-coverage)
- [Standard library in practice](#standard-library-in-practice)
- [The `tt_*` extended library](#the-tt_-extended-library)

---

# Part 1: Component Reference

## Lazarus Layer

### TDataSet

*File: `lazarus_db.dart`　Source: `db.pas`/`dataset.inc`*

The abstract base class every dataset inherits from (`TSQLQuery`
extends it). Below lists only the **externally usable** methods and
properties — the equivalent of Delphi/Lazarus `public` members, i.e.
what application code actually calls. `protected`-level internals
(open/buffer-management hooks meant for the framework itself, or for
writing a new dataset backend) aren't included in this manual.

#### Common methods

| Method | Signature | Description |
|---|---|---|
| Open | `void open()` | Opens the dataset (synchronous interface) |
| Close | `void close()` | Closes the dataset, releasing the cursor |
| Move cursor | `void next()` / `void prior()` / `void first()` / `void last()` | Moves the current-record cursor |
| Relative move | `void moveBy(int distance)` | Positive moves forward, negative moves backward, by the given count |
| Append (insert at end) | `void append()` | Enters insert mode, new record at the end of the dataset |
| Insert (at current position) | `void insert()` | Enters insert mode, new record at the current cursor position |
| Append record | `void appendRecord(List values)` | Supplies field values in one call and posts immediately |
| Insert record | `void insertRecord(List values)` | Same, but inserted at the current position |
| Enter edit mode | `void edit()` | |
| Post | `void post()` | Writes the currently-edited/inserted record back into the dataset (in memory) |
| Cancel | `void cancel()` | Discards the current edit/insert |
| Delete | `void delete()` | Deletes the current record |
| Refresh | `void refresh()` | Re-reads from the data source |
| Locate by field value | `bool locate(...)` | Searches and moves the cursor; returns `true` if found |
| Look up (without moving the cursor) | `bool lookup(...)` | |
| Find a record | `bool findFirst()` / `findLast()` / `findNext()` / `findPrior()` / `findRecord(...)` | |
| Get field by name (throws if missing) | `TField fieldByName(String fieldName)` | |
| Get field by name (returns null if missing) | `TField? findField(String fieldName)` | |
| Get field by number | `TField fieldByNumber(int number)` | |
| Get field name list | `List<String> getFieldNames()` | |
| Batch read/write field values | `dynamic fieldValues(...)` / `void setFieldValues(...)` | |
| Remove a field | `void removeField(TField field)` | |
| Disable UI updates | `void disableControls()` | Wrap a loop that walks lots of data in this to avoid triggering a repaint on every single move |
| Enable UI updates | `void enableControls()` | |
| Check whether disabled | `bool controlsDisabled()` | |

#### Common properties

| Property | Type | Description |
|---|---|---|
| `active` | `bool` | Whether the dataset is open |
| `eof` | `bool` | Whether the cursor is at end-of-file |
| `bof` | `bool` | Whether the cursor is at beginning-of-file |
| `isEmpty` | `bool` | Whether the dataset has no records |
| `recordCount` | `int` | Total record count |
| `recNo` | `int` | Current record number |
| `modified` | `bool` | Whether the current record has been changed |
| `state` | — | Current dataset state (browse/edit/insert/etc.) |
| `fields` | `TFields` | The collection of all fields |
| `fieldCount` | `int` | Number of fields |
| `fieldDefs` | `TFieldDefs` | Field definition collection |
| `dataSource` | `TDataSource?` | In a master-detail link, points at the parent dataset's `TDataSource` |
| `filter` | `String` | Filter condition string |
| `filtered` | `bool` | Whether a filter is applied |
| `canModify` | `bool` | Whether the dataset can be modified |
| `found` | `bool` | Whether the last `locate`/`lookup` found a match |

#### Events (`TDataSetNotifyEvent?`, all typed as `void Function(TDataSet ds)`)

`beforeOpen`/`afterOpen`/`beforeClose`/`afterClose`/`beforeInsert`/
`afterInsert`/`beforeEdit`/`afterEdit`/`beforePost`/`afterPost`/
`beforeCancel`/`afterCancel`/`beforeDelete`/`afterDelete`/
`beforeScroll`/`afterScroll`/`beforeRefresh`/`afterRefresh`/
`onCalcFields`/`onNewRecord`

These are exactly what a WML `<onevent type="...">` of each event type
compiles down to hooking — the event names map one-to-one to WML's
`type=` values (e.g. `type="afterscroll"` maps to `afterScroll`).

#### Usage example

```dart
// Walk the whole dataset, summing amounts that match a condition.
// disableControls/enableControls wraps the loop to avoid triggering a
// repaint on every single move.
double total = 0;
_sn.disableControls();
try {
  _sn.first();
  while (!_sn.eof) {
    if (_sn.fieldByName("active").asString == "1") {
      total += _sn.fieldByName("amount").asFloat;
    }
    _sn.next();
  }
} finally {
  _sn.enableControls();
}

// Append a record
_em.append();
_em.fieldByName("emp_name").asString = "New Employee";
_em.post();

// Locate a record by key value (single field)
if (_cu.locate("cno", "C001", {})) {
  print("Found customer: ${_cu.fieldByName('cname').asString}");
}

// Multi-field key, with an option (case-insensitive)
if (_sn.locate("sno;itm", ["S0001", 1], {TLocateOption.loCaseInsensitive})) {
  print("Found the detail row");
}
```

---

### The TField family

*File: `lazarus_db.dart`　Source: `fields.inc`*

`TStringField`/`TIntegerField`/`TFloatField`/`TDateField`/
`TDateTimeField`/`TTimeField`/`TBooleanField`/`TBCDField`/
`TFMTBCDField`/`TMemoField`/`TWideMemoField`/`TBlobField`/
`TCurrencyField`/`TLargeintField`/`TSmallintField`/`TWordField`/
`TAutoIncField`/`TGuidField`, etc., all inherit from `TField`.

#### `TField` shared properties (typed accessors, readable and writable)

| Property | Type | Description |
|---|---|---|
| `asString` | `String` | Read/write the field value as a string |
| `asInteger` | `int` | Read/write as an integer |
| `asFloat` | `double` | Read/write as a double |
| `asDateTime` | `DateTime` | Read/write as a date/time |
| `asBoolean` | `bool` | Read/write as a boolean |
| `isNull` | `bool` (read-only) | Whether the value is NULL |
| `displayLabel` | `String` | Corresponds to WML's `<field displaylabel=>` |
| `fieldName` | `String` (read-only) | The field's name |
| `dataType` | — | The field's data type |
| `required` | `bool` | Whether the field is required |
| `readOnly` | `bool` | Whether the field is read-only |
| `value` | `dynamic` | Generic access (type depends on the actual field) |

#### Usage example

```dart
// Read a field value (call whichever accessor matches the type you need)
final name = _em.fieldByName("emp_name").asString;
final hireDate = _em.fieldByName("hired").asDateTime;
final isActive = _cu.fieldByName("active").asBoolean;

// Check for NULL
if (_sn.fieldByName("remark").isNull) {
  print("Remark is empty");
}

// Write a field value (edit() or append() first, post() when done)
_em.edit();
_em.fieldByName("phone").asString = "02-1234-5678";
_em.post();
```

---

### TDataSource

*File: `lazarus_db.dart`*

The intermediary object that bridges a dataset to UI controls
(`TDBEdit`/`TDBGrid`, etc.).

| Member | Type/signature | Description |
|---|---|---|
| `dataSet` | `TDataSet?` (read/write) | The bound dataset |
| `enabled` | `bool` (read/write) | Whether the link is active |
| `state` | — (read-only) | The current state |
| `dataLinks` | — (read-only) | The registered data links |
| `dataLinkCount` | `int` (read-only) | Number of registered links |
| `edit()` | `void edit()` | Puts the underlying dataset into edit mode |
| `isLinkedTo(TDataSet)` | `bool` | Checks whether it's linked to the given dataset |

Usage:
```dart
// Create the data source, bound to a dataset
final _dsEm = TDataSource()..dataSet = _em;

// Wire up a UI control (TDBEdit/TDBGrid, etc. all reach the dataset via TDataSource)
TDBEdit(dataSource: _dsEm, dataField: "emp_name"),
TDBNavigator(dataSource: _dsEm),

// Re-bind to a different dataset (e.g. reusing the same input fields on another tab)
_dsEm.dataSet = _otherDs;
```

---

### TSQLQuery

*File: `lazarus_sqldb.dart`　Source: `sqldb.pp`*

`class TSQLQuery extends TCustomSQLQuery` — inherits all of
`TDataSet`'s API (above), plus:

| Member | Type/signature | Description |
|---|---|---|
| **Async open** | `Future<void> openAsync()` | **This is the one to use in a Web/HTTP environment** — `open()` is the synchronous interface (kept for parity with the Lazarus API), while `openAsync()` genuinely waits for the HTTP response. Every dataset produced by `dbquery()` should use this |
| SQL text | `TStrings get sql` | `.text = '...'` to set/read the SQL statement |
| Parameter collection | `TParams get params` | Matched in the order `:paramName` appears; `params[0].asString = ...` |
| Apply updates (sync signature) | `void applyUpdates(...)` | |
| Apply updates (explicitly async) | `Future<void> applyUpdatesAsync(...)` | Sends the accumulated INSERT/UPDATE/DELETE back to the database |
| `alwaysUpdateable` | `bool` (read/write) | Set to `true` so the dataset is always treated as updateable (datasets produced by `dbquery()` default to this) |

Usage (excerpted from the main `README.md`'s "From WML to this API"):
```dart
late final TSQLQuery _em = dbquery("em", r"select * from employees", define: (ds) {
  _key(ds, "emp_no",   "employee_id");
  _fld(ds, "emp_name", "name");
});
```

---

### TWapSQLConnection

*File: `lazarus_sqldb.dart` (original code, not a translation)*

A bridging connection class that talks to the backend over HTTP via
`WapDb`, since a browser can't open a native TCP connection to a
database directly.

| Method | Signature | Description |
|---|---|---|
| Async open connection | `Future<void> openAsync()` | |
| Async execute SQL | `Future<...> execSQLAsync(...)` | |
| Async apply updates | `Future<void> applyUpdatesAsync(...)` | |
| Async refresh | `Future<void> refreshAsync(...)` | |
| Commit | `void commit()` / `void commitRetaining()` | |
| Roll back | `void rollBack()` / `void rollBackRetaining()` | |
| Start transaction | `void startDBTransaction()` | |
| Get affected row count | `int rowsAffected()` | |
| Pending queue count | `int get pendingCount` (read-only) | |
| Flush pending queue | `void flushPending()` | |

Usage:
```dart
TWapSQLConnection(null, const WapDbBridgeDriver())
  ..databaseName = 'ag';
```

---

### WapDb

*File: `lazarus_sqldb.dart` (original code, static utility class)*

Responsible for the actual HTTP requests to the `server.js` gateway.

| Method | Signature | Description |
|---|---|---|
| Health check | `static Future<bool> ping()` | Checks whether the gateway is reachable; `example/lib/main.dart`'s home screen uses this to decide whether to show "Connected" |

(`WapDb` also has internal methods that handle the actual SQL
request/response, called by `TWapSQLConnection` — not normally used
directly at the application layer.)

#### Usage example

```dart
// Confirm the backend gateway is reachable before showing the main
// screen on app startup.
final ok = await WapDb.ping();
if (ok) {
  print("Connected to the WapDb gateway");
} else {
  print("Cannot reach the WapDb gateway at http://localhost:3000");
}
```

---

### TSQLTransaction

*File: `lazarus_sqldb.dart`*

Used together with `TSQLConnection`/`TWapSQLConnection`;
`applyUpdates`/`applyUpdatesAsync` wraps a transaction scope through
it internally. Typical usage just needs to create it and set
`database`:
```dart
final tx = TSQLTransaction()..database = connection;
```

---

### Data-bound controls

*File: `lazarus_dbctrls.dart`　Source: `dbctrls.pp`*

Four classes sharing the same pattern: `dataSource` + `dataField`
binding, extending `StatefulWidget`, with the constructor parameters
being the usable properties.

#### TDBEdit (single-line text input, maps to `<input field=...>`)

| Constructor parameter | Type | Description |
|---|---|---|
| `dataSource` | `TDataSource` | Required |
| `dataField` | `String` | Required, the bound field name |
| `readOnly` | `bool` | |
| `maxLength` | `int?` | |
| `maxLines` / `minLines` | `int?` | |
| `expands` | `bool` | |
| `autofocus` | `bool` | |
| `focusNode` | `FocusNode?` | |
| `font` | — | |
| `textAlign` | `TextAlign?` | |

#### TDBMemo (multi-line text input, maps to `<input field=... type="memo">`)

Constructor parameters: `dataSource`, `dataField`, `readOnly`,
`maxLength`, `lines`, `autofocus`, `focusNode`, `font`.

#### TDBRadioGroup (a bound field's option group, maps to `<select field=...>`)

Constructor parameters: `dataSource`, `dataField`, `caption`, `items`
(display-text list), `values` (values written back, matched by index
to `items`), `columns`, `width`, `height`, `readOnly`, `font`.

#### TDBNavigator (the full CRUD button bar, maps to `<navigator/>`)

| Constructor parameter | Type | Description |
|---|---|---|
| `dataSource` | `TDataSource` | Required |
| `visibleButtons` | — | Controls which buttons are shown |
| `confirmDelete` | `bool` | Whether to confirm before deleting |
| `onNavClick` | callback | Fires when any button is tapped |
| `onInsertAsync` | callback | Async hook on insert (e.g. auto-filling the master key on continuous entry) |
| `onPostAsync` | callback | Async hook on save |
| `onDeleteAsync` | callback | Async hook on delete |

#### Usage example

```dart
final _dsEm = TDataSource()..dataSet = _em;

// Single-line text input
TDBEdit(
  dataSource: _dsEm,
  dataField: "emp_name",
),

// Multi-line text input (remarks-type field)
TDBMemo(
  dataSource: _dsEm,
  dataField: "remark",
  lines: 4,
),

// Bound field's option group; items and values are matched by index
TDBRadioGroup(
  dataSource: _dsEm,
  dataField: "gender",
  caption: "Gender",
  items: const ["Male", "Female"],
  values: const ["M", "F"],
  columns: 2,
),

// The full CRUD button bar
TDBNavigator(
  dataSource: _dsEm,
  confirmDelete: true,
  onPostAsync: () async {
    await _em.applyUpdatesAsync();
  },
),
```

---

### Grid-related classes

*File: `lazarus_dbgrids.dart` (`TColumn`/`TDBGrid`/`TDBGridColumns`)
and `lazarus_grids.dart` (the `TGridColumn` base)*

#### TGridColumn (`TColumn`'s base class, defined in `lazarus_grids.dart`)

| Property | Type | Description |
|---|---|---|
| `width` | `double` (read/write) | Column width |
| `title` | `TGridColumnTitle` (read/write) | The title object; `.caption` sets the display text |
| `alignment` | — (read/write) | Alignment |
| `visible` | `bool` (read/write) | Whether shown |
| `readOnly` | `bool` (read/write) | Whether read-only |
| `color` | — (read/write) | Cell background color |
| `font` | — (read/write) | |
| `maxSize` / `minSize` | `double` (read/write) | |
| `sizePriority` | — (read/write) | |
| `pickList` | — (read/write) | Dropdown option list |
| `valueChecked` / `valueUnchecked` | — (read/write) | For checkbox-style fields |
| `layout` | — (read/write) | |

#### TColumn (`extends TGridColumn`)

**The constructor is not the named-parameter style** — it's the
Lazarus pattern of "construct, then set properties":

```dart
final c = cols.add();       // TDBGridColumns.add() returns a new TColumn
c.fieldName = "pno";
c.width = 112;
c.title.caption = "Item No.";
```

`TColumn`'s own additional members:

| Member | Type/signature | Description |
|---|---|---|
| `fieldName` | `String` (read/write) | The bound field name |
| `field` | `TField?` (read/write) | The bound field object (usually derived from `fieldName` automatically; rarely set by hand) |
| `dataSet` | `TDataSet?` (read-only) | Obtained via the owning `TDBGrid`'s `dataLink` |
| `displayFormat` | `String` (read/write) | The display format string |
| `displayName` | — (read-only) | |
| `isAutomaticColumn` | `bool` (read/write) | Whether it was auto-generated (when `.add()` isn't called by hand, the grid builds columns automatically from the dataset's fields) |
| `isDesignColumn` | `bool` (read-only) | |
| `designIndex` | `int` (read-only) | |
| `linkField()` | `void linkField()` | Re-links `field` to the corresponding `TField` on the dataset |
| `getDefaultAlignment()` / `getDefaultWidth()` / `getDefaultReadOnly()`, etc. | — | Internal methods that derive default styling from the field type |

#### TDBGridColumns (a collection of `TColumn`)

| Method | Signature | Description |
|---|---|---|
| Add a column | `TColumn add()` | Returns the newly created `TColumn`; set its properties next |
| Find column by field name | `TColumn? columnByFieldname(String name)` | |
| Find column by title | `TColumn? columnByTitle(String title)` | |
| Find column by `TField` | `TColumn? columnFromField(TField field)` | |
| Whether it has automatic columns | `bool hasAutomaticColumns()` | |
| Whether it has manually designed columns | `bool hasDesignColumns()` | |
| Re-link all columns | `void linkFields()` | |
| Remove automatic columns | `void removeAutoColumns()` | |
| Reset column order | `void resetColumnsOrder()` | |

#### TDBGrid

| Constructor parameter | Type | Description |
|---|---|---|
| `dataSource` | `TDataSource` | Required |
| `columns` | `TDBGridColumns?` | Auto-generated from the dataset's fields if not given |
| `width` / `height` | `double?` | |
| `readOnly` | `bool` | |
| `options` | — | Grid behavior options |
| `lookupResolver` | `TDBGridLookupResolver?` | The resolver callback for field lookups — see the `WapLookupBox` section below |
| `onRowInsert` | callback | Fires on continuous entry (Tab past the last cell auto-adds the next row) |
| `onRowPost` | callback | Fires when a detail row is saved |
| `onRowActivate` | callback | |
| `onExitLastRow` | callback | Fires when Tab leaves the last cell of the last row |

Other read-only properties: `dataLink`, `defaultColWidth`, `isLoading`.

#### Full usage example (all three classes together)

```dart
// 1. Prepare the data source (the detail dataset, e.g. shipment order line items)
final _dsSn = TDataSource()..dataSet = _sn;

// 2. Build the column collection, one column at a time
final _snCols = TDBGridColumns();

final colPno = _snCols.add()
  ..fieldName = "pno"
  ..width = 112
  ..title.caption = "Item No.";

_snCols.add()
  ..fieldName = "qty"
  ..width = 64
  ..alignment = TAlignment.taRightJustify
  ..title.caption = "Quantity";

_snCols.add()
  ..fieldName = "price"
  ..width = 72
  ..alignment = TAlignment.taRightJustify
  ..title.caption = "Unit Price";

_snCols.add()
  ..fieldName = "remark"
  ..width = 96
  ..readOnly = false
  ..title.caption = "Remarks";

// 3. Build the grid itself: wire up the data source, columns, and a
//    lookup resolver (so the item-number column can pop up a lookup
//    dialog — see the WapLookupBox section)
TDBGrid(
  dataSource: _dsSn,
  columns: _snCols,
  height: 240,
  lookupResolver: (fieldName) => fieldName.toLowerCase() != "pno"
      ? null
      : TDBGridLookupSpec(
          rows: _paLookupRows,      // { "P001": ["P001","Widget A"], ... }
          colWidths: const [80, 160],
        ),
  // Tab past the last row's last column auto-adds the next row (continuous entry).
  // ⚠️ Don't call ds.insert() directly -- adding a detail row needs to
  // check the master record and carry over its document number first,
  // which is why this must go through the page's own onnewrecord
  // handler (here, the _snInsert() that <onevent type="onnewrecord">
  // compiles to).
  onRowInsert: () async => _snInsert(),
  // Fires when an inline edit's row post completes (no parameters, just
  // a completion notification)
  onRowPost: () async {
    _recalcShAmount();
  },
),
```

This example corresponds to the main `README.md`'s "From WML to this
API" section's master-detail example (shipment order `sh`/line items
`sn`) — the simplified snippet there is fully spelled out here,
showing how the three classes (`TDBGridColumns`, `TColumn`,
`TDBGrid`) actually assemble into an editable, lookup-capable, and
continuously-enterable data grid.

---

## WapForm Layer

### WapEvaluator

*File: `wapform_expression.dart` (original code)*

The core class behind every `$(...)` expression in a WML file — the
lexer/parser/evaluator.

| Member | Type/signature | Description |
|---|---|---|
| Evaluate | `dynamic eval(String expr)` | Evaluates any expression, returns the result |
| Evaluate (no-throw version) | `dynamic evalNul(String expr)` | Returns `null` on error instead of throwing |
| Evaluate a boolean condition | `bool cond(String expr)` | Corresponds to WML's `cnd=` attribute |
| Read a variable | `dynamic getVar(String name)` | |
| Write a variable | `void setVar(String name, dynamic value)` | |
| Set the current row | `void setRow(...)` | Switches the "current data row" that expression evaluation references (e.g. accessing a dataset field like `em.eno`) |
| Register a dataset | `void registerDataSet(String id, TDataSet ds)` | |
| Unregister | `void unregisterDataSet(String id)` | |
| Clear all variables | `void clearVars()` | |
| Clear all dataset registrations | `void clearDataSets()` | |
| Whether there's an error | `bool get hasError` (read-only) | |
| Last error message | `String lastError` | |
| Dataset resolver | `set datasetResolver(...)` | Lets the evaluator dynamically resolve an external dataset "declared on a different card" |

**Top-level helper functions (module-level, not class methods):**
`setvar(name, value)` (corresponds to `<setvar>`), `condition(String
expr)` (corresponds to `cnd=`), `expression(String expr)` (general
expression interpolation), `expandText(String template)` (expands
`$(...)` interpolation syntax in a string, used together with
`emit`/`emitRow` in almost every report).

#### Usage example

```dart
final ev = WapEvaluator();
ev.registerDataSet("em", _em);

// Evaluate (corresponds to <setvar value="...">)
ev.setVar("TOTAL", 0);
final result = ev.eval("TOTAL+em.salary");

// Evaluate a boolean condition (corresponds to <if cnd="...">)
if (ev.cond("em.active='1' AND em.salary>30000")) {
  print("Matches the condition");
}

// Expand string interpolation (the common pattern inside a report's emitRow)
final html = expandText(r'''<p>$(em.emp_name) - $(FORMAT('%.2f',em.salary))</p>''');
```

---

### DataSetRegistry

*File: `wapform_lazarus.dart` (original code)*

The registry of every dataset already opened within a page (State),
accessed by a string id.

| Method | Signature | Description |
|---|---|---|
| Register | `void put(String id, TDataSet ds)` | |
| Find | `TDataSet? find(String id)` | Returns `null` if not found |
| Find (`TSQLQuery`-typed) | `TSQLQuery? findQuery(String id)` | Used by the `ds_foreign` "dataset declared on a different card" access pattern |
| Contains | `bool contains(String id)` | |
| Resolve (via the dynamic resolver) | `TDataSet? resolveDataSet(String id)` | |
| Release one dataset | `void release(String id)` | |
| Release all | `void releaseAll()` | Called on logout/page dispose, closing and releasing every registered dataset at once |
| Registered count | `int get count` (read-only) | |
| Registered id list | `List<String> get registeredIds` (read-only) | |

This is the mechanism behind how compiled-out code accesses a
"dataset declared on a different card" (a `foreign` dataset) — a
pattern like `TSQLQuery get _cu => _reg.findQuery("cu")!` goes through
this class.

#### Usage example

```dart
final reg = DataSetRegistry();
reg.put("em", _em);

// Another card reuses the same already-open dataset instead of re-querying
TSQLQuery get _cu => reg.findQuery("cu")!;

// Release everything together on page dispose
@override
void dispose() {
  reg.releaseAll();
  super.dispose();
}
```

---

### DbQuery

*File: `wapform_lazarus.dart` (original code)*

Corresponds to WML's `<dbquery>` tag — the implementation behind the
`dbquery()` helper method every page State has.

| Member | Type/signature | Description |
|---|---|---|
| `connection` | `TWapSQLConnection` | |
| `registry` | `DataSetRegistry` | |
| `databaseName` | `String` | |
| Query | `TSQLQuery query(String id, String sql, ...)` | Created on the first call for a given id, reused on subsequent calls |
| Execute | `Future<void> exec(String sql)` | Runs non-query SQL |

#### Usage example

```dart
// Every page State typically has a wrapped dbquery() helper method
// (see the main README's "From WML to this API" section); internally
// it calls DbQuery.query():
late final TSQLQuery _em = dbquery("em", r"select * from employees", define: (ds) {
  _key(ds, "emp_no",   "employee_id");
  _fld(ds, "emp_name", "name");
});

// Calling with the same id a second time returns the same object,
// without re-creating the query.
final same = dbquery("em", "");  // an empty sqlText means "reuse the existing one"
```

---

### WapLookupBox

*File: `wapform_lookup_box.dart` (original code)*

The unified lookup-dropdown widget, usable either as a standalone
field or as a `TDBGrid` cell editor (wired up via `TDBGrid`'s
`lookupResolver` parameter).

| Constructor parameter | Type | Description |
|---|---|---|
| `dataSet` | `TDataSet` | The lookup source dataset |
| `keyField` | `String` | The lookup source's key field |
| `displayFields` | `List<String>` | Fields shown in the dropdown list (can be more than one) |
| `colWidths` | `List<double>` | Display width for each of `displayFields` |
| `value` | `String?` | The currently selected key |
| `onChanged` | callback | Fires when the value changes |
| `onPicked` | `void Function(String key)?` | Fires after the user picks a value (one of the hooks for `<onevent type="onchange">`) |
| `forGrid` | `bool` | Whether it's being used as a `TDBGrid` cell editor |
| `readOnly` | `bool` | |
| `width` / `height` | `double?` | |
| `autofocus` | `bool` | |
| `textStyle` | — | |
| `onTab` / `onTabPrev` | callback | Fires when focus moves via Tab/Shift+Tab |
| `tapRegionGroupId` | — | Used to group tap regions for the dropdown menu |

Corresponds to WML's `<input lookup=>`/`<dbtable>` lookup
functionality; also the component used internally by
`TDBGridLookupSpec` (see the `TDBGrid` section above).

#### Usage example

```dart
// Standalone field: on the customer master screen, look up a shipper
// code and auto-display its name
WapLookupBox(
  dataSet: _fm,               // shipper master
  keyField: "fno",
  displayFields: const ["fno", "fname"],
  colWidths: const [60, 160],
  value: _cu.fieldByName("fno").asString,
  onPicked: (key) {
    _cu.edit();
    _cu.fieldByName("fno").asString = key;
    _cu.post();
  },
),
```

---

### WapFilter / FilterItem

*File: `wapform_filter.dart` (original code)*

#### WapFilter

| Constructor parameter | Type | Description |
|---|---|---|
| `items` | `List<FilterItem>` | The definition of each filter field |
| `sqlTemplate` | `String` | An SQL template containing the literal `$R` token, which the user-entered condition replaces |
| `onQuery` | callback | Fires with the assembled SQL after the user presses Search/Clear |
| `width` | `double?` | |
| `borderColor` | — | |

Corresponds to WML's `<dbfilter>`. The search logic auto-detects based
on what the user typed: exact match / range / starts-with / ends-with
/ contains.

#### FilterItem

| Property | Type | Description |
|---|---|---|
| `field` | `String` | Field name |
| `label` | `String` | Display label (from the dataset field's `displaylabel`) |
| `size` | `int` | Input box width |

#### Usage example

```dart
WapFilter(
  items: const [
    FilterItem(field: "cno", label: "Customer Code", size: 12),
    FilterItem(field: "cname", label: "Customer Name", size: 20),
  ],
  sqlTemplate: r"select * from cu where $R order by cno",
  onQuery: (sql) {
    _cu.close();
    _cu.sql.text = sql;
    _cu.openAsync();
  },
),
```

---

### WapReport

*File: `wapform_report.dart` (original code)*

`abstract class WapReport` — application code subclasses this to
write report logic. It is **not** `WapPage`'s subclass or parent
class — they're two independent classes that work together
(`WapPage` is responsible for displaying/hosting a `WapReport`
instance; see the `WapPage` section below).

#### The core method to override

```dart
@override
void parseBlock(String id) {
  switch (id) {
    case 'PREFIX':       ...   // start of the whole report (runs once)
    case 'PAGEPREFIX':   ...   // start of each page
    case 'G1_PREFIX':    ...   // start of level-1 group
    case 'RECORD':       ...   // each detail row (innermost, no change=)
    case 'G1_SUFFIX':    ...   // end of level-1 group
    case 'PAGESUFFIX':   ...   // end of each page
    case 'SUFFIX':       ...   // end of the whole report (runs once)
    case 'PAGEBREAK':    ...   // fires on a page break (for reprinting headers)
  }
}
```

#### Output methods

| Method | Signature | Description |
|---|---|---|
| **Line-counted output** | `void emitRow(String html, {bool isHeader, bool isFooter})` | **Use this for almost everything** — automatically counts how many lines the current page has printed, and auto-triggers a page break when full (calling `parseBlock('PAGEBREAK')` to reprint the header); internally calls `emit()`. In real generator output, `PREFIX`/`PAGEPREFIX`/every `G*_PREFIX`/`RECORD`/every `G*_SUFFIX`/`PAGESUFFIX` almost all call this |
| **Non-counted output** | `void emit(String text, {bool isHeader, bool isFooter, String tag})` | **Advanced usage** — output that doesn't count toward the page's line total and doesn't trigger page-break logic. Used in a handful of situations, e.g. the outermost report frame's closing tags "deferred to the last page," to keep content visually inside the frame |

#### Other methods

| Method | Signature | Description |
|---|---|---|
| Force a page break | `void forcePageBreak()` | Corresponds to WML's `<newpage/>` |
| Prepare group data | `Future<void> onGroupPrepare()` | Any query needing an async open (a `<dbquery>` inside group logic) is prepared here, since `parseBlock()` itself can't be `async` |
| Evaluate an expression | `dynamic expression(String expr)` | Used to insert an expression's result inside a report block |
| Build HTML | `String buildHtml()` | Assembles the whole report into a final HTML string |
| Build PDF | `Future<Uint8List> buildPdf()` | See the relevant limitations noted in the main `README.md`'s "Platform Support" section |
| Move to the first record | `void fetchFirst()` | |
| Move to the next record | `void fetchNext()` | |
| Move to the prior record | `void fetchPrior()` | |
| Initialize parameters | `void initParams()` | |
| Run the report | `void run()` | Drives the whole report flow's main loop |
| Lines per record | `int get linesPerRecord` (read-only, default 1) | Subclasses can override so the framework knows how many `emitRow()` calls one detail record translates into |

---

### WapPage

*File: `wapform_report.dart` (original code)*

`class WapPage extends StatefulWidget` — the Flutter widget that
displays/hosts a `WapReport` instance, handling pagination browsing,
on-screen preview, and the print button.

| Constructor parameter | Type | Description |
|---|---|---|
| `title` | `String` (required) | |
| `report` | `WapReport?` | The report instance to display; **exactly one of this and `src` must be given** (enforced by an `assert` in the constructor) |
| `src` | `String?` | An alternate source for demo/example purposes; **exactly one of this and `report` must be given** |
| `paper` | `String` (default `'A4'`) | Paper size (named, like `A4`/`letter`, or a custom `"WIDTHxHEIGHT"` in inches, e.g. `8.5x5.5`) |
| `orient` | `String` (default `'P'`) | Portrait/landscape; landscape accepts `L`/`landscape`/`橫`/`水平`/`1` (case-insensitive; see the main README's Platform Support section) |
| `fontAsset` | `String` (default `'assets/fonts/NotoSansTC-Regular.ttf'`) | The font asset path used to embed Chinese fonts in PDF output |
| `showPrint` | `bool` (default `true`) | Whether to show the print button |
| `padding` | `EdgeInsets` (default `all(16)`) | |
| `htmlStyle` | `Map<String, Style>?` | A custom stylesheet passed to `flutter_html` |

#### Usage example

```dart
// Used together with the ShStatement class defined in the WapReport section above
showDialog(
  context: context,
  builder: (_) => Dialog(
    child: WapPage(
      title: "Accounts Receivable Statement",
      report: ShStatement(),
      paper: "A4",
      orient: "P",
    ),
  ),
);
```

---

### WapColors

*File: `wapform_colors.dart` (original code, static utility class)*

Resolves the zebra-stripe CSS classes used by reports and grids.

| Member | Type/signature | Description |
|---|---|---|
| Load settings | `static Future<void> load({String asset})` | Parses the color scheme from a shared asset file (default `assets/wapform.htm`); falls back to built-in defaults on failure |
| Get a Flutter Color | `static Color flutter(String cls)` | |
| Get a CSS hex code | `static String hex(String cls)` | |
| Known class list | `static List<String> get classes` (read-only) | |
| Convenience properties | `trRow`/`trRow1`/`trRow2`/`tdRow1`/`tdRow2`/`tdRow3` (all `Color`, read-only) | |
| Convenience properties (CSS versions) | `hexTrRow`/`hexTrRow1`/`hexTrRow2` (all `String`, read-only) | |

#### Usage example

```dart
// Load the color scheme once on app startup
await WapColors.load();

// Grid zebra striping (used inside TColumn or custom paint logic)
final bgColor = rowIndex.isEven ? WapColors.trRow1 : WapColors.trRow2;

// Directly using the hex color code in report CSS
final css = '.row2 { background: ${WapColors.hexTrRow2}; }';
```

