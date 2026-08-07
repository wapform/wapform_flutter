// ═════════════════════════════════════════════════════════════════════════════
//  lazarus_extctrls.dart
//
//  This file is a Dart translation (derivative work) of the following
//  Object Pascal upstream source:
//    Upstream project: Lazarus Component Library (LCL)
//    Upstream file: extctrls.pp (1,803 lines, interface-aligned, not a line-by-line translation)
//    Upstream initial version: Sat Jul 26 12:04:35 PDT 1999
//
//  Upstream copyright:
//   Copyright (c) 1999-2024 by the Lazarus Development Team
//
//  License: GNU Lesser General Public License v2.1, with the static
//  linking exception (Modified LGPL, same as upstream FPC/Lazarus).
//  See the accompanying COPYING.LGPL.txt and COPYING.modifiedLGPL.txt.
//
//  Modification notice (required by LGPL section 2):
//    This file is a language translation from Object Pascal to Dart, with
//    adjustments for the Flutter platform. Every place that deviates from
//    upstream is marked with a block tag:
//      // aa !!! not fully translated — upstream source unavailable, or
//                the platform fundamentally can't do this
//      // aa ??? issue          —— deviates from upstream behavior to fix a defect
//      // aa ### flutter extension —— a feature added for Flutter that upstream doesn't have
//
//  Translation: Copyright (c) 2026 (your name or organization)
// ═════════════════════════════════════════════════════════════════════════════

// ═════════════════════════════════════════════════════════════════════════════
//  lazarus_extctrls.dart —— Flutter port of FPC/LCL extctrls.pp (community edition)
//  ─────────────────────────────────────────────────────────────────────────
//  Same translation approach as stdctrls / dbctrls: 【enums / core
//  properties / events kept faithfully, using LCL naming】, 【painting and
//  messaging reimplemented with Flutter widgets】.
//
//  Ported:
//    TRadioGroup / TCheckGroup  —— option groups (Columns / ColumnLayout)
//    TPanel                      —— container (Caption / Alignment / Bevel)
//    TBevel                      —— dividing lines and frames
//    TShape                      —— geometric shapes (CustomPainter)
//    TImage                      —— images (Stretch / Proportional / Center)
//    TTimer / TIdleTimer         —— timers
//    TLabeledEdit                —— a labeled input field
//    TFlowPanel                  —— a flow-layout container
//    TSplitter                   —— a draggable divider
//
// aa !!! not fully translated
//  1. This file 【as a whole】 is not a line-by-line translation, but a
//     "behavior-aligned rewrite". LCL controls are built on Win32/GTK
//     native widgets and a self-painting model; Flutter's widget tree is
//     a different architecture.
//     LCL's "interface contract" (class names, property names, event
//     names) is kept, while the internals are reimplemented with
//     Flutter's Material components. The goal is behavioral
//     compatibility, not identical implementation.
//  2. The following upstream classes 【were not ported】, because they
//     have no Flutter equivalent or require TCanvas:
//     TPaintBox (needs TCanvas self-painting), TTrayIcon (desktop system
//     tray), TControlBar / TCtrlBand (draggable toolbar bands),
//     TNotebook / TPage (LCL's old-style tab pages; WapForm's
//     <pagecontrol> takes a different route), TBoundLabel (folded into
//     TLabeledEdit). Add these later using the same pattern if needed.
//  3. Appearance-related properties (Anchors / BorderSpacing /
//     ChildSizing / BiDiMode / DoubleBuffered / ParentColor /
//     DragCursor…) have no direct Flutter equivalent and are omitted.
//  4. Mouse events: only OnClick is kept; OnMouseDown/Move/Up/Wheel/
//     Enter/Leave were not ported.
//  5. AutoFill / ChildSizing (used by LCL to make buttons etc. within a
//     group share equal width) was not ported; IntrinsicWidth is used
//     here instead, so each option just takes its own natural width.
// zz !!! not fully translated
//
//  Depends on: flutter/material, dart:math, dart:async,
//        lazarus_stdctrls.dart (TRadioButton / TCheckBox),
//        lazarus_db.dart (TAlignment shim)
// ═════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

// @@@ Each button inside a group uses stdctrls' existing components
//     directly (in LCL, what TCustomRadioGroup / TCustomCheckGroup manage
//     internally is exactly a set of TRadioButton / TCheckBox — they
//     don't paint their own circles and boxes).
import 'lazarus_stdctrls.dart' show TRadioButton, TCheckBox;
import 'lazarus_db.dart' show TAlignment;

// ─────────────────────────────────────────────────────────────────────────────
//  Enums (correspond to the same-named types in extctrls.pp)
// ─────────────────────────────────────────────────────────────────────────────

/// TColumnLayout (extctrls.pp:712) — the arrangement order of options within a group
enum TColumnLayout {
  clHorizontalThenVertical, // fill a row left-to-right before moving to the next row (LCL default)
  clVerticalThenHorizontal, // fill a column top-to-bottom before moving to the next column
}

/// TShapeType (extctrls.pp:266)
enum TShapeType {
  stRectangle,
  stSquare,
  stRoundRect,
  stRoundSquare,
  stEllipse,
  stCircle,
  stSquaredDiamond,
  stDiamond,
  stTriangle,
  stTriangleLeft,
  stTriangleRight,
  stTriangleDown,
  stStar,
  stStarDown,
  stPolygon,
}

/// TBevelShape (extctrls.pp:669)
enum TBevelShape {
  bsBox,
  bsFrame,
  bsTopLine,
  bsBottomLine,
  bsLeftLine,
  bsRightLine,
  bsSpacer,
}

/// TBevelStyle (extctrls.pp:668)
enum TBevelStyle { bsLowered, bsRaised }

/// TPanelBevel = TBevelCut (extctrls.pp:1120; type originally in the Graphics unit)
enum TPanelBevel { bvNone, bvLowered, bvRaised, bvSpace }

/// TLabelPosition (extctrls.pp:1022)
enum TLabelPosition { lpAbove, lpBelow, lpLeft, lpRight }

/// TVerticalAlignment (used by TCustomPanel.VerticalAlignment; type originally in Classes)
enum TVerticalAlignment { taAlignTop, taAlignBottom, taVerticalCenter }

/// TFlowStyle (used by TCustomFlowPanel.FlowStyle)
enum TFlowStyle {
  fsLeftRightTopBottom,
  fsRightLeftTopBottom,
  fsTopBottomLeftRight,
  fsBottomTopLeftRight,
}

/// TCheckGroupClicked (extctrls.pp:852)
typedef TCheckGroupClicked = void Function(Object sender, int index);

// ─────────────────────────────────────────────────────────────────────────────
//  Shared: group frame (corresponds to TCustomGroupBox — the parent class
//  of RadioGroup / CheckGroup). No frame is drawn when Caption is empty;
//  just the content is returned.
// ─────────────────────────────────────────────────────────────────────────────
Widget _groupFrame({
  required String caption,
  required Widget child,
  double? width,
  double? height,
}) {
  Widget body = child;
  if (caption.isNotEmpty) {
    body = Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(caption,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
          body,
        ],
      ),
    );
  }
// aa ### flutter extension
  // WML/LCL supply width/height (in pixels). Here they're treated as a
  // "minimum size" rather than a hard clip: forcing a fixed height in
  // Flutter easily causes options to get cut off or triggers an
  // overflow, especially since Chinese text tends to be taller than LCL
  // assumes.
  if (width != null || height != null) {
    body = ConstrainedBox(
      constraints: BoxConstraints(minWidth: width ?? 0, minHeight: height ?? 0),
      child: body,
    );
  }
// zz ### flutter extension
  return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: body);
}

/// Arranges cells into a grid according to Columns / ColumnLayout.
/// LCL's Columns is a "column count":
///   clHorizontalThenVertical → fills row by row (0,1 / 2,3)
///   clVerticalThenHorizontal → fills column by column (0,2 / 1,3)
Widget _layoutCells(List<Widget> cells, int columns, TColumnLayout layout) {
  final cols = columns < 1 ? 1 : columns;
  final n = cells.length;
  final rowCount = (n + cols - 1) ~/ cols;
  final rows = <Widget>[];

  for (var r = 0; r < rowCount; r++) {
    final rowCells = <Widget>[];
    for (var c = 0; c < cols; c++) {
      final int idx = (layout == TColumnLayout.clHorizontalThenVertical)
          ? r * cols + c
          : c * rowCount + r; // fill column by column: the r-th item of column c
      if (idx >= n) continue;
      if (rowCells.isNotEmpty) rowCells.add(const SizedBox(width: 12));
      rowCells.add(cells[idx]);
    }
    if (rowCells.isEmpty) continue;
    rows.add(Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rowCells,
    ));
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: rows,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  TCustomRadioGroup / TRadioGroup (extctrls.pp:717 / 787)
//
//  Core properties: Caption / Items / ItemIndex / Columns / ColumnLayout /
//                 Enabled / OnClick / OnSelectionChanged.
//
//  WapForm's <select title= columns=><option>…</option></select> maps to
//  this: title → Caption, columns → Columns, option → Items.
//  (HTML's <select> has no Columns attribute — the fact that this one
//  does is exactly why it's really a TRadioGroup underneath.)
// ─────────────────────────────────────────────────────────────────────────────
class TRadioGroup extends StatelessWidget {
  final String caption; // Caption
  final List<String> items; // Items
  final int itemIndex; // ItemIndex (-1 = none selected)
  final int columns; // Columns
  final TColumnLayout columnLayout; // ColumnLayout
  final bool enabled; // Enabled
  final bool readOnly; // visible but not changeable
  final void Function(int index)? onSelectionChanged; // OnSelectionChanged
  final void Function(int index)? onClick; // OnClick
  final double? width;
  final double? height;
  final TextStyle? font; // Font

  const TRadioGroup({
    super.key,
    this.caption = '',
    required this.items,
    this.itemIndex = -1,
    this.columns = 1,
    this.columnLayout = TColumnLayout.clHorizontalThenVertical,
    this.enabled = true,
    this.readOnly = false,
    this.onSelectionChanged,
    this.onClick,
    this.width,
    this.height,
    this.font,
  });

  bool get _canPick => enabled && !readOnly;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final style = font ?? const TextStyle(fontSize: 13);

    final cells = <Widget>[
      for (var i = 0; i < items.length; i++)
        // IntrinsicWidth: each option only takes the width it needs, so
        // the columns line up neatly
        IntrinsicWidth(
          child: TRadioButton<int>(
            caption: items[i],
            value: i,
            groupValue: itemIndex,
            // @@@ LCL semantics: only Enabled=False grays it out; ReadOnly
            //     looks normal but can't be changed. So `enabled` only
            //     drives the visual `enabled`, and whether it's actually
            //     changeable depends on whether onChange is attached.
            enabled: enabled,
            dense: true,
            font: style,
            onChange: _canPick
                ? (v) {
                    onSelectionChanged?.call(v);
                    onClick?.call(v);
                  }
                : null,
          ),
        ),
    ];

    return _groupFrame(
      caption: caption,
      width: width,
      height: height,
      child: _layoutCells(cells, columns, columnLayout),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TCustomCheckGroup / TCheckGroup (extctrls.pp:854 / 913)
//
//  Core properties: Caption / Items / Checked[] / CheckEnabled[] / Columns /
//                 ColumnLayout / OnItemClick.
//  Difference from RadioGroup: multi-select allowed, state is a set of
//  bools rather than a single ItemIndex.
// ─────────────────────────────────────────────────────────────────────────────
class TCheckGroup extends StatelessWidget {
  final String caption; // Caption
  final List<String> items; // Items
  final List<bool> checked; // Checked[Index]
  final List<bool>? checkEnabled; // CheckEnabled[Index] (null = all enabled)
  final int columns; // Columns
  final TColumnLayout columnLayout; // ColumnLayout
  final bool enabled; // Enabled
  final TCheckGroupClicked? onItemClick; // OnItemClick(Sender, Index)
  final double? width;
  final double? height;
  final TextStyle? font;

  const TCheckGroup({
    super.key,
    this.caption = '',
    required this.items,
    required this.checked,
    this.checkEnabled,
    this.columns = 1,
    this.columnLayout = TColumnLayout.clHorizontalThenVertical,
    this.enabled = true,
    this.onItemClick,
    this.width,
    this.height,
    this.font,
  });

  bool _itemEnabled(int i) {
    if (!enabled) return false;
    final ce = checkEnabled;
    if (ce == null || i >= ce.length) return true;
    return ce[i];
  }

  bool _isChecked(int i) => i < checked.length && checked[i];

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final style = font ?? const TextStyle(fontSize: 13);

    final cells = <Widget>[
      for (var i = 0; i < items.length; i++)
        IntrinsicWidth(
          child: TCheckBox(
            // @@@ ValueKey: TCheckBox has its own internal _value state,
            //     so when `checked` changes, without a key Flutter would
            //     reuse the old State and an externally-changed value
            //     wouldn't show up.
            key: ValueKey('$i:${_isChecked(i)}'),
            caption: items[i],
            checked: _isChecked(i),
            enabled: _itemEnabled(i),
            font: style,
            dense: true,
            onChange: _itemEnabled(i) ? (_) => onItemClick?.call(this, i) : null,
          ),
        ),
    ];

    return _groupFrame(
      caption: caption,
      width: width,
      height: height,
      child: _layoutCells(cells, columns, columnLayout),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TCustomPanel / TPanel (extctrls.pp:1123 / 1174)
//
//  Core properties: Caption / Alignment / VerticalAlignment / WordWrap /
//                 BevelInner / BevelOuter / BevelWidth / BevelColor / Color.
// ─────────────────────────────────────────────────────────────────────────────
class TPanel extends StatelessWidget {
  final String caption; // Caption
  final Widget? child; // child control
  final TAlignment alignment; // Alignment (LCL default: taCenter)
  final TVerticalAlignment verticalAlignment; // VerticalAlignment
  final bool wordWrap; // WordWrap
  final TPanelBevel bevelInner; // BevelInner (default bvNone)
  final TPanelBevel bevelOuter; // BevelOuter (default bvRaised)
  final double bevelWidth; // BevelWidth (default 1)
  final Color? bevelColor; // BevelColor
  final Color? color; // Color
  final double? width;
  final double? height;
  final TextStyle? font;
  final VoidCallback? onClick; // OnClick

  const TPanel({
    super.key,
    this.caption = '',
    this.child,
    this.alignment = TAlignment.taCenter,
    this.verticalAlignment = TVerticalAlignment.taVerticalCenter,
    this.wordWrap = false,
    this.bevelInner = TPanelBevel.bvNone,
    this.bevelOuter = TPanelBevel.bvRaised,
    this.bevelWidth = 1,
    this.bevelColor,
    this.color,
    this.width,
    this.height,
    this.font,
    this.onClick,
  });

  // bvRaised / bvLowered are 3D beveled borders in LCL. Flutter's
  // Material has no equivalent visual vocabulary; approximated here with
  // "light/dark two-tone borders": raised = light top-left, dark
  // bottom-right, lowered is the reverse.
  BoxDecoration? _bevel(TPanelBevel b) {
    if (b == TPanelBevel.bvNone || b == TPanelBevel.bvSpace) return null;
    final light = bevelColor ?? Colors.white;
    final dark = bevelColor ?? Colors.grey.shade600;
    final raised = b == TPanelBevel.bvRaised;
    return BoxDecoration(
      border: Border(
        top: BorderSide(color: raised ? light : dark, width: bevelWidth),
        left: BorderSide(color: raised ? light : dark, width: bevelWidth),
        bottom: BorderSide(color: raised ? dark : light, width: bevelWidth),
        right: BorderSide(color: raised ? dark : light, width: bevelWidth),
      ),
    );
  }

  Alignment get _align {
    final double x;
    switch (alignment) {
      case TAlignment.taLeftJustify:
        x = -1.0;
      case TAlignment.taRightJustify:
        x = 1.0;
      case TAlignment.taCenter:
        x = 0.0;
    }
    final double y;
    switch (verticalAlignment) {
      case TVerticalAlignment.taAlignTop:
        y = -1.0;
      case TVerticalAlignment.taAlignBottom:
        y = 1.0;
      case TVerticalAlignment.taVerticalCenter:
        y = 0.0;
    }
    return Alignment(x, y);
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (child != null) {
      content = child!;
    } else if (caption.isNotEmpty) {
      content = Text(
        caption,
        style: font,
        softWrap: wordWrap,
        overflow: wordWrap ? TextOverflow.clip : TextOverflow.ellipsis,
      );
    } else {
      content = const SizedBox.shrink();
    }

    Widget body = Align(alignment: _align, child: content);

    final inner = _bevel(bevelInner);
    if (inner != null) {
      body = DecoratedBox(decoration: inner, child: body);
    }

    body = Container(
      width: width,
      height: height,
      color: color,
      child: body,
    );

    final outer = _bevel(bevelOuter);
    if (outer != null) {
      body = DecoratedBox(decoration: outer, child: body);
    }

    if (onClick != null) {
      body = GestureDetector(onTap: onClick, child: body);
    }
    return body;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TBevel (extctrls.pp:671)
//
//  Core properties: Shape / Style. Purely decorative, no child control.
// ─────────────────────────────────────────────────────────────────────────────
class TBevel extends StatelessWidget {
  final TBevelShape shape; // Shape (default bsBox)
  final TBevelStyle style; // Style (default bsLowered)
  final double? width;
  final double? height;

  const TBevel({
    super.key,
    this.shape = TBevelShape.bsBox,
    this.style = TBevelStyle.bsLowered,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // bsSpacer just occupies space, nothing is drawn
    if (shape == TBevelShape.bsSpacer) {
      return SizedBox(width: width, height: height);
    }
    final lowered = style == TBevelStyle.bsLowered;
    final c = lowered ? Colors.grey.shade500 : Colors.white;
    final side = BorderSide(color: c, width: 1);

    Border border;
    switch (shape) {
      case TBevelShape.bsBox:
      case TBevelShape.bsFrame:
        border = Border.all(color: c, width: 1);
      case TBevelShape.bsTopLine:
        border = Border(top: side);
      case TBevelShape.bsBottomLine:
        border = Border(bottom: side);
      case TBevelShape.bsLeftLine:
        border = Border(left: side);
      case TBevelShape.bsRightLine:
        border = Border(right: side);
      case TBevelShape.bsSpacer:
        border = const Border();
    }
    // Line shapes (not Box/Frame) get 1px if no height is given, otherwise there's nothing to stretch
    final isLine = shape != TBevelShape.bsBox && shape != TBevelShape.bsFrame;
    return Container(
      width: width,
      height: height ?? (isLine ? 1 : null),
      decoration: BoxDecoration(border: border),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TShape (extctrls.pp:306)
//
//  Core properties: Shape / Brush (fill) / Pen (outline).
//  Drawn with a CustomPainter, corresponding to LCL's TCanvas painting.
// ─────────────────────────────────────────────────────────────────────────────
class TShape extends StatelessWidget {
  final TShapeType shape; // Shape (default stRectangle)
  final Color brushColor; // Brush.Color
  final Color penColor; // Pen.Color
  final double penWidth; // Pen.Width
  final double? width;
  final double? height;

  const TShape({
    super.key,
    this.shape = TShapeType.stRectangle,
    this.brushColor = Colors.white,
    this.penColor = Colors.black,
    this.penWidth = 1,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 65, // LCL's TShape defaults to 65×65
      height: height ?? 65,
      child: CustomPaint(
        painter: _ShapePainter(shape, brushColor, penColor, penWidth),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final TShapeType shape;
  final Color brush;
  final Color pen;
  final double penW;

  _ShapePainter(this.shape, this.brush, this.pen, this.penW);

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = brush
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = pen
      ..style = PaintingStyle.stroke
      ..strokeWidth = penW;

    // "Regular" shapes (Square / Circle / RoundSquare / SquaredDiamond)
    // are centered on the shorter side
    final sq = math.min(size.width, size.height);
    Rect r = Offset.zero & size;
    switch (shape) {
      case TShapeType.stSquare:
      case TShapeType.stCircle:
      case TShapeType.stRoundSquare:
      case TShapeType.stSquaredDiamond:
        r = Rect.fromCenter(
            center: size.center(Offset.zero), width: sq, height: sq);
      default:
        break;
    }
    r = r.deflate(penW / 2);

    Path path = Path();
    switch (shape) {
      case TShapeType.stRectangle:
      case TShapeType.stSquare:
        path.addRect(r);
      case TShapeType.stRoundRect:
      case TShapeType.stRoundSquare:
        path.addRRect(RRect.fromRectXY(r, r.width / 8, r.height / 8));
      case TShapeType.stEllipse:
      case TShapeType.stCircle:
        path.addOval(r);
      case TShapeType.stDiamond:
      case TShapeType.stSquaredDiamond:
        path.addPolygon([
          Offset(r.center.dx, r.top),
          Offset(r.right, r.center.dy),
          Offset(r.center.dx, r.bottom),
          Offset(r.left, r.center.dy),
        ], true);
      case TShapeType.stTriangle:
        path.addPolygon([
          Offset(r.center.dx, r.top),
          Offset(r.right, r.bottom),
          Offset(r.left, r.bottom),
        ], true);
      case TShapeType.stTriangleDown:
        path.addPolygon([
          Offset(r.left, r.top),
          Offset(r.right, r.top),
          Offset(r.center.dx, r.bottom),
        ], true);
      case TShapeType.stTriangleLeft:
        path.addPolygon([
          Offset(r.right, r.top),
          Offset(r.right, r.bottom),
          Offset(r.left, r.center.dy),
        ], true);
      case TShapeType.stTriangleRight:
        path.addPolygon([
          Offset(r.left, r.top),
          Offset(r.left, r.bottom),
          Offset(r.right, r.center.dy),
        ], true);
      case TShapeType.stStar:
        path = _star(r, down: false);
      case TShapeType.stStarDown:
        path = _star(r, down: true);
      case TShapeType.stPolygon:
// aa !!! not fully translated
        // Upstream lets you customize the point set via the
        // OnShapePoints event; that event doesn't exist here, so a
        // regular hexagon is drawn unconditionally.
        path = _regular(r, 6);
// zz !!! not fully translated
    }
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  Path _regular(Rect r, int n) {
    final p = Path();
    final rad = math.min(r.width, r.height) / 2;
    for (var i = 0; i < n; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / n;
      final x = r.center.dx + rad * math.cos(a);
      final y = r.center.dy + rad * math.sin(a);
      i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
    }
    p.close();
    return p;
  }

  Path _star(Rect r, {bool down = false}) {
    final p = Path();
    final outer = math.min(r.width, r.height) / 2;
    final inner = outer * 0.382; // inner/outer radius ratio for a regular five-pointed star
    for (var i = 0; i < 10; i++) {
      final rad = i.isEven ? outer : inner;
      var a = -math.pi / 2 + i * math.pi / 5;
      if (down) a += math.pi;
      final x = r.center.dx + rad * math.cos(a);
      final y = r.center.dy + rad * math.sin(a);
      i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
    }
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant _ShapePainter old) =>
      old.shape != shape ||
      old.brush != brush ||
      old.pen != pen ||
      old.penW != penW;
}

// ─────────────────────────────────────────────────────────────────────────────
//  TImage (extctrls.pp:612)
//
//  Core properties: Picture / Stretch / Proportional / Center / Transparent.
// aa !!! not fully translated
//  Upstream's Picture is a TPicture (loadable from a file/resource/
//  clipboard, and exposes a Canvas for custom drawing). Flutter has no
//  equivalent, so this takes an ImageProvider instead — the caller
//  decides the source using AssetImage / NetworkImage / MemoryImage.
//  Images / ImageIndex (TImageList) and Canvas were not ported.
// zz !!! not fully translated
// ─────────────────────────────────────────────────────────────────────────────
class TImage extends StatelessWidget {
  final ImageProvider? picture; // Picture
  final bool stretch; // Stretch
  final bool proportional; // Proportional
  final bool center; // Center
  final bool transparent; // Transparent
  final double? width;
  final double? height;
  final VoidCallback? onClick; // OnClick

  const TImage({
    super.key,
    this.picture,
    this.stretch = false,
    this.proportional = false,
    this.center = false,
    this.transparent = false,
    this.width,
    this.height,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    if (picture == null) return SizedBox(width: width, height: height);
    // LCL's combined semantics:
    //   Stretch + Proportional → scale proportionally to fill (contain)
    //   Stretch only          → stretch to fill regardless of aspect ratio (fill)
    //   Proportional only     → shrink only, never enlarge (scaleDown)
    //   neither                → original size (none); Center decides whether it's centered
    final BoxFit fit;
    if (stretch && proportional) {
      fit = BoxFit.contain;
    } else if (stretch) {
      fit = BoxFit.fill;
    } else if (proportional) {
      fit = BoxFit.scaleDown;
    } else {
      fit = BoxFit.none;
    }
    Widget img = Image(
      image: picture!,
      width: width,
      height: height,
      fit: fit,
      alignment: center ? Alignment.center : Alignment.topLeft,
    );
    if (onClick != null) {
      img = GestureDetector(onTap: onClick, child: img);
    }
    return img;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TTimer (extctrls.pp:195)
//
//  Core properties: Enabled / Interval / OnTimer / OnStartTimer / OnStopTimer.
// aa ### flutter extension
//  LCL's TTimer is a non-visual component (placed on a Form without
//  taking up layout space). Flutter has no concept of a "non-visual
//  widget", so this is built as a StatefulWidget that wraps a child; the
//  timer is created/disposed along with the widget's lifecycle. If no
//  child is given it returns a zero-size SizedBox.
// zz ### flutter extension
// ─────────────────────────────────────────────────────────────────────────────
class TTimer extends StatefulWidget {
  final bool enabled; // Enabled
  final int interval; // Interval (milliseconds; LCL default 1000)
  final VoidCallback? onTimer; // OnTimer
  final VoidCallback? onStartTimer; // OnStartTimer
  final VoidCallback? onStopTimer; // OnStopTimer
  final Widget? child;

  const TTimer({
    super.key,
    this.enabled = true,
    this.interval = 1000,
    this.onTimer,
    this.onStartTimer,
    this.onStopTimer,
    this.child,
  });

  @override
  State<TTimer> createState() => _TTimerState();
}

class _TTimerState extends State<TTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    if (!widget.enabled || widget.interval <= 0) return;
    widget.onStartTimer?.call();
    _timer = Timer.periodic(
        Duration(milliseconds: widget.interval), (_) => widget.onTimer?.call());
  }

  void _stop() {
    if (_timer == null) return;
    _timer!.cancel();
    _timer = null;
    widget.onStopTimer?.call();
  }

  @override
  void didUpdateWidget(covariant TTimer old) {
    super.didUpdateWidget(old);
    if (old.enabled != widget.enabled || old.interval != widget.interval) {
      _stop();
      _start();
    }
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child ?? const SizedBox.shrink();
}

// ─────────────────────────────────────────────────────────────────────────────
//  TIdleTimer (extctrls.pp:252) —— fires only after being idle for a
//  while; any activity resets the countdown.
// aa !!! not fully translated
//  Upstream's AutoEnabled / AutoStartEvent / AutoEndEvent hook into LCL's
//  Application.OnIdle; Flutter has no equivalent event. Instead: the
//  wrapped child resets the countdown whenever it receives a pointer
//  event, or TIdleTimerState's poke() can be called manually.
// zz !!! not fully translated
// ─────────────────────────────────────────────────────────────────────────────
class TIdleTimer extends StatefulWidget {
  final bool enabled;
  final int interval; // how long idle before firing (milliseconds)
  final VoidCallback? onTimer;
  final Widget? child;

  const TIdleTimer({
    super.key,
    this.enabled = true,
    this.interval = 1000,
    this.onTimer,
    this.child,
  });

  @override
  State<TIdleTimer> createState() => TIdleTimerState();
}

class TIdleTimerState extends State<TIdleTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    poke();
  }

  /// Activity → reset the countdown (corresponds to upstream's definition of "idle")
  void poke() {
    _timer?.cancel();
    if (!widget.enabled || widget.interval <= 0) return;
    _timer = Timer(
        Duration(milliseconds: widget.interval), () => widget.onTimer?.call());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (_) => poke(),
        child: widget.child ?? const SizedBox.shrink(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  TLabeledEdit (extctrls.pp:1054)
//
//  Core properties: EditLabel (TBoundLabel) / LabelPosition / LabelSpacing.
//  Upstream's EditLabel is a separate TBoundLabel component; simplified
//  here to a caption string (TBoundLabel was not ported separately — see
//  the file header note).
// ─────────────────────────────────────────────────────────────────────────────
class TLabeledEdit extends StatelessWidget {
  final String editLabel; // EditLabel.Caption
  final TLabelPosition labelPosition; // LabelPosition (LCL default lpAbove)
  final double labelSpacing; // LabelSpacing (LCL default 3)
  final Widget edit; // the actual input field (usually stdctrls' TEdit)
  final TextStyle? font;

  const TLabeledEdit({
    super.key,
    required this.editLabel,
    required this.edit,
    this.labelPosition = TLabelPosition.lpAbove,
    this.labelSpacing = 3,
    this.font,
  });

  @override
  Widget build(BuildContext context) {
    final lab = Text(editLabel, style: font);
    final gapH = SizedBox(width: labelSpacing);
    final gapV = SizedBox(height: labelSpacing);
    switch (labelPosition) {
      case TLabelPosition.lpAbove:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [lab, gapV, edit],
        );
      case TLabelPosition.lpBelow:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [edit, gapV, lab],
        );
      case TLabelPosition.lpLeft:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [lab, gapH, Flexible(child: edit)],
        );
      case TLabelPosition.lpRight:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [Flexible(child: edit), gapH, lab],
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TFlowPanel (extctrls.pp:1339)
//
//  Core properties: ControlList / FlowStyle / AutoWrap.
//  Flutter's Wrap maps onto this perfectly.
// ─────────────────────────────────────────────────────────────────────────────
class TFlowPanel extends StatelessWidget {
  final List<Widget> controlList; // ControlList
  final TFlowStyle flowStyle; // FlowStyle
  final bool autoWrap; // AutoWrap
  final double spacing;
  final double runSpacing;
  final Color? color;
  final double? width;
  final double? height;

  const TFlowPanel({
    super.key,
    required this.controlList,
    this.flowStyle = TFlowStyle.fsLeftRightTopBottom,
    this.autoWrap = true,
    this.spacing = 4,
    this.runSpacing = 4,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final vertical = flowStyle == TFlowStyle.fsTopBottomLeftRight ||
        flowStyle == TFlowStyle.fsBottomTopLeftRight;
    final reverse = flowStyle == TFlowStyle.fsRightLeftTopBottom ||
        flowStyle == TFlowStyle.fsBottomTopLeftRight;
    final kids = reverse ? controlList.reversed.toList() : controlList;

    Widget body;
    if (autoWrap) {
      body = Wrap(
        direction: vertical ? Axis.vertical : Axis.horizontal,
        spacing: spacing,
        runSpacing: runSpacing,
        children: kids,
      );
    } else {
      body = vertical
          ? Column(mainAxisSize: MainAxisSize.min, children: kids)
          : Row(mainAxisSize: MainAxisSize.min, children: kids);
    }
    return Container(width: width, height: height, color: color, child: body);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TSplitter (extctrls.pp:437)
//
//  Core properties: ResizeStyle / MinSize / Beveled / OnMoved.
// aa !!! not fully translated
//  Upstream's Splitter directly modifies the Width/Height of adjacent
//  controls. In Flutter, size is determined by the parent's state — a
//  widget can't reach into a sibling node and change it. So this only
//  reports the "drag delta"; the actual size is owned by the caller,
//  which calls setState. ResizeStyle / MinSize therefore don't apply.
// zz !!! not fully translated
// ─────────────────────────────────────────────────────────────────────────────
class TSplitter extends StatelessWidget {
  final Axis axis; // a vertical bar (dragged left/right) or a horizontal bar (dragged up/down)
  final double thickness; // divider thickness
  final bool beveled; // Beveled
  final void Function(double delta)? onMoved; // OnMoved (drag delta, in pixels)

  const TSplitter({
    super.key,
    this.axis = Axis.vertical,
    this.thickness = 5,
    this.beveled = true,
    this.onMoved,
  });

  @override
  Widget build(BuildContext context) {
    final vertical = axis == Axis.vertical; // vertical bar → dragged left/right
    final bar = Container(
      width: vertical ? thickness : null,
      height: vertical ? null : thickness,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border:
            beveled ? Border.all(color: Colors.grey.shade500, width: 0.5) : null,
      ),
    );
    return MouseRegion(
      cursor: vertical
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate:
            vertical ? (d) => onMoved?.call(d.delta.dx) : null,
        onVerticalDragUpdate: vertical ? null : (d) => onMoved?.call(d.delta.dy),
        child: bar,
      ),
    );
  }
}
