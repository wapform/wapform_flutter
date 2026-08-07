# Changelog

## 0.1.1

- Fixed `flutter analyze`'s one blocking error: `lazarus_db.dart` and
  `lazarus_dbgrids.dart` each declared a same-named `TFieldNotifyEvent`
  typedef with different signatures, causing an `ambiguous_export`
  error from `wapform_flutter.dart`'s barrel file. The `dbgrids`-local
  one is now declared inline instead of as a duplicate typedef.
- Removed a stray `@override` on `TSQLConnection.getFieldNames()` —
  `TSQLConnection` extends `TDatabase`, not `TDataSet`, so there was
  nothing to actually override (a Pascal name collision between two
  unrelated classes, not a real inheritance relationship). Not a
  behavioral bug — no method was being silently skipped — just a
  stale annotation flagged by `flutter analyze` as
  `override_on_non_overriding_member`.

## 0.1.0

- Initial packaging as a standalone, installable Flutter module.
- Fixed a stale import: `lazarus_sqldb2.dart` → `lazarus_sqldb.dart`
  (in `wapform_lazarus.dart` and `wapform_lookup_box.dart`).
- Fixed a stale import: `wap_colors.dart` → `wapform_colors.dart`
  (in `wapform_report.dart` and `wapform_report_style.dart`).
- Removed `lazarus_lookup_box.dart`: an unused, superseded early version
  of `wapform_lookup_box.dart` (no lookup-map caching / search index —
  see `wapform_lookup_box.dart` for the current implementation).
- `wapform_report.dart` no longer imports `dart:html` / `dart:ui_web`
  directly. The web-only iframe/print-window code now lives behind a
  conditional import (`src/report_web.dart`, `src/report_web_impl.dart`,
  `src/report_web_stub.dart`), so the package compiles on mobile and
  desktop targets as well as web.
- All source comments translated from Traditional Chinese to English.
- Added `pubspec.yaml`, `LICENSE`, `COPYING.LGPL.txt`,
  `COPYING.modifiedLGPL.txt`, and a `wapform_flutter.dart` barrel export.
