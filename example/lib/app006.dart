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

void showApp006(BuildContext context) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const App006CardP(),
    );
class App006CardP extends StatefulWidget {
  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  const App006CardP({super.key, this.ev, this.reg});
  @override
  State<App006CardP> createState() =>
      _App006CardPState();
}

class _App006CardPState
    extends State<App006CardP> with SingleTickerProviderStateMixin {
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

  // [diag] ds "sys": foreign=0 declared=1 lookupSrc=0 fields=0
  // [diag] ds "cu": foreign=0 declared=1 lookupSrc=1 fields=15
  // [diag] ds "sh": foreign=0 declared=1 lookupSrc=0 fields=46
  // [diag] ds "em": foreign=0 declared=1 lookupSrc=1 fields=0
  // [diag] ds "fm": foreign=0 declared=1 lookupSrc=1 fields=0
  // [diag] ds "sn": foreign=0 declared=1 lookupSrc=0 fields=14
  // [diag] ds "pa": foreign=0 declared=1 lookupSrc=1 fields=0
  // [diag] ds "xy": foreign=0 declared=1 lookupSrc=0 fields=22
  late final TSQLQuery _sys = dbquery("sys", r"select * from sys");
  late final TSQLQuery _cu = dbquery("cu", r"select * from cu where cno<'D' order by cno");
  late final TSQLQuery _em = dbquery("em", r"select * from em order by eno");
  late final TSQLQuery _fm = dbquery("fm", r"select * from fm order by fno");
  late final TSQLQuery _pa = dbquery("pa", r"select * from pa order by pno");
  late final TSQLQuery _sh =
      dbquery("sh", r"select * from sh where sno='XYZ' order by sno", define: (ds) {
    _key(ds, "sno", "Shipment No");
    _fld(ds, "sdate", "Ship Date", dateOnly: true);
    _fld(ds, "cno", "Customer Code");
    _lkp(ds, "cname", "Customer Name",
        keyField: "cno", lookupKey: "cno",
        resultField: "cname", lookupDs: _cu);
    _lkp(ds, "cucshort", "Customer Short",
        keyField: "cno", lookupKey: "cno",
        resultField: "cshort", lookupDs: _cu);
    _lkp(ds, "Addr1", "Address 1",
        keyField: "cno", lookupKey: "cno",
        resultField: "Addr1", lookupDs: _cu);
    _lkp(ds, "cuac", "Tax ID",
        keyField: "cno", lookupKey: "cno",
        resultField: "AC", lookupDs: _cu);
    _lkp(ds, "cdate", "Created Date",
        keyField: "cno", lookupKey: "cno",
        resultField: "cdate", lookupDs: _cu, dateOnly: true);
    _lkp(ds, "Zip", "Zip Code",
        keyField: "cno", lookupKey: "cno",
        resultField: "Zip", lookupDs: _cu);
    _lkp(ds, "Ziq", "Shipping Zone",
        keyField: "cno", lookupKey: "cno",
        resultField: "Ziq", lookupDs: _cu);
    _lkp(ds, "Phone", "Phone",
        keyField: "cno", lookupKey: "cno",
        resultField: "Phone", lookupDs: _cu);
    _lkp(ds, "FAX", "Fax",
        keyField: "cno", lookupKey: "cno",
        resultField: "FAX", lookupDs: _cu);
    _lkp(ds, "email", "email",
        keyField: "cno", lookupKey: "cno",
        resultField: "email", lookupDs: _cu);
    _lkp(ds, "Contact", "Contact",
        keyField: "cno", lookupKey: "cno",
        resultField: "Contact", lookupDs: _cu);
    _lkp(ds, "cupay", "Payment",
        keyField: "cno", lookupKey: "cno",
        resultField: "Pay", lookupDs: _cu);
    _lkp(ds, "cutyp", "Typ",
        keyField: "cno", lookupKey: "cno",
        resultField: "AType", lookupDs: _cu);
    _lkp(ds, "cuRem", "Remarks",
        keyField: "cno", lookupKey: "cno",
        resultField: "Rem", lookupDs: _cu);
    _lkp(ds, "cuRemark", "Remarks",
        keyField: "cno", lookupKey: "cno",
        resultField: "Remark", lookupDs: _cu);
    _fld(ds, "cshort", "Customer Short");
    _fld(ds, "AC", "Tax ID");
    _fld(ds, "Pay", "Payment");
    _fld(ds, "eno", "Employee ID");
    _lkp(ds, "ename", "Employee Name",
        keyField: "eno", lookupKey: "eno",
        resultField: "ename", lookupDs: _em);
    _fld(ds, "fno", "Shipper Code");
    _lkp(ds, "fmfname", "Shipper Name",
        keyField: "fno", lookupKey: "fno",
        resultField: "fname", lookupDs: _fm);
    _fld(ds, "fname", "Shipper Name");
    _fld(ds, "gno", "Pallet No");
    _fld(ds, "fty", "Qty of Pieces");
    _fld(ds, "ADate", "ADate", dateOnly: true);
    _fld(ds, "AType", "AType");
    _fld(ds, "ANo", "ANo");
    _fld(ds, "Rem", "Rem");
    _fld(ds, "Remark", "Remark");
    _fld(ds, "pc", "Order Status");
    _fld(ds, "source", "Sales Channel");
    _fld(ds, "topic", "topic");
    _fld(ds, "sales", "sales");
    _fld(ds, "dm", "dm");
    _fld(ds, "TaxRate", "Sales Tax Rate");
    _fld(ds, "Amount", "Shipment Amount");
    _fld(ds, "Tax", "Tax");
    _cal(ds, "Taxx", "Sales Tax");
    _fld(ds, "AmountTax", "AmountTax");
    _cal(ds, "AmountTaxx", "Amount incl. Tax");
    _fld(ds, "Paid", "Paid Amount");
    _cal(ds, "UnPaid", "Balance Due");

    ds.onCalcFields = (d) {
      setvar("sh.Taxx", "sh.Amount*sh.TaxRate/100");
      setvar("sh.AmountTaxx", "sh.Amount+sh.Taxx");
      setvar("sh.UnPaid", "sh.Amount+sh.Taxx-sh.Paid");
    };

    ds.onNewRecord = (d) {
      setvar("sh.sno", "DOCDATE+FORMAT('%4.4d',maxno.sno)");
      setvar("sh.cno", "''");
      setvar("sh.eno", "''");
      setvar("sh.TaxRate", "5");
      setvar("sh.sdate", "DATE");
      setvar("sh.ADate", "DATE");
      setvar("sh.AType", "'3'");
    };

    ds.beforePost = (d) {
      setvar("sh.cshort", "sh.cucshort");
      setvar("sh.fname", "sh.fmfname");
      setvar("sh.AC", "sh.cuac");
      setvar("sh.Pay", "sh.cupay");
      if (condition("sh.cutyp<>''")) setvar("sh.AType", "sh.cutyp");
      setvar("sh.Tax", "sh.Taxx");
      setvar("sh.AmountTax", "sh.AmountTaxx");
    };
    ds.beforeDelete = (d) {
      Future.microtask(() { if (mounted) _shBeforeDeleteAsync(); });
    };
    ds.afterScroll = (d) {
      Future.microtask(() { if (mounted) _shAfterScroll(); });
    };
  });
  late final TSQLQuery _sn =
      dbquery("sn", r"select * from sn where sno='$sh.sno' order by sno, itm", define: (ds) {
    _key(ds, "sno", "Shipment No");
    _key(ds, "Itm", "NO");
    _fld(ds, "sdate", "Ship Date", dateOnly: true);
    _fld(ds, "cno", "Customer Code");
    _fld(ds, "eno", "Employee ID");
    _fld(ds, "PNo", "Item No");
    _lkp(ds, "des", "Product Name",
        keyField: "PNo", lookupKey: "pno",
        resultField: "des", lookupDs: _pa);
    _lkp(ds, "unit", "Unit",
        keyField: "PNo", lookupKey: "pno",
        resultField: "unit", lookupDs: _pa);
    _lkp(ds, "price1", "List Price",
        keyField: "PNo", lookupKey: "pno",
        resultField: "price1", lookupDs: _pa);
    _lkp(ds, "pricea", "Standard Cost",
        keyField: "PNo", lookupKey: "pno",
        resultField: "pricea", lookupDs: _pa);
    _fld(ds, "Qty", "Quantity");
    _fld(ds, "Price", "Unit Price");
    _cal(ds, "Total", "Amount");
    _fld(ds, "Rem", "Remarks");

    ds.onCalcFields = (d) {
      setvar("sn.Total", "sn.Qty*sn.Price");
    };

    ds.onNewRecord = (d) {
      setvar("sn.sno", "sh.sno");
      setvar("sn.Itm", "maxitm.itm+1");
    };

    ds.beforeEdit = (d) {
      invoke("sh", "Edit");
    };
    ds.beforeInsert = (d) {
      invoke("sh", "Edit");
    };
    ds.beforeDelete = (d) {
      invoke("sh", "Edit");
    };
    ds.afterPost = (d) {
      _updateTotal();
    };
    ds.afterDelete = (d) {
      _updateTotal();
    };
  });
  late final TSQLQuery _xy =
      dbquery("xy", "select     sh.sno,sh.sdate,sh.cno,cu.cshort,cu.AC,sh.Pay,sh.TaxRate,sh.Amount,sh.Tax,sh.AmountTax,sh.Paid,sh.GetDate,sh.PayDate,     sh.gno,sh.fty,sh.ChkNo,sh.fno,sh.fname,sh.rempay,     CASE     WHEN sh.pc='1' THEN \"Order Received\"     WHEN sh.pc='2' THEN \"Preparing\"     WHEN sh.pc='3' THEN \"Shipped\"     WHEN sh.pc='4' THEN \"Transferring Stock\"     ELSE \"\"     END AS st     from sh, cu     where sh.cno=cu.cno and sh.sno='XYZ'     order by sh.sno", define: (ds) {
    ds.updateTableName = "sh";
    _key(ds, "sno", "Shipment No");
    _fld(ds, "sdate", "Ship Date", dateOnly: true);
    _key(ds, "cno", "Customer Code");
    _fld(ds, "cshort", "Customer Short", readOnly: true);
    _fld(ds, "st", "Order Status");
    _fld(ds, "AC", "Tax ID", readOnly: true);
    _fld(ds, "Pay", "Payment");
    _fld(ds, "TaxRate", "Sales Tax Rate");
    _fld(ds, "Amount", "Shipment Amount");
    _fld(ds, "Tax", "Tax Rate");
    _fld(ds, "AmountTax", "Amount incl. Tax");
    _fld(ds, "Paid", "Received Amount");
    _cal(ds, "Taxx", "Sales Tax");
    _cal(ds, "UnPaid", "Balance Due");
    _fld(ds, "GetDate", "Receipt Date", dateOnly: true);
    _fld(ds, "PayDate", "Due Date", dateOnly: true);
    _fld(ds, "gno", "Pallet No");
    _fld(ds, "fty", "Qty of Pieces");
    _fld(ds, "ChkNo", "Check No");
    _fld(ds, "fno", "Shipper Code");
    _fld(ds, "fname", "Shipper Name");
    _fld(ds, "RemPay", "Remarks");

    ds.onCalcFields = (d) {
      setvar("xy.Taxx", "xy.Amount*xy.TaxRate/100");
      setvar("xy.UnPaid", "xy.Amount+xy.Taxx-xy.Paid");
    };

  });

  late final TDataSource _shSrc;
  late final TDataSource _snSrc;
  late final TDataSource _xySrc;

  late final TDBGridColumns _snCols = _buildSnCols();
  late final TDBGridColumns _xyCols = _buildXyCols();

  Map<String, List<String>> get _paRows =>
      _pa.lookupMap("pno", const ["des"]);
  Map<String, List<String>> get _cuRows =>
      _cu.lookupMap("cno", const ["cshort"]);

  bool   _loading = true;
  String _error   = '';
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    varChangeHooks.add(_varSync);
    _conn();
    _tab = TabController(length: 2, vsync: this, initialIndex: 1);
    _shSrc = TDataSource()..dataSet = _sh;
    _snSrc = TDataSource()..dataSet = _sn;
    _xySrc = TDataSource()..dataSet = _xy;
    _bindEngine();

    setvar("DOCDATE", "FORMAT('%2.2d',YEAR(DATE)-1911)+FORMAT('%2.2d',MONTH(DATE))+FORMAT('%2.2d',DAY(DATE))");
    setvar("BARCODEGUARD", "0");
    setvar("DeletingItems", "0");
    setvar("BookMark", "0");
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
    setvar("BARCODEGUARD", "1");
    _load();
  }

  @override
  void dispose() {
    varChangeHooks.remove(_varSync);
    _tab.dispose();
    for (final c in _varCtls.values) {
      c.dispose();
    }
    if (_ownsReg) {
    _shSrc.dataSet = null;
    _snSrc.dataSet = null;
    _xySrc.dataSet = null;
    _sys.free();
    _cu.free();
    _sh.free();
    _em.free();
    _fm.free();
    _sn.free();
    _pa.free();
    _xy.free();
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
    _reg.put("sys", _sys);
    _reg.put("cu", _cu);
    _reg.put("sh", _sh);
    _reg.put("em", _em);
    _reg.put("fm", _fm);
    _reg.put("sn", _sn);
    _reg.put("pa", _pa);
    _reg.put("xy", _xy);
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = ''; });
    try {
      for (final id in ['sys', 'cu', 'em', 'fm', 'pa']) {
        try {
          final ds = _reg.findQuery(id)!;
          await dbquery(id, ds.sql.text).openAsync();
        } catch (e) {
          debugPrint("[app006] $id skip: $e");
        }
      }

      await dbquery("sh", r"select * from sh where sno='XYZ' order by sno").openAsync();
      // Detail is opened with a filter carried by sh's afterscroll
      await _shAfterScroll();
      await dbquery("xy", "select     sh.sno,sh.sdate,sh.cno,cu.cshort,cu.AC,sh.Pay,sh.TaxRate,sh.Amount,sh.Tax,sh.AmountTax,sh.Paid,sh.GetDate,sh.PayDate,     sh.gno,sh.fty,sh.ChkNo,sh.fno,sh.fname,sh.rempay,     CASE     WHEN sh.pc='1' THEN \"Order Received\"     WHEN sh.pc='2' THEN \"Preparing\"     WHEN sh.pc='3' THEN \"Shipped\"     WHEN sh.pc='4' THEN \"Transferring Stock\"     ELSE \"\"     END AS st     from sh, cu     where sh.cno=cu.cno and sh.sno='XYZ'     order by sh.sno").openAsync();
      if (!_cu.active) await _cu.openAsync();
      if (!_em.active) await _em.openAsync();
      if (!_fm.active) await _fm.openAsync();
      if (!_pa.active) await _pa.openAsync();
    } catch (e, st) {
      debugPrint("[app006] _load ERROR: $e\n$st");
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  TDBGridColumns _buildSnCols() {
    final c = TDBGridColumns();
    _column(c, "sno", "Shipment No", 12);
    _column(c, "PNo", "Item No", 12);  // lookup="pa;pno;des"
    _column(c, "des", "Product Name", 40, ro: true);
    _column(c, "unit", "Unit", 12, ro: true);
    _column(c, "price1", "List Price", 12, ro: true, align: TAlignment.taRightJustify);
    _column(c, "Qty", "Quantity", 12, align: TAlignment.taRightJustify);
    _column(c, "Price", "Unit Price", 12, align: TAlignment.taRightJustify);  // @@@ oncustomdlg="#PRICE": TDBGrid has no field-level custom-dialog hook, wired onto the standalone toolbar instead
    _column(c, "Total", "Amount", 12, ro: true, align: TAlignment.taRightJustify);
    _column(c, "Rem", "Remarks", 12);
    return c;
  }
  TDBGridColumns _buildXyCols() {
    final c = TDBGridColumns();
    _column(c, "sno", "Shipment No", 14);
    _column(c, "sdate", "Ship Date", 14);
    _column(c, "cno", "Customer Code", 16);  // lookup="cu;cno;cshort"
    _column(c, "cshort", "Customer Short", 20);
    _column(c, "AC", "Tax ID", 12);
    _column(c, "st", "Order Status", 12, align: TAlignment.taCenter);
    _column(c, "AmountTax", "Amount incl. Tax", 16);
    _column(c, "Pay", "Payment", 12, align: TAlignment.taCenter);
    _column(c, "Paid", "Received Amount", 16);
    _column(c, "UnPaid", "Balance Due", 16, ro: true, align: TAlignment.taRightJustify);
    _column(c, "GetDate", "Receipt Date", 12);
    _column(c, "PayDate", "Due Date", 12);
    _column(c, "gno", "Pallet No", 12);
    _column(c, "ChkNo", "Check No", 12);
    _column(c, "fty", "Qty of Pieces", 16);
    _column(c, "RemPay", "Remarks", 40);
    _column(c, "fname", "Shipper Name", 20);
    return c;
  }

  bool _updateTotalRunning = false;
  void _updateTotal() {
    if (_updateTotalRunning) return;
    _updateTotalRunning = true;
    try {
    if (condition("DeletingItems")) return;
    invoke("sn", "GetBookmark", result: "BookMark");
    invoke("sn", "DisableControls");
    invoke("sn", "First");
    setvar("TempTotal", "0");
    while (condition("NOT(sn.EOF)")) {
      setvar("TempTotal", "TempTotal+sn.Total");
      invoke("sn", "Next");
    }
    setvar("sh.Amount", "TempTotal");
    invoke("sn", "EnableControls");
    invoke("sn", "GoToBookmark", params: _ev.getVar("BookMark"));
    invoke("sn", "FreeBookmark");
    } finally {
      _updateTotalRunning = false;
    }
  }

  Future<void> _xyz() async {
    setvar("QUERYGUARD", "QUERYGUARD+1");
    if (condition("QUERYGUARD=1")) {
      setvar("SQL_WHERE", "' AND 2>1'");
      if (condition("SHIPDATE_FROM<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.sdate >= '''+SHIPDATE_FROM+''''");
      if (condition("SHIPDATE_TO<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.sdate <= '''+SHIPDATE_TO+''''");
      if (condition("CUSTNO_TO=''")) {
        if (condition("CUSTNO_FROM<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.cno like '''+CUSTNO_FROM+'%'''");
      } else {
        if (condition("CUSTNO_FROM<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.cno >= '''+CUSTNO_FROM+''''");
        if (condition("CUSTNO_TO<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.cno <= '''+CUSTNO_TO+''''");
      }
      if (condition("REMARK_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.rempay like ''%'+REMARK_KW+'%'''");
      if (condition("CUSTSHORT_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.cshort like '''+CUSTSHORT_KW+'%'''");
      if (condition("TAXID_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.ac like '''+TAXID_KW+'%'''");
      if (condition("BOARDNO_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.gno like '''+BOARDNO_KW+'%'''");
      if (condition("CHKNO_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.chkno like '''+CHKNO_KW+'%'''");
      if (condition("AMOUNTTAX_EQ<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.amounttax = '+AMOUNTTAX_EQ");
      if (condition("PAYTYPE_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.pay like '''+PAYTYPE_KW+''''");
      if (condition("UNPAID_ONLY='Y'")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.AmountTax-ifnull(sh.Paid,0)>0'");
      if (condition("SHIPPER_KW<>''")) setvar("SQL_WHERE", "SQL_WHERE+' AND sh.fno like '''+SHIPPER_KW+''''");
      if (condition("SQL_WHERE=' AND 2>1'")) setvar("SQL_WHERE", "' AND sh.sno=''XYZ'''");
      await dbquery("xy", "select     sh.sno,sh.sdate,sh.cno,cu.cshort,cu.AC,sh.Pay,sh.TaxRate,sh.Amount,sh.Tax,sh.AmountTax,sh.Paid,sh.GetDate,sh.PayDate,     sh.gno,sh.fty,sh.ChkNo,sh.fno,sh.fname,sh.rempay,     CASE     WHEN sh.pc='1' THEN \"Order Received\"     WHEN sh.pc='2' THEN \"Preparing\"     WHEN sh.pc='3' THEN \"Shipped\"     WHEN sh.pc='4' THEN \"Transferring Stock\"     ELSE \"\"     END AS st     from sh, cu     where sh.cno=cu.cno \$SQL_WHERE     order by sh.sno").openAsync();
      _log("");
      await dbquery("sh", r"select * from sh where 1 $SQL_WHERE order by sno").openAsync();
      _shLastKey = '\u0000';
      await _shAfterScroll();
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

  Future<void> _shInsert({bool atEnd = false}) async {
    try {
      await dbquery("ab", r"select * from num where date='$DOCDATE'").openAsync();
      if (condition("ab.count=0")) {
        await _execSql(expandSql(r"insert into num values ('$DOCDATE',0,0)"));
      }
      await _execSql(expandSql(r"update num set sno=sno+1 where date='$DOCDATE'"));
      await dbquery("maxno", r"select sno from num where date='$DOCDATE'").openAsync();
      if (atEnd) {
        _sh.append();
      } else {
        _sh.insert();
      }
      await _saveAsync(_sh);
      await _shAfterScroll();
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
      setvar("DeletingItems", "1");
      await _execSql(expandSql(r"delete from sn where sno='$sh.sno'"));
      setvar("DeletingItems", "0");
      await _delAsync(_sh);
      await _shAfterScroll();
      _snack("Deleted", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Delete failed: $e");
    }
  }

  String _shLastKey = '\u0000';
  Future<void> _shAfterScroll() async {
    final k = _str(_sh, "sno");
    if (k == _shLastKey) return;
    _shLastKey = k;
    if (condition("BARCODEGUARD=1")) {
      await dbquery("sn", r"select * from sn where sno='$sh.sno' order by sno, itm").openAsync();
    }
    if (mounted) setState(() {});
  }

  Future<void> _shBeforeDeleteAsync() async {
    setvar("DeletingItems", "1");
    await _execSql(expandSql(r"delete from sn where sno='$sh.sno'"));
    setvar("DeletingItems", "0");
    if (mounted) setState(() {});
  }

  Future<void> _shCnoChange() async {
    setvar("sh.cshort", "sh.cucshort");
    setvar("sh.AC", "sh.cuac");
    setvar("sh.Pay", "sh.cupay");
    if (condition("sh.cutyp<>''")) setvar("sh.AType", "sh.cutyp");
    await dbquery("sa", r"select sum(Amount+Tax) A, sum(Paid) B, sum(Amount+Tax-Paid) C           from sh where (cno='$sh.cno') and (sdate<'$sys.acbeg')").openAsync();
    if (condition("sa.c>0")) await _alert(expression("'Outstanding balance: '+STR(sa.c)").toString());
    if (mounted) setState(() {});
  }

  Future<void> _snInsert({bool atEnd = false}) async {
    if (_str(_sh, "sno").isEmpty) {
      _snack("Please create the main record first");
      return;
    }
    try {
      await dbquery("maxitm", r"select max(itm) as itm from sn where sno='$sh.sno'").openAsync();
      if (atEnd) {
        _sn.append();
      } else {
        _sn.insert();
      }
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Add failed: $e");
    }
  }

  Future<void> _snPost() async {
    try {
      await _saveAsync(_sn);
      // The detail's afterPost/afterDelete runs a totals function that changes the master; the master needs to be saved back too
      if (dsEditModes.contains(_sh.state)) await _saveAsync(_sh);
      _snack("Saved", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Save failed: $e");
    }
  }

  Future<void> _snDelete() async {
    try {
      await _delAsync(_sn);
      // The detail's afterPost/afterDelete runs a totals function that changes the master; the master needs to be saved back too
      if (dsEditModes.contains(_sh.state)) await _saveAsync(_sh);
      _snack("Deleted", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Delete failed: $e");
    }
  }

  Future<void> _snPNoChange() async {
    if (condition("BARCODEGUARD=0")) {
      await dbquery("bc", r"select pno from pa where barcode='$sn.PNo'").openAsync();
      if (condition("bc.count>0")) {
        setvar("BARCODEGUARD", "1");
        setvar("sn.PNo", "bc.pno");
        setvar("BARCODEGUARD", "0");
      }
    }
    await dbquery("vp", r"select nn.price from sh hh, sn nn where (hh.sno=nn.sno) and (hh.cno='$sh.cno') and (nn.pno='$sn.pno') order by nn.pno, hh.sdate desc").openAsync();
    if (condition("vp.COUNT>0")) setvar("sn.Price", "vp.Price");
    if (condition("vp.COUNT=0")) setvar("sn.Price", "sn.price1");
    if (mounted) setState(() {});
  }

  Future<void> _xyInsert({bool atEnd = false}) async {
    try {
      if (atEnd) {
        _xy.append();
      } else {
        _xy.insert();
      }
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Add failed: $e");
    }
  }

  Future<void> _xyPost() async {
    try {
      await _saveAsync(_xy);
      _snack("Saved", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Save failed: $e");
    }
  }

  Future<void> _xyDelete() async {
    try {
      await _delAsync(_xy);
      _snack("Deleted", ok: true);
      if (mounted) setState(() {});
    } catch (e) {
      _snack("Delete failed: $e");
    }
  }

  Future<void> _goPRICE() async {
    await showDialog(
        context: context,
        builder: (_) => App006CardPRICE(ev: _ev, reg: _reg));
    if (mounted) setState(() {});
  }

  Future<void> _goP1() async {
    await showDialog(
        context: context,
        builder: (_) => App006CardP1(ev: _ev, reg: _reg));
    if (mounted) setState(() {});
  }

  Future<void> _goP2() async {
    await showDialog(
        context: context,
        builder: (_) => App006CardP2(ev: _ev, reg: _reg));
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

  void _log(String msg) => debugPrint("[app006][log] $msg");

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
        constraints: const BoxConstraints(maxWidth: 1300, maxHeight: 840),
        child: SizedBox(width: 1300, child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Container(

            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: _kBlue,
            child: const Row(children: [
              Icon(Icons.article_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Shipment Order Master',
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
                              // <pagecontrol name="pagecontrol" activepageindex="1">
                              Column(children: [
                                TabBar(
                                  controller: _tab,
                                  isScrollable: true,
                                  labelColor: _kBlue,
                                  tabs: const [
                                    Tab(text: "Shipment Entry"),
                                    Tab(text: "Shipment Search"),
                                  ],
                                ),
                                SizedBox(
                                  height: 640,
                                  child: TabBarView(
                                    controller: _tab,
                                    children: [
                                    _tabPage([
                                      // <datasource dataset="sh">
                                      _nav(_shSrc, post: _shPost, insert: _shInsert, del: _shDelete),
                                      // <table columns="3" align="LLL" border="1">
                                      _tbl([
                                        _tdf(460.0, [
                                          _line([
                                            _lbl("Shipment No:"),
                                            _edit(_shSrc, "sno", 14, ro: true, order: 1, autofocus: true, roFocusable: true),
                                          ]),
                                          _line([
                                            _lbl("Ship Date:"),
                                            _edit(_shSrc, "sdate", 14, order: 2),
                                            _lbl("(1.Before Noon 2.Afternoon 3.Anytime)"),
                                          ]),
                                          _line([
                                            _lbl("Customer Code:"),
                                            _lookupBox(_sh, _cu, "cno", 14,
                                                "cno", const ["cname"], order: 3, onPicked: (k) async { if (_sh.state == TDataSetState.dsBrowse) _sh.edit(); setvar("sh.cno", "'${k.replaceAll("'", "''")}'"); _sh.dataEvent(TDataEvent.deRecordChange, 0); await _shCnoChange(); }),  // lookup="cu;cno;cname"
                                            _edit(_shSrc, "cshort", 10, ro: true),
                                            _edit(_shSrc, "cupay", 10, ro: true),
                                          ]),
                                          _line([
                                            _lbl("Created Date:"),
                                            _edit(_shSrc, "cdate", 14, ro: true),
                                          ]),
                                        ]),
                                        _vdiv(),
                                        _tdf(300.0, [
                                          _line([
                                            _lbl("Employee ID:"),
                                            _lookupBox(_sh, _em, "eno", 14,
                                                "eno", const ["ename"], order: 4),  // lookup="em;eno;ename"
                                            _edit(_shSrc, "ename", 10, ro: true),
                                          ]),
                                          _line([
                                            _lbl("Shipper Code:"),
                                            _lookupBox(_sh, _fm, "fno", 14,
                                                "fno", const ["fname"], order: 5),  // lookup="fm;fno;fname"
                                            _edit(_shSrc, "fmfname", 10, ro: true),
                                          ]),
                                          _line([
                                            _lbl("Pallet No:"),
                                            _edit(_shSrc, "gno", 14, order: 6),
                                          ]),
                                          _line([
                                            _lbl("Qty of Pieces:"),
                                            _edit(_shSrc, "fty", 14, order: 7),
                                          ]),
                                        ]),
                                        _vdiv(),
                                        _tdf(460.0, [
                                          _line([
                                            _lbl("Sales Tax Rate:"),
                                            _edit(_shSrc, "TaxRate", 1, order: 8),
                                          ]),
                                          _line([
                                            _lbl("Order Status:"),
                                            _edit(_shSrc, "pc", 1, order: 9),
                                            _lbl("(1.Order Received 2.Preparing 3.Shipped 4.Transferring)"),
                                          ]),
                                          _line([
                                            _lbl("Sales Channel:"),
                                            _edit(_shSrc, "source", 1, order: 10),
                                            _lbl("(1.In-Store 2.Online)"),
                                          ]),
                                        ]),
                                      ], border: true),
                                      // <datasource dataset="sn">
                                      Row(children: [
                                        Expanded(child: _nav(_snSrc, post: _snPost, insert: _snInsert, del: _snDelete)),
                                        TButton(caption: "PRICE", onClick: _goPRICE),
                                      ]),
                                      Center(child: // <dbgrid width="1280" height="200">
                                      FocusTraversalOrder(
                                        order: const NumericFocusOrder(11),
                                        child: FocusTraversalGroup(
                                          child: TDBGrid(
                                            dataSource: _snSrc,
                                            columns: _snCols,
                                            width: 1280,
                                            height: 200,
                                            onRowPost: _snPost,
                                            onRowInsert: () => _snInsert(atEnd: true),
                                            onExitLastRow: () => FocusScope.of(context).nextFocus(),
                                            // <item field="PNo" lookup="pa;pno;des"/>
                                            lookupResolver: (field) {
                                              if (field.toLowerCase() != "pno") return null;
                                              return TDBGridLookupSpec(
                                                rows: _paRows,
                                                colWidths: const [160],
                                                onPicked: (k) async {
                                                  setvar("sn.PNo", "'$k'");
                                                  await _snPNoChange();
                                                  if (mounted) setState(() {});
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      )),
                                      // </datasource sn>
                                      const SizedBox(height: 8),
                                      // <table columns="3" align="LLR">
                                      _tbl([
                                        _tdf(400.0, [
                                          _line([
                                            _lbl("Shipment Remarks"),
                                          ]),
                                          _line([
                                            _edit(_shSrc, "Rem", 50, memo: true, order: 12),
                                          ]),
                                        ]),
                                        _tdf(400.0, [
                                          _line([
                                            _lbl("Online Customer Note"),
                                          ]),
                                          _line([
                                            _edit(_shSrc, "topic", 50, ro: true, memo: true),
                                          ]),
                                        ]),
                                        _tdf(200.0, [
                                          _line([
                                            _lbl("Subtotal:"),
                                            _edit(_shSrc, "Amount", 11, ro: true),
                                          ]),
                                          _line([
                                            _lbl("Sales Tax:"),
                                            _edit(_shSrc, "Taxx", 11, ro: true),
                                          ]),
                                          _line([
                                            _lbl("Paid Amount:"),
                                            _edit(_shSrc, "Paid", 11, order: 13),
                                          ]),
                                          _line([
                                            _lbl("Balance Due:"),
                                            _edit(_shSrc, "UnPaid", 11, ro: true),
                                          ]),
                                        ], al: "R"),
                                      ]),
                                      // </datasource sh>
                                    ]),
                                    _tabPage([
                                      // <table columns="7" align="LLLLLLL" border="1">
                                      _tbl([
                                        _tdf(180.0, [
                                          _line([
                                            _lbl("Ship Date Fr:"),
                                            _vedit("SHIPDATE_FROM", "_SHIPDATE_FROM", 12, order: 14),
                                          ]),
                                          _line([
                                            _lbl("Ship Date To:"),
                                            _vedit("SHIPDATE_TO", "''", 12, order: 15),
                                          ]),
                                        ]),
                                        _vdiv(),
                                        _tdf(180.0, [
                                          _line([
                                            _lbl("Cust Code Fr:"),
                                            _vlookup("CUSTNO_FROM", "_CUSTNO_FROM", _cu, 12,
                                                "cno", const ["cshort"], order: 16),  // lookup="cu;cno;cshort"
                                          ]),
                                          _line([
                                            _lbl("Cust Code To:"),
                                            _vlookup("CUSTNO_TO", "_CUSTNO_TO", _cu, 12,
                                                "cno", const ["cshort"], order: 17),  // lookup="cu;cno;cshort"
                                          ]),
                                        ]),
                                        _vdiv(),
                                        _tdf(160.0, [
                                          _line([
                                            _lbl("Short Name:"),
                                            _vedit("CUSTSHORT_KW", "_CUSTSHORT_KW", 10, order: 18),
                                          ]),
                                          _line([
                                            _lbl("Tax ID:"),
                                            _vedit("TAXID_KW", "_TAXID_KW", 10, order: 19),
                                          ]),
                                        ]),
                                        _vdiv(),
                                        _tdf(160.0, [
                                          _line([
                                            _lbl("Incl. Tax:"),
                                            _vedit("AMOUNTTAX_EQ", "_AMOUNTTAX_EQ", 12, order: 20),
                                          ]),
                                          _line([
                                            _lbl("Payment:"),
                                            _vedit("PAYTYPE_KW", "_PAYTYPE_KW", 12, order: 21),
                                          ]),
                                        ]),
                                        _vdiv(),
                                        _tdf(160.0, [
                                          _line([
                                            _lbl("Pallet No:"),
                                            _vedit("BOARDNO_KW", "_BOARDNO_KW", 12, order: 22),
                                          ]),
                                          _line([
                                            _lbl("Check No:"),
                                            _vedit("CHKNO_KW", "_CHKNO_KW", 12, order: 23),
                                          ]),
                                        ]),
                                        _vdiv(),
                                        _tdf(180.0, [
                                          _line([
                                            _lbl("Shipper:"),
                                            _vlookup("SHIPPER_KW", "_SHIPPER_KW", _fm, 12,
                                                "fno", const ["fname"], order: 24),  // lookup="fm;fno;fname"
                                          ]),
                                          _line([
                                            _lbl("Remarks:"),
                                            _vedit("REMARK_KW", "_REMARK_KW", 12, order: 25),
                                          ]),
                                          _line([
                                            _lbl("Unpaid:"),
                                            _vcheck("UNPAID_ONLY", "Y"),
                                          ]),
                                        ]),
                                        _vdiv(),
                                        _tdf(100.0, [
                                          _line([
                                            TButton(caption: "Search", onClick: () async { await _xyz(); if (mounted) setState(() {}); }),
                                          ]),
                                          _line([
                                            TButton(caption: "Clear", onClick: () async { await _clr(); if (mounted) setState(() {}); }),
                                          ]),
                                        ]),
                                      ], border: true),
                                      // <datasource dataset="xy">
                                      _nav(_xySrc, post: _xyPost, insert: _xyInsert, del: _xyDelete),
                                      Center(child: // <dbgrid width="1280" height="450">
                                      FocusTraversalOrder(
                                        order: const NumericFocusOrder(26),
                                        child: FocusTraversalGroup(
                                          child: TDBGrid(
                                            dataSource: _xySrc,
                                            columns: _xyCols,
                                            width: 1280,
                                            height: 450,
                                            onRowPost: _xyPost,
                                            onExitLastRow: () => FocusScope.of(context).nextFocus(),
                                            onRowActivate: (_) {
                                              _set();
                                              _tab.animateTo(0);
                                              _sh.locate(expression("'sno'"), expression("xy.sno"), {TLocateOption.loCaseInsensitive, TLocateOption.loPartialKey});
                                              if (mounted) setState(() {});
                                            },
                                            // <item field="cno" lookup="cu;cno;cshort"/>
                                            lookupResolver: (field) {
                                              if (field.toLowerCase() != "cno") return null;
                                              return TDBGridLookupSpec(
                                                rows: _cuRows,
                                                colWidths: const [160],
                                                onPicked: (k) async {
                                                  setvar("xy.cno", "'$k'");
                                                  if (mounted) setState(() {});
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      )),
                                      // </datasource xy>
                                    ]),
                                    ],
                                  ),
                                ),
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
              TButton(caption: "Shipment Order", onClick: () async {
                await _goP1();
                if (mounted) setState(() {});
              }),
              const SizedBox(width: 8),
              TButton(caption: "Purchase Order", onClick: () async {
                await _goP2();
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

class App006CardPRICE extends StatefulWidget {
  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  const App006CardPRICE({super.key, this.ev, this.reg});
  @override
  State<App006CardPRICE> createState() =>
      _App006CardPRICEState();
}

class _App006CardPRICEState
    extends State<App006CardPRICE> {
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

  // [diag] ds "cp": foreign=0 declared=1 lookupSrc=0 fields=0
  late final TSQLQuery _cp = dbquery("cp", r"SELECT       hh.sno, hh.sdate, nn.price     FROM       sh hh, sn nn     WHERE       hh.sno=nn.sno and hh.cno = '$sh.cno' and nn.pno='$sn.pno'     ORDER BY       hh.sno desc, hh.sdate");

  late final TDataSource _cpSrc;

  late final TDBGridColumns _cpCols = _buildCpCols();

  bool   _loading = true;
  String _error   = '';

  @override
  void initState() {
    super.initState();
    varChangeHooks.add(_varSync);
    _conn();

    _cpSrc = TDataSource()..dataSet = _cp;
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
    _cpSrc.dataSet = null;
    _cp.free();
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
    _reg.put("cp", _cp);
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = ''; });
    try {
      for (final id in ['cp']) {
        try {
          final ds = _reg.findQuery(id)!;
          await dbquery(id, ds.sql.text).openAsync();
        } catch (e) {
          debugPrint("[app006] $id skip: $e");
        }
      }

    } catch (e, st) {
      debugPrint("[app006] _load ERROR: $e\n$st");
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  TDBGridColumns _buildCpCols() {
    final c = TDBGridColumns();
    _column(c, "sno", "sno", 12);
    _column(c, "sdate", "sdate", 12);
    _column(c, "Price", "Price", 12);
    return c;
  }

  Future<void> _goPRICE() async {
    await showDialog(
        context: context,
        builder: (_) => App006CardPRICE(ev: _ev, reg: _reg));
    if (mounted) setState(() {});
  }

  Future<void> _goP1() async {
    await showDialog(
        context: context,
        builder: (_) => App006CardP1(ev: _ev, reg: _reg));
    if (mounted) setState(() {});
  }

  Future<void> _goP2() async {
    await showDialog(
        context: context,
        builder: (_) => App006CardP2(ev: _ev, reg: _reg));
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

  void _log(String msg) => debugPrint("[app006][log] $msg");

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
        constraints: const BoxConstraints(maxWidth: 1300, maxHeight: 840),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: _kBlue,
            child: const Row(children: [
              Icon(Icons.article_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Customer Price Lookup',
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
                              // <datasource dataset="cp">
                              _nav(_cpSrc),
                              const SizedBox(height: 8),
                              Center(child: // <dbgrid width="1280" height="240">
                              FocusTraversalOrder(
                                order: const NumericFocusOrder(1),
                                child: FocusTraversalGroup(
                                  child: TDBGrid(
                                    dataSource: _cpSrc,
                                    columns: _cpCols,
                                    width: 1280,
                                    height: 240,
                                    onExitLastRow: () => FocusScope.of(context).nextFocus(),
                                  ),
                                ),
                              )),
                              // </datasource cp>
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
        ]),
      ),
    );
  }
}

class App006ReportP1 extends WapReport {
  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  late final WapEvaluator _ev = ev ?? WapEvaluator();
  late final DataSetRegistry _reg = reg ?? DataSetRegistry();

  App006ReportP1({this.ev, this.reg});

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
    wap.wapLpp = 9999;
    wap.wapGroups = 1;
  }
  @override
  String expression(int idx) => '';
  @override
  Future<bool> fetchFirst() async => false;
  @override
  Future<bool> fetchNext() async => false;
  @override
  Future<void> fetchPrior() async {}
  @override
  void parseBlock(String id) {}

  void _header() {
        emit(expandText(r'''<table width="740" align="center"><tr><td>'''));
        emit(expandText(r'''<p align="center"><big><b>$sys.company<br/><u>Shipment Order</u></b></big></p>'''));
        emit(expandText(r'''<table width="100%" border="0" cellspacing="0"><tr><td width="350">Customer Name:$sh.cname[$sh.cno]</td><td></td><td width="150">Ship Date:$sh.sdate</td></tr><tr><td>Tax ID:$sh.ac</td><td>Phone:$sh.phone</td><td>Shipment No:$sh.sno</td></tr><tr><td>Contact  Person:$sh.contact</td><td></td><td>Invoice Date:$sh.adate</td></tr><tr><td>Sales  Rep:$sh.ename</td><td>Fax:$sh.fax</td><td>Invoice Type:$(IF(sh.atype=2,'2-Part',IF(sh.atype=3,'3-Part','None')))</td></tr><tr><td colspan="2">Delivery Address:$sh.addr1</td><td>Invoice No:$sh.ano</td></tr></table>'''));
        emit(expandText(r'''<p align="center">123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890</p>'''));
        emit(expandText(r'''<table class="p10" width="100%">'''));
        emit(expandText(r'''<tr><th style="width:11%;">Item No</th><th style="width:33%;">Item Name / Spec</th><th style="width:8%;">Quantity</th><th style="width:7%;">Unit</th><th style="width:8%;">Unit Price</th><th style="width:9%;">Amount</th><th style="width:24%;">Remarks</th></tr>'''));
  }

  void _normal() {
        emit(expandText(r'''<tr><td style="width:11%;">$(sn.pno)</td><td style="width:33%;"><p align="left">$(sn.des)</p></td><td style="width:8%;"><p align="center">$(FORMAT('%6.0n',sn.qty*1.0))</p></td><td style="width:7%;"><p align="center">$(sn.unit)</p></td><td style="width:8%;"><p align="right">$(FORMAT('%6.1n',sn.price*1.0))</p></td><td style="width:9%;"><p align="right">$(FORMAT('%8.0n',sn.total*1.0))</p></td><td style="width:24%;"><p>$(sn.rem)</p></td></tr>'''));
  }

  void _space() {
        emit(expandText(r'''<tr><td style="width:11%;">AAA</td><td style="width:33%;"></td><td style="width:8%;"></td><td style="width:7%;"></td><td style="width:8%;"></td><td style="width:9%;"></td><td style="width:24%;"></td></tr>'''));
  }

  void _footer() {
        emit(expandText(r'''</table>'''));
        emit(expandText(r'''<table class="b10" width="100%">'''));
        emit(expandText(r'''<tr><td style="width:11%;" colspan="4"></td><td style="width:8%;"><p align="center">Subtotal<br/>Tax    <br/>Total</p></td><td style="width:9%;"><p align="right"><br/><br/></p></td></tr>'''));
        emit(expandText(r'''</table>'''));
        emit(expandText(r'''<br/>'''));
        emit(expandText(r'''<table border="0" cellspacing="0" width="100%"><tr><td>Shipped by:</td><td>Issued by:</td><td>Checked by:</td><td><p align="right">Page:$(CEIL(sn.count / 9))-$PAGENO</p></td></tr></table>'''));
        emit(expandText(r'''</td></tr></table>'''));
  }

  void _summary() {
        emit(expandText(r'''</table>'''));
        emit(expandText(r'''<table class="b10" width="100%">'''));
        emit(expandText(r'''<tr><td style="width:11%;" colspan="4">Remarks:$sh.rem</td><td style="width:8%;"><p align="center">Subtotal<br/>Tax    <br/>Total</p></td><td style="width:9%;"><p align="right">$(FORMAT('%8.0n',sh.amount*1.0))<br/>
						$(FORMAT('%8.0n',sh.tax*1.0))<br/>$(FORMAT('%8.0n',(sh.amount+sh.tax)*1.0))<br/></p></td></tr>'''));
        emit(expandText(r'''</table>'''));
        emit(expandText(r'''<br/>'''));
        emit(expandText(r'''<table border="0" cellspacing="0" width="100%"><tr><td>Shipped by:</td><td>Issued by:</td><td>Checked by:</td><td><p align="right">Page:$(CEIL(sn.count / 9))-$PAGENO</p></td></tr></table>'''));
        emit(expandText(r'''</td></tr></table>'''));
  }

  @override
  Future<void> run() async {
    lines.clear();
    try {
      _reg.findQuery("sn")?.disableControls();
      _reg.findQuery("sh")?.disableControls();
      emit('<table width="750" align="center"><tr><td>');
      setvar("PAGENO", "1");
      setvar("LINECOUNT", "0");
      if (condition("sn.state<>'BROWSE'")) {
        invoke("sn", "post");
      }
      if (condition("sh.state<>'BROWSE'")) {
        invoke("sh", "post");
      }
      invoke("sn", "GetBookmark", result: "BookMark");
      invoke("sn", "DisableControls");
      invoke("sn", "First");
      _header();
      while (condition("NOT(sn.EOF)")) {
        setvar("LINECOUNT", "LINECOUNT+1");
        if (condition("LINECOUNT>9")) {
          _footer();
          emit('<div style="page-break-after:always"></div>');
          setvar("PAGENO", "PAGENO+1");
          setvar("LINECOUNT", "1");
          _header();
        }
        _normal();
        invoke("sn", "Next");
      }
      while (condition("LINECOUNT<9")) {
        setvar("LINECOUNT", "LINECOUNT+1");
        _space();
      }
      _summary();
      invoke("sn", "EnableControls");
      invoke("sn", "GoToBookmark", params: _ev.getVar("BookMark"));
      invoke("sn", "FreeBookmark");
      emit('</td></tr></table>');
    } finally {
      _reg.findQuery("sn")?.enableControls();
      _reg.findQuery("sh")?.enableControls();
    }
  }
}

class App006CardP1 extends StatefulWidget {
  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  const App006CardP1({super.key, this.ev, this.reg});
  @override
  State<App006CardP1> createState() =>
      _App006CardP1State();
}

class _App006CardP1State
    extends State<App006CardP1> {
  late final WapEvaluator _ev = widget.ev ?? WapEvaluator();
  late final DataSetRegistry _reg = widget.reg ?? DataSetRegistry();
  bool get _ownsReg => widget.reg == null;
  final List<String> _ownedDs = []; // datasets this card created

  bool _loading = true;
  String _error = '';
  App006ReportP1? _rep;

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

  // [diag] ds "sn": foreign=1 declared=1 lookupSrc=0 fields=0
  // [diag] ds "sh": foreign=1 declared=1 lookupSrc=0 fields=0
  TSQLQuery get _sn => _reg.findQuery("sn")!;
  TSQLQuery get _sh => _reg.findQuery("sh")!;

  @override
  void initState() {
    super.initState();
    _conn();
    useEngine(_ev, _reg);

    setvar("PAGENO", "1");
    setvar("LINECOUNT", "0");
    _load();
  }

  @override
  void dispose() {
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

  Future<void> _load() async {
    try {
      _rep = App006ReportP1(ev: _ev, reg: _reg);
    } catch (e, st) {
      debugPrint("[app006] card P1 ERROR: $e\n$st");
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
      title: "Shipment Order",
      report: _rep,
      paper: r"8.5x5.5",
      orient: r"P",
    );
  }
}

class App006ReportP2 extends WapReport {
  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  late final WapEvaluator _ev = ev ?? WapEvaluator();
  late final DataSetRegistry _reg = reg ?? DataSetRegistry();

  App006ReportP2({this.ev, this.reg});

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
    wap.wapLpp = 9999;
    wap.wapGroups = 1;
  }
  @override
  String expression(int idx) => '';
  @override
  Future<bool> fetchFirst() async => false;
  @override
  Future<bool> fetchNext() async => false;
  @override
  Future<void> fetchPrior() async {}
  @override
  void parseBlock(String id) {}

  void _header() {
        emit(expandText(r'''<table width="760" align="center"><tr><td>'''));
        emit(expandText(r'''<p align="center"><big><b>$sys.company<br/><u>Purchase Order</u></b></big></p>'''));
        emit(expandText(r'''<table width="100%" border="0"><tr><td width="350">Customer Name:$sh.cname[$sh.cno]</td><td></td><td width="150">Ship Date:$sh.sdate</td></tr><tr><td>Tax ID:$sh.ac</td><td>Phone:$sh.phone</td><td>Shipment No:$sh.sno</td></tr><tr><td>Contact  Person:$sh.contact</td><td></td><td>Invoice Date:$sh.adate</td></tr><tr><td>Sales  Rep:$sh.ename</td><td>Fax:$sh.fax</td><td>Invoice Type:$(IF(sh.atype=2,'2-Part',IF(sh.atype=3,'3-Part','None')))</td></tr><tr><td colspan="2">Delivery Address:$sh.addr1</td><td>Invoice No:$sh.ano</td></tr></table>'''));
        emit(expandText(r'''<table border="1" cellspacing="0" width="100%">'''));
        emit(expandText(r'''<tr><th style="width:13%;">Item No</th><th style="width:27%;">Item Name / Spec</th><th style="width:6%;">Unit</th><th style="width:12%;">Quantity</th><th style="width:12%;">Unit Price</th><th style="width:12%;">Amount</th><th style="width:18%;">Remarks</th></tr>'''));
        emit(expandText(r'''</table>'''));
        emit(expandText(r'''<table border="0" width="100%">'''));
  }

  void _normal() {
        setvar("LINE_SUBTOTAL", "sn.qty*sn.pricea");
        setvar("TempTotal", "TempTotal+LINE_SUBTOTAL");
        emit(expandText(r'''<tr><td style="width:13%;">$(sn.pno)</td><td style="width:27%;"><p align="left">$(sn.des)</p></td><td style="width:6%;"><p align="center">$(sn.unit)</p></td><td style="width:12%;"><p align="right">$(FORMAT('%6.0n',sn.qty*1.0))</p></td><td style="width:12%;"><p align="right">$(FORMAT('%6.1n',sn.pricea*1.0))</p></td><td style="width:12%;"><p align="right">$(FORMAT('%8.0n',LINE_SUBTOTAL*1.0))</p></td><td style="width:18%;"><p>$(sn.rem)</p></td></tr>'''));
  }

  void _space() {
        emit(expandText(r'''<tr><td style="width:13%;">AAA</td><td style="width:27%;"></td><td style="width:6%;"></td><td style="width:12%;"></td><td style="width:12%;"></td><td style="width:12%;"></td><td style="width:18%;"></td></tr>'''));
  }

  void _footer() {
        emit(expandText(r'''</table>'''));
        emit(expandText(r'''<table border="1" cellspacing="0" width="100%">'''));
        emit(expandText(r'''<tr><td style="width:13%;" colspan="4"></td><td style="width:12%;"><p align="center">Subtotal<br/>Tax    <br/>Total</p></td><td style="width:12%;"><p align="right"><br/><br/></p></td></tr>'''));
        emit(expandText(r'''</table>'''));
        emit(expandText(r'''<p align="center">Page:$(CEIL(sn.count / 9))-$PAGENO</p>'''));
        emit(expandText(r'''<p align="center">123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890</p>'''));
        emit(expandText(r'''</td></tr></table>'''));
  }

  void _summary() {
        emit(expandText(r'''</table>'''));
        emit(expandText(r'''<table border="1" cellspacing="0" width="100%">'''));
        emit(expandText(r'''<tr><td style="width:13%;" colspan="4">Remarks:$sh.rem</td><td style="width:12%;"><p align="center">Subtotal<br/>Tax    <br/>Total</p></td><td style="width:12%;"><p align="right">$(FORMAT('%8.0n',TempTotal*1.0))<br/>
						$(FORMAT('%8.0n',ROUND(TempTotal*sh.taxrate/100,0)*1.0))<br/>
						$(FORMAT('%8.0n',(TempTotal+(ROUND(TempTotal*sh.taxrate/100,0)))*1.0))<br/></p></td></tr>'''));
        emit(expandText(r'''</table>'''));
        emit(expandText(r'''<p align="center">Page:$(CEIL(sn.count / 9))-$PAGENO</p>'''));
        emit(expandText(r'''<p align="center">123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890</p>'''));
        emit(expandText(r'''</td></tr></table>'''));
  }

  @override
  Future<void> run() async {
    lines.clear();
    try {
      _reg.findQuery("sn")?.disableControls();
      _reg.findQuery("sh")?.disableControls();
      emit('<table width="750" align="center"><tr><td>');
      setvar("PAGENO", "1");
      setvar("LINECOUNT", "0");
      setvar("LINE_SUBTOTAL", "0");
      setvar("TempTotal", "0");
      if (condition("sn.state<>'BROWSE'")) {
        invoke("sn", "post");
      }
      if (condition("sh.state<>'BROWSE'")) {
        invoke("sh", "post");
      }
      invoke("sn", "GetBookmark", result: "BookMark");
      invoke("sn", "DisableControls");
      invoke("sn", "First");
      _header();
      while (condition("NOT(sn.EOF)")) {
        setvar("LINECOUNT", "LINECOUNT+1");
        if (condition("LINECOUNT>9")) {
          _footer();
          emit('<div style="page-break-after:always"></div>');
          setvar("PAGENO", "PAGENO+1");
          setvar("LINECOUNT", "1");
          _header();
        }
        _normal();
        invoke("sn", "Next");
      }
      while (condition("LINECOUNT<9")) {
        setvar("LINECOUNT", "LINECOUNT+1");
        _space();
      }
      _summary();
      invoke("sn", "EnableControls");
      invoke("sn", "GoToBookmark", params: _ev.getVar("BookMark"));
      invoke("sn", "FreeBookmark");
      emit('</td></tr></table>');
    } finally {
      _reg.findQuery("sn")?.enableControls();
      _reg.findQuery("sh")?.enableControls();
    }
  }
}

class App006CardP2 extends StatefulWidget {
  final WapEvaluator? ev;
  final DataSetRegistry? reg;
  const App006CardP2({super.key, this.ev, this.reg});
  @override
  State<App006CardP2> createState() =>
      _App006CardP2State();
}

class _App006CardP2State
    extends State<App006CardP2> {
  late final WapEvaluator _ev = widget.ev ?? WapEvaluator();
  late final DataSetRegistry _reg = widget.reg ?? DataSetRegistry();
  bool get _ownsReg => widget.reg == null;
  final List<String> _ownedDs = []; // datasets this card created

  bool _loading = true;
  String _error = '';
  App006ReportP2? _rep;

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

  // [diag] ds "sn": foreign=1 declared=1 lookupSrc=0 fields=0
  // [diag] ds "sh": foreign=1 declared=1 lookupSrc=0 fields=0
  TSQLQuery get _sn => _reg.findQuery("sn")!;
  TSQLQuery get _sh => _reg.findQuery("sh")!;

  @override
  void initState() {
    super.initState();
    _conn();
    useEngine(_ev, _reg);

    setvar("PAGENO", "1");
    setvar("LINECOUNT", "0");
    setvar("LINE_SUBTOTAL", "0");
    setvar("TempTotal", "0");
    _load();
  }

  @override
  void dispose() {
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

  Future<void> _load() async {
    try {
      _rep = App006ReportP2(ev: _ev, reg: _reg);
    } catch (e, st) {
      debugPrint("[app006] card P2 ERROR: $e\n$st");
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
      title: "Purchase Order",
      report: _rep,
      paper: r"8.5x5.5",
      orient: r"P",
    );
  }
}
