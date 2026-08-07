// ═════════════════════════════════════════════════════════════════════════════
//  lazarus_sqldb.dart
//
//  This file is a Dart translation (derivative work) of the following Object Pascal upstream source:
//    Upstream project: Free Pascal FCL-DB (sqldb)
//    Upstream file: sqldb.pp
//
//  Upstream copyright:
//   Copyright (c) 2004-2024 by Joost van der Sluis and the Free Pascal development team
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
//  lazarus_sqldb.dart —— full line-by-line translation of FPC sqldb.pp
//  ─────────────────────────────────────────────────────────────────────────
//  Corresponds to: sqldb.pp (4,026 lines)
//  Depends on: lazarus_db.dart (the full translation of db.pas, same folder)
//
//  ??? Source for three `uses` dependencies (bufdataset / sqltypes / sqlscript) was not provided;
//  this file uses "minimal shims" to stand in for them, to be replaced section-by-section once the real source is obtained:
//    SECTION S0  sqltypes shim  —— pure types/enums (rebuilt from how
//                sqldb.pp actually uses them; low risk)
//    SECTION S1  sqlscript shim —— a minimal TCustomSQLScript implementation (script
//                splitting only by Terminator, without the real implementation's full comment/quote/SET TERM
//                parsing)
//    SECTION S2  bufdataset shim —— a mini TCustomBufDataset implementation (a minimally
//                usable version of the record storage/fetch protocol/update log — **not**
//                the real implementation's indexing/update-buffering/packet mechanism)
//  Shim sections are bounded by "=== SHIM ===" markers; everything after SECTION 1 is the
//  line-by-line translation of the sqldb.pp body itself.
//
//  Translation conventions carried over from lazarus_db.dart's header (the same 11 rules:
//  pointer→object, class of→factory, Variant→dynamic, method names lowerCamelCase……), not repeated here.
// ═════════════════════════════════════════════════════════════════════════════

import 'dart:typed_data';
import 'dart:convert';                        // @@@ used by WapDb's HTTP driver (JSON)
import 'package:http/http.dart' as http;      // @@@ used by WapDb's HTTP driver
import 'package:flutter/foundation.dart';     // @@@ debugPrint (SQL diagnostic output)

import 'lazarus_db.dart';

// @@@ TWapSQLConnection / WapDb / the async facade (openAsync/execSQLAsync/
// @@@ applyUpdatesAsync) etc. used to live separately in lazarus_sqldb_wap.dart, and have
// @@@ now been merged directly into this file (see the "lazarus_sqldb_wap.dart merged in"
// @@@ block at the end of the file); callers only need to import 'lazarus_sqldb.dart' to get every symbol.

// aa !!! not fully translated
// ─────────────────────────────────────────────────────────────────────────
//  The three sections below (S0/S1/S2) are "shims", not translations of FPC source —
//  because the source for these three `uses` dependencies wasn't available:
//    sqltypes.pp    → S0: pure types/enums, rebuilt from how sqldb.pp uses them (low risk)
//    sqlscript.pp   → S1: a minimal TCustomSQLScript version. The script is only split by Terminator,
//                     without the real implementation's full "comment/quote/SET TERM" parsing.
//    bufdataset.pas → S2: a mini TCustomBufDataset version. **Not** the real implementation's indexing/
//                     update-buffer/packet mechanism — just the minimal record engine needed to ground
//                     TDataSet's abstract contract (List<TRecordBuffer> + traversal
//                     + a 4-byte bookmark + a simple update log).
//
//  Impact: open/edit/post/applyUpdates work normally, but there's no index-accelerated lookup, no batched
//        packets, and performance falls short of the real implementation with large data volumes.
//  TODO: once the source above is obtained, replace it section by section (this file's SECTION 1 onward
//        is the line-by-line translation of sqldb.pp and is unaffected).
// ─────────────────────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
//  SECTION S0 —— sqltypes shim (=== SHIM ===, to be replaced with the real sqltypes.pp later)
//  Rebuilt from how the aliases/constants at sqldb.pp L26-83 are actually used.
// ═════════════════════════════════════════════════════════════════════════════

// TSchemaType（sqltypes）
enum TSchemaType {
  stNoSchema,
  stTables,
  stSysTables,
  stProcedures,
  stColumns,
  stProcedureParams,
  stIndexes,
  stPackages,
  stSchemata,
  stSequences,
}

// TStatementType（sqltypes）
enum TStatementType {
  stUnknown,
  stSelect,
  stInsert,
  stUpdate,
  stDelete,
  stDDL,
  stGetSegment,
  stPutSegment,
  stExecProcedure,
  stStartTrans,
  stCommit,
  stRollback,
  stSelectForUpd,
}

// TDBEventType / TDBEventTypes（sqltypes）
enum TDBEventType {
  detCustom,
  detPrepare,
  detExecute,
  detFetch,
  detCommit,
  detRollBack,
  detParamValue,
  detActualSQL,
}

typedef TDBEventTypes = Set<TDBEventType>;

// TQuoteChars = array[0..1] of char (sqltypes) → a List of length 2
typedef TQuoteChars = List<String>;

// TSqlObjectIdentifier / TSqlObjectIdentifierList（sqltypes）：
// The return container for GetObjectNames
class TSqlObjectIdentifier extends TCollectionItem {
  String schemaName = '';
  String objectName = '';

  TSqlObjectIdentifier(TCollection? aCollection) : super(aCollection);

  String get fullName =>
      schemaName.isEmpty ? objectName : "$schemaName.$objectName";
}

class TSqlObjectIdentifierList extends TCollection {
  TSqlObjectIdentifierList() : super((c) => TSqlObjectIdentifier(c));

  TSqlObjectIdentifier addIdentifier(
      [String aObjectName = '', String aSchemaName = '']) {
    final result = add() as TSqlObjectIdentifier;
    result.objectName = aObjectName;
    result.schemaName = aSchemaName;
    return result;
  }

  TSqlObjectIdentifier operator [](int index) =>
      getItem(index) as TSqlObjectIdentifier;
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION S1 —— sqlscript shim (=== SHIM ===, to be replaced with the real sqlscript.pp later)
//  The parent-class surface used by TSQLScript (sqldb.pp L721-758): Script/Terminator/
//  Directives/Defines/Aborted/Line/AutoCommit/UseSetTerm/UseCommit/
//  UseDefines/CommentsinSQL/UseDollarString/DollarStrings/OnException +
//  ExecuteStatement/ExecuteDirective/ExecuteCommit virtual hooks + Execute.
//  ??? Minimal implementation: splits and executes strictly by Terminator, without the real
//  implementation's full quote/comment/SET TERM/DEFINE parsing.
// ═════════════════════════════════════════════════════════════════════════════

typedef TSQLScriptDirectiveEvent = void Function(
    Object sender, String directive, String argument, TBoolRef stopExecution);

typedef TSQLScriptExceptionEvent = void Function(
    Object sender, TStrings theStatement, Object theException,
    TBoolRef continueExecution);

class TCustomSQLScript extends TComponent {
  bool autoCommit = false;
  bool useDollarString = false;
  late TStrings dollarStrings;
  late TStrings directives;
  late TStrings defines;
  late TStrings _script;
  String terminator = ';';
  bool commentsinSQL = true;
  bool useSetTerm = true;
  bool useCommit = true;
  bool useDefines = true;
  TSQLScriptExceptionEvent? onException;

  bool _aborted = false;
  int _line = 0;

  TCustomSQLScript([TComponent? aOwner]) : super(aOwner) {
    _script = TStringList();
    dollarStrings = TStringList();
    directives = TStringList();
    defines = TStringList();
  }

  bool get aborted => _aborted;
  int get line => _line;

  TStrings get script => _script;
  set script(TStrings value) => _script.assign(value);

  // Virtual hooks (abstract in the real implementation)
  void executeStatement(TStrings sqlStatement, TBoolRef stopExecution) {
    throw EDatabaseError("AbstractError: TCustomSQLScript.ExecuteStatement");
  }

  void executeDirective(
      String directive, String argument, TBoolRef stopExecution) {
    throw EDatabaseError("AbstractError: TCustomSQLScript.ExecuteDirective");
  }

  void executeCommit([bool commitRetaining = true]) {
    throw EDatabaseError("AbstractError: TCustomSQLScript.ExecuteCommit");
  }

  // Execute: ??? minimal shim version — splits the Script into individual statements by Terminator, feeding each to
  // ExecuteStatement; COMMIT entries go through ExecuteCommit.
  void execute() {
    _aborted = false;
    _line = 0;
    final full = _script.text;
    final statements = full.split(terminator);
    for (final raw in statements) {
      final stmt = raw.trim();
      if (stmt.isEmpty) continue;
      _line++;
      final stop = TBoolRef(false);
      if (useCommit && stmt.toUpperCase() == 'COMMIT') {
        executeCommit();
      } else {
        final sl = TStringList();
        sl.text = stmt;
        executeStatement(sl, stop);
      }
      if (stop.value) {
        _aborted = true;
        break;
      }
      if (autoCommit) {
        executeCommit();
      }
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION S2 —— bufdataset shim (=== SHIM ===, to be replaced with the real
//  bufdataset.pas later)
//  A mini TCustomBufDataset implementation: provides the virtual interface sqldb.pp needs
//  （Fetch/LoadField/LoadBlobIntoBuffer/ApplyRecUpdate/SetPacketRecords/
//  ApplyUpdates/SetReadOnly/BeforeRefreshOpenCursor/IndexDefs/
//  MaxIndexesCount) + the minimal record engine that grounds TDataSet's abstract contract:
//    - Record storage: List<TRecordBuffer>, getRecord traverses it + fetches on demand
//    - bookmark: a 4-byte representation of the record index
//    - Field values: TRecordBuffer.fieldData keyed by the uppercase field name
//    - Update log: a minimal pending list (ukInsert/ukModify/ukDelete),
//      ApplyUpdates calls applyRecUpdate for each entry
//  ??? The real implementation's indexing mechanism (TBufIndex multi-index/IndexFieldNames sorting),
//  packet loading (PacketRecords batching+FAllPacketsFetched), and update buffering
//  (FUpdateBuffer's full old/new snapshots) are only matched here in form, minimally.
// ═════════════════════════════════════════════════════════════════════════════

// TBlobBuffer / TBufBlobField / PBufBlobField（bufdataset）：
// The attached structure for a blob field inside the buffer
class TBlobBuffer {
  Uint8List? buffer;
  int size = 0;
  int fieldNo = 0;
}

class TBufBlobField {
  TBlobBuffer? blobBuffer;
  dynamic connBlobBuffer; // freely attached by the driver side
}

// PBufBlobField = ^TBufBlobField → an object reference (convention 1)
typedef PBufBlobField = TBufBlobField;

// An update-log entry (??? minimal shim version; the real implementation is
// FUpdateBuffer's TRecUpdateBuffer array with a full snapshot)
class _PendingUpdate {
  final TUpdateKind kind;
  final Map<String, dynamic> oldValues;
  final Map<String, dynamic> newValues;
  _PendingUpdate(this.kind, this.oldValues, this.newValues);
}

class TCustomBufDataset extends TDBDataset {
  final List<TRecordBuffer> _records = [];
  int _cursorIndex = -1; // the underlying cursor position (getRecord's current)
  bool _allPacketsFetched = false;
  bool _bufOpen = false;
  int _packetRecords = 10;
  bool _readOnly = false;
  int maxIndexesCount = 2;
  String indexFieldNames = '';
  late TIndexDefs _indexDefs;
  final List<_PendingUpdate> _pendingUpdates = [];
  int _changeCount = 0;

  TCustomBufDataset([TComponent? aOwner]) : super(aOwner) {
    _indexDefs = TIndexDefs(this);
  }

  // ---- The virtual interface sqldb.pp needs to override -----------------------------------
  // Fetch: asks the underlying cursor for the next row; true = there's data (overridden by TCustomSQLQuery)
  bool fetch() => false;

  // LoadField: loads a given field's value from the current cursor row into the buffer; false = NULL
  bool loadField(TFieldDef fieldDef, TValueBuffer buffer, TBoolRef createBlob) {
    return false;
  }

  // LoadBlobIntoBuffer（TCustomSQLQuery override）
  void loadBlobIntoBuffer(TFieldDef fieldDef, PBufBlobField aBlobBuf) {
    throw EDatabaseError(
        "AbstractError: TCustomBufDataset.LoadBlobIntoBuffer");
  }

  // ApplyRecUpdate（TCustomSQLQuery override）
  void applyRecUpdate(TUpdateKind updateKind) {
    throw EDatabaseError("AbstractError: TCustomBufDataset.ApplyRecUpdate");
  }

  int get packetRecords => _packetRecords;
  set packetRecords(int aValue) => setPacketRecords(aValue);

  void setPacketRecords(int aValue) {
    if (aValue == -1 || aValue > 0) {
      _packetRecords = aValue;
    } else {
      databaseError(SInvPacketRecordsValue);
    }
  }

  bool get readOnly => _readOnly;
  set readOnly(bool aValue) => setReadOnly(aValue);

  void setReadOnly(bool aValue) {
    _readOnly = aValue;
  }

  void beforeRefreshOpenCursor() {}

  // Refreshing（bufdataset.pas L525/L622）
  bool _refreshing = false;
  bool get refreshing => _refreshing;

  // InternalRefresh (bufdataset.pas L3760-3780, the real implementation's flow)
  @override
  void internalRefresh() {
    if (_pendingUpdates.isNotEmpty) {
      databaseError(SErrApplyUpdBeforeRefresh, this);
    }
    _refreshing = true;
    try {
      final storeDefaultFields = defaultFields;
      setDefaultFields(false);
      freeFieldBuffers();
      clearBuffers();
      internalClose();
      beforeRefreshOpenCursor();
      internalOpen();
      setDefaultFields(storeDefaultFields);
    } finally {
      _refreshing = false;
    }
  }

  // IsReadFromPacket（bufdataset.pas L3809-3812）：
  // (FDatasetReader<>nil) or (FFileName<>'') or FReadFromFile——
  // ??? The shim has no file-packet loading mechanism; always false
  bool isReadFromPacket() => false;

  // UniDirectional property（bufdataset.pas L667）
  bool get uniDirectional => isUniDirectional;
  set uniDirectional(bool value) => setUniDirectional(value);

  TIndexDefs get indexDefs => _indexDefs;

  int get changeCount => _changeCount;

  // ApplyUpdates: replays the update log entry by entry (??? minimal shim version: calls
  // applyRecUpdate directly in log order, aborting once the error count exceeds maxErrors; the real
  // implementation has a reconcile/resolver event flow)
  void applyUpdates([int maxErrors = 0]) {
    checkBrowseMode();
    var failures = 0;
    while (_pendingUpdates.isNotEmpty) {
      final upd = _pendingUpdates.first;
      try {
        _applyingUpdate = upd;
        applyRecUpdate(upd.kind);
        _pendingUpdates.removeAt(0);
        _changeCount = _pendingUpdates.length;
      } catch (_) {
        failures++;
        if (maxErrors >= 0 && failures > maxErrors) rethrow;
        _pendingUpdates.removeAt(0);
      } finally {
        _applyingUpdate = null;
      }
    }
  }

  _PendingUpdate? _applyingUpdate;

  void cancelUpdates() {
    _pendingUpdates.clear();
    _changeCount = 0;
  }

  // ---- Grounding TDataSet's abstract contract (a mini record engine) --------------------------------

  @override
  bool isCursorOpen() => _bufOpen;

  @override
  TRecordBuffer? allocRecordBuffer() => TRecordBuffer();

  @override
  void internalOpen() {
    _records.clear();
    _cursorIndex = -1;
    _allPacketsFetched = false;
    // @@@ The real TCustomBufDataset.InternalOpen doesn't build fields — building fields
    // @@@ is the descendant's responsibility (TCustomSQLQuery.internalOpen), which calls
    // @@@ createFields() before calling super.internalOpen(). Building them again here
    // @@@ would cause a duplicate fieldname. So this shim only does bindFields.
    bindFields(true);
    bookmarkSize = 4;
    _bufOpen = true;
  }

  @override
  void internalClose() {
    _bufOpen = false;
    _records.clear();
    _cursorIndex = -1;
    _pendingUpdates.clear();
    _changeCount = 0;
    // @@@ Symmetric with internalOpen: field creation/destruction is owned by the descendant
    // @@@ (TCustomSQLQuery); this shim only unbinds.
    bindFields(false);
  }

  @override
  void internalInitFieldDefs() {
    // descendant（TCustomSQLQuery）override
    throw EDatabaseError(
        "AbstractError: TCustomBufDataset.InternalInitFieldDefs");
  }

  // Fetches one row from the underlying source into _records when needed
  bool _fetchOne() {
    if (_allPacketsFetched) return false;
    if (!fetch()) {
      _allPacketsFetched = true;
      return false;
    }
    final rec = TRecordBuffer();
    for (var i = 0; i < fieldDefs.count; i++) {
      final fd = fieldDefs[i];
      final buf = TValueBuffer();
      final createBlob = TBoolRef(false);
      if (loadField(fd, buf, createBlob)) {
        if (createBlob.value) {
          final bb = TBufBlobField();
          loadBlobIntoBuffer(fd, bb);
          rec.fieldData[fd.name.toUpperCase()] =
              bb.blobBuffer?.buffer ?? Uint8List(0);
        } else {
          rec.fieldData[fd.name.toUpperCase()] = buf.value;
        }
      } else {
        rec.fieldData[fd.name.toUpperCase()] = null; // NULL
      }
    }
    _records.add(rec);
    return true;
  }

  @override
  TGetResult getRecord(TRecordBuffer buffer, TGetMode getMode, bool doCheck) {
    switch (getMode) {
      case TGetMode.gmCurrent:
        if (_cursorIndex < 0 || _cursorIndex >= _records.length) {
          return TGetResult.grError;
        }
        break;
      case TGetMode.gmNext:
        if (_cursorIndex + 1 >= _records.length && !_fetchOne()) {
          return TGetResult.grEOF;
        }
        _cursorIndex++;
        break;
      case TGetMode.gmPrior:
        if (_cursorIndex <= 0) return TGetResult.grBOF;
        _cursorIndex--;
        break;
    }
    final src = _records[_cursorIndex];
    buffer.fieldData
      ..clear()
      ..addAll(src.fieldData);
    buffer.bookmarkData = _indexToBookmark(_cursorIndex);
    buffer.bookmarkFlag = TBookmarkFlag.bfCurrent;
    buffer.tag = _cursorIndex;
    getCalcFields(buffer);
    return TGetResult.grOK;
  }

  Uint8List _indexToBookmark(int index) {
    final b = ByteData(4);
    b.setInt32(0, index, Endian.little);
    return b.buffer.asUint8List();
  }

  int _bookmarkToIndex(Uint8List bm) =>
      ByteData.sublistView(bm).getInt32(0, Endian.little);

  @override
  void internalFirst() {
    _cursorIndex = -1;
  }

  @override
  void internalLast() {
    while (_fetchOne()) {}
    _cursorIndex = _records.length;
  }

  @override
  void internalSetToRecord(TRecordBuffer buffer) {
    if (buffer.tag is int) {
      _cursorIndex = buffer.tag as int;
    } else if (buffer.bookmarkData != null) {
      _cursorIndex = _bookmarkToIndex(buffer.bookmarkData!);
    }
  }

  @override
  void internalGotoBookmark(dynamic aBookmark) {
    if (aBookmark is Uint8List) {
      _cursorIndex = _bookmarkToIndex(aBookmark);
    } else if (aBookmark is int) {
      _cursorIndex = aBookmark;
    }
  }

  @override
  void getBookmarkData(TRecordBuffer buffer, TValueBuffer data) {
    data.value = buffer.bookmarkData;
  }

  @override
  TBookmarkFlag getBookmarkFlag(TRecordBuffer buffer) => buffer.bookmarkFlag;

  @override
  void setBookmarkFlag(TRecordBuffer buffer, TBookmarkFlag value) {
    buffer.bookmarkFlag = value;
  }

  @override
  void setBookmarkData(TRecordBuffer buffer, dynamic data) {
    if (data is Uint8List) {
      buffer.bookmarkData = data;
    } else if (data == null) {
      buffer.bookmarkData = null;
    }
  }

  @override
  bool bookmarkValid(TBookmark? aBookmark) {
    if (aBookmark == null || aBookmark.length < 4) return false;
    final idx = _bookmarkToIndex(aBookmark);
    return idx >= 0 && idx < _records.length;
  }

  @override
  int compareBookmarks(TBookmark? bookmark1, TBookmark? bookmark2) {
    if (bookmark1 == null || bookmark2 == null) return 0;
    return _bookmarkToIndex(bookmark1) - _bookmarkToIndex(bookmark2);
  }

  @override
  bool getFieldDataNative(TField field, TValueBuffer? buffer) {
    final TRecordBuffer? rec;
    switch (state) {
      case TDataSetState.dsCalcFields:
        rec = calcBuffer;
        break;
      case TDataSetState.dsOldValue:
        rec = _oldValueBuffer ?? activeBuffer();
        break;
      default:
        rec = activeBuffer();
    }
    if (rec == null) return false;
    final key = field.fieldName.toUpperCase();
    final dynamic v;
    if (field.fieldKind == TFieldKind.fkCalculated ||
        field.fieldKind == TFieldKind.fkLookup) {
      if (!rec.calcData.containsKey(key)) return false;
      v = rec.calcData[key];
    } else {
      if (!rec.fieldData.containsKey(key)) return false;
      v = rec.fieldData[key];
    }
    if (v == null) return false;
    if (buffer != null) buffer.value = v;
    return true;
  }

  TRecordBuffer? _oldValueBuffer;

  @override
  void setFieldDataNative(TField field, TValueBuffer? buffer) {
    if (!dsWriteModes.contains(state)) {
      databaseErrorFmt(SNotEditing, [name], this);
    }
    final rec = state == TDataSetState.dsCalcFields ? calcBuffer : activeBuffer();
    if (rec == null) return;
    final key = field.fieldName.toUpperCase();
    if (field.fieldKind == TFieldKind.fkCalculated ||
        field.fieldKind == TFieldKind.fkLookup) {
      rec.calcData[key] = buffer?.value;
    } else {
      rec.fieldData[key] = buffer?.value;
    }
    // The tail of bufdataset's SetFieldData: only broadcasts outside of the calculated/filter/NewValue states
    const silentStates = {
      TDataSetState.dsCalcFields,
      TDataSetState.dsFilter,
      TDataSetState.dsNewValue,
    };
    if (!silentStates.contains(state)) {
      dataEvent(TDataEvent.deFieldChange, field);
    }
  }

  @override
  void internalEdit() {
    final rec = activeBuffer();
    if (rec != null) {
      _oldValueBuffer = TRecordBuffer()
        ..fieldData.addAll(rec.fieldData);
    }
  }

  @override
  void internalCancel() {
    final rec = activeBuffer();
    if (state == TDataSetState.dsEdit &&
        rec != null &&
        _oldValueBuffer != null) {
      rec.fieldData
        ..clear()
        ..addAll(_oldValueBuffer!.fieldData);
    }
    _oldValueBuffer = null;
  }

  @override
  void internalInitRecord(TRecordBuffer buffer) {
    buffer.fieldData.clear();
    buffer.calcData.clear();
    for (var i = 0; i < fieldDefs.count; i++) {
      buffer.fieldData[fieldDefs[i].name.toUpperCase()] = null;
    }
    buffer.tag = null;
  }

  @override
  void internalPost() {
    super.internalPost(); // CheckRequiredFields
    final rec = activeBuffer();
    if (rec == null) return;
    if (state == TDataSetState.dsInsert) {
      // Insertion point: at the current cursor position (a minimal analogue of bookmark semantics)
      var at = _cursorIndex + 1;
      if (rec.bookmarkFlag == TBookmarkFlag.bfEOF || at > _records.length) {
        at = _records.length;
      }
      if (at < 0) at = 0;
      final stored = TRecordBuffer()..fieldData.addAll(rec.fieldData);
      _records.insert(at, stored);
      _cursorIndex = at;
      _pendingUpdates.add(
          _PendingUpdate(TUpdateKind.ukInsert, {}, Map.of(rec.fieldData)));
    } else {
      if (_cursorIndex >= 0 && _cursorIndex < _records.length) {
        _records[_cursorIndex].fieldData
          ..clear()
          ..addAll(rec.fieldData);
      }
      _pendingUpdates.add(_PendingUpdate(
          TUpdateKind.ukModify,
          Map.of(_oldValueBuffer?.fieldData ?? {}),
          Map.of(rec.fieldData)));
    }
    _changeCount = _pendingUpdates.length;
    _oldValueBuffer = null;
  }

  @override
  void internalDelete() {
    if (_cursorIndex >= 0 && _cursorIndex < _records.length) {
      final removed = _records.removeAt(_cursorIndex);
      _pendingUpdates.add(_PendingUpdate(
          TUpdateKind.ukDelete, Map.of(removed.fieldData), {}));
      _changeCount = _pendingUpdates.length;
      if (_cursorIndex >= _records.length) {
        _cursorIndex = _records.length - 1;
      }
    }
  }

  @override
  int getRecordCountInternal() => _records.length;

  @override
  int getRecNo() {
    if (state == TDataSetState.dsInactive) return 0;
    final rec = activeBuffer();
    if (rec?.tag is int) return (rec!.tag as int) + 1;
    return _cursorIndex + 1;
  }

  @override
  TUpdateStatus updateStatus() {
    if (_applyingUpdate != null) {
      switch (_applyingUpdate!.kind) {
        case TUpdateKind.ukInsert:
          return TUpdateStatus.usInserted;
        case TUpdateKind.ukModify:
          return TUpdateStatus.usModified;
        case TUpdateKind.ukDelete:
          return TUpdateStatus.usDeleted;
      }
    }
    return TUpdateStatus.usUnmodified;
  }

  // A snapshot of the record being updated (used by TSQLConnection to build the WHERE clause via OldValue)
  Map<String, dynamic> get applyingOldValues =>
      _applyingUpdate?.oldValues ?? const {};
  Map<String, dynamic> get applyingNewValues =>
      _applyingUpdate?.newValues ?? const {};

  @override
  bool locate(String keyFields, dynamic keyValues, TLocateOptions options) {
    checkBrowseMode();
    // A minimal locate (the real implementation uses indexes): linear scan of _records
    final names = keyFields.split(";").map((s) => s.trim()).toList();
    final values = keyValues is List ? keyValues : [keyValues];
    // First makes sure everything is loaded
    while (_fetchOne()) {}
    for (var i = 0; i < _records.length; i++) {
      var match = true;
      for (var j = 0; j < names.length && match; j++) {
        final rowValue = _records[i].fieldData[names[j].toUpperCase()];
        final want = j < values.length ? values[j] : null;
        match = _valueMatches(rowValue, want, options);
      }
      if (match) {
        doBeforeScroll();
        internalGotoBookmark(i);
        resync({TResyncModeItem.rmExact, TResyncModeItem.rmCenter});
        doAfterScroll();
        return true;
      }
    }
    return false;
  }

  bool _valueMatches(dynamic rowValue, dynamic want, TLocateOptions options) {
    if (rowValue == null || want == null) return rowValue == want;
    if (rowValue is String && want is String) {
      var a = rowValue, b = want;
      if (options.contains(TLocateOption.loCaseInsensitive)) {
        a = a.toUpperCase();
        b = b.toUpperCase();
      }
      if (options.contains(TLocateOption.loPartialKey)) {
        return a.startsWith(b);
      }
      return a == b;
    }
    if (rowValue is num && want is num) return rowValue == want;
    return '$rowValue' == '$want';
  }

  @override
  dynamic lookup(String keyFields, dynamic keyValues, String resultFields) {
    final bm = getBookmark();
    disableControls();
    try {
      if (locate(keyFields, keyValues, {})) {
        return fieldValues(resultFields);
      }
      return null;
    } finally {
      if (bm != null && bookmarkValid(bm)) gotoBookmark(bm);
      enableControls();
    }
  }

  @override
  TStream? createBlobStream(TField field, TBlobStreamMode mode) {
    if (mode == TBlobStreamMode.bmRead) {
      final buf = TValueBuffer();
      if (!getFieldData(field, buf)) return null;
      final v = buf.value;
      final ms = TMemoryStream();
      if (v is Uint8List) {
        ms.loadFromBytes(v);
      } else if (v is String) {
        ms.loadFromBytes(v.codeUnits);
      }
      return ms;
    } else {
      // Write mode: returns the stream attached to the field value (already in fieldData once Post happens)
      final ms = _WriteBackMemoryStream(this, field);
      return ms;
    }
  }
}

// Writing back a blob stream: closing semantics are handled by the GC; writes reflect into the field value immediately
class _WriteBackMemoryStream extends TMemoryStream {
  final TCustomBufDataset _ds;
  final TField _field;
  _WriteBackMemoryStream(this._ds, this._field);

  @override
  int write(List<int> buffer, int count) {
    final result = super.write(buffer, count);
    _ds.setFieldData(_field, TValueBuffer(bytes));
    if (_field is TBlobField) (_field as TBlobField).modified = true;
    return result;
  }
}

// The sqldb-specific factory typedef counterpart for TFieldDefsClass / TParamClass
// (bufdataset declares FieldDefsClass as a class function, convention 2 →
// lazarus_db.dart's TDataSet.fieldDefsClass() virtual factory method)
typedef TFieldDefsClass = TFieldDefs Function(TDataSet? aDataSet);

// zz !!! not fully translated

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 1 —— sqldb.pp body: interface constants + global helpers (L26-874)
// ═════════════════════════════════════════════════════════════════════════════

// StatementTokens : Array[TStatementType] of string（L33-37）
const List<String> statementTokens = [
  '(unknown)', "select", "insert", "update", "delete",
  "create", "get", "put", "execute",
  "start", "commit", "rollback", "?",
];

// TSchemaObjectNames : array[TSchemaType] of String（L38-40）
const List<String> tSchemaObjectNames = [
  '???', "table_name", "???", "procedure_name", "column_name",
  "param_name", "index_name", "package_name", "schema_name", "sequence",
];

// SingleQuotes / DoubleQuotes（L41-42）
const TQuoteChars singleQuotes = ["'", "'"];
const TQuoteChars doubleQuotes = ['"', '"'];
// @@@ MariaDB/MySQL quotes field names with backticks (not the standard SQL double quotes).
const TQuoteChars backtickQuotes = ['`', "`"];

// LogAllEvents / LogAllEventsExtra（L43-44）
const TDBEventTypes logAllEvents = {
  TDBEventType.detCustom,
  TDBEventType.detPrepare,
  TDBEventType.detExecute,
  TDBEventType.detFetch,
  TDBEventType.detCommit,
  TDBEventType.detRollBack,
};

const TDBEventTypes logAllEventsExtra = {
  TDBEventType.detCustom,
  TDBEventType.detPrepare,
  TDBEventType.detExecute,
  TDBEventType.detFetch,
  TDBEventType.detCommit,
  TDBEventType.detRollBack,
  TDBEventType.detParamValue,
  TDBEventType.detActualSQL,
};

const String defaultMacroChar = '%'; // DefaultMacroChar（L81）

// TRowsCount = LargeInt（L83）
typedef TRowsCount = int;

// TSQLStatementInfo（L85-91）
class TSQLStatementInfo {
  TStatementType statementType = TStatementType.stUnknown;
  String tableName = '';
  bool updateable = false;
  int whereStartPos = 0;
  int whereStopPos = 0;
}

// A subset of TFormatSettings (DefaultSQLFormatSettings, L832-853):
// only keeps the fields sqldb.pp actually uses
class TFormatSettings {
  String decimalSeparator = '.';
  String dateSeparator = '-';
  String timeSeparator = ':';
  String shortDateFormat = 'yyyy-mm-dd';
  String shortTimeFormat = 'hh:nn:ss';
  String longTimeFormat = 'hh:nn:ss.zzz';
}

TFormatSettings defaultSQLFormatSettings() => TFormatSettings();

// The sqldb version of FormatDateTime (supports zzz milliseconds; FormatSettings only affects
// the separator character, the format string already includes it)
String _formatDateTimeFS(String fmt, DateTime dt) {
  String p2(int v) => v.toString().padLeft(2, "0");
  return fmt
      .replaceAll("yyyy", dt.year.toString().padLeft(4, "0"))
      .replaceAll("mm", p2(dt.month))
      .replaceAll("dd", p2(dt.day))
      .replaceAll("hh", p2(dt.hour))
      .replaceAll("nn", p2(dt.minute))
      .replaceAll("ss", p2(dt.second))
      .replaceAll("zzz", dt.millisecond.toString().padLeft(3, "0"));
}

// QuotedStr（SysUtils）
String quotedStr(String s) {
  final escaped = s.replaceAll("'", "''");
  return "'$escaped'";
}

// CP_NONE（system unit）
const int cpNONE = 0xFFFF;

// CodePageNameToCodePage shim: only recognizes the utf-8 family, everything else returns CP_NONE
int _codePageNameToCodePage(String name) {
  switch (name) {
    case 'utf8':
    case 'utf-8':
      return cpUTF8;
    default:
      return cpNONE;
  }
}

// RefreshFlags : Array[ukModify..ukInsert] of TProviderFlag（L861）
// Indexed by TUpdateKind, with only two entries: ukModify/ukInsert
TProviderFlag _refreshFlags(TUpdateKind kind) =>
    kind == TUpdateKind.ukModify
        ? TProviderFlag.pfRefreshOnUpdate
        : TProviderFlag.pfRefreshOnInsert;

// TimeIntervalToString (L864-874): a time interval (hours can be >24)
String timeIntervalToString(DateTime time) {
  final days = DateTime(time.year, time.month, time.day)
      .difference(pascalZeroDateTime)
      .inDays;
  final hour = time.hour + days * 24;
  String p2(int v) => v.toString().padLeft(2, "0");
  return '${hour.toString().padLeft(2, '0')}:${p2(time.minute)}:'
      '${p2(time.second)}.${time.millisecond.toString().padLeft(3, '0')}';
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 2 —— TSQLHandle / TSQLCursor / ESQLDatabaseError /
//               TSQLDBFieldDef(s) / TSQLDBParam(s) (declaration L100-157,
//               implementation L877-914)
// ═════════════════════════════════════════════════════════════════════════════

class TSQLHandle {}

// TSQLCursor (L105-113): the fields are public (as in the original source)
class TSQLCursor extends TSQLHandle {
  bool fDirect = false;
  bool fPrepared = false;
  bool fSelectable = false;
  bool fInitFieldDef = false;
  TStatementType fStatementType = TStatementType.stUnknown;
  TSchemaType fSchemaType = TSchemaType.stNoSchema;
}

// ESQLDatabaseError (L117-123, implementation L895-914)
class ESQLDatabaseError extends EDatabaseError {
  final int errorCode;
  final String sqlState;

  // constructor CreateFmt(Fmt, Args, Comp, AErrorCode, ASQLState)
  ESQLDatabaseError.createFmt(String fmt, List<dynamic> args,
      TComponent? comp, int aErrorCode, String aSQLState)
      : errorCode = aErrorCode,
        sqlState = aSQLState,
        super(_buildMsg(fmt, args, comp));

  static String _buildMsg(String fmt, List<dynamic> args, TComponent? comp) {
    String msg;
    if (comp == null) {
      msg = fmt;
    } else if (comp.name == '') {
      msg = '${comp.runtimeType} : $fmt';
    } else {
      msg = '${comp.name} : $fmt';
    }
    return args.isEmpty ? msg : formatMsg(msg, args);
  }
}

// TSQLDBFieldDef (L127-132): SQLDBData is a pointer freely attached by the driver side → dynamic
class TSQLDBFieldDef extends TFieldDef {
  dynamic sqldbData;
  TSQLDBFieldDef(TCollection? aCollection) : super(aCollection);
  TSQLDBFieldDef.named(TFieldDefs aOwner, String aName, TFieldType aDataType,
      int aSize, bool aRequired, int aFieldNo,
      [TSystemCodePage aCodePage = cpACP])
      : super.named(aOwner, aName, aDataType, aSize, aRequired, aFieldNo,
            aCodePage);
}

// TSQLDBFieldDefs (L136-139, implementation L879-882):
// class function FieldDefClass → overriding the virtual factory method (convention 2)
class TSQLDBFieldDefs extends TFieldDefs {
  TSQLDBFieldDefs(TDataSet? aDataSet) : super(aDataSet);

  @override
  TFieldDef fieldDefClass(TFieldDefs aOwner, String aName,
      TFieldType aDataType, int aSize, bool aRequired, int aFieldNo,
      [TSystemCodePage aCodePage = cpACP]) {
    return TSQLDBFieldDef.named(
        aOwner, aName, aDataType, aSize, aRequired, aFieldNo, aCodePage);
  }
}

// TSQLDBParam（L143-150）
class TSQLDBParam extends TParam {
  TFieldDef? fieldDef;
  dynamic sqldbData;
  TSQLDBParam(TCollection? aCollection) : super(aCollection);
}

// TSQLDBParams (L154-157, implementation L887-890)
class TSQLDBParams extends TParams {
  TSQLDBParams([TPersistent? aOwner])
      : super.withItemClass(aOwner, (c) => TSQLDBParam(c));
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 3 —— TCustomSQLStatement / TSQLStatement
//  Declaration: L360-442; implementation: L919-1359
// ═════════════════════════════════════════════════════════════════════════════

class TCustomSQLStatement extends TComponent {
  TSQLCursor? _cursor;
  TSQLConnection? _database;
  bool paramCheck = true;
  late TParams _params;
  bool _macroCheck = false;
  String _macroChar = defaultMacroChar;
  late TParams _macros;
  late TStrings _sql;
  String _origSQL = '';
  String _serverSQL = '';
  TSQLTransaction? _transaction;
  bool parseSQL = true;
  bool _doUnPrepare = false;
  TDataLink? _dataLink;
  TRowsCount _rowsAffected = -1;

  // constructor Create（L1135-1147）
  TCustomSQLStatement([TComponent? aOwner]) : super(aOwner) {
    _sql = TStringList();
    _sql.onChange = onChangeSQL;
    _params = createParams();
    paramCheck = true;
    _macros = createParams();
    _macroChar = defaultMacroChar;
    _macroCheck = false;
    parseSQL = true;
    _rowsAffected = -1;
  }

  // destructor Destroy（L1149-1160）
  @override
  void destroy() {
    unprepare();
    transaction = null;
    database = null;
    dataSource = null;
    _dataLink = null;
    super.destroy();
  }

  // OnChangeSQL（L919-942）
  void onChangeSQL(Object sender) {
    unprepare();
    recreateMacros();
    if (!paramCheck) return;
    TConnOptions connOptions;
    if (_database != null) {
      connOptions = _database!.connOptions;
    } else {
      connOptions = {TConnOption.sqEscapeRepeat, TConnOption.sqEscapeSlash};
    }
    final newParams = createParams();
    newParams.parseSQL(_sql.text, true,
        escapeSlash: connOptions.contains(TConnOption.sqEscapeSlash),
        escapeRepeat: connOptions.contains(TConnOption.sqEscapeRepeat),
        parameterStyle: TParamStyle.psInterbase);
    newParams.assignValues(_params);
    _params.assign(newParams);
  }

  // SetDatabase（L944-962）
  TSQLConnection? get database => _database;
  set database(TSQLConnection? aValue) {
    if (identical(_database, aValue)) return;
    unprepare();
    if (_database != null) {
      _database!.unRegisterStatement(this);
      _database!.removeFreeNotification(this);
    }
    _database = aValue;
    if (_database != null) {
      _database!.freeNotification(this);
      _database!.registerStatement(this);
      if (_database!.transaction != null &&
          (transaction == null ||
              !identical(transaction!.database, _database))) {
        transaction = _database!.transaction;
      }
      onChangeSQL(this);
    }
  }

  // SetMacroChar（L964-969）
  String get macroChar => _macroChar;
  set macroChar(String aValue) {
    if (_macroChar == aValue) return;
    _macroChar = aValue;
    recreateMacros();
  }

  // SetMacroCheck（L971-976）
  bool get macroCheck => _macroCheck;
  set macroCheck(bool aValue) {
    if (_macroCheck == aValue) return;
    _macroCheck = aValue;
    recreateMacros();
  }

  // SetTransaction（L978-991）
  TSQLTransaction? get transaction => _transaction;
  set transaction(TSQLTransaction? aValue) {
    if (identical(_transaction, aValue)) return;
    unprepare();
    if (_transaction != null) {
      _transaction!.removeFreeNotification(this);
    }
    _transaction = aValue;
    if (_transaction != null) {
      _transaction!.freeNotification(this);
      if (_transaction!.database != null &&
          !identical(database, _transaction!.database)) {
        database = _transaction!.database as TSQLConnection;
      }
    }
  }

  // RecreateMacros（L993-1021）
  void recreateMacros() {
    if (macroCheck) {
      TConnOptions connOptions;
      if (_database != null) {
        connOptions = _database!.connOptions;
      } else {
        connOptions = {TConnOption.sqEscapeRepeat, TConnOption.sqEscapeSlash};
      }
      final newParams = createParams();
      final po = <TSQLParseOption>{
        TSQLParseOption.spoCreate,
        TSQLParseOption.spoUseMacro
      };
      if (connOptions.contains(TConnOption.sqEscapeSlash)) {
        po.add(TSQLParseOption.spoEscapeSlash);
      }
      if (connOptions.contains(TConnOption.sqEscapeRepeat)) {
        po.add(TSQLParseOption.spoEscapeRepeat);
      }
      final pb = <int>[];
      final rs = TStringRef("");
      newParams.doParseSQL(
          _sql.text, po, TParamStyle.psInterbase, pb, macroChar, rs);
      newParams.assignValues(_macros);
      _macros.assign(newParams);
    }
  }

  // SetDataSource（L1023-1030）
  TDataSource? get dataSource => _dataLink?.dataSource;
  set dataSource(TDataSource? aValue) {
    if (identical(dataSource, aValue)) return;
    _dataLink ??= createDataLink();
    _dataLink!.dataSource = aValue;
  }

  // CopyParamsFromMaster（L1032-1036）
  void copyParamsFromMaster(bool copyBound) {
    if (dataSource != null && dataSource!.dataSet != null) {
      _params.copyParamValuesFromDataset(dataSource!.dataSet, copyBound);
    }
  }

  // SetParams（L1038-1042）
  TParams get params => _params;
  set params(TParams aValue) {
    if (identical(_params, aValue)) return;
    _params.assign(aValue);
  }

  // SetMacros（L1044-1048）
  TParams get macros => _macros;
  set macros(TParams aValue) {
    if (identical(_macros, aValue)) return;
    _macros.assign(aValue);
  }

  // SetSQL（L1050-1055）
  TStrings get sql => _sql;
  set sql(TStrings aValue) {
    if (identical(_sql, aValue)) return;
    _sql.assign(aValue);
    recreateMacros();
  }

  // DoExecute（L1057-1065）
  void doExecute() {
    _rowsAffected = -1;
    if (_params.count > 0 && dataSource != null) {
      copyParamsFromMaster(false);
    }
    if (logEvent(TDBEventType.detExecute)) {
      log(TDBEventType.detExecute, _serverSQL);
    }
    database!.execute(_cursor!, transaction, _params);
  }

  // GetPrepared（L1067-1071）
  bool get prepared =>
      _cursor != null && (_cursor!.fPrepared || _cursor!.fDirect);

  // CheckUnprepare（L1073-1080）
  void checkUnprepare() {
    if (_doUnPrepare) {
      unprepare();
      _doUnPrepare = false;
    }
  }

  // CheckPrepare（L1082-1089）
  void checkPrepare() {
    if (!prepared) {
      _doUnPrepare = true;
      prepare();
    }
  }

  // CreateDataLink（L1091-1094）
  TDataLink createDataLink() => TDataLink();

  // CreateParams（L1096-1099）
  TSQLDBParams createParams() => TSQLDBParams(null);

  // LogEvent（L1101-1104）
  bool logEvent(TDBEventType eventType) =>
      _database != null && _database!.logEvent(eventType);

  // Log（L1106-1119）
  void log(TDBEventType eventType, String msg) {
    if (logEvent(eventType)) {
      String m;
      if (name != '') {
        m = name;
      } else {
        m = runtimeType.toString();
      }
      _database!.log(eventType, "$m : $msg");
    }
  }

  // Notification（L1121-1133）
  @override
  void notification(TComponent aComponent, TOperation operation) {
    super.notification(aComponent, operation);
    if (operation == TOperation.opRemove) {
      if (identical(aComponent, _transaction)) {
        _transaction = null;
      } else if (identical(aComponent, _database)) {
        unprepare();
        _database = null;
      }
    }
  }

  // GetSchemaType / GetSchemaObjectName / GetSchemaPattern（L1162-1176）
  TSchemaType getSchemaType() => TSchemaType.stNoSchema;
  String getSchemaObjectName() => '';
  String getSchemaPattern() => '';

  // IsSelectable（L1178-1181）
  bool isSelectable() => false;

  // GetStatementInfo (L1183-1187): out Info → return value
  TSQLStatementInfo getStatementInfo(TStringRef aSQL) {
    return database!.getStatementInfo(aSQL.value);
  }

  // AllocateCursor（L1189-1195）
  void allocateCursor() {
    // Do this as late as possible. (original comment kept as-is)
    _cursor ??= database!.allocateCursorHandle();
  }

  // DeAllocateCursor（L1197-1201）
  void deAllocateCursor() {
    if (_cursor != null && _database != null) {
      _database!.deAllocateCursorHandle(_cursor!);
      _cursor = null; // a var parameter would be set to nil by DeAllocateCursorHandle
    }
  }

  // ExpandMacros（L1203-1260）
  String expandMacros(String origSQL) {
    var result = origSQL;
    if (!macroCheck) return result;
    // Terminators = SQLDelimiterCharacters + [#0,'=','+','-','*','\','/','[',']','|']
    final termArr = <String>{
      ...sqlDelimiterCharacters,
      "=", "+", "-", "*", "\\", "/", "[", "]", "|",
      macroChar,
    };
    result = '';
    var macroFlag = false;
    var tempMacroName = '';

    void substituteMacro() {
      final param = macros.findParam(tempMacroName);
      if (param != null) {
        result = result + param.asString;
      } else {
        result = '$result$macroChar$tempMacroName';
      }
      tempMacroName = '';
    }

    for (var i = 0; i < origSQL.length; i++) {
      final ch = origSQL[i];
      if (!macroFlag && ch == macroChar) {
        macroFlag = true;
        tempMacroName = '';
      } else if (macroFlag) {
        if (!termArr.contains(ch)) {
          tempMacroName = tempMacroName + ch;
        } else {
          substituteMacro();
          if (ch != macroChar) {
            macroFlag = false;
          }
          tempMacroName = '';
        }
      }
      if (!macroFlag) {
        result = result + ch;
      }
    }
    if (tempMacroName != '') {
      substituteMacro();
    }
    return result;
  }

  // DoPrepare（L1262-1284）
  void doPrepare() {
    if (getSchemaType() == TSchemaType.stNoSchema) {
      _origSQL = _sql.text.trimRight();
    } else {
      _origSQL = database!.getSchemaInfoSQL(
          getSchemaType(), getSchemaObjectName(), getSchemaPattern());
    }
    if (_origSQL == '') {
      databaseError(SErrNoStatement);
    }
    _serverSQL = expandMacros(_origSQL);
    final sqlRef = TStringRef(_serverSQL);
    final stmInfo = getStatementInfo(sqlRef);
    _serverSQL = sqlRef.value;
    allocateCursor();
    _cursor!.fSelectable = true; // let PrepareStatement and/or Execute
    // alter it (original comment kept as-is)
    _cursor!.fStatementType = stmInfo.statementType;
    _cursor!.fSchemaType = getSchemaType();
    if (logEvent(TDBEventType.detPrepare)) {
      log(TDBEventType.detPrepare, _serverSQL);
    }
    database!.prepareStatement(_cursor!, transaction, _serverSQL, _params);
    // Update (original comment kept as-is)
    _cursor!.fInitFieldDef = _cursor!.fSelectable;
  }

  // Prepare（L1286-1304）
  void prepare() {
    if (prepared) return;
    if (_database == null) {
      databaseError(SErrDatabasenAssigned);
    }
    if (_transaction == null) {
      databaseError(SErrTransactionnSet);
    }
    database!.maybeConnect();
    if (!transaction!.active) {
      transaction!.maybeStartTransaction();
    }
    try {
      doPrepare();
    } catch (_) {
      deAllocateCursor();
      rethrow;
    }
  }

  // Execute（L1306-1314）
  void execute() {
    checkPrepare();
    try {
      doExecute();
    } finally {
      checkUnprepare();
    }
  }

  // DoUnPrepare（L1316-1327）
  void doUnPrepare() {
    if (_cursor != null) {
      if (_database != null) {
        _database!.unPrepareStatement(_cursor!);
        deAllocateCursor();
      } else {
        // this should never happen. It means a cursor handle leaks in
        // the DB itself. (original comment kept as-is)
        _cursor = null;
      }
    }
  }

  // Unprepare（L1337-1344）
  void unprepare() {
    // Some SQLConnections does not support statement [un]preparation,
    // but they have allocated local cursor(s) so let them do cleanup
    // f.e. cancel pending queries and/or free resultset and also do
    // UnRegisterStatement! (original comment kept as-is)
    if (_cursor != null) {
      doUnPrepare();
    }
  }

  // ParamByName（L1346-1349）
  TParam paramByName(String aParamName) => _params.paramByName(aParamName);

  // RowsAffected（L1351-1359）
  TRowsCount rowsAffected() {
    if (_rowsAffected == -1) {
      if (_database != null) {
        _rowsAffected = _database!.rowsAffected(_cursor);
      }
    }
    return _rowsAffected;
  }

  TSQLCursor? get cursor => _cursor;
}

// TSQLStatement (L431-442): just re-exposes published properties; Dart has no
// published concept, so it inherits directly
class TSQLStatement extends TCustomSQLStatement {
  TSQLStatement([TComponent? aOwner]) : super(aOwner);
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 4 —— TSQLConnection
//  Declaration: L185-311; implementation: L1364-2327
// ═════════════════════════════════════════════════════════════════════════════

// Event/option types (L175-183)
typedef TDBLogNotifyEvent = void Function(
    TSQLConnection sender, TDBEventType eventType, String msg);

enum TConnOption {
  sqSupportParams,
  sqSupportEmptyDatabaseName,
  sqEscapeSlash,
  sqEscapeRepeat,
  sqImplicitTransaction,
  sqLastInsertID,
  sqSupportReturning,
  sqSequences,
}

typedef TConnOptions = Set<TConnOption>;

enum TSQLConnectionOption { scoExplicitConnect, scoApplyUpdatesChecksRowsAffected }

typedef TSQLConnectionOptions = Set<TSQLConnectionOption>;

// TConnInfoType (starting from citAll=-1 —— Dart enums have no custom ordinals,
// citAll is placed first, indices are understood with a -1 offset; only used for == comparisons and range traversal)
enum TConnInfoType {
  citAll,
  citServerType,
  citServerVersion,
  citServerVersionString,
  citClientName,
  citClientVersion,
}

// The GlobalDBLogHook global variable (L824)
TDBLogNotifyEvent? globalDBLogHook;

class TSQLConnection extends TDatabase {
  TQuoteChars fieldNameQuoteChars = doubleQuotes;
  TSQLConnectionOptions _options = <TSQLConnectionOption>{};
  String password = '';
  TSQLTransaction? _sqlTransaction; // FTransaction (shadowing the concept of TDatabase's
  // transactions collection; the original source is also a standalone field here)
  String userName = '';
  String hostName = '';
  String charSet = '';
  TSystemCodePage _codePage = cpACP;
  String role = '';
  final List<TCustomSQLStatement> _statements = []; // TThreadList
  // (dupIgnore) → a List + contains check
  TDBEventTypes logEvents = logAllEvents;
  TDBLogNotifyEvent? onLog;

  TConnOptions connOptions = <TConnOption>{};
  TFormatSettings sqlFormatSettings = defaultSQLFormatSettings();

  // constructor Create（L1364-1372）
  TSQLConnection([TComponent? aOwner]) : super(aOwner) {
    sqlFormatSettings = defaultSQLFormatSettings();
    fieldNameQuoteChars = doubleQuotes;
    logEvents = logAllEvents; // match Property LogEvents...Default
  }

  // destructor Destroy（L1374-1379）
  @override
  void destroy() {
    connected = false; // needed because we want to de-allocate statements
    super.destroy();
  }

  // StrToStatementType (L1381-1389): traverses stSelect..stRollback
  TStatementType strToStatementType(String s) {
    final lower = s.toLowerCase();
    for (var i = TStatementType.stSelect.index;
        i <= TStatementType.stRollback.index;
        i++) {
      if (lower == statementTokens[i]) {
        return TStatementType.values[i];
      }
    }
    return TStatementType.stUnknown;
  }

  // SetTransaction（L1391-1403）
  TSQLTransaction? get transaction => _sqlTransaction;
  set transaction(TSQLTransaction? value) {
    if (!identical(_sqlTransaction, value)) {
      if (_sqlTransaction != null && _sqlTransaction!.active) {
        databaseError(SErrAssTransaction);
      }
      if (value != null) {
        value.database = this;
      }
      _sqlTransaction = value;
      if (_sqlTransaction != null && _sqlTransaction!.database == null) {
        _sqlTransaction!.database = this;
      }
    }
  }

  // UpdateIndexDefs（L1405-1408）
  void updateIndexDefsFor(TIndexDefs indexDefs, String tableName) {
    // Empty abstract (original comment kept as-is)
  }

  // DoConnect (L1410-1435): connection character set → CodePage mapping
  @override
  void doConnect() {
    super.doConnect();
    final connectionCharSet = getConnectionCharSet().toLowerCase();
    switch (connectionCharSet) {
      case 'utf8':
      case 'utf-8':
      case 'utf8mb4':
        _codePage = cpUTF8;
        break;
      case 'win1250':
      case 'cp1250':
        _codePage = 1250;
        break;
      case 'win1251':
      case 'cp1251':
        _codePage = 1251;
        break;
      case 'win1252':
      case 'cp1252':
      case 'latin1':
      case 'iso8859_1':
        _codePage = 1252;
        break;
      default:
        _codePage = _codePageNameToCodePage(connectionCharSet);
        if (_codePage == cpNONE) {
          _codePage = cpACP;
        }
    }
  }

  TSystemCodePage get codePage => _codePage;

  // DoInternalConnect（L1437-1441）
  @override
  void doInternalConnect() {
    if (databaseName == '' &&
        !connOptions.contains(TConnOption.sqSupportEmptyDatabaseName)) {
      databaseError(SErrNoDatabaseName, this);
    }
  }

  // DoInternalDisconnect（L1443-1458）
  @override
  void doInternalDisConnect() {
    for (final s in List<TCustomSQLStatement>.from(_statements)) {
      s.unprepare();
    }
    _statements.clear();
  }

  // StartTransaction（L1460-1466）
  @override
  void startTransaction() {
    if (_sqlTransaction == null) {
      databaseError(SErrConnTransactionnSet);
    } else {
      _sqlTransaction!.startTransaction();
    }
  }

  // EndTransaction（L1468-1474）
  @override
  void endTransaction() {
    if (_sqlTransaction == null) {
      databaseError(SErrConnTransactionnSet);
    } else {
      _sqlTransaction!.endTransaction();
    }
  }

  // ExecuteDirect's two overloads (L1476-1515) → optional parameters
  void executeDirect(String sql, [TSQLTransaction? aTransaction]) {
    final trans = aTransaction ?? _sqlTransaction;
    if (trans == null) {
      databaseError(SErrTransactionnSet);
    }
    if (!connected) openConnection();
    if (!trans!.active) trans.maybeStartTransaction();

    var s = sql.trimRight();
    if (s == '') {
      databaseError(SErrNoStatement);
    }

    TSQLCursor? cursor;
    try {
      cursor = allocateCursorHandle();
      cursor.fStatementType = TStatementType.stUnknown;
      if (logEvent(TDBEventType.detPrepare)) {
        log(TDBEventType.detPrepare, s);
      }
      prepareStatement(cursor, trans, s, null);
      try {
        if (logEvent(TDBEventType.detExecute)) {
          log(TDBEventType.detExecute, s);
        }
        execute(cursor, trans, null);
      } finally {
        unPrepareStatement(cursor);
      }
    } finally {
      if (cursor != null) deAllocateCursorHandle(cursor);
    }
  }

  // GetPort / SetPort (L1517-1535): name=value access into Params.Values['Port'] —
  // the TStrings shim has no Values indexer, so this expands it inline
  int get port {
    for (var i = 0; i < params.count; i++) {
      final line = params[i];
      if (line.toUpperCase().startsWith("PORT=")) {
        return int.tryParse(line.substring(5)) ?? 0;
      }
    }
    return 0;
  }

  set port(int aValue) {
    var idx = -1;
    for (var i = 0; i < params.count; i++) {
      if (params[i].toUpperCase().startsWith("PORT=")) {
        idx = i;
        break;
      }
    }
    if (aValue != 0) {
      if (idx >= 0) {
        params[idx] = 'Port=$aValue';
      } else {
        params.add("Port=$aValue");
      }
    } else if (idx > -1) {
      params.delete(idx);
    }
  }

  // SetOptions（L1522-1526）
  TSQLConnectionOptions get options => _options;
  set options(TSQLConnectionOptions aValue) {
    if (_options == aValue) return;
    _options = aValue;
  }

  // AttemptCommit / AttemptRollBack（L1537-1559）
  bool attemptCommit(TSQLHandle trans) {
    try {
      return commit(trans);
    } catch (_) {
      if (forcedClose) {
        return true;
      }
      rethrow;
    }
  }

  bool attemptRollBack(TSQLHandle trans) {
    try {
      return rollBack(trans);
    } catch (_) {
      if (forcedClose) {
        return true;
      }
      rethrow;
    }
  }

  // GetDBInfo（L1561-1588）
  void getDBInfo(TSchemaType aSchemaType, String aSchemaObjectName,
      String aReturnField, TStrings aList) {
    if (_sqlTransaction == null) {
      databaseError(SErrConnTransactionnSet);
    }
    final qry = TCustomSQLQuery(null);
    try {
      qry.transaction = _sqlTransaction;
      qry.database = this;
      qry.parseSQL = false;
      qry.setSchemaInfo(aSchemaType, aSchemaObjectName, "");
      qry.open();
      aList.clear();
      while (!qry.eof) {
        aList.add(qry.fieldByName(aReturnField).asString.trim());
        qry.next();
      }
    } finally {
      qry.free();
    }
  }

  // GetConnectionCharSet（L1590-1595）
  String getConnectionCharSet() => charSet.toLowerCase();

  // RowsAffected（L1597-1600）
  TRowsCount rowsAffected(TSQLCursor? cursor) => -1;

  // AddFieldDef (L1602-1620): a helper the driver side uses to build a FieldDef
  TFieldDef addFieldDef(TFieldDefs aFieldDefs, int aFieldNo, String aName,
      TFieldType aDataType, int aSize, int aPrecision, bool aByteSize,
      bool aRequired, bool aReadOnly) {
    TSystemCodePage aCodePage;
    var size = aSize;
    if (aDataType == TFieldType.ftString ||
        aDataType == TFieldType.ftFixedChar ||
        aDataType == TFieldType.ftMemo) {
      aCodePage = _codePage;
      // if ASize of character data is passed as "byte length", translate
      // it to "character length" as expected by TFieldDef (original comment kept as-is)
      if (aByteSize && aCodePage == cpUTF8) {
        size = size ~/ 4;
      }
    } else {
      aCodePage = 0;
    }
    return aFieldDefs.addFull(aName, aDataType, size, aPrecision, aRequired,
        aReadOnly, aFieldNo, aCodePage);
  }

  // GetTableNames / GetProcedureNames / GetFieldNames / GetSchemaNames /
  // GetSequenceNames（L1622-1648）
  void getTableNames(TStrings list, [bool systemTables = false]) {
    if (!systemTables) {
      getDBInfo(TSchemaType.stTables, "", "table_name", list);
    } else {
      getDBInfo(TSchemaType.stSysTables, "", "table_name", list);
    }
  }

  void getProcedureNames(TStrings list) {
    getDBInfo(TSchemaType.stProcedures, "", "procedure_name", list);
  }

  // No @override here: TSQLConnection extends TDatabase, not TDataSet —
  // this is the Pascal name collision noted below, not an actual override.
  void getFieldNames(covariant dynamic tableNameOrList,
      [TStrings? list]) {
    // The Pascal overload with a different signature than TDataSet.GetFieldNames (name collision) — this
    // is TSQLConnection's own (TableName, List) version
    getDBInfo(TSchemaType.stColumns, tableNameOrList as String,
        "column_name", list!);
  }

  void getSchemaNames(TStrings list) {
    getDBInfo(TSchemaType.stSchemata, "", "SCHEMA_NAME", list);
  }

  void getSequenceNames(TStrings list) {
    getDBInfo(TSchemaType.stSequences, "", "SEQUENCE_NAME", list);
  }

  // GetObjectNames（L1654-1688）
  int getObjectNames(TSchemaType aSchemaType, TSqlObjectIdentifierList aList) {
    var result = 0;
    if (_sqlTransaction == null) {
      databaseError(SErrConnTransactionnSet);
    }
    final qry = TCustomSQLQuery(null);
    try {
      qry.transaction = _sqlTransaction;
      qry.database = this;
      qry.parseSQL = false;
      qry.setSchemaInfo(
          aSchemaType, tSchemaObjectNames[aSchemaType.index], "");
      qry.open();
      final f =
          qry.findField(tSchemaObjectNames[TSchemaType.stSchemata.index]);
      while (!qry.eof) {
        var vSchemaName = '';
        if (f != null) {
          vSchemaName = f.asString;
        }
        final vObjectName = qry.fieldByName(qry._schemaObjectName).asString;
        aList.addIdentifier(vObjectName, vSchemaName);
        qry.next();
        result++;
      }
    } finally {
      qry.free();
    }
    return result;
  }

  // GetConnectionInfo（L1690-1700）
  String getConnectionInfo(TConnInfoType infoType) {
    var result = '';
    if (infoType == TConnInfoType.citAll) {
      for (var i = TConnInfoType.citServerType.index;
          i <= TConnInfoType.citClientVersion.index;
          i++) {
        if (result != '') result = '$result,';
        result =
            '$result"${getConnectionInfo(TConnInfoType.values[i])}"';
      }
    }
    return result;
  }

  // GetStatementInfo (L1702-1872): the SQL statement parser (statement type/table name/
  // WHERE range), PChar scanning → indices, branch-by-branch mapping
  TSQLStatementInfo getStatementInfo(String aSQL) {
    // TParsePart / TPhraseSeparator / TKeyword (local types)
    const ppStart = 0, ppWith = 1, ppSelect = 2, ppTableName = 3,
        ppFrom = 4, ppWhere = 5, ppBogus = 8;
    const sepNone = 0, sepWhiteSpace = 1, sepComma = 2, sepComment = 3,
        sepParentheses = 4, sepDoubleQuote = 5, sepEnd = 6;
    const keywordNames = [
      'WITH', "SELECT", "INSERT", "UPDATE", "DELETE", "FROM", "JOIN",
      "WHERE", "GROUP", "ORDER", "UNION", "ROWS", "LIMIT", ""
    ];
    const kwWITH = 0, kwSELECT = 1, kwINSERT = 2, kwUPDATE = 3,
        kwDELETE = 4, kwFROM = 5, kwJOIN = 6, kwWHERE = 7, kwGROUP = 8,
        kwORDER = 9, kwUNION = 10, kwROWS = 11, kwLIMIT = 12,
        kwUnknown = 13;

    final result = TSQLStatementInfo();
    var parsePart = ppStart;

    final len = aSQL.length;
    String charAt(int i) => i >= len ? '\x00' : aSQL[i];

    var currentP = -1;
    var phraseP = 0;
    var pStatementPart = 0;
    var breakLoop = false;

    do {
      currentP++;
      var savedP = currentP;
      int separator;

      final c = charAt(currentP);
      if (c == ' ' || (c.codeUnitAt(0) >= 9 && c.codeUnitAt(0) <= 13)) {
        separator = sepWhiteSpace;
      } else if (c == ',') {
        separator = sepComma;
      } else if (c == '\x00' || c == ';') {
        separator = sepEnd;
      } else if (c == '(') {
        separator = sepParentheses;
        // skip everything between brackets, since it could be a
        // sub-select, and further nothing between brackets could be
        // interesting for the parser. (original comment kept as-is)
        var bracketCount = 1;
        do {
          currentP++;
          if (charAt(currentP) == '(') {
            bracketCount++;
          } else if (charAt(currentP) == ')') {
            bracketCount--;
          }
        } while (charAt(currentP) != '\x00' && bracketCount != 0);
        if (charAt(currentP) != '\x00') currentP++;
      } else if (c == '"' || c == '`') {
        final p = TIntRef(currentP);
        if (skipComments(aSQL, p,
            connOptions.contains(TConnOption.sqEscapeSlash),
            connOptions.contains(TConnOption.sqEscapeRepeat))) {
          separator = sepDoubleQuote;
          currentP = p.value;
        } else {
          separator = sepNone;
        }
      } else {
        final p = TIntRef(currentP);
        if (skipComments(aSQL, p,
            connOptions.contains(TConnOption.sqEscapeSlash),
            connOptions.contains(TConnOption.sqEscapeRepeat))) {
          separator = sepComment;
          currentP = p.value;
        } else {
          separator = sepNone;
        }
      }

      if (separator != sepNone) {
        if (currentP > savedP && savedP > phraseP) {
          currentP = savedP; // there is something before comment or left
          // parenthesis or double quote (original comment kept as-is)
        }

        if ((separator == sepWhiteSpace || separator == sepComment) &&
            savedP == phraseP) {
          phraseP = currentP; // skip comments (but not parentheses) and
          // white spaces (original comment kept as-is)
        }

        if (currentP - phraseP > 0 || separator == sepEnd) {
          final s = aSQL.substring(
              phraseP, currentP > len ? len : currentP);

          var keyword = kwUnknown;
          for (var k = 0; k < keywordNames.length; k++) {
            if (s.toUpperCase() == keywordNames[k]) {
              keyword = k;
              break;
            }
          }

          switch (parsePart) {
            case ppStart:
              result.statementType = strToStatementType(s);
              if (keyword == kwWITH) {
                parsePart = ppWith;
              } else if (keyword == kwSELECT) {
                parsePart = ppSelect;
              } else {
                breakLoop = true;
              }
              break;
            case ppWith:
              // WITH [RECURSIVE] CTE_name [(column_names)] AS
              // (CTE_query_definition) [, ...]
              //  { SELECT | INSERT | UPDATE | DELETE } ... (original comment kept as-is)
              switch (keyword) {
                case kwSELECT:
                  result.statementType = TStatementType.stSelect;
                  break;
                case kwINSERT:
                  result.statementType = TStatementType.stInsert;
                  break;
                case kwUPDATE:
                  result.statementType = TStatementType.stUpdate;
                  break;
                case kwDELETE:
                  result.statementType = TStatementType.stDelete;
                  break;
              }
              if (result.statementType != TStatementType.stUnknown) {
                breakLoop = true;
              }
              break;
            case ppSelect:
              if (keyword == kwFROM) {
                parsePart = ppTableName;
              }
              break;
            case ppTableName:
              // Meta-data requests are never updateable and select
              // statements from more than one table and/or derived
              // tables are also not updateable (original comment kept as-is)
              if (separator == sepWhiteSpace ||
                  separator == sepComment ||
                  separator == sepDoubleQuote ||
                  separator == sepEnd) {
                result.tableName = result.tableName + s;
                result.updateable = true;
              }
              // compound delimited classifier like:
              // "schema name"."table name" (original comment kept as-is)
              final nc = charAt(currentP);
              if (nc != '.' && nc != '"') {
                parsePart = ppFrom;
              }
              break;
            case ppFrom:
              if ((keyword == kwWHERE ||
                      keyword == kwGROUP ||
                      keyword == kwORDER ||
                      keyword == kwLIMIT ||
                      keyword == kwROWS) ||
                  separator == sepEnd) {
                if (keyword == kwWHERE) {
                  parsePart = ppWhere;
                } else if (keyword == kwGROUP || keyword == kwORDER) {
                  parsePart = ppBogus;
                } else {
                  parsePart = ppBogus;
                }
                result.whereStartPos = phraseP + 1; // PhraseP-PSQL+1
                pStatementPart = currentP;
              } else if (keyword == kwJOIN ||
                  separator == sepComma ||
                  separator == sepParentheses) {
                // joined table or user_defined_function (...) (original comment kept as-is)
                result.tableName = '';
                result.updateable = false;
              }
              break;
            case ppWhere:
              if ((keyword == kwGROUP ||
                      keyword == kwORDER ||
                      keyword == kwLIMIT ||
                      keyword == kwROWS) ||
                  separator == sepEnd) {
                parsePart = ppBogus;
                result.whereStartPos = pStatementPart;
                if (separator == sepEnd) {
                  result.whereStopPos = currentP + 1;
                } else {
                  result.whereStopPos = phraseP + 1;
                }
              } else if (keyword == kwUNION) {
                parsePart = ppBogus;
                result.updateable = false;
              }
              break;
          }
        }
        if (separator == sepComment ||
            separator == sepParentheses ||
            separator == sepDoubleQuote) {
          currentP--;
        }
        phraseP = currentP + 1;
      }
    } while (!breakLoop && charAt(currentP) != '\x00');
    return result;
  }

  // GetAsString(Param) (L1874-1887): RawByteString/SetCodePage's
  // byte-level transcoding has no equivalent in a Dart String (convention 3), merged into asString
  String getParamAsString(TParam param) {
    return param.asAnsiString;
  }

  // GetAsSQLText(Field)（L1889-1900）
  String getAsSQLTextField(TField? field) {
    if (field == null || field.isNull) return 'Null';
    switch (field.dataType) {
      case TFieldType.ftString:
        return quotedStr(field.asString);
      case TFieldType.ftDate:
        return "'${_formatDateTimeFS('yyyy-mm-dd', field.asDateTime)}'";
      case TFieldType.ftDateTime:
        return "'${_formatDateTimeFS('yyyy-mm-dd hh:nn:ss.zzz', field.asDateTime)}'";
      case TFieldType.ftTime:
        return "'${timeIntervalToString(field.asDateTime)}'";
      default:
        return field.asString;
    }
  }

  // GetAsSQLText(Param)（L1902-1920）
  String getAsSQLTextParam(TParam? param) {
    if (param == null || param.isNull) return 'Null';
    switch (param.dataType) {
      case TFieldType.ftGuid:
      case TFieldType.ftMemo:
      case TFieldType.ftFixedChar:
      case TFieldType.ftString:
        return quotedStr(getParamAsString(param));
      case TFieldType.ftDate:
        return "'${_formatDateTimeFS('yyyy-mm-dd', param.asDateTime)}'";
      case TFieldType.ftTime:
        return "'${timeIntervalToString(param.asDateTime)}'";
      case TFieldType.ftDateTime:
        return "'${_formatDateTimeFS('yyyy-mm-dd hh:nn:ss.zzz', param.asDateTime)}'";
      case TFieldType.ftCurrency:
      case TFieldType.ftBCD:
        return '${param.asCurrency}';
      case TFieldType.ftFloat:
        return '${param.asFloat}';
      case TFieldType.ftFMTBcd:
        // StringReplace(AsString, '.', FS.DecimalSeparator) — the separator character
        // is '.' on both sides, so this is an equivalent rewrite
        return param.asString.replaceFirst(
            ".", sqlFormatSettings.decimalSeparator);
      default:
        return param.asString;
    }
  }

  // GetHandle（L1923-1926）
  dynamic getHandle() => null;
  dynamic get handle => getHandle();

  // LogEvent（L1928-1931）
  bool logEvent(TDBEventType eventType) {
    return (onLog != null || globalDBLogHook != null) &&
        logEvents.contains(eventType);
  }

  // LogParams（L1933-1952）
  void logParams(TParams? aParams) {
    if (!logEvent(TDBEventType.detParamValue) || aParams == null) return;
    for (var i = 0; i < aParams.count; i++) {
      final p = aParams[i];
      String s;
      if (p.isNull) {
        s = '<NULL>';
      } else if (ftBlobTypes.contains(p.dataType) &&
          p.dataType != TFieldType.ftMemo &&
          p.dataType != TFieldType.ftFmtMemo &&
          p.dataType != TFieldType.ftWideMemo) {
        s = '<BLOB>';
      } else {
        s = p.asString;
      }
      log(TDBEventType.detParamValue, formatMsg(SLogParamValue, [p.name, s]));
    }
  }

  // Log（L1954-1973）
  void log(TDBEventType eventType, String msg) {
    if (logEvent(eventType)) {
      if (onLog != null) {
        onLog!(this, eventType, msg);
      }
      if (globalDBLogHook != null) {
        String m;
        if (name != '') {
          m = '$name : $msg';
        } else {
          m = '$runtimeType : $msg';
        }
        globalDBLogHook!(this, eventType, m);
      }
    }
  }

  // RegisterStatement / UnRegisterStatement（L1975-1985）
  void registerStatement(TCustomSQLStatement s) {
    if (!_statements.contains(s)) {
      _statements.add(s); // dupIgnore
    }
  }

  void unRegisterStatement(TCustomSQLStatement s) {
    _statements.remove(s);
  }

  // CreateCustomQuery（L1987-1991）
  TCustomSQLQuery createCustomQuery(TComponent? aOwner) =>
      TCustomSQLQuery(aOwner);

  // InitialiseUpdateStatement（L1993-2007）
  // ??? TComponentClass(Query.ClassType).Create(Nil): metaclass dynamic
  // instantiation of the same type — convention 2 → TCustomSQLQuery.newInstance virtual factory
  TCustomSQLQuery initialiseUpdateStatement(
      TCustomSQLQuery query, TQueryRef qryRef) {
    if (qryRef.value == null) {
      final qry = query.newInstance(null);
      qry.parseSQL = false;
      qry.database = this;
      qry.transaction = query.sqlTransaction;
      qry.uniDirectional = true;
      qry.usePrimaryKeyAsKey = false;
      qry.packetRecords = 1;
      qryRef.value = qry;
    }
    return qryRef.value!;
  }

  // AddFieldToUpdateWherePart（L2010-2027）
// aa ??? issue
  // Tolerant handling of an empty primary key.
  //
  // This used to produce `(cno is null)` whenever oldValue == null. But in legacy data, "no code"
  // is often stored as an **empty string** '' rather than NULL — in that case `cno is null` never matches a single row,
  // the UPDATE affects 0 rows with no error message and nothing gets saved (symptom: a particular record just never saves no matter what).
  // Changed to tolerate both.
  //
  // Only adds `= ''` for string-type fields: for numeric fields, MariaDB implicitly converts '' to 0,
  // and adding it there would wrongly match records where key = 0.
  static bool _isTextField(TField f) =>
      f.dataType == TFieldType.ftString ||
      f.dataType == TFieldType.ftFixedChar ||
      f.dataType == TFieldType.ftMemo;

  /// Produces the condition for "this field is an empty key". The return value is always non-empty.
  String _emptyKeyCond(TField f, String quotedName) =>
      _isTextField(f) ? '$quotedName is null or $quotedName = \'\'' : '$quotedName is null';
// zz ??? issue

  void addFieldToUpdateWherePart(
      TStringRef sqlWhere, TUpdateMode updateMode, TField f,
      [TBoolRef? usedEmptyKey]) {
    if (f.providerFlags.contains(TProviderFlag.pfInKey) ||
        (updateMode == TUpdateMode.upWhereAll &&
            f.providerFlags.contains(TProviderFlag.pfInWhere)) ||
        (updateMode == TUpdateMode.upWhereChanged &&
            f.providerFlags.contains(TProviderFlag.pfInWhere) &&
            f.value != f.oldValue)) {
      if (sqlWhere.value != '') {
        sqlWhere.value = '${sqlWhere.value} and ';
      }
      final qn =
          '${fieldNameQuoteChars[0]}${f.fieldName}${fieldNameQuoteChars[1]}';
      // primary key normally cannot be null (original comment kept as-is)
      if (f.dataSet != null && f.dataSet!.active && f.oldValue == null) {
        // @@@ Empty key: both NULL and empty string need to be covered — see _emptyKeyCond
        sqlWhere.value = '${sqlWhere.value}(${_emptyKeyCond(f, qn)}) ';
        usedEmptyKey?.value = true;
      } else {
        sqlWhere.value = '${sqlWhere.value}($qn= :"OLD_${f.fieldName}") ';
      }
    }
  }

  // ConstructInsertSQL（L2030-2069）
  String constructInsertSQL(TCustomSQLQuery query, TBoolRef returningClause) {
    var sqlFields = '';
    var sqlValues = '';
    var returningFields = '';
    for (var x = 0; x < query.fields.count; x++) {
      final f = query.fields[x];
      // @@@ lookup/calc columns are not physical fields, and must never go into an INSERT.
      if (f.fieldKind == TFieldKind.fkCalculated ||
          f.fieldKind == TFieldKind.fkLookup) {
        continue;
      }
      if (!f.isNull &&
          f.providerFlags.contains(TProviderFlag.pfInUpdate) &&
          !f.readOnly) {
        sqlFields =
            '$sqlFields${fieldNameQuoteChars[0]}${f.fieldName}${fieldNameQuoteChars[1]},';
        sqlValues = '$sqlValues:"${f.fieldName}",';
      }
      if (returningClause.value &&
          f.providerFlags.contains(TProviderFlag.pfRefreshOnInsert)) {
        returningFields =
            '$returningFields${fieldNameQuoteChars[0]}${f.fieldName}${fieldNameQuoteChars[1]},';
      }
    }
    if (sqlFields.isEmpty) {
      databaseErrorFmt(SNoUpdateFields, ['insert'], this);
    }
    sqlFields = sqlFields.substring(0, sqlFields.length - 1);
    sqlValues = sqlValues.substring(0, sqlValues.length - 1);
    var result =
        'insert into ${query._tableName} ($sqlFields) values ($sqlValues)';
    if (returningClause.value) {
      returningClause.value = returningFields.isNotEmpty;
      if (returningClause.value) {
        returningFields =
            returningFields.substring(0, returningFields.length - 1);
        result = '$result returning $returningFields';
      }
    }
    return result;
  }

  // ConstructUpdateSQL（L2072-2107）
  // @@@ Data-layer safety net: when there's no key field at all (pfInKey), uses the first physical field's old value as the WHERE,
  //     so applyUpdates can still build an UPDATE/DELETE...WHERE. Centralized here → individual programs/pages don't need to
  //     set a key themselves, or re-export.
  String _fallbackKeyWhere(TCustomSQLQuery query, [TBoolRef? usedEmptyKey]) {
    for (var x = 0; x < query.fields.count; x++) {
      final f = query.fields[x];
      if (f.fieldKind == TFieldKind.fkCalculated ||
          f.fieldKind == TFieldKind.fkLookup) {
        continue;
      }
      final n =
          '${fieldNameQuoteChars[0]}${f.fieldName}${fieldNameQuoteChars[1]}';
      if (f.dataSet != null && f.dataSet!.active && f.oldValue == null) {
        // @@@ Empty key: both NULL and empty string need to be covered (see _emptyKeyCond)
        usedEmptyKey?.value = true;
        return '(${_emptyKeyCond(f, n)})';
      }
      return '($n= :"OLD_${f.fieldName}")';
    }
    return '';
  }

  String constructUpdateSQL(TCustomSQLQuery query, TBoolRef returningClause) {
    var sqlSet = '';
    final sqlWhere = TStringRef("");
    final usedEmptyKey = TBoolRef(false); // @@@ whether the empty-key tolerance condition was used
    var returningFields = '';
    for (var x = 0; x < query.fields.count; x++) {
      final f = query.fields[x];
      // @@@ lookup/calc columns are not physical fields, and must never go into an UPDATE (even if providerFlags
      //     mistakenly carries pfInUpdate). The WHERE part is skipped too.
      if (f.fieldKind == TFieldKind.fkCalculated ||
          f.fieldKind == TFieldKind.fkLookup) {
        continue;
      }
      addFieldToUpdateWherePart(sqlWhere, query.updateMode, f, usedEmptyKey);
      if (f.providerFlags.contains(TProviderFlag.pfInUpdate) && !f.readOnly) {
        sqlSet =
            '$sqlSet${fieldNameQuoteChars[0]}${f.fieldName}${fieldNameQuoteChars[1]}=:"${f.fieldName}",';
      }
      if (returningClause.value &&
          f.providerFlags.contains(TProviderFlag.pfRefreshOnUpdate)) {
        returningFields =
            '$returningFields${fieldNameQuoteChars[0]}${f.fieldName}${fieldNameQuoteChars[1]},';
      }
    }
    if (sqlSet.isEmpty) databaseErrorFmt(SNoUpdateFields, ['update'], this);
    sqlSet = sqlSet.substring(0, sqlSet.length - 1);
    if (sqlWhere.value.isEmpty) {
      sqlWhere.value = _fallbackKeyWhere(query, usedEmptyKey); // @@@ no key → use the first field's old value as the condition
    }
    if (sqlWhere.value.isEmpty) {
      databaseErrorFmt(SNoWhereFields, ['update'], this);
    }
    final _updTbl = query.updateTableName.isNotEmpty ? query.updateTableName : query._tableName;
    var result =
        'update $_updTbl set $sqlSet where ${sqlWhere.value}';
// aa ??? issue
    // The empty-key tolerance condition (cno is null or cno = '') can match more than one row — in legacy data,
    // an empty code often has several matching rows. Adds limit 1 to ensure only one row is changed at a time, not the whole batch.
    // Only added when the tolerance condition is actually used; a normal UPDATE with a real primary key is completely unaffected.
    if (usedEmptyKey.value) result = '$result limit 1';
// zz ??? issue
    if (returningClause.value) {
      returningClause.value = returningFields.isNotEmpty;
      if (returningClause.value) {
        returningFields =
            returningFields.substring(0, returningFields.length - 1);
        result = '$result returning $returningFields';
      }
    }
    return result;
  }

  // ConstructDeleteSQL（L2110-2123）
  String constructDeleteSQL(TCustomSQLQuery query) {
    final sqlWhere = TStringRef("");
    final usedEmptyKey = TBoolRef(false);
    for (var x = 0; x < query.fields.count; x++) {
      addFieldToUpdateWherePart(
          sqlWhere, query.updateMode, query.fields[x], usedEmptyKey);
    }
    if (sqlWhere.value.isEmpty) {
      sqlWhere.value = _fallbackKeyWhere(query, usedEmptyKey); // @@@ no key → use the first field's old value as the condition
    }
    if (sqlWhere.value.isEmpty) {
      databaseErrorFmt(SNoWhereFields, ['delete'], this);
    }
    final _delTbl = query.updateTableName.isNotEmpty ? query.updateTableName : query._tableName;
    var result = 'delete from $_delTbl where ${sqlWhere.value}';
    // @@@ Same as UPDATE: the empty-key tolerance condition can match multiple rows, and deletion is even less safe to let hit them all
    if (usedEmptyKey.value) result = '$result limit 1';
    return result;
  }

  // ConstructRefreshSQL（L2125-2160）
  String constructRefreshSQL(TCustomSQLQuery query, TUpdateKind updateKind) {
    var result = query.refreshSQL.text.trim();
    if (result == '') {
      var where = '';
      final pf = _refreshFlags(updateKind);
      for (var i = 0; i < query.fields.count; i++) {
        final f = query.fields[i];
        if (f.providerFlags.contains(pf)) {
          if (result != '') {
            result = '$result, ';
          }
          if (f.origin != '' && f.origin != f.fieldName) {
            result = '$result${f.origin} AS ${f.fieldName}';
          } else {
            result =
                '$result${fieldNameQuoteChars[0]}${f.fieldName}${fieldNameQuoteChars[1]}';
          }
        }
        if (f.providerFlags.contains(TProviderFlag.pfInKey)) {
          if (where != '') {
            where = '$where AND ';
          }
          where =
              '$where(${fieldNameQuoteChars[0]}${f.fieldName}${fieldNameQuoteChars[1]} = :${f.fieldName})';
        }
      }
      if (where == '') {
        databaseError(SErrNoKeyFieldForRefreshClause, query);
      }
      result = 'SELECT $result FROM ${query._tableName} WHERE $where';
    }
    return result;
  }

  // ApplyFieldUpdate（L2162-2170）
  void applyFieldUpdate(
      TSQLCursor? c, TSQLDBParam p, TField f, bool useOldValue) {
    if (useOldValue) {
      p.assignFieldValue(f, f.oldValue);
    } else {
      p.assignFieldValue(f, f.value);
    }
    p.fieldDef = f.fieldDef;
  }

  // ApplyRecUpdate (L2172-2253): builds the update statement + binds parameters + executes
  void applyRecUpdate(TCustomSQLQuery query, TUpdateKind updateKind) {
    TCustomSQLQuery? qry;
    var hasReturningClause = TBoolRef(
        connOptions.contains(TConnOption.sqSupportReturning) &&
            !query.options.contains(TSQLQueryOption.sqoRefreshUsingSelect) &&
            query.refreshSQL.text.trim() == '');
    var s = '';
    switch (updateKind) {
      case TUpdateKind.ukInsert:
        s = query._insertSQL.text.trim();
        if (s == '') {
          s = constructInsertSQL(query, hasReturningClause);
        } else {
          hasReturningClause.value = false;
        }
        qry = initialiseUpdateStatement(query, query._insertQry);
        break;
      case TUpdateKind.ukModify:
        s = query._updateSQL.text.trim();
        if (s == '') {
          //if not assigned(Query.FUpdateQry) or
          //(Query.UpdateMode<>upWhereKeyOnly) then // first time or
          //dynamic where part (original comment kept as-is)
          s = constructUpdateSQL(query, hasReturningClause);
        } else {
          hasReturningClause.value = false;
        }
        qry = initialiseUpdateStatement(query, query._updateQry);
        break;
      case TUpdateKind.ukDelete:
        s = query._deleteSQL.text.trim();
        if (s == '' &&
            (query._deleteQry.value == null ||
                query.updateMode != TUpdateMode.upWhereKeyOnly)) {
          s = constructDeleteSQL(query);
        }
        hasReturningClause.value = false;
        qry = initialiseUpdateStatement(query, query._deleteQry);
        break;
    }
    if (s != '' && qry.sql.text != '$s\n') {
      qry.sql.text = s; // assign only when changed, to avoid
      // UnPrepare/Prepare (original comment kept as-is)
    }
    assert(qry.sql.text != '');
    for (var x = 0; x < qry.params.count; x++) {
      final p = qry.params[x];
      var s2 = p.name;
      final useOldValue = s2.length >= 4 &&
          s2.substring(0, 4).toUpperCase() == 'OLD_';
      TField? fld;
      if (useOldValue) {
        s2 = s2.substring(4);
        fld = query.fieldByName(s2);
      } else {
        fld = query.findField(s2);
      }
      if (fld != null) {
        applyFieldUpdate(query.cursor, p as TSQLDBParam, fld, useOldValue);
      } else {
        // if does not exists field with given name, try look for param
        // (original comment kept as-is)
        final par = query.params.findParam(s2);
        if (par != null) {
          p.assign(par);
        } else {
          databaseErrorFmt(SFieldNotFound, [s2], query); // same error as
          // raised by FieldByName() (original comment kept as-is)
        }
      }
    }
    if (hasReturningClause.value) {
      qry.close();
      qry.open();
    } else {
      qry.execSQL();
    }
    if (options
            .contains(TSQLConnectionOption.scoApplyUpdatesChecksRowsAffected) &&
        qry.rowsAffected() != 1) {
      final n = qry.rowsAffected();
      qry.close();
      databaseErrorFmt(SErrFailedToUpdateRecord, [n], query);
    }
    if (hasReturningClause.value) {
      query.applyReturningResult(qry, updateKind);
    }
  }

  // RefreshLastInsertID（L2255-2258）
  bool refreshLastInsertID(TCustomSQLQuery query, TField field) => false;

  // FreeFldBuffers（L2260-2263）
  void freeFldBuffers(TSQLCursor cursor) {
    // empty (original comment kept as-is)
  }

  // StartImplicitTransaction（L2265-2268）
  bool startImplicitTransaction(TSQLHandle trans, String aParams) => false;

  // GetSchemaInfoSQL（L2270-2281）
  String getSchemaInfoSQL(
      TSchemaType schemaType, String schemaObjectName, String schemaPattern) {
    switch (schemaType) {
      case TSchemaType.stTables:
        return "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'";
      case TSchemaType.stColumns:
        return 'SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=${quotedStr(schemaObjectName)}';
      case TSchemaType.stProcedures:
        return 'SELECT *, ROUTINE_NAME AS PROCEDURE_NAME FROM INFORMATION_SCHEMA.ROUTINES';
      case TSchemaType.stSchemata:
        return 'SELECT * FROM INFORMATION_SCHEMA.SCHEMATA';
      case TSchemaType.stSequences:
        return 'SELECT * FROM INFORMATION_SCHEMA.SEQUENCES';
      default:
        databaseError(SMetadataUnavailable);
    }
  }

  // GetNextValueSQL（L2283-2286）
  String getNextValueSQL(String sequenceName, int incrementBy) {
    return 'SELECT NEXT VALUE FOR $sequenceName';
  }

  // GetNextValue（L2288-2305）
  int getNextValue(String sequenceName, [int incrementBy = 1]) {
    var result = 0;
    final q = TCustomSQLQuery(null);
    try {
      q.database = this;
      q.transaction = _sqlTransaction;
      q.sql.text = getNextValueSQL(sequenceName, incrementBy);
      q.open();
      if (!q.eof) {
        result = q.fields[0].asLargeInt;
      }
      q.close();
    } finally {
      q.free();
    }
    return result;
  }

  // MaybeConnect（L2307-2315）
  void maybeConnect() {
    if (!connected) {
      if (options.contains(TSQLConnectionOption.scoExplicitConnect)) {
        databaseErrorFmt(SErrImplicitConnect, [name]);
      }
      connected = true;
    }
  }

  // CreateDB / DropDB（L2317-2327）
  void createDB() {
    databaseError(SNotSupported);
  }

  void dropDB() {
    databaseError(SNotSupported);
  }

  // ---- The abstract driver interface (declaration L240-261) → throws, virtual ------------------
  TSQLCursor allocateCursorHandle() {
    throw EDatabaseError("AbstractError: TSQLConnection.AllocateCursorHandle");
  }

  void deAllocateCursorHandle(TSQLCursor cursor) {
    throw EDatabaseError(
        "AbstractError: TSQLConnection.DeAllocateCursorHandle");
  }

  void prepareStatement(TSQLCursor cursor, TSQLTransaction? aTransaction,
      String buf, TParams? aParams) {
    throw EDatabaseError("AbstractError: TSQLConnection.PrepareStatement");
  }

  void unPrepareStatement(TSQLCursor cursor) {
    throw EDatabaseError("AbstractError: TSQLConnection.UnPrepareStatement");
  }

  void execute(TSQLCursor cursor, TSQLTransaction? aTransaction,
      TParams? aParams) {
    throw EDatabaseError("AbstractError: TSQLConnection.Execute");
  }

  bool fetch(TSQLCursor cursor) {
    throw EDatabaseError("AbstractError: TSQLConnection.Fetch");
  }

  void addFieldDefs(TSQLCursor cursor, TFieldDefs fieldDefs) {
    throw EDatabaseError("AbstractError: TSQLConnection.AddFieldDefs");
  }

  bool loadField(TSQLCursor cursor, TFieldDef fieldDef, TValueBuffer buffer,
      TBoolRef createBlob) {
    throw EDatabaseError("AbstractError: TSQLConnection.LoadField");
  }

  void loadBlobIntoBuffer(TFieldDef fieldDef, PBufBlobField aBlobBuf,
      TSQLCursor cursor, TSQLTransaction? aTransaction) {
    throw EDatabaseError("AbstractError: TSQLConnection.LoadBlobIntoBuffer");
  }

  TSQLHandle allocateTransactionHandle() {
    throw EDatabaseError(
        "AbstractError: TSQLConnection.AllocateTransactionHandle");
  }

  dynamic getTransactionHandle(TSQLHandle trans) {
    throw EDatabaseError(
        "AbstractError: TSQLConnection.GetTransactionHandle");
  }

  bool commit(TSQLHandle trans) {
    throw EDatabaseError("AbstractError: TSQLConnection.Commit");
  }

  bool rollBack(TSQLHandle trans) {
    throw EDatabaseError("AbstractError: TSQLConnection.RollBack");
  }

  bool startDBTransaction(TSQLHandle trans, String aParams) {
    throw EDatabaseError("AbstractError: TSQLConnection.StartDBTransaction");
  }

  void commitRetaining(TSQLHandle trans) {
    throw EDatabaseError("AbstractError: TSQLConnection.CommitRetaining");
  }

  void rollBackRetaining(TSQLHandle trans) {
    throw EDatabaseError("AbstractError: TSQLConnection.RollBackRetaining");
  }
}

// A reference wrapper for the qry parameter (InitialiseUpdateStatement's var TCustomSQLQuery)
class TQueryRef {
  TCustomSQLQuery? value;
  TQueryRef([this.value]);
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 5 —— TSQLTransaction / TSQLSequence / TQuerySQLStatement
//  Declaration: L315-354, L445-466, L2588-2600; implementation: L2332-2675
// ═════════════════════════════════════════════════════════════════════════════

// TCommitRollbackAction / TSQLTransactionOption(s)（L315-319）
enum TCommitRollbackAction {
  caNone,
  caCommit,
  caCommitRetaining,
  caRollback,
  caRollbackRetaining,
}

enum TSQLTransactionOption { stoUseImplicit, stoExplicitStart }

typedef TSQLTransactionOptions = Set<TSQLTransactionOption>;

class TSQLTransaction extends TDBTransaction {
  TSQLTransactionOptions _options = <TSQLTransactionOption>{};
  TSQLHandle? _trans;
  TCommitRollbackAction action = TCommitRollbackAction.caRollback;
  late TStringList _params;

  // constructor Create（L2332-2337）
  TSQLTransaction([TComponent? aOwner]) : super(aOwner) {
    _params = TStringList();
    action = TCommitRollbackAction.caRollback;
  }

  // destructor Destroy（L2339-2345）
  @override
  void destroy() {
    endTransaction();
    _trans = null;
    super.destroy();
  }

  // EndTransaction（L2347-2360）
  @override
  void endTransaction() {
    switch (action) {
      case TCommitRollbackAction.caCommit:
      case TCommitRollbackAction.caCommitRetaining:
        commit();
        break;
      case TCommitRollbackAction.caNone:
      case TCommitRollbackAction.caRollback:
      case TCommitRollbackAction.caRollbackRetaining:
        if (!_options.contains(TSQLTransactionOption.stoUseImplicit)) {
          rollback();
        } else {
          closeTrans();
        }
        break;
    }
  }

  // SetParams（L2362-2365）
  TStringList get params => _params;
  set params(TStringList aValue) {
    _params.assign(aValue);
  }

  // GetSQLConnection / SetSQLConnection（L2367-2370, L2380-2383）
  TSQLConnection? get sqlConnection => database as TSQLConnection?;
  set sqlConnection(TSQLConnection? aValue) {
    database = aValue;
  }

  // SetOptions（L2372-2378）
  TSQLTransactionOptions get options => _options;
  set options(TSQLTransactionOptions aValue) {
    if (_options == aValue) return;
    if (aValue.contains(TSQLTransactionOption.stoUseImplicit) &&
        sqlConnection != null &&
        !sqlConnection!.connOptions
            .contains(TConnOption.sqImplicitTransaction)) {
      databaseErrorFmt(
          SErrNoImplicitTransaction, [sqlConnection.runtimeType.toString()]);
    }
    _options = aValue;
  }

  // MaybeStartTransaction（L2385-2393）
  void maybeStartTransaction() {
    if (!active) {
      if (_options.contains(TSQLTransactionOption.stoExplicitStart)) {
        databaseErrorFmt(
            SErrImplictTransactionStart, [database?.name ?? '', name]);
      }
      startTransaction();
    }
  }

  // GetHandle（L2395-2398）
  dynamic get handle => sqlConnection!.getTransactionHandle(_trans!);

  // AllowClose（L2400-2406）
  @override
  bool allowClose(TDBDataset? ds) {
    if (ds is TSQLQuery) {
      return !ds.options.contains(TSQLQueryOption.sqoKeepOpenOnCommit);
    }
    return super.allowClose(ds);
  }

  // Commit（L2408-2425）
  @override
  void commit() {
    if (active) {
      closeDataSets();
      if (logEvent(TDBEventType.detCommit)) {
        log(TDBEventType.detCommit, SCommitting);
      }
      // The inherited closetrans must always be called.
      // So the last (FTrans=Nil) is for the case of forced close.
      // (Bug IDs 35246 and 33737)
      // Order is important: some connections do not have FTrans, but
      // they must still go through AttemptCommit. (original comment kept as-is)
      if (_options.contains(TSQLTransactionOption.stoUseImplicit) ||
          sqlConnection!.attemptCommit(_trans!) ||
          _trans == null) {
        closeTrans();
        _trans = null; // FreeAndNil
      }
    }
  }

  // CommitRetaining（L2427-2435）
  @override
  void commitRetaining() {
    if (active) {
      if (logEvent(TDBEventType.detCommit)) {
        log(TDBEventType.detCommit, SCommitRetaining);
      }
      sqlConnection!.commitRetaining(_trans!);
    }
  }

  // Rollback（L2437-2457）
  @override
  void rollback() {
    if (active) {
      if (_options.contains(TSQLTransactionOption.stoUseImplicit)) {
        databaseError(SErrImplicitNoRollBack);
      }
      closeDataSets();
      if (logEvent(TDBEventType.detRollBack)) {
        log(TDBEventType.detRollBack, SRollingBack);
      }
      // FTrans=Nil for the case of forced close. (original comment kept as-is)
      if (sqlConnection!.attemptRollBack(_trans!) || _trans == null) {
        closeTrans();
        _trans = null;
      }
    }
  }

  // RollbackRetaining（L2459-2469）
  @override
  void rollbackRetaining() {
    if (active) {
      if (_options.contains(TSQLTransactionOption.stoUseImplicit)) {
        databaseError(SErrImplicitNoRollBack);
      }
      if (logEvent(TDBEventType.detRollBack)) {
        log(TDBEventType.detRollBack, SRollBackRetaining);
      }
      sqlConnection!.rollBackRetaining(_trans!);
    }
  }

  // StartTransaction（L2471-2498）
  @override
  void startTransaction() {
    if (active) {
      databaseError(SErrTransAlreadyActive);
    }
    final db = sqlConnection;
    if (db == null) {
      databaseError(SErrDatabasenAssigned);
    }
    db!.maybeConnect();

    _trans ??= db.allocateTransactionHandle();

    // FParams.CommaText → comma-joined (the TStrings shim has no CommaText quoting
    // rule; params conventionally use name=value with no commas, so this is equivalent)
    final paramsText = _params.raw.join(",");
    if (_options.contains(TSQLTransactionOption.stoUseImplicit)) {
      if (db.startImplicitTransaction(_trans!, paramsText)) {
        openTrans();
      }
    } else {
      if (db.startDBTransaction(_trans!, paramsText)) {
        openTrans();
      }
    }
  }

  // SetDatabase（L2500-2516）
  @override
  set database(TDatabase? value) {
    if (!identical(value, database)) {
      if (value != null && value is! TSQLConnection) {
        databaseErrorFmt(SErrNotASQLConnection, [value.name], this);
      }
      checkInactive();
      if (_options.contains(TSQLTransactionOption.stoUseImplicit) &&
          value != null &&
          !(value as TSQLConnection)
              .connOptions
              .contains(TConnOption.sqImplicitTransaction)) {
        databaseErrorFmt(
            SErrNoImplicitTransaction, [value.runtimeType.toString()]);
      }
      if (database != null) {
        if (identical(sqlConnection!.transaction, this)) {
          sqlConnection!.transaction = null;
        }
      }
      super.database = value;
      if (database != null &&
          !componentState.contains(TComponentStateItem.csLoading)) {
        if (sqlConnection!.transaction == null) {
          sqlConnection!.transaction = this;
        }
      }
    }
  }

  // LogEvent（L2518-2521）
  bool logEvent(TDBEventType eventType) {
    return database != null && sqlConnection!.logEvent(eventType);
  }

  // Log（L2523-2537）
  void log(TDBEventType eventType, String msg) {
    if (logEvent(eventType)) {
      String m;
      if (name != '') {
        m = '$name : $msg';
      } else {
        m = msg;
      }
      sqlConnection!.log(eventType, m);
    }
  }
}

// ---- TSQLSequence (declaration L447-466, implementation L2542-2581) --------------------------
enum TSQLSequenceApplyEvent { saeOnNewRecord, saeOnPost }

class TSQLSequence extends TPersistent {
  final TCustomSQLQuery? _query;
  String fieldName = '';
  String sequenceName = '';
  int incrementBy = 1;
  TSQLSequenceApplyEvent applyEvent = TSQLSequenceApplyEvent.saeOnNewRecord;

  // constructor Create（L2542-2548）
  TSQLSequence(TCustomSQLQuery? aQuery)
      : _query = aQuery {
    applyEvent = TSQLSequenceApplyEvent.saeOnNewRecord;
    incrementBy = 1;
  }

  // Assign（L2550-2563）
  @override
  void assign(TPersistent? source) {
    if (source is TSQLSequence) {
      fieldName = source.fieldName;
      sequenceName = source.sequenceName;
      incrementBy = source.incrementBy;
      applyEvent = source.applyEvent;
    } else {
      super.assign(source);
    }
  }

  // Apply（L2565-2574）
  void apply() {
    if (_query != null && sequenceName != '' && fieldName != '') {
      final field = _query!.findField(fieldName);
      if (field != null && field.isNull) {
        field.asLargeInt = getNextValue();
      }
    }
  }

  // GetNextValue（L2576-2581）
  int getNextValue() {
    if (_query == null || _query!.sqlConnection == null) {
      databaseError(SErrDatabasenAssigned);
    }
    return _query!.sqlConnection!.getNextValue(sequenceName, incrementBy);
  }
}

// ---- TQuerySQLStatement (declaration L2588-2600, implementation L2604-2675) ------------------
// A Statement subclass used internally by TCustomSQLQuery, feeding the Schema/table-name parsing result
// back into the Query
class TQuerySQLStatement extends TCustomSQLStatement {
  final TCustomSQLQuery _query;

  // constructor（L2604-2608）：FQuery:=TCustomSQLQuery(AOwner)
  TQuerySQLStatement(TCustomSQLQuery aOwner)
      : _query = aOwner,
        super(aOwner);

  // CreateDataLink（L2610-2613）
  @override
  TDataLink createDataLink() => TMasterParamsDataLink(_query);

  // CreateParams（L2615-2618）
  @override
  TSQLDBParams createParams() => _query.createParams();

  // GetSchemaType（L2620-2626）
  @override
  TSchemaType getSchemaType() => _query._schemaType;

  // GetSchemaObjectName（L2628-2634）
  @override
  String getSchemaObjectName() => _query._schemaObjectName;

  // GetSchemaPattern（L2636-2642）
  @override
  String getSchemaPattern() => _query._schemaPattern;

  // GetStatementInfo（L2644-2666）
  @override
  TSQLStatementInfo getStatementInfo(TStringRef aSQL) {
    final info = super.getStatementInfo(aSQL);
    // Note: practical side effect of switch off ParseSQL is that
    // UpdateServerIndexDefs is bypassed which is used as performance
    // tuning option (original comment kept as-is)
    if (_query._schemaType == TSchemaType.stNoSchema && parseSQL) {
      _query._updateable = info.updateable;
      _query._tableName = info.tableName;
      _query._whereStartPos = info.whereStartPos;
      _query._whereStopPos = info.whereStopPos;
      if (_query.serverFiltered) {
        aSQL.value = _query.addFilter(aSQL.value);
      }
    } else {
      _query._updateable = false;
      _query._tableName = '';
      _query._whereStartPos = 0;
      _query._whereStopPos = 0;
    }
    return info;
  }

  // OnChangeSQL（L2668-2675）
  @override
  void onChangeSQL(Object sender) {
    unprepare();
    super.onChangeSQL(sender);
    if (paramCheck && _dataLink != null) {
      (_dataLink as TMasterParamsDataLink).refreshParamNames();
    }
    _query.serverIndexDefs.updated = false;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 6 —— TCustomSQLQuery
//  Declaration: L474-653; implementation: L2679-3505 (methods after L3506 are in a TODO at the end of the section)
// ═════════════════════════════════════════════════════════════════════════════

// TSQLQueryOption(s)（L471-472）
enum TSQLQueryOption {
  sqoKeepOpenOnCommit,
  sqoAutoApplyUpdates,
  sqoAutoCommit,
  sqoCancelUpdatesOnRefresh,
  sqoRefreshUsingSelect,
}

typedef TSQLQueryOptions = Set<TSQLQueryOption>;

// ---- TServerIndexDefs (declaration L164-169, implementation L4003-4017) ----------------------
class TServerIndexDefs extends TIndexDefs {
  // constructor Create(ADataset)（L4003-4008）
  TServerIndexDefs(TDataSet? aDataSet) : super(aDataSet) {
    if (aDataSet is! TCustomSQLQuery) {
      databaseErrorFmt(SErrNotASQLQuery, [aDataSet?.name ?? '']);
    }
  }

  // procedure Update; override（L4010-4017）
  @override
  void updateDefs() {
    // @@@ _dataset is a private field of TDefCollection in lazarus_db.dart,
    // @@@ inaccessible across files; uses the public getter dataset instead.
    if (!updated && dataset != null) {
      (dataset as TCustomSQLQuery).updateServerIndexDefs();
      updated = true;
    }
  }
}

class TCustomSQLQuery extends TCustomBufDataset {
  TSQLQueryOptions _options = <TSQLQueryOption>{};
  TSchemaType _schemaType = TSchemaType.stNoSchema;
  bool _updateable = false;
// aa ### flutter extension
  // forceUpdateable: for datasets that dynamically change SQL like loadWithSql, SQL parsing may not
  // determine updateable correctly, causing edit() to be blocked by canModify. applyUpdates builds its own
  // INSERT/UPDATE/DELETE using pfInKey fields, so it's safe to force this to true (provided a _key field is marked).
  set forceUpdateable(bool v) => _updateable = v;

  // alwaysUpdateable: forceUpdateable can only be set "after opening" (the open process recalculates
  // _updateable, and setting it earlier gets overwritten). This flag can be set "before" opening, and internalOpen
  // automatically applies it at the end —— so the caller only needs openAsync() to open, without wrapping an extra step to set it afterward.
  bool _alwaysUpdateable = false;
  bool get alwaysUpdateable => _alwaysUpdateable;
  set alwaysUpdateable(bool v) => _alwaysUpdateable = v;
// zz ### flutter extension
  String _tableName = '';
  String updateTableName = ''; // @@@ explicitly specifies the update table for a multi-table join (overrides an unparseable _tableName)
  late TCustomSQLStatement _statement;
  late TStringList _insertSQL;
  late TStringList _updateSQL;
  late TStringList _deleteSQL;
  late TStringList _refreshSQL;
  bool _isEOF = false;
  bool _loadingFieldDefs = false;
  TUpdateMode _updateMode = TUpdateMode.upWhereKeyOnly;
  bool _doUnprepare = false;
  bool _usePrimaryKeyAsKey = true;
  int _whereStartPos = 0;
  int _whereStopPos = 0;
  String _serverFilterText = '';
  bool _serverFiltered = false;
  late TServerIndexDefs _serverIndexDefs;

  // Used by SetSchemaType (original comment kept as-is)
  String _schemaObjectName = '';
  String _schemaPattern = '';

  final TQueryRef _insertQry = TQueryRef();
  final TQueryRef _updateQry = TQueryRef();
  final TQueryRef _deleteQry = TQueryRef();
  TSQLSequence? sequence;

  // CreateSQLStatement（L2679-2684）
  TCustomSQLStatement createSQLStatement(TComponent? aOwner) {
    return TQuerySQLStatement(this);
  }

  // ??? metaclass mapping (convention 2): InitialiseUpdateStatement's
  // TComponentClass(Query.ClassType).Create(Nil) uses this virtual factory,
  // the subclass (TSQLQuery) overrides it to return its own type
  TCustomSQLQuery newInstance(TComponent? aOwner) =>
      TCustomSQLQuery(aOwner);

  // constructor Create（L2686-2715）
  TCustomSQLQuery([TComponent? aOwner]) : super(aOwner) {
    _statement = createSQLStatement(this);

    _insertSQL = TStringList();
    _insertSQL.onChange = onChangeModifySQL;
    _updateSQL = TStringList();
    _updateSQL.onChange = onChangeModifySQL;
    _deleteSQL = TStringList();
    _deleteSQL.onChange = onChangeModifySQL;
    _refreshSQL = TStringList();
    _refreshSQL.onChange = onChangeModifySQL;

    sequence = TSQLSequence(this);
    _serverIndexDefs = TServerIndexDefs(this);

    _serverFiltered = false;
    _serverFilterText = '';

    _schemaType = TSchemaType.stNoSchema;
    _schemaObjectName = '';
    _schemaPattern = '';

    // Delphi has upWhereAll as default, but since strings and
    // oldvalue's don't work yet (variants) set it to upWhereKeyOnly
    // (original comment kept as-is)
    _updateMode = TUpdateMode.upWhereKeyOnly;
    _usePrimaryKeyAsKey = true;
  }

  // destructor Destroy（L2717-2729）
  @override
  void destroy() {
    if (active) close();
    unPrepare();
    _statement.destroy();
    super.destroy();
  }

  // ParamByName / MacroByName（L2731-2740）
  TParam paramByName(String aParamName) => params.paramByName(aParamName);
  TParam macroByName(String aParamName) => macros.paramByName(aParamName);

  // OnChangeModifySQL（L2742-2746）
  void onChangeModifySQL(Object sender) {
    checkInactive();
  }

  // SetDatabase（L2748-2763）
  @override
  set database(TDatabase? value) {
    if (identical(database, value)) return;
    if (value != null && value is! TSQLConnection) {
      databaseErrorFmt(SErrNotASQLConnection, [value.name], this);
    }
    unPrepare();
    final db = value as TSQLConnection?;
    _statement.database = db;
    super.database = value;
    if (db != null &&
        db.transaction != null &&
        (transaction == null ||
            !identical(transaction!.database, database))) {
      transaction = db.transaction;
    }
  }

  TDatabase? get database => super.database;

  // SetTransaction（L2765-2775）
  @override
  set transaction(TDBTransaction? value) {
    if (identical(transaction, value)) return;
    unPrepare();
    super.transaction = value;
    _statement.transaction = value as TSQLTransaction?;
    if (transaction != null &&
        transaction!.database != null &&
        !identical(database, transaction!.database)) {
      database = transaction!.database;
    }
  }

  TDBTransaction? get transaction => super.transaction;

  // IsPrepared（L2777-2784）
  bool isPrepared() {
    return _statement.prepared;
  }

  bool get prepared => isPrepared();

  // AddFilter (L2786-2802): system.insert is 1-based; _insert1 converts uniformly
  String addFilter(String sqlStr) {
    String insert1(String s, int oneBasedIndex, String what) {
      var idx = oneBasedIndex - 1;
      if (idx < 0) idx = 0;
      if (idx > s.length) idx = s.length;
      return s.substring(0, idx) + what + s.substring(idx);
    }

    var s = sqlStr;
    if (_whereStartPos > 0 && _whereStopPos > 0) {
      s = insert1(s, _whereStartPos + 1, "(");
      s = insert1(s, _whereStopPos + 1, ")");
    }

    if (_whereStartPos == 0) {
      s = '$s where ($serverFilter)';
    } else if (_whereStopPos > 0) {
      s = insert1(s, _whereStopPos + 2, " and ($serverFilter) ");
    } else {
      s = insert1(s, _whereStartPos, " where ($serverFilter) ");
    }
    return s;
  }

  // OpenCursor（L2804-2814）
  @override
  void openCursor(bool infoQuery) {
    if (infoQuery) {
      checkPrepare();
    }
    try {
      super.openCursor(infoQuery);
    } finally {
      if (infoQuery) {
        checkUnPrepare();
      }
    }
  }

  // NeedRefreshRecord（L2816-2837）
  bool needRefreshRecord(TUpdateKind updateKind) {
    var result = _refreshSQL.text.trim() != '';
    final doReturning =
        sqlConnection!.connOptions.contains(TConnOption.sqSupportReturning) &&
            !_options.contains(TSQLQueryOption.sqoRefreshUsingSelect);
    if (!(result || doReturning)) {
      final pf = _refreshFlags(updateKind);
      var i = 0;
      while (!result && i < fields.count) {
        result = fields[i].providerFlags.contains(pf);
        i++;
      }
    }
    return result;
  }

  // RefreshRecord（L2839-2887）
  bool refreshRecord(TUpdateKind updateKind) {
    var result = false;
    final q = TCustomSQLQuery(null);
    try {
      q.database = database;
      q.transaction = transaction;
      q.sql.text = sqlConnection!.constructRefreshSQL(this, updateKind);
      for (var i = 0; i < q.params.count; i++) {
        final p = q.params[i];
        var n = p.name;
        if (n.length >= 4 && n.substring(0, 4).toUpperCase() == 'OLD_') {
          n = n.substring(4);
        }
        final f = fields.findField(n);
        if (f != null) {
          p.assignField(f);
        }
      }
      q.open();
      try {
        if (q.eof && q.bof) {
          databaseError(SErrRefreshEmptyResult, this);
        } else {
          if (q.recordCount != 1) {
            databaseErrorFmt(
                SErrRefreshNotSingleton, [q.recordCount], this);
          }
          for (var i = 0; i < q.fields.count; i++) {
            final f = q.fields[i];
            final fd = fields.findField(f.fieldName);
            if (fd != null) {
              fd.assign(f);
              result = true; // We could check if the new value differs
              // from the old, but we won't. (original comment kept as-is)
            }
          }
        }
      } finally {
        q.close();
      }
    } finally {
      q.free();
    }
    return result;
  }

  // ApplyReturningResult（L2889-2906）
  void applyReturningResult(TCustomSQLQuery q, TUpdateKind updateKind) {
    final refreshFlag = _refreshFlags(updateKind);
    final s = setTempState(TDataSetState.dsRefreshFields);
    try {
      for (var i = 0; i < fields.count; i++) {
        final f = fields[i];
        if (f.providerFlags.contains(refreshFlag)) {
          f.assign(q.fieldByName(f.fieldName));
        }
      }
    } finally {
      restoreState(s);
    }
  }

  // ApplyFilter（L2908-2915）
  void applyFilter() {
    if (prepared) {
      _statement.unprepare();
    }
    internalRefresh();
    first();
  }

  // SetServerFiltered（L2917-2927）
  bool get serverFiltered => _serverFiltered;
  set serverFiltered(bool value) => setServerFiltered(value);

  void setServerFiltered(bool value) {
    if (value && !parseSQL) {
      databaseErrorFmt(SNoParseSQL, ['Filtering ']);
    }
    if (_serverFiltered != value) {
      _serverFiltered = value;
      if (active) applyFilter();
    }
  }

  // SetServerFilterText（L2929-2936）
  String get serverFilter => _serverFilterText;
  set serverFilter(String value) => setServerFilterText(value);

  void setServerFilterText(String value) {
    if (value != _serverFilterText) {
      _serverFilterText = value;
      if (active) applyFilter();
    }
  }

  // Prepare（L2939-2943）
  void prepare() {
    _statement.prepare();
  }

  // UnPrepare（L2945-2952）
  void unPrepare() {
    if (!refreshing) {
      checkInactive();
    }
    _statement.unprepare();
  }

  // FreeFldBuffers (L2954-2958) —— distinguished from TSQLConnection's method of the same name;
  // this is the query side's private forwarding version
  void freeFldBuffers() {
    if (cursor != null) {
      sqlConnection!.freeFldBuffers(cursor!);
    }
  }

  // The FStatement forwarding property group (L2960-3008)
  String get macroChar => _statement.macroChar;
  set macroChar(String aValue) => _statement.macroChar = aValue; // L3294

  bool get paramCheck => _statement.paramCheck;
  set paramCheck(bool aValue) => _statement.paramCheck = aValue; // L3420

  TParams get params => _statement.params;
  set params(TParams aValue) => _statement.params.assign(aValue); // L3470

  bool get macroCheck => _statement.macroCheck;
  set macroCheck(bool aValue) => _statement.macroCheck = aValue; // L3425

  TParams get macros => _statement.macros;
  set macros(TParams aValue) => _statement.macros.assign(aValue); // L3475

  bool get parseSQL => _statement.parseSQL;
  // SetParseSQL（L3241-3248）
  set parseSQL(bool aValue) {
    checkInactive();
    _statement.parseSQL = aValue;
    if (!aValue) {
      _serverFiltered = false;
    }
  }

  TServerIndexDefs get serverIndexDefs => _serverIndexDefs;

  TStringList get sql => _statement.sql as TStringList;
  // SetSQL（L3250-3253）
  set sql(TStringList aValue) {
    _statement.sql.assign(aValue);
  }

  TSQLConnection? get sqlConnection => database as TSQLConnection?;
  set sqlConnection(TSQLConnection? aValue) => database = aValue; // L3439

  TSQLTransaction? get sqlTransaction => transaction as TSQLTransaction?;
  set sqlTransaction(TSQLTransaction? aValue) => transaction = aValue; // L3444

  // Cursor（L3010-3013）
  TSQLCursor? get cursor => _statement.cursor;

  // Fetch（L3015-3025）
  // ??? The original source has two `Exit;` statements without setting Result (relying on FPC's uninitialized-
  // Boolean-defaults-to-False behavior), mapped here to `return false`
  @override
  bool fetch() {
    if (cursor == null) return false;
    if (!cursor!.fSelectable) return false;
    if (logEvent(TDBEventType.detFetch)) {
      log(TDBEventType.detFetch, _statement._serverSQL);
    }
    if (!_isEOF) {
      _isEOF = !sqlConnection!.fetch(cursor!);
    }
    return !_isEOF;
  }

  // Execute（L3027-3030）
  void execute() {
    _statement.doExecute();
  }

  // RowsAffected（L3032-3035）
  TRowsCount rowsAffected() => _statement.rowsAffected();

  // LoadField（L3037-3043）
  @override
  bool loadField(TFieldDef fieldDef, TValueBuffer buffer, TBoolRef createBlob) {
    final result =
        sqlConnection!.loadField(cursor!, fieldDef, buffer, createBlob);
    // disable deferred blob loading for "disconnected" datasets (original comment)
    if (result &&
        ftBlobTypes.contains(fieldDef.dataType) &&
        _options.contains(TSQLQueryOption.sqoKeepOpenOnCommit)) {
      createBlob.value = true;
    }
    return result;
  }

  // LoadBlobIntoBuffer（L3045-3049）
  @override
  void loadBlobIntoBuffer(TFieldDef fieldDef, PBufBlobField aBlobBuf) {
    sqlConnection!
        .loadBlobIntoBuffer(fieldDef, aBlobBuf, cursor!, sqlTransaction);
  }

  // InternalAddRecord（L3051-3054）
  @override
  void internalAddRecord(dynamic buffer, bool aAppend) {
    // not implemented - sql dataset (original comment kept as-is)
  }

  // InternalClose（L3056-3080）
  @override
  void internalClose() {
    if (cursor != null) {
      if (cursor!.fSelectable) {
        freeFldBuffers();
      }
      checkUnPrepare();
      // Some SQLConnections does not support statement [un]preparation,
      // so let them do cleanup f.e. cancel pending queries and/or free
      // resultset
      // if not Prepared then FStatement.DoUnprepare; (original comment kept as-is)
    }

    if (defaultFields) {
      destroyFields();
    }

    _isEOF = false;
    _updateQry.value = null; // FreeAndNil
    _insertQry.value = null;
    _deleteQry.value = null;
    // FRecordSize := 0; (original comment kept as-is)

    super.internalClose();
  }

  // InternalInitFieldDefs（L3082-3095）
  @override
  void internalInitFieldDefs() {
    if (_loadingFieldDefs) return;
    _loadingFieldDefs = true;
    try {
      fieldDefs.clear();
      sqlConnection!.addFieldDefs(cursor!, fieldDefs);
// aa ??? issue
      // When a query returns zero rows, the backend (gateway) doesn't return field metadata, so fieldDefs ends up
      // empty → bindFields afterward can't match a persistent field (az…), throwing
      // "Field not found: az" and crashing (symptom: a query with no data crashes).
      // Here, fieldDefs is inferred backward from the "already-defined persistent fields": an empty set never
      // actually reads values anyway — what matters is that the field "exists". lookup / calculated fields aren't physical
      // fields, so they aren't put into fieldDefs.
      if (fieldDefs.count == 0 && fields.count > 0) {
        for (var i = 0; i < fields.count; i++) {
          final f = fields[i];
          if (f.fieldKind != TFieldKind.fkData) continue;
          fieldDefs.addField(f.fieldName, f.dataType, f.size, f.required);
        }
      }
// zz ??? issue
    } finally {
      _loadingFieldDefs = false;
      if (cursor != null) cursor!.fInitFieldDef = false;
    }
  }

  // InternalOpen（L3097-3161）
  @override
  void internalOpen() {
    if (isReadFromPacket()) {
      // When we read from file there is no need for Cursor, also note
      // that Database may not be assigned (original comment kept as-is)
      //FStatement.AllocateCursor;
      //Cursor.FSelectable:=True;
      //Cursor.FStatementType:=stSelect;
      _updateable = true;
    } else {
      checkPrepare();
      if (!cursor!.fSelectable) {
        databaseError(SErrNoSelectStatement, this);
      }

      // Call UpdateServerIndexDefs before Execute, to avoid problems
      // with connections which do not allow processing multiple
      // recordsets at a time. (Microsoft calls this MARS, see bug
      // 13241) (original comment kept as-is)
      if (defaultFields &&
          _updateable &&
          _usePrimaryKeyAsKey &&
          !isUniDirectional) {
        updateServerIndexDefs();
      }

      _statement.execute();
      if (cursor == null || !cursor!.fSelectable) {
        databaseError(SErrNoSelectStatement, this);
      }

      // InternalInitFieldDef is only called after a prepare. i.e. not
      // twice if a dataset is opened - closed - opened. (original comment kept as-is)
      if (cursor!.fInitFieldDef) {
        internalInitFieldDefs();
      }
      if (defaultFields) {
        createFields();

        if (_updateable && _usePrimaryKeyAsKey && !isUniDirectional) {
          for (var counter = 0;
              counter < serverIndexDefs.count;
              counter++) {
            if (serverIndexDefs[counter]
                .options
                .contains(TIndexOption.ixPrimary)) {
              // ExtractStrings([';'],[' '],...) (original semantics: split on ; and
              // trim whitespace)
              final indexFields = serverIndexDefs[counter]
                  .fields
                  .split(";")
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              for (var fieldc = 0; fieldc < indexFields.length; fieldc++) {
                final f = findField(indexFields[fieldc]);
                if (f != null) {
                  f.providerFlags = {
                    ...f.providerFlags,
                    TProviderFlag.pfInKey
                  };
                }
              }
            }
          }
        }
      }
    }
    bindFields(true);

    if (!readOnly && !_updateable && _schemaType == TSchemaType.stNoSchema) {
      if (_deleteSQL.text.trim() != '' ||
          _updateSQL.text.trim() != '' ||
          _insertSQL.text.trim() != '') {
        _updateable = true;
      }
    }

// aa ### flutter extension
    // Applies the alwaysUpdateable set before opening, here (after the updateable determination completes).
    if (_alwaysUpdateable) _updateable = true;
// zz ### flutter extension

    super.internalOpen();
  }

  // InternalRefresh（L3163-3168）
  @override
  void internalRefresh() {
    if (changeCount > 0 &&
        _options.contains(TSQLQueryOption.sqoCancelUpdatesOnRefresh)) {
      cancelUpdates();
    }
    super.internalRefresh();
  }

  // CheckPrepare (L3172-3180) —— the query's own FDoUnPrepare flag
  void checkPrepare() {
    if (!isPrepared()) {
      prepare();
      _doUnprepare = true;
    }
  }

  // CheckUnPrepare（L3182-3190）
  void checkUnPrepare() {
    if (_doUnprepare) {
      _doUnprepare = false;
      unPrepare();
    }
  }

  // ExecSQL（L3193-3207）
  void execSQL() {
    checkPrepare();
    try {
      execute();
      // Always retrieve rows affected (original comment kept as-is)
      _statement.rowsAffected();
      if (_options.contains(TSQLQueryOption.sqoAutoCommit)) {
        sqlTransaction!.commit();
      }
    } finally {
      checkUnPrepare();
      // if not Prepared and (assigned(Database)) and (assigned(Cursor))
      // then SQLConnection.UnPrepareStatement(Cursor); (original comment kept as-is)
    }
  }

  // ApplyUpdates（L3209-3218）
  @override
  void applyUpdates([int maxErrors = 0]) {
    super.applyUpdates(maxErrors);
    if (_options.contains(TSQLQueryOption.sqoAutoCommit)) {
      // Retrieve rows affected for last update. (original comment kept as-is)
      _statement.rowsAffected();
      sqlTransaction!.commit();
    }
  }

  // Post（L3220-3225）
  @override
  void post() {
    super.post();
    if (_options.contains(TSQLQueryOption.sqoAutoApplyUpdates)) {
      applyUpdates();
    }
  }

  // Delete（L3227-3232）
  @override
  void delete() {
    super.delete();
    if (_options.contains(TSQLQueryOption.sqoAutoApplyUpdates)) {
      applyUpdates();
    }
  }

  // SetReadOnly（L3234-3239）
  @override
  void setReadOnly(bool aValue) {
    checkInactive();
    super.setReadOnly(aValue);
  }

  // SetUsePrimaryKeyAsKey（L3255-3264）
  bool get usePrimaryKeyAsKey => _usePrimaryKeyAsKey;
  set usePrimaryKeyAsKey(bool aValue) {
    if (!active) {
      _usePrimaryKeyAsKey = aValue;
    } else {
      // Just temporary, this should be possible in the future (original comment)
      databaseError(SActiveDataset);
    }
  }

  // UpdateServerIndexDefs（L3266-3272）
  void updateServerIndexDefs() {
    _serverIndexDefs.clear();
    if (database != null && _tableName != '') {
      sqlConnection!.updateIndexDefsFor(serverIndexDefs, _tableName);
    }
  }

  // NeedLastInsertID（L3274-3292）
  TField? needLastInsertID() {
    TField? result;
    if (sqlConnection!.connOptions.contains(TConnOption.sqLastInsertID)) {
      var i = 0;
      while (result == null && i < fields.count) {
        result = fields[i];
        if (result.dataType != TFieldType.ftAutoInc || !result.isNull) {
          result = null;
        }
        i++;
      }
    }
    return result;
  }

  // RefreshLastInsertID（L3299-3303）
  bool refreshLastInsertID(TField field) {
    return sqlConnection!.refreshLastInsertID(this, field);
  }

  // ApplyRecUpdate（L3305-3336）
  @override
  void applyRecUpdate(TUpdateKind updateKind) {
    // Moved to connection: the SQLConnection always has more
    // information about types etc. than SQLQuery itself. (original comment kept as-is)
    sqlConnection!.applyRecUpdate(this, updateKind);

    TField? lastIDField;
    if (updateKind == TUpdateKind.ukInsert) {
      lastIDField = needLastInsertID();
    } else {
      lastIDField = null;
    }
    final doRefresh = (updateKind == TUpdateKind.ukModify ||
            updateKind == TUpdateKind.ukInsert) &&
        needRefreshRecord(updateKind);
    if (lastIDField != null || doRefresh) {
      // updates fields directly in record buffer of TBufDataSet
      //   TDataSet buffers are resynchronized at end of ApplyUpdates
      //   process (original comment kept as-is)
      final s = setTempState(TDataSetState.dsRefreshFields);
      try {
        if (lastIDField != null) {
          refreshLastInsertID(lastIDField);
        }
        if (doRefresh) {
          refreshRecord(updateKind);
        }
      } finally {
        restoreState(s);
      }
    }
  }

  // SetPacketRecords（L3338-3344）
  @override
  void setPacketRecords(int aValue) {
    if (aValue == packetRecords) return;
    if (aValue != -1 &&
        _options.contains(TSQLQueryOption.sqoKeepOpenOnCommit)) {
      databaseError(SErrDisconnectedPacketRecords);
    }
    super.setPacketRecords(aValue);
  }

  // GetCanModify（L3347-3355）
  @override
  bool getCanModify() {
    // the test for assigned(Cursor) is needed for the case that the
    // dataset isn't opened (original comment kept as-is)
    if (cursor != null && cursor!.fStatementType == TStatementType.stSelect) {
      return _updateable && !readOnly && !isUniDirectional;
    }
    return false;
  }

  // SetUpdateMode（L3357-3361）
  TUpdateMode get updateMode => _updateMode;
  set updateMode(TUpdateMode aValue) {
    _updateMode = aValue;
  }

  // SetSchemaInfo（L3363-3369）
  void setSchemaInfo(
      TSchemaType aSchemaType, String aSchemaObjectName, String aSchemaPattern) {
    _schemaType = aSchemaType;
    _schemaObjectName = aSchemaObjectName;
    _schemaPattern = aSchemaPattern;
  }

  TSchemaType get schemaType => _schemaType;

  // BeforeRefreshOpenCursor（L3371-3379）
  @override
  void beforeRefreshOpenCursor() {
    // This is only necessary because TIBConnection can not re-open a
    // prepared cursor. In fact this is wrong, but has never led to
    // problems because in SetActive(false) queries are always
    // unprepared. (which is also wrong, but has to be fixed later)
    // (original comment kept as-is)
    if (isPrepared()) {
      sqlConnection!.unPrepareStatement(cursor!);
    }
  }

  // CreateParams（L3381-3384）
  TSQLDBParams createParams() => TSQLDBParams(null);

  // LogEvent（L3386-3389）
  bool logEvent(TDBEventType eventType) {
    return database != null && sqlConnection!.logEvent(eventType);
  }

  // Log（L3391-3404）
  void log(TDBEventType eventType, String msg) {
    if (logEvent(eventType)) {
      var m = msg;
      if (name != '') {
        m = '$name : $m';
      }
      sqlConnection!.log(eventType, m);
    }
  }

  // class function FieldDefsClass (L3406-3409) → TDataSet virtual factory
  // override (convention 2; lazarus_db's fieldDefsClass())
  @override
  TFieldDefs fieldDefsClass() => TSQLDBFieldDefs(this);

  // GetStatementType（L3411-3418）
  TStatementType getStatementType() {
    if (cursor != null) {
      return cursor!.fStatementType;
    }
    return TStatementType.stUnknown;
  }

  TStatementType get statementType => getStatementType();

  // SetOptions（L3430-3437）
  TSQLQueryOptions get options => _options;
  set options(TSQLQueryOptions aValue) {
    if (_options == aValue) return;
    checkInactive();
    _options = aValue;
    if (_options.contains(TSQLQueryOption.sqoKeepOpenOnCommit)) {
      packetRecords = -1;
    }
  }

  // SetInsertSQL / SetUpdateSQL / SetDeleteSQL / SetRefreshSQL
  //（L3449-3467）
  TStringList get insertSQL => _insertSQL;
  set insertSQL(TStringList aValue) => _insertSQL.assign(aValue);
  TStringList get updateSQL => _updateSQL;
  set updateSQL(TStringList aValue) => _updateSQL.assign(aValue);
  TStringList get deleteSQL => _deleteSQL;
  set deleteSQL(TStringList aValue) => _deleteSQL.assign(aValue);
  TStringList get refreshSQL => _refreshSQL;
  set refreshSQL(TStringList aValue) => _refreshSQL.assign(aValue);

  // SetDataSource（L3480-3495）
  void setDataSource(TDataSource? aValue) {
    final ds = dataSource;
    if (!identical(aValue, ds)) {
      if (aValue != null && identical(aValue.dataSet, this)) {
        databaseError(SErrCircularDataSourceReferenceNotAllowed, this);
      }
      if (ds != null) {
        ds.removeFreeNotification(this);
      }
      _statement.dataSource = aValue;
    }
  }

  // GetDataSource（L3497-3504）
  @override
  TDataSource? getDataSource() {
    return _statement.dataSource;
  }

  @override
  TDataSource? get dataSource => getDataSource();
  set dataSource(TDataSource? aValue) => setDataSource(aValue);

  // Notification（L3506-3512）
  @override
  void notification(TComponent aComponent, TOperation operation) {
    super.notification(aComponent, operation);
    if (operation == TOperation.opRemove &&
        identical(aComponent, dataSource)) {
      dataSource = null;
    }
  }

  // DoOnNewRecord（L3514-3519）
  @override
  void doOnNewRecord() {
    super.doOnNewRecord();
    if (sequence!.applyEvent == TSQLSequenceApplyEvent.saeOnNewRecord) {
      sequence!.apply();
    }
  }

  // DoBeforePost（L3521-3526）
  @override
  void doBeforePost() {
    if (state == TDataSetState.dsInsert &&
        sequence!.applyEvent == TSQLSequenceApplyEvent.saeOnPost) {
      sequence!.apply();
    }
    super.doBeforePost();
  }

  // PSGetUpdateException（L3528-3543）
  @override
  EUpdateError psGetUpdateException(Object e, EUpdateError? prev) {
    int prevErrorCode;
    if (prev != null) {
      prevErrorCode = prev.errorCode;
    } else {
      prevErrorCode = 0;
    }

    int errorCode;
    if (e is ESQLDatabaseError) {
      errorCode = e.errorCode;
    } else {
      errorCode = 0;
    }

    return EUpdateError(
        SOnUpdateError, "$e", errorCode, prevErrorCode, e);
  }

  // PSGetTableName（L3545-3548）
  @override
  String psGetTableName() => _tableName;
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 7 —— TSQLQuery (declaration L656-717)
//  A class that simply re-exposes published properties (Dart has no published concept, so it inherits directly);
//  MaxIndexesCount/IndexDefs come from TCustomBufDataset (already provided by the shim)
// ═════════════════════════════════════════════════════════════════════════════

class TSQLQuery extends TCustomSQLQuery {
  TSQLQuery([TComponent? aOwner]) : super(aOwner);

  // The metaclass factory (used by InitialiseUpdateStatement; convention 2)
  @override
  TCustomSQLQuery newInstance(TComponent? aOwner) => TSQLQuery(aOwner);

  // @@@ lookupMap: used by wapform_lookup_box.dart's WapLookupBox.
  // @@@ Corresponds to data_db2.TDataSet.lookupMap —— traverses every row, using keyField as the
  // @@@ key and cols as the display values, building a {key: [display columns...]} map. A read-only traversal, using a
  // @@@ bookmark to save/restore the cursor position.
  Map<String, List<String>> lookupMap(String keyField, List<String> cols) {
    final m = <String, List<String>>{};
    if (!active) return m;
    final bm = getBookmark();
    disableControls();
    try {
      first();
      while (!eof) {
        final k = (findField(keyField)?.asString ?? '').trim();
        if (k.isNotEmpty) {
          m[k] = [
            for (final c in cols) (findField(c)?.asString ?? '').trim()
          ];
        }
        next();
      }
    } finally {
      if (bm != null && bookmarkValid(bm)) gotoBookmark(bm);
      enableControls();
    }
    return m;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SECTION 8 —— TSQLScript / connection registry / TSQLConnector / TConnectionDef
//  Declaration: L721-830; implementation: L3552-4026
// ═════════════════════════════════════════════════════════════════════════════

// ---- TSQLScript (declaration L721-758, implementation L3552-3627) ----------------------------
class TSQLScript extends TCustomSQLScript {
  TSQLScriptDirectiveEvent? onDirective;
  late TCustomSQLQuery _query;
  TDatabase? _database;
  TDBTransaction? _transaction;

  // constructor Create（L3605-3609）
  TSQLScript([TComponent? aOwner]) : super(aOwner) {
    _query = createQuery();
  }

  // destructor Destroy（L3611-3615）
  @override
  void destroy() {
    _query.free();
    super.destroy();
  }

  // ExecuteStatement（L3552-3557）
  @override
  void executeStatement(TStrings sqlStatement, TBoolRef stopExecution) {
    _query.sql.assign(sqlStatement);
    _query.execSQL();
  }

  // ExecuteDirective（L3559-3564）
  @override
  void executeDirective(
      String directive, String argument, TBoolRef stopExecution) {
    if (onDirective != null) {
      onDirective!(this, directive, argument, stopExecution);
    }
  }

  // ExecuteCommit（L3566-3581）
  @override
  void executeCommit([bool commitRetaining = true]) {
    final t = _transaction;
    if (t is TSQLTransaction) {
      if (commitRetaining) {
        t.commitRetaining();
      } else {
        t.commit();
        t.startTransaction();
      }
    } else {
      _transaction!.active = false;
      _transaction!.active = true;
    }
  }

  // SetDatabase（L3583-3586）
  TDatabase? get database => _database;
  set database(TDatabase? value) {
    _database = value;
  }

  // SetTransaction（L3588-3591）
  TDBTransaction? get transaction => _transaction;
  set transaction(TDBTransaction? value) {
    _transaction = value;
  }

  // CheckDatabase（L3593-3597）
  void checkDatabase() {
    if (_database == null) {
      databaseError(SErrNoDatabaseAvailable, this);
    }
  }

  // CreateQuery（L3599-3603）
  TCustomSQLQuery createQuery() {
    final result = TCustomSQLQuery(null);
    result.paramCheck = false; // Do not parse for parameters; breaks use
    // of e.g. select bla into :bla in Firebird procedures (original comment kept as-is)
    return result;
  }

  // Execute（L3617-3622）
  @override
  void execute() {
    _query.database = _database;
    _query.transaction = _transaction;
    super.execute();
  }

  // ExecuteScript（L3624-3627）
  void executeScript() {
    execute();
  }
}

// ---- TConnectionDef (declaration L809-821, implementation L3960-3999) ------------------------
// TLibraryLoadFunction / TLibraryUnLoadFunction（L809-810）
typedef TLibraryLoadFunction = int Function(String s);
typedef TLibraryUnLoadFunction = void Function();

// TSQLConnectionClass = Class of TSQLConnection → a factory typedef (convention 2)
typedef TSQLConnectionClass = TSQLConnection Function(TComponent? aOwner);

class TConnectionDef extends TPersistent {
  // The class function group (L3960-3993) → instance methods (convention 2: a metaclass's
  // class function is carried by an instance method in Dart; the registry builds an instance first, then queries it)
  String typeName() => '';
  TSQLConnectionClass? connectionClass() => null;
  String description() => '';
  String defaultLibraryName() => '';
  TLibraryLoadFunction? loadFunction() => null;
  TLibraryUnLoadFunction? unLoadFunction() => null;
  String loadedLibraryName() => '';

  // ApplyParams（L3995-3999）
  void applyParams(TStrings params, TSQLConnection aConnection) {
    aConnection.params.assign(params);
  }
}

// TConnectionDefClass = class of TConnectionDef → a factory typedef
typedef TConnectionDefClass = TConnectionDef Function();

// ---- The connection registry (L3632-3722) ------------------------------------------------
// Var ConnDefs : TStringList (Sorted, dupError) → a name-sorted-traversal
// Map; AddObject/Objects[]'s string+object pairing is mapped to a Map
Map<String, TConnectionDef>? _connDefs;

// CheckDefs（L3635-3644）
void _checkDefs() {
  _connDefs ??= <String, TConnectionDef>{};
}

// DoneDefs (L3646-3662): Finalization cleanup; handled by the GC in Dart, kept
// for an explicit reset
void doneDefs() {
  _connDefs = null;
}

// GetConnectionDef（L3665-3677）
TConnectionDef? getConnectionDef(String connectorName) {
  _checkDefs();
  return _connDefs![connectorName];
}

// RegisterConnection (L3679-3694): Def.TypeName is a class function on the metaclass —
// in Dart, an instance is built via the factory first, then typeName is read from it (convention 2)
void registerConnection(TConnectionDefClass def) {
  _checkDefs();
  final inst = def();
  final name = inst.typeName();
  // Replaces it if it already exists (original source: Objects[I].Free; Objects[I]:=Def.Create)
  _connDefs![name] = inst;
}

// UnRegisterConnection (L3696-3699) overload: the Def version
void unRegisterConnectionDef(TConnectionDefClass def) {
  unRegisterConnection(def().typeName());
}

// UnRegisterConnection (L3701-3716) overload: the name version
void unRegisterConnection(String connectionName) {
  if (_connDefs != null) {
    _connDefs!.remove(connectionName);
  }
}

// GetConnectionList（L3718-3722）：List.Text := ConnDefs.Text
// (a Sorted list → sorted-by-name traversal)
void getConnectionList(TStrings list) {
  _checkDefs();
  final names = _connDefs!.keys.toList()..sort();
  list.text = names.join("\n");
}

// ---- TSQLConnector (declaration L762-804, implementation L3726-3955) -------------------------
class TSQLConnector extends TSQLConnection {
  TSQLConnection? _proxy;
  String _connectorType = '';

  TSQLConnector([TComponent? aOwner]) : super(aOwner);

  TSQLConnection? get proxy => _proxy;

  // SetConnectorType（L3726-3736）
  String get connectorType => _connectorType;
  set connectorType(String aValue) {
    if (_connectorType != aValue) {
      checkDisConnected();
      if (_proxy != null) {
        freeProxy();
      }
      _connectorType = aValue;
      createProxy();
    }
  }

  // SetTransaction（L3738-3743）
  @override
  set transaction(TSQLTransaction? value) {
    super.transaction = value;
    if (_proxy != null && !identical(_proxy!.transaction, value)) {
      _proxy!._sqlTransaction = value;
    }
  }

  // DoInternalConnect（L3745-3767）
  @override
  void doInternalConnect() {
    super.doInternalConnect();
    checkProxy();
    _proxy!.charSet = charSet;
    _proxy!.databaseName = databaseName;
    _proxy!.hostName = hostName;
    _proxy!.logEvents = logEvents;
    _proxy!.password = password;
    _proxy!.role = role;
    _proxy!.userName = userName;
    _proxy!._sqlTransaction = transaction;
    _proxy!.logEvents = logEvents; // the original source has this duplicated twice; carried over as-is
    _proxy!.onLog = onLog;
    _proxy!.options = options;
    final d = getConnectionDef(connectorType);
    d!.applyParams(params, _proxy!);
    _proxy!.connected = true;
  }

  // DoInternalDisconnect（L3769-3773）
  @override
  void doInternalDisConnect() {
    _proxy!.connected = false;
    super.doInternalDisConnect();
  }

  // CheckProxy（L3775-3779）
  void checkProxy() {
    if (_proxy == null) {
      createProxy();
    }
  }

  // CreateProxy（L3781-3793）
  void createProxy() {
    final d = getConnectionDef(connectorType);
    if (d == null) {
      databaseErrorFmt(SErrUnknownConnectorType, [connectorType], this);
    }
    final cls = d!.connectionClass();
    _proxy = cls!(this);
    fieldNameQuoteChars = _proxy!.fieldNameQuoteChars;
    connOptions = _proxy!.connOptions;
  }

  // FreeProxy（L3795-3799）
  void freeProxy() {
    _proxy!.connected = false;
    _proxy = null; // FreeAndNil
  }

  // ---- The proxy forwarding group (L3801-3955) --------------------------------------------
  @override
  TStatementType strToStatementType(String s) {
    checkProxy();
    return _proxy!.strToStatementType(s);
  }

  @override
  String getAsSQLTextField(TField? field) {
    checkProxy();
    return _proxy!.getAsSQLTextField(field);
  }

  @override
  String getAsSQLTextParam(TParam? param) {
    checkProxy();
    return _proxy!.getAsSQLTextParam(param);
  }

  @override
  dynamic getHandle() {
    checkProxy();
    return _proxy!.getHandle();
  }

  @override
  TSQLCursor allocateCursorHandle() {
    checkProxy();
    return _proxy!.allocateCursorHandle();
  }

  @override
  void deAllocateCursorHandle(TSQLCursor cursor) {
    checkProxy();
    _proxy!.deAllocateCursorHandle(cursor);
  }

  @override
  TSQLHandle allocateTransactionHandle() {
    checkProxy();
    return _proxy!.allocateTransactionHandle();
  }

  @override
  void prepareStatement(TSQLCursor cursor, TSQLTransaction? aTransaction,
      String buf, TParams? aParams) {
    checkProxy();
    _proxy!.prepareStatement(cursor, aTransaction, buf, aParams);
  }

  @override
  void execute(TSQLCursor cursor, TSQLTransaction? aTransaction,
      TParams? aParams) {
    checkProxy();
    _proxy!.execute(cursor, aTransaction, aParams);
  }

  @override
  TRowsCount rowsAffected(TSQLCursor? cursor) {
    checkProxy();
    return _proxy!.rowsAffected(cursor);
  }

  @override
  bool fetch(TSQLCursor cursor) {
    checkProxy();
    return _proxy!.fetch(cursor);
  }

  @override
  void addFieldDefs(TSQLCursor cursor, TFieldDefs fieldDefs) {
    checkProxy();
    _proxy!.addFieldDefs(cursor, fieldDefs);
  }

  @override
  void unPrepareStatement(TSQLCursor cursor) {
    checkProxy();
    _proxy!.unPrepareStatement(cursor);
  }

  @override
  void freeFldBuffers(TSQLCursor cursor) {
    checkProxy();
    _proxy!.freeFldBuffers(cursor);
  }

  @override
  String getNextValueSQL(String sequenceName, int incrementBy) {
    return proxy!.getNextValueSQL(sequenceName, incrementBy);
  }

  @override
  bool loadField(TSQLCursor cursor, TFieldDef fieldDef, TValueBuffer buffer,
      TBoolRef createBlob) {
    checkProxy();
    return _proxy!.loadField(cursor, fieldDef, buffer, createBlob);
  }

  @override
  void loadBlobIntoBuffer(TFieldDef fieldDef, PBufBlobField aBlobBuf,
      TSQLCursor cursor, TSQLTransaction? aTransaction) {
    checkProxy();
    _proxy!.loadBlobIntoBuffer(fieldDef, aBlobBuf, cursor, aTransaction);
  }

  @override
  dynamic getTransactionHandle(TSQLHandle trans) {
    checkProxy();
    return _proxy!.getTransactionHandle(trans);
  }

  @override
  bool commit(TSQLHandle trans) {
    checkProxy();
    return _proxy!.commit(trans);
  }

  @override
  bool rollBack(TSQLHandle trans) {
    checkProxy();
    return _proxy!.rollBack(trans);
  }

  @override
  bool startDBTransaction(TSQLHandle trans, String aParams) {
    checkProxy();
    return _proxy!.startDBTransaction(trans, aParams);
  }

  @override
  void commitRetaining(TSQLHandle trans) {
    checkProxy();
    _proxy!.commitRetaining(trans);
  }

  @override
  void rollBackRetaining(TSQLHandle trans) {
    checkProxy();
    _proxy!.rollBackRetaining(trans);
  }

  @override
  void updateIndexDefsFor(TIndexDefs indexDefs, String tableName) {
    checkProxy();
    _proxy!.updateIndexDefsFor(indexDefs, tableName);
  }

  @override
  String getSchemaInfoSQL(
      TSchemaType schemaType, String schemaObjectName, String schemaPattern) {
    checkProxy();
    return _proxy!.getSchemaInfoSQL(
        schemaType, schemaObjectName, schemaPattern);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Initialization / Finalization（L4022-4026）
//  The Pascal unit's Finalization calls DoneDefs — Dart has no unit lifecycle,
//  doneDefs() is kept as an explicit call (the GC handles the actual release)
//  —— sqldb.pp translation complete for the whole file ——
// ═════════════════════════════════════════════════════════════════════════════

// ═════════════════════════════════════════════════════════════════════════════
//  Merged in below from lazarus_sqldb_wap.dart (that file has been deleted, its contents moved entirely into this one)
//  TWapSQLConnection + the WapDb HTTP driver (replacing libmysqlclient)
//
//  This section is original code (not translated from FPC/Lazarus sources).
//  But it depends on the sqldb.pp translation in the same file, so it carries the same license to keep the overall licensing simple.
//
//  License: GNU Lesser General Public License v2.1, with the static linking exception (Modified LGPL)
//        See the accompanying COPYING.LGPL.txt and COPYING.modifiedLGPL.txt.
//
//  Copyright (c) 2026 Minhong Information Co., Ltd. (wapform.com)
//
//  @@@ This whole section is newly-written bridging code (not a translation of FPC source), occupying the
//  @@@ position that each database driver unit (sqlite3conn.pp / mysqlconn.pp …) occupies in the FPC ecosystem:
//  @@@ it implements TSQLConnection's 17 abstract driver methods, with the backend talking to the WapDb HTTP
//  @@@ gateway (the same localhost:3000 backend as wap_db_driver.dart).
//
//  @@@ The sync/async boundary design (the most important thing in this section):
//  @@@   FPC's sqldb driver interface is synchronous, and lazarus_db/lazarus_sqldb's entire
//  @@@   pipeline (open→internalOpen→execute→fetch→loadField) is synchronous too;
//  @@@   Dart's HTTP is async-only. The solution:
//  @@@   1. SELECT: the async facade openAsync() first calls prepare(), then awaits the backend to fetch the
//  @@@      whole batch of rows into the cursor, then calls the faithful, unmodified synchronous open() to run the full
//  @@@      pipeline — fetch()/loadField() then read synchronously from the preloaded rows in the cursor.
//  @@@   2. DML: the synchronous execute() pushes the SQL+params into the connection's pending-send queue,
//  @@@      and the async facade (execSQLAsync/applyUpdatesAsync) later awaits
//  @@@      flushPending() to send it all at once.
//  @@@   Trade-offs (stated honestly):
//  @@@   - DML backend errors only surface when flushed (not at the moment of post()/execSQL()
//  @@@     itself); applyUpdatesAsync propagates flush errors back to the caller.
//  @@@   - rowsAffected() doesn't have a real value before flushing (returns -1), so
//  @@@     the scoApplyUpdatesChecksRowsAffected option can't be used with this driver.
//  @@@   - the backend has no transaction API (wap_db_driver only has rawQuery/exec); commit
//  @@@     = flushing the queue, rollback = discarding the unsent queue; already-sent statements can't be rolled back.
// ═════════════════════════════════════════════════════════════════════════════

// ---------------------------------------------------------------------
//  @@@ The driver interface aligns with wap_db_driver.dart's IWapDbDriver shape, but parameters
//  @@@ are positional (List<Object?>) instead — because TWapSQLConnection's
//  @@@ prepareStatement already uses the faithfully-translated TParams.parseSQL to convert :name into
//  @@@ psInterbase's ?, so the bridge side doesn't need to parse it again.
// ---------------------------------------------------------------------
class LazarusDbResult {
  final bool success;
  final List<Map<String, dynamic>> data;
  final String? errorMessage;
  final int affectedRows;

  // @@@ Optional field metadata: an empty result set can't infer column names from data; if the backend can supply
  // @@@ a list of column names (the SELECT's projected columns), correct fieldDefs can still be built even for an empty result.
  // @@@ When not provided (null), falls back to "inferring from the first row" behavior.
  final List<String>? columns;

  const LazarusDbResult({
    required this.success,
    this.data = const [],
    this.errorMessage,
    this.affectedRows = 0,
    this.columns,
  });

  factory LazarusDbResult.error(String message) =>
      LazarusDbResult(success: false, data: const [], errorMessage: message);
}

abstract class LazarusDbDriver {
  /// A SELECT-type query, returns rows
  Future<LazarusDbResult> rawQuery(String sql, [List<Object?> args]);

  /// Executes an INSERT/UPDATE/DELETE etc.; carries back affectedRows if a value is given
  Future<LazarusDbResult> executeRawSql(String sql, [List<Object?> args]);
}

// ---------------------------------------------------------------------
//  @@@ TWapCursor: this driver's cursor. Every FPC driver works this way — a TSQLCursor
//  @@@ subclass carries whatever state its backend needs (sqlite3's stmt pointer, mysql's
//  @@@ result handle…); here it holds "preloaded rows + traversal index + parameter mapping".
// ---------------------------------------------------------------------
class TWapCursor extends TSQLCursor {
  String preparedSQL = '';
  TParamBinding paramBinding = <int>[];
  List<Map<String, dynamic>> rows = const [];
  List<String>? columns; // @@@ column-name metadata provided by the backend (nullable)
  int rowIndex = -1;
  bool executed = false; // whether openAsync has already finished preloading
}

class _PendingDML {
  final String sql;
  final List<Object?> args;
  _PendingDML(this.sql, this.args);
}

// @@@ Transaction handle: the backend has no transaction API, so the handle is just a marker for queue ownership
class TWapTransactionHandle extends TSQLHandle {
  bool active = false;
}

// ---------------------------------------------------------------------
//  TWapSQLConnection
// ---------------------------------------------------------------------
class TWapSQLConnection extends TSQLConnection {
  // @@@ The backend driver (the HTTP bridge is provided by lazarus_wapdb_bridge.dart)
  LazarusDbDriver? driver;

  // @@@ The DML pending-send queue (see design note point 2 in the file header)
  final List<_PendingDML> _pendingDML = [];
  TRowsCount _lastRowsAffected = -1;

  TWapSQLConnection([TComponent? aOwner, this.driver]) : super(aOwner) {
    // @@@ The backend is a WapDb gateway (a MySQL-family database): handles both '' doubling and \ escaping;
    // @@@ DatabaseName isn't needed (already bound on the gateway side)
    connOptions = {
      TConnOption.sqSupportParams,
      TConnOption.sqEscapeRepeat,
      TConnOption.sqEscapeSlash,
      TConnOption.sqSupportEmptyDatabaseName,
    };
    // @@@ MariaDB/MySQL quotes field names with backticks `col`, not standard SQL's double quotes "col"
    //     (used by applyUpdates when building INSERT/UPDATE via fieldNameQuoteChars).
    fieldNameQuoteChars = backtickQuotes;
  }

  void _checkDriver() {
    if (driver == null) {
      databaseError("@@@ TWapSQLConnection.driver is not set"
          '(pass it via registerLazarusDbDriver or the constructor)', this);
    }
  }

  @override
  void doInternalConnect() {
    super.doInternalConnect();
    _checkDriver();
    // @@@ An HTTP gateway has no "connect" action; connected is a pure status flag
  }

  @override
  void doInternalDisConnect() {
    super.doInternalDisConnect();
    _pendingDML.clear();
  }

  // ---- Cursor allocation -------------------------------------------------------------
  @override
  TSQLCursor allocateCursorHandle() => TWapCursor();

  @override
  void deAllocateCursorHandle(TSQLCursor cursor) {
    final c = cursor as TWapCursor;
    c.rows = const [];
    c.rowIndex = -1;
    c.executed = false;
    c.fPrepared = false;
  }

  // ---- Prepare: :name → ? (psInterbase), the correspondence table is stored on the cursor --------------------
  @override
  void prepareStatement(TSQLCursor cursor, TSQLTransaction? aTransaction,
      String buf, TParams? aParams) {
    final c = cursor as TWapCursor;
    var s = buf;
    c.paramBinding = <int>[];
    if (aParams != null && aParams.count > 0) {
      // Does parameter translation using the faithfully-translated DoParseSQL (handles comments/quotes/:: cast)
      s = aParams.parseSQL(s, false,
          escapeSlash: connOptions.contains(TConnOption.sqEscapeSlash),
          escapeRepeat: connOptions.contains(TConnOption.sqEscapeRepeat),
          parameterStyle: TParamStyle.psInterbase,
          paramBinding: c.paramBinding);
    }
    c.preparedSQL = s;
    // @@@ Whether it's queryable: a SELECT or a schema query
    c.fSelectable = c.fStatementType == TStatementType.stSelect ||
        c.fSchemaType != TSchemaType.stNoSchema;
    c.fPrepared = true;
  }

  @override
  void unPrepareStatement(TSQLCursor cursor) {
    final c = cursor as TWapCursor;
    c.fPrepared = false;
    c.rows = const [];
    c.rowIndex = -1;
    c.executed = false;
  }

  // ---- Parameter values → the backend's positional parameters ------------------------------------------------
  // @@@ DateTime → string conversion (the gateway expects 'yyyy-mm-dd hh:nn:ss'); everything else passed through as-is
  List<Object?> _bindArgs(TWapCursor c, TParams? aParams) {
    if (aParams == null || c.paramBinding.isEmpty) return const [];
    // @@@ paramBinding is generated in prepareStatement from that same set of aParams via parseSQL,
    //     so under normal circumstances the index is always valid. But if the caller swaps or shortens params
    //     after prepare, this would throw a RangeError and crash the whole save operation —— a bounds check was added,
    //     falling back to null; the backend gets at most one empty parameter, which is better than the whole page crashing.
    final result = <Object?>[];
    for (final idx in c.paramBinding) {
      if (idx < 0 || idx >= aParams.count) {
        result.add(null);
        continue;
      }
      final p = aParams[idx];
      result.add(p.isNull ? null : _toBackend(p.value));
    }
    return result;
  }

  Object? _toBackend(dynamic v) {
    if (v is DateTime) {
      return _formatDT(v);
    }
    if (v is Uint8List) return v;
    return v;
  }

  String _formatDT(DateTime dt) {
    String p2(int x) => x.toString().padLeft(2, "0");
    return '${dt.year.toString().padLeft(4, '0')}-${p2(dt.month)}-${p2(dt.day)}'
        ' ${p2(dt.hour)}:${p2(dt.minute)}:${p2(dt.second)}';
  }

  // ---- Execute (synchronous) --------------------------------------------------------
  @override
  void execute(TSQLCursor cursor, TSQLTransaction? aTransaction,
      TParams? aParams) {
    final c = cursor as TWapCursor;
    if (c.fSelectable) {
      // @@@ SELECT data must be preloaded via openAsync first (see the design note in the file header)
      if (!c.executed) {
        databaseError(
            "@@@ SELECT needs to be asynchronously preloaded via openAsync() before open() can be called; "
            'please change q.open() to await q.openAsync()', this);
      }
      c.rowIndex = -1; // resets the traversal position
    } else {
      // @@@ DML: pushed into the pending-send queue, actually sent when flushPending() runs
      _pendingDML.add(_PendingDML(c.preparedSQL, _bindArgs(c, aParams)));
      _lastRowsAffected = -1;
    }
  }

  // ---- Fetch / AddFieldDefs / LoadField --------------------------------------
  @override
  bool fetch(TSQLCursor cursor) {
    final c = cursor as TWapCursor;
    if (c.rowIndex + 1 >= c.rows.length) return false;
    c.rowIndex++;
    return true;
  }

  @override
  void addFieldDefs(TSQLCursor cursor, TFieldDefs fieldDefs) {
    final c = cursor as TWapCursor;
    // @@@ Type inference: the gateway returns JSON rows with no field-type metadata,
    // @@@ so every row is scanned and the type is decided from the first non-null value; an all-null column is treated as
    // @@@ ftString. A string field's size is set to the actual maximum length seen (at least 255).
    if (c.rows.isEmpty) {
      // @@@ An empty result set: if there's columns metadata, builds ftString fields (type unknown,
      // @@@ uniformly treated as strings — an empty set never actually reads values anyway, what matters is that the field exists);
      // @@@ without it, fieldDefs stays empty (a backend limitation)
      final cols = c.columns;
      if (cols != null) {
        var no = 1;
        for (final n in cols) {
          addFieldDef(fieldDefs, no, n, TFieldType.ftString, 255, 0,
              false, false, false);
          no++;
        }
      }
      return;
    }
    final names = c.rows.first.keys.toList();
    var fieldNo = 1;
    for (final n in names) {
      dynamic sample;
      for (final row in c.rows) {
        if (row[n] != null) {
          sample = row[n];
          break;
        }
      }
      TFieldType ft;
      var size = 0;
      if (sample == null) {
        ft = TFieldType.ftString;
        size = 255;
      } else if (sample is int) {
        // @@@ A Dart-web trap: JS only has a `number` type, so `15000.0 is int` would
        // @@@ return true. If ftInteger were inferred from this, a subsequently-stored value with a decimal (like
        // @@@ 12345.67) would get rounded to 12345 by TLongintField. The pragmatic solution:
        // @@@ always infer ftFloat for numeric fields (it can losslessly hold integer values too); when integer
        // @@@ semantics are needed, the caller can convert via asInteger when reading it.
        // @@@ (On native platforms, an int also goes through this same ftFloat branch, so the behavior is consistent)
        ft = TFieldType.ftFloat;
      } else if (sample is double) {
        ft = TFieldType.ftFloat;
      } else if (sample is bool) {
        ft = TFieldType.ftBoolean;
      } else if (sample is DateTime) {
        ft = TFieldType.ftDateTime;
      } else if (sample is Uint8List) {
        ft = TFieldType.ftBlob;
        size = 0;
      } else {
        ft = TFieldType.ftString;
        var maxLen = 0;
        for (final row in c.rows) {
          final v = row[n];
          if (v != null && '$v'.length > maxLen) maxLen = '$v'.length;
        }
        size = maxLen < 255 ? 255 : maxLen;
      }
      addFieldDef(fieldDefs, fieldNo, n, ft, size, 0, false, false, false);
      fieldNo++;
    }
  }

  @override
  bool loadField(TSQLCursor cursor, TFieldDef fieldDef, TValueBuffer buffer,
      TBoolRef createBlob) {
    final c = cursor as TWapCursor;
    if (c.rowIndex < 0 || c.rowIndex >= c.rows.length) return false;
    final v = c.rows[c.rowIndex][fieldDef.name];
    if (v == null) return false;
    createBlob.value = false;
    // @@@ DateTime fields: the gateway may return a string; converted back to DateTime here
    if ((fieldDef.dataType == TFieldType.ftDateTime ||
            fieldDef.dataType == TFieldType.ftDate ||
            fieldDef.dataType == TFieldType.ftTime) &&
        v is String) {
      buffer.value = DateTime.tryParse(v.replaceFirst(" ", "T")) ?? v;
    } else {
      buffer.value = v;
    }
    return true;
  }

  @override
  void loadBlobIntoBuffer(TFieldDef fieldDef, PBufBlobField aBlobBuf,
      TSQLCursor cursor, TSQLTransaction? aTransaction) {
    final c = cursor as TWapCursor;
    final v =
        (c.rowIndex >= 0 && c.rowIndex < c.rows.length)
            ? c.rows[c.rowIndex][fieldDef.name]
            : null;
    final bb = TBlobBuffer();
    if (v is Uint8List) {
      bb.buffer = v;
      bb.size = v.length;
    } else if (v is String) {
      bb.buffer = Uint8List.fromList(v.codeUnits);
      bb.size = v.length;
    } else {
      bb.buffer = Uint8List(0);
      bb.size = 0;
    }
    aBlobBuf.blobBuffer = bb;
  }

  // ---- RowsAffected ----------------------------------------------------------
  @override
  TRowsCount rowsAffected(TSQLCursor? cursor) => _lastRowsAffected;

  // ---- Transactions (@@@ the backend has no transaction API, see cost #3 in the file header's design note) ------------------
  @override
  TSQLHandle allocateTransactionHandle() => TWapTransactionHandle();

  @override
  dynamic getTransactionHandle(TSQLHandle trans) => trans;

  @override
  bool startDBTransaction(TSQLHandle trans, String aParams) {
    (trans as TWapTransactionHandle).active = true;
    return true;
  }

  @override
  bool commit(TSQLHandle trans) {
    // @@@ commit = marks the transaction as closed; the queue's actual sending happens in flushPending().
    // @@@ If there's still unsent DML in the queue, this can't send it synchronously (HTTP is async),
    // @@@ so commitAsync()/applyUpdatesAsync() are the complete flow to use.
    (trans as TWapTransactionHandle).active = false;
    return true;
  }

  @override
  bool rollBack(TSQLHandle trans) {
    // @@@ rollback = discards the not-yet-sent queue; already-sent statements can't be rolled back (a backend limitation)
    _pendingDML.clear();
    (trans as TWapTransactionHandle).active = false;
    return true;
  }

  @override
  void commitRetaining(TSQLHandle trans) {
    // @@@ Sending the queue is delegated to flushPending(); the transaction stays open
  }

  @override
  void rollBackRetaining(TSQLHandle trans) {
    _pendingDML.clear();
  }

  // ---- @@@ Sending the queue (the async boundary) ---------------------------------------------
  int get pendingCount => _pendingDML.length;

  Future<void> flushPending() async {
    _checkDriver();
    while (_pendingDML.isNotEmpty) {
      final p = _pendingDML.first;
      final res = await driver!.executeRawSql(p.sql, p.args);
      if (!res.success) {
        // @@@ Failed entries stay at the head of the queue (the caller can check pendingCount to decide whether to retry or
        // @@@ discard via rollback); the error is thrown back to the caller
        throw ESQLDatabaseError.createFmt(
            res.errorMessage ?? 'execute failed', [], this, 0, "");
      }
      _lastRowsAffected = res.affectedRows;
      _pendingDML.removeAt(0);
    }
  }
}

// ---------------------------------------------------------------------
//  @@@ The async facade: wraps "await preload/send" around the faithfully-synchronous pipeline.
//  @@@ Attached to TCustomSQLQuery via an extension; rcp078 callers look like this:
//  @@@    await q.openAsync();          // replaces q.open()
//  @@@    await q.execSQLAsync();       // replaces q.execSQL()
//  @@@    q.post();                     // post unchanged (synchronous, goes into the update log)
//  @@@    await q.applyUpdatesAsync();  // replaces q.applyUpdates()+commit
// ---------------------------------------------------------------------
extension TWapSQLQueryAsync on TCustomSQLQuery {
  TWapSQLConnection get _wapConn {
    final c = sqlConnection;
    if (c is! TWapSQLConnection) {
      databaseError("@@@ The openAsync family requires a TWapSQLConnection", this);
    }
    return c as TWapSQLConnection;
  }

  /// @@@ SELECT: prepare → await fetches the whole batch → loads it into the cursor → synchronous open()
  Future<void> openAsync() async {
    final conn = _wapConn;
    conn._checkDriver();
    conn.maybeConnect();
    prepare(); // goes through the faithful pipeline: macro expansion/GetStatementInfo/prepareStatement
    final c = cursor as TWapCursor;
    if (c.fSelectable) {
      final res = await conn.driver!
          .rawQuery(c.preparedSQL, conn._bindArgs(c, params));
      if (!res.success) {
        throw ESQLDatabaseError.createFmt(
            res.errorMessage ?? 'query failed', [], conn, 0, "");
      }
      c.rows = res.data;
      c.columns = res.columns;
      c.executed = true;
    }
    open(); // the faithful, unmodified synchronous pipeline (execute will see executed=true)
  }

  /// @@@ DML: synchronous execSQL into the queue → await to send it.
  /// @@@ Returns rowsAffected after flushing (the value cached inside the synchronous execSQL is
  /// @@@ -1 before flushing; what's returned here is the real backend value)
  Future<TRowsCount> execSQLAsync() async {
    final conn = _wapConn;
    conn.maybeConnect();
    execSQL(); // pushed into the queue (including the synchronous commit marker for sqoAutoCommit)
    await conn.flushPending();
    return conn._lastRowsAffected;
  }

  /// @@@ Replays the update log → await to send it. Backend errors surface here.
  Future<void> applyUpdatesAsync([int maxErrors = 0]) async {
    final conn = _wapConn;
    applyUpdates(maxErrors); // calls applyRecUpdate entry by entry → execute pushes into the queue
    await conn.flushPending();
  }

  /// @@@ Closes and reopens (the original Refresh preserves the position near the cursor; this
  /// @@@ backend has no cursor, so this is an honest reopen)
  Future<void> refreshAsync() async {
    close();
    await openAsync();
  }
}

// aa ### flutter extension
// ══════════════════════════════════════════════════════════════════
//  The original Lazarus version: TSQLQuery → mysqlconn.pas → libmysqlclient(C) → MariaDB
//  This version (Web):  TSQLQuery → TWapSQLConnection → WapDbBridgeDriver
//                 → WapDb(HTTP) → gateway(localhost:3000) → MariaDB
//
//  A browser can't load a C library and can't open a raw TCP connection to a database directly, so that last mile
//  at the very bottom is replaced with HTTP instead. This section isn't a translation of LCL source — it's an implementation replacing libmysqlclient.
//  (The former contents of wap_db.dart, merged in here; that file can be deleted.)
// ══════════════════════════════════════════════════════════════════

/// The HTTP client for the backend gateway.
// aa ### flutter extension
/// The SQL diagnostic-output switch. Set to true while debugging save issues, and every SQL statement sent, with its parameters,
/// is printed to the console. Recommended to leave off normally, to avoid excessive output.
const bool kWapSqlLog = true;
// zz ### flutter extension

class WapDb {
  static const _base = 'http://localhost:3000';

  // ── Single query ─────────────────────────────────────────
  // SELECT returns a List<Map>; DML returns an empty list. Throws an exception on HTTP or DB errors.
  static Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic> params = const [],
  ]) async {
    final res = await http.post(
      Uri.parse("$_base/query"),
      headers: {'Content-Type': "application/json"},
      body: jsonEncode({'sql': sql, "params": params}),
    );
    if (res.statusCode != 200) {
      final body = _tryDecode(res.body);
      throw Exception(body?['error'] ?? 'HTTP ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = data['rows'];
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  // ── Transaction: sends multiple statements at once (atomicity) ──────────────────
  // statements: [{ 'sql': '...', 'params': [...] }, ...]
  static Future<void> transaction(
      List<Map<String, dynamic>> statements) async {
// aa ### flutter extension
    // @@@ SQL diagnostic output: every DML statement passes through here, the single point they all go through.
    //     When debugging a save issue (e.g. "a particular record just never saves no matter what"), without the actual SQL you can only
    //     guess — printing the statement and its parameters here makes it immediately obvious whether the WHERE condition is right.
    //     Set kWapSqlLog to false when it's not needed.
    if (kWapSqlLog) {
      for (final st in statements) {
        debugPrint('[WapDb] SQL: ${st['sql']}');
        debugPrint('[WapDb] PRM: ${st['params']}');
      }
    }
// zz ### flutter extension
    final res = await http.post(
      Uri.parse("$_base/transaction"),
      headers: {'Content-Type': "application/json"},
      body: jsonEncode({'statements': statements}),
    );
    if (res.statusCode != 200) {
      final body = _tryDecode(res.body);
      throw Exception(body?['error'] ?? 'HTTP ${res.statusCode}');
    }
  }

  // ── Exec: a shortcut method for a single DML statement (internally goes through a transaction) ────────────
  static Future<void> exec(
    String sql, [
    List<dynamic> params = const [],
  ]) async {
    await transaction([{'sql': sql, "params": params}]);
  }

  // ── Ping: checks whether the backend is alive ────────────────────────────────────
  static Future<bool> ping() async {
    try {
      final res = await http.get(Uri.parse("$_base/ping"));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Map<String, dynamic>? _tryDecode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

/// The adapter: wires WapDb's HTTP calls into the LazarusDbDriver that TWapSQLConnection expects.
/// TWapSQLConnection is constructed with a const WapDbBridgeDriver() injected.
class WapDbBridgeDriver implements LazarusDbDriver {
  const WapDbBridgeDriver();

  @override
  Future<LazarusDbResult> rawQuery(String sql,
      [List<Object?> args = const []]) async {
    try {
      final rows = await WapDb.rawQuery(sql, args);
      return LazarusDbResult(
          success: true, data: List<Map<String, dynamic>>.from(rows));
    } catch (e) {
      return LazarusDbResult.error("$e");
    }
  }

  @override
  Future<LazarusDbResult> executeRawSql(String sql,
      [List<Object?> args = const []]) async {
    try {
      await WapDb.exec(sql, args);
      // WapDb.exec doesn't return affectedRows; carried back here once the gateway provides it in the future.
      return const LazarusDbResult(success: true, affectedRows: -1);
    } catch (e) {
      return LazarusDbResult.error("$e");
    }
  }
}
// zz ### flutter extension
