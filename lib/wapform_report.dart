// ═════════════════════════════════════════════════════════════════════════════
//  wapform_report.dart
//  WML banded report engine —— corresponds to WML's <report> / <page> / <group>
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
// File history (this file's own internal edit log — unrelated to the
// package version in pubspec.yaml):
//   2026-05-23  rev1  Initial release
//   2026-05-26  rev2  run() now fully corresponds to Delphi TCard._report's main loop
//   2026-05-26  rev3  _checkFtrs() now returns bool
//   2026-05-26  rev4  flushBuf row1 forced to white
//   2026-05-26  rev5  Full comments added, frozen
//   2026-06-06  rev6  Switched entirely to HTML output:
//                     - removed the pw/pdf packages
//                     - buildPdf() now uses Printing.convertHtml() + a base64 font
//                     - buildHtml() added, generates HTML using isHeader/isFooter/tag
//                     - the WapLine/emit()/columns interface fully preserved (backward compatible)
//                     - WapPage generic display layer integrated
//   2026-08-21  rev7  buildPdf() switched from Printing.convertHtml() (which
//                     hangs indefinitely on some real devices — a known
//                     upstream bug, dart_pdf#1517) to a native WebView +
//                     PrintDocumentAdapter pipeline (flutter_native_html_to_pdf),
//                     verified against real Android hardware. Also switched
//                     print output to reuse the same CSS as the on-screen
//                     preview (reportCssScreen), instead of a separate
//                     reportCssPrint-based layout that was wrapping fields.

import 'dart:convert'; // base64Encode (used by wapFontFaceCss)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
// aa ### flutter extension
// flutter_html 3.x's <table> needs this extension to render as a real
// table; without it, <tr>/<td> get stacked as ordinary blocks (the
// report's layout falls apart).
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:webview_flutter/webview_flutter.dart';
// zz ### flutter extension
import 'package:pdf/pdf.dart'; // @@@ PdfPageFormat
// @@@ 2026-08-21 switched to native WebView + PrintDocumentAdapter for
//     PDF generation. This package's approach is "lay the HTML out with
//     Android WebView / iOS WKWebView, then write a vector PDF via
//     createPrintDocumentAdapter()" -- an independent implementation from
//     the printing package's convertHtml, so it doesn't hit the bug where
//     that one hangs forever on some devices; and because layout is done
//     by a real browser engine, our reports' <table>s and CSS render
//     exactly as written.
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
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
  bool prefixChk = false;
  bool suffixChk = false;
  String str = '';
  String prefixTxt = '';
  String suffixTxt = '';
  String tagPrefix = '';
  String tagSuffix = '';
}

// ════════════════════════════════════════════════════════════
//  WapStorage
// ════════════════════════════════════════════════════════════
class WapStorage {
  int wapIdx = 0;
  int wapGroups = 0;
  bool wapChgFound = false;
  String wapExpVal = '';
  int wapLpp = 60;
  int wapLineNo = 0;
  int wapPageNo = 0;
  bool wapHasMore = false;
  bool wapEnable = true;
  String wapBlockId = '';

  final List<WapGroupRow> wapRow =
      List.generate(kMaxGroups, (_) => WapGroupRow());
}

// ════════════════════════════════════════════════════════════
//  WapLine — the original interface fully preserved
// ════════════════════════════════════════════════════════════
class WapLine {
  final String blockId;
  final String text; // an HTML string, or tab-separated columns
  final int pageNo;
  final int lineNo;
  final bool isHeader;
  final bool isFooter;
  final String tag; // CSS class (e.g. 'row1'/'row2')

  const WapLine({
    required this.blockId,
    required this.text,
    required this.pageNo,
    required this.lineNo,
    this.isHeader = false,
    this.isFooter = false,
    this.tag = '',
  });
}

// ════════════════════════════════════════════════════════════
//  WapReport — abstract base class
// ════════════════════════════════════════════════════════════
abstract class WapReport {
  final WapStorage wap = WapStorage();
  final List<WapLine> lines = [];

  void initParams();
  String expression(int idx);
  Future<bool> fetchFirst();
  Future<bool> fetchNext();
  Future<void> fetchPrior();
  void parseBlock(String blockId);
  // @@@ Async preparation for a group break (opens the <dbquery> used for
  //     group aggregation). parseBlock is synchronous and can't await, so
  //     anything that needs an async <dbquery>.openAsync() is opened here
  //     ahead of time instead. No-op by default; report generators with
  //     group queries override this.
  Future<void> onGroupPrepare() async {}

  // ── emit() — original interface fully preserved ──────────────────────
  void emit(
    String text, {
    bool isHeader = false,
    bool isFooter = false,
    String tag = '',
  }) {
    lines.add(WapLine(
      blockId: wap.wapBlockId,
      text: text,
      pageNo: wap.wapPageNo,
      lineNo: wap.wapLineNo,
      isHeader: isHeader,
      isFooter: isFooter,
      tag: tag,
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
    wap.wapEnable = true;
    parseBlock('PREFIX');

    _newPageStart();

    while (wap.wapHasMore) {
      _checkHdrs();
      if (wap.wapChgFound) {
        await onGroupPrepare(); // @@@ On a group break, first (async) open the <dbquery> the group needs
        _emitHdrs();
      }

      wap.wapBlockId = 'RECORD';
      wap.wapEnable = true;
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
    wap.wapEnable = false;
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
          final w = columns[ci].$1 != null
              ? ' width="${columns[ci].$1!.toInt()}"'
              : '';
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
    if (l.isHeader) return WapColors.hexTrRow;
    if (l.tag.isNotEmpty) return WapColors.hex(l.tag);
    return 'transparent';
  }

  // ── buildPdf() — Web: opens a new window to print; non-Web: Printing.convertHtml() ──
  //
  // aa ??? issue (historical -- superseded by rev7 below, kept for context)
  //  This used to call Printing.convertHtml() to produce a real PDF (see
  //  the file history above, rev6: "buildPdf() now uses
  //  Printing.convertHtml() + a base64 font"), but at some point the
  //  implementation got short-circuited to always return Uint8List(0)
  //  (empty content) -- on Android/desktop, pressing print brings up the
  //  system print/share dialog fine, but the resulting document is blank.
  //  This wired the originally-designed path back in.
  //
  //  Chinese fonts must be embedded: a PDF viewer won't automatically read
  //  system fonts, and the browser rendering engine (which is exactly what
  //  Printing.convertHtml() uses under the hood) can't see an @font-face
  //  it doesn't have, so it falls back to a default font and Chinese
  //  renders as tofu boxes or missing glyphs. The fix: read the font file
  //  as bytes, base64-encode it, and embed it via a data URI in the CSS
  //  @font-face.
  //
  //  Warning: Printing.convertHtml()'s exact parameter names/return type
  //  may vary by printing package version -- there's no pub.dev access
  //  here to check the currently locked version, so this was written
  //  against that package's long-stable public API (the two named
  //  parameters html/format).
  // zz ??? issue
  /// @@@ 2026-08-21 How PDFs are generated: native WebView +
  /// PrintDocumentAdapter.
  ///
  ///   Dead ends tried along the way, kept here so nobody circles back to
  ///   them later:
  ///   1. Printing.layoutPdf() -- brings up Android's native print
  ///      preview, which depends on the system's Print Spooler service.
  ///      This device doesn't have that service, so it hangs forever on
  ///      "preparing preview" -- our own code never even gets called.
  ///   2. Printing.convertHtml() -- a known bug in the printing package
  ///      (github.com/DavBfr/dart_pdf/issues/1517): on some devices, the
  ///      call neither returns nor throws -- it just hangs. Tested
  ///      shrinking the HTML from 9.48 million characters down to 9,853
  ///      characters and it still hung, so it isn't a content-size issue.
  ///   3. htmltopdfwidgets's HTMLToPdf() -- pure-Dart parsing, doesn't
  ///      hang, but it doesn't handle <table>: a 6,097-character detail
  ///      table's HTML only parsed into 2 blocks -- the table effectively
  ///      disappeared, and it also blew past MultiPage's page-count limit.
  ///
  ///   The current approach: hand the HTML to the system's native WebView
  ///   to lay out, then write a vector PDF (selectable text, scales
  ///   without quality loss) via createPrintDocumentAdapter(). An
  ///   independent implementation from (2), so it doesn't share the code
  ///   path that hangs; unlike (3), layout is handled by a real browser
  ///   engine, so <table>s and CSS render exactly as written. Chinese
  ///   fonts don't need to be embedded -- the WebView can see the
  ///   system's built-in Noto Sans CJK.
  Future<Uint8List> buildPdf({
    String orient = 'P',
    String paper = 'A4',
    String fontAsset = 'assets/fonts/NotoSansTC-Regular.ttf',
  }) async {
    // The Web platform doesn't support this path; uses _webPrint instead
    if (kIsWeb) {
      await _webPrintBody(buildHtml(), paper, orient);
      return Uint8List(0);
    }
    debugPrint('[buildPdf] starting (native WebView + PrintDocumentAdapter)');
    // @@@ 2026-08-21 PDF now reuses exactly the same CSS as the on-screen
    // preview.
    //
    //   PDF used to go through reportCssPrint(), a separate stylesheet
    //   from the on-screen preview's reportCssScreen(), which resulted in
    //   fields wrapping heavily. Tried shrinking the font size and
    //   locking a 760px canvas with proportional scaling (printFitCss) to
    //   fix it -- both were guesses at "what actually fits."
    //
    //   Testing then found: a phone in portrait's WebView preview width
    //   is about 720px, nearly identical to A4 portrait's printable width
    //   (718px), and it laid out with zero wrapping, ruler line intact.
    //   Which means the width was never the problem -- the two sides just
    //   had different CSS. No more guessing needed: just reuse the
    //   stylesheet already proven to lay out correctly.
    //
    //   reportCssScreen carries screen-only decoration (gray background,
    //   shadow, inter-page gaps); @media print strips that out for
    //   printing, with the layout/font size/column widths left untouched.
    final html = _fullHtmlLikeScreen(buildHtml(), paper, orient);
    debugPrint('[buildPdf] step 1/2 HTML assembled (${html.length} chars '
        'total, reusing the on-screen preview CSS, print font size derived '
        'from the $kRulerChars-character ruler line), handing off to the '
        'native WebView for PDF conversion...');
    final result = await HtmlToPdfConverter().convertHtmlToPdfBytes(html: html);
    debugPrint(
        '[buildPdf] step 2/2 PDF generation complete (${result.length} bytes)');
    return result;
  }

  /// A version identical to the HTML WapPage's on-screen preview
  /// (_buildIframe) produces, with one extra @media print block that
  /// strips the screen-only decoration.
  String _fullHtmlLikeScreen(String body, String paper, String orient) =>
      '''<!DOCTYPE html>
<html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
${reportCssScreen(paperWidthPx(paper, orient))}
${printChromeResetCss(pageSizeOf(paper, orient), paper, orient)}
</style></head><body>$body</body></html>''';

  // ── _webPrintBody() — wraps the HTML and opens a new window to print ───────────
  Future<void> _webPrintBody(String body, String paper, String orient) async {
    // @@@ This used to check orient == 'L' without expanding $(), so
    //     WML's "landscape" / "$(PL)" never matched → always portrait.
    //     Now goes through the shared pageSizeOf instead.
    final size = pageSizeOf(paper, orient);
    final html = _fullHtml(body, size);
    openHtmlForPrint(html);
  }

  // @@@ 2026-08-21 Print scaling: now computed on the Dart side and baked
  // into the CSS as a fixed ratio.
  //
  //   The problem: reports use a 120-character ruler line
  //   (<p>1234567890...</p>) to pin the layout width to a fixed character
  //   grid (carried over from the desktop version's 80/132-column report
  //   paper design). That digit string has no spaces and can't wrap, so
  //   it forces the container wide. Fine in a browser -- content wider
  //   than the viewport just gets a horizontal scrollbar -- but a PDF's
  //   paper width is physically fixed, and whatever overflows just gets
  //   cut off (tested: A4 portrait only fit 95 characters, and the two
  //   right-hand address columns disappeared entirely). Removing the
  //   ruler line doesn't work either: fields get squeezed into heavy
  //   wrapping and end up crammed together.
  //
  //   The fix (printFitCss(), see the note above that function): fix the
  //   canvas to the same 760px as the desktop version, then scale the
  //   whole thing proportionally down to whatever width the paper can
  //   fit. The scale ratio is computed on the Dart side, so there's no
  //   need to wait on the WebView to run JS to measure it -- which would
  //   mean gambling on whether the converter waits for the JS to finish.

  String _fullHtml(
    String body, [
    String pageSize = 'A4 portrait',
    // @@@ extraCss: spliced into <style> (currently used for buildPdf()'s
    //     embedded-font @font-face). includePrintScript: window.print() is
    //     for the Web new-tab print path -- the PDF path needs it off.
    String extraCss = '',
    bool includePrintScript = true,
  ]) =>
      '''<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>
${reportCssPrint(pageSize)}
$extraCss
</style></head><body>$body
${includePrintScript ? '<script>window.onload=function(){window.print();}</script>' : ''}
</body></html>''';

  // ── Internal methods (unchanged from the original) ──────────────────────────
  bool _invalid() {
    if (wap.wapLpp <= 0) {
      emit('[WapForm] wapLpp not set');
      return true;
    }
    if (wap.wapGroups <= 0) {
      emit('[WapForm] wapGroups not set');
      return true;
    }
    if (wap.wapGroups > kMaxGroups) {
      emit('[WapForm] wapGroups exceeds max');
      return true;
    }
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
        wap.wapChgFound = true;
        wap.wapRow[i].str = wap.wapRow[i].prefixTxt;
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
        wap.wapChgFound = true;
        wap.wapRow[i].str = wap.wapRow[i].suffixTxt;
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
        wap.wapEnable = true;
        wap.wapBlockId = wap.wapRow[i].tagPrefix;
        parseBlock(wap.wapRow[i].tagPrefix);
      }
    }
  }

  void _emitFtrs() {
    for (int i = wap.wapGroups - 1; i >= 0; i--) {
      if (wap.wapRow[i].suffixChk) {
        wap.wapEnable = false;
        wap.wapBlockId = wap.wapRow[i].tagSuffix;
        parseBlock(wap.wapRow[i].tagSuffix);
      }
    }
  }

  void _newPageStart() {
    wap.wapPageNo++;
    wap.wapLineNo = 0;
    _hadRecordThisPage = false; // @@@ reset on a new page
    wap.wapBlockId = 'PAGEPREFIX';
    parseBlock('PAGEPREFIX');
  }

  bool _hadRecordThisPage =
      false; // @@@ whether a RECORD has been printed on this page yet (avoids a blank leading page)

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

  @override
  void initParams() {
    wap.wapLpp = 9999;
    wap.wapGroups = 1;
    wap.wapRow[0].tagPrefix = 'G1_PREFIX';
    wap.wapRow[0].tagSuffix = 'G1_SUFFIX';
  }

  @override
  String expression(int i) => '';
  @override
  Future<bool> fetchFirst() async => true;
  @override
  Future<bool> fetchNext() async => false;
  @override
  Future<void> fetchPrior() async {}
  @override
  void parseBlock(String id) {
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
    return v
        .trim(); // fall back to the original string if the expression fails to evaluate, rather than crashing the whole report
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

// aa ### flutter extension
/// @@@ 2026-08-10 added: custom paper size, format "WIDTHxHEIGHT" (inches),
/// e.g. the 8.5x5.5 pre-printed continuous-form paper common in Taiwan.
/// Shares the same detection logic as named sizes (letter/A4...) -- all
/// three call sites (screen width, CSS @page, PdfPageFormat) call this, so
/// they never disagree. Returns null when it isn't a custom format,
/// leaving normalizePaper to handle the named-size path.
(double, double)? customPaperSizeInches(String paper) {
  final p = _expandAttr(paper).trim().toLowerCase();
  final m = RegExp(r'^(\d+(?:\.\d+)?)\s*x\s*(\d+(?:\.\d+)?)$').firstMatch(p);
  if (m == null) return null;
  final w = double.tryParse(m.group(1)!);
  final h = double.tryParse(m.group(2)!);
  if (w == null || h == null || w <= 0 || h <= 0) return null;
  return (w, h);
}
// zz ### flutter extension

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
/// @@@ 2026-08-10 fix: a custom size (e.g. "8.5x5.5") now uses its inch
/// value directly as the CSS size, instead of always falling back to A4.
String pageSizeOf(String paper, String orient) {
  final custom = customPaperSizeInches(paper);
  if (custom != null) {
    final (w, h) = custom;
    final (pw, ph) = isLandscape(orient) ? (h, w) : (w, h);
    return '${pw}in ${ph}in ${isLandscape(orient) ? 'landscape' : 'portrait'}';
  }
  return '${normalizePaper(paper)} ${isLandscape(orient) ? 'landscape' : 'portrait'}';
}

// aa ??? issue
//  Two pieces of shared logic PDF generation needs are pulled out as
//  top-level functions instead of living on WapReport -- WapPage's
//  _print() (when a demo card has no WapReport object) needs the same
//  logic too, and hanging it on the class would force that other path to
//  duplicate it, letting the two copies drift apart over time.
// zz ??? issue

/// Reads the font file, base64-encodes it, and assembles an embeddable
/// @font-face CSS block. Chinese fonts must be embedded: this used to
/// matter because Printing.convertHtml()'s underlying engine was an
/// offline renderer that couldn't see system-installed fonts, so without
/// @font-face it fell back to a default font and Chinese turned into tofu
/// boxes -- kept here since the native-WebView path (rev7) no longer
/// needs it but nothing currently calls this to remove it. Falls back to
/// an empty string when the font file can't be read -- better to print
/// with the wrong font than to blow up PDF generation entirely.
/// @@@ Cached: the font file (NotoSansTC-Regular.ttf, ~6.8MB) balloons to
///     roughly 9MB once base64-encoded, and re-reading + re-encoding it
///     on every print could take several seconds alone on weaker
///     devices -- and the font file never changes during the app's
///     lifetime, so redoing it every time is wasted work. Computed once
///     per fontAsset, then reused after that.
final Map<String, String> _fontFaceCssCache = {};

Future<String> wapFontFaceCss(String fontAsset) async {
  final cached = _fontFaceCssCache[fontAsset];
  if (cached != null) return cached;
  try {
    final bytes = await rootBundle.load(fontAsset);
    final b64 = base64Encode(bytes.buffer.asUint8List());
    final css = '''
@font-face {
  font-family: "WapReportFont";
  src: url(data:font/ttf;base64,$b64) format("truetype");
}
* { font-family: "WapReportFont", "Microsoft JhengHei", "Noto Sans TC", sans-serif !important; }
''';
    _fontFaceCssCache[fontAsset] = css;
    return css;
  } catch (e) {
    debugPrint(
        '[wapform_report] Font embedding failed, falling back to the system default font: $e');
    return '';
  }
}

/// PdfPageFormat reuses the same normalizePaper/isLandscape detection as
/// the on-screen/HTML print path, so all three (screen width, @page size,
/// PdfPageFormat) never disagree.
/// @@@ 2026-08-10 fix: a custom size (e.g. "8.5x5.5") now builds the
/// PdfPageFormat directly from its inch value.
PdfPageFormat wapPdfPageFormat(String paper, String orient) {
  final custom = customPaperSizeInches(paper);
  if (custom != null) {
    final (w, h) = custom;
    final base = PdfPageFormat(w * PdfPageFormat.inch, h * PdfPageFormat.inch);
    return isLandscape(orient) ? base.landscape : base.portrait;
  }
  final PdfPageFormat base;
  switch (normalizePaper(paper)) {
    case 'letter':
      base = PdfPageFormat.letter;
    case 'legal':
      base = PdfPageFormat.legal;
    case 'A3':
      base = PdfPageFormat.a3;
    case 'A5':
      base = PdfPageFormat.a5;
    default:
      base = PdfPageFormat.a4;
  }
  return isLandscape(orient) ? base.landscape : base.portrait;
}

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
/// Number of characters in the report's ruler line.
///
///   Reports use a numeric ruler line (<p>1234567890...</p>) to define
///   the layout's baseline width -- that digit string has no spaces and
///   can't wrap, so the whole report needs to be at least "this many
///   characters" wide to fit. Currently set to 116 characters in WML.
///   If the WML ruler line's length changes, this needs to change with
///   it.
const int kRulerChars = 116;

/// The ratio of digit-character width to font size.
///
///   Used to derive the print font size from "how many characters the
///   ruler line has." This value **was measured, not guessed**:
///   previously assumed 0.55, and a 116-character ruler line only
///   printed 111 characters (5 got cut off). Worked backward from the
///   actual output -- printable width 718px / 111 printed characters =
///   6.468px per character, divided by the font size in use at the time
///   (11.25px), giving a real ratio of 0.575.
///
///   Using 0.60 here, about 4% more safety margin than the measured
///   value: small font-size variations and font fallback differences
///   across devices can shift character width a little, and it's better
///   to fit slightly fewer characters than to get clipped again. This
///   value needs to be re-measured if the font changes.
const double kRulerCharWidthRatio = 0.60;

/// @@@ 2026-08-21 The print-only "strip screen decoration + scale font to
/// match the ruler line" stylesheet.
///
///   PDF reuses reportCssScreen() (the same one the on-screen preview
///   uses, layout already verified correct), and this adds the two
///   things only printing needs:
///
///   (1) Strip the screen-only decoration: gray background, white-paper
///       shadow, border, inter-page gaps.
///
///   (2) Derive the font size from the ruler line's character count. The
///       on-screen preview's canvas is paperWidthPx() (750px for A4
///       portrait), but after @page margin:10mm the actual printable
///       width is only 718px -- the canvas is wider than the printable
///       area, and at the original 13.3px font size, 116 characters need
///       848px, so the right side gets cut off. This shrinks the font
///       size to "exactly $kRulerChars characters fits the printable
///       width." Also narrows the cell padding (printing doesn't need
///       the screen's click-target padding), buying fields a bit more
///       horizontal room.
///       Capped at 13.3px: when the paper is wide enough (A4 landscape,
///       etc.), the original font size is kept, not enlarged.
String printChromeResetCss(String pageSize, String paper, String orient) {
  const mmPerPx = 96.0 / 25.4;
  const marginMm = 20.0; // @page margin 10mm on each side (left + right)
  final printablePx = paperMm(paper, orient) * mmPerPx - marginMm * mmPerPx;
  final usable = printablePx < paperWidthPx(paper, orient)
      ? printablePx
      : paperWidthPx(paper, orient);
  var f = usable / (kRulerChars * kRulerCharWidthRatio);
  if (f > 13.3) f = 13.3;
  final fs = f.toStringAsFixed(2);
  return '''
/* aa @@@ Print: strip screen-only decoration + scale font to match the ruler line ($kRulerChars characters) */
@page { size: $pageSize; margin: 10mm; }
@media print {
  body {
    background: #ffffff;   /* don't print the screen's gray backdrop */
    padding: 0;
  }
  body > table {
    box-shadow: none;      /* paper shadow */
    border: none;
    margin: 0 auto;        /* inter-page gap */
    width: ${usable.toStringAsFixed(0)}px !important;
  }
  body, p, td, th { font-size: ${fs}px; line-height: 1.25; }
  big { font-size: ${(f * 1.35).toStringAsFixed(2)}px; }
  /* printing doesn't need the screen's click-target padding; narrowed for more horizontal room */
  td, th { padding: 1px 3px; }
  /* meaningful background colors (header gray, zebra stripes) must be kept -- browsers filter these out of print by default */
  * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
  /* don't let a row split across two pages */
  tr, td, th { page-break-inside: avoid; }
}
/* zz @@@ */
''';
}

/// Paper width (mm), taking the short or long edge depending on
/// orientation. Shared by paperWidthPx/printChromeResetCss.
double paperMm(String paper, String orient) {
  final custom = customPaperSizeInches(paper);
  if (custom != null) {
    final (w, h) = custom;
    final (pw, _) = isLandscape(orient) ? (h, w) : (w, h);
    return pw * 25.4;
  }
  const sizes = <String, List<double>>{
    'A3': [297, 420],
    'A4': [210, 297],
    'A5': [148, 210],
    'B5': [176, 250],
    'letter': [215.9, 279.4],
    'legal': [215.9, 355.6],
  };
  final wh = sizes[normalizePaper(paper)] ?? sizes['A4']!;
  return isLandscape(orient) ? wh[1] : wh[0];
}

double paperWidthPx(String paper, String orient) {
  const mmPerPx = 96.0 / 25.4;
  const margin = 44.0; // left + right margins combined
  // @@@ the paper-size table is now provided uniformly by paperMm() --
  //     don't copy another one here. Maintaining two separate tables
  //     means one eventually gets updated and the other forgotten.
  final px = paperMm(paper, orient) * mmPerPx - margin;
  return px < 200 ? 200 : px; // lower-bound safety net
}

// zz ### flutter extension

// ════════════════════════════════════════════════════════════
//  WapPage — generic display layer for a WML card
// ════════════════════════════════════════════════════════════
class WapPage extends StatefulWidget {
  final String title;
  final String? src;
  final WapReport? report;
  final String paper;
  final String orient;
  final String fontAsset;
  final bool showPrint;
  final EdgeInsets padding;
  final Map<String, Style>? htmlStyle;

  const WapPage({
    super.key,
    required this.title,
    this.src,
    this.report,
    this.paper = 'A4',
    this.orient = 'P',
    this.fontAsset = 'assets/fonts/NotoSansTC-Regular.ttf',
    this.showPrint = true,
    this.padding = const EdgeInsets.all(16),
    this.htmlStyle,
  }) : assert(src != null || report != null,
            'WapPage: exactly one of src or report must be provided');

  @override
  State<WapPage> createState() => _WapPageState();
}

class _WapPageState extends State<WapPage> {
  String _html = '';
  bool _loading = true;
  String? _error;

  static final Map<String, Style> _defaultStyle = {
    'pre': Style(
        fontFamily: 'monospace',
        fontSize: FontSize(13),
        whiteSpace: WhiteSpace.pre,
        color: const Color(0xFF222222)),
    'b': Style(color: const Color(0xFF1A6FB5)),
    'td': Style(fontSize: FontSize(12)),
    'th': Style(fontSize: FontSize(12), fontWeight: FontWeight.bold),
    'p': Style(fontSize: FontSize(13)),
    'label': Style(fontSize: FontSize(13)),
    'big': Style(fontSize: FontSize(16), fontWeight: FontWeight.bold),
  };

  @override
  void initState() {
    super.initState();
    // @@@ 2026-08-10 fix: _build() (and therefore report.run()) used to
    // fire from initState() synchronously (unawaited). If run() has no
    // genuine internal await point of its own — as with a manually
    // scripted report card whose <invoke> calls are all synchronous —
    // its entire body, including enableControls() at the end, executes
    // within the same synchronous call stack as initState(), which
    // Flutter still considers "during build". enableControls() re-
    // enabling a Foreign (registry-shared) dataset fires a catch-up
    // notification to whatever's still bound to it elsewhere (e.g. a
    // sibling card's still-mounted TDBGrid) — entirely correct behavior
    // on its own, but landing mid-build here triggers "setState() or
    // markNeedsBuild() called during build". Deferring the whole _build()
    // call to after the current frame settles (postFrameCallback) means
    // by the time run() actually executes, building has finished and
    // setState() elsewhere is safe again.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _build();
    });
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
      if (mounted)
        setState(() {
          _html = html;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  // Reports are injected as complete HTML via an iframe (Web) or a real
  // WebView (native) (avoids packages like flutter_html/flutter_html_table
  // that re-implement their own layout -- mobile/tablet uses the system's
  // native WebView instead (the Chrome engine, on Android), so CSS layout
  // is rendered by a real browser, looks the same as the Web build, and
  // doesn't hit flutter_html_table's known dry-layout crash.)
  WebViewController? _webCtl;
  String? _webCtlLoadedHtml;

  Widget _buildIframe(String body) {
    final html = '''<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>
${reportCssScreen(paperWidthPx(widget.paper, widget.orient))}
</style></head><body>$body</body></html>''';

    if (!kIsWeb) {
      // @@@ the controller must be reused, not re-created with `new` on
      //     every build() -- otherwise every rebuild reloads the whole
      //     page and flickers. _webCtlLoadedHtml remembers what was last
      //     loaded, and loadHtmlString() is only called when the content
      //     actually changed.
      _webCtl ??= WebViewController()
        ..setJavaScriptMode(JavaScriptMode.disabled)
        ..setBackgroundColor(const Color(0x00000000));
      if (_webCtlLoadedHtml != html) {
        _webCtlLoadedHtml = html;
        _webCtl!.loadHtmlString(html);
      }
      return WebViewWidget(controller: _webCtl!);
    }

    // buildHtmlIframe() only returns non-null on Flutter Web (kIsWeb was
    // already checked above, so this should always succeed here).
    return buildHtmlIframe(html) ??
        SingleChildScrollView(
          padding: widget.padding,
          child: Html(
            data: body,
            extensions: const [TableHtmlExtension()],
            style: {..._defaultStyle, ...?widget.htmlStyle},
          ),
        );
  }

  Future<void> _print() async {
    final body = widget.report != null ? widget.report!.buildHtml() : _html;
    final size = pageSizeOf(widget.paper, widget.orient);
    if (kIsWeb) {
      // @@@ Same as above: expand $() and accept spellings like landscape
      final html = widget.report != null
          ? widget.report!._fullHtml(body, size)
          : _fullHtmlSrc(body, size);
      openHtmlForPrint(html);
      return;
    }
    // @@@ when there's a WapReport object, its buildPdf() is reused
    //     directly (the same implementation, not rewritten); only a demo
    //     card with no WapReport assembles HTML in place and converts it
    //     to PDF.
    // @@@ 2026-08-21 switched from Printing.layoutPdf() to
    //     Printing.sharePdf(): layoutPdf() internally calls Android's
    //     native PrintManager and brings up the system print preview,
    //     which depends on the system's resident Print Spooler service --
    //     some devices (stripped-down system builds, specialized
    //     hardware, etc.) don't have that service, so it hangs forever on
    //     "preparing preview," and our own code never gets called at all
    //     (none of buildPdf()'s debug messages print, because
    //     layoutPdf() never gets that far). sharePdf() goes through
    //     Android's Share Intent mechanism instead, which doesn't depend
    //     on the print service -- once the PDF is generated, it goes
    //     straight to the system share sheet (save to file / send to
    //     another app / a printer app, etc.), so the user can still save
    //     the PDF, and it works fine on devices missing the print
    //     service.
    if (widget.report != null) {
      final bytes = await widget.report!
          .buildPdf(paper: widget.paper, orient: widget.orient);
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${widget.title}.pdf',
      );
      return;
    }
    // @@@ 2026-08-21 the demo card now goes through the same native
    //     WebView path too (see the long comment above
    //     WapReport.buildPdf() for why).
    final html = '''<!DOCTYPE html>
<html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
${reportCssSrc(size)}
${printChromeResetCss(size, widget.paper, widget.orient)}
</style></head><body>$body</body></html>''';
    final bytes = await HtmlToPdfConverter().convertHtmlToPdfBytes(html: html);
    await Printing.sharePdf(bytes: bytes, filename: '${widget.title}.pdf');
  }

  // The HTML wrapper used for printing the demo card
  String _fullHtmlSrc(String body, String pageSize,
          [String extraCss = '', bool includePrintScript = true]) =>
      '''<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>
${reportCssSrc(pageSize)}
$extraCss
</style></head><body>$body
${includePrintScript ? '<script>window.onload=function(){window.print();}</script>' : ''}
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
    if (_error != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Error:\n$_error',
            style: const TextStyle(color: Colors.red, fontSize: 13)),
      ));
    }
    // Report cards: rendered via iframe (avoids cross-fragment HTML concatenation issues)
    if (widget.report != null) {
      return _buildIframe(_html);
    }
    // Demo cards: flutter_html (structure is complete, renders normally)
    return SingleChildScrollView(
      padding: widget.padding,
      child: Html(
        data: _html,
        extensions: const [
          TableHtmlExtension()
        ], // @@@ table rendering (not const)
        style: {..._defaultStyle, ...?widget.htmlStyle},
      ),
    );
  }
}
