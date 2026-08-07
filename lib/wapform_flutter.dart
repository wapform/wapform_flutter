// wapform_flutter.dart
// ═════════════════════════════════════════════════════════════════════════
// Barrel file — import this single file to get the whole package, or
// import the individual files below directly if you only need part of it
// (e.g. `package:wapform_flutter/lazarus_db.dart`).
// ═════════════════════════════════════════════════════════════════════════

// ── FPC/Lazarus translation layer ──────────────────────────────────────
export 'lazarus_db.dart';
export 'lazarus_sqldb.dart';
export 'lazarus_dbctrls.dart';
export 'lazarus_dbgrids.dart';
export 'lazarus_grids.dart';
export 'lazarus_stdctrls.dart';
export 'lazarus_extctrls.dart';

// ── WapForm layer (original code built on top of the above) ───────────
export 'wapform_expression.dart';
export 'wapform_lazarus.dart';
export 'wapform_lookup_box.dart';
export 'wapform_report.dart';
export 'wapform_report_style.dart';
export 'wapform_colors.dart';
