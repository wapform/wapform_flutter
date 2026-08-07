// report_web_impl.dart
// ═════════════════════════════════════════════════════════════════════════
// Flutter Web implementation of the report web-embedding helpers.
// Only compiled in when dart:html is available (see report_web.dart's
// conditional import) — never referenced on mobile/desktop builds.
// ═════════════════════════════════════════════════════════════════════════
import 'dart:html' as html_lib;
import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';

/// Opens [html] as a full page in a new browser tab and triggers
/// window.print() (the page itself calls print() via a small inline
/// script — see WapReport._fullHtml).
void openHtmlForPrint(String html) {
  final blob = html_lib.Blob([html], 'text/html');
  final url = html_lib.Url.createObjectUrl(blob);
  html_lib.window.open(url, '_blank');
}

/// Embeds [html] in place using a registered <iframe> platform view.
/// Used instead of flutter_html for full reports, to avoid issues with
/// flutter_html splitting content across widget fragments.
Widget? buildHtmlIframe(String html) {
  final blob = html_lib.Blob([html], 'text/html');
  final url = html_lib.Url.createObjectUrl(blob);
  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(
    url,
    (int viewId) => html_lib.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%',
  );
  return HtmlElementView(viewType: url);
}
