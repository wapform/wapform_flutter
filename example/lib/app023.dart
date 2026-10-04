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
      return TStringField();
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

void showApp023(BuildContext context) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const App023CardP(),
    );
class App023CardP extends StatefulWidget {
  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  const App023CardP({super.key, this.ev, this.reg});
  @override
  State<App023CardP> createState() =>
      _App023CardPState();
}

class _App023CardPState
    extends State<App023CardP> {
  late final WapEvaluator _ev = widget.ev ?? WapEvaluator();
  late final DataSetRegistry _reg = widget.reg ?? DataSetRegistry();
  bool get _ownsReg => widget.reg == null;

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

  // [diag] ds "sys": foreign=0 declared=1 lookupSrc=0 fields=4
  // [diag] ds "sh": foreign=0 declared=1 lookupSrc=0 fields=21
  // [diag] ds "cu": foreign=0 declared=1 lookupSrc=1 fields=0
  // [diag] ds "fm": foreign=0 declared=1 lookupSrc=1 fields=0
  late final TSQLQuery _cu = dbquery("cu", r"select * from cu");
  late final TSQLQuery _fm = dbquery("fm", r"select fname from fm order by fno");
  late final TSQLQuery _sys =
      dbquery("sys", r"select * from sys", define: (ds) {
    _key(ds, "TaxRate", "Sales Tax Rate");
    _fld(ds, "Company", "Company Name");
    _fld(ds, "AcBeg", "Closing Date From");
    _fld(ds, "AcEnd", "Closing Date To");

  });
  late final TSQLQuery _sh =
      dbquery("sh", r"select     sh.sno,sh.sdate,sh.cno,cu.cshort,cu.AC,sh.Pay,sh.TaxRate,sh.Amount,sh.Tax,sh.AmountTax,sh.Paid,sh.GetDate,sh.PayDate,     sh.gno,sh.fty,sh.ChkNo,sh.fno,sh.rempay,fm.fname     from sh, cu, fm where sh.cno=cu.cno and sh.fno=fm.fno and sh.sno='XYZ' order by sh.sno", define: (ds) {
    ds.updateTableName = "sh";
    _key(ds, "sno", "Shipment No");
    _fld(ds, "sdate", "Ship Date", dateOnly: true);
    _key(ds, "cno", "Customer Code");
    _fld(ds, "cshort", "Customer Short", readOnly: true);
    _fld(ds, "AC", "Tax ID", readOnly: true);
    _fld(ds, "Pay", "Payment");
    _fld(ds, "TaxRate", "Sales Tax Rate");
    _fld(ds, "Amount", "Shipment Amount");
    _fld(ds, "Tax", "Tax Rate");
    _fld(ds, "AmountTax", "Amount incl. Tax");
    _fld(ds, "Paid", "Paid Amount");
    _cal(ds, "Taxx", "Sales Tax");
    _cal(ds, "UnPaid", "Balance Due");
    _fld(ds, "GetDate", "Receipt Date", dateOnly: true);
    _fld(ds, "PayDate", "Due Date", dateOnly: true);
    _fld(ds, "gno", "Pallet No");
    _fld(ds, "fty", "Qty of Pieces");
    _fld(ds, "ChkNo", "Check No");
    _key(ds, "fno", "Shipper Code");
    _fld(ds, "fname", "Shipper Name", readOnly: true);
    _fld(ds, "RemPay", "Remarks");

    ds.onCalcFields = (d) {
      setvar("sh.Taxx", "sh.Amount*sh.TaxRate/100");
      setvar("sh.UnPaid", "sh.Amount+sh.Taxx-sh.Paid");
    };

  });

  late final TDataSource _shSrc;

  late final TDBGridColumns _shCols = _buildShCols();

  Map<String, List<String>> get _cuRows =>
      _cu.lookupMap("cno", const ["cshort"]);

  bool   _loading = true;
  String _error   = '';

  @override
  void initState() {
    super.initState();
    varChangeHooks.add(_varSync);
    _conn();

    _shSrc = TDataSource()..dataSet = _sh;
    _bindEngine();

    setvar("QUERYGUARD", "0");
    setvar("_SHIPDATE_FROM", "''");
    setvar("_SHIPDATE_TO", "''");
    setvar("_CUSTNO_FROM", "''");
    setvar("_CUSTNO_TO", "''");
    setvar("_REMARK_KW", "''");
    setvar("_CUSTSHORT_KW", "''");
    setvar("_TAXID_KW", "''");
    setvar("_BOARDNO_KW", "''");
    setvar("_CHKNO_KW", "''");
    setvar("_PAYTYPE_KW", "''");
    setvar("_AMOUNTTAX_EQ", "''");
    setvar("_SHIPPER_KW", "''");
    _load();
  }

  @override
  void dispose() {
    varChangeHooks.remove(_varSync);

    for (final c in _varCtls.values) {
      c.dispose();
    }
    if (_ownsReg) {
    _shSrc.dataSet = null;
    _sys.free();
    _sh.free();
    _cu.free();
    _fm.free();
      _reg.releaseAll();
    }
    super.dispose();
  }

  void _bindEngine() {
    useEngine(_ev, _reg);
    _reg.put("sys", _sys);
    _reg.put("sh", _sh);
    _reg.put("cu", _cu);
    _reg.put("fm", _fm);
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = ''; });
    try {
      for (final id in ['cu', 'fm']) {
        try {
          final ds = _reg.findQuery(id)!;
          await dbquery(id, ds.sql.text).openAsync();
        } catch (e) {
          debugPrint("[app023] $id skip: $e");
        }
      }

      await dbquery("sys", r"select * from sys").openAsync();
      await dbquery("sh", r"select     sh.sno,sh.sdate,sh.cno,cu.cshort,cu.AC,sh.Pay,sh.TaxRate,sh.Amount,sh.Tax,sh.AmountTax,sh.Paid,sh.GetDate,sh.PayDate,     sh.gno,sh.fty,sh.ChkNo,sh.fno,sh.rempay,fm.fname     from sh, cu, fm where sh.cno=cu.cno and sh.fno=fm.fno and sh.sno='XYZ' order by sh.sno").openAsync();
      if (!_cu.active) await _cu.openAsync();
      if (!_fm.active) await _fm.openAsync();
    } catch (e, st) {
      debugPrint("[app023] _load ERROR: $e\n$st");
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  TDBGridColumns _buildShCols() {
    final c = TDBGridColumns();
    _column(c, "sno", "Shipment No", 16);
    _column(c, "sdate", "Ship Date", 14);
    _column(c, "cno", "Customer Code", 16);  // lookup="cu;cno;cshort"
    _column(c, "cshort", "Customer Short", 16);
    _column(c, "AC", "Tax ID", 16);
    _column(c, "AmountTax", "Amount incl. Tax", 16);
    _column(c, "Pay", "Payment", 16);
    _column(c, "Paid", "Paid Amount", 16);
    _column(c, "UnPaid", "Balance Due", 16, ro: true, align: TAlignment.taRightJustify);
    _column(c, "GetDate", "Receipt Date", 12);
    _column(c, "PayDate", "Due Date", 12);
    _column(c, "fname", "Shipper Name", 16);
    _column(c, "gno", "Pallet No", 10);
    _column(c, "ChkNo", "Check No", 10);
    _column(c, "fty", "Qty of Pieces", 16);
    _column(c, "RemPay", "Remarks", 40);
    return c;
  }

  Future<void> _xyz() async {
    setvar("QUERYGUARD", "QUERYGUARD+1");
    if (condition("QUERYGUARD=1")) {
      setvar("SQL_WHERE", "''");
      if (condition("SHIPDATE_FROM<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.sdate >= '''+SHIPDATE_FROM+''''");
      if (condition("SHIPDATE_TO<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.sdate <= '''+SHIPDATE_TO+''''");
      if (condition("CUSTNO_TO=''")) {
        if (condition("CUSTNO_FROM<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.cno like '''+CUSTNO_FROM+'%'''");
      } else {
        if (condition("CUSTNO_FROM<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.cno >= '''+CUSTNO_FROM+''''");
        if (condition("CUSTNO_TO<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.cno <= '''+CUSTNO_TO+''''");
      }
      if (condition("REMARK_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.rempay like ''%'+REMARK_KW+'%'''");
      if (condition("CUSTSHORT_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND cu.cshort like '''+CUSTSHORT_KW+'%'''");
      if (condition("SHIPPER_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND fm.fname like '''+SHIPPER_KW+'%'''");
      if (condition("TAXID_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.ac like '''+TAXID_KW+'%'''");
      if (condition("BOARDNO_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.gno like '''+BOARDNO_KW+'%'''");
      if (condition("CHKNO_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.chkno like '''+CHKNO_KW+'%'''");
      if (condition("AMOUNTTAX_EQ<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.amounttax = '+AMOUNTTAX_EQ");
      if (condition("PAYTYPE_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.pay like '''+PAYTYPE_KW+''''");
      if (condition("UNPAID_ONLY='Y'")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.AmountTax-ifnull(sh.Paid,0)>0'");
      _log("");
      if (condition("SQL_WHERE=''")) setvar("SQL_WHERE", "' AND sh.sno=''XYZ'''");
      await dbquery("sh", r"select sh.sno,sh.sdate,sh.cno,cu.cshort,cu.AC,sh.Pay,sh.TaxRate,sh.Amount,sh.Tax,sh.AmountTax,sh.Paid,sh.GetDate,sh.PayDate,     sh.gno,sh.fty,sh.ChkNo,sh.fno,sh.rempay,fm.fname     from sh, cu, fm where sh.cno=cu.cno and sh.fno=fm.fno $SQL_WHERE order by sh.sno").openAsync();
      _log("");
    }
    setvar("QUERYGUARD", "0");
  }

  Future<void> _clr() async {
    setvar("SHIPDATE_FROM", "''");
    setvar("SHIPDATE_TO", "''");
    setvar("CUSTNO_FROM", "''");
    setvar("CUSTNO_TO", "''");
    setvar("REMARK_KW", "''");
    setvar("CUSTSHORT_KW", "''");
    setvar("TAXID_KW", "''");
    setvar("BOARDNO_KW", "''");
    setvar("CHKNO_KW", "''");
    setvar("PAYTYPE_KW", "''");
    setvar("AMOUNTTAX_EQ", "''");
    setvar("SHIPPER_KW", "''");
    setvar("UNPAID_ONLY", "''");
    await _xyz();
  }

  void _set() {
    setvar("_SHIPDATE_FROM", "SHIPDATE_FROM");
    setvar("_SHIPDATE_TO", "SHIPDATE_TO");
    setvar("_CUSTNO_FROM", "CUSTNO_FROM");
    setvar("_CUSTNO_TO", "CUSTNO_TO");
    setvar("_REMARK_KW", "REMARK_KW");
    setvar("_CUSTSHORT_KW", "CUSTSHORT_KW");
    setvar("_TAXID_KW", "TAXID_KW");
    setvar("_BOARDNO_KW", "BOARDNO_KW");
    setvar("_CHKNO_KW", "CHKNO_KW");
    setvar("_PAYTYPE_KW", "PAYTYPE_KW");
    setvar("_AMOUNTTAX_EQ", "AMOUNTTAX_EQ");
    setvar("_SHIPPER_KW", "SHIPPER_KW");
    setvar("_UNPAID_ONLY", "UNPAID_ONLY");
  }

  Future<void> _sysInsert({bool atEnd = false}) async {
    try {
      if (atEnd) {
        _sys.append();
      } else {
        _sys.insert();
      }
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Add failed: $e");
    }
  }

  Future<void> _sysPost() async {
    try {
      await _saveAsync(_sys);
      _snack("Saved", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Save failed: $e");
    }
  }

  Future<void> _sysDelete() async {
    try {
      await _delAsync(_sys);
      _snack("Deleted", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Delete failed: $e");
    }
  }

  Future<void> _shInsert({bool atEnd = false}) async {
    try {
      if (atEnd) {
        _sh.append();
      } else {
        _sh.insert();
      }
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Add failed: $e");
    }
  }

  Future<void> _shPost() async {
    try {
      await _saveAsync(_sh);
      _snack("Saved", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Save failed: $e");
    }
  }

  Future<void> _shDelete() async {
    try {
      await _delAsync(_sh);
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

  void _log(String msg) => debugPrint("[app023][log] $msg");

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
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 840),
        child: SizedBox(width: 1200, child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Container(

            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: _kBlue,
            child: const Row(children: [
              Icon(Icons.article_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Payment Receipt Master',
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
                              // <table columns="6" align="LLLLLL">
                              _tbl([
                                _tdf(180.0, [
                                  _line([
                                    _lbl("Ship Date Fr:"),
                                    _vedit("SHIPDATE_FROM", "_SHIPDATE_FROM", 12, order: 1),
                                  ]),
                                  _line([
                                    _lbl("Ship Date To:"),
                                    _vedit("SHIPDATE_TO", "_SHIPDATE_TO", 12, order: 2),
                                  ]),
                                ]),
                                _tdf(180.0, [
                                  _line([
                                    _lbl("Cust Code Fr:"),
                                    _vlookup("CUSTNO_FROM", "_CUSTNO_FROM", _cu, 12,
                                        "cno", const ["cshort"], order: 3),  // lookup="cu;cno;cshort"
                                  ]),
                                  _line([
                                    _lbl("Cust Code To:"),
                                    _vlookup("CUSTNO_TO", "_CUSTNO_TO", _cu, 12,
                                        "cno", const ["cshort"], order: 4),  // lookup="cu;cno;cshort"
                                  ]),
                                ]),
                                _tdf(180.0, [
                                  _line([
                                    _lbl("Short Name:"),
                                    _vedit("CUSTSHORT_KW", "_CUSTSHORT_KW", 12, order: 5),
                                  ]),
                                  _line([
                                    _lbl("Tax ID:"),
                                    _vedit("TAXID_KW", "_TAXID_KW", 12, order: 6),
                                  ]),
                                ]),
                                _tdf(140.0, [
                                  _line([
                                    _lbl("Incl. Tax:"),
                                    _vedit("AMOUNTTAX_EQ", "_AMOUNTTAX_EQ", 10, order: 7),
                                  ]),
                                  _line([
                                    _lbl("Payment:"),
                                    _vedit("PAYTYPE_KW", "_PAYTYPE_KW", 10, order: 8),
                                  ]),
                                ]),
                                _tdf(140.0, [
                                  _line([
                                    _lbl("Pallet No:"),
                                    _vedit("BOARDNO_KW", "_BOARDNO_KW", 10, order: 9),
                                  ]),
                                  _line([
                                    _lbl("Check No:"),
                                    _vedit("CHKNO_KW", "_CHKNO_KW", 10, order: 10),
                                  ]),
                                ]),
                                _tdf(140.0, [
                                  _line([
                                    _lbl("Shipper:"),
                                    _vlookup("SHIPPER_KW", "_SHIPPER_KW", _fm, 10,
                                        "fname", const ["fname"], order: 11),  // lookup="sql;fm;select fname from fm order by fno"
                                  ]),
                                  _line([
                                    _lbl("Remarks:"),
                                    _vedit("REMARK_KW", "_REMARK_KW", 10, order: 12),
                                  ]),
                                  _line([
                                    _lbl("Unpaid:"),
                                    _vcheck("UNPAID_ONLY", "Y"),
                                  ]),
                                ]),
                                  _line([
                                    TButton(caption: "Search", onClick: () async { await _xyz(); if (mounted) setState(() {}); }),
                                  ]),
                                  _line([
                                    TButton(caption: "Clear", onClick: () async { await _clr(); if (mounted) setState(() {}); }),
                                  ]),
                              ]),
                              // <datasource dataset="sh">
                              _nav(_shSrc, post: _shPost, insert: _shInsert, del: _shDelete),
                              Center(child: // <dbgrid width="1180" height="350">
                              FocusTraversalOrder(
                                order: NumericFocusOrder(13),
                                child: FocusTraversalGroup(
                                  child: TDBGrid(
                                    dataSource: _shSrc,
                                    columns: _shCols,
                                    width: 1180,
                                    height: 350,
                                    onRowPost: _shPost,
                                    onExitLastRow: () => FocusScope.of(context).nextFocus(),
                                    // <item field="cno" lookup="cu;cno;cshort"/>
                                    lookupResolver: (field) {
                                      if (field.toLowerCase() != "cno") return null;
                                      return TDBGridLookupSpec(
                                        rows: _cuRows,
                                        colWidths: const [160],
                                        onPicked: (k) async {
                                          setvar("sh.cno", "'$k'");
                                          if (mounted) setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ),
                              )),
                              // </datasource sh>
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
