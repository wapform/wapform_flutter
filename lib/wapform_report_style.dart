// wapform_report_style.dart
// ════════════════════════════════════════════════════════════════
//  Shared report styling — pulled out here so every report shares
//  it. Change a report's look (fonts/colors/group rows/borders…)
//  here and it changes everywhere at once.
//  Provided as functions because the CSS embeds $pageSize (paper
//  size) and WapColors (row background colors).
// ════════════════════════════════════════════════════════════════
/// CSS used to show and print reports.
library;

import 'wapform_colors.dart';

// Print version (same look as the on-screen preview, minus the
// "reader" chrome; row background colors are not applied when printing)
/// CSS for printing a report on [pageSize] paper.
String reportCssPrint(String pageSize) => '''
/* aa ### flutter extension
   Print version: same appearance as the screen preview, with the
   "reader" decoration stripped out — the gray backdrop, shadow, and
   inter-page gaps shouldn't be printed on paper; the sheet should lie
   flat and use all of the printable area. */

html, body { margin: 0; padding: 0; }

body {
  font-family: "Microsoft JhengHei", "Noto Sans TC", -apple-system, "Segoe UI", sans-serif;
  font-size: 13.3px;
  color: #2C2C2A;
  background: #F5F4F0;
  padding: 20px 0;
}

body > table {
  background: #ffffff;
  margin: 0 auto 20px auto;
  padding: 8px 16px 10px 16px;
  box-shadow: 0 1px 5px rgba(0,0,0,.16);
  border-collapse: separate;
}
body > table table { width: 100%; border-collapse: collapse; }
body > table > tbody > tr > td { padding: 0; border: 0; }

/* @@@ 2026-08-10 added: the same visual-stitching rule as reportCssScreen --
   some WML prints an extra trailing block after the paper container's
   (outer </table>'s) closing tag (e.g. a page-number row); this makes that
   block share the paper's white background and shadow so the two seams
   together. Width follows the 740px WML commonly uses (body>table itself
   has no width set here -- left alone; only the trailing block is handled). */
body > table:has(+ p:last-child) {
  margin-bottom: 0;
  box-shadow: 0 -1px 5px rgba(0,0,0,.16);
}
body > table + p:last-child {
  width: 740px;
  max-width: 100%;
  box-sizing: border-box;
  margin: 0 auto 20px auto;
  padding: 4px 16px 10px 16px;
  background: #ffffff;
  box-shadow: 0 1px 5px rgba(0,0,0,.16);
}

big { font-size: 1.35em; font-weight: 700; letter-spacing: 1px; color: #1a1a18;
      display: block; line-height: 1.4; }

/* Header block (the first nested table): collapse <p>/<td> spacing,
   otherwise it ends up far too tall */
p { margin: 0; padding: 0; }
body > table td > table:first-of-type td { /* @@@ allow an extra nesting level in case the WML brings its own centering frame */
  border-bottom: 0; padding: 1px 4px; font-size: 12.3px; color: #5F5E5A;
}

th {
  background: #D0CFC9; color: #2C2C2A; font-weight: 600; font-size: 13.3px;
  padding: 4px; text-align: center; white-space: normal; word-break: break-word;
}
tr.row th { background: #D0CFC9; color: #2C2C2A; }
tr.row    { background: transparent; }

/* @@@ Data tables use a fixed layout so <th width>/column widths are
   strictly honored (auto layout would not shrink below content width).
   @@@ 2026-08-10: margin-top 6px -- p{margin:0} keeps the header block
   compact, but that also pins the header's last line (often a ruler line /
   customer info) right up against the detail table's first row; this gives
   the detail table a little breathing room on its own, without loosening
   the header block's compactness. */
body > table td > table:not(:first-of-type) { table-layout: fixed; width: 100%; margin-top: 6px; }

td { padding: 4px; font-size: 13.3px; font-weight: 500; color: #2C2C2A; border-bottom: 1px solid #E8E7E1; vertical-align: top; }

tr.grp td { background: #EDEAE3; font-weight: 700; color: #185FA5; padding: 5px 5px; }

tr.sub td { background: #FAFAF8; font-size: 12.3px; color: #5F5E5A; padding: 3px 5px; }
tr.sub td:first-child { padding-left: 22px; }

.row1 { background: ${WapColors.hexTrRow1}; }
.row2 { background: ${WapColors.hexTrRow2}; }

/* @@@ 2026-08-10 added: the same fallback as reportCssScreen -- reports
   without an explicit class="row1"/"row2" still get zebra striping,
   auto-detected via :nth-child. */
body > table td > table:not(:first-of-type) tr:not(.row):not(.row1):not(.row2):not(.grp):not(.sub):not([height]):nth-child(even) td {
  background: ${WapColors.hexTrRow2};
}

/* ── Print: strip the reader chrome, let the sheet lie flat ── */
@media print {
  @page { size: $pageSize; margin: 10mm; }   /* smaller margins → maximize printable area */
  body {
    background: #ffffff;
    padding: 0;
    -webkit-print-color-adjust: exact;       /* keep header/group-row background colors */
    print-color-adjust: exact;
  }
  body > table {
    box-shadow: none;
    margin: 0;
    padding: 0;
    width: 100% !important;
  }
  tr, td, th { page-break-inside: avoid; }   /* don't let a row split across two pages */
}
/* zz ### flutter extension */
''';

// On-screen preview version (includes row background colors)
// @@@ pageWidthPx: content width of the paper, computed by
//     wapform_report's paperWidthPx(paper, orient). Used to override
//     the WML-hardcoded <table width="750"> via CSS (CSS wins over an
//     HTML width attribute), so switching landscape/portrait or paper
//     size updates the screen without touching the WML, and without
//     resorting to a long string to force the layout wide.
/// CSS for showing a report on screen, [pageWidthPx] wide.
String reportCssScreen([double pageWidthPx = 750]) => '''
/* aa ### flutter extension
   ═══════════════════════════════════════════════════════════════════════
   Default report appearance — defined here so every report gets it
   automatically; the WML never needs any styling of its own.

   This works because the HTML structure produced by WML export is fixed:
     <table width="750" align="center">   ← the "paper" (a direct child of body)
       <tr><td>
         <table>…company name / title / page number / date…</table>
         <table>
           <tr class="row"><th>…column headers…</th></tr>   ← WML's class="row"
           <tr><td>…detail rows…</td></tr>
         </table>
   So `body > table` reliably selects the paper, and `th` reliably
   selects the column headers — precisely, without any cooperation
   needed from the WML side.
   ═══════════════════════════════════════════════════════════════════════ */

html, body { margin: 0; padding: 0; }

body {
  font-family: "Microsoft JhengHei", "Noto Sans TC", -apple-system, "Segoe UI", sans-serif;
  font-size: 13.3px;
  color: #2C2C2A;
  background: #F5F4F0;            /* outer gray backdrop: sets off the white "paper", like a PDF reader */
  padding: 20px 0;
}

/* ── Paper: body's first-level table is the WML's 750px frame ── */
body > table {
  background: #ffffff;
  /* @@@ Width is now driven by paper size + orientation, overriding
     the WML-hardcoded width="750". box-sizing must include padding,
     otherwise the 22px left/right padding would push the paper wider
     than the intended width. */
  width: ${pageWidthPx.toStringAsFixed(0)}px;
  max-width: 100%;
  box-sizing: border-box;
  margin: 0 auto 20px auto;       /* centered; gap between multiple pages */
  padding: 8px 16px 10px 16px;            /* smaller top padding so the header isn't too far from the top edge */
  box-shadow: 0 1px 3px rgba(0,0,0,.10); border: 1px solid #E8E7E1;
  border-collapse: separate;
}

/* @@@ 2026-08-10 added: some WML content prints an extra trailing block
   after the paper container's (outer </table>'s) closing tag (e.g. a
   page-number row) -- CSS can't "move it back" inside the container, so
   this only achieves a visual stitch: the paper itself drops its bottom
   rounded corners/shadow/border, and this trailing block gets the same
   white background, width, shadow, and border, so the seam is invisible
   and it reads as a continuation of the same sheet.
   :has() is supported by modern browsers (Chrome/Edge 105+, Safari 15.4+). */
body > table:has(+ p:last-child) {
  margin-bottom: 0;
  border-bottom: none;
  box-shadow: 0 -1px 3px rgba(0,0,0,.10);   /* shadow kept only on the left/top/right sides -- the bottom edge is handed off to the trailing block */
}
body > table + p:last-child {
  width: ${pageWidthPx.toStringAsFixed(0)}px;
  max-width: 100%;
  box-sizing: border-box;
  margin: 0 auto 20px auto;
  padding: 4px 16px 10px 16px;
  background: #ffffff;
  border: 1px solid #E8E7E1;
  border-top: none;
  box-shadow: 0 1px 3px rgba(0,0,0,.10);
}
/* Tables inside the paper: fill the width, no extra spacing */
body > table table { width: 100%; border-collapse: collapse; }
body > table > tbody > tr > td { padding: 0; border: 0; }

/* ── Header (company name / report title) ── */
big {
  font-size: 1.35em;
  font-weight: 700;
  letter-spacing: 1px;
  color: #1a1a18;
  display: block;
  line-height: 1.4;
}

/* ── Header block (company name / title / page number / date) ──
   WML structure: paper (750px table) > td > [header table] + [detail table]
   The header is the "first nested table". If its <td> inherits the
   detail table's padding/underline, plus the default top/bottom
   margin on <p>, the header ends up stretched far too tall. This
   collapses that precisely. */
p { margin: 0; padding: 0; }
body > table td > table:first-of-type td { /* @@@ allow an extra nesting level in case the WML brings its own centering frame */
  border-bottom: 0;
  padding: 1px 4px;
  font-size: 12.3px;
  color: #5F5E5A;
}

/* ── Column headers: dark background, white text (WML's <tr class="row"><th>) ── */
th {
  background: #D0CFC9;
  color: #2C2C2A;
  font-weight: 600;
  font-size: 13.3px;
  padding: 4px;               /* @@@ 2026-08-10: reduced to fit short paper sizes (e.g. 8.5x5.5) and avoid content overflowing the page */
  text-align: center;
  white-space: normal; /* @@@ allow narrow column headers to wrap */
  word-break: break-word;
}
tr.row th { background: #D0CFC9; color: #2C2C2A; }
tr.row    { background: transparent; }   /* prevent .row's background from covering the header */

/* @@@ Data tables use a fixed layout so <th width>/column widths are strictly honored */
body > table td > table:not(:first-of-type) { table-layout: fixed; width: 100%; margin-top: 6px; }

/* ── Detail cells: thin underline as a separator ── */
td {
  padding: 4px;               /* @@@ 2026-08-10: reduced to fit short paper sizes (e.g. 8.5x5.5) and avoid content overflowing the page */
  font-size: 13.3px;
  font-weight: 500;          /* @@@ slightly bolder: crisper when printed */
  color: #2C2C2A;
  border-bottom: 1px solid #E8E7E1;
  vertical-align: top;
}

/* ── Group header row (the exporter adds class="grp" to this <tr>) ── */
tr.grp td {
  background: #EDEAE3;
  font-weight: 700;
  color: #185FA5;
  padding: 5px 5px;
}

/* ── Sub-report row (the exporter adds class="sub" to this <tr>) ── */
tr.sub td {
  background: #FAFAF8;
  font-size: 12.3px;
  color: #5F5E5A;
  padding: 3px 5px;
}
tr.sub td:first-child { padding-left: 22px; }   /* indent: visually subordinate to the row above */

/* ── WML's existing zebra-stripe classes (carried over from wapform.htm) ── */
.row1 { background: ${WapColors.hexTrRow1}; }
.row2 { background: ${WapColors.hexTrRow2}; }

/* @@@ 2026-08-10 added: reports without an explicit class="row1"/"row2"
   (e.g. a hand-written-function report, emitting <tr> directly via
   <function> with no WML-computed ROWIDX mod 2) still need zebra striping,
   without forcing every report's WML to compute it itself -- auto-detected
   via :nth-child. :not(...) excludes <tr>s that already carry one of the
   existing row/row1/row2/grp/sub classes, to avoid conflicting with logic
   the WML already computed itself (e.g. a record spanning two rows). */
body > table td > table:not(:first-of-type) tr:not(.row):not(.row1):not(.row2):not(.grp):not(.sub):not([height]):nth-child(even) td {
  background: ${WapColors.hexTrRow2};
}

/* zz ### flutter extension */
''';

// Compact style for the demo card (_SrcReport)
/// CSS for printing an HTML ([WapPage.src]) card on [pageSize] paper.
String reportCssSrc(String pageSize) => '''
  @media print { @page { size: $pageSize; margin: 12mm; } }
  body { font-family: sans-serif; font-size: 13.3px; margin: 16px; }
  pre  { font-family: monospace; white-space: pre-wrap; }
''';
