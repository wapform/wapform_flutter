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

void showApp012(BuildContext context) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const App012CardP(),
    );
class App012CardP extends StatefulWidget {
  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  const App012CardP({super.key, this.ev, this.reg});
  @override
  State<App012CardP> createState() =>
      _App012CardPState();
}

class _App012CardPState
    extends State<App012CardP> {
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

  bool   _loading = true;
  String _error   = '';

  @override
  void initState() {
    super.initState();
    varChangeHooks.add(_varSync);
    _conn();

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
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = ''; });
    try {
      for (final id in []) {
        try {
          final ds = _reg.findQuery(id)!;
          await dbquery(id, ds.sql.text).openAsync();
        } catch (e) {
          debugPrint("[app012] $id skip: $e");
        }
      }

    } catch (e, st) {
      debugPrint("[app012] _load ERROR: $e\n$st");
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _goP1() async {
    await showDialog(
        context: context,
        builder: (_) => App012CardP1(ev: _ev, reg: _reg));
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

  void _log(String msg) => debugPrint("[app012][log] $msg");

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
        constraints: const BoxConstraints(maxWidth: 1180, maxHeight: 840),
        child: IntrinsicWidth(child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Container(

            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: _kBlue,
            child: const Row(children: [
              Icon(Icons.article_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Accounts Receivable Statement Print',
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
                                _line([
                                  _lbl("Please enter the print range and load 80-line report paper"),
                                ]),
                                _line([
                                  _lbl("Customer Code:"),
                                  _vedit("CUSTNO_FROM", "'000000'", 14, order: 1),
                                  _lbl("~"),
                                  _vedit("CUSTNO_TO", "'ZZZZZZ'", 14, order: 2),
                                ]),
                                _line([
                                  _lbl("Ship Date:"),
                                  _vedit("SHIPDATE_FROM", "'20200101'", 14, order: 3),
                                  _lbl("~"),
                                  _vedit("SHIPDATE_TO", "'20261231'", 14, order: 4),
                                ]),
                                _line([
                                  _lbl("report:"),
                                  _vedit("report_MODE", "'S'", 1, order: 5),
                                  _lbl("(S.Screen P.Printer)"),
                                ]),
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

class App012ReportP1 extends WapReport {
  final TSQLQuery _ds;

  final int linesPerPage;

  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  late final WapEvaluator _ev = ev ?? WapEvaluator();
  late final DataSetRegistry _reg = reg ?? DataSetRegistry();

  App012ReportP1(this._ds,
      {this.linesPerPage = 60, this.ev, this.reg});

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
    wap.wapGroups = 3;
    wap.wapRow[0].tagPrefix = 'G1_PREFIX';
    wap.wapRow[0].tagSuffix = 'G1_SUFFIX';
    wap.wapRow[1].tagPrefix = 'G2_PREFIX';
    wap.wapRow[1].tagSuffix = 'G2_SUFFIX';
    wap.wapRow[2].tagPrefix = 'G3_PREFIX';
    wap.wapRow[2].tagSuffix = 'G3_SUFFIX';
  }

  @override
  String expression(int idx) {
    switch (idx) {
      case 0:   // <group change="sh.cno">
        return expandText(r'''$(sh.cno)''');
      case 1:   // <group change="datetostr(sh.sdate)">
        return expandText(r'''$(datetostr(sh.sdate))''');
      case 2:   // <group change="datetostr(sh.sdate)+sh.sno">
        return expandText(r'''$(datetostr(sh.sdate)+sh.sno)''');
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

  @override
  Future<void> onGroupPrepare() async {
      await dbquery("R", r"select cno, SUM(Amount) as A, SUM(Tax) as B, SUM(Paid) as C       from sh where sh.sdate < '$(SHIPDATE_FROM)' and cno='$sh.cno' group by cno     order by cno").openAsync();
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

        break;

      //   ── Start of group 1  change="sh.cno"
      case 'G1_PREFIX':
        setvar("PAGENO", "0");
        setvar("BAL_BEGIN", "0");
        setvar("AMOUNT_SUM", "0");
        setvar("TAX_SUM", "0");
        setvar("PAID_SUM", "0");
        setvar("BAL_END", "0");
        forcePageBreak();
        emitRow(expandText(r'''<table width="740" align="center"><tr class="grp"><td>'''));
        setvar("PAGENO", "PAGENO+1");
        emitRow(expandText(r'''<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td colspan="4"><p align="center"><big>$(sys.Company)</big></p></td></tr><tr><td colspan="4"><p align="center"><big>Accounts Receivable Statement</big></p></td></tr><tr><td colspan="4"></td></tr><tr><td width="350">Customer:$(sh.cname)[$(sh.cno)]</td><td width="180">Phone:$(sh.Phone)</td><td width="120"></td><td width="130">Page:$(PAGENO)</td></tr><tr><td>Address:$(sh.Addr1)</td><td>Fax:$(sh.Fax)</td><td>Tax ID:$(sh.ac)</td><td>Date:$(DATE)</td></tr></table>'''));
        emitRow(r'''<table width="100%" class="p09">''');
        emitRow(expandText(r'''<tr><th style="width:12%;">Ship Date</th><th style="width:12%;">Shipment No</th><th style="width:12%;">Amount</th><th style="width:12%;">Tax</th><th style="width:12%;">Total incl. Tax</th><th style="width:12%;">Paid</th><th style="width:12%;">Balance Due</th></tr>'''));
        break;

      //     ── Start of group 2  change="datetostr(sh.sdate)"
      case 'G2_PREFIX':
        // (no content defined in the WML)
        break;

      //       ── Start of group 3  change="datetostr(sh.sdate)+sh.sno"
      case 'G3_PREFIX':
        // (no content defined in the WML)
        break;

      //         ── Each row of data
      case 'RECORD':
        emitRow(expandText(r'''<tr><td style="width:12%;"><p align="center">$(sh.sdate)</p></td><td style="width:12%;"><p align="center">$(sh.sno)</p></td><td style="width:12%;"><p align="right">$(sh.amount)</p></td><td style="width:12%;"><p align="right">$(sh.tax)</p></td><td style="width:12%;"><p align="right">$(sh.amount+sh.tax)</p></td><td style="width:12%;"><p align="right">$(sh.paid)</p></td><td style="width:12%;"><p align="right">$(sh.amount+sh.tax-sh.paid)</p></td></tr>'''));
        break;

      //       ── End of group 3
      case 'G3_SUFFIX':
        setvar("AMOUNT_SUM", "AMOUNT_SUM+sh.amount");
        setvar("TAX_SUM", "TAX_SUM+sh.tax");
        setvar("PAID_SUM", "PAID_SUM+sh.paid");
        break;

      //     ── End of group 2
      case 'G2_SUFFIX':
        // (no content defined in the WML)
        break;

      //   ── End of group 1
      case 'G1_SUFFIX':
        emitRow(r'''</table>''');
        emitRow(expandText(r'''</td></tr></table>'''));
        emitRow(expandText(r'''<hr align="center"/>'''));
        setvar("BAL_BEGIN", "R.A+R.B-R.C");
        setvar("BAL_END", "BAL_BEGIN+AMOUNT_SUM+TAX_SUM-PAID_SUM");
        emitRow(expandText(r'''<table width="740" align="center"><tr><td>'''));
        emitRow(expandText(r'''<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td>Company Address:$(sys.Addr)</td><td width="150" align="right">Prior Balance:</td><td width="100" align="right">$(FORMAT('%8.0n',BAL_BEGIN*1.0))</td></tr><tr><td>Company Phone:$(sys.Phone)</td><td align="right">+ Sales This Period:</td><td align="right">$(FORMAT('%8.0n',AMOUNT_SUM*1.0))</td></tr><tr><td>Company Fax:$(sys.Fax)</td><td align="right">+ Tax This Period:</td><td align="right">$(FORMAT('%8.0n',TAX_SUM*1.0))</td></tr><tr><td><p></p></td><td align="right">- Paid This Period:</td><td align="right">$(FORMAT('%8.0n',PAID_SUM*1.0))</td></tr><tr><td><p></p></td><td align="right">= Balance Due:</td><td align="right">$(FORMAT('%8.0n',BAL_END*1.0))</td></tr></table>'''));
        emitRow(expandText(r'''</td></tr></table>'''));
        break;

      // ── Bottom of every page
      case 'PAGESUFFIX':

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

        emit('</td></tr></table>');  // the last page's frame-closing is deferred to here
        break;
    }
  }
}

class App012CardP1 extends StatefulWidget {
  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  const App012CardP1({super.key, this.ev, this.reg});
  @override
  State<App012CardP1> createState() =>
      _App012CardP1State();
}

class _App012CardP1State
    extends State<App012CardP1> {
  late final WapEvaluator _ev = widget.ev ?? WapEvaluator();
  late final DataSetRegistry _reg = widget.reg ?? DataSetRegistry();
  bool get _ownsReg => widget.reg == null;
  final List<String> _ownedDs = []; // datasets this card created

  bool _loading = true;
  String _error = '';
  App012ReportP1? _rep;

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
  // [diag] ds "sh": foreign=0 declared=1 lookupSrc=0 fields=0
  // [diag] ds "R": foreign=0 declared=0 lookupSrc=0 fields=0
  late final TSQLQuery _sys = dbquery("sys", r"select * from sys");
  late final TSQLQuery _sh = dbquery("sh", r"SELECT       sh.cno, sh.sno, sh.sdate, sh.TaxRate, sh.Amount, sh.Tax, sh.Paid, sh.Rem,       cu.cname, cu.Phone, cu.Fax, cu.Addr1, cu.ac     FROM       sh, cu     WHERE       (sh.sdate >= '$SHIPDATE_FROM') and (sh.sdate <= '$SHIPDATE_TO')       and       sh.cno >= '$CUSTNO_FROM' and sh.cno <= '$CUSTNO_TO'       and       cu.cno = sh.cno     ORDER BY       sh.cno, sh.sdate, sh.sno");

  @override
  void initState() {
    super.initState();
    _conn();
    useEngine(_ev, _reg);
    _reg.put("sys", _sys);
    _reg.put("sh", _sh);

    _load();
  }

  @override
  void dispose() {
    if (_ownsReg) {
    _sys.free();
    _sh.free();
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
      if (!_sh.active) await _sh.openAsync();
      _rep = App012ReportP1(_sh,
          ev: _ev, reg: _reg);
    } catch (e, st) {
      debugPrint("[app012] card P1 ERROR: $e\n$st");
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
      paper: r"Letter",
      orient: r"P",
    );
  }
}
