// ignore_for_file: unused_element, unused_field
import 'package:flutter/material.dart';

import 'package:wapform_flutter/lazarus_db.dart';
import 'package:wapform_flutter/lazarus_sqldb.dart';
import 'package:wapform_flutter/lazarus_dbgrids.dart';
import 'package:wapform_flutter/lazarus_dbctrls.dart';
import 'package:wapform_flutter/lazarus_stdctrls.dart';
import 'package:wapform_flutter/lazarus_extctrls.dart';
import 'package:wapform_flutter/wapform_lookup_box.dart';
import 'package:wapform_flutter/wapform_expression.dart';
import 'package:wapform_flutter/wapform_lazarus.dart';

const String _kDb = 'WapProductionDB';

TWapSQLConnection? _wapConn;
TWapSQLConnection _conn() {
  if (_wapConn == null) {
    final c = TWapSQLConnection(null, const WapDbBridgeDriver());
    c.databaseName = _kDb;
    final tx = TSQLTransaction();
    tx.database = c;
    _wapConn = c;
  }
  return _wapConn!;
}

TField _fieldOf(String type) {
  switch (type) {
    case 'integer':
      return TIntegerField();
    case 'float':
    case 'currency':
      return TFloatField();
    case 'date':
    case 'datetime':
    case 'time':
      return TDateTimeField();
    case 'boolean':
      return TBooleanField();
    default:
      // size 0 = no length limit (the default 20 cut longer values such as file names)
      return TStringField()..size = 0;
  }
}

void _setDateOnlyText(TField f) {
  f.onGetText = (fld, ref, displayText) {
    final raw = fld.value;
    final s = raw == null ? '' : "$raw";
    if (!displayText) {
      ref.value = s;
      return;
    }

    final hasZone = s.endsWith('Z') ||
        RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(s);
    if (hasZone) {
      final dt = DateTime.tryParse(s);
      if (dt != null) {
        final l = dt.toLocal();
        final mm = l.month.toString().padLeft(2, '0');
        final dd = l.day.toString().padLeft(2, '0');
        ref.value = "${l.year}-$mm-$dd";
        return;
      }
    }

    final t = s.indexOf("T");
    final sp = s.indexOf(" ");
    var cut = -1;
    if (t >= 0) cut = t;
    if (sp >= 0 && (cut < 0 || sp < cut)) cut = sp;
    ref.value = cut > 0 ? s.substring(0, cut) : s;
  };
}

void _fld(TSQLQuery q, String name, String label,
    {String type = '', bool dateOnly = false, bool readOnly = false}) {
  final f = _fieldOf(type);
  f.fieldName = name;
  f.fieldKind = TFieldKind.fkData;
  if (label != '') f.displayLabel = label;
  if (dateOnly) _setDateOnlyText(f);
  f.readOnly = readOnly;
  f.dataSet = q;
}

void _key(TSQLQuery q, String name, String label,
    {String type = '', bool dateOnly = false}) {
  final f = _fieldOf(type);
  f.fieldName = name;
  f.fieldKind = TFieldKind.fkData;
  f.providerFlags = {
    TProviderFlag.pfInKey,
    TProviderFlag.pfInUpdate,
    TProviderFlag.pfInWhere,
  };
  if (label != '') f.displayLabel = label;
  if (dateOnly) _setDateOnlyText(f);
  f.dataSet = q;
}

void _lkp(TSQLQuery q, String name, String label,
    {required String keyField,
    required String lookupKey,
    required String resultField,
    required TDataSet lookupDs,
    String type = '',
    bool dateOnly = false}) {
  final f = _fieldOf(type);
  f.fieldName = name;
  f.fieldKind = TFieldKind.fkLookup;
  f.keyFields = keyField;
  f.lookupDataSet = lookupDs;
  f.lookupKeyFields = lookupKey;
  f.lookupResultField = resultField;
  f.lookupCache = false;
  f.providerFlags = {};
  if (label != '') f.displayLabel = label;
  if (dateOnly) _setDateOnlyText(f);
  f.dataSet = q;
}

void _cal(TSQLQuery q, String name, String label, {String type = 'integer'}) {
  final f = _fieldOf(type);
  f.fieldName = name;
  f.fieldKind = TFieldKind.fkCalculated;
  f.providerFlags = {};
  if (label != '') f.displayLabel = label;
  f.dataSet = q;
}

String _str(TDataSet ds, String name) => ds.findField(name)?.asString ?? '';

Future<void> _saveAsync(TSQLQuery q) async {
  if (dsEditModes.contains(q.state)) q.post();
  await q.applyUpdatesAsync();
}

Future<void> _delAsync(TSQLQuery q) async {
  q.delete();
  await q.applyUpdatesAsync();
}

Future<void> _execSql(String sql) async {
  final q = TSQLQuery();
  q.database = _conn();
  q.sql.text = sql;
  await q.execSQLAsync();
  q.free();
}

const _kBlue   = Color(0xFF1A6FB5);
const _kBorder = Color(0xFFD3D1C7);

const bool _kDbgLayout = false;
const Color _kDbgTbl = Color(0xFFE53935);
const Color _kDbgTd  = Color(0xFF1E88E5);

const double _kChar = 8.0;
double _w(num size) => size * _kChar;

TColumn _column(TDBGridColumns cols, String f, String cap, num size,
    {bool ro = false, TAlignment align = TAlignment.taLeftJustify}) {
  final c = cols.add();
  c.fieldName = f;
  c.width = _w(size).round();
  c.readOnly = ro;
  c.alignment = align;
  c.title.caption = cap;
  return c;
}

void showApp902(BuildContext context) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const App902CardP(),
    );
class App902CardP extends StatefulWidget {
  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  const App902CardP({super.key, this.ev, this.reg});
  @override
  State<App902CardP> createState() =>
      _App902CardPState();
}

class _App902CardPState
    extends State<App902CardP> {
  late final WapEvaluator _ev = widget.ev ?? WapEvaluator();
  late final DataSetRegistry _reg = widget.reg ?? DataSetRegistry();
  bool get _ownsReg => widget.reg == null;
  final List<String> _ownedDs = []; // datasets this card created

  TSQLQuery dbquery(String id, String sqlText,
      {void Function(TSQLQuery ds)? define}) {
    final existing = _reg.find(id);
    TSQLQuery q;
    var isNew = false;
    if (existing is TSQLQuery) {
      q = existing;
    } else {
      q = TSQLQuery();
      q.database = _conn();
      q.name = id;
      _reg.put(id, q);
      isNew = true;
      _ownedDs.add(id);
    }
    if (sqlText.isNotEmpty) {
      final sql = expandSql(sqlText);
      if (q.active) q.close();
      q.unPrepare();
      q.sql.text = sql;
    }
    q.alwaysUpdateable = true;
    if (isNew && define != null) define(q);
    return q;
  }

  // [diag] ds "mnu": foreign=0 declared=1 lookupSrc=0 fields=6
  // [diag] ds "login": foreign=0 declared=1 lookupSrc=0 fields=5
  // [diag] ds "users": foreign=0 declared=1 lookupSrc=1 fields=0
  late final TSQLQuery _users = dbquery("users", r"select * from users");
  late final TSQLQuery _mnu =
      dbquery("mnu", r"select * from mnu order by id", define: (ds) {
    _key(ds, "id", "id");
    _fld(ds, "sub", "sub");
    _fld(ds, "title", "Title");
    _fld(ds, "href", "Client Target");
    _fld(ds, "http", "Server Target");
    _fld(ds, "active", "active");

    ds.beforeDelete = (d) {
      Future.microtask(() { if (mounted) _mnuBeforeDeleteAsync(); });
    };
    ds.afterScroll = (d) {
      Future.microtask(() { if (mounted) _mnuAfterScroll(); });
    };
  });
  late final TSQLQuery _login =
      dbquery("login", r"select * from login order by id, itm", define: (ds) {
    ds.updateTableName = "login";
    _key(ds, "id", "id");
    _key(ds, "itm", "itm");
    _fld(ds, "uid", "User");
    _fld(ds, "r", "Read");
    _fld(ds, "w", "Write");

    ds.onNewRecord = (d) {
      setvar("login.id", "mnu.id");
      setvar("login.r", "1");
      setvar("login.w", "1");
      setvar("login.itm", "FORMAT('%2.2d',maxitm.itm+1)");
    };
  });

  late final TDataSource _mnuSrc;
  late final TDataSource _loginSrc;

  late final TDBGridColumns _mnuCols = _buildMnuCols();
  late final TDBGridColumns _loginCols = _buildLoginCols();

  Map<String, List<String>> get _usersRows =>
      _users.lookupMap("userid", const ["userid"]);

  bool   _loading = true;
  String _error   = '';

  @override
  void initState() {
    super.initState();
    varChangeHooks.add(_varSync);
    _conn();

    _mnuSrc = TDataSource()..dataSet = _mnu;
    _loginSrc = TDataSource()..dataSet = _login;
    _bindEngine();

    _load();
  }

  @override
  void dispose() {
    varChangeHooks.remove(_varSync);

    for (final c in _varCtls.values) {
      c.dispose();
    }
    if (_ownsReg) {
    _mnuSrc.dataSet = null;
    _loginSrc.dataSet = null;
    _mnu.free();
    _login.free();
    _users.free();
      _reg.releaseAll();
    } else {
      // shared registry: drop the datasets this card created, so a
      // reopened card re-creates them with events bound to its new State
      for (final id in _ownedDs) {
        _reg.release(id);
      }
    }
    super.dispose();
  }

  void _bindEngine() {
    useEngine(_ev, _reg);
    _reg.put("mnu", _mnu);
    _reg.put("login", _login);
    _reg.put("users", _users);
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = ''; });
    try {
      for (final id in ['users']) {
        try {
          final ds = _reg.findQuery(id)!;
          await dbquery(id, ds.sql.text).openAsync();
        } catch (e) {
          debugPrint("[app902] $id skip: $e");
        }
      }

      await dbquery("mnu", r"select * from mnu order by id").openAsync();
      // Detail is opened with a filter carried by mnu's afterscroll
      await _mnuAfterScroll();
      if (!_users.active) await _users.openAsync();
    } catch (e, st) {
      debugPrint("[app902] _load ERROR: $e\n$st");
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  TDBGridColumns _buildMnuCols() {
    final c = TDBGridColumns();
    _column(c, "id", "id", 10);
    _column(c, "sub", "sub", 10);
    _column(c, "title", "Title", 30);
    _column(c, "href", "Client Target", 30);
    _column(c, "active", "active", 10);
    return c;
  }
  TDBGridColumns _buildLoginCols() {
    final c = TDBGridColumns();
    _column(c, "itm", "itm", 10);
    _column(c, "uid", "User", 10);  // lookup="users;userid"
    _column(c, "w", "Write", 10);
    return c;
  }

  Future<void> _mnuInsert({bool atEnd = false}) async {
    try {
      if (atEnd) {
        _mnu.append();
      } else {
        _mnu.insert();
      }
      await _mnuAfterScroll();
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Add failed: $e");
    }
  }

  Future<void> _mnuPost() async {
    try {
      await _saveAsync(_mnu);
      _snack("Saved", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Save failed: $e");
    }
  }

  Future<void> _mnuDelete() async {
    try {
      await _execSql(expandSql(r"delete from login where id='$mnu.id'"));
      await _delAsync(_mnu);
      await _mnuAfterScroll();
      _snack("Deleted", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Delete failed: $e");
    }
  }

  String _mnuLastKey = '\u0000';
  Future<void> _mnuAfterScroll() async {
    final k = _str(_mnu, "id");
    if (k == _mnuLastKey) return;
    _mnuLastKey = k;
    // masterfields="id": requeries detail login whenever master mnu's cursor moves
    await dbquery("login", r"select * from login where id='$mnu.id' order by id, itm").openAsync();
    if (mounted) setState(() {});
  }

  Future<void> _mnuBeforeDeleteAsync() async {
    await _execSql(expandSql(r"delete from login where id='$mnu.id'"));
    if (mounted) setState(() {});
  }

  Future<void> _loginInsert({bool atEnd = false}) async {
    if (_str(_mnu, "id").isEmpty) {
      _snack("Please create the main record first");
      return;
    }
    try {
      await dbquery("maxitm", r"select max(itm) as itm from login where id='$mnu.id'").openAsync();
      if (atEnd) {
        _login.append();
      } else {
        _login.insert();
      }
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Add failed: $e");
    }
  }

  Future<void> _loginPost() async {
    try {
      await _saveAsync(_login);
      // The detail's afterPost/afterDelete runs a totals function that changes the master; the master needs to be saved back too
      if (dsEditModes.contains(_mnu.state)) await _saveAsync(_mnu);
      _snack("Saved", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Save failed: $e");
    }
  }

  Future<void> _loginDelete() async {
    try {
      await _delAsync(_login);
      // The detail's afterPost/afterDelete runs a totals function that changes the master; the master needs to be saved back too
      if (dsEditModes.contains(_mnu.state)) await _saveAsync(_mnu);
      _snack("Deleted", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Delete failed: $e");
    }
  }

  void _snack(String msg, {bool ok = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _alert(String msg) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(), child: const Text("OK")),
        ],
      ),
    );
  }

  void _log(String msg) => debugPrint("[app902][log] $msg");

  Widget _line(List<Widget> children) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Wrap(
            spacing: 0,
            runSpacing: 1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children),
      );

  Widget _lbl(String s) => Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Text(s, style: const TextStyle(fontSize: 13)),
      );

  Widget _lblR(String s, double w) => SizedBox(
        width: w,
        child: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(s, style: const TextStyle(fontSize: 13)),
          ),
        ),
      );

  Widget _tdf(double weight, List<Widget> children, {String al = 'L'}) =>
      Expanded(
        flex: weight.round() < 1 ? 1 : weight.round(),
        child: _dbgBox(
            _kDbgTd,
            Column(
                crossAxisAlignment: _xa(al),
                mainAxisSize: MainAxisSize.min,
                children: children)),
      );

  CrossAxisAlignment _xa(String al) => al == 'R'
      ? CrossAxisAlignment.end
      : al == 'C'
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start;

  Widget _dbgBox(Color c, Widget child) => _kDbgLayout
      ? Container(
          decoration: BoxDecoration(border: Border.all(color: c, width: 1)),
          child: child)
      : child;

  Widget _tbl(List<Widget> children, {bool border = false}) {
    if (!border) {
      return _dbgBox(
        _kDbgTbl,
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );
    }
    return _dbgBox(
      _kDbgTbl,
      Container(
        decoration: BoxDecoration(border: Border.all(color: _kBorder)),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _vdiv() => Container(width: 1, color: _kBorder);

  Widget _td(double width, List<Widget> children, {String al = 'L'}) =>
      SizedBox(
        width: width,
        child: _dbgBox(
            _kDbgTd,
            Column(
                crossAxisAlignment: _xa(al),
                mainAxisSize: MainAxisSize.min,
                children: children)),
      );

  static const _kNumericFieldTypes = <TFieldType>{
    TFieldType.ftSmallint,
    TFieldType.ftInteger,
    TFieldType.ftWord,
    TFieldType.ftFloat,
    TFieldType.ftCurrency,
    TFieldType.ftBCD,
    TFieldType.ftAutoInc,
    TFieldType.ftLargeint,
    TFieldType.ftFMTBcd,
  };

  bool _looksNumeric(TDataSource src, String field) {
    final f = src.dataSet?.findField(field);
    if (f == null) return false;
    if (_kNumericFieldTypes.contains(f.dataType)) return true;
    if (f.dataType != TFieldType.ftString) return false;
    final s = f.asString.trim();
    if (s.isEmpty) return false;
    return num.tryParse(s) != null;
  }

  Widget _edit(TDataSource src, String field, num size,
      {bool ro = false,
      bool memo = false,
      double order = 0,
      FocusNode? focusNode,

      bool autofocus = false,

      bool roFocusable = false}) {
    final align = _looksNumeric(src, field) ? TextAlign.right : TextAlign.left;
    Widget e = SizedBox(
      width: _w(size) < 44 ? 44.0 : _w(size),
      height: memo ? 56 : 28,

      child: memo
          ? TDBMemo(
              dataSource: src,
              dataField: field,
              readOnly: ro,
              focusNode: focusNode,
              autofocus: autofocus,
              font: const TextStyle(fontSize: 13),
            )
          : TDBEdit(
              dataSource: src,
              dataField: field,
              readOnly: ro,
              focusNode: focusNode,
              autofocus: autofocus,
              font: const TextStyle(fontSize: 13),
              textAlign: align,
            ),
    );
    if (ro && !roFocusable) {
      return ExcludeFocusTraversal(child: e);
    }
    if (order > 0) {
      e = FocusTraversalOrder(order: NumericFocusOrder(order), child: e);
    }
    return e;
  }

  Widget _lookupBox(TSQLQuery own, TSQLQuery lk, String field, num size,
      String keyField, List<String> displayFields,
      {double order = 0, Future<void> Function(String key)? onPicked}) {
    Widget b = SizedBox(
      width: _w(size),
      height: 28,
      child: WapLookupBox(
        value: _str(own, field),
        width: _w(size),
        dataSet: lk,
        keyField: keyField,
        displayFields: displayFields,
        colWidths: List<double>.filled(displayFields.length, 160),
        onChanged: (key) async {
          if (onPicked != null) {
            await onPicked(key);
            return;
          }
          if (own.state == TDataSetState.dsBrowse) own.edit();
          final v = key.replaceAll("'", "''");
          setvar("${own.name}.$field", "'$v'");
          own.dataEvent(TDataEvent.deRecordChange, 0);
          if (mounted) setState(() {});
        },
      ),
    );
    if (order > 0) {
      b = FocusTraversalOrder(order: NumericFocusOrder(order), child: b);
    }
    return b;
  }

  final Map<String, TextEditingController> _varCtls = {};

  bool _varSyncPending = false;

  void _varSync(String name) {
    final c = _varCtls[name];
    if (c != null) {
      final v = _str2(name);
      if (c.text != v) {
        c.value = TextEditingValue(
          text: v,
          selection: TextSelection.collapsed(offset: v.length),
        );
      }
    }

    if (_varSyncPending || !mounted) return;
    _varSyncPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _varSyncPending = false;
      if (mounted) setState(() {});
    });
  }

  void _setVarStr(String name, String v) {
    final e = v.replaceAll("'", "''");
    setvar(name, "'$e'");
  }

  TextEditingController _varCtl(String name, String init) =>
      _varCtls.putIfAbsent(name, () {
        var v = '';
        try {
          v = expression(init).toString();
        } catch (_) {}
        if (v == 'null') v = '';
        _setVarStr(name, v);
        final c = TextEditingController(text: v);
        c.addListener(() => _setVarStr(name, c.text));
        return c;
      });

  Widget _vedit(String name, String init, num size, {double order = 0}) {
    final ctl = _varCtl(name, init);
    final base = size * _kChar;
    final minW = base < 44 ? 44.0 : base.toDouble();
    final maxW = (base * 2) < 120 ? 120.0 : (base * 2).toDouble();
    final w = ((ctl.text.length + 2) * _kChar).clamp(minW, maxW).toDouble();
    Widget e = SizedBox(
      width: w,
      height: 28,
      child: TextField(
        controller: ctl,
        onChanged: (_) {
          if (mounted) setState(() {});
        },
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            border: OutlineInputBorder()),
      ),
    );
    if (order > 0) {
      e = FocusTraversalOrder(order: NumericFocusOrder(order), child: e);
    }
    return e;
  }

  Widget _vcheck(String name, String onValue) {
    final on = _str2(name) == onValue;
    return SizedBox(
      width: 30,
      height: 26,
      child: Checkbox(
        value: on,
        onChanged: (v) {
          setvar(name, (v ?? false) ? "'$onValue'" : "''");
          if (mounted) setState(() {});
        },
      ),
    );
  }

  Widget _vselect(String name, String title, int columns,
      List<String> items, List<String> values,
      {double? width, double? height}) {
    if (items.isEmpty) return const SizedBox.shrink();
    var cur = _str2(name);
    if (cur.isEmpty) {
      cur = values.first;
      setvar(name, "'$cur'");
    }
    var idx = values.indexOf(cur);
    if (idx < 0) idx = -1;
    return TRadioGroup(
      caption: title,
      items: items,
      itemIndex: idx,
      columns: columns,
      width: width,
      height: height,
      onSelectionChanged: (i) {
        setvar(name, "'${values[i]}'");
        if (mounted) setState(() {});
      },
    );
  }

  Widget _dbselect(TDataSource src, String field, String title, int columns,
      List<String> items, List<String> values,
      {double? width, double? height}) {
    if (items.isEmpty) return const SizedBox.shrink();
    return TDBRadioGroup(
      dataSource: src,
      dataField: field,
      caption: title,
      items: items,
      values: values,
      columns: columns,
      width: width,
      height: height,
    );
  }

  Widget _vlookup(String name, String init, TSQLQuery lk, num size,
      String keyField, List<String> displayFields, {double order = 0}) {
    _varCtl(name, init);
    Widget b = SizedBox(
      width: _w(size),
      height: 28,
      child: WapLookupBox(
        value: _str2(name),
        width: _w(size),
        dataSet: lk,
        keyField: keyField,
        displayFields: displayFields,
        colWidths: List<double>.filled(displayFields.length, 160),
        onChanged: (key) {
          _setVarStr(name, key);
          _varCtls[name]?.text = key;
          if (mounted) setState(() {});
        },
      ),
    );
    if (order > 0) {
      b = FocusTraversalOrder(order: NumericFocusOrder(order), child: b);
    }
    return b;
  }

  void _refreshVars() {
    for (final e in _varCtls.entries) {
      final v = _ev.getVar(e.key);
      e.value.text = (v == null) ? '' : "$v";
    }
    if (mounted) setState(() {});
  }

  String _str2(String name) {
    final v = _ev.getVar(name);
    return (v == null) ? '' : "$v";
  }

  Widget _tabPage(List<Widget> children) => SingleChildScrollView(
        padding: const EdgeInsets.all(4),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children),
      );

  Widget _nav(TDataSource src,
          {Future<void> Function()? post,
          Future<void> Function()? insert,
          Future<void> Function()? del}) =>
      Center(
        child: TDBNavigator(
          dataSource: src,
          onPostAsync: post,
          onInsertAsync: insert,
          onDeleteAsync: del,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 840),
        child: SizedBox(width: 960, child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Container(

            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: _kBlue,
            child: const Row(children: [
              Icon(Icons.article_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Password Data Maintenance',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ]),
          ),

          Flexible(
            fit: FlexFit.loose,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text("Load failed: $_error",
                              style: const TextStyle(color: Colors.red)),
                        ),
                      )
                    : FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // <datasource dataset="mnu">
                              _nav(_mnuSrc, post: _mnuPost, insert: _mnuInsert, del: _mnuDelete),
                              Center(child: // <dbgrid width="940" height="200">
                              FocusTraversalOrder(
                                order: const NumericFocusOrder(1),
                                child: FocusTraversalGroup(
                                  child: TDBGrid(
                                    dataSource: _mnuSrc,
                                    columns: _mnuCols,
                                    width: 940,
                                    height: 200,
                                    onRowPost: _mnuPost,
                                    onExitLastRow: () => FocusScope.of(context).nextFocus(),
                                  ),
                                ),
                              )),
                              // <datasource dataset="login">
                              _nav(_loginSrc, post: _loginPost, insert: _loginInsert, del: _loginDelete),
                              Center(child: // <dbgrid width="940" height="200">
                              FocusTraversalOrder(
                                order: const NumericFocusOrder(2),
                                child: FocusTraversalGroup(
                                  child: TDBGrid(
                                    dataSource: _loginSrc,
                                    columns: _loginCols,
                                    width: 940,
                                    height: 200,
                                    onRowPost: _loginPost,
                                    onRowInsert: () => _loginInsert(atEnd: true),
                                    onExitLastRow: () => FocusScope.of(context).nextFocus(),
                                    // <item field="uid" lookup="users;userid"/>
                                    lookupResolver: (field) {
                                      if (field.toLowerCase() != "uid") return null;
                                      return TDBGridLookupSpec(
                                        rows: _usersRows,
                                        colWidths: const [160],
                                        onPicked: (k) async {
                                          setvar("login.uid", "'$k'");
                                          if (mounted) setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ),
                              )),
                              // </datasource login>
                              // </datasource mnu>
                            ],
                          ),
                        ),
                      ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _kBorder))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TButton(caption: "Close", onClick: () {
                Navigator.of(context).maybePop();
                if (mounted) setState(() {});
              }),
            ]),
          ),
        ]),)
      ),
    );
  }
}
