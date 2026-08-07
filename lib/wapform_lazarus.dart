// ═════════════════════════════════════════════════════════════════════════════
//  lazarus_wapform.dart
//  WML tag engine (expression / condition / setvar / invoke / dbquery)
//
//  This file is original code (not translated from FPC/Lazarus sources).
//  But it depends on the LGPL translation modules in this repo, so it
//  carries the same license to keep the overall licensing simple.
//
//  License: GNU Lesser General Public License v2.1, with the static
//  linking exception (Modified LGPL). See the accompanying
//  COPYING.LGPL.txt and COPYING.modifiedLGPL.txt.
//
//  Copyright (c) 2026 (your name or organization)
// ═════════════════════════════════════════════════════════════════════════════

// ════════════════════════════════════════════════════════════════════════════
//  lazarus_wapform.dart —— shared core module for rcp078 (the Lazarus
//  version of wapform.dart)
//  ────────────────────────────────────────────────────────────────────────
//  Corresponds to: wapform.dart (the BDE version, shared by agp102/ag6006)
//
//  @@@ This version has migrated from the "simplified foundation" to the
//  @@@ "full line-by-line translation" stack:
//  @@@   lazarus_db.dart + lazarus_sqldb.dart + lazarus_sqldb_wap.dart
//  @@@ Migration differences: DataSetState→TDataSetState, setFieldValue→setFieldValues,
//  @@@ q.sql=string→q.sql.text, execSqlAsync→execSQLAsync,
//  @@@ unprepare→unPrepare, gotoBookmark now takes a TBookmark (Uint8List).
//  @@@ DbQuery.connection needs a TWapSQLConnection with TSQLTransaction
//  @@@ already attached (a query inherits connection.transaction automatically
//  @@@ when created).
//
//  Differences from wapform.dart:
//    - DataSetRegistry: the map's value type changed from data_db2.dart's
//      TDataSet to lazarus_db_dataset.dart's TDataSet (same name, but
//      completely different classes that cannot be mixed — this is the
//      fundamental reason this is a separate file)
//    - DbTable has no counterpart: Lazarus/SQLdb has no TTable concept;
//      whole-table usage always goes through DbQuery with
//      SELECT * FROM table instead. findTable was dropped too, leaving
//      only findQuery (which covers what findTable used to be used for)
//    - DbQuery's constructor gained a `connection` (TSQLConnection)
//      parameter: the original code only recognized a databaseName
//      string (presumably resolved to an actual connection via some
//      global session/database registry). The Lazarus version has no
//      such global registration mechanism, so the caller must pass the
//      TSQLConnection object in directly
//    - invoke()'s beginwalk/endwalk have no direct equivalent method;
//      mapped to disableControls/enableControls for now (see the ???
//      note below)
//
//  The expression/condition/setvar/expandSql/expandText string/expression
//  processing logic is nearly identical to the original code
//  (wapform_expression.dart is a data-layer-agnostic shared core that
//  didn't need to change); only the places inside setvar() that call
//  TDataSet methods were mapped to the new method names.
//
//  Depends on: lazarus_db_types.dart, lazarus_db_dataset.dart,
//  lazarus_sqldb_connection.dart, lazarus_sqldb_query.dart, wapform_expression.dart
// ════════════════════════════════════════════════════════════════════════════

import 'dart:typed_data'; // @@@ used for TBookmark (Uint8List)

import 'lazarus_db.dart';
import 'lazarus_sqldb.dart';
import 'wapform_expression.dart';


// ── Global engine state (private, same as upstream — external code always
//    goes through the public functions below) ──────────────────────────
WapEvaluator? _currentEvaluator;
DataSetRegistry? _currentRegistry;

void useEngine(WapEvaluator ev, [DataSetRegistry? registry]) {
  _currentEvaluator = ev;
  _currentRegistry = registry;
  if (registry != null) {
    ev.datasetResolver = registry.resolveDataSet;
  }
}

WapEvaluator? get currentEvaluator => _currentEvaluator;
DataSetRegistry? get currentRegistry => _currentRegistry;

/// Expression — empty Str → null; returns the value on success, null on
/// failure (prints red-colored [ERROR] text).
dynamic expression(String str, {bool nul = true}) {
  if (str.isEmpty) return null;
  final ev = _currentEvaluator;
  if (ev == null) return null;
  final v = ev.eval(str, nul: nul);
  if (ev.hasError) {
    // ignore: avoid_print
    print('<font color="#ff0000">[ERROR] $str # ${ev.lastError}</font>');
    return null;
  }
  return v;
}

/// condition — empty Str → false; returns bool on success, false on failure.
bool condition(String str) {
  if (str.isEmpty) return false;
  final ev = _currentEvaluator;
  if (ev == null) return false;
  final r = ev.cond(str);
  if (ev.hasError) {
    // ignore: avoid_print
    print('<font color="#ff0000">[ERROR] $str # ${ev.lastError}</font>');
    return false;
  }
  return r;
}

bool _isAlphaCh(String c) {
  final u = c.codeUnitAt(0);
  return (u >= 48 && u <= 57) ||
      (u >= 65 && u <= 90) ||
      (u >= 97 && u <= 122) ||
      c == '_' ||
      c == '.';
}

String _p2(int n) => n.toString().padLeft(2, "0");

String _wrapStr(String v) {
  final escaped = v.replaceAll("'", "''");
  return "'$escaped'";
}

String _valToStr(dynamic v, String mode) {
  // @@@ null: for text/sqlraw (fragment variables like $S) → empty string;
  //     for quoted etc. → the SQL keyword NULL. It used to always return
  //     "Null", which broke SQL like "$S order by" into the syntactically
  //     invalid "Null order by".
  if (v == null) return (mode == 'text' || mode == 'sqlraw') ? '' : 'NULL';
  if (v is bool) return v ? 'TRUE' : "FALSE";
  if (v is int) return v.toString();
  if (v is double) {
    if (v == v.truncateToDouble() && !v.isInfinite && !v.isNaN) {
      return v.toInt().toString();
    }
    return v.toString(); // @@@ Dart's shortest round-trip representation: 26.9→"26.9", no more exploding floating-point tails
  }
  if (v is DateTime) {
    final d = '${v.year}-${_p2(v.month)}-${_p2(v.day)}';
    final s = (v.hour == 0 && v.minute == 0 && v.second == 0)
        ? d
        : "$d ${_p2(v.hour)}:${_p2(v.minute)}:${_p2(v.second)}";
    return mode == 'quoted' ? _wrapStr(s) : s;
  }
  // @@@ An ISO datetime string returned by the backend
  // (2020-01-01T16:00:00.000Z) → displayed as local YYYY/MM/DD
  if (v is String && (mode == 'text' || mode == 'quoted')) {
    if (RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}').hasMatch(v)) {
      final dt = DateTime.tryParse(v)?.toLocal();
      if (dt != null) {
        final s = '${dt.year}/${_p2(dt.month)}/${_p2(dt.day)}';
        return mode == 'quoted' ? _wrapStr(s) : s;
      }
    }
  }
  return (mode == 'text' || mode == 'sqlraw') ? v.toString() : _wrapStr(v.toString());
}

/// Shared scanner: $var / $(expr) / $$ → evaluate and convert to string per
/// mode, finally replacing ` with '.
String _expand(String s, String mode) {
  final buf = StringBuffer();
  final len = s.length;
  int i = 0, segStart = 0;
  while (i < len) {
    if (s[i] == r'$') {
      buf.write(s.substring(segStart, i));
      i++;
      if (i < len && s[i] == r'$') {
        buf.write(r"$");
        i++;
        segStart = i;
        continue;
      }
      String expr;
      if (i < len && s[i] == '(') {
        i++;
        int depth = 1;
        final eb = StringBuffer();
        while (i < len && depth > 0) {
          if (s[i] == '(') depth++;
          else if (s[i] == ')') {
            depth--;
            if (depth == 0) {
              i++;
              break;
            }
          }
          if (depth > 0) eb.write(s[i]);
          i++;
        }
        expr = eb.toString();
      } else {
        final start = i;
        while (i < len && _isAlphaCh(s[i])) i++;
        expr = s.substring(start, i);
      }
      if (expr.isNotEmpty) buf.write(_valToStr(expression(expr), mode));
      segStart = i;
      continue;
    }
    i++;
  }
  if (i > segStart) buf.write(s.substring(segStart, i));
  return buf.toString().replaceAll("`", "'");
}

String expandText(String s) => _expand(s, "text");
String expandSql(String s) => _expand(s, "sqlraw");
String expandSqlAuto(String s) => _expand(s, "sql");
String expandSqlQuoted(String s) => _expand(s, "quoted");

/// @@@ Notification fired when a variable is rewritten by setvar (lets the
///     UI sync the value back into an input field).
///     _varCtl only does one-way sync from "input field → variable". Without
///     this notify-back mechanism, when something like a WML
///     <function id="clr"> clears a variable via setvar, the on-screen
///     TextField wouldn't clear along with it (only a lookup field would
///     update, because it syncs itself in didUpdateWidget).
final List<void Function(String name)> varChangeHooks =
    <void Function(String name)>[];

void _notifyVarChanged(String name) {
  if (varChangeHooks.isEmpty) return;
  for (final h in List<void Function(String)>.of(varChangeHooks)) {
    h(name);
  }
}

/// setvar — corresponds to WML's <setvar name= value=>.
void setvar(String name, dynamic value) {
  final ev = _currentEvaluator;
  if (ev == null) return;
  final dynamic v = (value is String) ? expression(value) : value;

  final lb = name.indexOf("[");
  final rb = name.indexOf("]");
  if (lb > 0 && rb > lb) {
    final aryName = name.substring(0, lb);
    final idxExpr = name.substring(lb + 1, rb);
    final k = expression(idxExpr);
    final idx = (k is int) ? k : int.tryParse("$k") ?? 0;
    final cur = ev.getVar(aryName);
    final list = (cur is List) ? cur : <dynamic>[];
    while (list.length <= idx) {
      list.add(null);
    }
    list[idx] = v;
    ev.setVar(aryName, list);
    _notifyVarChanged(aryName);
    return;
  }

  final dot = name.indexOf(".");
  if (dot > 0 && _currentRegistry != null) {
    final dsName = name.substring(0, dot);
    final field = name.substring(dot + 1);
    final ds = _currentRegistry!.find(dsName);
    if (ds != null && ds.active) {
      // Corresponds to lazarus_db_types.dart's DataSetState (the original
      // code used TTDataSetState.dsBrowse; here it's TDataSetState.dsBrowse)
      if (ds.state == TDataSetState.dsBrowse) ds.edit();
      ds.setFieldValues(field, v);
      return;
    }
  }

  ev.setVar(name, v);
  _notifyVarChanged(name);
}

/// invoke — corresponds to WML's <invoke instance="ds" method="..." params=... result=...>.
dynamic invoke(String instance, String method, {dynamic params, String? result}) {
  final ds = _currentRegistry?.find(instance);
  if (ds == null) return null;
  dynamic ret;
  switch (method.toLowerCase()) {
    case 'first':
      ds.first();
      break;
    case 'next':
      ds.next();
      break;
    case 'prior':
      ds.prior();
      break;
    case 'last':
      ds.last();
      break;
    case 'edit':
      ds.edit();
      break;
    case 'post':
      ds.post();
      break;
    case 'insert':
      ds.insert();
      break;
    case 'append':
      ds.append();
      break;
    case 'cancel':
      ds.cancel();
      break;
    case 'delete':
      ds.delete();
      break;
    case 'disablecontrols':
      ds.disableControls();
      break;
    case 'enablecontrols':
      ds.enableControls();
      break;
    // ??? beginwalk/endwalk were separate methods in the original code
    // (data_db2.dart's TDataSet has beginWalk/endWalk; their exact
    // semantics are unclear — the upstream implementation wasn't
    // available this time). Guessing it means "start/end a traversal
    // pass", which in effect is close to disableControls/enableControls
    // (suspend event broadcasting). Mapped to those two for now; revisit
    // here if the semantics turn out to be more than that.
    case 'beginwalk':
      ds.disableControls();
      break;
    case 'endwalk':
      ds.enableControls();
      break;
    case 'getbookmark':
      ret = ds.getBookmark();
      break;
    case 'gotobookmark':
      // @@@ In the full version, TBookmark is a Uint8List (4-byte index);
      // @@@ kept compatible with old callers that pass an int
      // @@@ (converted to the equivalent bookmark)
      if (params is Uint8List) {
        ds.gotoBookmark(params);
      } else {
        final idx = (params is int) ? params : int.tryParse("$params") ?? 0;
        final bd = ByteData(4);
        bd.setInt32(0, idx, Endian.little);
        ds.gotoBookmark(bd.buffer.asUint8List());
      }
      break;
    case 'freebookmark':
      break; // no need to free (Dart GC)
    default:
      break;
  }
  if (result != null && result.isNotEmpty) {
    _currentEvaluator?.setVar(result, ret);
  }
  return ret;
}

// ── _DataSetExprAdapter: TDataSet → ExprDataSet (lets expressions read sh.Amount)
class _DataSetExprAdapter extends ExprDataSet {
  final TDataSet _ds;
  _DataSetExprAdapter(this._ds);

  @override
  int get recordCount => _ds.recordCount;
  @override
  bool get bof => _ds.bof;
  @override
  bool get eof => _ds.eof;
  @override
  String get state {
    switch (_ds.state) {
      case TDataSetState.dsBrowse:
        return 'BROWSE';
      case TDataSetState.dsEdit:
        return 'EDIT';
      case TDataSetState.dsInsert:
        return 'INSERT';
      case TDataSetState.dsInactive:
        return 'INACTIVE';
      default:
        // @@@ This used to be toString().replaceFirst("TDataSetState.ds", "").
        //     All 14 members of TDataSetState currently carry a "ds"
        //     prefix, so this works fine functionally, but enum.toString()'s
        //     format is a Dart SDK implementation detail, not a guaranteed
        //     spec — .name is the officially supported way to get the
        //     name. The prefix is now only stripped if present, so nothing
        //     breaks if that ever changes.
        final n = _ds.state.name;
        return (n.startsWith('ds') ? n.substring(2) : n).toUpperCase();
    }
  }

  @override
  bool hasField(String name) => _ds.findField(name) != null;

  // @@@ When a WML <field> has no type= attribute, the field gets built as
  //     a TStringField and reads out as a string; but the underlying DB
  //     field may actually be numeric. Expression `+` treats a String
  //     operand as "string concatenation" ("1540" + "77" → "154077",
  //     wildly inflating unpaid amounts), while `-` forces a numeric
  //     conversion. In real WapForm, fields are built according to the DB
  //     field's actual type, so this converts numeric fields back to
  //     numbers based on FieldDefs' real type, restoring the intended
  //     arithmetic semantics.
  static const Set<TFieldType> _numericFts = {
    TFieldType.ftSmallint,
    TFieldType.ftInteger,
    TFieldType.ftWord,
    TFieldType.ftFloat,
    TFieldType.ftCurrency,
    TFieldType.ftBCD,
    TFieldType.ftAutoInc,
    TFieldType.ftLargeint,
  };

  // @@@ Cache: dataset → {lowercase field name: is it a numeric field}.
  //     fieldDefs.find() does a linear scan, and each comparison calls
  //     toUpperCase() twice; on the hot path of "reading values field by
  //     field" this seriously slows things down (dropdown menus, per-row
  //     report evaluation nearly grind to a halt). Here the whole type
  //     table is built once, then every lookup afterward is O(1). Rebuilt
  //     when the field count changes.
  static final Expando<Map<String, bool>> _numFldCache =
      Expando<Map<String, bool>>();

  Map<String, bool> _numFldMap() {
    final defs = _ds.fieldDefs;
    var m = _numFldCache[_ds];
    if (m == null || m.length != defs.count) {
      m = <String, bool>{};
      for (var i = 0; i < defs.count; i++) {
        final fd = defs[i];
        m[fd.name.toLowerCase()] = _numericFts.contains(fd.dataType);
      }
      _numFldCache[_ds] = m;
    }
    return m;
  }

  @override
  dynamic fieldValue(String name) {
    final v = _ds.fieldValues(name);
    if (v is String) {
      final t = v.trim();
      if (t.isNotEmpty && _numFldMap()[name.toLowerCase()] == true) {
        final n = num.tryParse(t);
        if (n != null) return n;
      }
    }
    return v;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  DataSetRegistry — corresponds to the original code's global object
//  list; the map's value type is now the lazarus version of TDataSet.
// ═════════════════════════════════════════════════════════════════════════════
class DataSetRegistry {
  final Map<String, TDataSet> _dataSets = {};

  Map<String, TDataSet> get dataSets => _dataSets;
  List<String> get registeredIds => _dataSets.keys.toList();
  int get count => _dataSets.length;
  bool contains(String id) => _dataSets.containsKey(id);
  TDataSet? find(String id) => _dataSets[id.toLowerCase()]; // @@@ case-insensitive

  // findQuery covers the usage that the original code's findTable was
  // used for (Lazarus/SQLdb has no TTable; whole-table queries are also
  // TSQLQuery)
  TSQLQuery? findQuery(String id) => _dataSets[id.toLowerCase()] is TSQLQuery ? _dataSets[id.toLowerCase()] as TSQLQuery : null; // @@@ case-insensitive

  void put(String id, TDataSet ds) => _dataSets[id.toLowerCase()] = ds; // @@@ case-insensitive

  ExprDataSet? resolveDataSet(String name) {
    final ds = _dataSets[name.toLowerCase()]; // @@@ case-insensitive → both $tt and $TT resolve
    return ds == null ? null : _DataSetExprAdapter(ds);
  }

  void release(String id) {
    final ds = _dataSets.remove(id.toLowerCase()); // @@@ case-insensitive
    if (ds != null && ds.active) ds.close();
  }

  void releaseAll() {
    for (final ds in _dataSets.values) {
      if (ds.active) ds.close();
    }
    _dataSets.clear();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  DbQuery — handles only TSQLQuery (SELECT / ExecSQL).
//  Corresponds to the original code's DbQuery; since there's no TTable,
//  DbTable has no counterpart, and whole-table usage also goes through
//  here uniformly (SELECT * FROM table).
// ═════════════════════════════════════════════════════════════════════════════
class DbQuery {
  final String databaseName;
  final DataSetRegistry registry;

  // ??? Differs from the original code: the original only recognized a
  // databaseName string, whereas this needs an actual TSQLConnection
  // object to be able to actually issue the query (the Lazarus version
  // has no global session/database registry that could resolve a
  // connection from a string).
  final TSQLConnection connection;

  DbQuery({
    required this.registry,
    required this.connection,
    this.databaseName = 'TestDB',
  });

  /// Runs a SELECT. With an id: creates and registers it the first time,
  /// reuses it thereafter; with an empty id: a one-off query that isn't registered.
  Future<TSQLQuery> query(
    String id,
    String sql, {
    Map<String, dynamic>? params,
    bool readOnly = false,
  }) async {
    final sqlToRun = (params == null) ? expandSql(sql) : sql;

    if (id.isEmpty) {
      final q = TSQLQuery();
      q.database = connection;
      _applySqlAndParams(q, sqlToRun, params);
      await q.openAsync();
      return q;
    }

    final existing = registry.find(id);
    if (existing is TSQLQuery) {
      existing.disableControls();
      try {
        if (existing.active) existing.close();
        existing.unPrepare();
        _applySqlAndParams(existing, sqlToRun, params);
        await existing.openAsync();
      } finally {
        existing.enableControls();
      }
      return existing;
    } else {
      final q = TSQLQuery();
      q.database = connection;
      _applySqlAndParams(q, sqlToRun, params);
      await q.openAsync();
      registry.put(id, q);
      return q;
    }
  }

  /// Runs an INSERT / UPDATE / DELETE (an id-less ExecSQL). Returns the
  /// number of affected rows.
  Future<int> exec(String sql, {Map<String, dynamic>? params}) async {
    final sqlToRun = (params == null) ? expandSql(sql) : sql;
    final q = TSQLQuery();
    q.database = connection;
    _applySqlAndParams(q, sqlToRun, params);
    return await q.execSQLAsync();
  }

  void _applySqlAndParams(TSQLQuery q, String sql, Map<String, dynamic>? params) {
    // q.sql = sql already auto-runs parseSql(doCreate:true) to build the
    // params (the behavior of lazarus_sqldb_query.dart's Step8), so there's
    // no need for the extra q.params.clear() call the original code made.
    q.sql.text = sql;
    if (params != null) {
      params.forEach((key, value) {
        final p = q.params.paramByName(key);
        if (value == null) {
          p.clear();
        } else if (value is int) {
          p.asInteger = value;
        } else if (value is double) {
          p.asFloat = value;
        } else if (value is bool) {
          p.asBoolean = value;
        } else {
          p.asString = value.toString();
        }
      });
    }
  }
}
