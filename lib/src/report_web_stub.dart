// report_web_stub.dart
// ═════════════════════════════════════════════════════════════════════════
// Non-web fallback for the report web-embedding helpers.
//
// wapform_report.dart needs two browser-only capabilities on Flutter Web:
//   1. Opening a full HTML page in a new tab and triggering window.print().
//   2. Embedding raw HTML in-place via an <iframe> platform view.
//
// Neither capability exists outside the browser, so this stub provides
// no-op / null fallbacks. The real implementation (report_web_impl.dart,
// which uses dart:html and dart:ui_web) is swapped in automatically by
// the conditional import in report_web.dart whenever dart:html is
// available. This keeps wapform_report.dart itself platform-agnostic so
// the package can be added to mobile/desktop projects without a
// compile-time dependency on web-only libraries.
// ═════════════════════════════════════════════════════════════════════════
import 'package:flutter/widgets.dart';

/// Opens [html] as a full page and triggers printing.
/// Not supported outside the browser; on non-web platforms printing goes
/// through the `printing` package instead (see WapReport.buildPdf).
void openHtmlForPrint(String html) {
  // No-op: non-web platforms use Printing.layoutPdf() instead.
}

/// Embeds [html] in place via a platform view. Web-only feature — returns
/// null on other platforms, where WapPage uses a WebView instead.
Widget? buildHtmlIframe(String html) => null;
