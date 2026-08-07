// ═════════════════════════════════════════════════════════════════════════════
//  wapform_report.dart
//  WML banded report engine —— corresponds to WML's <output> / <page> / <group>
//
//  This file is original code (not translated from FPC/Lazarus sources).
//  But it depends on the LGPL translation modules in this repo, so it
//  carries the same license.
//
//  License: GNU Lesser General Public License v2.1, with the static
//  linking exception (Modified LGPL). See the accompanying
//  COPYING.LGPL.txt and COPYING.modifiedLGPL.txt.
//
//  Copyright (c) 2026 Minhong Information Co., Ltd. (wapform.com)
// ─────────────────────────────────────────────────────────────────────────────
//  Contract that subclasses must override:
//    initParams()        set wapLpp (lines per page) / wapGroups (number of group levels)
//    expression(idx)     the value used to detect a group break (a changed value triggers a break)
//    fetchFirst/Next/Prior()  dataset traversal
//    parseBlock(blockId) emits each block:
//        PREFIX / PAGEPREFIX / G1_PREFIX / RECORD / G1_SUFFIX /
//        PAGESUFFIX / PAGEBREAK / SUFFIX
//
//  Provided by the engine: emit() to produce a line, run() the main loop
//  (pagination + group breaks), buildHtml(), buildPdf(), WapPage (the
//  on-screen preview widget)
// ═════════════════════════════════════════════════════════════════════════════
// lib/wap/wap_report.dart
// WapForm Report Engine — Flutter port of Delphi TCard._report
//
// Revision History:
//   2026-05-23  V1.0  Initial release
//   2026-05-26  V1.1  run() now fully corresponds to Delphi TCard._report's main loop
//   2026-05-26  V1.2  _checkFtrs() now returns bool
//   2026-05-26  V1.3  flushBuf row1 forced to white
//   2026-05-26  V1.4  Full comments added, frozen
//   2026-06-06  V2.0  Switched entirely to HTML output:
//                     - removed the pw/pdf packages
//                     - buildPdf() now uses Printing.convertHtml() + a base64 font
//                     - buildHtml() added, generates HTML using isHeader/isFooter/tag
//                     - the WapLine/emit()/columns interface fully preserved (backward compatible)
//                     - WapPage generic display layer integrated

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
// aa ### flutter extension
// flutter_html 3.x's <table> needs this extension to render as a real
// table; without it, <tr>/<td> get stacked as ordinary blocks (the
// report's layout falls apart).
import 'package:flutter_html_table/flutter_html_table.dart';
// zz ### flutter extension
import 'package:printing/printing.dart';
import 'wapform_colors.dart'; // @@@ shared by both sets, keeping the old name (a static table can only have one copy)
import 'wapform_report_style.dart'; // @@@ shared report CSS (pulled into its own file)
import 'wapform_lazarus.dart'; // @@@ expandText(): $(expression) → string (replaces wap_tag's WapCdata.ev)
// @@@ platform-agnostic wrapper: picks the dart:html/dart:ui_web
// implementation on Flutter Web, and a no-op stub on mobile/desktop, so
// this file compiles on every platform (see src/report_web.dart).
import 'src/report_web.dart';

// ════════════════════════════════════════════════════════════
//  Constants
// ════════════════════════════════════════════════════════════
const int kMaxGroups = 9;

// ════════════════════════════════════════════════════════════
//  WapGroupRow
// ════════════════════════════════════════════════════════════
class WapGroupRow {
  bool   prefixChk = false;
  bool   suffixChk = false;
  String str       = '';
  String prefixTxt = '';
  String suffixTxt = '';
  String tagPrefix = '';
  String tagSuffix = '';
}

// ════════════════════════════════════════════════════════════
//  WapStorage
// ════════════════════════════════════════════════════════════
class WapStorage {
  int    wapIdx      = 0;
  int    wapGroups   = 0;
  bool   wapChgFound = false;
  String wapExpVal   = '';
  int    wapLpp      = 60;
  int    wapLineNo   = 0;
  int    wapPageNo   = 0;
  bool   wapHasMore  = false;
  bool   wapEnable   = true;
  String wapBlockId  = '';

  final List<WapGroupRow> wapRow =
      List.generate(kMaxGroups, (_) => WapGroupRow());
}

// ════════════════════════════════════════════════════════════
//  WapLine — the original interface fully preserved
// ════════════════════════════════════════════════════════════
class WapLine {
  final String blockId;
  final String text;      // an HTML string, or tab-separated columns
  final int    pageNo;
  final int    lineNo;
  final bool   isHeader;
  final bool   isFooter;
  final String tag;       // CSS class (e.g. 'row1'/'row2')

  const WapLine({
    required this.blockId,
    required this.text,
    required this.pageNo,
    required this.lineNo,
    this.isHeader = false,
    this.isFooter = false,
    this.tag      = '',
  });
}

// ════════════════════════════════════════════════════════════
//  WapReport — abstract base class
// ════════════════════════════════════════════════════════════
abstract class WapReport {

  final WapStorage    wap   = WapStorage();
  final List<WapLine> lines = [];

  void          initParams();
  String        expression(int idx);
  Future<bool>  fetchFirst();
  Future<bool>  fetchNext();
  Future<void>  fetchPrior();
  void          parseBlock(String blockId);
  // @@@ Async preparation for a group break (opens the <dbquery> used for
  //     group aggregation). parseBlock is synchronous and can't await, so
  //     anything that needs an async <dbquery>.openAsync() is opened here
  //     ahead of time instead. No-op by default; report generators with
  //     group queries override this.
  Future<void> onGroupPrepare() async {}

  // ── emit() — original interface fully preserved ──────────────────────
  void emit(String text, {
    bool   isHeader = false,
    bool   isFooter = false,
    String tag      = '',
  }) {
    lines.add(WapLine(
      blockId:  wap.wapBlockId,
      text:     text,
      pageNo:   wap.wapPageNo,
      lineNo:   wap.wapLineNo,
      isHeader: isHeader,
      isFooter: isFooter,
      tag:      tag,
    ));
  }

  // ── columns / linesPerRecord / lineToColumns — original interface preserved ─
  List<(double?, String)> get columns => [];
  int get linesPerRecord => 1;
  List<String> lineToColumns(WapLine line) =>
      line.text.split('\t').map((s) => s.trim()).toList();

  // ── run() — unchanged from the original ─────────────────────────────────
  Future<void> run() async {
    lines.clear();
    initParams();
    if (_invalid()) return;

    wap.wapHasMore = await fetchFirst();
    if (!wap.wapHasMore) return;

    _cacheInit();

    wap.wapBlockId = 'PREFIX';
    wap.wapEnable  = true;
    parseBlock('PREFIX');

    _newPageStart();

    while (wap.wapHasMore) {
      _checkHdrs();
      if (wap.wapChgFound) {
        await onGroupPrepare(); // @@@ On a group break, first (async) open the <dbquery> the group needs
        _emitHdrs();
      }

      wap.wapBlockId = 'RECORD';
      wap.wapEnable  = true;
      parseBlock('RECORD');
      _hadRecordThisPage = true; // @@@ this page now has a detail row

      wap.wapHasMore = await fetchNext();

      if (wap.wapHasMore) {
        if (_checkFtrs()) {
          await fetchPrior();
          _emitFtrs();
          wap.wapHasMore = await fetchNext();
        }
      }

// aa ### flutter extension
      // There used to be a "check for a page break only after printing a
      // whole record" check here:
      //     if (wapHasMore && wapLineNo >= wapLpp) { close out the page → page break }
      // This has been removed — page breaks are now decided by
      // emitRow() on "every single line printed" instead.
      // Reason: a sub-report's rows (device="sub") also belong to the
      //         main report's page flow, and can be nested multiple
      //         levels deep; checking only at the outermost level means
      //         a single main record dragging along N levels of
      //         sub-reports could blow the layout apart.
// zz ### flutter extension
    }

    _flushLastFtrs();
    _emitFtrs();
    _newPageEnd();

    wap.wapBlockId = 'SUFFIX';
    wap.wapEnable  = false;
    parseBlock('SUFFIX');
  }

  // ── buildHtml() — WapLine → HTML ─────────────────────────
  // isHeader → bold <tr>, header background color
  // isFooter → gray text
  // tag      → CSS class ('row1'/'row2', etc.)
  // columns  → if defined, tab-separated text is converted to <td>; otherwise the whole line is output as-is
  String buildHtml() {
    final useTable = columns.isNotEmpty;
    final buf = StringBuffer();

    if (useTable) {
      buf.writeln('<table>');
      for (final l in lines) {
        final bg = _rowBg(l);
        final fw = l.isHeader ? 'font-weight:bold;' : '';
        final fc = l.isFooter ? 'color:#666;' : '';
        final cells = lineToColumns(l);
        buf.write('<tr style="background:$bg;$fc">');
        for (int ci = 0; ci < columns.length; ci++) {
          final w   = columns[ci].$1 != null ? ' width="${columns[ci].$1!.toInt()}"' : '';
          final txt = ci < cells.length ? cells[ci] : '';
          buf.write('<td$w style="$fw">$txt</td>');
        }
        buf.writeln('</tr>');
      }
      buf.writeln('</table>');
    } else {
      // No column definitions: output `text` directly (it may already be an HTML string)
      for (final l in lines) {
        buf.writeln(l.text);
      }
    }

    return buf.toString();
  }

  String _rowBg(WapLine l) {
    if (l.isHeader)        return WapColors.hexTrRow;
    if (l.tag.isNotEmpty)  return WapColors.hex(l.tag);
    return 'transparent';
  }

  // ── buildPdf() — Web: opens a new window to print; non-Web: Printing.layoutPdf ──
  Future<Uint8List> buildPdf({
    String orient    = 'P',
    String paper     = 'A4',
    String fontAsset = 'assets/fonts/NotoSansTC-Regular.ttf',
  }) async {
    // The Web platform doesn't support convertHtml; uses _webPrint instead
    if (kIsWeb) {
      await _webPrintBody(buildHtml(), paper, orient);
      return Uint8List(0);
    }
    // Non-Web: could hook up the pw package in the future
    return Uint8List(0);
  }

  // ── _webPrintBody() — wraps the HTML and opens a new window to print ───────────
  Future<void> _webPrintBody(String body, String paper, String orient) async {
    // @@@ This used to check orient == 'L' without expanding $(), so
    //     WML's "landscape" / "$(PL)" never matched → always portrait.
    //     Now goes through the shared pageSizeOf instead.
    final size = pageSizeOf(paper, orient);
    final html = _fullHtml(body, size);
    openHtmlForPrint(html);
  }

  String _fullHtml(String body, [String pageSize = 'A4 portrait']) => '''<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>
${reportCssPrint(pageSize)}
</style></head><body>$body
<script>window.onload=function(){window.print();}</script>
</body></html>''';

  // ── Internal methods (unchanged from the original) ──────────────────────────
  bool _invalid() {
    if (wap.wapLpp <= 0)            { emit('[WapForm] wapLpp not set');        return true; }
    if (wap.wapGroups <= 0)         { emit('[WapForm] wapGroups not set');      return true; }
    if (wap.wapGroups > kMaxGroups) { emit('[WapForm] wapGroups exceeds max'); return true; }
    return false;
  }

  void _cacheInit() {
    for (int i = 0; i < wap.wapGroups; i++) {
      wap.wapRow[i].prefixTxt = '';
      wap.wapRow[i].suffixTxt = expression(i);
    }
  }

  void _checkHdrs() {
    wap.wapChgFound = false;
    for (int i = 0; i < wap.wapGroups; i++) {
      wap.wapRow[i].prefixChk = false;
      final val = expression(i);
      if (wap.wapChgFound || val != wap.wapRow[i].prefixTxt) {
        wap.wapChgFound         = true;
        wap.wapRow[i].str       = wap.wapRow[i].prefixTxt;
        wap.wapRow[i].prefixChk = true;
        wap.wapRow[i].prefixTxt = val;
      }
    }
  }

  bool _checkFtrs() {
    wap.wapChgFound = false;
    for (int i = 0; i < wap.wapGroups; i++) {
      wap.wapRow[i].suffixChk = false;
      final val = expression(i);
      if (wap.wapChgFound || val != wap.wapRow[i].suffixTxt) {
        wap.wapChgFound         = true;
        wap.wapRow[i].str       = wap.wapRow[i].suffixTxt;
        wap.wapRow[i].suffixChk = true;
        wap.wapRow[i].suffixTxt = val;
      }
    }
    return wap.wapChgFound;
  }

  void _flushLastFtrs() {
    for (int i = wap.wapGroups - 1; i >= 0; i--) {
      wap.wapRow[i].suffixChk = !wap.wapRow[i].suffixChk;
    }
  }

  void _emitHdrs() {
    for (int i = 0; i < wap.wapGroups; i++) {
      if (wap.wapRow[i].prefixChk) {
        wap.wapEnable  = true;
        wap.wapBlockId = wap.wapRow[i].tagPrefix;
        parseBlock(wap.wapRow[i].tagPrefix);
      }
    }
  }

  void _emitFtrs() {
    for (int i = wap.wapGroups - 1; i >= 0; i--) {
      if (wap.wapRow[i].suffixChk) {
        wap.wapEnable  = false;
        wap.wapBlockId = wap.wapRow[i].tagSuffix;
        parseBlock(wap.wapRow[i].tagSuffix);
      }
    }
  }

  void _newPageStart() {
    wap.wapPageNo++;
    wap.wapLineNo  = 0;
    _hadRecordThisPage = false; // @@@ reset on a new page
    wap.wapBlockId = 'PAGEPREFIX';
    parseBlock('PAGEPREFIX');
  }

  bool _hadRecordThisPage = false; // @@@ whether a RECORD has been printed on this page yet (avoids a blank leading page)

  // @@@ Forces a page break (for a <page> or <newpage> inside a group —
  //     e.g. "one page per customer"). Doesn't break if already at the
  //     top of a page (wapLineNo==0), to avoid producing a blank page.
  //     Closes out the current page → breaks → reprints the page header.
  void forcePageBreak() {
    if (_hadRecordThisPage) {
      _newPageEnd();
      wap.wapBlockId = 'PAGEBREAK';
      parseBlock('PAGEBREAK');
      _newPageStart();
    }
  }

  void _newPageEnd() {
    wap.wapBlockId = 'PAGESUFFIX';
    parseBlock('PAGESUFFIX');
  }

// aa ### flutter extension
  /// Prints a single line —— regardless of whether it comes from the main
  /// report, or from a sub-report at any nesting level (device="sub").
  ///
  /// A WML sub-report "rides along with" the main report: it has no
  /// output device of its own, and its rows are merged directly into the
  /// main report's page flow. So every row must go through this single
  /// exit point, which handles everything uniformly:
  ///   1. If the current page is full (wapLineNo >= wapLpp) → close the
  ///      page, break, and reprint the page header and column headers
  ///   2. Increment the line count
  ///   3. Emit this row
  ///
  /// This way, no matter how many levels of sub-reports are nested,
  /// pagination stays correct — every level just calls emitRow() and
  /// never has to manage wapLineNo or page breaks itself.
  ///
  /// Note: a page break can land in the middle of a sub-report (a single
  ///     main record's sub-report can get split across two pages). This
  ///     is the price of "exact lines per page", and is also the default
  ///     behavior of most reporting tools.
  void emitRow(String html, {bool isHeader = false, bool isFooter = false}) {
    if (wap.wapLineNo >= wap.wapLpp) {
      _newPageEnd();
      wap.wapBlockId = 'PAGEBREAK';
      parseBlock('PAGEBREAK');
      _newPageStart(); // includes wapLineNo = 0 + reprinting the page header/column headers
    }
    wap.wapLineNo++;
    emit(html, isHeader: isHeader, isFooter: isFooter);
  }
// zz ### flutter extension
}

// ════════════════════════════════════════════════════════════
//  _SrcReport — a minimal shell for the demo card's PDF
// ════════════════════════════════════════════════════════════
class _SrcReport extends WapReport {
  final String _src;
  _SrcReport(this._src);

  @override void initParams() {
    wap.wapLpp    = 9999;
    wap.wapGroups = 1;
    wap.wapRow[0].tagPrefix = 'G1_PREFIX';
    wap.wapRow[0].tagSuffix = 'G1_SUFFIX';
  }
  @override String       expression(int i)  => '';
  @override Future<bool> fetchFirst() async => true;
  @override Future<bool> fetchNext()  async => false;
  @override Future<void> fetchPrior() async {}
  @override void parseBlock(String id) {
    if (id != 'PREFIX') return;
    wap.wapLineNo++;
    emit(expandText(_src));
  }
}

// ════════════════════════════════════════════════════════════
//  Normalizing paper size and orientation
// aa ??? issue
//  Two independent defects stacked together, causing WML's horizontal
//  setting to always print as portrait:
//
//  1. orient's value could be an expression. WML writes
//     orientation="$(PL)" (agp007 lets the user pick portrait/landscape
//     from a dropdown), and the generator leaves the $ as-is, passing a
//     raw string through to runtime — but this code never called
//     expandText() → it got the literal "$(PL)".
//  2. Even after expanding it, the comparison still didn't match. The
//     original check was orient == 'L', while WML's
//     <option value="landscape"> gives "landscape" → always false,
//     always fell through to portrait — including @page size, so even
//     printing came out portrait.
//
//  Handled uniformly here: expandText first, then map various spellings
//  (L / landscape / 橫 / 水平 / 1) to the same result. Same for paper
//  (which might be written as $(...) or in inconsistent casing).
// zz ??? issue
// ════════════════════════════════════════════════════════════

/// Expands $(expression) and trims surrounding whitespace; returns as-is if there's no $.
String _expandAttr(String v) {
  if (!v.contains(r'$')) return v.trim();
  try {
    return expandText(v).trim();
  } catch (_) {
    return v.trim(); // fall back to the original string if the expression fails to evaluate, rather than crashing the whole report
  }
}

/// Whether this is landscape. Accepts L / landscape / 橫 / 水平 / 1 (case-insensitive).
bool isLandscape(String orient) {
  final o = _expandAttr(orient).toLowerCase();
  if (o.isEmpty) return false;
  return o == 'l' ||
      o == '1' ||
      o.startsWith('landscape') ||
      o.contains('橫') ||
      o.contains('水平');
}

/// Normalizes the paper name, returning the string used for CSS @page size (A4 / letter / B5 …).
/// Returns A4 for an empty or unrecognized value, consistent with upstream WapPage's default.
String normalizePaper(String paper) {
  final p = _expandAttr(paper).toLowerCase();
  if (p.isEmpty) return 'A4';
  if (p.startsWith('letter')) return 'letter';
  if (p.startsWith('legal')) return 'legal';
  if (p.startsWith('a3')) return 'A3';
  if (p.startsWith('a5')) return 'A5';
  if (p.startsWith('b5')) return 'B5';
  if (p.startsWith('a4')) return 'A4';
  return 'A4';
}

/// Builds the value for CSS @page's size, e.g. "letter landscape".
String pageSizeOf(String paper, String orient) =>
    '${normalizePaper(paper)} ${isLandscape(orient) ? 'landscape' : 'portrait'}';

// aa ### flutter extension
/// The paper content width (px) for the on-screen preview.
///
/// Conversion basis: CSS's 96dpi (1in = 96px = 25.4mm), minus 44px total
/// for the left/right margins.
/// A4 portrait comes out to exactly 750 —— the same as flutter.pas's
/// original hardcoded PaperW constant, which confirms in reverse that
/// that 750 was "A4 portrait minus margins", so this formula is
/// compatible with the existing layout.
///
/// With this, WML no longer needs to "stretch" the layout with a long
/// string, nor does each page need its own <table width=>: the width is
/// determined by the paper size and orientation, and the screen updates
/// automatically when orientation changes.
double paperWidthPx(String paper, String orient) {
  const mmPerPx = 96.0 / 25.4;
  const margin = 44.0; // left + right margins combined
  // short/long side of each paper size (mm)
  const sizes = <String, List<double>>{
    'A3': [297, 420],
    'A4': [210, 297],
    'A5': [148, 210],
    'B5': [176, 250],
    'letter': [215.9, 279.4],
    'legal': [215.9, 355.6],
  };
  final wh = sizes[normalizePaper(paper)] ?? sizes['A4']!;
  final mm = isLandscape(orient) ? wh[1] : wh[0];
  final px = mm * mmPerPx - margin;
  return px < 200 ? 200 : px; // lower-bound safety net
}
// zz ### flutter extension

// ════════════════════════════════════════════════════════════
//  WapPage — generic display layer for a WML card
// ════════════════════════════════════════════════════════════
class WapPage extends StatefulWidget {
  final String      title;
  final String?     src;
  final WapReport?  report;
  final String      paper;
  final String      orient;
  final String      fontAsset;
  final bool        showPrint;
  final EdgeInsets  padding;
  final Map<String, Style>? htmlStyle;

  const WapPage({
    super.key,
    required this.title,
    this.src,
    this.report,
    this.paper      = 'A4',
    this.orient     = 'P',
    this.fontAsset  = 'assets/fonts/NotoSansTC-Regular.ttf',
    this.showPrint  = true,
    this.padding    = const EdgeInsets.all(16),
    this.htmlStyle,
  }) : assert(src != null || report != null,
              'WapPage: exactly one of src or report must be provided');

  @override
  State<WapPage> createState() => _WapPageState();
}

class _WapPageState extends State<WapPage> {
  String  _html    = '';
  bool    _loading = true;
  String? _error;

  static final Map<String, Style> _defaultStyle = {
    'pre':   Style(fontFamily: 'monospace', fontSize: FontSize(13),
                   whiteSpace: WhiteSpace.pre, color: const Color(0xFF222222)),
    'b':     Style(color: const Color(0xFF1A6FB5)),
    'td':    Style(fontSize: FontSize(12)),
    'th':    Style(fontSize: FontSize(12), fontWeight: FontWeight.bold),
    'p':     Style(fontSize: FontSize(13)),
    'label': Style(fontSize: FontSize(13)),
    'big':   Style(fontSize: FontSize(16), fontWeight: FontWeight.bold),
  };

  @override
  void initState() {
    super.initState();
    _build();
  }

  Future<void> _build() async {
    try {
      String html;
      if (widget.src != null) {
        html = expandText(widget.src!);
      } else {
        await widget.report!.run();
        html = widget.report!.buildHtml();
      }
      if (mounted) setState(() { _html = html; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // Reports are injected as complete HTML via an iframe (avoids
  // flutter_html's cross-fragment concatenation issues)
  Widget _buildIframe(String body) {
    if (!kIsWeb) {
      return SingleChildScrollView(
        padding: widget.padding,
        child: Html(
          data: body,
          extensions: [TableHtmlExtension()], // @@@ table rendering (not const)
          style: {..._defaultStyle, ...?widget.htmlStyle},
        ),
      );
    }
    final html = '''<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>
${reportCssScreen(paperWidthPx(widget.paper, widget.orient))}
</style></head><body>$body</body></html>''';

    // buildHtmlIframe() only returns non-null on Flutter Web (kIsWeb was
    // already checked above, so this should always succeed here).
    return buildHtmlIframe(html) ??
        SingleChildScrollView(
          padding: widget.padding,
          child: Html(
            data: body,
            extensions: [TableHtmlExtension()],
            style: {..._defaultStyle, ...?widget.htmlStyle},
          ),
        );
  }

  Future<void> _print() async {
    final body = widget.report != null
        ? widget.report!.buildHtml()
        : _html;
    if (kIsWeb) {
      // @@@ Same as above: expand $() and accept spellings like landscape
      final size = pageSizeOf(widget.paper, widget.orient);
      final html = widget.report != null
          ? widget.report!._fullHtml(body, size)
          : _fullHtmlSrc(body, size);
      openHtmlForPrint(html);
      return;
    }
    await Printing.layoutPdf(onLayout: (_) async => Uint8List(0));
  }

  // The HTML wrapper used for printing the demo card
  String _fullHtmlSrc(String body, String pageSize) => '''<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>
${reportCssSrc(pageSize)}
</style></head><body>$body
<script>window.onload=function(){window.print();}</script>
</body></html>''';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      actions: [
        if (widget.showPrint && !_loading && _error == null)
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print / Save as PDF',
            onPressed: _print,
          ),
      ],
    ),
    body: _buildBody(),
  );

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text('Error:\n$_error',
          style: const TextStyle(color: Colors.red, fontSize: 13)),
    ));
    // Report cards: rendered via iframe (avoids cross-fragment HTML concatenation issues)
    if (widget.report != null) {
      return _buildIframe(_html);
    }
    // Demo cards: flutter_html (structure is complete, renders normally)
    return SingleChildScrollView(
      padding: widget.padding,
      child: Html(
        data: _html,
        extensions: [TableHtmlExtension()], // @@@ table rendering (not const)
        style: {..._defaultStyle, ...?widget.htmlStyle},
      ),
    );
  }
}
