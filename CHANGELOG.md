# Changelog

## 0.2.1

- Fixed a real name collision in the package's public API: a
  never-called top-level `isNull(dynamic v)` helper in
  `wapform_expression.dart` collided with `package:matcher`'s `isNull`
  matcher, causing an `ambiguous_export` compile error in any file that
  imported this package alongside `flutter_test` (e.g. every test
  file). Renamed to `_isNull` (private) — unused anywhere in this
  codebase, so this is not a behavioral change.
- Fixed a syntax bug in `test/wapform_expression_test.dart`: an
  unescaped `$` in a non-raw string literal (`'...via $ substitution'`)
  is invalid Dart — `$` always starts an interpolation, raw or not,
  unless escaped or the string is a raw string.

## 0.2.0

- Added `test/wapform_expression_test.dart`: unit tests for the WML
  expression engine (`WapEvaluator`) — arithmetic, `cond()`, variable
  management (`setVar`/`setRow`/`clearVars`), a sample of the `tt_*`
  built-in function library, and `datasetResolver`-backed `$id.field`
  expressions via a lightweight fake `ExprDataSet` (no network/DB
  dependency, so this runs anywhere with `flutter test`). CI now runs
  `flutter test` in addition to `flutter analyze`.
- Added `example/`: a runnable Flutter app built around
  `agp001.dart`'s "系統參數建檔" (system parameters master file)
  screen — the real generator output for a single-table CRUD form,
  unmodified apart from its import block. Includes the WapDb HTTP
  gateway (`example/server/server.js`, `schema.sql`) needed to run it
  end to end. See `example/README.md`.

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
