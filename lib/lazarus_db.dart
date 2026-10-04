// ═════════════════════════════════════════════════════════════════════════════
//  lazarus_db.dart
//
//  This file is a Dart translation (derivative work) of the following Object Pascal upstream source:
//    Upstream project: Free Pascal RTL / FCL-DB
//    Upstream files: db.pas, dataset.inc, fields.inc, datasource.inc, database.inc, dsparams.inc, dbconst.pas
//
//  Upstream copyright:
//   Copyright (c) 1999-2000 by Michael Van Canneyt
//   Copyright (c) 2004-2024 by the Free Pascal development team
//
//  License: GNU Lesser General Public License v2.1, with the static linking exception
//        (Modified LGPL, same as upstream FPC/Lazarus)
//        See the accompanying COPYING.LGPL.txt and COPYING.modifiedLGPL.txt.
//
//  Modification notice (required by LGPL section 2):
//    This file is a language translation from Object Pascal to Dart, with adjustments for the Flutter platform.
//    Every place that deviates from upstream is marked with a block tag:
//      // aa !!! not fully translated — upstream source unavailable, or the platform fundamentally can't do this
//      // aa ??? issue          —— deviates from upstream behavior to fix a defect
//      // aa ### flutter extension —— a feature added for Flutter that upstream doesn't have
//
//  Translation: Copyright (c) 2026 Minhong Information Co., Ltd. (wapform.com)
// ═════════════════════════════════════════════════════════════════════════════

// ═════════════════════════════════════════════════════════════════════════════
//  lazarus_db.dart —— full line-by-line translation of FPC db.pas (including all .inc files), single file
//  ─────────────────────────────────────────────────────────────────────────
//  Corresponds to (FPC RTL / FCL-DB):
//    db.pas        2,723 lines  unit interface declarations + implementation global functions
//    dataset.inc   2,527 lines  TDataSet / TFieldDef(s) implementation
//    fields.inc    3,657 lines  TField and all subclasses / TFields / TIndexDefs implementation
//    datasource.inc 719 lines  TDataLink / TDataSource implementation
//    database.inc   777 lines  TDatabase / TDBTransaction / TCustomConnection implementation
//    dsparams.inc  1,270 lines  TParam / TParams implementation
//    dbconst.pas    134 lines  error-message resourcestrings
//    (fpmake.inc is a build-configuration list, not code, excluded)
//
//  The file is organized into sections following the upstream source's structure:
//    SECTION 0   FCL/RTL base-class shims (source not provided, minimal implementation)
//    SECTION 1   dbconst.pas error-message constants + formatMsg
//    SECTION 2   db.pas constants / enums / exceptions (L25-130)
//    SECTION 3   TNamedItem / TDefCollection / TFieldDef / TFieldDefs
//    SECTION 4   TLookupList / TField
//    SECTION 5   all TField subclasses (TStringField…TGuidField)
//    SECTION 6   TIndexDefs / TCheckConstraints / TFields
//    SECTION 7   TParam / TParams
//    SECTION 8   TDataSet and supporting types (the buffer-window mechanism fully preserved)
//    SECTION 9   TDataLink / TDetailDataLink / TMasterDataLink /
//                TMasterParamsDataLink / TDataSource
//    SECTION 10  TDBDataset / TDBTransaction / TCustomConnection / TDatabase
//    SECTION 11  global functions in db.pas's implementation section
//
//  ─────────────────────────────────────────────────────────────────────────
//  ??? Fixed Pascal→Dart translation conventions (apply to the whole file, not re-annotated at each individual spot):
//
//  1. Pointers/memory: the TRecordBuffer=PAnsiChar, GetMem/FreeMem/Move toolkit
//     has no Dart equivalent. Buffers are uniformly replaced with a TRecordBuffer class (internally
//     a Map<String,dynamic> holding field values + extra attached bookmark/flag data),
//     but the "buffer window" architecture (AllocRecordBuffer/ActiveBuffer/
//     GetBuffer/BufferCount/FirstRecord offset arithmetic) is fully preserved,
//     with no simplification of behavior.
//  2. class of X (metaclass): Dart has no class references, so a factory function
//     typedef is used instead (e.g. TFieldClass = TField Function()).
//  3. Variant → dynamic; Null/Unassigned → null (Pascal distinguishes the two,
//     Dart merges them into null — a known difference).
//  4. TDateTime → Dart DateTime (Pascal is a double counted from 1899-12-30;
//     date-serial arithmetic is converted in place where needed). Currency → double.
//  5. TBCD (the FmtBCD unit, source not provided) → double, a known precision-semantics difference.
//  6. TEditMask (the MaskUtils unit, source not provided) → String (stored only, not applied).
//  7. set of X → Set<X>；resourcestring → const String；
//     Format('%s',[..]) → formatMsg()（SECTION 1）。
//  8. Naming conventions follow this project's existing port: class/enum-value names keep the original
//     Pascal names (TField, ftString, dsBrowse); method/property names become lowerCamelCase
//     （Open→open、FieldByName→fieldByName）。
//  9. Destructor Destroy → destroy() (calls preserved wherever cleanup of a link/relationship is needed;
//     the memory itself is left to Dart's GC). Free → free() (= the safe version of destroy()).
//  10. {$IFDEF} (FPC/Delphi compatibility branches) uniformly takes the FPC mainline branch.
//  11. deprecated members are translated and annotated as such, never silently dropped.
//
//  This file is self-contained and doesn't import the project's other lazarus_* files (those are the earlier
//  simplified foundation, still used by rcp078.dart; the two sides share class names and must not be imported together).
// ═════════════════════════════════════════════════════════════════════════════

import 'dart:typed_data';

// aa !!! not fully translated
// ─────────────────────────────────────────────────────────────────────────
//  SECTION 0 is a "shim", not a translation of upstream source —
//  db.pas's classes inherit from FCL/RTL's TPersistent / TCollection / TComponent /
//  TStrings / TStream, but the source for those units (classes.pp, sysutils.pas) wasn't available.
//  This only provides "the subset db.pas actually uses", a minimally usable implementation.
//
//  Known gaps:
//    - TStrings.AddObject: the attached-object slot isn't implemented, only the string is added.
//    - format(): only supports %s / %d / %f, no width/precision modifiers (like %-10.2f).
//    - TStream / TComponent: only the minimal surface db.pas actually uses, not full FCL behavior.
//  TODO: replace section by section once classes.pp / sysutils.pas are obtained.
// ─────────────────────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 0 —— FCL/RTL base-class shims
//  db.pas's classes inherit from FCL's TPersistent/TCollection/TComponent/
//  TStrings/TStream; those units (classes.pp/sysutils) are outside this
//  upload's scope — this provides a minimal implementation of "the subset db.pas actually uses".
// ═════════════════════════════════════════════════════════════════════════════

// ---- Event typedefs (classes.pp) ---------------------------------------------
typedef TNotifyEvent = void Function(Object sender);

// ---- TOperation / TComponentState（classes.pp）-----------------------------
enum TOperation { opInsert, opRemove }

enum TComponentStateItem { csLoading, csReading, csDesigning, csDestroying }

typedef TComponentState = Set<TComponentStateItem>;

// ---- TSeekOrigin（classes.pp）-----------------------------------------------
enum TSeekOrigin { soBeginning, soCurrent, soEnd }

// ---- TPersistent（classes.pp）-----------------------------------------------
class TPersistent {
  // Assign: by default throws the other side's AssignTo back at it; if neither side overrides it, it throws —
  // same semantics as classes.pp's TPersistent.Assign/AssignError.
  void assign(TPersistent? source) {
    if (source != null) {
      source.assignTo(this);
    } else {
      throw EDatabaseError("Cannot assign a nil source");
    }
  }

  void assignTo(TPersistent dest) {
    throw EDatabaseError(
        "Cannot assign a $runtimeType to a ${dest.runtimeType}");
  }
}

// ---- TCollectionItem / TCollection / TOwnedCollection（classes.pp）---------
class TCollectionItem extends TPersistent {
  TCollection? _collection;

  TCollectionItem(TCollection? aCollection) {
    if (aCollection != null) {
      collection = aCollection;
    }
  }

  TCollection? get collection => _collection;
  set collection(TCollection? value) {
    if (identical(_collection, value)) return;
    _collection?._items.remove(this);
    _collection = value;
    value?._items.add(this);
    // classes.pp：InsertItem → Notify(cnAdded) → SetItemName
    value?.setItemName(this);
    changed(false);
  }

  int get index => _collection?._items.indexOf(this) ?? -1;
  set index(int value) {
    final c = _collection;
    if (c == null) return;
    final cur = c._items.indexOf(this);
    if (cur < 0 || cur == value) return;
    c._items.removeAt(cur);
    c._items.insert(value, this);
    changed(false);
  }

  // ID: classes.pp uses an incrementing sequence number; here the index at insertion time is used as an approximation
  // (db.pas doesn't rely on ID's uniqueness — only TParam uses it as a display-name fallback).
  int get id => index;

  String get displayName => runtimeType.toString();
  set displayName(String value) {
    changed(false);
  }

  void changed(bool allItems) {
    _collection?._update(allItems ? null : this);
  }

  void free() {
    collection = null;
  }
}

// class of TCollectionItem → a factory function (translation convention 2)
typedef TCollectionItemFactory = TCollectionItem Function(
    TCollection aCollection);

class TCollection extends TPersistent {
  final TCollectionItemFactory itemFactory;
  final List<TCollectionItem> _items = [];
  int _updateCount = 0;

  TCollection(this.itemFactory);

  int get count => _items.length;
  TCollectionItem getItem(int index) => _items[index];
  void setItem(int index, TCollectionItem value) {
    _items[index].assign(value);
  }

  TCollectionItem add() {
    final item = itemFactory(this);
    // Inside itemFactory (TCollectionItem's constructor) the item has already been attached to
    // _items, corresponding to classes.pp's Add=Create(Self) behavior.
    _update(item);
    return item;
  }

  void clear() {
    beginUpdate();
    try {
      while (_items.isNotEmpty) {
        _items.last.free();
      }
    } finally {
      endUpdate();
    }
  }

  void delete(int index) {
    _items[index].free();
    _update(null);
  }

  int indexOf(TCollectionItem item) => _items.indexOf(item);

  void beginUpdate() {
    _updateCount++;
  }

  void endUpdate() {
    if (_updateCount > 0) _updateCount--;
    if (_updateCount == 0) _update(null);
  }

  bool get updating => _updateCount > 0;

  void _update(TCollectionItem? item) {
    if (_updateCount == 0) update(item);
  }

  // Update: left for subclasses to override (TFieldDefs.Update, etc.)
  void update(TCollectionItem? item) {}

  // SetItemName: a naming hook fired when an item is attached to the collection (classes.pp's base is
  // an empty implementation; TDefCollection overrides it to fill in a default name for unnamed items)
  void setItemName(TCollectionItem item) {}

  TPersistent? get owner => null;

  @override
  void assign(TPersistent? source) {
    if (source is TCollection) {
      beginUpdate();
      try {
        clear();
        for (var i = 0; i < source.count; i++) {
          add().assign(source.getItem(i));
        }
      } finally {
        endUpdate();
      }
      return;
    }
    super.assign(source);
  }
}

class TOwnedCollection extends TCollection {
  final TPersistent? _owner;

  TOwnedCollection(this._owner, TCollectionItemFactory itemFactory)
      : super(itemFactory);

  @override
  TPersistent? get owner => _owner;
}

// ---- TComponent (a subset of classes.pp) -------------------------------------------
class TComponent extends TPersistent {
  String _componentName = '';
  // Name: TDataSet.SetName needs to override this, so it's implemented as a getter/setter instead
  String get name => _componentName;
  set name(String value) => _componentName = value;

  TComponent? _owner;
  final List<TComponent> _components = [];
  final TComponentState componentState = <TComponentStateItem>{};
  // The FreeNotification list: objects to notify when componentA is freed
  final List<TComponent> _freeNotifies = [];

  TComponent([TComponent? aOwner]) {
    _owner = aOwner;
    aOwner?._components.add(this);
  }

  TComponent? get owner => _owner;
  int get componentCount => _components.length;
  TComponent components(int index) => _components[index];

  // FindComponent (classes.pp): finds an owned component by name
  TComponent? findComponent(String aName) {
    for (final c in _components) {
      if (c.name.toUpperCase() == aName.toUpperCase()) return c;
    }
    return null;
  }

  void freeNotification(TComponent aComponent) {
    if (!_freeNotifies.contains(aComponent)) {
      _freeNotifies.add(aComponent);
    }
  }

  void removeFreeNotification(TComponent aComponent) {
    _freeNotifies.remove(aComponent);
  }

  // Notification: a hook fired when a component is inserted/removed; db.pas uses it to clean up
  // references between DataSource/DataSet, overridden by subclasses.
  void notification(TComponent aComponent, TOperation operation) {}

  void destroy() {
    componentState.add(TComponentStateItem.csDestroying);
    // First notifies objects registered via FreeNotification
    for (final c in List<TComponent>.from(_freeNotifies)) {
      c.notification(this, TOperation.opRemove);
    }
    _freeNotifies.clear();
    // Frees the components it owns itself
    while (_components.isNotEmpty) {
      _components.last.free();
    }
    _owner?._components.remove(this);
    _owner = null;
  }

  void free() => destroy();
}

// ---- TStrings / TStringList (a subset of classes.pp) ------------------------
class TStrings extends TPersistent {
  final List<String> _list = [];
  int _updateCount = 0;
  TNotifyEvent? onChange;
  TNotifyEvent? onChanging;

  int get count => _list.length;

  String operator [](int index) => _list[index];
  void operator []=(int index, String value) {
    changing();
    _list[index] = value;
    changed();
  }

  int add(String s) {
    changing();
    _list.add(s);
    changed();
    return _list.length - 1;
  }

  void insert(int index, String s) {
    changing();
    _list.insert(index, s);
    changed();
  }

  void delete(int index) {
    changing();
    _list.removeAt(index);
    changed();
  }

  void clear() {
    changing();
    _list.clear();
    changed();
  }

  int indexOf(String s) => _list.indexOf(s);

  // Text: lines joined by newlines (classes.pp's CRLF/LF choice is platform-dependent; here it's uniformly \n)
  String get text => _list.isEmpty ? '' : "${_list.join('\n')}\n";
  set text(String value) {
    changing();
    _list.clear();
    if (value.isNotEmpty) {
      var v = value.replaceAll("\r\n", "\n").replaceAll("\r", "\n");
      if (v.endsWith("\n")) v = v.substring(0, v.length - 1);
      _list.addAll(v.split("\n"));
    }
    changed();
  }

  List<String> get raw => _list;

  void beginUpdate() {
    _updateCount++;
  }

  void endUpdate() {
    if (_updateCount > 0) _updateCount--;
    if (_updateCount == 0) changed();
  }

  void changing() {
    if (_updateCount == 0) onChanging?.call(this);
  }

  void changed() {
    if (_updateCount == 0) onChange?.call(this);
  }

  @override
  void assign(TPersistent? source) {
    if (source is TStrings) {
      beginUpdate();
      try {
        _list
          ..clear()
          ..addAll(source._list);
      } finally {
        endUpdate();
      }
      return;
    }
    super.assign(source);
  }
}

class TStringList extends TStrings {}

// ---- TStream / TMemoryStream / TBytesStream (a subset of classes.pp) --------------
abstract class TStream {
  int get size;
  set size(int value) {
    throw EDatabaseError("Stream does not support SetSize");
  }

  int position = 0;

  // Read/Write: returns the actual number of bytes read/written, same semantics as classes.pp
  int read(List<int> buffer, int count);
  int write(List<int> buffer, int count);

  int seek(int offset, TSeekOrigin origin) {
    switch (origin) {
      case TSeekOrigin.soBeginning:
        position = offset;
        break;
      case TSeekOrigin.soCurrent:
        position += offset;
        break;
      case TSeekOrigin.soEnd:
        position = size + offset;
        break;
    }
    if (position < 0) position = 0;
    return position;
  }

  void readBuffer(List<int> buffer, int count) {
    if (read(buffer, count) != count) {
      throw EDatabaseError("Stream read error");
    }
  }

  void writeBuffer(List<int> buffer, int count) {
    if (write(buffer, count) != count) {
      throw EDatabaseError("Stream write error");
    }
  }

  int copyFrom(TStream source, int count) {
    if (count <= 0) {
      source.position = 0;
      count = source.size;
    }
    final buf = List<int>.filled(count, 0);
    final n = source.read(buf, count);
    write(buf, n);
    return n;
  }
}

class TMemoryStream extends TStream {
  final List<int> _data = [];

  @override
  int get size => _data.length;

  @override
  set size(int value) {
    if (value < _data.length) {
      _data.removeRange(value, _data.length);
    } else {
      while (_data.length < value) {
        _data.add(0);
      }
    }
    if (position > _data.length) position = _data.length;
  }

  @override
  int read(List<int> buffer, int count) {
    var n = count;
    if (position + n > _data.length) n = _data.length - position;
    if (n <= 0) return 0;
    for (var i = 0; i < n; i++) {
      buffer[i] = _data[position + i];
    }
    position += n;
    return n;
  }

  @override
  int write(List<int> buffer, int count) {
    // overwrites + extends the length when needed
    for (var i = 0; i < count; i++) {
      final p = position + i;
      if (p < _data.length) {
        _data[p] = buffer[i];
      } else {
        _data.add(buffer[i]);
      }
    }
    position += count;
    return count;
  }

  void clearStream() {
    _data.clear();
    position = 0;
  }

  Uint8List get bytes => Uint8List.fromList(_data);

  void loadFromBytes(List<int> data) {
    _data
      ..clear()
      ..addAll(data);
    position = 0;
  }
}

// zz !!! not fully translated

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 1 —— dbconst.pas error-message constants (resourcestring → const, convention 7)
// ═════════════════════════════════════════════════════════════════════════════

const SActiveDataset = 'Operation cannot be performed on an active dataset';
const SBadParamFieldType = 'Bad fieldtype for parameter "%s".';
const SCantSetAutoIncFields = 'AutoInc Fields are read-only';
const SConnected = 'Operation cannot be performed on a connected database';
const SDatasetReadOnly = 'Dataset is read-only.';
const SDatasetRegistered = 'Dataset already registered : "%s"';
const SDuplicateFieldName = 'Duplicate fieldname : "%s"';
const SErrAssTransaction =
    'Cannot assign transaction while old transaction active!';
const SErrColumnNotFound = 'Column "%s" not found.';
const SErrDatabasenAssigned = 'Database not assigned!';
const SErrNoDatabaseAvailable = 'Invalid operation: Not attached to database';
const SErrNoDatabaseName =
    'Database connect string (DatabaseName) not filled in!';
const SErrNoSelectStatement = 'Cannot open a non-select statement';
const SErrNoStatement = 'SQL statement not set';
const SErrTransAlreadyActive = 'Transaction already active';
const SErrTransactionnSet = 'Transaction not set';
const SErrIndexResultTooLong =
    'Index result for "%s" too long, >100 characters (%d).';
const SErrIndexBasedOnInvField =
    'Field "%s" has an invalid field type (%s) to base index on.';
const SErrIndexBasedOnUnkField = 'Index based on unknown field "%s".';
const SErrConnTransactionnSet = 'Transaction of connection not set';
const SErrNotASQLConnection = '"%s" is not a TSQLConnection';
const SErrNotASQLQuery = '"%s" is not a TCustomSQLQuery';
const STransNotActive =
    'Operation cannot be performed on an inactive transaction';
const STransActive = 'Operation cannot be performed on an active transaction';
const SFieldNotFound = 'Field not found : "%s"';
const SInactiveDataset = 'Operation cannot be performed on an inactive dataset';
const SInvalidDisplayValues = '"%s" are not valid boolean displayvalues';
const SInvalidFieldKind = '%s : invalid field kind : ';
const SInvalidBookmark = 'Invalid bookmark';
const SInvalidFieldSize = 'Invalid field size : %d';
const SInvalidTypeConversion = 'Invalid type conversion to %s in field %s';
const SNeedField = 'Field %s is required, but not supplied.';
const SNeedFieldName = 'Field needs a name';
const SNoDataset = 'No dataset asssigned for field : "%s"';
const SNoDatasetRegistered = 'No such dataset registered : "%s"';
const SNoDatasets = 'No datasets are attached to the database';
const SNoSuchRecord = 'Could not find the requested record.';
const SNoTransactionRegistered = 'No such transaction registered : "%s"';
const SNoTransactions = 'No transactions are attached to the database';
const SNotABoolean = '"%s" is not a valid boolean';
const SNotAFloat = '"%s" is not a valid float';
const SNotAninteger = '"%s" is not a valid integer';
const SNotConnected =
    'Operation cannot be performed on an disconnected database';
const SNotEditing =
    'Operation not allowed, dataset "%s" is not in an edit or insert state.';
const SParameterNotFound = 'Parameter "%s" not found';
const SRangeError = '%f is not between %f and %f for %s';
const SRangeError2 = '%f is not between %f and %f.';
const SReadOnlyField = 'Field %s cannot be modified, it is read-only.';
const STransactionRegistered = 'Transaction already registered : "%s"';
const SUniDirectional =
    'Operation cannot be performed on an unidirectional dataset';
const SUnknownField = 'No field named "%s" was found in dataset "%s"';
const SUnknownFieldType = 'Unknown field type : %s';
const SUnknownParamFieldType = 'Unknown fieldtype for parameter "%s".';
const SMetadataUnavailable =
    'The metadata is not available for this type of database.';
const SDeletedRecord = 'The record is deleted.';
const SIndexNotFound = "Index '%s' not found";
const SParameterCountIncorrect = 'The number of parameters is incorrect.';
const SUnsupportedParameter =
    "Parameters of the type '%s' are not (yet) supported.";
const SFieldValueError = "Invalid value for field '%s'";
const SInvalidCalcType = "Field '%s' cannot be a calculated or lookup field";
const SDuplicateName = "Duplicate name '%s' in %s";
const SNoParseSQL = '%s is only possible if ParseSQL is True';
const SLookupInfoError = "Lookup information for field '%s' is incomplete";
const SUnsupportedFieldType = 'Fieldtype %s is not supported';
const SInvPacketRecordsValue = 'PacketRecords has to be larger then 0';
const SInvPacketRecordsValueFieldNames =
    'PacketRecords must be -1 if IndexFieldNames is set';
const SInvPacketRecordsValueUniDirectional =
    'PacketRecords must not be -1 on an unidirectional dataset';
const SInvalidSearchFieldType =
    'Searching in fields of type %s is not supported';
const SDatasetEmpty = 'The dataset is empty';
const SFieldIsNull = 'The field is null';
const SOnUpdateError =
    'An error occurred while applying the updates in a record: %s';
const SApplyRecNotSupported =
    'Applying updates is not supported by this TDataset descendent';
const SNoWhereFields =
    'No %s query specified and failed to generate one. (No fields for inclusion in where statement found)';
const SNoUpdateFields =
    'No %s query specified and failed to generate one. (No fields for insert- or update-statement found)';
const SNotSupported = 'Operation is not supported by this type of database';
const SDBCreateDropFailed = 'Creation or dropping of database failed';
const SMaxIndexes = 'The maximum amount of indexes is reached';
const SMinIndexes = 'The minimum amount of indexes is 1';
const STooManyFields = 'More fields specified then really exist';
// These are added for Delphi-compatilility, but not used by the fcl:
const SFieldIndexError = 'Field index out of range';
const SIndexFieldMissing = "Cannot access index field '%s'";
const SNoFieldIndexes = 'No index currently active';
const SNotIndexField = "Field '%s' is not indexed and cannot be modified";
const SErrUnknownConnectorType = 'Unknown connector type: "%s"';
const SNoIndexFieldNameGiven = 'Cannot create index "%s": No fields available.';
const SStreamNotRecognised = 'The data-stream format is not recognized';
const SNoReaderClassRegistered =
    'There is no TDatapacketReaderClass registered for this kind of data-stream';
const SErrCircularDataSourceReferenceNotAllowed =
    'Circular datasource references are not allowed.';
const SCommitting = 'Committing transaction';
const SRollingBack = 'Rolling back transaction';
const SCommitRetaining = 'Commit and retaining transaction';
const SRollBackRetaining = 'Rollback and retaining transaction';
const SErrNoFieldsDefined =
    'Can not create a dataset when there are no fielddefinitions or fields defined';
const SErrApplyUpdBeforeRefresh = 'Must apply updates before refreshing data';
const SErrNoDataset = 'Missing (compatible) underlying dataset, can not open';
const SErrDisconnectedPacketRecords =
    'For disconnected TSQLQuery instances, packetrecords must be -1';
const SErrImplicitNoRollBack =
    'Implicit use of transactions does not allow rollback.';
const SErrNoImplicitTransaction =
    'Connection %s does not allow implicit transactions.';
const SErrImplictTransactionStart =
    'Error: attempt to implicitly start a transaction on Connection "%s", transaction "%s".';
const SErrImplicitConnect =
    'Error: attempt to implicitly activate connection "%s".';
const SErrFailedToUpdateRecord =
    'Failed to apply record updates: %d rows updated.';
const SErrRefreshNotSingleton = 'Refresh SQL resulted in multiple records: %d.';
const SErrRefreshEmptyResult = 'Refresh SQL resulted in empty result set.';
const SErrNoKeyFieldForRefreshClause =
    'No key field found to construct refresh SQL WHERE clause';
const SErrFailedToFetchReturningResult = 'Failed to fetch returning result';
const SLogParamValue = 'Parameter "%s" value : "%s"';
const SFieldError = 'Field "%s" error: ';
const SInvalidVariant = 'Invalid variant value';

/// formatMsg —— corresponds to the subset of SysUtils.Format that db.pas uses:
/// substitutes %s / %d / %f with args' values in order (no width/precision modifiers supported,
/// since dbconst's messages don't use those).
String formatMsg(String fmt, List<dynamic> args) {
  final buf = StringBuffer();
  var argIndex = 0;
  var i = 0;
  while (i < fmt.length) {
    final c = fmt[i];
    if (c == '%' && i + 1 < fmt.length) {
      final spec = fmt[i + 1];
      if (spec == 's' || spec == 'd' || spec == 'f') {
        final arg = argIndex < args.length ? args[argIndex] : "";
        argIndex++;
        buf.write("$arg");
        i += 2;
        continue;
      }
      if (spec == '%') {
        buf.write("%");
        i += 2;
        continue;
      }
    }
    buf.write(c);
    i++;
  }
  return buf.toString();
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 2 —— db.pas constants / enums / exceptions (db.pas L25-130)
// ═════════════════════════════════════════════════════════════════════════════

// The const section (db.pas L27-36)
const int dsMaxBufferCount = 0x7FFFFFFF ~/ 8; // MAXINT div 8
const int dsMaxStringSize = 8192;

// YesNoChars : Array[Boolean] of char = ('N', 'Y')
// index 0 = False('N'), 1 = True('Y'); accessed as yesNoChars[b ? 1 : 0]
const List<String> yesNoChars = ['N', "Y"];

// SQLDelimiterCharacters（set of char）
const Set<String> sqlDelimiterCharacters = {
  ';',
  ",",
  " ",
  "(",
  ")",
  "\r",
  "\n",
  "\t"
};

// LargeInt = Int64 (Dart's int itself is 64-bit)
typedef LargeInt = int;

// TStringFieldBuffer (a fixed-length AnsiChar array) — since the buffer representation has already been
// switched to an object per convention 1, this helper type isn't needed; only the dsMaxStringSize constant is kept.

// TDataSetState (db.pas L49-51, all 14 values)
enum TDataSetState {
  dsInactive,
  dsBrowse,
  dsEdit,
  dsInsert,
  dsSetKey,
  dsCalcFields,
  dsFilter,
  dsNewValue,
  dsOldValue,
  dsCurValue,
  dsBlockRead,
  dsInternalCalc,
  dsOpening,
  dsRefreshFields,
}

// TDataEvent (db.pas L53-56, all 15 values)
enum TDataEvent {
  deFieldChange,
  deRecordChange,
  deDataSetChange,
  deDataSetScroll,
  deLayoutChange,
  deUpdateRecord,
  deUpdateState,
  deCheckBrowseMode,
  dePropertyChange,
  deFieldListChange,
  deFocusControl,
  deParentScroll,
  deConnectChange,
  deReconcileError,
  deDisabledStateChange,
}

// TUpdateStatus / TUpdateStatusSet（db.pas L58-59）
enum TUpdateStatus { usUnmodified, usModified, usInserted, usDeleted }

typedef TUpdateStatusSet = Set<TUpdateStatus>;

// TUpdateMode / TResolverResponse（db.pas L61-62）
enum TUpdateMode { upWhereAll, upWhereChanged, upWhereKeyOnly }

enum TResolverResponse { rrSkip, rrAbort, rrMerge, rrApply, rrIgnore }

// TProviderFlag / TProviderFlags（db.pas L64-65）
enum TProviderFlag {
  pfInUpdate,
  pfInWhere,
  pfInKey,
  pfHidden,
  pfRefreshOnInsert,
  pfRefreshOnUpdate,
}

typedef TProviderFlags = Set<TProviderFlag>;

// Forward declarations (db.pas L69-77) —— Dart doesn't need forward declarations, omitted.

// ---- Exception classes（db.pas L81-97）--------------------------------------

// EDatabaseError = class(Exception)
class EDatabaseError implements Exception {
  final String message;
  EDatabaseError(this.message);

  @override
  String toString() => message;
}

// EUpdateError = class(EDatabaseError) (db.pas L83-97, implementation L2321-2337)
class EUpdateError extends EDatabaseError {
  final String context;
  final int errorCode;
  final Object? originalException;
  final int previousError;

  // constructor Create(NativeError, Context: String; ErrCode, PrevError:
  // integer; E: Exception)
  // Original source: Inherited CreateFmt(NativeError,[Context]) —— the message itself
  // substitutes Context into NativeError's %s.
  EUpdateError(String nativeError, this.context, this.errorCode,
      this.previousError, this.originalException)
      : super(formatMsg(nativeError, [context]));

  // Destroy calls FreeAndNil(FOriginalException) —— handled by Dart's GC, omitted.
}

// TFieldClass = class of TField → a factory function (convention 2)
// (TField is defined in SECTION 4; the factory typedef is declared here first, matching the original source's position)
// typedef TFieldClass —— see the end of SECTION 4 (needs the TField type itself).

// TFieldType (db.pas L106-112, all 40 values, ordered to match Delphi compatibility,
// must not be reordered — several places compare by ordinal/range, and the order is part of the behavior)
enum TFieldType {
  ftUnknown,
  ftString,
  ftSmallint,
  ftInteger,
  ftWord,
  ftBoolean,
  ftFloat,
  ftCurrency,
  ftBCD,
  ftDate,
  ftTime,
  ftDateTime,
  ftBytes,
  ftVarBytes,
  ftAutoInc,
  ftBlob,
  ftMemo,
  ftGraphic,
  ftFmtMemo,
  ftParadoxOle,
  ftDBaseOle,
  ftTypedBinary,
  ftCursor,
  ftFixedChar,
  ftWideString,
  ftLargeint,
  ftADT,
  ftArray,
  ftReference,
  ftDataSet,
  ftOraBlob,
  ftOraClob,
  ftVariant,
  ftInterface,
  ftIDispatch,
  ftGuid,
  ftTimeStamp,
  ftFMTBcd,
  ftFixedWideChar,
  ftWideMemo,
}

// TFieldMap = array[TFieldType] of Byte → a
// List<int> indexed by TFieldType.index (convention: when an array's index type is an enum, use .index)
typedef TFieldMap = List<int>;

// ---- TDateTimeRec（db.pas L120-127）----------------------------------------
// A Pascal variant record (three interpretations of the same memory), Dart has no union,
// so it's changed to a three-field class; each call site only reads the one field matching its TFieldType — behaviorally equivalent.
class TDateTimeRec {
  int date = 0; // ftDate: a date serial (in days)
  int time = 0; // ftTime: a count of milliseconds
  DateTime? dateTime; // ftDateTime
}

// TFieldAttribute / TFieldAttributes（db.pas L129-130）
enum TFieldAttribute {
  faHiddenCol,
  faReadonly,
  faRequired,
  faLink,
  faUnNamed,
  faFixed,
}

typedef TFieldAttributes = Set<TFieldAttribute>;

// ═════════════════════════════════════════════════════════════════════════════
//  Global helper functions (db.pas implementation section L2276-2318)
//  ??? In the original source this sits at the start of the implementation section (in Section 11's range), but since
//  every later section calls it, it's placed here up front per Dart convention; Section 11 only holds the
//  remaining other global functions.
// ═════════════════════════════════════════════════════════════════════════════

// Procedure DatabaseError(Const Msg : String);
// Procedure DatabaseError(Const Msg : String; Comp : TComponent);
// (a Pascal overload → Dart optional parameters)
Never databaseError(String msg, [TComponent? comp]) {
  if (comp != null && comp.name != '') {
    throw EDatabaseError("${comp.name} : $msg");
  }
  throw EDatabaseError(msg);
}

// Procedure DatabaseErrorFmt(Const Fmt; Const Args);
// Procedure DatabaseErrorFmt(Const Fmt; Const Args; Comp : TComponent);
Never databaseErrorFmt(String fmt, List<dynamic> args, [TComponent? comp]) {
  if (comp != null) {
    throw EDatabaseError(formatMsg("${comp.name} : $fmt", args));
  }
  throw EDatabaseError(formatMsg(fmt, args));
}

// function ExtractFieldName(const Fields: string; var Pos: Integer): string;
// A Pascal var parameter → wrapped as a _PosRef in Dart (reference semantics for a single int)
class TIntRef {
  int value;
  TIntRef(this.value);
}

String extractFieldName(String fields, TIntRef pos) {
  // The original source is a 1-based string index; the semantics are kept but converted to 0-based:
  // the caller starts with TIntRef(0) (corresponding to Pascal's Pos=1).
  var i = pos.value;
  final fieldsLength = fields.length;
  while (i < fieldsLength && fields[i] != ';') {
    i++;
  }
  final result = fields.substring(pos.value, i).trim();
  if (i < fieldsLength && fields[i] == ';') i++;
  pos.value = i;
  return result;
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 3 —— TNamedItem / TDefCollection / TFieldDef / TFieldDefs
//  Declaration: db.pas L134-231; implementation: db.pas L2341-2410 + fields.inc L31-330
// ═════════════════════════════════════════════════════════════════════════════

// The TSystemCodePage constant (the system unit)
typedef TSystemCodePage = int;
const int cpACP = 0; // CP_ACP
const int cpUTF16 = 1200; // CP_UTF16
const int cpUTF8 = 65001; // CP_UTF8

// ---- TNamedItem (db.pas L134-144, implementation L2341-2358) --------------------------
class TNamedItem extends TCollectionItem {
  String _name = '';

  TNamedItem(super.aCollection);

  String get name => _name;
  set name(String value) => displayName = value;

  // GetDisplayName（db.pas L2341）
  @override
  String get displayName => _name;

  // SetDisplayName (db.pas L2346-2358): checks for name collisions within a TFieldDefs collection
  @override
  set displayName(String value) {
    if (_name == value) return;
    if (value != '' && collection is TFieldDefs) {
      final tmpInd = (collection as TDefCollection).indexOfName(value);
      if (tmpInd >= 0 && tmpInd != index) {
        databaseErrorFmt(
            SDuplicateName, [value, collection.runtimeType.toString()]);
      }
    }
    _name = value;
    changed(false); // inherited SetDisplayName
  }
}

// ---- TDefCollection (db.pas L148-161, implementation L2362-2410) ----------------------
class TDefCollection extends TOwnedCollection {
  final TDataSet? _dataset;
  bool updated = false;

  // constructor create(ADataset, AOwner, AClass)（db.pas L2375-2380）
  TDefCollection(TDataSet? aDataset, super.aOwner, super.aClass)
      : _dataset = aDataset;

  TDataSet? get dataset => _dataset;

  // SetItemName (db.pas L2362-2373): fills in a default name for an unnamed item —
  // "DatasetName + ClassName minus the leading T, 5 characters + a sequence number"
  @override
  void setItemName(TCollectionItem item) {
    final named = item as TNamedItem;
    if (named.name == '') {
      // Copy(ClassName, 2, 5): drops the leading 'T' and takes 5 characters
      final cn = named.runtimeType.toString();
      final part =
          cn.length > 1 ? cn.substring(1, cn.length > 6 ? 6 : cn.length) : cn;
      if (_dataset != null) {
        named._name = '${_dataset.name}$part${named.id + 1}';
      } else {
        named._name = '$part${named.id + 1}';
      }
    } else {
      super.setItemName(item);
    }
  }

  // Find (db.pas L2382-2391): AnsiSameText = case-insensitive
  TNamedItem? find(String aName) {
    for (var i = 0; i < count; i++) {
      final item = getItem(i) as TNamedItem;
      if (item.name.toUpperCase() == aName.toUpperCase()) {
        return item;
      }
    }
    return null;
  }

  // GetItemNames（db.pas L2393-2398）
  void getItemNames(TStrings list) {
    for (var i = 0; i < count; i++) {
      list.add((getItem(i) as TNamedItem).name);
    }
  }

  // IndexOf (db.pas L2400-2410) —— has a different parameter type than the shim's
  // TCollection.indexOf(item) (this one takes a name string); Dart can't overload by name,
  // so it's renamed to indexOfName (convention: a Pascal overload → a name suffix)
  int indexOfName(String aName) {
    for (var i = 0; i < count; i++) {
      final item = getItem(i) as TNamedItem;
      if (item.name.toUpperCase() == aName.toUpperCase()) {
        return i;
      }
    }
    return -1;
  }
}

// ---- TFieldDef (db.pas L165-201, implementation fields.inc L31-192) -------------------
class TFieldDef extends TNamedItem {
  TFieldAttributes _attributes = <TFieldAttribute>{};
  TSystemCodePage _codePage = 0;
  TFieldType _dataType = TFieldType.ftUnknown;
  int _fieldNo = 0;
  bool internalCalcField = false;
  int _precision = 0;
  bool _required = false;
  int _size = 0;

  // constructor Create(ACollection: TCollection)（fields.inc L31-36）
  TFieldDef(super.aCollection) {
    _fieldNo = index + 1;
  }

  // constructor Create(AOwner, AName, ADataType, ASize, ARequired,
  //   AFieldNo, ACodePage = CP_ACP)（fields.inc L38-61）
  TFieldDef.named(TFieldDefs super.aOwner, String aName, TFieldType aDataType,
      int aSize, bool aRequired, int aFieldNo,
      [TSystemCodePage aCodePage = cpACP]) {
    name = aName;
    _dataType = aDataType;
    _size = aSize;
    _required = aRequired;
    _precision = -1;
    _fieldNo = aFieldNo;
    switch (_dataType) {
      case TFieldType.ftString:
      case TFieldType.ftFixedChar:
      case TFieldType.ftMemo:
        _codePage = aCodePage;
        break;
      case TFieldType.ftWideString:
      case TFieldType.ftFixedWideChar:
      case TFieldType.ftWideMemo:
        _codePage = cpUTF16;
        break;
      default:
        _codePage = 0;
    }
  }

  // destructor Destroy (fields.inc L63-67): only calls inherited, handled by the GC.

  int get fieldNo => _fieldNo;
  TSystemCodePage get codePage => _codePage;

  bool get required => _required;
  // SetRequired（fields.inc L158-162）
  set required(bool value) {
    _required = value;
    changed(false);
  }

  TFieldAttributes get attributes => _attributes;
  // SetAttributes（fields.inc L134-138）
  set attributes(TFieldAttributes value) {
    _attributes = value;
    changed(false);
  }

  TFieldType get dataType => _dataType;
  // SetDataType（fields.inc L140-144）
  set dataType(TFieldType value) {
    _dataType = value;
    changed(false);
  }

  int get precision => _precision;
  // SetPrecision（fields.inc L146-150）
  set precision(int value) {
    _precision = value;
    changed(false);
  }

  int get size => _size;
  // SetSize（fields.inc L152-156）
  set size(int value) {
    _size = value;
    changed(false);
  }

  // Assign（fields.inc L69-90）
  @override
  void assign(TPersistent? source) {
    if (source is TFieldDef) {
      collection?.beginUpdate();
      try {
        name = source.name;
        dataType = source.dataType;
        size = source.size;
        precision = source.precision;
        _required = source.required;
        _codePage = source._codePage;
      } finally {
        collection?.endUpdate();
      }
      return;
    }
    super.assign(source);
  }

  // GetFieldClass（fields.inc L164-175）
  TFieldClass? get fieldClass {
    //!! Should be owner as tdataset but that doesn't work ?? (original comment kept as-is)
    final c = collection;
    if (c is TFieldDefs && c.dataset != null) {
      return c.dataset!.getFieldClass(_dataType);
    }
    return null;
  }

  // CreateField（fields.inc L92-132）
  TField createField(TComponent? aOwner) {
    final theField = fieldClass;
    if (theField == null) {
      databaseErrorFmt(SUnknownFieldType, [name]);
    }
    final result = theField(aOwner);
    try {
      result._fieldDef = this;
      result.size = _size;
      result.required = _required;
      result._fieldName = name;
      result._displayLabel = displayName;
      result._fieldNo = fieldNo;
      result.setFieldType(dataType);
      result._readOnly = _attributes.contains(TFieldAttribute.faReadonly);
      result.dataSet = (collection as TFieldDefs).dataset;
      if (result is TStringField) {
        result._codePage = _codePage;
      } else if (result is TMemoField) {
        result._codePage = _codePage;
      } else if (result is TFloatField) {
        result.precision = _precision;
      } else if (result is TBCDField) {
        result.precision = _precision;
      } else if (result is TFMTBCDField) {
        result.precision = _precision;
      }
      return result;
    } catch (_) {
      result.free();
      rethrow;
    }
  }

  // GetCharSize（fields.inc L177-192）
  int get charSize {
    switch (_dataType) {
      case TFieldType.ftGuid:
        return 1;
      case TFieldType.ftString:
      case TFieldType.ftFixedChar:
        return _codePage == cpUTF8 ? 4 : 1;
      case TFieldType.ftWideString:
      case TFieldType.ftFixedWideChar:
        return 2;
      default:
        return 0;
    }
  }
}

// TFieldDefClass = Class of TFieldDef → a factory typedef (convention 2):
// each of the two constructor paths has its own factory signature, played by TFieldDefs' virtual method for
// the role the original source's "class function FieldDefClass" (replaceable by subclasses) fills.

// ---- TFieldDefs (db.pas L206-230, implementation fields.inc L208-330) -----------------
class TFieldDefs extends TDefCollection {
  bool hiddenFields = false;

  // constructor Create(ADataSet)（fields.inc L252-255）
  // The original source's `inherited Create(ADataset, Owner, FieldDefClass)` —— AOwner
  // is passed the dataset itself (TComponent is a TPersistent subclass).
  TFieldDefs(TDataSet? aDataSet)
      : super(aDataSet, aDataSet, (c) => TFieldDef(c));

  // class function FieldDefClass: TFieldDefClass（fields.inc L247-250）
  // → a virtual factory method (convention 2), which subclasses can override to swap the item class
  TFieldDef fieldDefClass(TFieldDefs aOwner, String aName, TFieldType aDataType,
      int aSize, bool aRequired, int aFieldNo,
      [TSystemCodePage aCodePage = cpACP]) {
    return TFieldDef.named(
        aOwner, aName, aDataType, aSize, aRequired, aFieldNo, aCodePage);
  }

  // GetItem / SetItem (fields.inc L236-245) —— Dart's [] operator
  TFieldDef operator [](int index) => getItem(index) as TFieldDef;
  void operator []=(int index, TFieldDef value) => setItem(index, value);

  // The five-overload Add group (db.pas L216-220):
  // Dart has no overloading, so the three procedure versions are merged into add() (with optional parameters),
  // and the two function versions are renamed addWithFieldNo / addFull (convention: suffix naming).

  // procedure Add(AName, ADataType[, ASize[, ARequired]])
  // （fields.inc L208-234）
  // @@@ Renamed to addField: Pascal's `procedure Add` and TCollection.add()
  // @@@ (a function returning TCollectionItem) would be an illegal override in Dart (different return
  // @@@ type / parameter count). Pascal distinguishes them by overload, Dart can't, so
  // @@@ the procedure version is renamed. Callers (including initFieldDefsFromFields etc.)
  // @@@ switched to addField in step.
  void addField(String aName, TFieldType aDataType,
      [int aSize = 0, bool aRequired = false]) {
    if (aName.isEmpty) {
      databaseError(SNeedFieldName);
    }
    // the fielddef will register itself here as an owned component.
    // fieldno is 1 based ! (original comment kept as-is)
    beginUpdate();
    try {
      addWithFieldNo(aName, aDataType, aSize, aRequired, count + 1);
    } finally {
      endUpdate();
    }
  }

  // function Add(AName, ADataType, ASize, ARequired, AFieldNo): TFieldDef
  // （fields.inc L269-272）
  TFieldDef addWithFieldNo(String aName, TFieldType aDataType, int aSize,
      bool aRequired, int aFieldNo) {
    return fieldDefClass(this, aName, aDataType, aSize, aRequired, aFieldNo);
  }

  // function Add(AName, ADataType, ASize, APrecision, ARequired,
  //   AReadOnly, AFieldNo, ACodePage): TFieldDef（fields.inc L257-267）
  TFieldDef addFull(
      String aName,
      TFieldType aDataType,
      int aSize,
      int aPrecision,
      bool aRequired,
      bool aReadOnly,
      int aFieldNo,
      TSystemCodePage aCodePage) {
    final result = fieldDefClass(this, makeNameUnique(aName), aDataType, aSize,
        aRequired, aFieldNo, aCodePage);
    switch (aDataType) {
      case TFieldType.ftBCD:
      case TFieldType.ftFMTBcd:
        result.precision = aPrecision;
        break;
      default:
        break;
    }
    if (aReadOnly) {
      result.attributes = {...result.attributes, TFieldAttribute.faReadonly};
    }
    return result;
  }

  // AddFieldDef（fields.inc L326-330）
  TFieldDef addFieldDef() {
    return fieldDefClass(this, "", TFieldType.ftUnknown, 0, false, count + 1);
  }

  // Assign(FieldDefs) (fields.inc L274-283) —— same signature name as TPersistent.assign
  // but a different type; in Pascal it's an overload; kept as `assign` here, with the
  // actual type discriminated internally (TCollection.assign already covers the general path).
  void assignFieldDefs(TFieldDefs fieldDefs) {
    clear();
    for (var i = 0; i < fieldDefs.count; i++) {
      final fd = fieldDefs[i];
      addField(fd.name, fd.dataType, fd.size, fd.required);
    }
  }

  // Find (fields.inc L285-289): throws immediately if not found (unlike TDefCollection.find,
  // which returns null — the original source is asymmetric this way)
  TFieldDef findDef(String aName) {
    final result = super.find(aName) as TFieldDef?;
    if (result == null) {
      databaseErrorFmt(SFieldNotFound, [aName], _dataset);
    }
    return result;
  }

  // Update（fields.inc L303-312）
  void updateDefs() {
    if (!updated) {
      _dataset?.initFieldDefs();
      updated = true;
    }
  }

  // MakeNameUnique（fields.inc L314-324）
  String makeNameUnique(String aName) {
    var dblFieldCount = 0;
    var result = aName;
    while (super.find(result) != null) {
      dblFieldCount++;
      result = '${aName}_$dblFieldCount';
    }
    return result;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 4 —— TFieldKind / event typedefs / TLookupList / TField
//  Declaration: db.pas L235-468; implementation: db.pas L2610-2700 + fields.inc L336-1108
// ═════════════════════════════════════════════════════════════════════════════

// TAlignment (a classes-unit shim, used by TField.Alignment)
enum TAlignment { taLeftJustify, taRightJustify, taCenter }

// TEditMask (MaskUtils, source not provided) → String (convention 6)
typedef TEditMask = String;

// TFieldKind / TFieldKinds（db.pas L235-236）
enum TFieldKind { fkData, fkCalculated, fkLookup, fkInternalCalc }

typedef TFieldKinds = Set<TFieldKind>;

// Event typedefs (db.pas L238-243)
typedef TFieldNotifyEvent = void Function(TField sender);

// A var aText parameter → wrapped as TStringRef (the Pascal var-parameter convention, same as TIntRef)
class TStringRef {
  String value;
  TStringRef(this.value);
}

typedef TFieldGetTextEvent = void Function(
    TField sender, TStringRef aText, bool displayText);
typedef TFieldSetTextEvent = void Function(TField sender, String aText);

// TFieldChars = set of Char
typedef TFieldChars = Set<String>;

// ---- TValueBuffer: the value-carrying container for GetData/SetData (a concretization of convention 1) ----------
// In Pascal, Buffer: Pointer is memory the caller allocates, GetData fills it in and returns
// False for NULL; SetData(nil) means "set to NULL". This is replaced with a "box holding a
// value" that preserves exactly the same calling protocol:
//   GetIsNull = not GetData(null)     —— passing null just asks "is there a value"
//   Clear     = SetData(null)         —— passing null means "set to NULL"
class TValueBuffer {
  dynamic value;
  TValueBuffer([this.value]);
}

// TLookupListRec（db.pas L246-249）
class TLookupListRec {
  dynamic key;
  dynamic value;
  TLookupListRec(this.key, this.value);
}

// ---- TLookupList (db.pas L253-264, implementation L2612-2700) -------------------------
class TLookupList {
  final List<TLookupListRec> _list = [];

  // Add（db.pas L2626-2634）
  void add(dynamic aKey, dynamic aValue) {
    _list.add(TLookupListRec(aKey, aValue));
  }

  // Clear（db.pas L2636-2641）
  void clear() {
    _list.clear();
  }

  // FirstKeyByValue（db.pas L2643-2655）
  dynamic firstKeyByValue(dynamic aValue) {
    for (final rec in _list) {
      if (rec.value == aValue) return rec.key;
    }
    return null;
  }

  // ValueOfKey (db.pas L2657-2687): searches from the end backward; Key can be a
  // VarArray (a multi-key field); the nested function VarArraySameValues corresponds to
  // an element-by-element List comparison.
  dynamic valueOfKey(dynamic aKey) {
    if (aKey == null) return null;

    bool varArraySameValues(List a1, List a2) {
      // This only works for one-dimensional vararrays with a lower bound
      // of 0 ... (original comment, semantics kept as-is)
      if (a1.length != a2.length) return false;
      for (var i = 0; i < a1.length; i++) {
        if (a1[i] != a2[i]) return false;
      }
      return true;
    }

    var i = _list.length - 1;
    if (aKey is List) {
      while (i >= 0 &&
          !(_list[i].key is List &&
              varArraySameValues(_list[i].key as List, aKey))) {
        i--;
      }
    } else {
      while (i >= 0 && _list[i].key != aKey) {
        i--;
      }
    }
    return i >= 0 ? _list[i].value : null;
  }

  // ValuesToStrings (db.pas L2689-2700): the attached-object slot of AddObject
  // (TStrings.AddObject) isn't implemented by the shim, so only the string is added — the attached object
  // has no reader anywhere inside db.pas, so this is behaviorally equivalent.
  void valuesToStrings(TStrings aStrings) {
    aStrings.clear();
    for (final rec in _list) {
      aStrings.add("${rec.value}");
    }
  }
}

// ---- fields.inc local constants (L336-345) -----------------------------------------
const String _sBCD = 'BCD';
const String _sBoolean = 'Boolean';
const String _sDateTime = 'TDateTime';
const String _sFloat = 'Float';
const String _sInteger = 'Integer';
const String _sLargeInt = 'LargeInt';
const String _sVariant = 'Variant';
const String _sString = 'String';
const String _sBytes = 'Bytes';

// ---- TField (db.pas L268-468, implementation fields.inc L347-1108) --------------------
class TField extends TComponent {
  TAlignment _alignment = TAlignment.taLeftJustify;
  String attributeSet = '';
  bool calculated = false;
  String constraintErrorMessage = '';
  String customConstraint = '';
  TDataSet? _dataSet;
  TFieldType _dataType = TFieldType.ftUnknown;
  String defaultExpression = '';
  String _displayLabel = '';
  int _displayWidth = 0;
  TEditMask editMask = '';
  TFieldDef? _fieldDef;
  TFieldKind fieldKind = TFieldKind.fkData;
  String _fieldName = '';
  int _fieldNo = 0;
  TFields? _fields; // filled in by TFields.Add
  final bool _hasConstraints = false;
  String importedConstraint = '';
  final bool _isIndexField = false;
  String keyFields = '';
  bool lookupCache = false;
  TDataSet? _lookupDataSet;
  // @@@ lookupDataSet is a published property of db.pas (around L390);
  // @@@ only a private field was kept before and the accessor was missing — added it back
  TDataSet? get lookupDataSet => _lookupDataSet;
  set lookupDataSet(TDataSet? value) => _lookupDataSet = value;
  String lookupKeyFields = '';
  String lookupResultField = '';
  TLookupList? _lookupList;
  int _offset = 0;
  TFieldNotifyEvent? onChange;
  TFieldGetTextEvent? onGetText;
  TFieldSetTextEvent? onSetText;
  TFieldNotifyEvent? onValidate;
  String origin = '';
  bool _readOnly = false;
  bool required = false;
  int _size = 0;
  TFieldChars validChars = {};
  TValueBuffer? _valueBuffer;
  bool _validating = false;
  bool _visible = true;
  TProviderFlags providerFlags = {};

  // constructor Create（fields.inc L347-355）
  TField([super.aOwner]) {
    _visible = true;
    // FValidChars:=[#0..#255] —— Dart's Set<String> doesn't actually enumerate all 256
    // characters; instead an empty set means "unrestricted", handled accordingly in IsValidChar.
    validChars = {};
    providerFlags = {TProviderFlag.pfInUpdate, TProviderFlag.pfInWhere};
  }

  // destructor Destroy（fields.inc L357-368）
  @override
  void destroy() {
    if (_dataSet != null) {
      _dataSet!.active = false;
      _fields?.remove(this);
    }
    _lookupList = null; // FLookupList.Free
    super.destroy();
  }

  // AccessError（fields.inc L370-374）
  EDatabaseError accessError(String typeName) {
    return EDatabaseError(
        formatMsg(SInvalidTypeConversion, [typeName, _fieldName]));
  }

  // Assign（fields.inc L376-384）
  @override
  void assign(TPersistent? source) {
    if (source == null) {
      clear();
    } else if (source is TField) {
      value = source.value;
    } else {
      super.assign(source);
    }
  }

  // AssignValue(TVarRec) (fields.inc L386-429): TVarRec is the tagged-union element type of a Pascal
  // open-array constant; in Dart this becomes runtime type dispatch, with each branch mapping one-to-one
  // to vtInteger/vtBoolean/vtString/vtExtended/vtObject/
  // vtVariant/vtInt64 (char/pchar/ansistring/unicodestring are all
  // String in Dart, merged into asString).
  void assignValue(dynamic aValue) {
    void error() {
      databaseErrorFmt(SFieldValueError, [displayName]);
    }

    if (aValue is int) {
      asInteger = aValue;
    } else if (aValue is bool) {
      asBoolean = aValue;
    } else if (aValue is double) {
      asFloat = aValue;
    } else if (aValue is String) {
      asString = aValue;
    } else if (aValue is TPersistent) {
      assign(aValue);
    } else if (aValue == null) {
      assign(null);
    } else {
      error();
    }
  }

  // Bind (fields.inc L431-446): when the dataset opens, an fkLookup field checks that its
  // lookup configuration is complete and opens the lookup dataset
  void bind(bool binding) {
    if (binding && fieldKind == TFieldKind.fkLookup) {
      if (_lookupDataSet == null ||
          lookupKeyFields == '' ||
          lookupResultField == '' ||
          keyFields == '') {
        databaseErrorFmt(SLookupInfoError, [displayName]);
      }
      _fields!.checkFieldNames(keyFields);
      _lookupDataSet!.open();
      _lookupDataSet!.fields.checkFieldNames(lookupKeyFields);
      _lookupDataSet!.fieldByName(lookupResultField);
      if (lookupCache) {
        refreshLookupList();
      }
    }
  }

  // Change（fields.inc L448-453）
  void change() {
    onChange?.call(this);
  }

  // CheckInactive（fields.inc L455-460）
  void checkInactive() {
    _dataSet?.checkInactive();
  }

  // Clear（fields.inc L462-466）
  void clear() {
    setData(null);
  }

  // DataChanged（fields.inc L468-472）
  void dataChanged() {
    _dataSet!.dataEvent(TDataEvent.deFieldChange, this);
  }

  // FocusControl (fields.inc L474-480): the original source passes @Field1 (the address of the
  // field reference); here the field itself is passed directly
  void focusControl() {
    _dataSet!.dataEvent(TDataEvent.deFocusControl, this);
  }

  // FreeBuffers（fields.inc L482-487）
  void freeBuffers() {
    // Empty. Provided for backward compatibiliy;
    // TDataset manages the buffers. (original comment kept as-is)
  }

  // ---- The GetAsXxx base (real implementations only exist in subclasses) -------------------------
  // GetAsBCD（fields.inc L489）
  double getAsBCD() => throw accessError(_sBCD);
  // GetAsBoolean（L494）
  bool getAsBoolean() => throw accessError(_sBoolean);

  // GetAsBytes (L499-506): allocates DataSize bytes, GetData fills them in
  Uint8List? getAsBytes() {
    final buf = TValueBuffer();
    if (!getData(buf, false)) return null;
    final v = buf.value;
    if (v is Uint8List) return v;
    if (v is List<int>) return Uint8List.fromList(v);
    return null;
  }

  // GetAsCurrency（L508）
  double getAsCurrency() => getAsFloat();
  // GetAsDateTime（L513）
  DateTime getAsDateTime() => throw accessError(_sDateTime);
  // GetAsFloat (L519-523) —— ??? the original source raises AccessError(SDateTime) here
  // instead of SFloat (an FPC source typo), carried over faithfully with this note.
  double getAsFloat() => throw accessError(_sDateTime);
  // GetAsLargeInt（L525）
  int getAsLargeInt() => throw accessError(_sLargeInt);
  // GetAsLongint（L530）
  int getAsLongint() => getAsInteger();
  // GetAsInteger（L536）
  int getAsInteger() => throw accessError(_sInteger);
  // GetAsVariant（L542）
  dynamic getAsVariant() => throw accessError(_sVariant);
  // GetAsString（L549）
  String getAsString() => getClassDesc();
  // GetAsAnsiString/GetAsUnicodeString/GetAsUTF8String（L554-567）：
  // Dart only has one String type, everything merges into it
  String getAsAnsiString() => getAsString();
  String getAsUnicodeString() => getAsString();
  String getAsUTF8String() => getAsString();
  // GetAsWideString（L569）
  String getAsWideString() => getAsUnicodeString();

  // GetOldValue（fields.inc L574-586）
  dynamic getOldValue() {
    final saveState = _dataSet!.state;
    try {
      _dataSet!.setTempState(TDataSetState.dsOldValue);
      return getAsVariant();
    } finally {
      _dataSet!.restoreState(saveState);
    }
  }

  // GetNewValue（L588-600）
  dynamic getNewValue() {
    final saveState = _dataSet!.state;
    try {
      _dataSet!.setTempState(TDataSetState.dsNewValue);
      return getAsVariant();
    } finally {
      _dataSet!.restoreState(saveState);
    }
  }

  // SetNewValue（L602-614）
  void setNewValue(dynamic aValue) {
    final saveState = _dataSet!.state;
    try {
      _dataSet!.setTempState(TDataSetState.dsNewValue);
      setAsVariant(aValue);
    } finally {
      _dataSet!.restoreState(saveState);
    }
  }

  // GetCurValue（L616-628）
  dynamic getCurValue() {
    final saveState = _dataSet!.state;
    try {
      _dataSet!.setTempState(TDataSetState.dsCurValue);
      return getAsVariant();
    } finally {
      _dataSet!.restoreState(saveState);
    }
  }

  // GetCanModify（fields.inc L630-644）
  bool getCanModify() {
    var result = !readOnly;
    if (result) {
      result = fieldKind == TFieldKind.fkData ||
          fieldKind == TFieldKind.fkInternalCalc;
      if (result) {
        result = _dataSet != null && _dataSet!.active;
        if (result) {
          result = _dataSet!.canModify;
        }
      }
    }
    return result;
  }

  // GetClassDesc（fields.inc L646-654）：'TStringField' → '(STRING)'
  String getClassDesc() {
    final className = runtimeType.toString();
    final fieldPos = className.indexOf("Field");
    final classN = fieldPos > 1 ? className.substring(1, fieldPos) : className;
    return isNull ? '(${classN.toLowerCase()})' : "(${classN.toUpperCase()})";
  }

  // GetData's two overloads (fields.inc L656-675) → optional parameters
  bool getData(TValueBuffer? buffer, [bool nativeFormat = true]) {
    if (_dataSet == null) {
      databaseErrorFmt(SNoDataset, [fieldName]);
    }
    if (_validating) {
      final result = _valueBuffer != null;
      if (result && buffer != null) {
        buffer.value = _valueBuffer!.value;
      }
      return result;
    }
    return _dataSet!.getFieldData(this, buffer, nativeFormat);
  }

  // GetDataSize（fields.inc L677-681）
  int getDataSize() => 0;

  // GetDefaultWidth（fields.inc L683-687）
  int getDefaultWidth() => 10;

  // GetDisplayName（fields.inc L689-696）
  String get displayName => _displayLabel != '' ? _displayLabel : _fieldName;

  // IsDisplayLabelStored / IsDisplayWidthStored（L698-708，designer
  // (a stored check used for streaming, translated as-is)
  bool isDisplayLabelStored() => displayLabel != fieldName;
  bool isDisplayWidthStored() => _displayWidth != 0;

  // GetLookupList（fields.inc L710-715）：lazy create
  TLookupList get lookupList {
    _lookupList ??= TLookupList();
    return _lookupList!;
  }

  // CalcLookupValue（fields.inc L717-723）
  void calcLookupValue() {
    if (lookupCache) {
      value = lookupList.valueOfKey(_dataSet!.fieldValues(keyFields));
    } else if (_lookupDataSet != null && _dataSet!.active) {
      value = _lookupDataSet!.lookup(
          lookupKeyFields, _dataSet!.fieldValues(keyFields), lookupResultField);
    }
  }

  // GetIndex（fields.inc L725-732）
  int get index => _dataSet != null ? _dataSet!._fieldList.indexOf(this) : -1;

  // SetIndex（fields.inc L748-751）
  set index(int value) {
    _fields?.setFieldIndex(this, value);
  }

  // GetLookup / SetLookup（fields.inc L734-737, L1085-1090）deprecated
  bool get lookup => fieldKind == TFieldKind.fkLookup;
  set lookup(bool value) {
    fieldKind = value ? TFieldKind.fkLookup : TFieldKind.fkData;
  }

  // Alignment（fields.inc L739-746）
  TAlignment get alignment => _alignment;
  set alignment(TAlignment value) {
    if (_alignment != value) {
      _alignment = value;
      propertyChanged(false);
    }
  }

  // GetIsNull（fields.inc L758-762）
  bool get isNull => !getData(null);

  // GetParentComponent（fields.inc L764-768）/ HasParent（L776-780）
  TComponent? getParentComponent() => dataSet;
  bool hasParent() => true;

  // GetText（fields.inc L770-774）
  void getText(TStringRef aText, bool aDisplayText) {
    aText.value = getAsString();
  }

  // IsValidChar (fields.inc L782-787): an empty validChars set = the original source's
  // [#0..#255] (all characters allowed — see the note on the constructor)
  bool isValidChar(String inputChar) {
    if (validChars.isEmpty) return true;
    return validChars.contains(inputChar);
  }

  // RefreshLookupList（fields.inc L789-819）
  void refreshLookupList() {
    if (_lookupDataSet == null ||
        lookupKeyFields.isEmpty ||
        lookupResultField.isEmpty ||
        keyFields.isEmpty) {
      return;
    }
    final tmpActive = _lookupDataSet!.active;
    try {
      _lookupDataSet!.active = true;
      _fields!.checkFieldNames(keyFields);
      _lookupDataSet!.fields.checkFieldNames(lookupKeyFields);
      // I presume that if it doesn't exist it throws exception, and that
      // a field with null value is still valid (original comment kept as-is)
      _lookupDataSet!.fieldByName(lookupResultField);
      // have to be F-less because we might be creating it here with
      // getter! (original comment kept as-is)
      lookupList.clear();

      _lookupDataSet!.disableControls();
      try {
        _lookupDataSet!.first();
        while (!_lookupDataSet!.eof) {
          _lookupList!.add(_lookupDataSet!.fieldValues(lookupKeyFields),
              _lookupDataSet!.fieldValues(lookupResultField));
          _lookupDataSet!.next();
        }
      } finally {
        _lookupDataSet!.enableControls();
      }
    } finally {
      _lookupDataSet!.active = tmpActive;
    }
  }

  // Notification（fields.inc L821-827）
  @override
  void notification(TComponent aComponent, TOperation operation) {
    super.notification(aComponent, operation);
    if (operation == TOperation.opRemove &&
        identical(aComponent, _lookupDataSet)) {
      _lookupDataSet = null;
    }
  }

  // PropertyChanged（fields.inc L829-837）
  void propertyChanged(bool layoutAffected) {
    if (_dataSet != null && _dataSet!.active) {
      if (layoutAffected) {
        _dataSet!.dataEvent(TDataEvent.deLayoutChange, 0);
      } else {
        _dataSet!.dataEvent(TDataEvent.deDataSetChange, 0);
      }
    }
  }

  // ReadState(Reader) (fields.inc L839-845): TReader is the design-time form
  // streaming mechanism (.lfm loading); this translation doesn't include a form-streaming system, not translated.

  // ---- The SetAsXxx base -------------------------------------------------------
  // SetAsBCD（fields.inc L847）
  void setAsBCD(double aValue) => throw accessError(_sBCD);
  // SetAsBytes（L852）
  void setAsBytes(Uint8List aValue) => throw accessError(_sBytes);
  // SetAsBoolean（L857）
  void setAsBoolean(bool aValue) => throw accessError(_sBoolean);
  // SetAsDateTime（L863）
  void setAsDateTime(DateTime aValue) => throw accessError(_sDateTime);
  // SetAsFloat（L869）
  void setAsFloat(double aValue) => throw accessError(_sFloat);

  // SetAsVariant（fields.inc L875-887）
  void setAsVariant(dynamic aValue) {
    if (aValue == null) {
      clear();
    } else {
      try {
        setVarValue(aValue);
      } on TypeError {
        // on EVariantError —— corresponds to TypeError in Dart
        databaseErrorFmt(SFieldError + SInvalidVariant, [displayName]);
      }
    }
  }

  // SetAsLongint（L890）
  void setAsLongint(int aValue) => setAsInteger(aValue);
  // SetAsInteger（L895）
  void setAsInteger(int aValue) => throw accessError(_sInteger);
  // SetAsLargeInt（L900）
  void setAsLargeInt(int aValue) => throw accessError(_sLargeInt);
  // SetAsString（L905）
  void setAsString(String aValue) => throw accessError(_sString);
  // SetAsAnsiString/SetAsUnicodeString/SetAsUTF8String（L910-923）
  void setAsAnsiString(String aValue) => setAsString(aValue);
  void setAsUnicodeString(String aValue) => setAsString(aValue);
  void setAsUTF8String(String aValue) => setAsString(aValue);
  // SetAsWideString（L925）
  void setAsWideString(String aValue) => setAsUnicodeString(aValue);

  // SetData's two overloads (fields.inc L931-943)
  void setData(TValueBuffer? buffer, [bool nativeFormat = true]) {
    if (_dataSet == null) {
      databaseErrorFmt(SNoDataset, [displayName]);
    }
    _dataSet!.setFieldData(this, buffer, nativeFormat);
  }

  // SetDataset（fields.inc L945-963）
  TDataSet? get dataSet => _dataSet;
  set dataSet(TDataSet? aValue) {
    if (identical(aValue, _dataSet)) return;
    if (_dataSet != null) {
      _dataSet!.checkInactive();
      _dataSet!._fieldList.remove(this);
    }
    if (aValue != null) {
      aValue.checkInactive();
      aValue._fieldList.add(this);
    }
    _dataSet = aValue;
  }

  // SetDataType (fields.inc L965-969) —— the original source is a protected setter,
  // the DataType property is externally read-only
  TFieldType get dataType => _dataType;
  void setDataType(TFieldType aValue) {
    _dataType = aValue;
  }

  // SetFieldType (fields.inc L971-975): an empty base implementation, overridden by subclasses (multi-type
  // fields like TDateTimeField)
  void setFieldType(TFieldType aValue) {
    // { empty }
  }

  // SetParentComponent（fields.inc L977-982）
  void setParentComponent(TComponent? aParent) {
    if (!componentState.contains(TComponentStateItem.csLoading)) {
      dataSet = aParent as TDataSet?;
    }
  }

  // SetSize（fields.inc L984-990）
  int get size => _size;
  set size(int aValue) {
    checkInactive();
    checkTypeSize(aValue);
    _size = aValue;
  }

  // SetText（fields.inc L992-996）
  void setTextValue(String aValue) {
    setAsString(aValue);
  }

  // SetVarValue（fields.inc L998-1001）
  void setVarValue(dynamic aValue) => throw accessError(_sVariant);

  // Validate（fields.inc L1003-1016）
  void validate(TValueBuffer? buffer) {
    if (onValidate != null) {
      _valueBuffer = buffer;
      _validating = true;
      try {
        onValidate!(this);
      } finally {
        _validating = false;
      }
    }
  }

  // class function IsBlob（fields.inc L1018-1022）
  // ??? class virtual → instance member (Dart static methods have no polymorphism; an extension of convention 2)
  bool get isBlob => false;

  // class procedure CheckTypeSize（fields.inc L1024-1029）
  void checkTypeSize(int aValue) {
    if (aValue != 0 && !isBlob) {
      databaseErrorFmt(SInvalidFieldSize, [aValue]);
    }
  }

  // SetEditText / GetEditText (fields.inc L1033-1048) → the Text property
  String get text {
    final ref = TStringRef("");
    if (onGetText != null) {
      onGetText!(this, ref, false);
    } else {
      getText(ref, false);
    }
    return ref.value;
  }

  set text(String aValue) {
    if (onSetText != null) {
      onSetText!(this, aValue);
    } else {
      setTextValue(aValue);
    }
  }

  // GetDisplayText（fields.inc L1050-1057）
  String get displayText {
    final ref = TStringRef("");
    if (onGetText != null) {
      onGetText!(this, ref, true);
    } else {
      getText(ref, true);
    }
    return ref.value;
  }

  // DisplayLabel（fields.inc L1059-1066）
  String get displayLabel => displayName;
  set displayLabel(String aValue) {
    if (_displayLabel != aValue) {
      _displayLabel = aValue;
      propertyChanged(true);
    }
  }

  // DisplayWidth（fields.inc L1068-1083）
  int get displayWidth =>
      _displayWidth == 0 ? getDefaultWidth() : _displayWidth;
  set displayWidth(int aValue) {
    if (_displayWidth != aValue) {
      _displayWidth = aValue;
      propertyChanged(true);
    }
  }

  // ReadOnly（fields.inc L1092-1099）
  bool get readOnly => _readOnly;
  set readOnly(bool aValue) {
    if (_readOnly != aValue) {
      _readOnly = aValue;
      propertyChanged(true);
    }
  }

  // Visible（fields.inc L1101-1108）
  bool get visible => _visible;
  set visible(bool aValue) {
    if (_visible != aValue) {
      _visible = aValue;
      propertyChanged(true);
    }
  }

  // ---- The public property group (db.pas L403-467's property section) ------------------------
  double get asBCD => getAsBCD();
  set asBCD(double v) => setAsBCD(v);
  bool get asBoolean => getAsBoolean();
  set asBoolean(bool v) => setAsBoolean(v);
  Uint8List? get asBytes => getAsBytes();
  set asBytes(Uint8List? v) => v == null ? clear() : setAsBytes(v);
  double get asCurrency => getAsCurrency();
  set asCurrency(double v) => setAsCurrency(v);
  DateTime get asDateTime => getAsDateTime();
  set asDateTime(DateTime v) => setAsDateTime(v);
  double get asFloat => getAsFloat();
  set asFloat(double v) => setAsFloat(v);
  int get asLongint => getAsLongint();
  set asLongint(int v) => setAsLongint(v);
  int get asLargeInt => getAsLargeInt();
  set asLargeInt(int v) => setAsLargeInt(v);
  int get asInteger => getAsInteger();
  set asInteger(int v) => setAsInteger(v);
  String get asString => getAsString();
  set asString(String v) => setAsString(v);
  String get asAnsiString => getAsAnsiString();
  set asAnsiString(String v) => setAsAnsiString(v);
  String get asUnicodeString => getAsUnicodeString();
  set asUnicodeString(String v) => setAsUnicodeString(v);
  String get asUTF8String => getAsUTF8String();
  set asUTF8String(String v) => setAsUTF8String(v);
  String get asWideString => getAsWideString();
  set asWideString(String v) => setAsWideString(v);
  dynamic get asVariant => getAsVariant();
  set asVariant(dynamic v) => setAsVariant(v);

  bool get canModify => getCanModify();
  dynamic get curValue => getCurValue();
  int get dataSize => getDataSize();
  int get fieldNo => _fieldNo;
  bool get isIndexField => _isIndexField;
  dynamic get newValue => getNewValue();
  set newValue(dynamic v) => setNewValue(v);
  int get offset => _offset;
  dynamic get value => getAsVariant();
  set value(dynamic v) => setAsVariant(v);
  dynamic get oldValue => getOldValue();
  TFieldDef? get fieldDef => _fieldDef;
  bool get hasConstraints => _hasConstraints;

  String get fieldName => _fieldName;
  set fieldName(String v) => _fieldName = v;

  // SetAsCurrency（fields.inc L753-756）
  void setAsCurrency(double aValue) {
    setAsFloat(aValue);
  }
}

// TFieldClass = class of TField → a factory typedef (convention 2)
typedef TFieldClass = TField Function(TComponent? aOwner);

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 5 —— all TField subclasses (fields.inc L1110-3440)
// ═════════════════════════════════════════════════════════════════════════════

// aa !!! not fully translated
// A "subset" SysUtils formatting shim (an extension of Section 0; used by field subclasses' GetText).
// Source unavailable, only implements the formats db.pas actually uses; not a complete SysUtils.Format.
// zz !!! not fully translated
// The original source uses SysUtils' FormatFloat/FloatToStrF/FormatDateTime and
// locale settings variables. Source not provided; the subset db.pas actually needs is provided here:
enum TFloatFormat { ffGeneral, ffExponent, ffFixed, ffNumber, ffCurrency }

const String decimalSeparator = '.';
const int currencyDecimals = 2;
const String longTimeFormat = 'hh:nn:ss';
const String shortDateFormat = 'yyyy-mm-dd';

// A FormatFloat subset: supports the 0/#/./, mask; other characters pass through as-is.
String formatFloat(String fmt, num value) {
  if (fmt.isEmpty) return '$value';
  // splits the integer/decimal mask parts
  final dot = fmt.indexOf(".");
  final intMask = dot < 0 ? fmt : fmt.substring(0, dot);
  final fracMask = dot < 0 ? '' : fmt.substring(dot + 1);
  final fracDigits = fracMask.replaceAll(RegExp("[^0#]"), "").length;
  var s = value.toStringAsFixed(fracDigits);
  var neg = s.startsWith("-");
  if (neg) s = s.substring(1);
  var intPart = fracDigits > 0 ? s.substring(0, s.indexOf(".")) : s;
  final fracPart = fracDigits > 0 ? s.substring(s.indexOf(".") + 1) : "";
  // thousands separator (when the mask contains ',')
  if (intMask.contains(",")) {
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(",");
      buf.write(intPart[i]);
    }
    intPart = buf.toString();
  }
  // minimum digit count for the integer part (the count of '0')
  final minInt = intMask.replaceAll(RegExp("[^0]"), "").length;
  while (intPart.replaceAll(",", "").length < minInt) {
    intPart = '0$intPart';
  }
  var result = intPart;
  if (fracDigits > 0) result = '$result$decimalSeparator$fracPart';
  return neg ? '-$result' : result;
}

// A FloatToStrF subset
String floatToStrF(
    double value, TFloatFormat format, int precision, int digits) {
  switch (format) {
    case TFloatFormat.ffFixed:
    case TFloatFormat.ffNumber:
      return value.toStringAsFixed(digits);
    case TFloatFormat.ffCurrency:
      return value.toStringAsFixed(digits);
    case TFloatFormat.ffExponent:
      return value.toStringAsExponential(precision > 0 ? precision - 1 : 6);
    case TFloatFormat.ffGeneral:
      if (value == value.truncateToDouble() &&
          value.abs() < 1e15 &&
          !value.isInfinite) {
        return value.toInt().toString();
      }
      return value.toString();
  }
}

String _dtPad2(int v) => v.toString().padLeft(2, "0");

// A FormatDateTime subset: supports c / yyyy / yy / mm / dd / hh / nn / ss
String formatDateTime(String fmt, DateTime dt) {
  if (fmt == 'c' || fmt.isEmpty) {
    final d = '${dt.year}-${_dtPad2(dt.month)}-${_dtPad2(dt.day)}';
    if (dt.hour == 0 && dt.minute == 0 && dt.second == 0) return d;
    return '$d ${_dtPad2(dt.hour)}:${_dtPad2(dt.minute)}:${_dtPad2(dt.second)}';
  }
  return fmt
      .replaceAll("yyyy", dt.year.toString().padLeft(4, "0"))
      .replaceAll("yy", _dtPad2(dt.year % 100))
      .replaceAll("mm", _dtPad2(dt.month))
      .replaceAll("dd", _dtPad2(dt.day))
      .replaceAll("hh", _dtPad2(dt.hour))
      .replaceAll("nn", _dtPad2(dt.minute))
      .replaceAll("ss", _dtPad2(dt.second));
}

// Pascal's TDateTime zero value (1899-12-30); returned by GetAsDateTime for a null value
final DateTime pascalZeroDateTime = DateTime(1899, 12, 30);

// StrToDateTime/StrToTime subset
DateTime strToDateTime(String s) {
  final parsed = DateTime.tryParse(s.replaceFirst(" ", "T"));
  if (parsed != null) return parsed;
  throw EDatabaseError('"$s" is not a valid date/time');
}

DateTime strToTime(String s) {
  final parts = s.split(":");
  if (parts.length >= 2) {
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final sec = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    if (h != null && m != null) {
      return DateTime(1899, 12, 30, h, m, sec);
    }
  }
  throw EDatabaseError('"$s" is not a valid time');
}

// ---------------------------------------------------------------------
//  TStringField (db.pas L472-514, implementation fields.inc L1116-1373)
// ---------------------------------------------------------------------
class TStringField extends TField {
  TSystemCodePage _codePage = cpACP;
  bool fixedChar = false;
  bool transliterate = false;

  // constructor（fields.inc L1116-1125）
  TStringField([super.aOwner]) {
    setDataType(TFieldType.ftString);
    _codePage = cpACP;
    fixedChar = false;
    transliterate = false;
    _size = 20;
  }

  TSystemCodePage get codePage => _codePage;

  // SetFieldType（L1127-1131）
  @override
  void setFieldType(TFieldType aValue) {
    if (aValue == TFieldType.ftString || aValue == TFieldType.ftFixedChar) {
      setDataType(aValue);
    }
  }

  // CheckTypeSize (L1133-1141): allows 0 (original comment: Firebird's
  // `select '' as fieldname` produces a size-0 string field)
  @override
  void checkTypeSize(int aValue) {
    if (aValue < 0) {
      databaseErrorFmt(SInvalidFieldSize, [aValue]);
    }
  }

  // GetAsBoolean (L1143-1150): the first character is 'T' or YesNoChars[True]('Y')
  @override
  bool getAsBoolean() {
    final s = getAsString();
    if (s.isEmpty) return false;
    final c = s[0].toUpperCase();
    return c == 'T' || c == yesNoChars[1];
  }

  // GetAsDateTime（L1152）
  @override
  DateTime getAsDateTime() => strToDateTime(getAsString());

  // GetAsFloat（L1158）
  @override
  double getAsFloat() {
    final s = getAsString();
    final f = double.tryParse(s);
    if (f == null) throw EDatabaseError(formatMsg(SNotAFloat, [s]));
    return f;
  }

  // GetAsInteger（L1164）
  @override
  int getAsInteger() {
    final s = getAsString();
    final i = int.tryParse(s);
    if (i == null) throw EDatabaseError(formatMsg(SNotAninteger, [s]));
    return i;
  }

  // GetAsLargeInt（L1170）
  @override
  int getAsLargeInt() => getAsInteger();

  // GetValue (fields.inc L1240-1279): the buffer version pulls out the value and truncates it to
  // Size length (Buf[DataSize-1]:=#0); codepage/transliterate's byte-level
  // operations have no Dart-String equivalent (conventions 1/3); the truncation semantics are kept.
  bool getValue(TStringRef aValue) {
    final buf = TValueBuffer();
    final result = getData(buf);
    if (result) {
      var s = '${buf.value ?? ''}';
      if (size > 0 && s.length > size) s = s.substring(0, size); // truncate
      aValue.value = s;
    }
    return result;
  }

  // GetAsString / GetAsAnsiString / GetAsUTF8String（L1176-1202）
  @override
  String getAsString() {
    final ref = TStringRef("");
    return getValue(ref) ? ref.value : "";
  }

  @override
  String getAsAnsiString() => getAsString();

  @override
  String getAsUTF8String() => getAsString();

  // GetAsVariant（L1204-1216）
  @override
  dynamic getAsVariant() {
    final ref = TStringRef("");
    return getValue(ref) ? ref.value : null;
  }

  // GetDataSize（L1219-1226）
  @override
  int getDataSize() {
    return _codePage == cpUTF8 ? 4 * size + 1 : size + 1;
  }

  // GetDefaultWidth（L1228-1232）
  @override
  int getDefaultWidth() => size;

  // GetText（L1234-1238）
  @override
  void getText(TStringRef aText, bool aDisplayText) {
    aText.value = getAsString();
  }

  // SetAsBoolean（L1281-1288）
  @override
  void setAsBoolean(bool aValue) {
    setAsString(aValue ? 'T' : "F");
  }

  // SetAsDateTime（L1290）
  @override
  void setAsDateTime(DateTime aValue) {
    setAsString(formatDateTime("c", aValue));
  }

  // SetAsFloat（L1296）
  @override
  void setAsFloat(double aValue) {
    setAsString(floatToStrF(aValue, TFloatFormat.ffGeneral, 15, 0));
  }

  // SetAsInteger（L1302）
  @override
  void setAsInteger(int aValue) {
    setAsString("$aValue");
  }

  // SetAsLargeInt（L1308）
  @override
  void setAsLargeInt(int aValue) {
    setAsString("$aValue");
  }

  // SetValue (fields.inc L1314-1349): length truncated to DataSize-1 (=Size);
  // an empty string is still "a valued empty string", not NULL (original source: Buf:=#0; SetData(@Buf))
  void setValue(String aValue) {
    var s = aValue;
    if (size > 0 && s.length > size) {
      s = s.substring(
          0, size); // the truncation semantics of StrPLCopy(..., DataSize-1)
    }
    setData(TValueBuffer(s));
  }

  // SetAsString（L1351-1358）/ SetAsAnsiString / SetAsUTF8String
  @override
  void setAsString(String aValue) => setValue(aValue);
  @override
  void setAsAnsiString(String aValue) => setValue(aValue);
  @override
  void setAsUTF8String(String aValue) => setValue(aValue);

  // SetVarValue（L1370-1373）
  @override
  void setVarValue(dynamic aValue) {
    setAsString("$aValue");
  }
}

// ---------------------------------------------------------------------
//  TWideStringField (db.pas L516-544, implementation fields.inc L1380-1497)
//  A Dart String is already UTF-16, so wide and narrow strings merge; the only remaining difference is the DataSize calculation
// ---------------------------------------------------------------------
class TWideStringField extends TStringField {
  // constructor（L1389-1394）
  TWideStringField([super.aOwner]) {
    setDataType(TFieldType.ftWideString);
    _codePage = cpUTF16;
  }

  // CheckTypeSize (L1380-1387): same as TStringField (allows 0)
  // —— the inherited version behaves the same, no override needed.

  // SetFieldType（L1396-1400）
  @override
  void setFieldType(TFieldType aValue) {
    if (aValue == TFieldType.ftWideString ||
        aValue == TFieldType.ftFixedWideChar) {
      setDataType(aValue);
    }
  }

  // GetDataSize（L1494-1497）
  @override
  int getDataSize() => (size + 1) * 2;

  // GetValue/GetAsString/SetAsString/GetAsVariant/...（L1402-1492）：
  // These are all permutations of wide/narrow string conversion, which Dart merges into TStringField's
  // String implementation, behaviorally equivalent — not overridden again.
}

// ---------------------------------------------------------------------
//  TNumericField (db.pas L546-565, implementation fields.inc L1505-1555)
// ---------------------------------------------------------------------
class TNumericField extends TField {
  String _displayFormat = '';
  String _editFormat = '';

  // constructor（L1505-1510）
  TNumericField([super.aOwner]) {
    alignment = TAlignment.taRightJustify;
  }

  // CheckTypeSize (L1512-1519): allows <=16 (original comment: some TDataset
  // descendants set Size as if it were DataSize; allowed for compatibility)
  @override
  void checkTypeSize(int aValue) {
    if (aValue > 16) {
      databaseErrorFmt(SInvalidFieldSize, [aValue]);
    }
  }

  // RangeError（L1521-1525）
  void rangeError(double aValue, double min, double max) {
    databaseErrorFmt(
        SFieldError + SRangeError2, [displayName, aValue, min, max]);
  }

  // DisplayFormat（L1527-1535）
  String get displayFormat => _displayFormat;
  set displayFormat(String aValue) {
    if (_displayFormat != aValue) {
      _displayFormat = aValue;
      propertyChanged(true);
    }
  }

  // EditFormat（L1537-1545）
  String get editFormat => _editFormat;
  set editFormat(String aValue) {
    if (_editFormat != aValue) {
      _editFormat = aValue;
      propertyChanged(true);
    }
  }

  // GetAsBoolean（L1547-1550）
  @override
  bool getAsBoolean() => getAsInteger() != 0;

  // SetAsBoolean（L1552-1555）
  @override
  void setAsBoolean(bool aValue) => setAsInteger(aValue ? 1 : 0);
}

// ---------------------------------------------------------------------
//  TLongintField (db.pas L567-595, implementation fields.inc L1562-1725)
// ---------------------------------------------------------------------
class TLongintField extends TNumericField {
  int _minValue = 0;
  int _maxValue = 0;
  int _minRange = 0;
  int _maxRange = 0;

  // constructor（L1562-1570）
  TLongintField([super.aOwner]) {
    setDataType(TFieldType.ftInteger);
    _minRange = -2147483648; // Low(LongInt)
    _maxRange = 2147483647; // High(LongInt)
    validChars = {'+', "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};
  }

  // GetAsFloat（L1572）
  @override
  double getAsFloat() => getAsInteger().toDouble();

  // GetAsLargeInt（L1578）
  @override
  int getAsLargeInt() => getAsInteger();

  // GetAsInteger（L1583-1588）
  @override
  int getAsInteger() {
    final ref = TIntRef(0);
    if (!getValue(ref)) return 0;
    return ref.value;
  }

  // GetAsVariant（L1590-1599）
  @override
  dynamic getAsVariant() {
    final ref = TIntRef(0);
    return getValue(ref) ? ref.value : null;
  }

  // GetAsString（L1601-1610）
  @override
  String getAsString() {
    final ref = TIntRef(0);
    return getValue(ref) ? '${ref.value}' : "";
  }

  // GetDataSize（L1612）：SizeOf(Longint)
  @override
  int getDataSize() => 4;

  // GetText（L1618-1634）
  @override
  void getText(TStringRef aText, bool aDisplayText) {
    aText.value = '';
    final ref = TIntRef(0);
    if (!getValue(ref)) return;
    final fmt =
        (aDisplayText || _editFormat == '') ? _displayFormat : _editFormat;
    if (fmt.isNotEmpty) {
      aText.value = formatFloat(fmt, ref.value);
    } else {
      aText.value = '${ref.value}';
    }
  }

  // GetValue (fields.inc L1636-1651): reads Longint/Word/Smallint from the buffer depending on
  // DataType —— since value transport is already type-agnostic (convention 1), everything is uniformly read as int
  bool getValue(TIntRef aValue) {
    final buf = TValueBuffer();
    final result = getData(buf);
    if (result) {
      final v = buf.value;
      if (v is int) {
        aValue.value = v;
      } else if (v is num) {
        aValue.value = v.toInt();
      } else if (v is String) {
        aValue.value = int.tryParse(v) ?? 0;
      }
    }
    return result;
  }

  // SetAsLargeInt（L1653-1659）
  @override
  void setAsLargeInt(int aValue) {
    if (aValue >= _minRange && aValue <= _maxRange) {
      setAsInteger(aValue);
    } else {
      rangeError(aValue.toDouble(), _minRange.toDouble(), _maxRange.toDouble());
    }
  }

  // SetAsFloat（L1661-1665）
  @override
  void setAsFloat(double aValue) {
    setAsInteger(aValue.round());
  }

  // SetAsInteger（L1667-1676）
  @override
  void setAsInteger(int aValue) {
    if (checkRange(aValue)) {
      setData(TValueBuffer(aValue));
    } else {
      if (_minValue != 0 || _maxValue != 0) {
        rangeError(
            aValue.toDouble(), _minValue.toDouble(), _maxValue.toDouble());
      } else {
        rangeError(
            aValue.toDouble(), _minRange.toDouble(), _maxRange.toDouble());
      }
    }
  }

  // SetVarValue (L1678-1681): a Variant implicitly converted to an integer —— maps in Dart to
  // a lenient num/String conversion (a Pascal Variant assignment already does this coercion)
  @override
  void setVarValue(dynamic aValue) {
    if (aValue is int) {
      setAsInteger(aValue);
    } else if (aValue is num) {
      setAsInteger(aValue.toInt());
    } else {
      final i = int.tryParse("$aValue");
      if (i == null) {
        databaseErrorFmt(SFieldError + SNotAninteger, [displayName, aValue]);
      }
      setAsInteger(i);
    }
  }

  // SetAsString (L1683-1698): a Val() parse failure throws SNotAnInteger
  @override
  void setAsString(String aValue) {
    if (aValue.isEmpty) {
      clear();
    } else {
      final l = int.tryParse(aValue);
      if (l != null) {
        setAsInteger(l);
      } else {
        databaseErrorFmt(SFieldError + SNotAninteger, [displayName, aValue]);
      }
    }
  }

  // CheckRange（L1700-1707）
  bool checkRange(int aValue) {
    if (_minValue != 0 || _maxValue != 0) {
      return aValue >= _minValue && aValue <= _maxValue;
    }
    return aValue >= _minRange && aValue <= _maxRange;
  }

  // MinValue/MaxValue（L1709-1725）
  int get maxValue => _maxValue;
  set maxValue(int aValue) {
    if (aValue >= _minRange && aValue <= _maxRange) {
      _maxValue = aValue;
    } else {
      rangeError(aValue.toDouble(), _minRange.toDouble(), _maxRange.toDouble());
    }
  }

  int get minValue => _minValue;
  set minValue(int aValue) {
    if (aValue >= _minRange && aValue <= _maxRange) {
      _minValue = aValue;
    } else {
      rangeError(aValue.toDouble(), _minRange.toDouble(), _maxRange.toDouble());
    }
  }
}

// TIntegerField = Class(TLongintField)（db.pas L597）
class TIntegerField extends TLongintField {
  TIntegerField([super.aOwner]);
}

// ---------------------------------------------------------------------
//  TLargeintField (db.pas L601-632, implementation fields.inc L1732-1885)
//  Dart's int is 64-bit itself, logically isomorphic to TLongintField with a different range
// ---------------------------------------------------------------------
class TLargeintField extends TNumericField {
  int _minValue = 0;
  int _maxValue = 0;
  int _minRange = 0;
  int _maxRange = 0;

  // constructor（L1732-1740）
  TLargeintField([super.aOwner]) {
    setDataType(TFieldType.ftLargeint);
// aa !!! not fully translated
    // Platform limitation: on Web (JS), integers are doubles and can't precisely represent ±2^63. The bit
    // operations here construct the boundary values (Low = (-1)<<63, High = ~Low), but **a
    // LargeInt beyond 2^53 will still lose precision on Web**. Native (VM) targets don't have this problem.
    _minRange = -1 << 63; // Low(Largeint) = -9223372036854775808
    _maxRange = ~(-1 << 63); // High(Largeint) = 9223372036854775807
// zz !!! not fully translated
    validChars = {'+', "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};
  }

  @override
  double getAsFloat() => getAsLargeInt().toDouble();

  @override
  int getAsLargeInt() {
    final ref = TIntRef(0);
    if (!getValue(ref)) return 0;
    return ref.value;
  }

  @override
  dynamic getAsVariant() {
    final ref = TIntRef(0);
    return getValue(ref) ? ref.value : null;
  }

  @override
  int getAsInteger() => getAsLargeInt();

  @override
  String getAsString() {
    final ref = TIntRef(0);
    return getValue(ref) ? '${ref.value}' : "";
  }

  // GetDataSize：SizeOf(Largeint)
  @override
  int getDataSize() => 8;

  @override
  void getText(TStringRef aText, bool aDisplayText) {
    aText.value = '';
    final ref = TIntRef(0);
    if (!getValue(ref)) return;
    final fmt =
        (aDisplayText || _editFormat == '') ? _displayFormat : _editFormat;
    if (fmt.isNotEmpty) {
      aText.value = formatFloat(fmt, ref.value);
    } else {
      aText.value = '${ref.value}';
    }
  }

  bool getValue(TIntRef aValue) {
    final buf = TValueBuffer();
    final result = getData(buf);
    if (result) {
      final v = buf.value;
      if (v is int) {
        aValue.value = v;
      } else if (v is num) {
        aValue.value = v.toInt();
      } else if (v is String) {
        aValue.value = int.tryParse(v) ?? 0;
      }
    }
    return result;
  }

  @override
  void setAsFloat(double aValue) {
    setAsLargeInt(aValue.round());
  }

  @override
  void setAsLargeInt(int aValue) {
    if (checkRange(aValue)) {
      setData(TValueBuffer(aValue));
    } else {
      rangeError(aValue.toDouble(), _minValue.toDouble(), _maxValue.toDouble());
    }
  }

  @override
  void setAsInteger(int aValue) {
    setAsLargeInt(aValue);
  }

  @override
  void setAsString(String aValue) {
    if (aValue.isEmpty) {
      clear();
    } else {
      final l = int.tryParse(aValue);
      if (l != null) {
        setAsLargeInt(l);
      } else {
        databaseErrorFmt(SFieldError + SNotAninteger, [displayName, aValue]);
      }
    }
  }

  @override
  void setVarValue(dynamic aValue) {
    if (aValue is int) {
      setAsLargeInt(aValue);
    } else if (aValue is num) {
      setAsLargeInt(aValue.toInt());
    } else {
      final i = int.tryParse("$aValue");
      if (i == null) {
        databaseErrorFmt(SFieldError + SNotAninteger, [displayName, aValue]);
      }
      setAsLargeInt(i);
    }
  }

  bool checkRange(int aValue) {
    if (_minValue != 0 || _maxValue != 0) {
      return aValue >= _minValue && aValue <= _maxValue;
    }
    return aValue >= _minRange && aValue <= _maxRange;
  }

  int get maxValue => _maxValue;
  set maxValue(int aValue) {
    if (aValue >= _minRange && aValue <= _maxRange) {
      _maxValue = aValue;
    } else {
      rangeError(aValue.toDouble(), _minRange.toDouble(), _maxRange.toDouble());
    }
  }

  int get minValue => _minValue;
  set minValue(int aValue) {
    if (aValue >= _minRange && aValue <= _maxRange) {
      _minValue = aValue;
    } else {
      rangeError(aValue.toDouble(), _minRange.toDouble(), _maxRange.toDouble());
    }
  }
}

// ---- TSmallintField (db.pas L634-641, implementation fields.inc L1889-1902) ----------
class TSmallintField extends TLongintField {
  TSmallintField([super.aOwner]) {
    setDataType(TFieldType.ftSmallint);
    _minRange = -32768;
    _maxRange = 32767;
  }

  // GetDataSize：SizeOf(SmallInt)
  @override
  int getDataSize() => 2;
}

// ---- TWordField (db.pas L643-650, implementation fields.inc L1907-1921) --------------
class TWordField extends TLongintField {
  TWordField([super.aOwner]) {
    setDataType(TFieldType.ftWord);
    _minRange = 0;
    _maxRange = 65535;
    validChars = {'+', "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};
  }

  // GetDataSize：SizeOf(Word)
  @override
  int getDataSize() => 2;
}

// ---- TAutoIncField (db.pas L652-659, implementation fields.inc L1925-1941) -----------
class TAutoIncField extends TLongintField {
  TAutoIncField([super.aOwner]) {
    setDataType(TFieldType.ftAutoInc);
  }

  // SetAsInteger (L1932-1941): the original source keeps a commented-out read-only check
  // (allowing the client to push a value, leaving enforcement to the server side), calling inherited directly
  @override
  void setAsInteger(int aValue) {
    // Some databases allows insertion of explicit values into identity
    // columns ... So allow it at client side and leave check for server
    // side (original comment kept as-is)
    super.setAsInteger(aValue);
  }
}

// ---------------------------------------------------------------------
//  TFloatField (db.pas L661-696, implementation fields.inc L1945-2110)
// ---------------------------------------------------------------------
class TFloatField extends TNumericField {
  bool _currency = false;
  double _maxValue = 0;
  double _minValue = 0;
  int _precision = 15;

  // constructor（L2094-2101）
  TFloatField([super.aOwner]) {
    setDataType(TFieldType.ftFloat);
    _precision = 15;
    validChars = {
      decimalSeparator,
      "+",
      "-",
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "E",
      "e"
    };
  }

  // Currency（L1945-1949）
  bool get currency => _currency;
  set currency(bool aValue) {
    if (_currency == aValue) return;
    _currency = aValue;
  }

  // Precision（L1951-1957）
  int get precision => _precision;
  set precision(int aValue) {
    if (aValue == -1 || aValue > 1) {
      _precision = aValue;
    } else {
      _precision = 2;
    }
  }

  double get maxValue => _maxValue;
  set maxValue(double v) => _maxValue = v;
  double get minValue => _minValue;
  set minValue(double v) => _minValue = v;

  // GetAsBCD (L1959-1966): TBCD→double (convention 5)
  @override
  double getAsBCD() {
    final buf = TValueBuffer();
    if (getData(buf)) {
      return _toDouble(buf.value);
    }
    return 0.0; // the double equivalent of NullBCD
  }

  double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse("$v") ?? 0.0;
  }

  // GetAsFloat（L1968-1973）
  @override
  double getAsFloat() {
    final buf = TValueBuffer();
    if (!getData(buf)) return 0.0;
    return _toDouble(buf.value);
  }

  // GetAsVariant（L1975-1984）
  @override
  dynamic getAsVariant() {
    final buf = TValueBuffer();
    return getData(buf) ? _toDouble(buf.value) : null;
  }

  // GetAsLargeInt（L1986）/ GetAsInteger（L1991）
  @override
  int getAsLargeInt() => getAsFloat().round();
  @override
  int getAsInteger() => getAsFloat().round();

  // GetAsString（L1997-2006）
  @override
  String getAsString() {
    final buf = TValueBuffer();
    if (!getData(buf)) return '';
    return floatToStrF(_toDouble(buf.value), TFloatFormat.ffGeneral, 15, 0);
  }

  // GetDataSize：SizeOf(Double)
  @override
  int getDataSize() => 8;

  // GetText（L2014-2047）
  @override
  void getText(TStringRef aText, bool aDisplayText) {
    aText.value = '';
    final buf = TValueBuffer();
    if (!getData(buf)) return;
    final e = _toDouble(buf.value);
    final fmt =
        (aDisplayText || _editFormat.isEmpty) ? _displayFormat : _editFormat;

    var digits = 0;
    TFloatFormat ff;
    if (!_currency) {
      ff = TFloatFormat.ffGeneral;
    } else {
      digits = currencyDecimals;
      ff = aDisplayText ? TFloatFormat.ffCurrency : TFloatFormat.ffFixed;
    }

    if (fmt.isNotEmpty) {
      aText.value = formatFloat(fmt, e);
    } else {
      aText.value = floatToStrF(e, ff, _precision, digits);
    }
  }

  // SetAsBCD（L2049-2052）
  @override
  void setAsBCD(double aValue) {
    setAsFloat(aValue);
  }

  // SetAsFloat（L2054-2061）
  @override
  void setAsFloat(double aValue) {
    if (checkRange(aValue)) {
      setData(TValueBuffer(aValue));
    } else {
      rangeError(aValue, _minValue, _maxValue);
    }
  }

  // SetAsLargeInt（L2063）/ SetAsInteger（L2068）
  @override
  void setAsLargeInt(int aValue) => setAsFloat(aValue.toDouble());
  @override
  void setAsInteger(int aValue) => setAsFloat(aValue.toDouble());

  // SetAsString（L2074-2087）
  @override
  void setAsString(String aValue) {
    if (aValue.isEmpty) {
      clear();
    } else {
      final f = double.tryParse(aValue);
      if (f == null) {
        databaseErrorFmt(SNotAFloat, [aValue]);
      }
      setAsFloat(f);
    }
  }

  // SetVarValue（L2089-2092）
  @override
  void setVarValue(dynamic aValue) {
    if (aValue is num) {
      setAsFloat(aValue.toDouble());
    } else {
      final f = double.tryParse("$aValue");
      if (f == null) {
        databaseErrorFmt(SNotAFloat, [aValue]);
      }
      setAsFloat(f);
    }
  }

  // CheckRange（L2103-2110）
  bool checkRange(double aValue) {
    if (_minValue != 0 || _maxValue != 0) {
      return aValue >= _minValue && aValue <= _maxValue;
    }
    return true;
  }
}

// ---- TCurrencyField (db.pas L698-705, implementation fields.inc L2114-2120) ----------
class TCurrencyField extends TFloatField {
  TCurrencyField([super.aOwner]) {
    setDataType(TFieldType.ftCurrency);
    currency = true;
  }
}

// ---------------------------------------------------------------------
//  TBooleanField (db.pas L707-731, implementation fields.inc L2124-2237)
// ---------------------------------------------------------------------
class TBooleanField extends TField {
  String _displayValues = '';
  // FDisplays : Array[Boolean,Boolean] of String
  // First dimension = whether it's the uppercase version, second dimension = the boolean value; [u][v] u,v: false=0,true=1
  final List<List<String>> _displays = [
    ['', ""],
    ['', ""]
  ];

  // constructor（L2211-2217）
  TBooleanField([super.aOwner]) {
    setDataType(TFieldType.ftBoolean);
    displayValues = 'True;False';
  }

  bool? _getRaw() {
    final buf = TValueBuffer();
    if (!getData(buf)) return null;
    final v = buf.value;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = '$v'.toUpperCase();
    return s == 'TRUE' || s == 'T' || s == 'Y' || s == '1';
  }

  // GetAsBoolean（L2124-2133）
  @override
  bool getAsBoolean() => _getRaw() ?? false;

  // GetAsVariant（L2135-2144）
  @override
  dynamic getAsVariant() => _getRaw();

  // GetAsString（L2146-2155）：FDisplays[False,B]
  @override
  String getAsString() {
    final b = _getRaw();
    if (b == null) return '';
    return _displays[0][b ? 1 : 0];
  }

  // GetDataSize：SizeOf(wordBool)
  @override
  int getDataSize() => 2;

  // GetDefaultWidth（L2163-2169）
  @override
  int getDefaultWidth() {
    var result = _displays[0][0].length;
    if (result < _displays[0][1].length) {
      result = _displays[0][1].length;
    }
    return result;
  }

  // GetAsInteger（L2171-2174）
  @override
  int getAsInteger() => getAsBoolean() ? 1 : 0;

  // SetAsInteger（L2176-2179）
  @override
  void setAsInteger(int aValue) => setAsBoolean(aValue != 0);

  // SetAsBoolean（L2181-2188）
  @override
  void setAsBoolean(bool aValue) {
    setData(TValueBuffer(aValue));
  }

  // SetAsString (L2190-2204): compared by prefix against the uppercase display value
  @override
  void setAsString(String aValue) {
    final temp = aValue.toUpperCase();
    if (temp.isEmpty) {
      clear();
    } else if (_displays[1][1].startsWith(temp)) {
      setAsBoolean(true);
    } else if (_displays[1][0].startsWith(temp)) {
      setAsBoolean(false);
    } else {
      databaseErrorFmt(SNotABoolean, [aValue]);
    }
  }

  // SetVarValue（L2206-2209）
  @override
  void setVarValue(dynamic aValue) {
    if (aValue is bool) {
      setAsBoolean(aValue);
    } else if (aValue is num) {
      setAsBoolean(aValue != 0);
    } else {
      setAsString("$aValue");
    }
  }

  // DisplayValues（L2219-2237）
  String get displayValues => _displayValues;
  set displayValues(String aValue) {
    if (_displayValues != aValue) {
      final i = aValue.indexOf(";") + 1; // Pascal's Pos is 1-based
      if (i < 2 || i == aValue.length) {
        databaseErrorFmt(
            SFieldError + SInvalidDisplayValues, [displayName, aValue]);
      }
      _displayValues = aValue;
      // Store display values and their uppercase equivalents; (original comment)
      _displays[0][1] =
          aValue.substring(0, i - 1); // the display value for True
      _displays[1][1] = _displays[0][1].toUpperCase();
      _displays[0][0] = aValue.substring(i); // the display value for False
      _displays[1][0] = _displays[0][0].toUpperCase();
      propertyChanged(true);
    }
  }
}

// ---------------------------------------------------------------------
//  TDateTimeField (db.pas L733-756, implementation fields.inc L2241-2351)
// ---------------------------------------------------------------------
class TDateTimeField extends TField {
  String _displayFormat = '';

  // constructor（L2346-2351）
  TDateTimeField([super.aOwner]) {
    setDataType(TFieldType.ftDateTime);
  }

  // DisplayFormat（L2241-2247）
  String get displayFormat => _displayFormat;
  set displayFormat(String aValue) {
    if (_displayFormat != aValue) {
      _displayFormat = aValue;
      propertyChanged(true);
    }
  }

  DateTime? _getRaw() {
    final buf = TValueBuffer();
    if (!getData(buf, false)) return null;
    final v = buf.value;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v.replaceFirst(" ", "T"));
    return null;
  }

  // GetAsDateTime (L2249-2254): returns 0 (=1899-12-30, convention 4) when null
  @override
  DateTime getAsDateTime() => _getRaw() ?? pascalZeroDateTime;

  // SetVarValue（L2256-2259）
  @override
  void setVarValue(dynamic aValue) {
    if (aValue is DateTime) {
      setAsDateTime(aValue);
    } else {
      setAsDateTime(strToDateTime("$aValue"));
    }
  }

  // GetAsVariant（L2261-2270）
  @override
  dynamic getAsVariant() => _getRaw();

  // GetAsFloat (L2272-2276): TDateTime's double representation (a day count
  // from 1899-12-30, converted per convention 4)
  @override
  double getAsFloat() {
    final d = getAsDateTime();
    return d.difference(pascalZeroDateTime).inMilliseconds / 86400000.0;
  }

  // GetAsString（L2279-2283）
  @override
  String getAsString() {
    final ref = TStringRef("");
    getText(ref, false);
    return ref.value;
  }

  // GetDataSize：SizeOf(TDateTime)
  @override
  int getDataSize() => 8;

  // GetText（L2293-2314）
  @override
  void getText(TStringRef aText, bool aDisplayText) {
    final r = _getRaw();
    if (r == null) {
      aText.value = '';
    } else {
      String f;
      if (aDisplayText && _displayFormat.isNotEmpty) {
        f = _displayFormat;
      } else {
        switch (dataType) {
          case TFieldType.ftTime:
            f = longTimeFormat;
            break;
          case TFieldType.ftDate:
            f = shortDateFormat;
            break;
          default:
            f = 'c';
        }
      }
      aText.value = formatDateTime(f, r);
    }
  }

  // SetAsDateTime（L2317-2321）
  @override
  void setAsDateTime(DateTime aValue) {
    setData(TValueBuffer(aValue), false);
  }

  // SetAsFloat (L2324-2328): a days-double → DateTime (converted per convention 4)
  @override
  void setAsFloat(double aValue) {
    setAsDateTime(pascalZeroDateTime
        .add(Duration(milliseconds: (aValue * 86400000).round())));
  }

  // SetAsString（L2331-2343）
  @override
  void setAsString(String aValue) {
    if (aValue.isNotEmpty) {
      setData(TValueBuffer(strToDateTime(aValue)), false);
    } else {
      setData(null);
    }
  }
}

// ---- TDateField (db.pas L758-763, implementation fields.inc L2356-2361) --------------
class TDateField extends TDateTimeField {
  TDateField([super.aOwner]) {
    setDataType(TFieldType.ftDate);
  }
}

// ---- TTimeField (db.pas L765-772, implementation fields.inc L2366-2383) --------------
class TTimeField extends TDateTimeField {
  TTimeField([super.aOwner]) {
    setDataType(TFieldType.ftTime);
  }

  // SetAsString（L2373-2383）
  @override
  void setAsString(String aValue) {
    if (aValue.isEmpty) {
      clear(); // set to NULL (original comment kept as-is)
    } else {
      setData(TValueBuffer(strToTime(aValue)), false);
    }
  }
}

// ---------------------------------------------------------------------
//  TBinaryField (db.pas L774-790, implementation fields.inc L2389-2520)
//  ??? Byte-layout details (ftVarBytes' Word length prefix, ftBytes' zero-padding)
//  are part of the buffer's memory layout; TValueBuffer holds a Uint8List directly,
//  so the length prefix doesn't need separate encoding, but the semantics of "ftBytes fixed-length
//  zero-pad/truncate, ftVarBytes preserves the actual length" are kept.
// ---------------------------------------------------------------------
class TBinaryField extends TField {
  TBinaryField([super.aOwner]);

  // CheckTypeSize（L2389-2396）
  @override
  void checkTypeSize(int aValue) {
    // Just check for really invalid stuff; actual size is dependent on
    // the record... (original comment kept as-is; an MSSQL view can have a 0-length field)
    if (aValue < 0) {
      databaseErrorFmt(SInvalidFieldSize, [aValue]);
    }
  }

  // GetValue（L2434-2447）
  bool getValue(TValueBuffer aValue) {
    final buf = TValueBuffer();
    final result = getData(buf, true);
    if (result) {
      final v = buf.value;
      if (v is Uint8List) {
        aValue.value = v;
      } else if (v is List<int>) {
        aValue.value = Uint8List.fromList(v);
      } else if (v is String) {
        aValue.value = Uint8List.fromList(v.codeUnits);
      } else {
        aValue.value = Uint8List(0);
      }
    }
    return result;
  }

  // GetAsBytes（L2398-2402）
  @override
  Uint8List? getAsBytes() {
    final buf = TValueBuffer();
    if (!getValue(buf)) return Uint8List(0);
    return buf.value as Uint8List;
  }

  // GetAsString（L2405-2412）
  @override
  String getAsString() {
    final buf = TValueBuffer();
    if (!getValue(buf)) return '';
    return String.fromCharCodes(buf.value as Uint8List);
  }

  // GetAsVariant（L2415-2431）：VarArray of byte → Uint8List
  @override
  dynamic getAsVariant() {
    final buf = TValueBuffer();
    return getValue(buf) ? buf.value : null;
  }

  // SetAsBytes (L2450-2477): ftBytes zero-pads to a fixed length, ftVarBytes keeps
  // the actual length
  @override
  void setAsBytes(Uint8List aValue) {
    Uint8List data;
    if (dataType == TFieldType.ftVarBytes || aValue.length >= getDataSize()) {
      data = aValue;
    } else {
      // ftBytes: right pad with #0 (original comment kept as-is)
      data = Uint8List(getDataSize());
      data.setRange(0, aValue.length, aValue);
    }
    setData(TValueBuffer(data), true);
  }

  // SetAsString（L2480-2491）
  @override
  void setAsString(String aValue) {
    setAsBytes(Uint8List.fromList(aValue.codeUnits));
  }

  // SetVarValue（L2494-2513）
  @override
  void setVarValue(dynamic aValue) {
    if (aValue is Uint8List) {
      setAsBytes(aValue);
    } else if (aValue is List<int>) {
      setAsBytes(Uint8List.fromList(aValue));
    } else {
      setAsString("$aValue");
    }
  }
}

// ---- TBytesField (db.pas L792-799, implementation fields.inc L2526-2539) -------------
class TBytesField extends TBinaryField {
  TBytesField([super.aOwner]) {
    setDataType(TFieldType.ftBytes);
    size = 16;
  }

  // GetDataSize（L2526-2530）
  @override
  int getDataSize() => size;
}

// ---- TVarBytesField (db.pas L801-808, implementation fields.inc L2545-2558) ----------
class TVarBytesField extends TBytesField {
  TVarBytesField([super.aOwner]) {
    setDataType(TFieldType.ftVarBytes);
    size = 16;
  }

  // GetDataSize (L2545-2549): Size+2 (a Word length prefix)
  @override
  int getDataSize() => size + 2;
}

// ---------------------------------------------------------------------
//  TBCDField (db.pas L810-846, implementation fields.inc L2562-2729)
//  The underlying type is system.Currency (a 4-decimal-place fixed-point number) → double (convention 5)
// ---------------------------------------------------------------------
class TBCDField extends TNumericField {
  bool _currency = false;
  double _maxValue = 0;
  double _minValue = 0;
  int _precision = 18;

  // constructor（L2719-2729）
  TBCDField([super.aOwner]) {
    _maxValue = 0;
    _minValue = 0;
    validChars = {
      decimalSeparator,
      "+",
      "-",
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9"
    };
    setDataType(TFieldType.ftBCD);
    precision = 18;
    size = 4;
  }

  bool get currency => _currency;
  set currency(bool v) => _currency = v;
  int get precision => _precision;
  set precision(int v) => _precision = v;
  double get maxValue => _maxValue;
  set maxValue(double v) => _maxValue = v;
  double get minValue => _minValue;
  set minValue(double v) => _minValue = v;

  // CheckTypeSize（L2562-2567）：0..4
  @override
  void checkTypeSize(int aValue) {
    if (aValue < 0 || aValue > 4) {
      databaseErrorFmt(SInvalidFieldSize, [aValue]);
    }
  }

  double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse("$v") ?? 0.0;
  }

  bool _getRaw(TValueBuffer buf) => getData(buf);

  // GetAsBCD（L2569-2578）
  @override
  double getAsBCD() {
    final buf = TValueBuffer();
    return _getRaw(buf) ? _toDouble(buf.value) : 0.0;
  }

  // GetAsCurrency（L2580-2585）
  @override
  double getAsCurrency() {
    final buf = TValueBuffer();
    return _getRaw(buf) ? _toDouble(buf.value) : 0;
  }

  // GetAsVariant（L2587-2596）
  @override
  dynamic getAsVariant() {
    final buf = TValueBuffer();
    return _getRaw(buf) ? _toDouble(buf.value) : null;
  }

  // GetAsFloat（L2598）
  @override
  double getAsFloat() => getAsCurrency();

  // GetAsInteger（L2605）
  @override
  int getAsInteger() => getAsCurrency().round();

  // GetAsString（L2612-2621）
  @override
  String getAsString() {
    final buf = TValueBuffer();
    if (!_getRaw(buf)) return '';
    return floatToStrF(_toDouble(buf.value), TFloatFormat.ffGeneral, 15, 0);
  }

  // GetValue（L2623-2627）
  bool getValue(TValueBuffer aValue) => getData(aValue);

  // GetDataSize：sizeof(system.currency)
  @override
  int getDataSize() => 8;

  // GetDefaultWidth（L2635-2640）
  @override
  int getDefaultWidth() => _precision > 0 ? _precision + 1 : 10;

  // GetText（L2642-2663）
  @override
  void getText(TStringRef aText, bool aDisplayText) {
    final buf = TValueBuffer();
    if (_getRaw(buf)) {
      final c = _toDouble(buf.value);
      final fmt =
          (aDisplayText || _editFormat == '') ? _displayFormat : _editFormat;
      if (fmt.isNotEmpty) {
        aText.value = formatFloat(fmt, c);
      } else if (_currency) {
        aText.value = floatToStrF(
            c,
            aDisplayText ? TFloatFormat.ffCurrency : TFloatFormat.ffFixed,
            _precision,
            2 /*digits? (original comment kept as-is)*/);
      } else {
        aText.value = floatToStrF(c, TFloatFormat.ffGeneral, _precision, 0);
      }
    } else {
      aText.value = '';
    }
  }

  // SetAsBCD（L2665-2671）
  @override
  void setAsBCD(double aValue) {
    setAsCurrency(aValue);
  }

  // SetAsCurrency（L2673-2680）
  @override
  void setAsCurrency(double aValue) {
    if (checkRange(aValue)) {
      setData(TValueBuffer(aValue));
    } else {
      rangeError(aValue, _minValue, _maxValue);
    }
  }

  // SetVarValue（L2682-2685）
  @override
  void setVarValue(dynamic aValue) {
    setAsCurrency(_toDouble(aValue));
  }

  // CheckRange（L2687-2694）
  bool checkRange(double aValue) {
    if (_minValue != 0 || _maxValue != 0) {
      return aValue >= _minValue && aValue <= _maxValue;
    }
    return true;
  }

  // SetAsFloat（L2696）/ SetAsInteger（L2703）
  @override
  void setAsFloat(double aValue) => setAsCurrency(aValue);
  @override
  void setAsInteger(int aValue) => setAsCurrency(aValue.toDouble());

  // SetAsString（L2710-2717）
  @override
  void setAsString(String aValue) {
    if (aValue.isEmpty) {
      clear(); // set to NULL (original comment kept as-is)
    } else {
      final c = double.tryParse(aValue);
      if (c == null) {
        databaseErrorFmt(SNotAFloat, [aValue]);
      }
      setAsCurrency(c);
    }
  }
}

// ---------------------------------------------------------------------
//  TFMTBCDField (db.pas L848-889, implementation fields.inc L2734-2912)
//  TBCD (the fmtbcd unit, not provided) → double (convention 5); the MinValue/MaxValue
//  properties keep a String interface (round-tripping through BCDToStr/StrToBCD as in the original source)
// ---------------------------------------------------------------------
const int maxFMTBcdFractionSize = 255; // fmtbcd unit MAXFMTBcdFractionSize

class TFMTBCDField extends TNumericField {
  bool _currency = false;
  double _maxValue = 0;
  double _minValue = 0;
  int _precision = 18;

  // constructor（L2740-2751）
  TFMTBCDField([super.aOwner]) {
    _maxValue = 0;
    _minValue = 0;
    validChars = {
      decimalSeparator,
      "+",
      "-",
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9"
    };
    setDataType(TFieldType.ftFMTBcd);
    // Max.precision for NUMERIC,DECIMAL datatypes supported by some
    // databases: Firebird-18; Oracle,SqlServer-38; MySQL-65;
    // PostgreSQL-1000 (original comment kept as-is)
    precision = 18; // default number of digits
    size = 4; // default number of digits after decimal place
  }

  bool get currency => _currency;
  set currency(bool v) => _currency = v;
  int get precision => _precision;
  set precision(int v) => _precision = v;

  // CheckTypeSize（L2734-2738）
  @override
  void checkTypeSize(int aValue) {
    if (aValue > maxFMTBcdFractionSize) {
      databaseErrorFmt(SInvalidFieldSize, [aValue]);
    }
  }

  double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse("$v") ?? 0.0;
  }

  // GetDataSize: sizeof(TBCD) (fmtbcd's TBCD is 34 bytes; since convention 5
  // has already switched it to double, this reports the double's size instead)
  @override
  int getDataSize() => 8;

  // GetDefaultWidth（L2758-2762）
  @override
  int getDefaultWidth() =>
      _precision > 0 ? _precision + 1 : super.getDefaultWidth();

  // GetAsBCD（L2764-2768）
  @override
  double getAsBCD() {
    final buf = TValueBuffer();
    return getData(buf) ? _toDouble(buf.value) : 0.0;
  }

  // GetAsCurrency（L2770-2777）
  @override
  double getAsCurrency() {
    final buf = TValueBuffer();
    return getData(buf) ? _toDouble(buf.value) : 0;
  }

  // GetAsVariant（L2779-2786）
  @override
  dynamic getAsVariant() {
    final buf = TValueBuffer();
    return getData(buf) ? _toDouble(buf.value) : null;
  }

  // GetAsFloat（L2788-2795）
  @override
  double getAsFloat() {
    final buf = TValueBuffer();
    return getData(buf) ? _toDouble(buf.value) : 0;
  }

  // GetAsLargeInt（L2797-2804）
  @override
  int getAsLargeInt() {
    final buf = TValueBuffer();
    return getData(buf) ? _toDouble(buf.value).truncate() : 0;
  }

  // GetAsInteger（L2806-2809）
  @override
  int getAsInteger() => getAsFloat().round();

  // GetAsString（L2811-2818）
  @override
  String getAsString() {
    final buf = TValueBuffer();
    if (!getData(buf)) return '';
    return floatToStrF(_toDouble(buf.value), TFloatFormat.ffGeneral, 15, 0);
  }

  // GetText（L2820-2841）
  @override
  void getText(TStringRef aText, bool aDisplayText) {
    final buf = TValueBuffer();
    if (getData(buf)) {
      final bcd = _toDouble(buf.value);
      final fmt =
          (aDisplayText || _editFormat == '') ? _displayFormat : _editFormat;
      if (fmt.isNotEmpty) {
        aText.value = formatFloat(fmt, bcd);
      } else if (_currency) {
        aText.value = floatToStrF(
            bcd,
            aDisplayText ? TFloatFormat.ffCurrency : TFloatFormat.ffFixed,
            _precision,
            2);
      } else {
        aText.value =
            floatToStrF(bcd, TFloatFormat.ffGeneral, _precision, size);
      }
    } else {
      aText.value = '';
    }
  }

  // MaxValue/MinValue (L2843-2861): a String interface
  String get maxValue => floatToStrF(_maxValue, TFloatFormat.ffGeneral, 15, 0);
  set maxValue(String aValue) => _maxValue = double.tryParse(aValue) ?? 0;
  String get minValue => floatToStrF(_minValue, TFloatFormat.ffGeneral, 15, 0);
  set minValue(String aValue) => _minValue = double.tryParse(aValue) ?? 0;

  // CheckRange（L2863-2869）
  bool checkRange(double aValue) {
    if (_minValue != 0 || _maxValue != 0) {
      return aValue >= _minValue && aValue <= _maxValue;
    }
    return true;
  }

  // SetAsBCD（L2871-2877）
  @override
  void setAsBCD(double aValue) {
    if (checkRange(aValue)) {
      setData(TValueBuffer(aValue));
    } else {
      rangeError(aValue, _minValue, _maxValue);
    }
  }

  // SetAsCurrency（L2879-2884）
  @override
  void setAsCurrency(double aValue) => setAsBCD(aValue);

  // SetVarValue（L2886-2889）
  @override
  void setVarValue(dynamic aValue) => setAsBCD(_toDouble(aValue));

  // SetAsFloat（L2891）/ SetAsLargeInt（L2896）/ SetAsInteger（L2901）
  @override
  void setAsFloat(double aValue) => setAsBCD(aValue);
  @override
  void setAsLargeInt(int aValue) => setAsBCD(aValue.toDouble());
  @override
  void setAsInteger(int aValue) => setAsBCD(aValue.toDouble());

  // SetAsString（L2906-2912）
  @override
  void setAsString(String aValue) {
    if (aValue.isEmpty) {
      clear(); // set to NULL
    } else {
      final b = double.tryParse(aValue);
      if (b == null) {
        databaseErrorFmt(SNotAFloat, [aValue]);
      }
      setAsBCD(b);
    }
  }
}

// ---------------------------------------------------------------------
//  TBlobField (db.pas L891-939, implementation fields.inc L2917-3206)
// ---------------------------------------------------------------------
enum TBlobStreamMode { bmRead, bmWrite, bmReadWrite }

// TBlobType = ftBlob..ftWideMemo (deprecated, still translated as an alias)
typedef TBlobType = TFieldType;

// ftBlobTypes（db.pas L2244-2245）
const Set<TFieldType> ftBlobTypes = {
  TFieldType.ftBlob,
  TFieldType.ftMemo,
  TFieldType.ftGraphic,
  TFieldType.ftFmtMemo,
  TFieldType.ftParadoxOle,
  TFieldType.ftDBaseOle,
  TFieldType.ftTypedBinary,
  TFieldType.ftOraBlob,
  TFieldType.ftOraClob,
  TFieldType.ftWideMemo,
};

class TBlobField extends TField {
  bool modified = false;
  bool transliterate = false;

  // constructor（L2917-2922）
  TBlobField([super.aOwner]) {
    setDataType(TFieldType.ftBlob);
  }

  // GetBlobStream（L2925-2929）
  TStream? getBlobStream(TBlobStreamMode mode) {
    return _dataSet!.createBlobStream(this, mode);
  }

  // BlobType（L2931-2939）
  TBlobType get blobType => dataType;
  set blobType(TBlobType aValue) => setFieldType(aValue);

  // FreeBuffers（L2941-2943）
  @override
  void freeBuffers() {}

  // GetAsBytes（L2945-2962）
  @override
  Uint8List? getAsBytes() {
    final stream = getBlobStream(TBlobStreamMode.bmRead);
    if (stream != null) {
      final len = stream.size;
      final result = List<int>.filled(len, 0);
      if (len > 0) stream.readBuffer(result, len);
      return Uint8List.fromList(result);
    }
    return Uint8List(0);
  }

  // GetAsString（L2964-2971）/ GetAsAnsiString（L2973-3003）/
  // GetAsUnicodeString (L3005-3023): merges into a Dart String; transliterate's
  // byte-level conversion has no equivalent (conventions 1/3)
  @override
  String getAsString() => getAsAnsiString();

  @override
  String getAsAnsiString() {
    final stream = getBlobStream(TBlobStreamMode.bmRead);
    if (stream != null) {
      final len = stream.size;
      if (len > 0) {
        final bytes = List<int>.filled(len, 0);
        stream.readBuffer(bytes, len);
        return String.fromCharCodes(bytes);
      }
    }
    return '';
  }

  @override
  String getAsUnicodeString() => getAsAnsiString();

  // GetAsVariant（L3025-3031）
  @override
  dynamic getAsVariant() {
    if (!isNull) {
      return getAsString();
    }
    return null;
  }

  // GetBlobSize（L3034-3048）
  int getBlobSize() {
    final stream = getBlobStream(TBlobStreamMode.bmRead);
    if (stream != null) {
      return stream.size;
    }
    return 0;
  }

  int get blobSize => getBlobSize();

  // GetIsNull（L3051-3063）
  @override
  bool get isNull {
    if (!modified) {
      return super.isNull;
    }
    final stream = getBlobStream(TBlobStreamMode.bmRead);
    return stream == null || stream.size == 0;
  }

  // GetText (L3065-3068): calls inherited GetAsString (=the GetClassDesc-
  // style '(BLOB)')
  @override
  void getText(TStringRef aText, bool aDisplayText) {
    aText.value = getClassDesc(); // inherited GetAsString
  }

  // SetAsBytes（L3071-3083）
  @override
  void setAsBytes(Uint8List aValue) {
    final stream = getBlobStream(TBlobStreamMode.bmWrite);
    if (stream != null && aValue.isNotEmpty) {
      stream.writeBuffer(aValue, aValue.length);
    }
  }

  // SetAsString（L3086-3093）/ SetAsAnsiString（L3095-3117）/
  // SetAsUnicodeString（L3119-3131）
  @override
  void setAsString(String aValue) => setAsAnsiString(aValue);

  @override
  void setAsAnsiString(String aValue) {
    final stream = getBlobStream(TBlobStreamMode.bmWrite);
    if (stream != null && aValue.isNotEmpty) {
      final bytes = aValue.codeUnits;
      stream.writeBuffer(bytes, bytes.length);
    }
  }

  @override
  void setAsUnicodeString(String aValue) => setAsAnsiString(aValue);

  // SetVarValue（L3134-3137）
  @override
  void setVarValue(dynamic aValue) {
    setAsString("$aValue");
  }

  // Clear (L3140-3144): opens a write stream and immediately closes it = clears the value
  @override
  void clear() {
    getBlobStream(TBlobStreamMode.bmWrite);
  }

  // class function IsBlob（L3147-3151）
  @override
  bool get isBlob => true;

  // LoadFromFile/SaveToFile (L3154-3187): TFileStream depends on the filesystem
  // (dart:io), which Flutter Web has no equivalent for; file I/O is left to the caller, who should
  // use LoadFromStream/SaveToStream instead. This is a platform limitation, not a simplification.

  // LoadFromStream（L3166-3175）
  void loadFromStream(TStream stream) {
    final blob = getBlobStream(TBlobStreamMode.bmWrite);
    blob?.copyFrom(stream, 0);
  }

  // SaveToStream（L3190-3200）
  void saveToStream(TStream stream) {
    final s = getBlobStream(TBlobStreamMode.bmRead);
    if (s != null) {
      stream.copyFrom(s, 0);
    }
  }

  // SetFieldType（L3202-3206）
  @override
  void setFieldType(TFieldType aValue) {
    if (ftBlobTypes.contains(aValue)) {
      setDataType(aValue);
    }
  }
}

// ---- TMemoField (db.pas L941-958, implementation fields.inc L3210-3253) --------------
// The codepage conversion chain merges away under Dart's String (convention 3); the class and type settings are kept
class TMemoField extends TBlobField {
  TSystemCodePage _codePage = 0;

  TMemoField([super.aOwner]) {
    setDataType(TFieldType.ftMemo);
  }

  TSystemCodePage get codePage => _codePage;
}

// ---- TWideMemoField (db.pas L960-977, implementation fields.inc L3257-3304) ----------
class TWideMemoField extends TBlobField {
  TWideMemoField([super.aOwner]) {
    setDataType(TFieldType.ftWideMemo);
  }

  // GetAsVariant（L3293-3299）
  @override
  dynamic getAsVariant() {
    if (!isNull) {
      return getAsUnicodeString();
    }
    return null;
  }
}

// ---- TGraphicField (db.pas L979-984, implementation fields.inc L3308-3313) -----------
class TGraphicField extends TBlobField {
  TGraphicField([super.aOwner]) {
    setDataType(TFieldType.ftGraphic);
  }
}

// ---- TVariantField (db.pas L986-1016, implementation fields.inc L3355-3440) ----------
class TVariantField extends TField {
  TVariantField([super.aOwner]) {
    setDataType(TFieldType.ftVariant);
  }

  // CheckTypeSize（L3361-3364）
  @override
  void checkTypeSize(int aValue) {
    // { empty }
  }

  // GetDefaultWidth（L3366-3369）
  @override
  int getDefaultWidth() => 15;

  @override
  bool getAsBoolean() => getAsVariant() == true;

  @override
  DateTime getAsDateTime() {
    final v = getAsVariant();
    if (v is DateTime) return v;
    return strToDateTime("$v");
  }

  @override
  double getAsFloat() {
    final v = getAsVariant();
    if (v is num) return v.toDouble();
    return double.tryParse("$v") ?? 0;
  }

  @override
  int getAsInteger() {
    final v = getAsVariant();
    if (v is num) return v.toInt();
    return int.tryParse("$v") ?? 0;
  }

  // GetAsString（L3391-3394）：VarToStr（null → ''）
  @override
  String getAsString() {
    final v = getAsVariant();
    return v == null ? '' : "$v";
  }

  @override
  String getAsWideString() => getAsString();

  // GetAsVariant（L3401-3405）
  @override
  dynamic getAsVariant() {
    final buf = TValueBuffer();
    return getData(buf) ? buf.value : null;
  }

  @override
  void setAsBoolean(bool aValue) => setVarValue(aValue);
  @override
  void setAsDateTime(DateTime aValue) => setVarValue(aValue);
  @override
  void setAsFloat(double aValue) => setVarValue(aValue);
  @override
  void setAsInteger(int aValue) => setVarValue(aValue);
  @override
  void setAsString(String aValue) => setVarValue(aValue);
  @override
  void setAsWideString(String aValue) => setVarValue(aValue);

  // SetVarValue（L3437-3440）
  @override
  void setVarValue(dynamic aValue) {
    setData(TValueBuffer(aValue));
  }
}

// ---- TGuidField (db.pas L1018-1030, implementation fields.inc L3317-3351) ------------
// TGUID → normalized to a '{...}' string (convention: a record type is represented by its string form)
class TGuidField extends TStringField {
  static const String nullGuid = '{00000000-0000-0000-0000-000000000000}';

  TGuidField([super.aOwner]) {
    _size = 38;
    setDataType(TFieldType.ftGuid);
  }

  // CheckTypeSize（L3324-3328）
  @override
  void checkTypeSize(int aValue) {
    if (aValue != 38) {
      databaseErrorFmt(SInvalidFieldSize, [aValue]);
    }
  }

  // GetAsGuid（L3330-3341）
  String getAsGuid() {
    final s = getAsString();
    return s.isEmpty ? nullGuid : s;
  }

  // GetDefaultWidth（L3343-3346）
  @override
  int getDefaultWidth() => 38;

  // SetAsGuid（L3348-3351）
  void setAsGuid(String aValue) {
    setAsString(aValue);
  }

  String get asGuid => getAsGuid();
  set asGuid(String v) => setAsGuid(v);
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 6 —— TFieldsEnumerator / TFields
//  Declaration: db.pas L1116-1165; implementation: fields.inc L3444-3656
//  (TIndexDefs / TCheckConstraints follow after)
// ═════════════════════════════════════════════════════════════════════════════

// ---- TFieldsEnumerator（fields.inc L3444-3460）------------------------------
class TFieldsEnumerator {
  final TFields _fields;
  int _position = -1;

  TFieldsEnumerator(this._fields);

  TField get current => _fields[_position];

  bool moveNext() {
    _position++;
    return _position < _fields.count;
  }
}

// ---- TFields (db.pas L1120-1165, implementation fields.inc L3464-3656) ----------------
class TFields {
  TDataSet? _dataSet;
  final List<TField> _fieldList = [];
  TNotifyEvent? onChange;
  TFieldKinds validFieldKinds = {};

  // constructor（L3464-3470）
  TFields(TDataSet? aDataset) {
    _dataSet = aDataset;
    validFieldKinds = {
      TFieldKind.fkData,
      TFieldKind.fkCalculated,
      TFieldKind.fkLookup,
      TFieldKind.fkInternalCalc,
    }; // [fkData..fkInternalcalc]
  }

  TDataSet? get dataSet => _dataSet;

  // ClearFieldDefs（L3481-3489）
  void clearFieldDefs() {
    for (var i = 0; i < count; i++) {
      this[i]._fieldDef = null;
    }
  }

  // Changed（L3491-3499）
  void changed() {
    // Removed FDataSet.Active check, needed for Persistent fields (see
    // bug ID 30954) (original comment kept as-is)
    if (_dataSet != null &&
        !_dataSet!.componentState.contains(TComponentStateItem.csDestroying)) {
      _dataSet!.dataEvent(TDataEvent.deFieldListChange, 0);
    }
    onChange?.call(this);
  }

  // CheckFieldKind（L3501-3506）
  void checkFieldKind(TFieldKind fieldKind, TField field) {
    if (!validFieldKinds.contains(fieldKind)) {
      databaseErrorFmt(SInvalidFieldKind, [field.displayName]);
    }
  }

  // GetCount（L3508-3512）
  int get count => _fieldList.length;

  // GetField / SetField（L3515-3524）→ [] operator
  TField operator [](int index) => _fieldList[index];
  void operator []=(int index, TField value) {
    _fieldList[index].assign(value);
  }

  // SetFieldIndex（L3526-3542）
  void setFieldIndex(TField field, int value) {
    final old = _fieldList.indexOf(field);
    if (old == -1) return;
    // Check value (original comment kept as-is)
    var v = value;
    if (v < 0) v = 0;
    if (v >= count) v = count - 1;
    if (v != old) {
      _fieldList.removeAt(old);
      _fieldList.insert(v, field);
      field.propertyChanged(true);
      changed();
    }
  }

  // Add（L3544-3551）
  void add(TField field) {
    checkFieldName(field.fieldName);
    _fieldList.add(field);
    field._fields = this;
    changed();
  }

  // CheckFieldName（L3553-3558）
  void checkFieldName(String value) {
    if (findField(value) != null) {
      databaseErrorFmt(SDuplicateFieldName, [value], _dataSet);
    }
  }

  // CheckFieldNames（L3560-3575）
  void checkFieldNames(String value) {
    if (value == '') return;
    final pos = TIntRef(0);
    do {
      final n = extractFieldName(value, pos);
      // Will raise an error if no such field... (original comment kept as-is)
      fieldByName(n);
    } while (pos.value < value.length);
  }

  // Clear（L3577-3589）
  void clear() {
    while (_fieldList.isNotEmpty) {
      final aField = _fieldList.last;
      aField._dataSet = null;
      aField.free();
      if (_fieldList.isNotEmpty && identical(_fieldList.last, aField)) {
        _fieldList.removeLast();
      }
    }
    changed();
  }

  // FindField (L3591-3608): matched via UpperCase
  TField? findField(String value) {
    final s = value.toUpperCase();
    for (final f in _fieldList) {
      if (s == f.fieldName.toUpperCase()) {
        return f;
      }
    }
    return null;
  }

  // FieldByName（L3610-3616）
  TField fieldByName(String value) {
    final result = findField(value);
    if (result == null) {
      databaseErrorFmt(SFieldNotFound, [value], _dataSet);
    }
    return result;
  }

  // FieldByNumber（L3618-3628）
  TField? fieldByNumber(int fieldNo) {
    for (final f in _fieldList) {
      if (fieldNo == f.fieldNo) {
        return f;
      }
    }
    return null;
  }

  // GetEnumerator（L3630-3634）
  TFieldsEnumerator getEnumerator() => TFieldsEnumerator(this);

  // GetFieldNames（L3636-3642）
  void getFieldNames(TStrings values) {
    values.clear();
    for (final f in _fieldList) {
      values.add(f.fieldName);
    }
  }

  // IndexOf（L3644-3648）
  int indexOf(TField field) => _fieldList.indexOf(field);

  // Remove（L3650-3656）
  void remove(TField value) {
    _fieldList.remove(value);
    value._fields = null;
    changed();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  db.pas's global constant table (L2148-2245)
// ═════════════════════════════════════════════════════════════════════════════

// Fieldtypenames : Array[TFieldType] of String（db.pas L2148-2190）
// indexed by TFieldType.index (convention 7)
const List<String> fieldTypeNames = [
  'Unknown',
  "String",
  "Smallint",
  "Integer",
  "Word",
  "Boolean",
  "Float",
  "Currency",
  "BCD",
  "Date",
  "Time",
  "DateTime",
  "Bytes",
  "VarBytes",
  "AutoInc",
  "Blob",
  "Memo",
  "Graphic",
  "FmtMemo",
  "ParadoxOle",
  "DBaseOle",
  "TypedBinary",
  "Cursor",
  "FixedChar",
  "WideString",
  "Largeint",
  "ADT",
  "Array",
  "Reference",
  "DataSet",
  "OraBlob",
  "OraClob",
  "Variant",
  "Interface",
  "IDispatch",
  "Guid",
  "TimeStamp",
  "FMTBcd",
  "FixedWideChar",
  "WideMemo",
];

// DefaultFieldClasses : Array[TFieldType] of TFieldClass（db.pas L2194-2236）
// A Nil entry → null
final List<TFieldClass?> defaultFieldClasses = [
  /* ftUnknown */ (o) => TField(o),
  /* ftString */ (o) => TStringField(o),
  /* ftSmallint */ (o) => TSmallintField(o),
  /* ftInteger */ (o) => TLongintField(o),
  /* ftWord */ (o) => TWordField(o),
  /* ftBoolean */ (o) => TBooleanField(o),
  /* ftFloat */ (o) => TFloatField(o),
  /* ftCurrency */ (o) => TCurrencyField(o),
  /* ftBCD */ (o) => TBCDField(o),
  /* ftDate */ (o) => TDateField(o),
  /* ftTime */ (o) => TTimeField(o),
  /* ftDateTime */ (o) => TDateTimeField(o),
  /* ftBytes */ (o) => TBytesField(o),
  /* ftVarBytes */ (o) => TVarBytesField(o),
  /* ftAutoInc */ (o) => TAutoIncField(o),
  /* ftBlob */ (o) => TBlobField(o),
  /* ftMemo */ (o) => TMemoField(o),
  /* ftGraphic */ (o) => TGraphicField(o),
  /* ftFmtMemo */ (o) => TBlobField(o),
  /* ftParadoxOle */ (o) => TBlobField(o),
  /* ftDBaseOle */ (o) => TBlobField(o),
  /* ftTypedBinary */ (o) => TBlobField(o),
  /* ftCursor */ null,
  /* ftFixedChar */ (o) => TStringField(o),
  /* ftWideString */ (o) => TWideStringField(o),
  /* ftLargeint */ (o) => TLargeintField(o),
  /* ftADT */ null,
  /* ftArray */ null,
  /* ftReference */ null,
  /* ftDataSet */ null,
  /* ftOraBlob */ (o) => TBlobField(o),
  /* ftOraClob */ (o) => TMemoField(o),
  /* ftVariant */ (o) => TVariantField(o),
  /* ftInterface */ null,
  /* ftIDispatch */ null,
  /* ftGuid */ (o) => TGuidField(o),
  /* ftTimeStamp */ null,
  /* ftFMTBcd */ (o) => TFMTBCDField(o),
  /* ftFixedWideChar */ (o) => TWideStringField(o),
  /* ftWideMemo */ (o) => TWideMemoField(o),
];

// dsEditModes / dsWriteModes（db.pas L2238-2240）
const Set<TDataSetState> dsEditModes = {
  TDataSetState.dsEdit,
  TDataSetState.dsInsert,
  TDataSetState.dsSetKey,
};

const Set<TDataSetState> dsWriteModes = {
  TDataSetState.dsEdit,
  TDataSetState.dsInsert,
  TDataSetState.dsSetKey,
  TDataSetState.dsCalcFields,
  TDataSetState.dsFilter,
  TDataSetState.dsNewValue,
  TDataSetState.dsInternalCalc,
  TDataSetState.dsRefreshFields,
};

// ---- TIndexOption / TIndexDef (db.pas L1034-1062, implementation L2414-2465) ----------
enum TIndexOption {
  ixPrimary,
  ixUnique,
  ixDescending,
  ixCaseInsensitive,
  ixExpression,
  ixNonMaintained,
}

typedef TIndexOptions = Set<TIndexOption>;

class TIndexDef extends TNamedItem {
  String _caseInsFields = '';
  String _descFields = '';
  String _expression = '';
  String fields = '';
  TIndexOptions options = <TIndexOption>{};
  String source = '';

  // constructor Create(Owner, AName, TheFields, TheOptions)（L2457-2465）
  // The original source sets FName before calling inherited create (a workaround to dodge the name-
  // collision check); under Dart's constructor-ordering constraints, this is handled equivalently: attach to the collection first, then write _name directly.
  TIndexDef(TIndexDefs? super.owner, String aName, String theFields,
      TIndexOptions theOptions) {
    _name = aName;
    fields = theFields;
    options = theOptions;
  }

  // A parameterless path used by the collection factory
  TIndexDef.fromCollection(super.aCollection);

  // Assign（L2421-2438）
  @override
  void assign(TPersistent? source) {
    if (source is TIndexDef) {
      _name = source.name;
      fields = source.fields;
      options = {...source.options};
      _caseInsFields = source.caseInsFields;
      _descFields = source.descFields;
      this.source = source.source;
      _expression = source.expression;
      return;
    }
    super.assign(source);
  }

  // Expression（L2440-2448）
  String get expression => _expression;
  set expression(String aValue) => _expression = aValue;

  // CaseInsFields (L2450-2455): setting a non-empty value automatically adds ixCaseInsensitive
  String get caseInsFields => _caseInsFields;
  set caseInsFields(String aValue) {
    if (_caseInsFields == aValue) return;
    if (aValue != '') options = {...options, TIndexOption.ixCaseInsensitive};
    _caseInsFields = aValue;
  }

  // DescFields (L2414-2419): setting a non-empty value automatically adds ixDescending
  String get descFields => _descFields;
  set descFields(String aValue) {
    if (_descFields == aValue) return;
    if (aValue != '') options = {...options, TIndexOption.ixDescending};
    _descFields = aValue;
  }
}

// ---- TIndexDefs (db.pas L1066-1080, implementation L2470-2558) ------------------------
class TIndexDefs extends TDefCollection {
  // constructor（L2481-2485）
  TIndexDefs(TDataSet? aDataSet)
      : super(aDataSet, aDataSet, (c) => TIndexDef.fromCollection(c));

  TIndexDef operator [](int index) => getItem(index) as TIndexDef;
  void operator []=(int index, TIndexDef value) => setItem(index, value);

  // AddIndexDef（L2488-2492）
  TIndexDef addIndexDef() => add() as TIndexDef;

  // Add(Name, Fields, Options)（L2494-2504）
  void addIndex(String name, String fields, TIndexOptions options) {
    final d = addIndexDef();
    d.name = name;
    d.fields = fields;
    d.options = options;
  }

  // Find (L2506-2511): throws SIndexNotFound if not found
  TIndexDef findIndex(String indexName) {
    final result = super.find(indexName) as TIndexDef?;
    if (result == null) {
      databaseErrorFmt(SIndexNotFound, [indexName], _dataset);
    }
    return result;
  }

  // FindIndexForFields (L2513-2517): the original source is `//!! To be implemented`,
  // translated as an empty shell as-is (returns null)
  TIndexDef? findIndexForFields(String fields) {
    //!! To be implemented (original comment kept as-is)
    return null;
  }

  // GetIndexForFields（L2520-2548）
  TIndexDef? getIndexForFields(String fields, bool caseInsensitive) {
    TIndexDef? last;
    final fieldsLen = fields.length;
    for (var i = 0; i < count; i++) {
      final result = this[i];
      final descOrExpr = result.options.contains(TIndexOption.ixDescending) ||
          result.options.contains(TIndexOption.ixExpression);
      if (!descOrExpr &&
          (!caseInsensitive ||
              result.options.contains(TIndexOption.ixCaseInsensitive)) &&
          fields.toUpperCase() == result.fields.toUpperCase()) {
        return result;
      } else if (fieldsLen <= result.fields.length &&
          fields.toUpperCase() ==
              result.fields.substring(0, fieldsLen).toUpperCase() &&
          (result.fields.length == fieldsLen ||
              result.fields[fieldsLen] == ';')) {
        if (last == null || last.fields.length > result.fields.length) {
          last = result;
        }
      }
    }
    return last;
  }

  // Update（L2550-2558）
  void updateDefs() {
    if (!updated && _dataset != null) {
      _dataset.updateIndexDefs();
      updated = true;
    }
  }
}

// ---- TCheckConstraint / TCheckConstraints (db.pas L1084-1112, implementation
//      L2562-2608) —— the original source is almost entirely `//!! To be implemented` empty shells, translated as-is
class TCheckConstraint extends TCollectionItem {
  String customConstraint = '';
  String errorMessage = '';
  bool fromDictionary = false;
  String importedConstraint = '';

  TCheckConstraint(super.aCollection);

  // Assign（L2562-2566）
  @override
  void assign(TPersistent? source) {
    //!! To be implemented (original comment kept as-is)
  }
}

class TCheckConstraints extends TCollection {
  final TPersistent? _owner;

  // constructor（L2595-2600）
  TCheckConstraints(this._owner) : super((c) => TCheckConstraint(c));

  // GetItem/SetItem/GetOwner/Add (L2572-2608) are all `//!! To be
  // implemented`; the original source's GetItem always returns nil, changed here under Dart's null-safety to
  // conservatively return the actual item instead (caller behavior unchanged: the original source never actually used this collection)
  TCheckConstraint operator [](int index) => getItem(index) as TCheckConstraint;

  @override
  TPersistent? get owner => _owner;

  TCheckConstraint addConstraint() => add() as TCheckConstraint;
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 7 —— TParam / TParams
//  Declaration: db.pas L1167-1339; implementation: dsparams.inc (the whole file)
// ═════════════════════════════════════════════════════════════════════════════

// TBlobData = TBytes（db.pas L1167）
typedef TBlobData = Uint8List;

// TParamBinding = array of integer（db.pas L1169）
typedef TParamBinding = List<int>;

// TParamType / TParamTypes / TParamStyle（db.pas L1171-1174）
enum TParamType { ptUnknown, ptInput, ptOutput, ptInputOutput, ptResult }

typedef TParamTypes = Set<TParamType>;

enum TParamStyle { psInterbase, psPostgreSQL, psSimulated }

// TSQLParseOption / TSQLParseOptions（db.pas L1300-1301）
enum TSQLParseOption { spoCreate, spoEscapeSlash, spoEscapeRepeat, spoUseMacro }

typedef TSQLParseOptions = Set<TSQLParseOption>;

// ---- The Variant type-mapping table (db.pas L2102-2144 FieldTypetoVariantMap) ----------
// Pascal uses varXxx integer constants; Dart only needs the information "what Variant
// target type does this FieldType map to, or is it varError", expressed instead as an enum table (convention 3).
enum _VarKind { vError, vStr, vInt, vBool, vFloat, vCurrency, vDate, vVariant }

const List<_VarKind> _fieldTypeToVariantMap = [
  /* ftUnknown */ _VarKind.vError,
  /* ftString */ _VarKind.vStr,
  /* ftSmallint */ _VarKind.vInt,
  /* ftInteger */ _VarKind.vInt,
  /* ftWord */ _VarKind.vInt, // varSmallint
  /* ftBoolean */ _VarKind.vBool,
  /* ftFloat */ _VarKind.vFloat,
  /* ftCurrency */ _VarKind.vCurrency,
  /* ftBCD */ _VarKind.vCurrency,
  /* ftDate */ _VarKind.vDate,
  /* ftTime */ _VarKind.vDate,
  /* ftDateTime */ _VarKind.vDate,
  /* ftBytes */ _VarKind.vStr,
  /* ftVarBytes */ _VarKind.vStr,
  /* ftAutoInc */ _VarKind.vInt,
  /* ftBlob */ _VarKind.vStr,
  /* ftMemo */ _VarKind.vStr,
  /* ftGraphic */ _VarKind.vStr,
  /* ftFmtMemo */ _VarKind.vStr,
  /* ftParadoxOle */ _VarKind.vStr,
  /* ftDBaseOle */ _VarKind.vStr,
  /* ftTypedBinary */ _VarKind.vStr,
  /* ftCursor */ _VarKind.vError,
  /* ftFixedChar */ _VarKind.vStr,
  /* ftWideString */ _VarKind.vStr,
  /* ftLargeint */ _VarKind.vInt, // varint64
  /* ftADT */ _VarKind.vError,
  /* ftArray */ _VarKind.vError,
  /* ftReference */ _VarKind.vError,
  /* ftDataSet */ _VarKind.vError,
  /* ftOraBlob */ _VarKind.vStr,
  /* ftOraClob */ _VarKind.vStr,
  /* ftVariant */ _VarKind.vVariant,
  /* ftInterface */ _VarKind
      .vError, // varUnknown (a COM interface, no equivalent)
  /* ftIDispatch */ _VarKind
      .vError, // varDispatch (a COM interface, no equivalent)
  /* ftGuid */ _VarKind.vStr,
  /* ftTimeStamp */ _VarKind.vStr,
  /* ftFMTBcd */ _VarKind.vFloat,
  /* ftFixedWideChar */ _VarKind.vStr,
  /* ftWideMemo */ _VarKind.vStr,
];

// ---- Pascal Variant conversion semantics (the implicit conversion in GetAsXxx's Result:=FValue) --------
// A Pascal Variant automatically converts when assigned to a target type, throwing EVariantError if it can't.
// This helper group faithfully matches that semantics (a numeric string converts to a number, a non-numeric one throws).
int _varAsInteger(dynamic v) {
  if (v is int) return v;
  if (v is bool) return v ? 1 : 0;
  if (v is num) return v.round();
  if (v is String) {
    final i = int.tryParse(v);
    if (i != null) return i;
    final f = double.tryParse(v);
    if (f != null) return f.round();
  }
  throw EDatabaseError(SInvalidVariant);
}

double _varAsFloat(dynamic v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is bool) return v ? 1.0 : 0.0;
  if (v is String) {
    final f = double.tryParse(v);
    if (f != null) return f;
  }
  throw EDatabaseError(SInvalidVariant);
}

bool _varAsBoolean(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.toUpperCase();
    if (s == 'TRUE') return true;
    if (s == 'FALSE') return false;
  }
  throw EDatabaseError(SInvalidVariant);
}

DateTime _varAsDateTime(dynamic v) {
  if (v is DateTime) return v;
  if (v is num) {
    // A TDateTime double: a day count from 1899-12-30 (convention 4)
    return pascalZeroDateTime
        .add(Duration(milliseconds: (v * 86400000).round()));
  }
  if (v is String) {
    final d = DateTime.tryParse(v.replaceFirst(" ", "T"));
    if (d != null) return d;
  }
  throw EDatabaseError(SInvalidVariant);
}

String _varAsString(dynamic v) {
  if (v is String) return v;
  if (v is DateTime) return formatDateTime("c", v);
  return '$v';
}

// ---- TTimeStamp (a SysUtils shim; used by TParam.GetData/SetData's
//      ftTime/ftDate/ftDateTime buffer representation) ------------------------------
class TTimeStamp {
  int time; // milliseconds since midnight
  int date; // days since 0001-01-01, plus 1
  TTimeStamp(this.time, this.date);
}

const int dateDelta =
    693594; // the number of days between 0001-01-01 and 1899-12-30

TTimeStamp dateTimeToTimeStamp(DateTime dt) {
  final days = DateTime(dt.year, dt.month, dt.day)
          .difference(DateTime(1899, 12, 30))
          .inDays +
      dateDelta;
  final msecs =
      dt.hour * 3600000 + dt.minute * 60000 + dt.second * 1000 + dt.millisecond;
  return TTimeStamp(msecs, days);
}

DateTime timeStampToDateTime(TTimeStamp ts) {
  final base = DateTime(1899, 12, 30).add(Duration(days: ts.date - dateDelta));
  return base.add(Duration(milliseconds: ts.time));
}

int timeStampToMSecs(TTimeStamp ts) => ts.date * 86400000 + ts.time;

TTimeStamp mSecsToTimeStamp(int msecs) =>
    TTimeStamp(msecs % 86400000, msecs ~/ 86400000);

// ---- SkipQuotesString（dsparams.inc L2-23）----------------------------------
// A Pascal var p: PChar → a TIntRef index (convention 1)
void skipQuotesString(String s, TIntRef p, String quoteChar, bool escapeSlash,
    bool escapeRepeat) {
  p.value++;
  bool notRepeatEscaped;
  do {
    notRepeatEscaped = true;
    while (p.value < s.length && s[p.value] != quoteChar) {
      if (escapeSlash && s[p.value] == '\\' && p.value + 1 < s.length) {
        p.value +=
            2; // make sure we handle escaped quotes and double backslashes (original comment's meaning)
      } else {
        p.value++;
      }
    }
    if (p.value < s.length && s[p.value] == quoteChar) {
      p.value++; // skip final '
      if (p.value < s.length && s[p.value] == quoteChar && escapeRepeat) {
        // Handle escaping by '' (original comment kept as-is)
        notRepeatEscaped = false;
        p.value++;
      }
    }
  } while (!notRepeatEscaped);
}

// ---- SkipComments (dsparams.inc L254-298; publicly exposed via db.pas interface L2264) ----------
bool skipComments(String s, TIntRef p, bool escapeSlash, bool escapeRepeat) {
  var result = false;
  if (p.value >= s.length) return false;
  final c = s[p.value];
  switch (c) {
    case "'":
    case '"':
    case '`':
      result = true;
      // single quote, double quote or backtick delimited string (original comment)
      skipQuotesString(s, p, c, escapeSlash, escapeRepeat);
      break;
    case '-': // possible start of -- comment
      p.value++;
      if (p.value < s.length && s[p.value] == '-') {
        // -- comment
        result = true;
        do {
          p.value++; // skip until at end of line
        } while (
            p.value < s.length && s[p.value] != '\n' && s[p.value] != '\r');
        while (
            p.value < s.length && (s[p.value] == '\n' || s[p.value] == '\r')) {
          p.value++; // newline is part of comment (original comment kept as-is)
        }
      }
      break;
    case '/': // possible start of /* */ comment
      p.value++;
      if (p.value < s.length && s[p.value] == '*') {
        // /* */ comment
        result = true;
        p.value++;
        while (p.value < s.length) {
          if (s[p.value] == '*') {
            // possible end of comment
            p.value++;
            if (p.value < s.length && s[p.value] == '/') break;
          } else {
            p.value++;
          }
        }
        if (p.value < s.length && s[p.value] == '/') {
          p.value++; // skip final /
        }
      }
      break;
  }
  return result;
}

// ---- TParam (db.pas L1178-1283, implementation dsparams.inc L516-1244) ----------------
class TParam extends TCollectionItem {
  String nativeStr = '';
  dynamic _value;
  int precision = 0;
  int numericScale = 0;
  String name = '';
  TFieldType _dataType = TFieldType.ftUnknown;
  bool bound = false;
  TParamType paramType = TParamType.ptUnknown;
  int size = 0;

  // constructor Create(ACollection)（dsparams.inc L911-917）
  TParam(super.aCollection) {
    paramType = TParamType.ptUnknown;
    _dataType = TFieldType.ftUnknown;
    _value = null; // Unassigned
  }

  // constructor Create(AParams, AParamType)（L919-923）
  TParam.withType(TParams super.aParams, TParamType aParamType) {
    paramType = aParamType;
    _dataType = TFieldType.ftUnknown;
    _value = null;
  }

  // GetDataSet（L518-524）
  TDataSet? get dataSet {
    final c = collection;
    if (c is TParams) return c.dataSet;
    return null;
  }

  // IsParamStored（L526-529）
  bool isParamStored() => bound;

  // AssignParam（L531-558）
  void assignParam(TParam? param) {
    if (param == null) {
      clear();
      _dataType = TFieldType.ftUnknown;
      paramType = TParamType.ptUnknown;
      name = '';
      size = 0;
      precision = 0;
      numericScale = 0;
    } else {
      _dataType = param.dataType;
      if (param.isNull) {
        clear();
      } else {
        _value = param._value;
      }
      bound = param.bound;
      name = param.name;
      if (paramType == TParamType.ptUnknown) {
        paramType = param.paramType;
      }
      size = param.size;
      precision = param.precision;
      numericScale = param.numericScale;
    }
  }

  // AssignTo（L560-566）
  @override
  void assignTo(TPersistent dest) {
    if (dest is TField) {
      assignToField(dest);
    } else {
      super.assignTo(dest);
    }
  }

  // GetAsXxx (L568-700): returns the zero value for each type when IsNull, otherwise converts via Variant
  bool get asBoolean => isNull ? false : _varAsBoolean(_value);
  set asBoolean(bool aValue) {
    _dataType = TFieldType.ftBoolean;
    value = aValue;
  }

  Uint8List? get asBytes {
    if (isNull) return null;
    final v = _value;
    if (v is Uint8List) return v;
    if (v is List<int>) return Uint8List.fromList(v);
    if (v is String) return Uint8List.fromList(v.codeUnits); // BytesOf
    // todo: conversion from other variant types to TBytes (original comment kept as-is)
    return null;
  }

  set asBytes(Uint8List? aValue) {
    _dataType = TFieldType.ftVarBytes;
    value = aValue;
  }

  double get asCurrency => isNull ? 0.0 : _varAsFloat(_value);
  set asCurrency(double aValue) {
    _dataType = TFieldType.ftCurrency;
    value = aValue;
  }

  DateTime get asDateTime =>
      isNull ? pascalZeroDateTime : _varAsDateTime(_value);
  set asDateTime(DateTime aValue) {
    _dataType = TFieldType.ftDateTime;
    value = aValue;
  }

  double get asFloat => isNull ? 0.0 : _varAsFloat(_value);
  set asFloat(double aValue) {
    _dataType = TFieldType.ftFloat;
    value = aValue;
  }

  int get asInteger => isNull ? 0 : _varAsInteger(_value);
  set asInteger(int aValue) {
    _dataType = TFieldType.ftInteger;
    value = aValue;
  }

  int get asLargeInt => isNull ? 0 : _varAsInteger(_value);
  set asLargeInt(int aValue) {
    _dataType = TFieldType.ftLargeint;
    value = aValue;
  }

  String get asMemo => isNull ? '' : _varAsString(_value);
  set asMemo(String aValue) {
    _dataType = TFieldType.ftMemo;
    value = aValue;
  }

  // GetAsString (L638-655): for a Bytes type, restores the byte array back into a string
  String get asString {
    if (isNull) return '';
    if ((_dataType == TFieldType.ftBytes ||
            _dataType == TFieldType.ftVarBytes ||
            _dataType == TFieldType.ftBlob) &&
        _value is List) {
      return String.fromCharCodes((_value as List).cast<int>());
    }
    return _varAsString(_value);
  }

  set asString(String aValue) {
    if (_dataType != TFieldType.ftFixedChar) {
      _dataType = TFieldType.ftString;
    }
    value = aValue;
  }

  String get asAnsiString => asString;
  set asAnsiString(String aValue) => asString = aValue;
  String get asUTF8String => asString;
  set asUTF8String(String aValue) => asString = aValue;

  String get asUnicodeString => isNull ? '' : _varAsString(_value);
  set asUnicodeString(String aValue) {
    if (_dataType != TFieldType.ftFixedWideChar) {
      _dataType = TFieldType.ftWideString;
    }
    value = aValue;
  }

  String get asWideString => asUnicodeString;
  set asWideString(String aValue) => asUnicodeString = aValue;

  dynamic get asVariant => isNull ? null : _value;
  // SetAsVariant (L841-870): infers DataType backward from the Variant's runtime type
  set asVariant(dynamic aValue) {
    _value = aValue;
    bound = aValue != null; // not VarIsClear
    if (_dataType == TFieldType.ftUnknown) {
      if (aValue is bool) {
        _dataType = TFieldType.ftBoolean;
      } else if (aValue is int) {
        // varInteger/varInt64 are both Dart int; a value out of 32-bit range maps to
        // varInt64 → ftLargeInt
        _dataType = (aValue >= -2147483648 && aValue <= 2147483647)
            ? TFieldType.ftInteger
            : TFieldType.ftLargeint;
      } else if (aValue is double) {
        _dataType = TFieldType.ftFloat;
      } else if (aValue is DateTime) {
        _dataType = TFieldType.ftDateTime;
      } else if (aValue is String) {
        if (_dataType != TFieldType.ftFixedChar) {
          _dataType = TFieldType.ftString;
        }
      } else if (aValue is Uint8List || aValue is List<int>) {
        _dataType = TFieldType.ftVarBytes;
      } else {
        _dataType = TFieldType.ftUnknown;
      }
    }
  }

  double get asBCD => asCurrency;
  set asBCD(double aValue) {
    _dataType = TFieldType.ftBCD;
    value = aValue;
  }

  Uint8List? get asBlob => asBytes;
  set asBlob(Uint8List? aValue) {
    _dataType = TFieldType.ftBlob;
    value = aValue;
  }

  DateTime get asDate => asDateTime;
  set asDate(DateTime aValue) {
    _dataType = TFieldType.ftDate;
    value = aValue;
  }

  DateTime get asTime => asDateTime;
  set asTime(DateTime aValue) {
    _dataType = TFieldType.ftTime;
    value = aValue;
  }

  int get asSmallInt => asInteger;
  set asSmallInt(int aValue) {
    _dataType = TFieldType.ftSmallint;
    value = aValue;
  }

  int get asWord => asInteger;
  set asWord(int aValue) {
    _dataType = TFieldType.ftWord;
    value = aValue;
  }

  // AsFMTBCD (L694-700, L878-882): TBCD → double (convention 5)
  double get asFMTBCD => isNull ? 0 : _varAsFloat(_value);
  set asFMTBCD(double aValue) {
    _dataType = TFieldType.ftFMTBcd;
    _value = aValue;
  }

  // GetDisplayName（L702-708）
  @override
  String get displayName => name != '' ? name : super.displayName;

  // GetIsNull (L710-713): VarIsNull or VarIsClear → merged into null in Dart
  bool get isNull => _value == null;

  // IsEqual（L715-724）
  bool isEqual(TParam aValue) {
    return name == aValue.name &&
        isNull == aValue.isNull &&
        bound == aValue.bound &&
        dataType == aValue.dataType &&
        paramType == aValue.paramType &&
        _value.runtimeType == aValue._value.runtimeType &&
        _value == aValue._value;
  }

  // SetDataType (L884-904): when changing type, tries to convert the existing value into the new type's
  // Variant representation; Clears if it can't convert; a varError type just Clears directly
  TFieldType get dataType => _dataType;
  set dataType(TFieldType aValue) {
    if (_dataType == aValue) return;
    _dataType = aValue;
    final vk = _fieldTypeToVariantMap[aValue.index];
    if (vk == _VarKind.vError) {
      clear();
    } else if (_value != null) {
      try {
        switch (vk) {
          case _VarKind.vStr:
            _value = _varAsString(_value);
            break;
          case _VarKind.vInt:
            _value = _varAsInteger(_value);
            break;
          case _VarKind.vBool:
            _value = _varAsBoolean(_value);
            break;
          case _VarKind.vFloat:
          case _VarKind.vCurrency:
            _value = _varAsFloat(_value);
            break;
          case _VarKind.vDate:
            _value = _varAsDateTime(_value);
            break;
          case _VarKind.vVariant:
          case _VarKind.vError:
            break;
        }
      } catch (_) {
        clear();
      }
    }
  }

  // SetText（L906-909）
  set text(String aValue) => value = aValue;
  String get text => asString;

  dynamic get value => asVariant;
  set value(dynamic v) => asVariant = v;

  // Assign（L925-935）
  @override
  void assign(TPersistent? source) {
    if (source is TParam) {
      assignParam(source);
    } else if (source is TField) {
      assignField(source);
    } else if (source is TStrings) {
      asMemo = source.text;
    } else {
      super.assign(source);
    }
  }

  // AssignField（L937-950）
  void assignField(TField? field) {
    if (field != null) {
      // Need TField.Value (original comment kept as-is)
      assignFieldValue(field, field.value);
      name = field.fieldName;
    } else {
      clear();
      name = '';
    }
  }

  // AssignToField（L952-987）
  void assignToField(TField? field) {
    if (field == null) return;
    switch (_dataType) {
      case TFieldType.ftUnknown:
        databaseErrorFmt(SUnknownParamFieldType, [name], dataSet);
      case TFieldType.ftSmallint:
        field.asInteger =
            asSmallInt; // Need TField.AsSmallInt (original comment)
        break;
      case TFieldType.ftWord:
        field.asInteger = asWord; // Need TField.AsWord (original comment)
        break;
      case TFieldType.ftInteger:
      case TFieldType.ftAutoInc:
        field.asInteger = asInteger;
        break;
      case TFieldType.ftCurrency:
        field.asCurrency = asCurrency;
        break;
      case TFieldType.ftFloat:
        field.asFloat = asFloat;
        break;
      case TFieldType.ftBoolean:
        field.asBoolean = asBoolean;
        break;
      case TFieldType.ftBlob:
      case TFieldType.ftGraphic:
      case TFieldType.ftFmtMemo:
      case TFieldType.ftParadoxOle:
      case TFieldType.ftDBaseOle:
      case TFieldType.ftTypedBinary:
      case TFieldType.ftOraBlob:
      case TFieldType.ftOraClob:
      case TFieldType.ftString:
      case TFieldType.ftMemo:
      case TFieldType.ftADT:
      case TFieldType.ftFixedChar:
        field.asString = asString;
        break;
      case TFieldType.ftTime:
      case TFieldType.ftDate:
      case TFieldType.ftDateTime:
        field.asDateTime = asDateTime;
        break;
      case TFieldType.ftBytes:
      case TFieldType.ftVarBytes:
        field.asVariant = value;
        break;
      case TFieldType.ftFMTBcd:
        field.asBCD = asFMTBCD;
        break;
      case TFieldType.ftFixedWideChar:
      case TFieldType.ftWideString:
        field.asWideString = asWideString;
        break;
      default:
        if (_dataType != TFieldType.ftCursor &&
            _dataType != TFieldType.ftArray &&
            _dataType != TFieldType.ftDataSet &&
            _dataType != TFieldType.ftReference) {
          databaseErrorFmt(SBadParamFieldType, [name], dataSet);
        }
    }
  }

  // AssignFromField（L989-1028）
  void assignFromField(TField? field) {
    if (field == null) return;
    _dataType = field.dataType;
    switch (field.dataType) {
      case TFieldType.ftUnknown:
        databaseErrorFmt(SUnknownParamFieldType, [name], dataSet);
      case TFieldType.ftSmallint:
        asSmallInt = field.asInteger;
        break;
      case TFieldType.ftWord:
        asWord = field.asInteger;
        break;
      case TFieldType.ftInteger:
      case TFieldType.ftAutoInc:
        asInteger = field.asInteger;
        break;
      case TFieldType.ftBCD:
      case TFieldType.ftCurrency:
        asCurrency = field.asCurrency;
        break;
      case TFieldType.ftFloat:
        asFloat = field.asFloat;
        break;
      case TFieldType.ftBoolean:
        asBoolean = field.asBoolean;
        break;
      case TFieldType.ftBlob:
      case TFieldType.ftGraphic:
      case TFieldType.ftFmtMemo:
      case TFieldType.ftParadoxOle:
      case TFieldType.ftDBaseOle:
      case TFieldType.ftTypedBinary:
      case TFieldType.ftOraBlob:
      case TFieldType.ftOraClob:
      case TFieldType.ftString:
      case TFieldType.ftMemo:
      case TFieldType.ftADT:
      case TFieldType.ftFixedChar:
        asString = field.asString;
        break;
      case TFieldType.ftTime:
      case TFieldType.ftDate:
      case TFieldType.ftDateTime:
        asDateTime = field.asDateTime;
        break;
      case TFieldType.ftBytes:
      case TFieldType.ftVarBytes:
        value = field.asVariant;
        break;
      case TFieldType.ftFMTBcd:
        asFMTBCD = field.asBCD;
        break;
      case TFieldType.ftFixedWideChar:
      case TFieldType.ftWideString:
        asWideString = field.asWideString;
        break;
      default:
        if (_dataType != TFieldType.ftCursor &&
            _dataType != TFieldType.ftArray &&
            _dataType != TFieldType.ftDataSet &&
            _dataType != TFieldType.ftReference) {
          databaseErrorFmt(SBadParamFieldType, [name], dataSet);
        }
    }
  }

  // AssignFieldValue（L1030-1056）
  void assignFieldValue(TField? field, dynamic aValue) {
    if (field == null) return;
    if (field.dataType == TFieldType.ftString &&
        field is TStringField &&
        field.fixedChar) {
      _dataType = TFieldType.ftFixedChar;
    } else if (field.dataType == TFieldType.ftMemo && field.size > 255) {
      _dataType = TFieldType.ftString;
    } else if (field.dataType == TFieldType.ftWideString &&
        field is TWideStringField &&
        field.fixedChar) {
      _dataType = TFieldType.ftFixedWideChar;
    } else if (field.dataType == TFieldType.ftWideMemo && field.size > 255) {
      _dataType = TFieldType.ftWideString;
    } else {
      _dataType = field.dataType;
    }

    if (aValue == null) {
      clear();
    } else {
      value = aValue;
    }

    size = field.dataSize;
    bound = true;
  }

  // Clear（L1058-1061）
  void clear() {
    _value = null; // Unassigned
  }

  // GetData (L1063-1125): Pointer buffer → TValueBuffer (convention 1),
  // placing the value into the buffer representation according to DataType (ftTime/ftDate is a TimeStamp
  // integer, ftDateTime is a millisecond double — this representation layer is faithfully preserved)
  void getData(TValueBuffer buffer) {
    switch (_dataType) {
      case TFieldType.ftUnknown:
        databaseErrorFmt(SUnknownParamFieldType, [name], dataSet);
      case TFieldType.ftSmallint:
        buffer.value = asSmallInt;
        break;
      case TFieldType.ftWord:
        buffer.value = asWord;
        break;
      case TFieldType.ftInteger:
      case TFieldType.ftAutoInc:
        buffer.value = asInteger;
        break;
      case TFieldType.ftCurrency:
        buffer.value = asCurrency;
        break;
      case TFieldType.ftFloat:
        buffer.value = asFloat;
        break;
      case TFieldType.ftBoolean:
        buffer.value = asBoolean;
        break;
      case TFieldType.ftString:
      case TFieldType.ftMemo:
      case TFieldType.ftADT:
      case TFieldType.ftFixedChar:
      case TFieldType.ftWideString:
      case TFieldType.ftWideMemo:
        buffer.value = asString;
        break;
      case TFieldType.ftTime:
        buffer.value = dateTimeToTimeStamp(asTime).time;
        break;
      case TFieldType.ftDate:
        // ??? the original source at L1098 has DateTimeToTimeStamp(AsTime).Date ——
        // using AsTime rather than AsDate (both go through the same GetAsDateTime, behaving identically,
        // but the original source literally writes AsTime), carried over as-is with this note.
        buffer.value = dateTimeToTimeStamp(asTime).date;
        break;
      case TFieldType.ftDateTime:
        buffer.value =
            timeStampToMSecs(dateTimeToTimeStamp(asDateTime)).toDouble();
        break;
      case TFieldType.ftBlob:
      case TFieldType.ftGraphic:
      case TFieldType.ftFmtMemo:
      case TFieldType.ftParadoxOle:
      case TFieldType.ftDBaseOle:
      case TFieldType.ftTypedBinary:
      case TFieldType.ftOraBlob:
      case TFieldType.ftOraClob:
        buffer.value = asString;
        break;
      case TFieldType.ftBytes:
      case TFieldType.ftVarBytes:
        if (_value is List) {
          buffer.value = asBytes;
        }
        break;
      case TFieldType.ftFMTBcd:
        buffer.value = asFMTBCD;
        break;
      default:
        if (_dataType != TFieldType.ftCursor &&
            _dataType != TFieldType.ftArray &&
            _dataType != TFieldType.ftDataSet &&
            _dataType != TFieldType.ftReference) {
          databaseErrorFmt(SBadParamFieldType, [name], dataSet);
        }
    }
  }

  // GetDataSize（L1127-1164）
  int getDataSize() {
    switch (dataType) {
      case TFieldType.ftUnknown:
        databaseErrorFmt(SUnknownParamFieldType, [name], dataSet);
      case TFieldType.ftBoolean:
        return 2; // SizeOf(WordBool)
      case TFieldType.ftInteger:
      case TFieldType.ftAutoInc:
        return 4;
      case TFieldType.ftSmallint:
        return 2;
      case TFieldType.ftWord:
        return 2;
      case TFieldType.ftTime:
      case TFieldType.ftDate:
        return 4;
      case TFieldType.ftDateTime:
      case TFieldType.ftCurrency:
      case TFieldType.ftFloat:
        return 8;
      case TFieldType.ftString:
      case TFieldType.ftFixedChar:
      case TFieldType.ftMemo:
      case TFieldType.ftADT:
        return asString.length + 1;
      case TFieldType.ftBytes:
      case TFieldType.ftVarBytes:
        return _value is List ? (_value as List).length : 0;
      case TFieldType.ftBlob:
      case TFieldType.ftGraphic:
      case TFieldType.ftFmtMemo:
      case TFieldType.ftParadoxOle:
      case TFieldType.ftDBaseOle:
      case TFieldType.ftTypedBinary:
      case TFieldType.ftOraClob:
      case TFieldType.ftOraBlob:
        return asString.length;
      case TFieldType.ftArray:
      case TFieldType.ftDataSet:
      case TFieldType.ftReference:
      case TFieldType.ftCursor:
        return 0;
      case TFieldType.ftFMTBcd:
        return 8; // SizeOf(TBCD)→double (convention 5)
      default:
        databaseErrorFmt(SBadParamFieldType, [name], dataSet);
    }
  }

  // LoadFromFile (L1166-1178): TFileStream depends on the filesystem (convention:
  // no equivalent on Flutter Web); file I/O is left to the caller, using LoadFromStream instead.

  // LoadFromStream（L1180-1194）
  void loadFromStream(TStream stream, TBlobType blobType) {
    _dataType = blobType;
    stream.position = 0;
    final temp = List<int>.filled(stream.size, 0);
    stream.readBuffer(temp, stream.size);
    value = String.fromCharCodes(temp);
  }

  // SetBlobData（L1196-1205）
  void setBlobData(List<int> buffer, int aSize) {
    asBlob = Uint8List.fromList(buffer.sublist(0, aSize));
  }

  // SetData（L1207-1244）
  void setData(TValueBuffer buffer) {
    DateTime fromTimeStamp(int t, int d) =>
        timeStampToDateTime(TTimeStamp(t, d));

    switch (_dataType) {
      case TFieldType.ftUnknown:
        databaseErrorFmt(SUnknownParamFieldType, [name], dataSet);
      case TFieldType.ftSmallint:
        asSmallInt = _varAsInteger(buffer.value);
        break;
      case TFieldType.ftWord:
        asWord = _varAsInteger(buffer.value);
        break;
      case TFieldType.ftInteger:
      case TFieldType.ftAutoInc:
        asInteger = _varAsInteger(buffer.value);
        break;
      case TFieldType.ftCurrency:
        asCurrency = _varAsFloat(buffer.value);
        break;
      case TFieldType.ftFloat:
        asFloat = _varAsFloat(buffer.value);
        break;
      case TFieldType.ftBoolean:
        asBoolean = _varAsBoolean(buffer.value);
        break;
      case TFieldType.ftString:
      case TFieldType.ftFixedChar:
        asString = _varAsString(buffer.value);
        break;
      case TFieldType.ftMemo:
        asMemo = _varAsString(buffer.value);
        break;
      case TFieldType.ftTime:
        asTime = fromTimeStamp(_varAsInteger(buffer.value), dateDelta);
        break;
      case TFieldType.ftDate:
        asDate = fromTimeStamp(0, _varAsInteger(buffer.value));
        break;
      case TFieldType.ftDateTime:
        asDateTime = timeStampToDateTime(
            mSecsToTimeStamp(_varAsFloat(buffer.value).truncate()));
        break;
      case TFieldType.ftCursor:
        _value = 0;
        break;
      case TFieldType.ftBlob:
      case TFieldType.ftGraphic:
      case TFieldType.ftFmtMemo:
      case TFieldType.ftParadoxOle:
      case TFieldType.ftDBaseOle:
      case TFieldType.ftTypedBinary:
      case TFieldType.ftOraBlob:
      case TFieldType.ftOraClob:
        final s = _varAsString(buffer.value);
        setBlobData(s.codeUnits, s.length);
        break;
      case TFieldType.ftFMTBcd:
        asFMTBCD = _varAsFloat(buffer.value);
        break;
      default:
        databaseErrorFmt(SBadParamFieldType, [name], dataSet);
    }
  }
}

// TParamClass = Class of TParam → a factory typedef (convention 2)
typedef TParamClass = TParam Function(TCollection? aCollection);

// ---- TParamsEnumerator (db.pas L1288-1297, implementation dsparams.inc L27-43) --------
class TParamsEnumerator {
  final TParams _params;
  int _position = -1;

  TParamsEnumerator(this._params);

  TParam get current => _params[_position];

  bool moveNext() {
    _position++;
    return _position < _params.count;
  }
}

// ---- TParams (db.pas L1303-1339, implementation dsparams.inc L47-514, L1247-1270) -----
class TParams extends TCollection {
  final TPersistent? _paramsOwner;

  // class function ParamClass (L103-106) → a virtual factory method (convention 2)
  static TParam _defaultParamFactory(TCollection c) => TParam(c);

  // constructor Create(AOwner, AItemClass)（L108-113）
  TParams.withItemClass(this._paramsOwner, TCollectionItemFactory itemClass)
      : super(itemClass);

  // constructor Create(AOwner)（L116-119）
  TParams([this._paramsOwner]) : super((c) => _defaultParamFactory(c));

  @override
  TPersistent? get owner => _paramsOwner;

  // GetDataSet（L90-96）
  TDataSet? get dataSet => _paramsOwner is TDataSet ? _paramsOwner : null;

  // GetItem / SetItem（L47-60）→ [] operator
  TParam operator [](int index) => getItem(index) as TParam;
  void operator []=(int index, TParam value) => setItem(index, value);

  // ParamValues（L52-65）
  dynamic getParamValue(String paramName) => paramByName(paramName).value;
  void setParamValue(String paramName, dynamic value) {
    paramByName(paramName).value = value;
  }

  // CreateParseOpts（L67-80）
  TSQLParseOptions createParseOpts(
      bool doCreate, bool escapeSlash, bool escapeRepeat) {
    final result = <TSQLParseOption>{};
    if (doCreate) result.add(TSQLParseOption.spoCreate);
    if (escapeSlash) result.add(TSQLParseOption.spoEscapeSlash);
    if (escapeRepeat) result.add(TSQLParseOption.spoEscapeRepeat);
    return result;
  }

  // AssignTo（L82-88）
  @override
  void assignTo(TPersistent dest) {
    if (dest is TParams) {
      dest.assign(this);
    } else {
      super.assignTo(dest);
    }
  }

  // AddParam（L126-129）
  void addParam(TParam value) {
    value.collection = this;
  }

  // AssignValues（L131-145）
  void assignValues(TParams value) {
    for (var i = 0; i < value.count; i++) {
      final ps = value[i];
      final p = findParam(ps.name);
      p?.assign(ps);
    }
  }

  // CreateParam（L147-155）
  TParam createParam(
      TFieldType fldType, String paramName, TParamType paramType) {
    final result = add() as TParam;
    result.name = paramName;
    result.dataType = fldType;
    result.paramType = paramType;
    return result;
  }

  // FindParam (L157-170): CompareText = case-insensitive, searched from the end backward
  TParam? findParam(String value) {
    var i = count - 1;
    while (i >= 0) {
      if (value.toUpperCase() == this[i].name.toUpperCase()) {
        return this[i];
      }
      i--;
    }
    return null;
  }

  // GetParamList（L172-188）
  void getParamList(List<TParam> list, String paramNames) {
    if (paramNames == '') return;
    final pos = TIntRef(0);
    do {
      final n = extractFieldName(paramNames, pos);
      list.add(paramByName(n));
    } while (pos.value < paramNames.length);
  }

  // IsEqual（L190-203）
  bool isEqual(TParams value) {
    var result = value.count == count;
    var i = count - 1;
    while (result && i >= 0) {
      result = this[i].isEqual(value[i]);
      i--;
    }
    return result;
  }

  // GetEnumerator（L205-208）
  TParamsEnumerator getEnumerator() => TParamsEnumerator(this);

  // ParamByName（L210-215）
  TParam paramByName(String value) {
    final result = findParam(value);
    if (result == null) {
      databaseErrorFmt(SParameterNotFound, [value], dataSet);
    }
    return result;
  }

  // The five-overload ParseSQL group (L217-317): merged in Dart into one main entry point + a convenience entry
  // using optional/out parameters (convention: overload → optional parameters)
  String parseSQL(String sql, bool doCreate,
      {bool escapeSlash = true,
      bool escapeRepeat = true,
      TParamStyle parameterStyle = TParamStyle.psInterbase,
      TParamBinding? paramBinding,
      TStringRef? replaceString}) {
    final po = createParseOpts(doCreate, escapeSlash, escapeRepeat);
    return doParseSQL(sql, po, parameterStyle, paramBinding ?? <int>[], " ",
        replaceString ?? TStringRef(""));
  }

  // DoParseSQL (L319-508): fully ported — comment skipping, quoted parameter names,
  // :: cast escaping, ? positional parameters, the three output styles
  // psInterbase/psPostgreSQL/psSimulated, and MacroChar mode. PChar scanning → a TIntRef index.
  String doParseSQL(
      String sql,
      TSQLParseOptions options,
      TParamStyle parameterStyle,
      TParamBinding paramBinding,
      String macroChar,
      TStringRef replaceString) {
    if (options.contains(TSQLParseOption.spoCreate)) clear();

    // Parse the SQL and build ParamBinding (original comment kept as-is)
    final escapeSlash = options.contains(TSQLParseOption.spoEscapeSlash);
    final escapeRepeat = options.contains(TSQLParseOption.spoEscapeRepeat);
    var paramCount = 0;
    final paramPartStart = <int>[];
    final paramPartStop = <int>[];
    paramBinding.clear();
    var questionMarkParamCount = 0; // number of ? params found in query

    replaceString.value = r'$';
    if (parameterStyle == TParamStyle.psSimulated) {
      while (sql.contains(replaceString.value)) {
        replaceString.value = '${replaceString.value}\$';
      }
    }

    final p = TIntRef(0);
    // ParamDelim
    final Set<String> paramDelim = options.contains(TSQLParseOption.spoUseMacro)
        ? {macroChar}
        : {':', "?"};

    // characters that may not appear in a parameter name (SQLDelimiterCharacters + extra symbols)
    const extraDelims = {
      '=',
      "+",
      "-",
      "*",
      "\\",
      "/",
      "[",
      "]",
      "|",
      "<",
      ">"
    };

    while (true) {
      while (skipComments(sql, p, escapeSlash, escapeRepeat)) {}
      if (p.value < sql.length && paramDelim.contains(sql[p.value])) {
        // parameter
        var ignorePart = false;
        int paramNameStart;
        String paramName;
        if (sql[p.value] != '?') {
          // find parameter name
          p.value++;
          if (p.value < sql.length &&
              (sql[p.value] == ':' ||
                  sql[p.value] == '=' ||
                  sql[p.value] == ' ')) {
            // ignore ::, since some databases (postgres) uses this as a
            // cast (wb 4813) (original comment kept as-is)
            ignorePart = true;
            p.value++;
            paramNameStart = p.value;
            paramName = '';
          } else if (p.value < sql.length && sql[p.value] == '"') {
            // Check if the parameter-name is between quotes
            paramNameStart = p.value;
            skipQuotesString(sql, p, '"', escapeSlash, escapeRepeat);
            // Do not include the quotes in ParamName, but they must be
            // included when the parameter is replaced by some
            // place-holder. (original comment kept as-is)
            paramName = sql.substring(paramNameStart + 1, p.value - 1);
          } else {
            paramNameStart = p.value;
            while (p.value < sql.length &&
                !sqlDelimiterCharacters.contains(sql[p.value]) &&
                !extraDelims.contains(sql[p.value])) {
              p.value++;
            }
            paramName = sql.substring(paramNameStart, p.value);
          }
        } else {
          p.value++;
          paramNameStart = p.value;
          paramName = '';
        }

        if (!ignorePart) {
          paramCount++;
          int parameterIndex;
          if (options.contains(TSQLParseOption.spoCreate)) {
            // Check if this is the first occurance of the parameter.
            // If so, create the parameter and assign the Parameterindex
            final tmpParam = findParam(paramName);
            if (tmpParam == null) {
              parameterIndex = createParam(
                      TFieldType.ftUnknown, paramName, TParamType.ptInput)
                  .index;
            } else {
              // else only assign the ParameterIndex
              parameterIndex = tmpParam.index;
            }
          } else {
            // else find ParameterIndex
            if (paramName != '') {
              parameterIndex = paramByName(paramName).index;
            } else {
              parameterIndex = questionMarkParamCount;
              questionMarkParamCount++;
            }
          }

          // store ParameterIndex, ParamPart data
          // ParamPart.Start includes the leading ':' or '?' character (1-based→0-based)
          paramBinding.add(parameterIndex);
          paramPartStart.add(paramNameStart > 0 ? paramNameStart - 1 : 0);
          paramPartStop.add(p.value);
        }
      } else if (p.value >= sql.length) {
        break; // end of SQL
      } else {
        p.value++;
      }
    }

    if (paramCount > 0) {
      // replace :ParamName by ? for interbase and by $x for
      // postgresql/psSimulated (original comment kept as-is)
      final newQuery = StringBuffer();
      var bufIndex = 0;
      for (var i = 0; i < paramPartStart.length; i++) {
        newQuery.write(sql.substring(bufIndex, paramPartStart[i]));
        switch (parameterStyle) {
          case TParamStyle.psInterbase:
            newQuery.write("?");
            break;
          case TParamStyle.psPostgreSQL:
          case TParamStyle.psSimulated:
            newQuery.write(replaceString.value);
            newQuery.write("${paramBinding[i] + 1}");
            break;
        }
        bufIndex = paramPartStop[i];
      }
      if (bufIndex < sql.length) {
        newQuery.write(sql.substring(bufIndex));
      }
      return newQuery.toString();
    }
    return sql;
  }

  // RemoveParam（L511-514）
  void removeParam(TParam value) {
    value.collection = null;
  }

  // CopyParamValuesFromDataset（L1247-1270）
  void copyParamValuesFromDataset(TDataSet? aDataset, bool copyBound) {
    if (aDataset == null) return;
    for (var i = 0; i < count; i++) {
      final p = this[i];
      if (copyBound || !p.bound) {
        // Master dataset must be active and unbound parameters must
        // have fields with same names in master dataset (Delphi
        // compatible behavior) (original comment kept as-is)
        final f = aDataset.fieldByName(p.name);
        p.assignField(f);
        if (!copyBound) p.bound = false;
      }
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 8 —— TDataSet and supporting types
//  Declaration: db.pas L1343-1781; implementation: dataset.inc (the whole 2,528-line file)
// ═════════════════════════════════════════════════════════════════════════════

// TBookmark = TBytes (db.pas L1346, taking FPC's mainline, not the noautomatedbookmark branch)
typedef TBookmark = Uint8List;
// TBookmarkStr = ansistring（db.pas L1348）
typedef TBookmarkStr = String;

// TBookmarkFlag（db.pas L1351）
enum TBookmarkFlag { bfCurrent, bfBOF, bfEOF, bfInserted }

// ---- TRecordBuffer（db.pas L1360-1364）--------------------------------------
// ??? The original source's TRecordBuffer = PAnsiChar (a raw memory block, whose layout is defined by each TDataSet
// subclass itself: a field-data region + a calc-field region + an attached bookmark region).
// A concretization of convention 1: changed to an object, naming the three regions subclasses conventionally use:
//   fieldData    field values (the storage region for a subclass's GetFieldData/SetFieldData)
//   calcData     calc/lookup field values (corresponds to the original source's FOffset
//                offset into the CalcFieldsSize region)
//   bookmarkData/bookmarkFlag  attached bookmark data (the storage region for GetBookmarkData/Flag)
// The "buffer window" pointer movement (Shift/Exchange/ReAlloc) is fully preserved, just with the
// thing being moved changed from a pointer to an object reference — same semantics.
class TRecordBuffer {
  final Map<String, dynamic> fieldData = <String, dynamic>{};
  final Map<String, dynamic> calcData = <String, dynamic>{};
  Uint8List? bookmarkData;
  TBookmarkFlag bookmarkFlag = TBookmarkFlag.bfCurrent;
  // freely attached by subclasses (the counterpart to the original source's subclasses defining the whole buffer layout themselves)
  dynamic tag;
}

// TBufferList/TBufferArray（db.pas L1362-1364）→ List<TRecordBuffer?>
typedef TBufferList = List<TRecordBuffer?>;

// TGetMode / TGetResult（db.pas L1366-1368）
enum TGetMode { gmCurrent, gmNext, gmPrior }

enum TGetResult { grOK, grBOF, grEOF, grError }

// TResyncMode（db.pas L1370）
enum TResyncModeItem { rmExact, rmCenter }

typedef TResyncMode = Set<TResyncModeItem>;

// TDataAction / TUpdateAction / TUpdateKind（db.pas L1372-1376）
enum TDataAction { daFail, daAbort, daRetry }

enum TUpdateAction { uaFail, uaAbort, uaSkip, uaRetry, uaApplied }

enum TUpdateKind { ukModify, ukInsert, ukDelete }

// TLocateOption(s)（db.pas L1379-1380）
enum TLocateOption { loCaseInsensitive, loPartialKey }

typedef TLocateOptions = Set<TLocateOption>;

// TDataOperation / events (db.pas L1382-1392)
typedef TDataOperation = void Function();
typedef TDataSetNotifyEvent = void Function(TDataSet dataSet);

// A var DataAction parameter → wrapped as TDataActionRef (the same convention as TIntRef)
class TDataActionRef {
  TDataAction value;
  TDataActionRef(this.value);
}

typedef TDataSetErrorEvent = void Function(
    TDataSet dataSet, EDatabaseError e, TDataActionRef dataAction);

// TFilterOption(s) / TFilterRecordEvent（db.pas L1388-1392）
enum TFilterOption { foCaseInsensitive, foNoPartialCompare }

typedef TFilterOptions = Set<TFilterOption>;

class TBoolRef {
  bool value;
  TBoolRef(this.value);
}

typedef TFilterRecordEvent = void Function(TDataSet dataSet, TBoolRef accept);

// TPSCommandType（db.pas L1400-1410）
enum TPSCommandType {
  ctUnknown,
  ctQuery,
  ctTable,
  ctStoredProc,
  ctSelect,
  ctInsert,
  ctUpdate,
  ctDelete,
  ctDDL,
}

// The IProviderSupport interface (db.pas L1412-1436): a Pascal interface →
// a Dart abstract class; TDataSet implements it directly as a group of protected virtual methods
// (the original source also puts PS* in TDataSet's protected section), so no separate declaration is needed.

// EAbort (a SysUtils shim; used by TryDoing's daAbort branch)
class EAbort implements Exception {
  final String message = 'Operation aborted';
  @override
  String toString() => message;
}

// ---- DateTimeRecToDateTime / DateTimeToDateTimeRec（dataset.inc
//      L614-654; the global function publicly exposed via db.pas interface L2258-2259) ------------------------

// A TDateTime alias (for clarity, to avoid confusion with Dart's DateTime)
typedef TDateTime4Compat = DateTime;

TDateTime4Compat dateTimeRecToDateTime(TFieldType dt, TDateTimeRec data) {
  var ts = TTimeStamp(0, 0);
  switch (dt) {
    case TFieldType.ftDate:
      ts.date = data.date;
      break;
    case TFieldType.ftTime:
      ts.time = data.time;
      ts.date = dateDelta;
      break;
    default:
      try {
        // MSecsToTimeStamp(trunc(Data.DateTime)): a DateTime field stores milliseconds
        final ms = data.dateTime != null
            ? timeStampToMSecs(dateTimeToTimeStamp(data.dateTime!))
            : 0;
        ts = mSecsToTimeStamp(ms);
      } catch (_) {
        // the original source has an empty except swallowing the exception, translated as-is
      }
  }
  return timeStampToDateTime(ts);
}

TDateTimeRec dateTimeToDateTimeRec(TFieldType dt, DateTime data) {
  final ts = dateTimeToTimeStamp(data);
  final result = TDateTimeRec();
  switch (dt) {
    case TFieldType.ftDate:
      result.date = ts.date;
      break;
    case TFieldType.ftTime:
      result.time = ts.time;
      break;
    default:
      result.dateTime = timeStampToDateTime(mSecsToTimeStamp(timeStampToMSecs(
          ts))); // the object representation of DateTime:=TimeStampToMSecs(TS) —
    // TDateTimeRec.dateTime stores the DateTime directly (convention 1)
  }
  return result;
}

// ---- TDataSet (db.pas L1439-1770, implementation dataset.inc) --------------------------

// Const DefaultBufferCount = 10（dataset.inc L21）
const int defaultBufferCount = 10;

class TDataSet extends TComponent {
  // ---- private fields (db.pas L1441-1495, F-prefix removed, _-prefix used instead) ----------------
  bool _openAfterRead = false;
  int _activeRecord = 0;
  TDataSetNotifyEvent? afterCancel;
  TDataSetNotifyEvent? afterClose;
  TDataSetNotifyEvent? afterDelete;
  TDataSetNotifyEvent? afterEdit;
  TDataSetNotifyEvent? afterInsert;
  TDataSetNotifyEvent? afterOpen;
  TDataSetNotifyEvent? afterPost;
  TDataSetNotifyEvent? afterRefresh;
  TDataSetNotifyEvent? afterScroll;
  bool autoCalcFields = true;
  bool _bof = true;
  TDataSetNotifyEvent? beforeCancel;
  TDataSetNotifyEvent? beforeClose;
  TDataSetNotifyEvent? beforeDelete;
  TDataSetNotifyEvent? beforeEdit;
  TDataSetNotifyEvent? beforeInsert;
  TDataSetNotifyEvent? beforeOpen;
  TDataSetNotifyEvent? beforePost;
  TDataSetNotifyEvent? beforeRefresh;
  TDataSetNotifyEvent? beforeScroll;
  int _blobFieldCount = 0;
  int _blockReadSize = 0;
  int _bookmarkSize = 0;
  final TBufferList _buffers = <TRecordBuffer?>[];
  int _bufferCount = -1;
  TRecordBuffer? _calcBuffer;
  int _calcFieldsSize = 0;
  late TCheckConstraints _constraints;
  int _disableControlsCount = 0;
  TDataSetState _disableControlsState = TDataSetState.dsInactive;
  int _currentRecord = -1;
  final List<TDataSource> _dataSourcesList = [];
  bool _defaultFields = false;
  bool _eof = true;
  TDataEvent _enableControlsEvent = TDataEvent.deLayoutChange;
  late TFields _fieldList;
  late TFieldDefs _fieldDefs;
  TFilterOptions _filterOptions = <TFilterOption>{};
  String _filterText = '';
  bool _filtered = false;
  bool _found = false;
  bool _internalCalcFields = false;
  bool _modified = false;
  TDataSetNotifyEvent? onCalcFields;
  TDataSetErrorEvent? onDeleteError;
  TDataSetErrorEvent? onEditError;
  TFilterRecordEvent? _onFilterRecord;
  TDataSetNotifyEvent? onNewRecord;
  TDataSetErrorEvent? onPostError;
  int _recordCount = 0;
  bool _isUniDirectional = false;
  TDataSetState _state = TDataSetState.dsInactive;
  bool _internalOpenComplete = false;

  // constructor Create（dataset.inc L23-42）
  TDataSet([super.aOwner]) {
    _fieldDefs = fieldDefsClass();
    _fieldList = fieldsClass();
    _constraints = TCheckConstraints(this);

    // FBuffer must be allocated on create, to make Activebuffer return
    // nil (original comment kept as-is)
    _buffers.add(null); // ReAllocMem(FBuffers,SizeOf) + FBuffers[0]:=nil
    _activeRecord = 0;
    _bufferCount = -1;
    _eof = true;
    _bof = true;
    _isUniDirectional = false;
    autoCalcFields = true;
  }

  // destructor Destroy（dataset.inc L46-63）
  @override
  void destroy() {
    active = false;
    // FFieldDefs.Free / FFieldList.Free: handled by the GC
    while (myDataSourceCount > 0) {
      myDataSources(myDataSourceCount - 1).dataSet = null;
    }
    for (var i = 0; i <= _bufferCount && i < _buffers.length; i++) {
      final b = _buffers[i];
      if (b != null) freeRecordBuffer(b);
    }
    super.destroy();
  }

  // ---- class function FieldDefsClass / FieldsClass（dataset.inc
  //      L1066-1074) → a virtual factory method (convention 2)
  TFieldDefs fieldDefsClass() => TFieldDefs(this);
  TFields fieldsClass() => TFields(this);

  // ActivateBuffers（dataset.inc L66-72）
  // This procedure must be called when the first record is made/read
  void activateBuffers() {
    _bof = false;
    _eof = false;
    _activeRecord = 0;
  }

  // UpdateFieldDefs（L74-78）
  void updateFieldDefs() {
    //!! To be implemented (original comment kept as-is)
  }

  // BindFields（L80-131）
  void bindFields(bool binding) {
    // { FieldNo is set to -1 for calculated/lookup fields, to 0 for
    //   unbound field and for bound fields it is set to
    //   FieldDef.FieldNo } (original comment kept as-is)
    _calcFieldsSize = 0;
    _blobFieldCount = 0;
    for (var i = 0; i < fields.count; i++) {
      final field = fields[i];
      field._fieldDef = null;
      if (!binding) {
        field._fieldNo = 0;
      } else if (field.fieldKind == TFieldKind.fkCalculated ||
          field.fieldKind == TFieldKind.fkLookup) {
        field._fieldNo = -1;
        field._offset = _calcFieldsSize;
        _calcFieldsSize += field.dataSize + 1;
      } else {
        final fieldIndex = fieldDefs.indexOfName(field.fieldName);
        if (fieldIndex == -1) {
          databaseErrorFmt(SFieldNotFound, [field.fieldName], this);
        } else {
          final fieldDef = fieldDefs[fieldIndex];
          field._fieldDef = fieldDef;
          field._fieldNo = fieldDef.fieldNo;
          if (fieldDef.internalCalcField) {
            _internalCalcFields = true;
          }
          if (field.isBlob) {
            field._size = fieldDef.size;
            field._offset = _blobFieldCount;
            _blobFieldCount++;
          }
          // synchronize CodePage between TFieldDef and TField (original comment)
          if (field is TStringField) {
            field._codePage = fieldDef.codePage;
          } else if (field is TMemoField) {
            field._codePage = fieldDef.codePage;
          }
        }
      }
      field.bind(binding);
    }
  }

  // BookmarkAvailable（L133-140）
  bool bookmarkAvailable() {
    const bookmarkStates = {
      TDataSetState.dsBrowse,
      TDataSetState.dsEdit,
      TDataSetState.dsInsert
    };
    return !isEmpty &&
        !_isUniDirectional &&
        bookmarkStates.contains(state) &&
        getBookmarkFlag(activeBuffer()!) == TBookmarkFlag.bfCurrent;
  }

  // CalculateFields（L142-163）
  void calculateFields(TRecordBuffer buffer) {
    _calcBuffer = buffer;
    if (_state != TDataSetState.dsInternalCalc) {
      final oldState = _state;
      _state = TDataSetState.dsCalcFields;
      try {
        clearCalcFields(_calcBuffer!);
        if (!isUniDirectional) {
          for (var i = 0; i < _fieldList.count; i++) {
            if (_fieldList[i].fieldKind == TFieldKind.fkLookup) {
              _fieldList[i].calcLookupValue();
            }
          }
        }
      } finally {
        doOnCalcFields();
        _state = oldState;
      }
    }
  }

  // CheckActive / CheckInactive（L165-177）
  void checkActive() {
    if (!active) databaseError(SInactiveDataset);
  }

  void checkInactive() {
    if (active) databaseError(SActiveDataset);
  }

  // ClearBuffers（L179-187）
  void clearBuffers() {
    _recordCount = 0;
    _activeRecord = 0;
    _currentRecord = -1;
    _bof = true;
    _eof = true;
  }

  // ClearCalcFields（L189-193）
  void clearCalcFields(TRecordBuffer buffer) {
    // Empty (original comment kept as-is)
  }

  // CloseBlob（L195-199）
  void closeBlob(TField field) {
    //!! To be implemented (original comment kept as-is)
  }

  // CloseCursor（L201-210）
  void closeCursor() {
    freeFieldBuffers();
    clearBuffers();
    setBufListSize(0);
    fields.clearFieldDefs();
    internalClose();
    _internalOpenComplete = false;
  }

  // CreateFields（L212-232）
  void createFields() {
    for (var i = 0; i < fieldDefs.count; i++) {
      final fd = fieldDefs[i];
      if (fd.dataType != TFieldType.ftUnknown) {
        fd.createField(this);
      }
    }
  }

  // DataEvent (L234-273): Info is a Ptrint (can hold a TField reference or an integer),
  // represented as dynamic in Dart
  void dataEvent(TDataEvent event, dynamic info) {
    void handleFieldChange(TField aField) {
      if (aField.fieldKind == TFieldKind.fkData ||
          aField.fieldKind == TFieldKind.fkInternalCalc) {
        setModified(true);
      }
      if (state != TDataSetState.dsSetKey) {
        if (aField.fieldKind == TFieldKind.fkData) {
          if (_internalCalcFields) {
            refreshInternalCalcFields(activeBuffer()!);
          } else if (autoCalcFields && _calcFieldsSize != 0) {
            calculateFields(activeBuffer()!);
          }
        }
        aField.change();
      }
    }

    void handleScrollOrChange() {
      if (state != TDataSetState.dsInsert) updateCursorPos();
    }

    switch (event) {
      case TDataEvent.deFieldChange:
        handleFieldChange(info as TField);
        break;
      case TDataEvent.deDataSetChange:
      case TDataEvent.deDataSetScroll:
        handleScrollOrChange();
        break;
      case TDataEvent.deLayoutChange:
        _enableControlsEvent = TDataEvent.deLayoutChange;
        break;
      default:
        break;
    }

    if (!controlsDisabled() && _state != TDataSetState.dsBlockRead) {
      if (myDataSourceCount > 0) {
        print('[DEBUG7 dataEvent] name=$name event=$event actually notified $myDataSourceCount DataSource(s)');
      }
      for (var i = 0; i < myDataSourceCount; i++) {
        myDataSources(i).processEvent(event, info);
      }
    } else if (controlsDisabled() && myDataSourceCount > 0) {
      print('[DEBUG7 dataEvent] name=$name event=$event blocked by controlsDisabled (would have been $myDataSourceCount DataSource(s))');
    }
  }

  // DestroyFields（L275-279）
  void destroyFields() {
    _fieldList.clear();
  }

  // The DoAfterXxx / DoBeforeXxx event-firing group (L281-436)
  void doAfterCancel() => afterCancel?.call(this);
  void doAfterClose() {
    if (afterClose != null &&
        !componentState.contains(TComponentStateItem.csDestroying)) {
      afterClose!(this);
    }
  }

  void doAfterDelete() => afterDelete?.call(this);
  void doAfterEdit() => afterEdit?.call(this);
  void doAfterInsert() => afterInsert?.call(this);
  void doAfterOpen() => afterOpen?.call(this);
  void doAfterPost() => afterPost?.call(this);
  // @@@ 2026-08-10 fix: doAfterScroll() used to fire afterScroll
  // unconditionally, bypassing controlsDisabled() entirely — unlike
  // dataEvent()/processEvent(), which correctly check it before
  // notifying bound TDataSource/TDataLink controls (see line ~6386).
  // WML's <onevent type="afterscroll"> handlers get wired up as exactly
  // this afterScroll callback (e.g. app006's sh.afterScroll reloading
  // the sn detail grid via a Future.microtask + setState() on a
  // sibling card's State). disableControls()/enableControls() around a
  // report's run() is specifically meant to suspend ALL such
  // notifications while it drives a shared (Foreign) dataset's cursor —
  // but this callback ignored that guard, so navigating "sh"/"sn" mid-
  // print still fired the sibling card's afterScroll handler, which
  // deferred a setState() via Future.microtask that could land while
  // the print dialog itself was still building →
  // "setState() or markNeedsBuild() called during build". Now respects
  // controlsDisabled() the same way dataEvent() does.
  void doAfterScroll() {
    if (controlsDisabled()) {
      print('[DEBUG7 doAfterScroll] name=$name blocked by controlsDisabled');
      return;
    }
    if (afterScroll != null) {
      print('[DEBUG7 doAfterScroll] name=$name actually fired the afterScroll callback');
    }
    afterScroll?.call(this);
  }
  void doAfterRefresh() => afterRefresh?.call(this);
  void doBeforeCancel() => beforeCancel?.call(this);
  void doBeforeClose() {
    if (beforeClose != null &&
        !componentState.contains(TComponentStateItem.csDestroying)) {
      beforeClose!(this);
    }
  }

  void doBeforeDelete() => beforeDelete?.call(this);
  void doBeforeEdit() => beforeEdit?.call(this);
  void doBeforeInsert() => beforeInsert?.call(this);
  void doBeforeOpen() => beforeOpen?.call(this);
  void doBeforePost() => beforePost?.call(this);
  void doBeforeScroll() => beforeScroll?.call(this);
  void doBeforeRefresh() => beforeRefresh?.call(this);

  // DoInternalOpen（L407-422）
  void _doInternalOpen() {
    internalOpen();
    _internalOpenComplete = true;
    _recordCount = 0;
    recalcBufListSize();
    _bof = true;
    // @@@ 2026-08-10 fix: was `_eof = _recordCount == 0;` — _recordCount
    // is the base class's windowed-buffer fill count, only ever
    // populated by recalcBufListSize() when some bound TDataLink has set
    // a bufferCount>0 (e.g. a TDBGrid). A dataset used directly with no
    // UI binding at all — most notably WapReport's _ds, which drives a
    // report purely via .first()/.next(), never through a grid/edit
    // control — never gets its buffer filled, so _recordCount stays 0
    // forever and _eof was permanently (and wrongly) true right after
    // opening, even when the query actually returned rows. isEmpty
    // (_bof && _eof) then always reported true, so WapReport's
    // fetchFirst() bailed out immediately and printed nothing at all.
    // recordCount (the public property, correctly overridden per
    // subclass — TCustomBufDataset returns _records.length) reflects the
    // real row count regardless of any buffer/UI binding, so use that.
    _eof = recordCount == 0;
  }

  // DoOnCalcFields / DoOnNewRecord（L424-436）
  void doOnCalcFields() => onCalcFields?.call(this);
  void doOnNewRecord() => onNewRecord?.call(this);

  // FieldByNumber（L438-442）
  TField? fieldByNumber(int fieldNo) => _fieldList.fieldByNumber(fieldNo);

  // FindRecord（L444-448）
  bool findRecord(bool restart, bool goForward) {
    //!! To be implemented (original comment kept as-is)
    return false;
  }

  // FreeFieldBuffers（L450-457）
  void freeFieldBuffers() {
    for (var i = 0; i < _fieldList.count; i++) {
      _fieldList[i].freeBuffers();
    }
  }

  // GetBookmarkStr (L459-468): bookmark bytes → a Latin-1 string representation
  TBookmarkStr getBookmarkStr() {
    if (bookmarkAvailable()) {
      final data = TValueBuffer();
      getBookmarkData(activeBuffer()!, data);
      final bytes = data.value;
      if (bytes is Uint8List) return String.fromCharCodes(bytes);
    }
    return '';
  }

  // GetBuffer（L470-474）
  TRecordBuffer? getBuffer(int index) => _buffers[index];

  // MyDataSourceCount / MyDataSources（L476-484）
  int get myDataSourceCount => _dataSourcesList.length;
  TDataSource myDataSources(int aIndex) => _dataSourcesList[aIndex];

  // GetCalcFields（L486-491）
  void getCalcFields(TRecordBuffer buffer) {
    if (_calcFieldsSize > 0 || _internalCalcFields) {
      calculateFields(buffer);
    }
  }

  // GetCanModify（L493-497）
  bool getCanModify() => !_isUniDirectional;

  // GetChildren (L499-511): TReader/the design-time form-streaming mechanism, not translated (same
  // treatment as TField.ReadState).

  // GetDataSource（L513-516）
  TDataSource? getDataSource() => null;

  // GetRecordSize（L518-521）
  int getRecordSize() => 0;

  // InternalAddRecord / InternalDelete / InternalFirst /
  // InternalGotoBookmark (L523-541): an empty-shell virtual
  void internalAddRecord(dynamic buffer, bool aAppend) {
    // empty stub (original comment kept as-is)
  }

  void internalDelete() {
    // empty stub
  }

  void internalFirst() {
    // empty stub
  }

  void internalGotoBookmark(dynamic aBookmark) {
    // empty stub
  }

  // GetFieldData(Field, Buffer) (L543-547): the base returns False,
  // overridden by concrete subclasses (the bufdataset/sqldb layer)
  bool getFieldDataNative(TField field, TValueBuffer? buffer) {
    return false;
  }

  // DataConvert (L549-582): type conversion between the native (in-buffer representation) and the
  // external representation. ftDate/ftTime/ftDateTime's native representation is
  // TDateTimeRec (this conversion layer is still kept even under convention 1)
  void dataConvert(
      TField aField, TValueBuffer aSource, TValueBuffer aDest, bool aToNative) {
    final dt = aField.dataType;
    if (aToNative) {
      switch (dt) {
        case TFieldType.ftDate:
        case TFieldType.ftTime:
        case TFieldType.ftDateTime:
          aDest.value = dateTimeToDateTimeRec(dt, aSource.value as DateTime);
          break;
        case TFieldType.ftTimeStamp:
          aDest.value = aSource.value;
          break;
        case TFieldType.ftBCD:
        case TFieldType.ftFMTBcd:
          aDest.value =
              aSource.value; // TBCD→double (convention 5), no conversion needed
          break;
        // ftBytes/ftVarBytes: see the mantis 8204 comment, left blank in the original source
        case TFieldType.ftWideString:
          aDest.value = aSource.value;
          break;
        default:
          break;
      }
    } else {
      switch (dt) {
        case TFieldType.ftDate:
        case TFieldType.ftTime:
        case TFieldType.ftDateTime:
          aDest.value =
              dateTimeRecToDateTime(dt, aSource.value as TDateTimeRec);
          break;
        case TFieldType.ftTimeStamp:
          aDest.value = aSource.value;
          break;
        case TFieldType.ftBCD:
        case TFieldType.ftFMTBcd:
          aDest.value = aSource.value;
          break;
        case TFieldType.ftWideString:
          aDest.value = aSource.value;
          break;
        default:
          break;
      }
    }
  }

  // GetFieldData(Field, Buffer, NativeFormat)（L584-612）
  bool getFieldData(TField field, TValueBuffer? buffer,
      [bool nativeFormat = true]) {
    if (nativeFormat) {
      return getFieldDataNative(field, buffer);
    } else {
      final statBuffer = TValueBuffer();
      final result = getFieldDataNative(field, statBuffer);
      if (result && buffer != null) {
        dataConvert(field, statBuffer, buffer, false);
      }
      return result;
    }
  }

  // SetFieldData(Field, Buffer) (L656-660): an empty base implementation
  void setFieldDataNative(TField field, TValueBuffer? buffer) {
    // empty procedure (original comment kept as-is)
  }

  // SetFieldData(Field, Buffer, NativeFormat)（L662-690）
  void setFieldData(TField field, TValueBuffer? buffer,
      [bool nativeFormat = true]) {
    if (nativeFormat) {
      setFieldDataNative(field, buffer);
    } else {
      if (buffer == null) {
        setFieldDataNative(field, null);
      } else {
        final statBuffer = TValueBuffer();
        dataConvert(field, buffer, statBuffer, true);
        setFieldDataNative(field, statBuffer);
      }
    }
  }

  // GetField（L692-696）
  TField getField(int index) => _fieldList[index];

  // GetFieldClass（L698-702）
  TFieldClass? getFieldClass(TFieldType fieldType) =>
      defaultFieldClasses[fieldType.index];

  // GetIsIndexField（L704-708）
  bool getIsIndexField(TField field) => false;

  // GetIndexDefs（L710-743）
  TIndexDefs getIndexDefs(TIndexDefs indexDefs, TIndexOptions indexTypes) {
    indexDefs.updateDefs();
    final result = TIndexDefs(this);
    result.assign(indexDefs);
    var i = 0;
    while (i < result.count) {
      final opts = result[i].options;
      final intersection = indexTypes.intersection(opts);
      if (!(indexTypes.isEmpty && opts.isEmpty) && intersection.isEmpty) {
        result.delete(i);
        i--;
      } else {
        // ExtractStrings([';'],[' '],...): splits on ; and trims whitespace
        final indexFields = result[i]
            .fields
            .split(";")
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        for (final f in indexFields) {
          if (findField(f) == null) {
            result.delete(i);
            i--;
            break;
          }
        }
      }
      i++;
    }
    return result;
  }

  // GetNextRecord (L745-781): advances the buffer window by one record
  bool getNextRecord() {
    if (_recordCount > 0) setCurrentRecord(_recordCount - 1);
    final result = getRecord(_buffers[_bufferCount]!, TGetMode.gmNext, true) ==
        TGetResult.grOK;

    if (result) {
      if (_recordCount == 0) activateBuffers();
      if (_recordCount == _bufferCount) {
        shiftBuffersBackward();
      } else {
        _recordCount++;
        _currentRecord = _recordCount - 1;
        // ExchangeBuffers(FBuffers[FCurrentRecord],FBuffers[FBufferCount])
        final temp = _buffers[_currentRecord];
        _buffers[_currentRecord] = _buffers[_bufferCount];
        _buffers[_bufferCount] = temp;
      }
    } else {
      cursorPosChanged();
    }
    return result;
  }

  // GetNextRecords（L783-795）
  int getNextRecords() {
    var result = 0;
    while (_recordCount < _bufferCount && getNextRecord()) {
      result++;
    }
    return result;
  }

  // GetPriorRecord (L797-819): moves the buffer window back by one record
  bool getPriorRecord() {
    checkBiDirectional();
    if (_recordCount > 0) setCurrentRecord(0);
    final result = getRecord(_buffers[_bufferCount]!, TGetMode.gmPrior, true) ==
        TGetResult.grOK;
    if (result) {
      if (_recordCount == 0) activateBuffers();
      shiftBuffersForward();
      if (_recordCount < _bufferCount) {
        _recordCount++;
      }
    } else {
      cursorPosChanged();
    }
    return result;
  }

  // GetPriorRecords（L821-830）
  int getPriorRecords() {
    var result = 0;
    while (_recordCount < _bufferCount && getPriorRecord()) {
      result++;
    }
    return result;
  }

  // GetRecNo / GetRecordCount (L832-842): the base returns -1, overridden by subclasses
  int getRecNo() => -1;
  int getRecordCountInternal() => -1;

  // InitFieldDefs（L844-857）
  void initFieldDefs() {
    if (isCursorOpen()) {
      internalInitFieldDefs();
    } else {
      try {
        openCursor(true);
      } finally {
        closeCursor();
      }
    }
  }

  // SetBlockReadSize（L859-875）
  int get blockReadSize => _blockReadSize;
  set blockReadSize(int aValue) {
    // the state is changed even when setting the same BlockReadSize
    // (follows Delphi behavior) (original comment kept as-is)
    _blockReadSize = aValue;
    if (aValue > 0) {
      checkActive();
      setState(TDataSetState.dsBlockRead);
    } else {
      // update state only when in dsBlockRead
      if (_state == TDataSetState.dsBlockRead) {
        setState(TDataSetState.dsBrowse);
      }
    }
  }

  // SetFieldDefs（L877-882）
  TFieldDefs get fieldDefs => _fieldDefs;
  set fieldDefs(TFieldDefs aFieldDefs) {
    fields.clearFieldDefs();
    _fieldDefs.assign(aFieldDefs);
  }

  // DoInsertAppendRecord（L884-899）：array of const → List<dynamic>
  void _doInsertAppendRecord(List<dynamic> values, bool doAppend) {
    final valuesSize = values.length;
    if (valuesSize > fieldCount) databaseError(STooManyFields, this);
    if (doAppend) {
      append();
    } else {
      insert();
    }
    for (var i = 0; i < valuesSize; i++) {
      fields[i].assignValue(values[i]);
    }
    post();
  }

  // InitFieldDefsFromFields（L901-925）
  void initFieldDefsFromFields() {
    if (fieldDefs.count == 0) {
      fieldDefs.beginUpdate();
      try {
        for (var i = 0; i < fields.count; i++) {
          final f = fields[i];
          if (f.fieldKind != TFieldKind.fkCalculated &&
              f.fieldKind != TFieldKind.fkLookup) {
            // Do not add fielddefs for calculated/lookup fields.
            f._fieldDef = fieldDefs.fieldDefClass(fieldDefs, f.fieldName,
                f.dataType, f.size, f.required, fieldDefs.count + 1);
            final fd = f._fieldDef!;
            if (f.required) {
              fd.attributes = {...fd.attributes, TFieldAttribute.faRequired};
            }
            if (f.readOnly) {
              fd.attributes = {...fd.attributes, TFieldAttribute.faReadonly};
            }
            if (f.dataType == TFieldType.ftBCD) {
              fd.precision = (f as TBCDField).precision;
            } else if (f.dataType == TFieldType.ftFMTBcd) {
              fd.precision = (f as TFMTBCDField).precision;
            }
          }
        }
      } finally {
        fieldDefs.endUpdate();
      }
    }
  }

  // InitRecord（L927-932）
  void initRecord(TRecordBuffer buffer) {
    internalInitRecord(buffer);
    clearCalcFields(buffer);
  }

  // InternalCancel / InternalEdit / InternalRefresh（L934-950）
  void internalCancel() {
    //!! To be implemented (original comment kept as-is)
  }

  void internalEdit() {
    //!! To be implemented
  }

  void internalRefresh() {
    //!! To be implemented
  }

  // OpenCursor（L952-959）
  void openCursor(bool infoQuery) {
    if (infoQuery) {
      internalInitFieldDefs();
    } else if (state != TDataSetState.dsOpening) {
      _doInternalOpen();
    }
  }

  // OpenCursorComplete（L961-979）
  void openCursorComplete() {
    try {
      if (_state == TDataSetState.dsOpening) _doInternalOpen();
    } finally {
      if (_internalOpenComplete) {
        setState(TDataSetState.dsBrowse);
        doAfterOpen();
        if (!isEmpty) doAfterScroll();
      } else {
        setState(TDataSetState.dsInactive);
        closeCursor();
      }
    }
  }

  // RefreshInternalCalcFields（L981-985）
  void refreshInternalCalcFields(TRecordBuffer buffer) {
    //!! To be implemented (original comment kept as-is)
  }

  // SetTempState / RestoreState（L987-1000）
  TDataSetState setTempState(TDataSetState value) {
    final result = _state;
    _state = value;
    _disableControlsCount++;
    return result;
  }

  void restoreState(TDataSetState value) {
    _state = value;
    _disableControlsCount--;
  }

  // GetActive（L1002-1006）
  bool get active =>
      _state != TDataSetState.dsInactive && _state != TDataSetState.dsOpening;

  // InternalHandleException（L1008-1015）：ApplicationHandleException
  // A global exception hook (taken over by the GUI framework), no equivalent — degrades to print
  void internalHandleException() {
    // ignore: avoid_print
    print("TDataSet.internalHandleException: unhandled exception");
  }

  // InternalInitRecord / InternalLast（L1017-1025）
  void internalInitRecord(TRecordBuffer buffer) {
    // empty stub
  }

  void internalLast() {
    // empty stub
  }

  // InternalPost（L1027-1044）
  void internalPost() {
    void checkRequiredFields() {
      for (var i = 0; i < _fieldList.count; i++) {
        final f = _fieldList[i];
        // Required fields that are NOT autoinc !! Autoinc cannot be
        // set !! (original comment kept as-is)
        if (f.required &&
            !f.readOnly &&
            f.fieldKind == TFieldKind.fkData &&
            f.dataType != TFieldType.ftAutoInc &&
            f.isNull) {
          databaseErrorFmt(SNeedField, [f.displayName], this);
        }
      }
    }

    checkRequiredFields();
  }

  // InternalSetToRecord / SetBookmarkFlag / SetBookmarkData（L1046-1059）
  void internalSetToRecord(TRecordBuffer buffer) {
    // empty stub
  }

  void setBookmarkFlag(TRecordBuffer buffer, TBookmarkFlag value) {
    // empty stub
  }

  void setBookmarkData(TRecordBuffer buffer, dynamic data) {
    // empty stub
  }

  // SetUniDirectional（L1061-1064）
  bool get isUniDirectional => _isUniDirectional;
  void setUniDirectional(bool value) {
    _isUniDirectional = value;
  }

  // SetActive（dataset.inc L1076-1108）
  set active(bool value) {
    if (value && _state == TDataSetState.dsInactive) {
      if (componentState.contains(TComponentStateItem.csLoading)) {
        _openAfterRead = true;
        return;
      } else {
        doBeforeOpen();
        _enableControlsEvent = TDataEvent.deLayoutChange;
        _internalCalcFields = false;
        try {
          _defaultFields = fieldCount == 0;
          openCursor(false);
        } finally {
          if (_state != TDataSetState.dsOpening) openCursorComplete();
        }
      }
      _modified = false;
    } else if (!value && _state != TDataSetState.dsInactive) {
      doBeforeClose();
      setState(TDataSetState.dsInactive);
      closeCursor();
      doAfterClose();
      _modified = false;
    }
  }

  // Loaded (L1110-1122): a hook fired when design-time form loading completes
  void loaded() {
    try {
      if (_openAfterRead) active = true;
    } catch (_) {
      if (componentState.contains(TComponentStateItem.csDesigning)) {
        internalHandleException();
      } else {
        rethrow;
      }
    }
  }

  // RecalcBufListSize (L1125-1180): computes the buffer window size based on the needs of
  // the attached DataLinks
  void recalcBufListSize() {
    if (!isCursorOpen()) return;

    int aBufferCount;
    if (isUniDirectional) {
      aBufferCount = 1;
    } else {
      aBufferCount = defaultBufferCount;
    }

    for (var i = 0; i < myDataSourceCount; i++) {
      final src = myDataSources(i);
      for (var j = 0; j < src.dataLinkCount; j++) {
        final dataLink = src.dataLink(j);
        if (aBufferCount < dataLink.bufferCount) {
          aBufferCount = dataLink.bufferCount;
        }
      }
    }

    if (_bufferCount == aBufferCount) return;

    setBufListSize(aBufferCount);
    getNextRecords();
    if (_recordCount < _bufferCount && !isUniDirectional) {
      _activeRecord = _activeRecord + getPriorRecords();
      cursorPosChanged();
    }
    for (var i = 0; i < myDataSourceCount; i++) {
      final src = myDataSources(i);
      for (var j = 0; j < src.dataLinkCount; j++) {
        src.dataLink(j).calcRange();
      }
    }
  }

  // SetBookmarkStr（L1182-1186）
  void setBookmarkStr(TBookmarkStr value) {
    gotoBookmark(Uint8List.fromList(value.codeUnits));
  }

  // SetBufListSize (L1188-1265): buffer-window allocation/release; the pointer movement is
  // replaced with List operations (convention 1), the flow mapped line by line
  void setBufListSize(int value) {
    var v = value;
    if (v == 0) v = -1;
    if (v == _bufferCount) return;
    if (v > _bufferCount) {
      // ReAllocMem(FBuffers,(Value+1)*SizeOf) + FillChar(#0)
      while (_buffers.length < v + 1) {
        _buffers.add(null);
      }
      _bufferCount++; // Cause FBuffers[FBufferCount] is already allocated
      try {
        for (var i = _bufferCount; i <= v; i++) {
          _buffers[i] = allocRecordBuffer();
        }
      } catch (_) {
        var i = _bufferCount;
        while (i < v + 1) {
          final b = _buffers[i];
          if (b != null) freeRecordBuffer(b);
          _buffers[i] = null;
          i++;
        }
        rethrow;
      }
    } else {
      if (v > -1 && _activeRecord > v - 1) {
        for (var i = 0; i <= _activeRecord - v; i++) {
          shiftBuffersBackward();
        }
        _activeRecord = v - 1;
      }

      for (var i = v + 1; i <= _bufferCount && i < _buffers.length; i++) {
        final b = _buffers[i];
        if (b != null) freeRecordBuffer(b);
      }
      // FBuffer must stay allocated, to make sure that Activebuffer
      // returns nil (original comment kept as-is)
      if (v == -1) {
        _buffers
          ..clear()
          ..add(null);
      } else {
        while (_buffers.length > v + 1) {
          _buffers.removeLast();
        }
      }
    }
    _bufferCount = v;
    if (v == -1) v = 0;
    if (_recordCount > v) _recordCount = v;
  }

  // SetChildOrder (L1267-1275): a design-time streaming-order hook
  void setChildOrder(TComponent component, int order) {
    final field = component as TField;
    if (fields.indexOf(field) >= 0) {
      field.index = order;
    }
  }

  // SetCurrentRecord（L1277-1292）
  void setCurrentRecord(int index) {
    if (_currentRecord != index) {
      if (!_isUniDirectional) {
        switch (getBookmarkFlag(_buffers[index]!)) {
          case TBookmarkFlag.bfCurrent:
            internalSetToRecord(_buffers[index]!);
            break;
          case TBookmarkFlag.bfBOF:
            internalFirst();
            break;
          case TBookmarkFlag.bfEOF:
            internalLast();
            break;
          case TBookmarkFlag.bfInserted:
            break;
        }
      }
      _currentRecord = index;
    }
  }

  // SetDefaultFields（L1294-1297）
  void setDefaultFields(bool value) {
    _defaultFields = value;
  }

  // SetField（L1299-1303）
  void setField(int index, TField value) {
    //!! To be implemented (original comment kept as-is)
  }

  // CheckBiDirectional（L1305-1309）
  void checkBiDirectional() {
    if (_isUniDirectional) databaseError(SUniDirectional);
  }

  // The Filter property group (L1311-1334)
  TFilterOptions get filterOptions => _filterOptions;
  set filterOptions(TFilterOptions value) {
    checkBiDirectional();
    _filterOptions = value;
  }

  String get filter => _filterText;
  set filter(String value) {
    _filterText = value;
  }

  bool get filtered => _filtered;
  set filtered(bool value) {
    if (value) checkBiDirectional();
    _filtered = value;
  }

  bool get found => _found;
  void setFound(bool value) {
    _found = value;
  }

  // SetModified（L1336-1340）
  void setModified(bool value) {
    _modified = value;
  }

  // SetName (L1342-1385): a design-time field-component rename-along hook
  @override
  set name(String value) {
    String checkName(String fieldName) {
      var result = fieldName;
      var i = 0;
      var j = 0;
      // Check if fieldname exists. (original comment kept as-is)
      while (i < fields.count) {
        if (result.toUpperCase() != fields[i].name.toUpperCase()) {
          i++;
        } else {
          j++;
          result = '$fieldName$j';
          i = 0;
        }
      }
      // Check if component with the same name exists.
      if (owner != null) {
        while (owner!.findComponent(result) != null) {
          j++;
          result = '$fieldName$j';
        }
      }
      return result;
    }

    if (name == value) return;
    final oldName = name;
    super.name = value;
    if (componentState.contains(TComponentStateItem.csDesigning)) {
      for (var i = 0; i < fields.count; i++) {
        final oldFieldName = '$oldName${fields[i].fieldName}';
        if (fields[i].name.startsWith(oldFieldName)) {
          fields[i].name = checkName("$value${fields[i].fieldName}");
        }
      }
    }
  }

  // SetOnFilterRecord（L1387-1392）
  TFilterRecordEvent? get onFilterRecord => _onFilterRecord;
  set onFilterRecord(TFilterRecordEvent? value) {
    checkBiDirectional();
    _onFilterRecord = value;
  }

  // SetRecNo（L1394-1398）
  void setRecNo(int value) {
    //!! To be implemented (original comment kept as-is)
  }

  int get recNo => getRecNo();
  set recNo(int value) => setRecNo(value);

  // SetState（L1400-1410）
  void setState(TDataSetState value) {
    if (value != _state) {
      _state = value;
      if (value == TDataSetState.dsBrowse) _modified = false;
      dataEvent(TDataEvent.deUpdateState, 0);
    }
  }

  // TempBuffer（L1412-1416）
  TRecordBuffer? tempBuffer() => _buffers[_recordCount];

  // UpdateIndexDefs（L1418-1422）
  void updateIndexDefs() {
    // Empty Abstract (original comment kept as-is)
  }

  // AllocRecordBuffer (L1424-1427): the base returns nil; concrete subclasses override it to
  // allocate their own buffer layout
  TRecordBuffer? allocRecordBuffer() => null;

  // FreeRecordBuffer（L1429-1432）
  void freeRecordBuffer(TRecordBuffer buffer) {
    // empty stub (handled by Dart's GC)
  }

  // GetBookmarkData / GetBookmarkFlag（L1434-1442）
  void getBookmarkData(TRecordBuffer buffer, TValueBuffer data) {
    // empty stub
  }

  TBookmarkFlag getBookmarkFlag(TRecordBuffer buffer) =>
      TBookmarkFlag.bfCurrent;

  // ControlsDisabled（L1444-1448）
  bool controlsDisabled() => _disableControlsCount > 0;

  // ActiveBuffer（L1450-1457）
  TRecordBuffer? activeBuffer() => _buffers[_activeRecord];

  // Append（L1459-1463）
  void append() {
    _doInsertAppend(true);
  }

  // InternalInsert（L1465-1469）
  void internalInsert() {
    //!! To be implemented (original comment kept as-is)
  }

  // AppendRecord（L1471-1475）
  void appendRecord(List<dynamic> values) {
    _doInsertAppendRecord(values, true);
  }

  // BookmarkValid（L1477-1483）
  // { Should be overridden by descendant objects. } (original comment kept as-is)
  bool bookmarkValid(TBookmark? aBookmark) => false;

  // Cancel（L1485-1512）
  void cancel() {
    if (_state == TDataSetState.dsEdit || _state == TDataSetState.dsInsert) {
      dataEvent(TDataEvent.deCheckBrowseMode, 0);
      doBeforeCancel();
      updateCursorPos();
      internalCancel();
      freeFieldBuffers();
      if (_state == TDataSetState.dsInsert && _recordCount == 1) {
        _eof = true;
        _bof = true;
        _recordCount = 0;
        initRecord(activeBuffer()!);
        setState(TDataSetState.dsBrowse);
        dataEvent(TDataEvent.deDataSetChange, 0);
      } else {
        setState(TDataSetState.dsBrowse);
        setCurrentRecord(_activeRecord);
        resync(<TResyncModeItem>{});
      }
      doAfterCancel();
    }
  }

  // CheckBrowseMode（L1514-1526）
  void checkBrowseMode() {
    checkActive();
    dataEvent(TDataEvent.deCheckBrowseMode, 0);
    switch (state) {
      case TDataSetState.dsEdit:
      case TDataSetState.dsInsert:
        updateRecord();
        if (modified) {
          post();
        } else {
          cancel();
        }
        break;
      case TDataSetState.dsSetKey:
        post();
        break;
      default:
        break;
    }
  }

  // ClearFields（L1528-1539）
  void clearFields() {
    if (!dsEditModes.contains(state)) {
      databaseError(SNotEditing, this);
    }
    dataEvent(TDataEvent.deCheckBrowseMode, 0);
    freeFieldBuffers();
    internalInitRecord(activeBuffer()!);
    if (state != TDataSetState.dsSetKey) getCalcFields(activeBuffer()!);
    dataEvent(TDataEvent.deRecordChange, 0);
  }

  // Close（L1541-1545）
  void close() {
    active = false;
  }

  // CompareBookmarks（L1547-1551）
  int compareBookmarks(TBookmark? bookmark1, TBookmark? bookmark2) => 0;

  // CreateBlobStream（L1553-1559）
  TStream? createBlobStream(TField field, TBlobStreamMode mode) => null;

  // CursorPosChanged（L1561-1566）
  void cursorPosChanged() {
    _currentRecord = -1;
  }

  // Delete（L1568-1599）
  void delete() {
    if (!canModify) {
      databaseError(SDatasetReadOnly, this);
    }
    if (isEmpty) {
      databaseError(SDatasetEmpty, this);
    }
    if (_state == TDataSetState.dsInsert) {
      cancel();
    } else {
      dataEvent(TDataEvent.deCheckBrowseMode, 0);
      doBeforeDelete();
      doBeforeScroll();
      if (!tryDoing(internalDelete, onDeleteError)) return;
      freeFieldBuffers();
      setState(TDataSetState.dsBrowse);
      setCurrentRecord(_activeRecord);
      resync(<TResyncModeItem>{});
      doAfterDelete();
      doAfterScroll();
    }
  }

  // DisableControls（L1601-1614）
  void disableControls() {
    if (_disableControlsCount == 0) {
      // { Save current state, needed to detect change of state when
      //   enabling controls. } (original comment kept as-is)
      _disableControlsState = _state;
      _enableControlsEvent = TDataEvent.deDataSetChange;
    }
    _disableControlsCount++;
  }

  // DoInsertAppend (L1616-1721): the main offset logic for insert/append's buffer
  void _doInsertAppend(bool doAppend) {
    void doInsert(bool doAppendInner) {
      // need to scroll up al buffers after current one, but copy
      // current bookmark to insert buffer. (original comment kept as-is)
      TBookmark? bookBeforeInsert;
      if (_recordCount > 0) {
        bookBeforeInsert = getBookmark();
      }

      if (!doAppendInner) {
        if (_recordCount > 0) {
          // move(FBuffers[FActiveRecord],FBuffers[FActiveRecord+1],...)
          final tempBuf = _buffers[_bufferCount];
          for (var i = _bufferCount; i > _activeRecord; i--) {
            _buffers[i] = _buffers[i - 1];
          }
          _buffers[_activeRecord] = tempBuf;
        }
      } else if (_recordCount == _bufferCount) {
        shiftBuffersBackward();
      } else {
        if (_recordCount > 0) {
          _activeRecord++;
        }
      }

      // Active buffer is now edit buffer. Initialize. (original comment kept as-is)
      initRecord(_buffers[_activeRecord]!);
      cursorPosChanged();

      // Put bookmark in edit buffer. (original comment kept as-is)
      if (_recordCount == 0) {
        setBookmarkFlag(activeBuffer()!, TBookmarkFlag.bfEOF);
      } else {
        _bof = false;
        // 29:01:05, JvdS: Why is this here?!? ...
        // 1-apr-06, JvdS: It just sets the bookmark of the newly
        // inserted record to the place where the record should be
        // inserted. So it is ok. (original comment kept as-is)
        if (_recordCount > 0) {
          setBookmarkData(activeBuffer()!, bookBeforeInsert);
          freeBookmark(bookBeforeInsert);
        }
      }

      internalInsert();

      // update buffer count. (original comment kept as-is)
      if (_recordCount < _bufferCount) {
        _recordCount++;
      }
    }

    checkBrowseMode();
    if (!canModify) {
      databaseError(SDatasetReadOnly, this);
    }
    doBeforeInsert();
    doBeforeScroll();
    if (!doAppend) {
      doInsert(false);
    } else {
      clearBuffers();
      internalLast();
      getPriorRecords();
      if (_recordCount > 0) {
        _activeRecord = _recordCount - 1;
      }
      doInsert(true);
      setBookmarkFlag(activeBuffer()!, TBookmarkFlag.bfEOF);
      _bof = false;
      _eof = true;
    }
    setState(TDataSetState.dsInsert);
    try {
      doOnNewRecord();
    } catch (_) {
      setCurrentRecord(_activeRecord);
      resync(<TResyncModeItem>{});
      rethrow;
    }
    // mark as not modified. (original comment kept as-is)
    _modified = false;
    // Final events.
    dataEvent(TDataEvent.deDataSetChange, 0);
    doAfterInsert();
    doAfterScroll();
  }

  // Edit（L1723-1741）
  void edit() {
    if (_state == TDataSetState.dsEdit || _state == TDataSetState.dsInsert) {
      return;
    }
    checkBrowseMode();
    if (!canModify) {
      databaseError(SDatasetReadOnly, this);
    }
    if (_recordCount == 0) {
      append();
      return;
    }
    doBeforeEdit();
    if (!tryDoing(internalEdit, onEditError)) return;
    getCalcFields(activeBuffer()!);
    setState(TDataSetState.dsEdit);
    dataEvent(TDataEvent.deRecordChange, 0);
    doAfterEdit();
  }

  // EnableControls（L1743-1757）
  void enableControls() {
    if (_disableControlsCount > 0) {
      _disableControlsCount--;
    }
    if (_disableControlsCount == 0) {
      if (_state != _disableControlsState) {
        dataEvent(TDataEvent.deUpdateState, 0);
      }
      if (_state != TDataSetState.dsInactive &&
          _disableControlsState != TDataSetState.dsInactive) {
        dataEvent(_enableControlsEvent, 0);
      }
    }
  }

  // FieldByName（L1759-1766）
  TField fieldByName(String fieldName) {
    final result = findField(fieldName);
    if (result == null) {
      databaseErrorFmt(SFieldNotFound, [fieldName], this);
    }
    return result;
  }

  // FindField（L1768-1773）
  TField? findField(String fieldName) => _fieldList.findField(fieldName);

  // FindFirst/FindLast/FindNext/FindPrior (L1775-1801): the base all return False
  bool findFirst() => false;
  bool findLast() => false;
  bool findNext() => false;
  bool findPrior() => false;

  // First（L1803-1824）
  void first() {
    checkBrowseMode();
    doBeforeScroll();
    if (!_isUniDirectional) {
      clearBuffers();
    } else if (!_bof) {
      active = false;
      active = true;
    }
    try {
      internalFirst();
      if (!_isUniDirectional) getNextRecords();
    } finally {
      _bof = true;
      dataEvent(TDataEvent.deDataSetChange, 0);
      doAfterScroll();
    }
  }

  // FreeBookmark (L1826-1833): an automated bookmark (TBytes) is handled by the GC
  void freeBookmark(TBookmark? aBookmark) {}

  // GetBookmark（L1835-1850）
  TBookmark? getBookmark() {
    if (bookmarkAvailable()) {
      final data = TValueBuffer();
      getBookmarkData(activeBuffer()!, data);
      final v = data.value;
      if (v is Uint8List) return v;
      if (v is List<int>) return Uint8List.fromList(v);
      return Uint8List(0);
    }
    return null;
  }

  // GetCurrentRecord（L1852-1857）
  bool getCurrentRecord(TRecordBuffer buffer) => false;

  // GetFieldList（L1859-1875）
  void getFieldList(List<TField> list, String fieldNames) {
    if (fieldNames == '') return;
    final pos = TIntRef(0);
    do {
      final n = extractFieldName(fieldNames, pos);
      list.add(fieldByName(n));
    } while (pos.value < fieldNames.length);
  }

  // GetFieldNames（L1877-1882）
  void getFieldNames(TStrings list) {
    _fieldList.getFieldNames(list);
  }

  // GotoBookmark（L1884-1896）
  void gotoBookmark(TBookmark? aBookmark) {
    if (aBookmark != null) {
      checkBrowseMode();
      doBeforeScroll();
      internalGotoBookmark(aBookmark);
      resync({TResyncModeItem.rmExact, TResyncModeItem.rmCenter});
      doAfterScroll();
    }
  }

  // Insert（L1898-1902）
  void insert() {
    _doInsertAppend(false);
  }

  // InsertRecord（L1904-1908）
  void insertRecord(List<dynamic> values) {
    _doInsertAppendRecord(values, false);
  }

  // IsEmpty（L1910-1915）
  bool get isEmpty => (_bof && _eof) && state != TDataSetState.dsInsert;
  // After an insert on an empty dataset, both fBof and fEof are true
  // (original comment kept as-is)

  // IsLinkedTo（L1917-1929）
  bool isLinkedTo(TDataSource? aDataSource) {
    //!! Not tested, I never used nested DS (original comment kept as-is)
    if (aDataSource == null || aDataSource.dataSet == null) {
      return false;
    } else if (identical(aDataSource.dataSet, this)) {
      return true;
    } else {
      return aDataSource.dataSet!.isLinkedTo(aDataSource.dataSet!.dataSource);
    }
    //!! DataSetField not implemented (original comment kept as-is)
  }

  TDataSource? get dataSource => getDataSource();

  // IsSequenced（L1931-1935）
  bool isSequenced() => true;

  // Last（L1937-1954）
  void last() {
    checkBiDirectional();
    checkBrowseMode();
    doBeforeScroll();
    clearBuffers();
    try {
      internalLast();
      getPriorRecords();
      if (_recordCount > 0) {
        _activeRecord = _recordCount - 1;
      }
    } finally {
      _eof = true;
      dataEvent(TDataEvent.deDataSetChange, 0);
      doAfterScroll();
    }
  }

  // MoveBy（L1956-2056）
  int moveBy(int distance) {
    var theResult = 0;
    var dist = distance;

    int scrollForward() {
      var result = 0;
      _bof = false;
      while (dist > 0 && !_eof) {
        if (_activeRecord < _recordCount - 1) {
          _activeRecord++;
          dist--;
          theResult++;
        } else {
          if (getNextRecord()) {
            dist--;
            result--;
            theResult++;
          } else {
            _eof = true;
          }
        }
      }
      return result;
    }

    int scrollBackward() {
      checkBiDirectional();
      var result = 0;
      _eof = false;
      while (dist < 0 && !_bof) {
        if (_activeRecord > 0) {
          _activeRecord--;
          dist++;
          theResult--;
        } else {
          if (getPriorRecord()) {
            dist++;
            result++;
            theResult--;
          } else {
            _bof = true;
          }
        }
      }
      return result;
    }

    checkBrowseMode();
    doBeforeScroll();
    if (dist == 0 || (dist > 0 && _eof) || (dist < 0 && _bof)) {
      return 0;
    }
    var scrolled = 0;
    try {
      if (dist > 0) {
        scrolled = scrollForward();
      } else {
        scrolled = scrollBackward();
      }
    } finally {
      dataEvent(TDataEvent.deDataSetScroll, scrolled);
      doAfterScroll();
    }
    return theResult;
  }

  // Next（L2058-2065）
  void next() {
    if (blockReadSize > 0) {
      blockReadNext();
    } else {
      moveBy(1);
    }
  }

  // BlockReadNext（L2067-2070）
  void blockReadNext() {
    moveBy(1);
  }

  // Open（L2072-2076）
  void open() {
    active = true;
  }

  // Post（L2078-2106）
  void post() {
    updateRecord();
    if (_state == TDataSetState.dsEdit || _state == TDataSetState.dsInsert) {
      dataEvent(TDataEvent.deCheckBrowseMode, 0);
      doBeforePost();
      if (!tryDoing(internalPost, onPostError)) return;
      cursorPosChanged();
      freeFieldBuffers();
      // First set the state to dsBrowse, then the Resync, to prevent
      // the calling of the deDatasetChange event, while the state is
      // still 'editable', while the db isn't (original comment kept as-is)
      setState(TDataSetState.dsBrowse);
      resync(<TResyncModeItem>{});
      doAfterPost();
    } else if (_state != TDataSetState.dsSetKey) {
      databaseErrorFmt(SNotEditing, [name], this);
    }
  }

  // Prior（L2108-2112）
  void prior() {
    moveBy(-1);
  }

  // Refresh（L2114-2126）
  void refresh() {
    checkBrowseMode();
    doBeforeRefresh();
    updateCursorPos();
    internalRefresh();
    // { SetCurrentRecord is called by UpdateCursorPos already, ... }
    resync(<TResyncModeItem>{});
    doAfterRefresh();
  }

  // RegisterDataSource（L2128-2133）
  void registerDataSource(TDataSource aDataSource) {
    _dataSourcesList.add(aDataSource);
    recalcBufListSize();
  }

  // Resync (L2136-2189): re-syncs the buffer window with the underlying cursor
  void resync(TResyncMode mode) {
    if (_isUniDirectional) return;

    // Now look if the data on the current cursor of the underlying
    // dataset is still available (original comment kept as-is)
    if (getRecord(_buffers[0]!, TGetMode.gmCurrent, false) != TGetResult.grOK) {
      // If that fails and rmExact is set, then raise an exception
      if (mode.contains(TResyncModeItem.rmExact)) {
        databaseError(SNoSuchRecord, this);
      }
      // else, try to fetch the next or prior record in the underlying
      // dataset
      else if (getRecord(_buffers[0]!, TGetMode.gmNext, true) !=
              TGetResult.grOK &&
          getRecord(_buffers[0]!, TGetMode.gmPrior, true) != TGetResult.grOK) {
        // nothing found, invalidate buffer and bail out. (original comment kept as-is)
        clearBuffers();
        dataEvent(TDataEvent.deDataSetChange, 0);
        return;
      }
    }
    _currentRecord = 0;
    _eof = false;
    _bof = false;

    // If we've arrived here, FBuffer[0] is the current record (original comment)
    int count;
    if (mode.contains(TResyncModeItem.rmCenter)) {
      count = _recordCount ~/ 2;
    } else {
      count = _activeRecord;
    }
    var i = 0;
    _recordCount = 1;
    _activeRecord = 0;

    // Fill the buffers before the active record (original comment kept as-is)
    while (i < count && getPriorRecord()) {
      i++;
    }
    _activeRecord = i;
    // Fill the rest of the buffer
    getNextRecords();
    // If the buffer is not full yet, try to fetch some more prior
    // records
    if (_recordCount < _bufferCount) {
      _activeRecord += getPriorRecords();
    }
    // That's all folks! (original comment kept as-is)
    dataEvent(TDataEvent.deDataSetChange, 0);
  }

  // SetFields（L2191-2197）
  void setFields(List<dynamic> values) {
    for (var i = 0; i < values.length; i++) {
      fields[i].assignValue(values[i]);
    }
  }

  // Translate (L2199-2204): OEM character conversion has no Dart-String equivalent,
  // the base semantics of "copy and return the length" are kept
  int translate(String src, TStringRef dest, bool toOem) {
    dest.value = src;
    return dest.value.length;
  }

  // TryDoing（L2206-2245）
  bool tryDoing(TDataOperation p, TDataSetErrorEvent? ev) {
    var retry = TDataAction.daRetry;
    while (retry == TDataAction.daRetry) {
      try {
        updateCursorPos();
        p();
        return true;
      } on EDatabaseError catch (e) {
        retry = TDataAction.daFail;
        if (ev != null) {
          final ref = TDataActionRef(retry);
          ev(this, e, ref);
          retry = ref.value;
        }
        switch (retry) {
          case TDataAction.daFail:
            rethrow;
          case TDataAction.daAbort:
            throw EAbort();
          case TDataAction.daRetry:
            break;
        }
      }
    }
    return true;
  }

  // UpdateCursorPos（L2247-2252）
  void updateCursorPos() {
    if (_recordCount > 0) {
      setCurrentRecord(_activeRecord);
    }
  }

  // UpdateRecord（L2254-2260）
  void updateRecord() {
    if (!dsEditModes.contains(state)) {
      databaseErrorFmt(SNotEditing, [name], this);
    }
    dataEvent(TDataEvent.deUpdateRecord, 0);
  }

  // UpdateStatus（L2262-2266）
  TUpdateStatus updateStatus() => TUpdateStatus.usUnmodified;

  // RemoveField（L2268-2272）
  void removeField(TField field) {
    //!! To be implemented (original comment kept as-is)
  }

  // SetConstraints（L2274-2277）
  TCheckConstraints get constraints => _constraints;
  set constraints(TCheckConstraints value) {
    _constraints.assign(value);
  }

  // GetFieldCount（L2279-2283）
  int get fieldCount => _fieldList.count;

  // ShiftBuffersBackward (L2285-2293): shifts the whole buffer row forward by one slot,
  // the head buffer rotates around to the tail
  void shiftBuffersBackward() {
    final tempBuf = _buffers[0];
    for (var i = 0; i < _bufferCount; i++) {
      _buffers[i] = _buffers[i + 1];
    }
    _buffers[_bufferCount] = tempBuf;
  }

  // ShiftBuffersForward (L2295-2303): shifts the whole buffer row backward by one slot,
  // the tail buffer rotates around to the head
  void shiftBuffersForward() {
    final tempBuf = _buffers[_bufferCount];
    for (var i = _bufferCount; i > 0; i--) {
      _buffers[i] = _buffers[i - 1];
    }
    _buffers[0] = tempBuf;
  }

  // GetFieldValues (L2305-2322): multiple fields (;-separated) return a List
  dynamic fieldValues(String fieldName) {
    final fieldList = <TField>[];
    getFieldList(fieldList, fieldName);
    if (fieldList.length > 1) {
      return [for (final f in fieldList) f.value];
    }
    return fieldByName(fieldName).value;
  }

  // SetFieldValues（L2324-2347）
  void setFieldValues(String fieldName, dynamic value) {
    if (value is List) {
      final fieldList = <TField>[];
      getFieldList(fieldList, fieldName);
      if (fieldList.length == 1 && value.length > 1) {
        // Allow for a field type that can deal with an array (original comment)
        fieldByName(fieldName).value = value;
      } else {
        for (var i = 0; i < fieldList.length; i++) {
          fieldList[i].value = value[i];
        }
      }
    } else {
      fieldByName(fieldName).value = value;
    }
  }

  // Locate (L2349-2355): the base returns False, overridden by concrete subclasses
  bool locate(String keyFields, dynamic keyValues, TLocateOptions options) {
    checkBiDirectional();
    return false;
  }

  // Lookup (L2357-2363): the base returns Null
  dynamic lookup(String keyFields, dynamic keyValues, String resultFields) {
    checkBiDirectional();
    return null;
  }

  // UnRegisterDataSource（L2366-2370）
  void unRegisterDataSource(TDataSource aDataSource) {
    _dataSourcesList.remove(aDataSource);
  }

  // ---- The IProviderSupport method group (L2375-2497) --------------------------------
  void psEndTransaction(bool commit) {
    databaseError("Provider support not available", this);
  }

  void psExecute() {
    databaseError("Provider support not available", this);
  }

  int psExecuteStatement(String aSQL, TParams aParams, [dynamic resultSet]) {
    databaseError("Provider support not available", this);
  }

  void psGetAttributes(List<dynamic> list) {
    databaseError("Provider support not available", this);
  }

  String psGetCommandText() {
    databaseError("Provider support not available", this);
  }

  TPSCommandType psGetCommandType() {
    databaseError("Provider support not available", this);
  }

  TIndexDef? psGetDefaultOrder() {
    return null;
    //DatabaseError('Provider support not available', Self); (original comment kept as-is)
  }

  TIndexDefs? psGetIndexDefs(TIndexOptions indexTypes) {
    databaseError("Provider support not available", this);
  }

  String psGetKeyFields() {
    databaseError("Provider support not available", this);
  }

  TParams? psGetParams() {
    databaseError("Provider support not available", this);
  }

  String psGetQuoteChar() {
    databaseError("Provider support not available", this);
  }

  String psGetTableName() {
    databaseError("Provider support not available", this);
  }

  EUpdateError psGetUpdateException(Object e, EUpdateError? prev) {
    if (prev != null) {
      return EUpdateError("$e", "", 0, prev.errorCode, e);
    }
    return EUpdateError("$e", "", 0, 0, e);
  }

  bool psInTransaction() {
    databaseError("Provider support not available", this);
  }

  bool psIsSQLBased() {
    databaseError("Provider support not available", this);
  }

  bool psIsSQLSupported() {
    databaseError("Provider support not available", this);
  }

  void psReset() {
    //DatabaseError('Provider support not available', Self); (original comment kept as-is)
  }

  void psSetCommandText(String commandText) {
    databaseError("Provider support not available", this);
  }

  void psSetParams(TParams aParams) {
    databaseError("Provider support not available", this);
  }

  void psStartTransaction() {
    databaseError("Provider support not available", this);
  }

  bool psUpdateRecord(TUpdateKind updateKind, TDataSet delta) {
    databaseError("Provider support not available", this);
  }

  // ---- The abstract method group (db.pas L1633-1638) ---------------------------------
  // A concrete Dart class can't have abstract members, so these are throwing virtuals instead (subclasses must
  // override them; semantically equivalent to a virtual/abstract runtime error when unimplemented)
  TGetResult getRecord(TRecordBuffer buffer, TGetMode getMode, bool doCheck) {
    throw EDatabaseError("AbstractError: TDataSet.GetRecord");
  }

  void internalClose() {
    throw EDatabaseError("AbstractError: TDataSet.InternalClose");
  }

  void internalOpen() {
    throw EDatabaseError("AbstractError: TDataSet.InternalOpen");
  }

  void internalInitFieldDefs() {
    throw EDatabaseError("AbstractError: TDataSet.InternalInitFieldDefs");
  }

  bool isCursorOpen() {
    throw EDatabaseError("AbstractError: TDataSet.IsCursorOpen");
  }

  // ---- Public properties (db.pas L1722-1745) --------------------------------------
  bool get bof => _bof;
  TBookmark? get bookmark => getBookmark();
  set bookmark(TBookmark? b) => gotoBookmark(b);
  bool get canModify => getCanModify();
  bool get defaultFields => _defaultFields;
  bool get eof => _eof;
  bool get modified => _modified;
  int get recordCount => getRecordCountInternal();
  int get recordSize => getRecordSize();
  TDataSetState get state => _state;
  TFields get fields => _fieldList;
  int get activeRecordIndex => _activeRecord; // property ActiveRecord
  int get currentRecordIndex => _currentRecord; // property CurrentRecord
  int get blobFieldCount => _blobFieldCount;
  int get bookmarkSize => _bookmarkSize;
  set bookmarkSize(int v) => _bookmarkSize = v;
  TRecordBuffer? get calcBuffer => _calcBuffer;
  int get calcFieldsSize => _calcFieldsSize;
  bool get internalCalcFields => _internalCalcFields;
  int get bufferCount => _bufferCount;
}

// ---- TDataSetEnumerator (db.pas L1772-1781, implementation dataset.inc
//      L2506-2527）+ operator Enumerator（L2501-2504）------------------------
class TDataSetEnumerator {
  final TDataSet _dataSet;
  bool _enumBOF = true;

  // constructor（L2506-2512）
  TDataSetEnumerator(this._dataSet) {
    _enumBOF = true;
    _dataSet.first();
  }

  // GetCurrent（L2514-2517）
  TFields get current => _dataSet.fields;

  // MoveNext（L2519-2527）
  bool moveNext() {
    if (_enumBOF) {
      _enumBOF = false;
    } else {
      _dataSet.next();
    }
    return !_dataSet.eof;
  }
}

// operator Enumerator(ADataSet) (dataset.inc L2501-2504): Pascal's
// for-in operator overload has no Dart syntax equivalent, so a same-named factory function is provided instead
TDataSetEnumerator dataSetEnumerator(TDataSet aDataSet) =>
    TDataSetEnumerator(aDataSet);

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 9 —— TDataLink / TDetailDataLink / TMasterDataLink /
//               TMasterParamsDataLink / TDataSource
//  Declaration: db.pas L1785-1938; implementation: datasource.inc (the whole 720-line file)
// ═════════════════════════════════════════════════════════════════════════════

// TFieldRef = ^TField: the field reference carried by the deFocusControl event. Under convention 1
// the TField itself is passed directly (TField.focusControl already does this).
typedef TFieldRef = TField;

// ---- TDataLink (db.pas L1785-1842, implementation datasource.inc L5-329) --------------
class TDataLink extends TPersistent {
  int _firstRecord = 0;
  int _bufferCount = 1;
  bool _active = false;
  bool dataSourceFixed = false;
  bool _editing = false;
  bool _readOnly = false;
  bool _updatingRecord = false;
  bool visualControl = false;
  TDataSource? _dataSource;

  // constructor Create（datasource.inc L5-13）
  TDataLink() {
    _bufferCount = 1;
    _firstRecord = 0;
    _dataSource = null;
    dataSourceFixed = false;
  }

  // destructor Destroy（L16-24）
  void destroy() {
    _active = false;
    _editing = false;
    dataSourceFixed = false;
    dataSource = null;
  }

  void free() => destroy();

  // ActiveChanged（L27-31）
  void activeChanged() {
    _firstRecord = 0;
  }

  // CheckActiveAndEditing（L33-51）
  void checkActiveAndEditing() {
    var b = _dataSource != null &&
        _dataSource!.state != TDataSetState.dsInactive &&
        _dataSource!.state != TDataSetState.dsOpening;
    if (b != _active) {
      _active = b;
      activeChanged();
    }
    b = _dataSource != null &&
        dsEditModes.contains(_dataSource!.state) &&
        !_readOnly;
    if (b != _editing) {
      _editing = b;
      editingChanged();
    }
  }

  // CheckBrowseMode（L54-57）
  void checkBrowseMode() {}

  // CalcFirstRecord (L60-69): computes "this link's first record"'s relative
  // position within the buffer window —— fully preserved
  int calcFirstRecord(int index) {
    final ds = dataSource!.dataSet!;
    int result;
    if (ds._activeRecord > _firstRecord + index + _bufferCount - 1) {
      result = ds._activeRecord - (_firstRecord + index + _bufferCount - 1);
    } else if (ds._activeRecord < _firstRecord + index) {
      result = ds._activeRecord - (_firstRecord + index);
    } else {
      result = 0;
    }
    _firstRecord += index + result;
    return result;
  }

  // CalcRange (L72-96): clamps the window range —— fully preserved
  void calcRange() {
    // During loading, dataset may not be set yet. (original comment kept as-is)
    final ds = dataSet;
    if (ds == null) {
      _firstRecord = 0;
      return;
    }
    var aMin = ds._activeRecord - _bufferCount + 1;
    if (aMin < 0) aMin = 0;
    var aMax = ds._bufferCount - _bufferCount;
    if (aMax < 0) aMax = 0;

    if (aMax > ds._activeRecord) aMax = ds._activeRecord;

    if (_firstRecord < aMin) _firstRecord = aMin;
    if (_firstRecord > aMax) _firstRecord = aMax;

    if (_firstRecord != 0 &&
        ds._activeRecord - _firstRecord < _bufferCount - 1) {
      _firstRecord -= 1;
    }
  }

  // DataEvent（L99-123）
  void dataEvent(TDataEvent event, dynamic info) {
    switch (event) {
      case TDataEvent.deFieldChange:
      case TDataEvent.deRecordChange:
        if (!_updatingRecord) {
          recordChanged(info is TField ? info : null);
        }
        break;
      case TDataEvent.deDataSetChange:
        _setActive(dataSource!.dataSet!.active);
        calcRange();
        calcFirstRecord(info is int ? info : 0);
        dataSetChanged();
        break;
      case TDataEvent.deDataSetScroll:
        dataSetScrolled(calcFirstRecord(info is int ? info : 0));
        break;
      case TDataEvent.deLayoutChange:
        calcFirstRecord(info is int ? info : 0);
        layoutChanged();
        break;
      case TDataEvent.deUpdateRecord:
        updateRecord();
        break;
      case TDataEvent.deUpdateState:
        checkActiveAndEditing();
        break;
      case TDataEvent.deCheckBrowseMode:
        checkBrowseMode();
        break;
      case TDataEvent.deFocusControl:
        focusControl(info is TField ? info : null);
        break;
      default:
        break;
    }
  }

  // DataSetChanged（L126-130）
  void dataSetChanged() {
    recordChanged(null);
  }

  // DataSetScrolled（L133-137）
  void dataSetScrolled(int distance) {
    dataSetChanged();
  }

  // EditingChanged（L140-143）
  void editingChanged() {}

  // FocusControl（L146-149）
  void focusControl(TFieldRef? field) {}

  // GetActiveRecord（L152-156）
  int get activeRecord => dataSet!._activeRecord - _firstRecord;

  // SetActiveRecord（L218-225）
  set activeRecord(int value) {
    dataSet!._activeRecord = value + _firstRecord;
  }

  // GetDataSet（L158-165）
  TDataSet? get dataSet => _dataSource?.dataSet;

  // GetBOF（L168-172）
  bool get bof => dataSet!.bof;

  // GetBufferCount（L175-179）
  int get bufferCount => _bufferCount;

  // SetBufferCount（L228-239）
  set bufferCount(int value) {
    if (_bufferCount != value) {
      _bufferCount = value;
      if (active) {
        dataSet!.recalcBufListSize();
        calcRange();
      }
    }
  }

  // GetEOF（L182-186）
  bool get eof => dataSet!.eof;

  // GetRecordCount（L189-195）
  // @@@ fix: this used to read dataSet!._recordCount (a private field on
  // the dataset base class -- a count of "how many records are currently
  // buffered in the windowed buffer"; resync() resets it to a small value
  // on every call, capped at the dataset's own _bufferCount, see resync()'s
  // implementation), then capped it again against bufferCount (the
  // DataLink's own buffer setting) -- both are "small windowed buffer"
  // concepts. But the datasets actually in use (TCustomBufDataset/
  // TSQLQuery) aren't windowed-buffered at all -- the entire query result
  // lives in the _records array, and dataSet.recordCount (a public
  // property each subclass correctly overrides to _records.length) is the
  // real record count. The grid's _buildRow() already accesses any record
  // directly by index -- it isn't really limited to a small buffered
  // window -- so capping against _recordCount/bufferCount only makes the
  // grid think there are far fewer records than there actually are (even
  // 0). This is exactly why a 22-row detail grid rendered completely
  // blank.
  int get recordCount => dataSet?.recordCount ?? 0;

  // LayoutChanged（L198-202）
  void layoutChanged() {
    dataSetChanged();
  }

  // MoveBy（L205-209）
  int moveBy(int distance) => dataSet!.moveBy(distance);

  // RecordChanged（L212-215）
  void recordChanged(TField? field) {}

  // SetActive（L241-249）private
  void _setActive(bool aActive) {
    if (active != aActive) {
      _active = aActive;
      // !!!: Set internal state (original comment kept as-is)
      activeChanged();
    }
  }

  // SetDataSource（L251-271）
  TDataSource? get dataSource => _dataSource;
  set dataSource(TDataSource? value) {
    if (identical(_dataSource, value)) return;
    if (!dataSourceFixed) {
      if (_dataSource != null) {
        _dataSource!.unregisterDataLink(this);
        _dataSource = null;
        checkActiveAndEditing();
      }
      _dataSource = value;
      if (_dataSource != null) {
        _dataSource!.registerDataLink(this);
        checkActiveAndEditing();
      }
    }
  }

  // SetReadOnly（L273-281）
  bool get readOnly => _readOnly;
  set readOnly(bool value) {
    if (_readOnly != value) {
      _readOnly = value;
      checkActiveAndEditing();
    }
  }

  // UpdateData（L283-286）
  void updateData() {}

  // Edit（L290-297）
  bool edit() {
    if (!_readOnly) {
      dataSource!.edit();
    }
    // Triggered event will set FEditing (original comment kept as-is)
    return _editing;
  }

  // UpdateRecord（L300-309）
  void updateRecord() {
    _updatingRecord = true;
    try {
      updateData();
    } finally {
      _updatingRecord = false;
    }
  }

  // ExecuteAction / UpdateAction (L311-329): TBasicAction is LCL's
  // action system (the classes unit); this translation doesn't include a GUI action mechanism, not translated.

  bool get active => _active;
  bool get editing => _editing;
  int get firstRecord => _firstRecord;
  set firstRecord(int v) => _firstRecord = v;
}

// ---- TDetailDataLink (db.pas L1846-1851, implementation datasource.inc L336-340) ------
class TDetailDataLink extends TDataLink {
  // GetDetailDataSet（L336-340）
  TDataSet? get detailDataSet => null;
}

// ---- TMasterDataLink (db.pas L1855-1878, implementation datasource.inc L347-435) ------
class TMasterDataLink extends TDetailDataLink {
  final TDataSet _detailDataSet;
  String _fieldNames = '';
  final List<TField> _fields = [];
  TNotifyEvent? onMasterChange;
  TNotifyEvent? onMasterDisable;

  // constructor Create(ADataSet)（L347-353）
  TMasterDataLink(TDataSet aDataSet) : _detailDataSet = aDataSet;

  // destructor Destroy (L356-361): FFields.Free → handled by the GC

  // ActiveChanged（L364-380）
  @override
  void activeChanged() {
    _fields.clear();
    if (active) {
      try {
        dataSet!.getFieldList(_fields, _fieldNames);
      } catch (_) {
        _fields.clear();
        rethrow;
      }
    }
    if (_detailDataSet.active &&
        !_detailDataSet.componentState
            .contains(TComponentStateItem.csDestroying)) {
      if (active && _fields.isNotEmpty) {
        doMasterChange();
      } else {
        doMasterDisable();
      }
    }
  }

  // CheckBrowseMode（L383-387）
  @override
  void checkBrowseMode() {
    if (_detailDataSet.active) _detailDataSet.checkBrowseMode();
  }

  // GetDetailDataSet（L390-394）
  @override
  TDataSet? get detailDataSet => _detailDataSet;

  // LayoutChanged（L397-401）
  @override
  void layoutChanged() {
    activeChanged();
  }

  // RecordChanged（L404-411）
  @override
  void recordChanged(TField? field) {
    if (dataSource!.state != TDataSetState.dsSetKey &&
        _detailDataSet.active &&
        _fields.isNotEmpty &&
        (field == null || _fields.contains(field))) {
      doMasterChange();
    }
  }

  // SetFieldNames（L413-421）
  String get fieldNames => _fieldNames;
  set fieldNames(String value) {
    if (_fieldNames != value) {
      _fieldNames = value;
      activeChanged();
    }
  }

  List<TField> get fieldsList => _fields; // property Fields: TList

  // DoMasterDisable（L423-428）
  void doMasterDisable() {
    onMasterDisable?.call(this);
  }

  // DoMasterChange（L430-435）
  void doMasterChange() {
    onMasterChange?.call(this);
  }
}

// ---- TMasterParamsDataLink (db.pas L1882-1894, implementation datasource.inc
//      L441-525）--------------------------------------------------------------
class TMasterParamsDataLink extends TMasterDataLink {
  TParams? _params;

  // constructor Create(ADataSet)（L441-454）
  // ??? The original source uses RTTI (GetObjectProp(ADataset,'Params')) to dynamically fetch
  // the dataset's Params property —— Dart has no RTTI, so dynamic duck-typing is attempted
  // instead; if there's no such property, it stays null (behaviorally equivalent: when the original source can't
  // find the property, P=Nil and it just isn't set either).
  TMasterParamsDataLink(TDataSet aDataSet) : super(aDataSet) {
    try {
      final p = (aDataSet as dynamic).params;
      if (p is TParams) {
        params = p;
      }
    } catch (_) {
      // this dataset has no Params property
    }
  }

  // SetParams（L457-463）
  TParams? get params => _params;
  set params(TParams? aValue) {
    _params = aValue;
    if (aValue != null) {
      refreshParamNames();
    }
  }

  // RefreshParamNames（L465-498）
  void refreshParamNames() {
    var fn = '';
    final ds = dataSet;
    if (_params != null) {
      TField? f;
      for (var i = 0; i < _params!.count; i++) {
        final p = _params![i];
        if (!p.bound) {
          if (ds != null) {
            f = ds.findField(p.name);
          }
          if (ds == null || !ds.active || f != null) {
            if (fn != '') {
              fn = '$fn;';
            }
            fn = '$fn${p.name}';
          }
        }
      }
    }
    fieldNames = fn;
  }

  // CopyParamsFromMaster（L500-505）
  void copyParamsFromMaster(bool copyBound) {
    _params?.copyParamValuesFromDataset(dataSet, copyBound);
  }

  // DoMasterDisable（L507-513）

  // DoMasterChange（L515-525）
  @override
  void doMasterChange() {
    super.doMasterChange();
    if (params != null && detailDataSet != null && detailDataSet!.active) {
      detailDataSet!.checkBrowseMode();
      detailDataSet!.close();
      detailDataSet!.open();
    }
  }
}

// ---- TDataSource (db.pas L1898-1938, implementation datasource.inc L531-719) ----------

// TDataChangeEvent（db.pas L1898）
typedef TDataChangeEvent = void Function(Object sender, TField? field);

class TDataSource extends TComponent {
  TDataSet? _dataSet;
  final List<TDataLink> _dataLinks = [];
  bool _enabled = true;
  bool autoEdit = true;
  TDataSetState _state = TDataSetState.dsInactive;
  TNotifyEvent? onStateChange;
  TDataChangeEvent? onDataChange;
  TNotifyEvent? onUpdateData;

  // constructor Create（datasource.inc L531-538）
  TDataSource([super.aOwner]) {
    _enabled = true;
    autoEdit = true;
  }

  // destructor Destroy（L541-551）
  @override
  void destroy() {
    onStateChange = null;
    dataSet = null;
    while (_dataLinks.isNotEmpty) {
      _dataLinks.last.dataSource = null;
    }
    super.destroy();
  }

  // Edit（L554-559）
  void edit() {
    if (state == TDataSetState.dsBrowse && autoEdit) {
      dataSet!.edit();
    }
  }

  // IsLinkedTo（L562-577）
  bool isLinkedTo(TDataSet? aDataset) {
    var result = false;
    var ds = aDataset;
    do {
      final src = ds!.getDataSource();
      result = identical(src, this);
      if (src != null) {
        ds = src.dataSet;
      } else {
        ds = null;
      }
    } while (!result && ds != null);
    return result;
  }

  // DistributeEvent (L580-598): non-visual links receive it first, visual links receive it after
  void distributeEvent(TDataEvent event, dynamic info) {
    for (final link in List<TDataLink>.from(_dataLinks)) {
      if (!link.visualControl) {
        link.dataEvent(event, info);
      }
    }
    for (final link in List<TDataLink>.from(_dataLinks)) {
      if (link.visualControl) {
        link.dataEvent(event, info);
      }
    }
  }

  // GetLink / GetLinkCount（L600-608）
  TDataLink dataLink(int aIndex) => _dataLinks[aIndex];
  int get dataLinkCount => _dataLinks.length;
  List<TDataLink> get dataLinks => _dataLinks;

  // RegisterDataLink（L610-616）
  void registerDataLink(TDataLink dataLink) {
    _dataLinks.add(dataLink);
    _dataSet?.recalcBufListSize();
  }

  // SetDataSet（L619-635）
  TDataSet? get dataSet => _dataSet;
  set dataSet(TDataSet? aDataSet) {
    if (_dataSet != null) {
      _dataSet!.unRegisterDataSource(this);
      _dataSet = null;
      processEvent(TDataEvent.deUpdateState, 0);
    }
    if (aDataSet != null) {
      if (isLinkedTo(aDataSet)) {
        databaseError(SErrCircularDataSourceReferenceNotAllowed, this);
      }
      _dataSet = aDataSet;
      aDataSet.registerDataSource(this);
      processEvent(TDataEvent.deUpdateState, 0);
    }
  }

  // SetEnabled（L638-642）
  bool get enabled => _enabled;
  set enabled(bool value) {
    _enabled = value;
  }

  // DoDataChange（L645-650）
  void doDataChange(TField? info) {
    onDataChange?.call(this, info);
  }

  // DoStateChange（L652-657）
  void doStateChange() {
    onStateChange?.call(this);
  }

  // DoUpdateData（L660-665）
  void doUpdateData() {
    onUpdateData?.call(this);
  }

  // UnregisterDataLink（L668-675）
  void unregisterDataLink(TDataLink dataLink) {
    _dataLinks.remove(dataLink);
    _dataSet?.recalcBufListSize();
    //Dataset.SetBufListSize(DataLink.BufferCount); (original comment kept as-is)
  }

  // ProcessEvent（L678-719）
  void processEvent(TDataEvent event, dynamic info) {
    const onDataChangeEvents = {
      TDataEvent.deRecordChange,
      TDataEvent.deDataSetChange,
      TDataEvent.deDataSetScroll,
      TDataEvent.deLayoutChange,
      TDataEvent.deUpdateState,
    };

    bool needDataChange;
    // Special UpdateState handling. (original comment kept as-is)
    if (event == TDataEvent.deUpdateState) {
      needDataChange = _state == TDataSetState.dsInactive;
      final lastState = _state;
      if (_dataSet != null) {
        _state = _dataSet!.state;
      } else {
        _state = TDataSetState.dsInactive;
      }
      // Don't do events if nothing changed. (original comment kept as-is)
      if (_state == lastState) return;
    } else {
      needDataChange = true;
    }
    if (event != TDataEvent.deUpdateState &&
        _state == TDataSetState.dsInactive) {
      return;
    }
    distributeEvent(event, info);
    // Extra handlers (original comment kept as-is)
    if (!componentState.contains(TComponentStateItem.csDestroying)) {
      if (event == TDataEvent.deUpdateState) {
        doStateChange();
      }
      if (onDataChangeEvents.contains(event) && needDataChange) {
        doDataChange(null);
      }
      if (event == TDataEvent.deFieldChange) {
        doDataChange(info is TField ? info : null);
      }
      if (event == TDataEvent.deUpdateRecord) {
        doUpdateData();
      }
    }
  }

  TDataSetState get state => _state;
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 10 —— TDBDataset / TDBTransaction / TCustomConnection / TDatabase
//  Declaration: db.pas L1942-2098; implementation: database.inc (the whole 778-line file)
//  ??? TThreadList (a thread-safe list) → List: within Dart's single isolate there's no
//  data race, so the paired LockList/UnlockList calls are just expanded directly into accessing the underlying list.
// ═════════════════════════════════════════════════════════════════════════════

// TLoginEvent（db.pas L1999）
typedef TLoginEvent = void Function(
    Object sender, String username, String password);

// The LoginDialogExProc global variable (db.pas L2248): a var parameter → wrapped as TStringRef
typedef TLoginDialogExProc = bool Function(String aDatabaseName,
    TStringRef aUserName, TStringRef aPassword, bool userNameReadOnly);

TLoginDialogExProc? loginDialogExProc;

// ---- TCustomConnection (db.pas L2001-2044, implementation database.inc
//      L615-776）--------------------------------------------------------------
class TCustomConnection extends TComponent {
  TNotifyEvent? afterConnect;
  TNotifyEvent? afterDisconnect;
  TNotifyEvent? beforeConnect;
  TNotifyEvent? beforeDisconnect;
  bool forcedClose = false;
  bool loginPrompt = false;
  TLoginEvent? onLogin;
  bool streamedConnected = false;

  TCustomConnection([super.aOwner]);

  // GetDataSet / GetDataSetCount（database.inc L615-623）
  TDataSet? getDataSet(int index) => null;
  int getDataSetCount() => 0;

  int get dataSetCount => getDataSetCount();
  TDataSet? dataSets(int index) => getDataSet(index);

  // InternalHandleException (L625-631): the same handling as TDataSet's
  void internalHandleException() {
    // ignore: avoid_print
    print("TCustomConnection.internalHandleException: unhandled exception");
  }

  // The SetAfterConnect etc. setters (L633-651): Dart event fields are directly writable,
  // and the original setters have no extra logic, so they're merged into public fields.

  // DoLoginPrompt（L653-670）
  void doLoginPrompt() {
    if (loginPrompt) {
      final dbName = TStringRef("");
      final userName = TStringRef("");
      final password = TStringRef("");
      getLoginParams(dbName, userName, password);
      if (onLogin != null) {
        onLogin!(this, userName.value,
            password.value); // by value (original comment)
      } else if (loginDialogExProc != null) {
        loginDialogExProc!(
            dbName.value, userName, password, false); // by reference
        setLoginParams(dbName.value, userName.value, password.value);
      }
    }
  }

  // SetConnected（L672-703）
  bool get connected => getConnected();
  set connected(bool value) => setConnected(value);

  void setConnected(bool value) {
    if (value != connected) {
      if (value) {
        if (componentState.contains(TComponentStateItem.csReading)) {
          streamedConnected = true;
          return;
        } else {
          beforeConnect?.call(this);
          doLoginPrompt();
          doConnect();
          afterConnect?.call(this);
        }
      } else {
        beforeDisconnect?.call(this);
        doDisconnect();
        afterDisconnect?.call(this);
      }
    }
  }

  // GetLoginParams / SetLoginParams（L705-723）
  // ??? The original source uses RTTI (IsPublishedProp/GetStrProp) to dynamically access the
  // 'DatabaseName'/'UserName'/'Password' properties —— Dart has no RTTI, so dynamic
  // duck-typing is used instead, skipping if the property doesn't exist (behaviorally equivalent).
  void getLoginParams(
      TStringRef aDatabaseName, TStringRef aUserName, TStringRef aPassword) {
    try {
      final v = (this as dynamic).databaseName;
      if (v is String) aDatabaseName.value = v;
    } catch (_) {}
    try {
      final v = (this as dynamic).userName;
      if (v is String) aUserName.value = v;
    } catch (_) {}
    try {
      final v = (this as dynamic).password;
      if (v is String) aPassword.value = v;
    } catch (_) {}
  }

  void setLoginParams(
      String aDatabaseName, String aUserName, String aPassword) {
    try {
      (this as dynamic).databaseName = aDatabaseName;
    } catch (_) {}
    try {
      (this as dynamic).userName = aUserName;
    } catch (_) {}
    try {
      (this as dynamic).password = aPassword;
    } catch (_) {}
  }

  // DoConnect / DoDisconnect（L725-735）
  void doConnect() {
    // Do nothing yet (original comment kept as-is)
  }

  void doDisconnect() {
    // Do nothing yet (original comment kept as-is)
  }

  // GetConnected（L737-741）
  bool getConnected() => false;

  // Loaded（L743-755）
  void loaded() {
    try {
      if (streamedConnected) setConnected(true);
    } catch (_) {
      if (componentState.contains(TComponentStateItem.csDesigning)) {
        internalHandleException();
      } else {
        rethrow;
      }
    }
  }

  // Close（L757-765）
  void closeConnection([bool forceClose = false]) {
    try {
      forcedClose = forceClose;
      connected = false;
    } finally {
      forcedClose = false;
    }
  }

  // destructor Destroy（L767-771）
  @override
  void destroy() {
    connected = false;
    super.destroy();
  }

  // Open（L773-776）
  void openConnection() {
    connected = true;
  }
}

// ---- TDatabase (db.pas L2051-2098, implementation database.inc L21-316) ---------------
class TDatabase extends TCustomConnection {
  bool _connected = false;
  String databaseName = '';
  final List<TDBDataset> _dbDatasets =
      []; // TThreadList → List (see the note at the start of this section)
  final List<TDBTransaction> _transactions = [];
  String directory = '';
  bool keepConnection = false;
  late TStrings _params;
  final bool _sqlBased = false;
  bool _openAfterRead = false;

  // constructor Create（database.inc L56-64）
  TDatabase([super.aOwner]) {
    _params = TStringList();
    _connected = false;
  }

  // destructor Destroy（L66-76）
  @override
  void destroy() {
    connected = false;
    removeDataSets();
    removeTransactions();
    super.destroy();
  }

  // CheckConnected / CheckDisConnected（L21-33）
  void checkConnected() {
    if (!connected) databaseError(SNotConnected, this);
  }

  void checkDisConnected() {
    if (connected) databaseError(SConnected, this);
  }

  // DoConnect（L35-39）
  @override
  void doConnect() {
    doInternalConnect();
    _connected = true;
  }

  // DoDisconnect（L41-49）
  @override
  void doDisconnect() {
    closeDataSets();
    closeTransactions();
    doInternalDisConnect();
    if (componentState.contains(TComponentStateItem.csLoading)) {
      _openAfterRead = false;
    }
    _connected = false;
  }

  // GetConnected（L51-54）
  @override
  bool getConnected() => _connected;

  // CloseDataSets (L78-95): from the end backward
  void closeDataSets() {
    for (var i = _dbDatasets.length - 1; i >= 0; i--) {
      _dbDatasets[i].close();
    }
  }

  // CloseTransactions（L97-119）
  void closeTransactions() {
    for (var i = _transactions.length - 1; i >= 0; i--) {
      try {
        _transactions[i].endTransaction();
      } catch (_) {
        if (!forcedClose) rethrow;
      }
    }
  }

  // RemoveDataSets（L121-137）
  void removeDataSets() {
    for (var i = _dbDatasets.length - 1; i >= 0; i--) {
      _dbDatasets[i].database = null;
    }
  }

  // RemoveTransactions（L139-155）
  void removeTransactions() {
    for (var i = _transactions.length - 1; i >= 0; i--) {
      _transactions[i].database = null;
    }
  }

  // SetParams（L157-161）
  TStrings get params => _params;
  set params(TStrings? aValue) {
    if (aValue != null) _params.assign(aValue);
  }

  // GetDataSetCount / GetTransactionCount（L163-197）
  @override
  int getDataSetCount() => _dbDatasets.length;

  int get transactionCount => _transactions.length;

  // GetDataset / GetTransaction（L199-241）
  @override
  TDataSet? getDataSet(int index) {
    return _dbDatasets[index];
  }

  TDBTransaction transactions(int index) => _transactions[index];

  // RegisterDataset（L243-259）
  void registerDataset(TDBDataset ds) {
    if (!_dbDatasets.contains(ds)) {
      _dbDatasets.add(ds);
    } else {
      databaseErrorFmt(SDatasetRegistered, [ds.name]);
    }
  }

  // RegisterTransaction（L261-278）
  void registerTransaction(TDBTransaction ta) {
    if (!_transactions.contains(ta)) {
      _transactions.add(ta);
    } else {
      databaseErrorFmt(STransactionRegistered, [ta.name]);
    }
  }

  // UnRegisterDataset（L280-297）
  void unregisterDataset(TDBDataset ds) {
    if (_dbDatasets.contains(ds)) {
      _dbDatasets.remove(ds);
    } else {
      databaseErrorFmt(SNoDatasetRegistered, [ds.name]);
    }
  }

  // UnRegisterTransaction（L299-316）
  void unregisterTransaction(TDBTransaction ta) {
    if (_transactions.contains(ta)) {
      _transactions.remove(ta);
    } else {
      databaseErrorFmt(SNoTransactionRegistered, [ta.name]);
    }
  }

  bool get isSQLBased => _sqlBased;

  // The abstract method group (db.pas L2079-2088) → throwing virtuals (same
  // treatment as TDataSet's abstract members)
  void doInternalConnect() {
    throw EDatabaseError("AbstractError: TDatabase.DoInternalConnect");
  }

  void doInternalDisConnect() {
    throw EDatabaseError("AbstractError: TDatabase.DoInternalDisConnect");
  }

  void startTransaction() {
    throw EDatabaseError("AbstractError: TDatabase.StartTransaction");
  }

  void endTransaction() {
    throw EDatabaseError("AbstractError: TDatabase.EndTransaction");
  }
}

// ---- TDBTransaction (db.pas L1960-1995, implementation database.inc L369-609) ---------
class TDBTransaction extends TComponent {
  bool _transActive = false;
  TDatabase? _database;
  final List<TDBDataset> _dbDatasets = []; // TThreadList → List
  bool _openAfterRead = false;

  // constructor Create（database.inc L468-473）
  TDBTransaction([super.aOwner]);

  // destructor Destroy（L512-520）
  @override
  void destroy() {
    database = null;
    closeDataSets();
    removeDataSets();
    super.destroy();
  }

  // SetActive（L369-381）
  bool get active => _transActive;
  set active(bool value) {
    if (_transActive && !value) {
      endTransaction();
    } else if (!_transActive && value) {
      if (componentState.contains(TComponentStateItem.csLoading)) {
        _openAfterRead = true;
        return;
      } else {
        startTransaction();
      }
    }
  }

  // Loaded（L383-395）
  void loaded() {
    try {
      if (_openAfterRead) active = true;
    } catch (_) {
      if (componentState.contains(TComponentStateItem.csDesigning)) {
        internalHandleException();
      } else {
        rethrow;
      }
    }
  }

  // InternalHandleException（L397-404）
  void internalHandleException() {
    // ignore: avoid_print
    print("TDBTransaction.internalHandleException: unhandled exception");
  }

  // CheckActive / CheckInactive（L406-418）
  void checkActive() {
    if (!_transActive) databaseError(STransNotActive, this);
  }

  void checkInactive() {
    if (_transActive) databaseError(STransActive, this);
  }

  // Commit / CommitRetaining / Rollback / RollbackRetaining（L420-440）
  void commit() {
    endTransaction();
  }

  void commitRetaining() {
    commit();
    startTransaction();
  }

  void rollback() {
    endTransaction();
  }

  void rollbackRetaining() {
    rollback();
    startTransaction();
  }

  // CloseTrans / OpenTrans（L442-452）
  void closeTrans() {
    _transActive = false;
  }

  void openTrans() {
    _transActive = true;
  }

  // SetDatabase（L454-466）
  TDatabase? get database => _database;
  set database(TDatabase? value) {
    if (!identical(value, _database)) {
      checkInactive();
      if (_database != null) {
        _database!.unregisterTransaction(this);
      }
      if (value != null) {
        value.registerTransaction(this);
      }
      _database = value;
    }
  }

  // CheckDatabase（L475-480）
  void checkDatabase() {
    if (_database == null) {
      databaseError(SErrNoDatabaseAvailable, this);
    }
  }

  // AllowClose（L482-486）
  bool allowClose(TDBDataset? ds) => ds != null;

  // CloseDataSets（L488-510）
  void closeDataSets() {
    for (var i = _dbDatasets.length - 1; i >= 0; i--) {
      final ds = _dbDatasets[i];
      if (allowClose(ds)) {
        ds.close();
      }
    }
  }

  // RemoveDataSets（L522-538）
  void removeDataSets() {
    for (var i = _dbDatasets.length - 1; i >= 0; i--) {
      _dbDatasets[i].transaction = null;
    }
  }

  // GetDataset / GetDataSetCount（L540-572）
  TDBDataset getDataset(int index) => _dbDatasets[index];
  int get dataSetCount => _dbDatasets.length;

  // RegisterDataset（L574-590）
  void registerDataset(TDBDataset ds) {
    if (!_dbDatasets.contains(ds)) {
      _dbDatasets.add(ds);
    } else {
      databaseErrorFmt(SDatasetRegistered, [ds.name]);
    }
  }

  // UnRegisterDataset（L592-609）
  void unRegisterDataset(TDBDataset ds) {
    if (_dbDatasets.contains(ds)) {
      _dbDatasets.remove(ds);
    } else {
      databaseErrorFmt(SNoDatasetRegistered, [ds.name]);
    }
  }

  // The abstract method (db.pas L1984-1985)
  void endTransaction() {
    throw EDatabaseError("AbstractError: TDBTransaction.EndTransaction");
  }

  void startTransaction() {
    throw EDatabaseError("AbstractError: TDBTransaction.StartTransaction");
  }
}

// ---- TDBDataset (db.pas L1943-1955, implementation database.inc L323-364) -------------
// TDBDatasetClass = Class of TDBDataset → a factory typedef (convention 2)
typedef TDBDatasetClass = TDBDataset Function(TComponent? aOwner);

class TDBDataset extends TDataSet {
  TDatabase? _database;
  TDBTransaction? _transaction;

  TDBDataset([super.aOwner]);

  // SetDatabase（database.inc L323-335）
  TDatabase? get database => _database;
  set database(TDatabase? value) {
    if (!identical(value, _database)) {
      checkInactive();
      if (_database != null) {
        _database!.unregisterDataset(this);
      }
      if (value != null) {
        value.registerDataset(this);
      }
      _database = value;
    }
  }

  // SetTransaction（L337-349）
  TDBTransaction? get transaction => _transaction;
  set transaction(TDBTransaction? value) {
    checkInactive();
    if (!identical(value, _transaction)) {
      if (_transaction != null) {
        _transaction!.unRegisterDataset(this);
      }
      if (value != null) {
        value.registerDataset(this);
      }
      _transaction = value;
    }
  }

  // CheckDatabase（L351-356）
  void checkDatabase() {
    if (_database == null) {
      databaseError(SErrNoDatabaseAvailable, this);
    }
  }

  // destructor Destroy（L358-364）
  @override
  void destroy() {
    database = null;
    transaction = null;
    super.destroy();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 11 —— the remaining global functions in db.pas's implementation section (L2702-2716)
//  (DatabaseError/DatabaseErrorFmt/ExtractFieldName were already placed earlier, in Section 3;
//  DateTimeRecToDateTime/DateTimeToDateTimeRec are in
//  Section 8; SkipComments/SkipQuotesString are in Section 7)
// ═════════════════════════════════════════════════════════════════════════════

// DisposeMem（db.pas L2702-2709）/ BuffersEqual（L2712-2716）：
// Pure pointer/memory operations (FreeMem/CompareByte) — under convention 1 the buffer is
// an object with memory managed by the GC, so there's no equivalent need — BuffersEqual provides a semantically
// equivalent byte-array comparison version for subclasses to use.
bool buffersEqual(Uint8List? buf1, Uint8List? buf2, int size) {
  if (buf1 == null || buf2 == null) return buf1 == buf2;
  for (var i = 0; i < size; i++) {
    if (buf1[i] != buf2[i]) return false;
  }
  return true;
}

// ═════════════════════════════════════════════════════════════════════════════
//  End of file —— db.pas + all .inc files fully translated
//  {$i dataset.inc}{$i fields.inc}{$i datasource.inc}{$i database.inc}
//  {$i dsparams.inc} → corresponds to SECTION 3-10 of this file
// ═════════════════════════════════════════════════════════════════════════════
