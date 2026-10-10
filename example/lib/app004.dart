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
import 'package:wapform_flutter/wapform_report.dart';
import 'package:wapform_flutter/wapform_filter.dart';

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

void showApp004(BuildContext context) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const App004CardP(),
    );
class App004CardP extends StatefulWidget {
  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  const App004CardP({super.key, this.ev, this.reg});
  @override
  State<App004CardP> createState() =>
      _App004CardPState();
}

class _App004CardPState
    extends State<App004CardP> {
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

  // [diag] ds "cu": foreign=0 declared=1 lookupSrc=0 fields=22
  late final TSQLQuery _cu =
      dbquery("cu", r"select * from cu order by cno", define: (ds) {
    _key(ds, "Cno", "Customer Code");
    _fld(ds, "Cname", "Customer Name");
    _fld(ds, "Cshort", "Customer Short");
    _fld(ds, "Addr1", "Address 1");
    _fld(ds, "Addr2", "Address 2");
    _fld(ds, "AC", "Tax ID");
    _fld(ds, "Zip", "Zip Code");
    _fld(ds, "Ziq", "Shipping Zone");
    _fld(ds, "Phone", "Phone");
    _fld(ds, "FAX", "Fax");
    _fld(ds, "GSM", "Mobile");
    _fld(ds, "Email", "Email");
    _fld(ds, "Password", "Password");
    _fld(ds, "Charger", "Owner");
    _fld(ds, "Contact", "Contact");
    _fld(ds, "Level", "Level");
    _fld(ds, "Pay", "Payment");
    _fld(ds, "AType", "Type");
    _fld(ds, "Capital", "Capital");
    _fld(ds, "CDate", "Created Date", dateOnly: true);
    _fld(ds, "Rem", "Customer Remarks");
    _fld(ds, "Remark", "Company Remarks");

  });

  late final TDataSource _cuSrc;

  late final TDBGridColumns _cuCols = _buildCuCols();

  bool   _loading = true;
  String _error   = '';

  @override
  void initState() {
    super.initState();
    varChangeHooks.add(_varSync);
    _conn();

    _cuSrc = TDataSource()..dataSet = _cu;
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
    _cuSrc.dataSet = null;
    _cu.free();
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
    _reg.put("cu", _cu);
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = ''; });
    try {
      for (final id in []) {
        try {
          final ds = _reg.findQuery(id)!;
          await dbquery(id, ds.sql.text).openAsync();
        } catch (e) {
          debugPrint("[app004] $id skip: $e");
        }
      }

      await dbquery("cu", r"select * from cu order by cno").openAsync();
    } catch (e, st) {
      debugPrint("[app004] _load ERROR: $e\n$st");
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  TDBGridColumns _buildCuCols() {
    final c = TDBGridColumns();
    _column(c, "Cno", "Customer Code", 16);
    _column(c, "CDate", "Created Date", 14);
    _column(c, "Pay", "Payment", 10);
    _column(c, "AType", "Type", 10);
    _column(c, "Cname", "Customer Name", 40);
    _column(c, "Cshort", "Customer Short", 16);
    _column(c, "Phone", "Phone", 20);
    _column(c, "Contact", "Contact", 10);
    _column(c, "Addr1", "Address 1", 60);
    _column(c, "Addr2", "Address 2", 60);
    _column(c, "AC", "Tax ID", 10);
    _column(c, "Zip", "Zip Code", 16);
    _column(c, "Ziq", "Shipping Zone", 16);
    _column(c, "FAX", "Fax", 16);
    _column(c, "GSM", "Mobile", 16);
    _column(c, "Email", "Email", 30);
    _column(c, "Password", "Password", 40);
    _column(c, "Charger", "Owner", 16);
    _column(c, "Capital", "Capital", 16);
    _column(c, "Rem", "Customer Remarks", 40);
    _column(c, "Remark", "Company Remarks", 40);
    return c;
  }

  Future<void> _cuInsert({bool atEnd = false}) async {
    try {
      if (atEnd) {
        _cu.append();
      } else {
        _cu.insert();
      }
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Add failed: $e");
    }
  }

  Future<void> _cuPost() async {
    try {
      await _saveAsync(_cu);
      _snack("Saved", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Save failed: $e");
    }
  }

  Future<void> _cuDelete() async {
    try {
      await _delAsync(_cu);
      _snack("Deleted", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Delete failed: $e");
    }
  }

  Future<void> _goP1() async {
    await showDialog(
        context: context,
        builder: (_) => App004CardP1(ev: _ev, reg: _reg));
    if (mounted) setState(() {});
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

  void _log(String msg) => debugPrint("[app004][log] $msg");

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
              Text('Customer Master',
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
                              // <datasource dataset="cu">
                              // <dbfilter result="R">
                              WapFilter(
                                items: const [
                                  FilterItem(field: "cno", label: "Customer Code", size: 20),
                                  FilterItem(field: "cname", label: "Customer Name", size: 20),
                                ],
                                sqlTemplate: r"select * from cu where $R order by cno",
                                onQuery: (sql) async {
                                  await dbquery("cu", sql).openAsync();
                                  if (mounted) setState(() {});
                                },
                              ),
                              _nav(_cuSrc, post: _cuPost, insert: _cuInsert, del: _cuDelete),
                              Center(child: // <dbgrid width="940" height="400">
                              FocusTraversalOrder(
                                order: const NumericFocusOrder(1),
                                child: FocusTraversalGroup(
                                  child: TDBGrid(
                                    dataSource: _cuSrc,
                                    columns: _cuCols,
                                    width: 940,
                                    height: 400,
                                    onRowPost: _cuPost,
                                    onExitLastRow: () => FocusScope.of(context).nextFocus(),
                                  ),
                                ),
                              )),
                              // </datasource cu>
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
              TButton(caption: "Print", onClick: () async {
                await _goP1();
                if (mounted) setState(() {});
              }),
              const SizedBox(width: 8),
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

class App004ReportP1 extends WapReport {
  final TSQLQuery _ds;

  final int linesPerPage;

  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  late final WapEvaluator _ev = ev ?? WapEvaluator();
  late final DataSetRegistry _reg = reg ?? DataSetRegistry();

  App004ReportP1(this._ds,
      {this.linesPerPage = 50, this.ev, this.reg});

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

  @override
  void initParams() {
    wap.wapLpp = linesPerPage;
    wap.wapGroups = 1;
    wap.wapRow[0].tagPrefix = 'G1_PREFIX';
    wap.wapRow[0].tagSuffix = 'G1_SUFFIX';
  }

  @override
  String expression(int idx) {
    switch (idx) {
    }
    return '';
  }

  @override
  Future<bool> fetchFirst() async {
    if (!_ds.active) await _ds.openAsync();
    if (_ds.isEmpty) return false;
    _ds.first();
    return !_ds.eof;
  }

  @override
  Future<bool> fetchNext() async {
    _ds.next();
    return !_ds.eof;
  }

  @override
  Future<void> fetchPrior() async => _ds.prior();

  @override
  Future<void> run() async {
    _ds.disableControls();
    try {
      await super.run();
    } finally {
      _ds.enableControls();
    }
  }

  void syncCounters() {
    setvar("PAGE", wap.wapPageNo);
    setvar("PAGENO", wap.wapPageNo);
    setvar("LINE", wap.wapLineNo);
    setvar("LINENO", wap.wapLineNo);
  }

  @override
  void parseBlock(String id) {
    syncCounters();

    switch (id) {
      // ── Report header (runs once for the whole report)
      case 'PREFIX':
        // (no content defined in the WML)
        break;

      // ── Top of every page
      case 'PAGEPREFIX':
        emitRow('<table width="750" align="center"><tr><td>');
        setvar("ROWIDX", "1");
        emitRow(expandText(r'''<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td colspan="3"><p align="center"><big>$(sys.company)</big></p></td></tr><tr><td colspan="3"><p align="center"><big>Customer List</big></p></td></tr><tr><td></td><td></td><td width="100">Page:$(PAGE)</td></tr><tr><td></td><td></td><td>Date:$(DATE)</td></tr></table>'''));
        emitRow(expandText(r'''<p align="center">123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890</p>'''));
        emitRow(r'''<table width="100%" align="center" border="0" cellspacing="0" cellpadding="0">''');
        emitRow(expandText(r'''<tr class="row"><th style="width:13%;">Customer Code</th><th style="width:13%;">Customer Name</th><th style="width:20%;">Fax</th><th style="width:11%;">Contact</th><th style="width:43%;">Invoice Address</th></tr>'''));
        emitRow(expandText(r'''<tr class="row"><th style="width:13%;"></th><th style="width:13%;">Phone</th><th style="width:20%;"></th><th style="width:11%;">Tax ID</th><th style="width:43%;">Company Address</th></tr>'''));
        break;

      //   ── Each row of data
      case 'RECORD':
        emitRow(expandText(r'''<tr class="$(IF(ROWIDX mod 2 = 1, 'row1', 'row2'))"><td style="width:13%;" align="center">$(cu.CNo)</td><td style="width:13%;">$(cu.CName)</td><td style="width:20%;">$(cu.Fax)</td><td style="width:11%;">$(cu.Contact)</td><td style="width:43%;" rowspan="2">$(cu.Addr1)</td></tr>'''));
        emitRow(expandText(r'''<tr class="$(IF(ROWIDX mod 2 = 1, 'row1', 'row2'))"><td style="width:13%;"></td><td style="width:13%;">$(cu.Phone)</td><td style="width:20%;"></td><td style="width:11%;">$(cu.Ac)</td></tr>'''));
        setvar("ROWIDX", "ROWIDX+1");
        break;

      // ── Bottom of every page
      case 'PAGESUFFIX':
        emit(r'''</table>''');
        // Only close the frame immediately on a mid-report page break;
        //     the last page's frame-closing is deferred into SUFFIX, so the
        //     content right after </page> ends up wrapped inside the frame too.
        if (wap.wapHasMore) {
          emit('</td></tr></table>');
        }
        break;
      case 'PAGEBREAK':
        emit('<div style="page-break-after:always"></div>');
        break;

      // ── Report footer (runs once for the whole report)
      case 'SUFFIX':
        emit(expandText(r'''<p align="center">123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890</p>'''));
        emit('</td></tr></table>');  // the last page's frame-closing is deferred to here
        break;
    }
  }
}

class App004CardP1 extends StatefulWidget {
  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  const App004CardP1({super.key, this.ev, this.reg});
  @override
  State<App004CardP1> createState() =>
      _App004CardP1State();
}

class _App004CardP1State
    extends State<App004CardP1> {
  late final WapEvaluator _ev = widget.ev ?? WapEvaluator();
  late final DataSetRegistry _reg = widget.reg ?? DataSetRegistry();
  bool get _ownsReg => widget.reg == null;
  final List<String> _ownedDs = []; // datasets this card created

  bool _loading = true;
  String _error = '';
  App004ReportP1? _rep;

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

  // [diag] ds "sys": foreign=0 declared=1 lookupSrc=0 fields=0
  // [diag] ds "cu": foreign=1 declared=1 lookupSrc=0 fields=0
  TSQLQuery get _cu => _reg.findQuery("cu")!;
  late final TSQLQuery _sys = dbquery("sys", r"select * from sys");

  @override
  void initState() {
    super.initState();
    _conn();
    useEngine(_ev, _reg);
    _reg.put("sys", _sys);

    setvar("ROWIDX", "0");
    _load();
  }

  @override
  void dispose() {
    if (_ownsReg) {
    _sys.free();
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

  Future<void> _load() async {
    try {
      if (!_sys.active) await _sys.openAsync();
      if (_sys.recordCount > 0) _sys.first();
      _rep = App004ReportP1(_cu,
          ev: _ev, reg: _reg);
    } catch (e, st) {
      debugPrint("[app004] card P1 ERROR: $e\n$st");
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text("Report failed: $_error",
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return WapPage(
      title: "Print Report",
      report: _rep,
      paper: r"A4",
      orient: r"P",
    );
  }
}
