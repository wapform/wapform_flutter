// report_web.dart
// ═════════════════════════════════════════════════════════════════════════
// Platform-agnostic entry point for the report web-embedding helpers.
// Picks report_web_impl.dart (real dart:html/dart:ui_web implementation)
// when compiling for Flutter Web, and report_web_stub.dart (no-op
// fallback) everywhere else. This is what lets wapform_report.dart be
// imported from mobile/desktop projects without pulling in web-only
// libraries at compile time.
// ═════════════════════════════════════════════════════════════════════════
export 'report_web_stub.dart' if (dart.library.html) 'report_web_impl.dart';
