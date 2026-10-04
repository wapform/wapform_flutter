# Changelog

## Unreleased

- **Supported platforms declared: Android and Web** (`platforms:` in
  `pubspec.yaml`). Web builds were verified with `flutter build web` of
  the example; pub.dev previously inferred Android / iOS only from
  `flutter_native_html_to_pdf`.
- **`LICENSE` is now the plain LGPL-2.1 text** so pub.dev / GitHub can
  recognize it. The FPC static-linking exception is unchanged and still
  applies; it is in `COPYING.modifiedLGPL.txt`.
- `dart fix` / `dart format` applied to `lib` and `test`; the FPC
  resource-string names (`lazarus_db.dart`) and WML function names
  (`wapform_expression.dart`) keep their original spelling
  (`ignore_for_file` for the naming lints). Analyzer issues 394 -> 54.

## 1.6.6

- **Example database account is now `xyz` / `123`** (simulated sample
  values), the same account used by every WapForm sample
  (`example/lib/wapform.ini`, `example/server/server.js`,
  `example/server/sales.sql`, `INSTALL.md`).

## 1.6.5

- **Example pages updated to the latest generator output** (`app*.dart`,
  `function.dart`, `main.dart`, the `wapform_*` helpers and their `.wml`
  sources), all importing the runtime as `package:wapform_flutter/...`.
- **Fixed publishing/compile errors**: `pdf` is now a direct dependency
  (`wapform_report.dart` imports `PdfPageFormat`), and
  `flutter_native_html_to_pdf` is `^3.0.0`, the version that provides
  `HtmlToPdfConverter`.
- **`html` pinned to `<0.15.7`**: `flutter_html` 3.0.0 does not compile
  against `html` 0.15.7 (`QuerySelector.matches` was removed).
- **Example database account uses simulated values** (`wapform` /
  `wapform123`, created by `example/server/sales.sql`) in
  `example/lib/wapform.ini` and `example/server/server.js`.
- Example smoke test updated for the `WapApp` entry point.

- **`example/server/sales.sql` replaced with a complete sample-data
  export** (fictitious companies and people), not hand-written/partial seed data. All 12 tables the
  example app needs (`num` aside, which the app populates itself) now
  have real sample rows, not just `sys`/`mnu`/`login`/`users`.
- **Database renamed from `flutter` to `sales`**, matching this real
  export's actual name — updated consistently across `sales.sql`,
  `server.js`, `example/lib/wapform.ini`, `INSTALL.md`, and
  `example/README.md`.
- **`web` table dropped** — the regenerated `app002.dart` (since
  1.6.0) no longer queries it; a stale reference to it in the main
  `README.md`'s page-by-page description is fixed.
- **The old `mnu.activate` vs. `active` column-name mismatch (worked
  around with a sync trigger in the previous `sales.sql`) turns out to
  have been this repo's own placeholder schema using the wrong column
  name, not a bug in `wapform_menu.dart`'s query** — the real schema
  has always used `activate`. The trigger workaround is gone; the
  column is just `activate` now, matching the query directly.
- **`function.wml`'s self-test report is now a real, permanent `mnu`
  menu item** (id 216, "Function Self-Test"), not only a
  `kDebugMode`-only button — a deliberate choice, confirmed while
  reviewing this update, that makes it reachable in release builds
  too for any account with a matching `login` permission row. Updated
  `example/lib/main.dart`'s comments (which had claimed the opposite)
  and both READMEs' `function.wml` descriptions to match. The
  debug-only button in `main.dart` stays as a faster shortcut during
  development, not the only path to it anymore.
- Dropped one junk row from the uploaded `mnu` seed data (id 123,
  title `'123'`, empty href) that looked like accidental leftover
  test data, confirmed as such before removing it.
- `INSTALL.md` updated throughout: seed-data description (real data,
  not "4 tables seeded, rest blank"), updated row counts in
  troubleshooting steps, and a stale claim that Web was "the only
  platform actually exercised" (superseded by 1.6.5's Android
  verification, missed when that entry was written).

## 1.6.5

- **"Platform Support & Web-First Architecture" now reflects Android
  as a verified platform, not just future work.** Previously said
  mobile support "will be added incrementally going forward"; that's
  no longer accurate — the full example app (all 12 pages, login, the
  data-driven menu, and the report/PDF pipeline) has been fully
  tested against real Android hardware, not just the report path in
  isolation. Also expanded the "Native HTML reports and printing"
  bullet to describe Android's actual print path (native WebView +
  `PrintDocumentAdapter` via `flutter_native_html_to_pdf`), alongside
  the existing Web (`window.print()`) description. iOS/desktop
  remain future work. `pubspec.yaml`'s separate warning about
  `webview_flutter`/`flutter_native_html_to_pdf` potentially breaking
  the *Web* build (unconditional imports, unverified against Web
  specifically) is untouched — Android verification doesn't resolve
  that, they're different questions. Documentation only.

## 1.6.4

- **Removed the `tt_*`/"COBOL-intrinsic" framing of the function
  library** from `README.md` (File reference's
  `wapform_expression.dart` entry and the `function.wml`/
  `function.dart` section) and `example/README.md` — functions are no
  longer separated into `tt_`/`cb_` prefixes, so describing the
  library that way no longer matches reality.
- **Dropped the "13th file" framing** for `function.wml`/
  `function.dart` in both READMEs. Both now close with a pointer to
  **wapform_manual**, the complete technical manual at
  [wapform.com](https://wapform.com), as the reference for WapForm's
  overall architecture — every tag, every function, how the pieces
  fit together — rather than treating the manual link as narrowly
  "what this one test file checks itself against."
- Documentation only.

## 1.6.3

- Moved the "download the full manual" pointer from
  `example/README.md` to the main `README.md`'s "Example pages"
  section — the intended location; it had been added to the wrong
  file. Corrected the URL to `https://wapform.com` (was `http://`).
- While there, fixed the main `README.md`'s "Example pages" section
  heading and prose, which still said `example/lib/pages/` — stale
  since 1.6.0 flattened that directory. Added a short entry for the
  13th file, `function.wml`/`function.dart` (previously undocumented
  in the main README, only covered in `example/README.md`), and a
  one-line mention that login/menu now sit in front of the 12 pages.
  Documentation only.

## 1.6.2

- **The manual's structure changed since `function.wml` was written**:
  the complete function reference is no longer a standalone Chapter
  17 — it's now **Appendix B, "Complete Function Reference"** (Chapter
  6, "Expressions and the Function Library," now covers only
  interpolation syntax and operators). Updated every reference:
  - `function.wml`'s own header comment and its rendered
    "all tests passed" summary line (user-visible report text, not
    just a code comment).
  - `example/README.md`'s description of `function.wml`/`function.dart`.
  - Also noted, since the new manual states it explicitly: Appendix B
    documents **398 functions** in total, and this test file's 363
    cases cover most of that, not literally every entry — the README
    previously implied full coverage without saying so.
  - `example/README.md`'s wapform.com pointer now cites Chapter 4
    ("Complete Tag Reference") and Appendix B by name, instead of a
    generic "every tag and function."
  Verified with a real XML parser (not a regex) that `function.wml`
  is still well-formed after the edits. Documentation only — no
  test-case content or pass/fail logic changed.

## 1.6.1

- `example/README.md`'s `function.wml`/`function.dart` section now
  points to the full WML tag/function reference manual, downloadable
  from wapform.com — `function.wml` only cross-checks against it, it
  isn't a substitute for it. Documentation only.

## 1.6.0

### Package (`lib/`)

- **`wapform_expression.dart` gains roughly 60 previously-undocumented
  functions**, added after cross-referencing the new
  `function.wml`/`function.dart` self-test report (see below) against
  Chapter 17 of WapForm's own function reference — functions the
  documentation described but the engine never actually registered.
  Also fixes two real bugs the same cross-check surfaced: `Color2Hex`/
  `Hex2Color` had the byte order backwards (Delphi's `TColor` is BGR,
  not RGB), and `ROUND`/`ROUNDTO`'s sign handling was inverted
  relative to the spreadsheet convention this engine follows (Delphi's
  native `RoundTo` uses the opposite sign for "decimal places" vs.
  "integer places").
- Real dataset/UI fixes carried in this release (translated from the
  source that already had them fixed): `WapLookupBox` no longer caches
  an empty lookup map while its dataset isn't open yet (was leaving
  picker lists permanently empty in some timing cases); alignment
  fixes in `lazarus_dbctrls.dart`/`lazarus_dbgrids.dart`/
  `lazarus_stdctrls.dart`.
- Reapplied several fixes from 1.0.0–1.5.0 that had drifted back to
  their pre-fix state in the uploaded source this release was built
  from: the `wapform_filter.dart` barrel export, `<report>`/`<output>`
  naming, `rev1`/`rev2`/… file-history relabeling, `report_web.dart`'s
  import path, and a batch of already-translated English comments that
  had reverted to Chinese. No new content beyond what was already
  shipped — carried forward, not re-derived.

### Example app (`example/`)

- **The example is now login → a fully data-driven main menu**,
  replacing the flat 12-button reference gallery from 1.2.0–1.5.0.
  `wapform_login.dart` and `wapform_menu.dart` reproduce the desktop
  WapToolkit's own login dialog and dynamic menu; `wapform_session.dart`
  holds one shared `WapEvaluator`/`DataSetRegistry` per app run, so
  `$username` and friends are readable by every page after login, the
  way they are in the original WML. Menu contents (groups, items,
  order, titles, per-user permissions) come entirely from the
  `mnu`/`login`/`users` tables — changing the menu means changing
  data, not code.
- **Every file now lives flat in `example/lib/`** (the `pages/`
  subfolder from 1.2.0 is gone) — that's the layout the generator
  itself produces and `main.dart`'s imports assume.
- **New 13th file: `function.wml`/`function.dart`, the package's
  primary test program** — a 363-case self-test report that runs
  every documented example expression for every function in
  `wapform_expression.dart` and checks it against its documented
  expected value, grouped into six categories with a pass/fail count
  per category and overall. Not a real menu item (no `mnu.href` row);
  reachable only via a `[debug] Function self-test report` button that
  `kDebugMode` strips from release builds. `function.wml` was
  originally Big5-encoded (not UTF-8, unlike every other `.wml` file
  in this repo) — converted, and verified with a real XML parser
  (not a regex) both before and after translation.
- **Database name changed from `ag` to `flutter`** — updated
  consistently across `sales.sql`, `server.js` (including its
  previously-flagged stale `shopcloud` comment/banner, now actually
  fixed instead of just documented as harmless), `INSTALL.md`, and
  `example/README.md`.
- **`sales.sql` now seeds `users`/`mnu`/`login`, not just `sys`** —
  required for the app to be usable at all under the new login/menu
  architecture (previously, seeing the 12 pages needed no login at
  all). Seeded account: `admin`/`admin`.
- **Found and worked around a real schema/code mismatch**: the new
  `wapform_menu.dart`'s menu query filters on `mnu.activate = 1`, but
  the real production schema's column is `active`. Added `activate`
  as a real column kept in sync with `active` via two triggers, with
  the mismatch documented inline in `sales.sql` — not silently
  patched, and `wapform_menu.dart` itself wasn't modified; the actual
  fix belongs in that query.
- `example/lib/main.dart` and `wapform_colors.dart`'s asset loading
  (`assets/wapform.htm`, declared in `pubspec.yaml`) are wired
  together again after the `main.dart` replacement — this exact fix
  had already been made once in 1.5.0's now-superseded `main.dart`.
- `INSTALL.md` and `example/README.md` rewritten throughout to match:
  the login step and default credentials, the flat file layout, the
  `function.wml` test program, and updated troubleshooting entries
  (the old "Cannot reach the WapDb gateway" status banner no longer
  exists in the new `main.dart`).

## 1.5.0

- **`WapColors.load()` is now actually wired up in the example app.**
  `example/assets/wapform.htm` (the CSS source `WapColors` parses for
  report/grid zebra-stripe colors) is now bundled via `pubspec.yaml`'s
  `flutter.assets`, and `example/lib/main.dart`'s `main()` calls
  `await WapColors.load()` before `runApp()` (with
  `WidgetsFlutterBinding.ensureInitialized()` first, required for any
  async call this early). Previously neither existed: the asset wasn't
  bundled and nothing ever called `load()`, so the example always
  silently ran on `WapColors`' built-in default colors — not broken
  (there's a try/catch fallback), just never actually exercising the
  CSS-driven path the type exists for.
- Added **`example/lib/pages/wapform.ini`**, a database-connection
  profile in the format the *desktop* WapForm designer tool reads —
  not consumed by the Flutter app itself. Included as a reference so
  that opening any of the 12 `.wml` files in the actual desktop tool
  has a connection profile already pointed at the same `ag` database
  this example's backend uses.
- `example/README.md` documents both new files and what each is
  actually for.
- No changes to `lib/` (the published package itself) or to any of
  the 12 example page `.dart`/`.wml` pairs in this release.

## 1.4.0

- **Non-Web PDF generation now actually works, verified against real
  Android hardware** — replacing the unverified `Printing.convertHtml()`
  approach from 1.1.0, which turned out to have a real upstream bug
  (`dart_pdf#1517`): it hangs indefinitely on some devices regardless
  of content size (tested down to under 10,000 characters, still
  hung). `Printing.layoutPdf()` was tried too and depends on a system
  Print Spooler service some devices don't have, hanging on "preparing
  preview" without ever calling into this package's code.
  `WapReport.buildPdf()` now generates PDFs via a native WebView +
  `PrintDocumentAdapter` pipeline (the `flutter_native_html_to_pdf`
  package), and also reuses the on-screen preview's CSS instead of a
  separate print stylesheet that was wrapping fields — both changes
  actually tested on-device, not just theorized. New dependencies:
  `webview_flutter`, `flutter_native_html_to_pdf`.
  **⚠ Not verified here: whether this breaks the Web build.** Both new
  packages are imported unconditionally in `wapform_report.dart` (no
  `if (dart.library.html)`-style guard like `src/report_web.dart`
  uses), and `flutter_native_html_to_pdf` in particular may not have a
  Web implementation at all. If neither package supports Web, `flutter
  build web` could fail to compile — which would contradict this
  package's Web-first positioning. Run `flutter build web` before
  relying on this.
- `WapPage`'s screen preview and demo-card print path also switched to
  the native WebView, replacing `flutter_html`/`flutter_html_table`
  for full-report rendering — avoids `flutter_html_table`'s known
  dry-layout crash, and layout is now handled by a real browser engine
  instead of a from-scratch HTML re-implementation. The demo card's
  print path also switched from `Printing.layoutPdf()` to
  `Printing.sharePdf()`, for the same Print Spooler reason as above —
  `sharePdf()` goes through Android's Share Intent instead, which
  doesn't depend on that service.
- Print-output scaling is now computed on the Dart side and baked into
  fixed CSS, replacing an in-browser JS-measurement approach. The
  report's 116-character ruler line (which can't wrap) needs the
  printable area to fit at least that many characters; the print font
  size is now derived directly from a measured (not assumed)
  characters-per-pixel ratio — an earlier assumed ratio undershot by
  enough to clip 5 of 116 characters in testing.
- **Security fix**: `WapFilter`'s search box now escapes single quotes
  before building `WHERE` clauses (`field = '...'`) — previously, a
  user typing `'` into a search field could break the SQL string
  literal, at best causing a query error and at worst constructing an
  unintended condition. Matches the escaping WML's own SQL_WHERE
  generation already does via REPLACE().
- `WapFilter`'s layout rewritten to match the original desktop
  (Delphi/Lazarus `TCard._dbfilter`) positioning: Search/Clear
  buttons and the syntax-hint text now share the first row (previously
  the buttons were placed after the search fields, with the hint on
  its own line, which didn't match the desktop version), and field
  width now follows the desktop version's exact formula instead of an
  approximated one.
- `WapLookupBox` fixed a caching bug where a lookup's picker list
  could stay empty forever: the lookup map used to get cached
  regardless of whether the dataset was open yet, so if the
  record count happened to match on both the "not yet open" and
  first "now open" builds, the cache never got invalidated. Especially
  likely to hit dynamically-created lookup sources
  (`lookup="sql;<id>;<SELECT>"`), which open later than a
  `<dbtable>`-declared dataset. Now returns (and doesn't cache) an
  empty map while the dataset is closed, so the next build retries.
- Re-applied fixes from 1.0.0–1.3.3 that had drifted back to their
  pre-fix state in the uploaded source this release was built from
  (same underlying files, evidently edited from an older branch):
  `wapform_filter.dart` missing from the barrel export,
  `<output>`/`<report>` tag naming, the `rev1`/`rev2`/... file-history
  relabeling, `report_web.dart`'s import path, and several
  already-translated English comments that had reverted to Chinese.
  No new content in any of these beyond what 1.0.0–1.3.3 already
  covered — carried forward, not re-derived.

## 1.3.3

- **Re-attributed three "core definition" claims from WML to
  WapForm.** WML is just the declarative language WapForm reads and
  writes (comparable to HTML being just a markup language, not an
  application in itself) — WapForm is the system that adds the
  generator/runtime automation on top of it. Three places in the
  README stated the "source of truth" / "single definition" / "the
  center" role in terms of WML itself; reworded to attribute that
  role to WapForm instead:
  - "WML is the application's source of truth." → "WapForm is the
    application's source of truth."
  - "WML is the single application definition; the generator expands
    it..." → "WapForm is the single application definition; the
    generator expands it..."
  - "WML is the center. AI is the accelerator..." → "WapForm is the
    center. AI is the accelerator..."
  Left two other WML-related sentences unchanged, since they already
  describe WML correctly as WapForm's language rather than claiming a
  central role for it: "WML is a plain-text, declarative
  application-definition language" and "WML is WapForm's
  platform-agnostic, declarative application-definition language."
  Documentation only.

## 1.3.2

- **The `<output>`→`<report>` tag rename (documentation-only in
  1.1.4, which explicitly noted the actual WML/generator-side rename
  was out of scope) is now applied throughout the repo**, not just in
  prose: the 5 example WML files that actually use the tag
  (`app002.wml`, `app004.wml`, `app007.wml`, `app012.wml`,
  `app901.wml`) now declare `<report ...>...</report>` instead of
  `<output ...>...</output>`, and the matching comments in their
  paired `.dart` files (which describe what the tag compiles to) were
  updated to match, so each WML/Dart pair stays consistent with
  itself. Also updated `lib/wapform_report.dart`'s own file-header
  comment, which still described itself as corresponding to WML's
  `<output>`.
- Comment-only / example-content-only changes — no logic changes in
  `lib/`.

## 1.3.1

- **Relabeled the per-file "Revision History" headers in
  `wapform_lookup_box.dart`, `wapform_expression.dart`,
  `wapform_colors.dart`, and `wapform_report.dart`.** These four files
  each carry their own internal edit log using a `V1.0`/`V1.1`/`V2.0`
  style — a leftover convention from the original Delphi/Pascal
  sources — which visually collides with this package's own semver
  (`pubspec.yaml`, now well past 1.0.0). A reader could easily mistake
  `wapform_report.dart`'s internal "V2.0" for a claim about the
  package being at major version 2 (it isn't — the package is at
  1.3.1). Renamed to `rev1`/`rev2`/... and added a one-line note
  ("unrelated to the package version in pubspec.yaml") to each
  header. `wapform_report.dart` had one internal cross-reference to
  its own old "V2.0" label (in a comment about the PDF-generation
  fix) updated to match (`rev6`).
- `wapform_expression.dart` also had four inline comments marking
  which version range of the original **`myexp_flutter`** project
  (an earlier, separate codebase this file's expression engine was
  merged from — not part of this package) a section of code came
  from, e.g. `tt_ custom function library V1.3`. Three of the four
  appeared without "myexp" nearby, so out of context they read the
  same way — prefixed all three with "myexp" to make the source
  unambiguous; left the fourth alone since it already sits two lines
  below an explicit "myexp.pas" comment.
- No behavior changes — every edit in this release is a comment-only
  rename.

## 1.3.0

- **`example/server/schema.sql` renamed to `sales.sql`**, matching the
  package's "sales management system" framing (see the "Example pages"
  section of the main README). All references updated across
  `example/README.md`, `INSTALL.md`, and the file's own header/usage
  comments.
- **`sales.sql` expanded from 1 table to 13** (`cu`, `em`, `fm`,
  `login`, `mnu`, `num`, `pa`, `sh`, `sn`, `sys`, `users`, `ve`, `web`)
  — every table the 12 example pages actually query, checked against
  every `select`/`insert`/`update` in `example/lib/pages/app*.dart`
  against a real production database dump. Only `sys` has a seed row;
  the other 12 are created empty (documented in `example/README.md`
  and `INSTALL.md` — pages open successfully now, but most show a
  blank form/grid until you add your own data).
- Fixed two example-package bugs found while writing `INSTALL.md`:
  `example/pubspec.yaml` was missing the `flutter_html` and
  `url_launcher` dependencies that several of the 12 pages actually
  import (would have failed to compile), and its `description` still
  referenced the old single-page demo.
- **Added `INSTALL.md`** at the repo root: a full step-by-step setup
  guide starting from installing the Flutter SDK itself (including the
  `C:\flutter` Windows convention) through running the example app,
  with a "why does this need two servers" explanation up front and a
  troubleshooting section. Linked from the main README's "Install"
  section.
- Added a short "Example pages" section to the main README's file
  reference, describing what each of the 12 `example/lib/pages/`
  WML/Dart pairs demonstrates, and noting `app012` specifically as the
  source of the grouped-report example used earlier in the README.
- Collapsed `example/README.md`'s own step-by-step setup section (which
  had grown to duplicate most of `INSTALL.md`) down to a short pointer
  at the new file, keeping only a minimal quick-start snippet — one
  install guide to maintain instead of two that could drift apart.

## 1.2.0

- **Replaced the single-page `example/` demo (`agp001.dart`) with 12
  real generator-output pages**, each paired with its source `.wml`
  file in the same folder (`example/lib/pages/app001.wml` +
  `app001.dart`, ... `app902.wml` + `app902.dart`) — genuine output
  from WapForm for Flutter's commercial generator, not hand-written
  illustrations. Fixed each file's import block (`wap/xxx.dart` →
  `package:wapform_flutter/xxx.dart`) to resolve as a normal pub
  dependency; no other changes to the generated Dart.
- `example/lib/main.dart` rewritten as a flat reference-gallery list
  of all 12 pages (no shared login/session/menu — each page opens
  standalone via its own `showAppXXX(context)`), replacing the old
  single hard-coded button (which also had an untranslated Chinese
  label, "系統參數建檔" — gone now along with the rest of the old
  page).
- `example/README.md` rewritten to document the new 12-page set,
  including a table of what each pair demonstrates (master-detail,
  grouped reports, filtered search, lookup fields, etc.) mapped back
  to the corresponding sections of the main README.
- **Known limitation, called out explicitly in the new README**:
  `server/schema.sql` still only defines the `sys` table from the old
  single-page demo. Of the 12 pages, only page 1 (System Parameters)
  can actually open successfully against this demo database — the
  other 11 reference tables that don't exist yet in this schema, and
  are included as WML/Dart reference pairs to read, not as verified
  end-to-end demos. Extending the schema to cover all 12 is tracked as
  follow-up work, not done in this release.

## 1.1.7

- Rewrote "Platform support" as "Platform Support & Web-First
  Architecture." The previous version asserted the package "compiles
  on mobile, desktop, and web" and that everything "behaves the same
  on every platform," qualified only by a PDF-output caveat — an
  unverified claim (no actual mobile/desktop compile had been run).
  The new version is scoped to what's actually been exercised: Web is
  the current focus, with mobile support explicitly framed as future
  work, not a present (if imperfect) capability. No longer mentions
  PDF/`Printing.layoutPdf()`/`Uint8List(0)` at all — report
  output is described simply as HTML-based via `window.print()` on
  Web, without implying PDF support is a near-term gap to be filled.
  Documentation only.

## 1.1.6

- Merged `WML → embedded` and `WML → other platforms` (the latter had
  no examples) into one line naming actual candidates: `WML → other
  platforms: MicroPython, Node.js`.

## 1.1.5

- Merged the three COBOL subsections ("Not the Same as Typical AI
  COBOL → Java Conversion", "Isn't Just an Output Target...", "Doesn't
  Have to Start From Zero") into one ("On COBOL: Not a Language
  Converter, and Not Starting From Zero") — they covered one
  connected argument and reads more directly as a single section
  instead of three, cutting the repeated setup between them
  (about 45% shorter).
- While merging, restored a fix that had been silently reverted:
  the "future can look like" list was back to `COBOL → WML → Flutter`
  / `WML → COBOL` (the original order) instead of `COBOL → WML →
  COBOL` / `COBOL → WML → Flutter`, which is what this repo settled
  on. This slipped back in when a full-section rewrite was pasted in
  wholesale later and carried its own draft of that list along with
  it. Fixed again here.
- Confirmed `wapform_flutter.dart` (the barrel file) doesn't need its
  own bullet entry in "File reference" — it already gets an intro
  paragraph at the top of that section (added in 1.1.1), which fits
  better than forcing it into either the Lazarus-layer or
  WapForm-layer list when it belongs to neither. No change needed.

## 1.1.4

- Fixed the employee-master example's indentation: `<dbquery>` and
  `<datasource>` are both direct children of `<card>` and should be
  indented at the same level; `<dbquery>` was flush against the left
  margin instead.
- **Renamed the report tag `<output>` to `<report>` throughout the
  README** (the grouped-report example and its two mentions in "File
  reference"). This is a naming change on the WML/generator side —
  the actual `<output>`→`<report>` rename in the WML language and
  generator itself is out of scope for this repo and being handled
  separately; nothing in `lib/` changed here. Going forward,
  documentation in this repo uses `<report>` as the standard name.
  Documentation only.

## 1.1.3

- The "From WML to this API" section's master-detail and report
  paragraphs were assertions with no code to back them up, unlike the
  employee-master example right above them. Both now have full WML +
  Dart examples, matching the employee example's format:
  - **Master-detail**: a shipment order (`sh`) with its line items
    (`sn`), using `masterfields` to refilter the detail on every
    master-record scroll, plus a `<dbgrid><item lookup=>` grid column
    wired to a lookup resolver — based on `app006.wml`'s real
    structure, not an invented example.
  - **Grouped report**: a customer statement using `<group
    change="sh.cno">` with `setvar`-accumulated subtotals, translated
    into a `WapReport` subclass's `parseBlock()` — based on
    `app012.wml`'s real structure (trimmed from three nested group
    levels to one, for length).
  - Both Dart examples were checked against real generated output
    (`app006.dart`/`app012.dart`) and the actual class definitions in
    this repo before being written up, after an initial draft used
    invented method signatures (`emit()`, a value-returning
    `parseBlock()`, `TColumn`'s constructor taking named parameters)
    that don't match the real API. Corrected before publishing.
  Documentation only — no code changes.

## 1.1.2

- Fixed the "From WML to this API" example: `<dbquery>` was shown as a
  sibling of `<card>` (declared at the top level, before the card).
  The actual WML convention — matching every real WML file in this
  project — is to declare `<dbquery>` as the first child inside the
  `<card>` it belongs to. Documentation only, no code changes.

## 1.1.1

- README's "File reference" section was missing two things that
  actually exist in the package: `wapform_filter.dart` (added to the
  barrel export in 1.1.0, but never documented) now has its own entry
  next to `wapform_lookup_box.dart`; and `wapform_flutter.dart` itself
  (the barrel file) now gets a short intro at the top of the section
  explaining what it does and why every file lives flat in `lib/`
  instead of behind `lib/src/` (so each one stays independently
  importable). Documentation only — no code changes.

## 1.1.0

- **`wapform_filter.dart` is now exported from the barrel file**
  (`wapform_flutter.dart`). It existed as a real, working widget
  (`WapFilter`, wired into the WML→Flutter generator's `<dbfilter>`
  output) but was never added to the barrel export list, so anyone
  importing `package:wapform_flutter/wapform_flutter.dart` couldn't
  reach it without also importing the file directly. Translated its
  remaining Chinese UI strings to English (`Search`/`Clear` button
  labels, the range/wildcard syntax hint text) to match the rest of
  the package.
- **Fixed `wapform_report.dart`'s import of the web-embedding
  helpers**: was `import 'report_web.dart';`, which doesn't resolve
  since `report_web.dart`/`report_web_impl.dart`/`report_web_stub.dart`
  live in `lib/src/`, not `lib/`. Now `import 'src/report_web.dart';`.
- **Non-Web PDF generation is wired back in.** `WapReport.buildPdf()`
  previously short-circuited to always return an empty `Uint8List(0)`
  on mobile/desktop — the native print/share dialog would appear, but
  the resulting document was blank. It now calls
  `Printing.convertHtml()` with a base64-embedded Chinese font
  (`wapFontFaceCss()`), since `Printing.convertHtml()`'s underlying
  offline rendering engine can't see system-installed fonts and would
  otherwise render Chinese as tofu boxes. **This has not been verified
  against the currently-locked `printing` package version** — the
  translation work here had no pub.dev access to confirm
  `Printing.convertHtml()`'s exact parameter names/return type against
  the version this package locks; it's written against that package's
  long-stable public API. If you hit a compile error here (e.g. a
  named parameter not found), please file an issue with the exact
  error. This also means the "PDF/print output is Web-only" caveat in
  this README's Platform Support section may now be outdated — please
  confirm on your target platform before relying on it, and let us
  know either way.
- **Custom paper sizes.** `paper="8.5x5.5"`-style WxH-in-inches sizes
  (e.g. Taiwan's common pre-printed continuous-form paper) are now
  recognized alongside named sizes (A4/letter/...), consistently
  across screen width, CSS `@page`, and `PdfPageFormat` generation
  (`customPaperSizeInches()`).
- Fixed two real dataset bugs surfaced while translating their
  explanatory comments to English (not just translation — the
  underlying logic was corrected):
  - `lazarus_sqldb.dart`: during `applyRecUpdate()`, the old-value
    snapshot used to build a row's `WHERE` clause could be read from
    the wrong record (whatever the cursor currently pointed at, rather
    than the record actually being updated) after a `DELETE` shifted
    the internal record array — in the worst case, this could delete
    the wrong row.
  - `lazarus_sqldb.dart`: `resync()` no longer applies the base
    windowed-buffer `rmCenter` centering logic, which doesn't apply to
    this subclass (`TCustomBufDataset` keeps the full result set in
    memory) and was shifting the cursor to an unrelated record after
    `<invoke method="locate">`.
  - `lazarus_db.dart`: `TDBGrid` no longer caps its apparent row count
    against a windowed-buffer field that doesn't reflect this
    dataset's real record count — this was causing detail grids to
    render blank even with data present (e.g. a 22-row grid showing
    nothing).
- Translated the remaining alignment-fix comments in
  `lazarus_dbctrls.dart`, `lazarus_dbgrids.dart`, and
  `lazarus_stdctrls.dart` (2026-08-14 fixes for single-line field
  vertical alignment and the data-grid header/border gap) to English.
- `wapform_report_style.dart`: translated newly-added CSS comments
  (the paper/trailing-block visual-stitching rule, the reduced cell
  padding for short paper sizes, and the `:nth-child` zebra-stripe
  fallback for reports without explicit `row1`/`row2` classes).
- Known issue carried forward, not addressed in this release: four
  `[DEBUG7 ...]` `print()` calls remain in `lazarus_db.dart`
  (`dataEvent`/`doAfterScroll`), left over from verifying the
  2026-08-14 `controlsDisabled()` fix. Translated their messages to
  English, but recommend removing them before their next use — `print()`
  can't be filtered by consumers and will spam the console of every
  app that uses this package.

## 1.0.0

- Added a new README section, "Development Vision & Technical
  Strategy" (with an "AI-Enabled, Highly Automated Translation"
  subsection), placed between "About the commercial generator" and
  "From WML to this API". It explains how this port was built
  (AI-assisted development against WML as a strongly-typed
  intermediate representation, rather than freeform AI code
  generation) and the longer-term portability goal (the same WML
  definition re-expandable against other target platforms/languages,
  not just Flutter).
- First 1.0.0 release: no breaking API changes from 0.2.4 — this is a
  documentation-only release. Bumped to 1.0.0 as a deliberate signal
  that the public API (`lazarus_*.dart` / `wapform_*.dart`) is
  considered stable going forward; see semver notes below if you're
  pinning a version constraint.

## 0.2.4

- Removed 18 unused private helper functions/methods from
  `example/lib/pages/agp001.dart` (`_key`, `_lkp`, `_cal`, `_execSql`,
  `_column`, `_sysInsert`, `_sysPost`, `_sysDelete`, `_log`, `_lbl`,
  `_td`, `_lookupBox`, `_vedit`, `_vcheck`, `_vlookup`, `_refreshVars`,
  `_tabPage`, `_nav`) — each had zero call sites in this file (verified
  by counting references before deleting, not just going on the
  analyzer's say-so). These are standard WML→Dart helper names the
  generator emits for every page regardless of which WML tags that
  particular page actually uses; `agp001` ("system parameters master")
  is a plain single-table form with no lookup/calculated/grid fields,
  so the lookup/calc/grid/tab/checkbox helpers were dead weight here —
  other generated pages that do use `<dbtable>`/`<dbgrid>`/etc would
  keep the equivalent helpers. File goes from 791 to 543 lines; no
  behavior change, purely removes code nothing calls.
- Note (not yet addressed): the same file, along with `example/README.md`,
  `example/lib/main.dart`, `example/pubspec.yaml`, and one line in this
  CHANGELOG, still contain Traditional Chinese comments and UI labels
  (~116 lines with actual Chinese words, plus separate full-width
  punctuation cleanup still pending in `lib/`) — tracked for a
  follow-up English-language pass, not done in this release.

## 0.2.3

Fixes based on the full `flutter analyze` output for v0.2.2 (the sample
of 2 issues pub.dev shows isn't the whole picture — thanks to running
the complete analysis locally, this round fixes every `warning`-level
issue found in `lib/`, not just the ones pub.dev happened to show).

- Fixed 4 more redundant `!` null-assertions in `lib/lazarus_db.dart`
  (`fieldByName`, `findIndex`, `paramByName` — lines 4315/4526/5686/7410):
  same shape as the 6 fixed in 0.2.2 (`if (x == null) { databaseErrorFmt(...); }`
  followed by `return x!;`), just missed on the first pass because that
  pass only searched for the exact `int.tryParse` variant.
- Fixed 3 more in `lib/lazarus_sqldb.dart` (lines 1686/2907/4317),
  including one `is!` check followed by a redundant `as` cast.
- Fixed 1 in `lib/wapform_expression.dart:1859` (`tt_ADDWORKDAYS`'s
  workday-stepping loop): `d = d!.add(...)` — `d` was already promoted
  non-null by an earlier `if (d == null) return null;`.
- Fixed 3 `unnecessary_cast` warnings (`lib/lazarus_db.dart:5588`,
  `lib/lazarus_sqldb.dart:842` and `:4930`) — each was an `as` cast
  immediately after an `is` check that had already promoted the type.
- Removed dead code the analyzer flagged as unused: an import
  (`dart:convert` in `wapform_report.dart`), a local variable (`base`
  in `wapform_expression.dart`), an import's `show TNotifyEvent` in
  `lazarus_stdctrls.dart`, and three private helper methods in
  `wapform_expression.dart` (`_isNull`, `_stackEmpty`, `_peek` — each
  had an equivalent inline call already in use elsewhere, e.g.
  `_stack.isEmpty`).
- Removed an unused field, `_prevToken`, in `wapform_expression.dart`
  (written once, never read).
- Removed an unused field, `_openAfterRead`, from `TDatabase` in
  `lazarus_db.dart`. **Worth double-checking against the upstream FPC
  source**: the same field name exists on the `TDataSet`-family classes
  elsewhere in this file with a real read/write pair (an "open after
  design-time load" flag tied to `active`/`loaded()`), but `TDatabase`
  has no such lifecycle — this looked like copy-paste leftover rather
  than a genuine gap, so it was removed rather than wired up. Flagging
  in case the upstream source says otherwise.
- Not touched (flagged for follow-up, not obviously dead code):
  `_cellText` in `lazarus_dbgrids.dart` and `_SrcReport` in
  `wapform_report.dart` both look like functionality that was written
  but never wired in, rather than pure dead code — left alone pending
  confirmation of intent.
- Not touched: the `unused_element` warnings in
  `example/lib/pages/agp001.dart` (a dozen or so private helpers like
  `_key`/`_lkp`/`_execSql`) — this is example/demo code, not the
  package itself, and the unused methods look like template scaffolding
  that may be intentionally there for reference.
- Not touched: the large number of `info`-level
  `non_constant_identifier_names` warnings on `tt_*`/`COB_*` function
  names in `wapform_expression.dart` — these intentionally preserve the
  original COBOL/Pascal-derived naming convention; renaming several
  hundred of them to `lowerCamelCase` would be a much bigger, more
  disruptive change than the other fixes in this release and needs a
  deliberate decision, not a drive-by lint fix.

## 0.2.2

- Fixed 6 redundant null-assertion warnings in `lib/lazarus_db.dart`
  (`i!`, `f!`, `c!`, `b!` after `int.tryParse`/similar): each of these
  is followed by `if (x == null) { databaseErrorFmt(...); }`, and
  `databaseErrorFmt` is declared `Never` — so the analyzer already
  promotes `x` to non-null past that check, making the trailing `!`
  a no-op. Confirmed each of the 6 occurrences shares this exact shape
  before removing the `!`; not a behavior change, purely removes dead
  syntax the analyzer was warning about (`pub points`: static analysis
  category).
- Shortened `pubspec.yaml`'s `description` from 307 to 162 characters
  (pub.dev's description-length check caps at 180; the previous text
  listed every translated FPC unit by name and ran well over).
- `LICENSE` now contains the full Modified-LGPL text directly (the
  static-linking exception, followed by the complete unmodified
  LGPL-2.1 text), instead of only pointing to `COPYING.LGPL.txt` /
  `COPYING.modifiedLGPL.txt`. Those two files are unchanged and still
  the canonical source for each part — `LICENSE` now just also
  reproduces them inline, verbatim, so pub.dev's and GitHub's
  automated license detectors (which only read the file literally
  named `LICENSE`) can recognize it as LGPL-2.1.
- Converted 849 existing `//` comments directly above public
  declarations (classes, typedefs, top-level functions, and first-level
  class members) to `///` dartdoc comments across `lib/`. No comment
  text or code logic changed — only the leading `//` became `///` where
  a comment already immediately preceded a public API element. Most of
  this content is the original-Pascal-source cross-references already
  present in the translation (e.g. `db.pas L1898`), which is genuinely
  useful dartdoc content, just written with the wrong comment syntax
  until now.

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
