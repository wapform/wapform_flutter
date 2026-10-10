// ═════════════════════════════════════════════════════════════════════════════
//  lazarus_grids.dart
//
//  This file is a Dart translation (derivative work) of the following
//  Object Pascal upstream source:
//    Upstream project: Lazarus Component Library (LCL)
//    Upstream file: grids.pas
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
//  Translation: Copyright (c) 2026 Minhong Information Co., Ltd. (wapform.com)
// ═════════════════════════════════════════════════════════════════════════════

// ═════════════════════════════════════════════════════════════════════════════
//  lazarus_grids.dart —— translation of the "column model" subset of
//  FPC/LCL grids.pas
//  ─────────────────────────────────────────────────────────────────────────
//  Corresponds to: grids.pas (LCL, 13,967 lines)
//
//  ⚠ Scope decision for this translation (per the user's direction of
//    "behavioral equivalence"):
//    grids.pas's TCustomGrid is a TCustomControl subclass — a pure LCL GUI
//    widget that paints cell-by-cell via Canvas and handles mouse/keyboard
//    through Win32 LM_/WM_ messages. Flutter has no equivalent
//    infrastructure, so translating that 13,000-line window-skeleton
//    line-by-line would serve no purpose.
//    So this file 【only translates the column "data model" that
//    dbgrids.pas needs】:
//      TGridColumnTitle / TGridColumn / TGridColumns (column definitions:
//      width/alignment/visible/readOnly/title/PickList/button style…)
//      plus the related enums.
//    Drawing, selection, the message loop, and cell editor GUI
//    infrastructure 【are not translated】 — they're reimplemented
//    Flutter-idiomatically in dbgrids' Flutter widget layer
//    (lazarus_dbgrid_widget.dart).
//
//  Translation conventions carried over from lazarus_db.dart's header
//  (pointer→object, ^T→nullable, class of→factory, TColor→int(ARGB),
//  TFont→object, method names lowerCamelCase).
//  grids' ^Integer/^TColor/^Boolean "optional value pointer" semantics
//  (nil = use the default) → Dart nullable field + `?? getDefaultXxx()`
//  fallback maps onto this perfectly.
//
//  Depends on: lazarus_db.dart (TPersistent/TCollection/TCollectionItem/TStrings)
// ═════════════════════════════════════════════════════════════════════════════

/// Grid base classes and column definitions used by the data-aware grid.
library;

import 'lazarus_db.dart';

// aa !!! not fully translated
// Minimal shim for GUI types: the source for LCL's Graphics/Controls
// units wasn't available; only the types needed by the grids/dbgrids
// column model are rebuilt here. This is not a full set of LCL GUI types.
// zz !!! not fully translated

// TColor (Graphics): in LCL this is 32-bit BGR plus high-order system-color
// bits; simplified here to an ARGB int (usable directly with Flutter's
// Color(value)). The special clDefault sentinel value is kept.
typedef TColor = int;
const int clDefault = 0x20000000; // LCL's clDefault sentinel value
const int clWindow =
    0xFFFFFFFF; // corresponds to a white background (simplified)
const int clWindowText = 0xFF000000;
const int clBtnFace = 0xFFF0F0F0;
const int clGrayText = 0xFF808080;
const int clHighlight = 0xFF3399FF;
const int clHighlightText = 0xFFFFFFFF;
const int clBlack = 0xFF000000;
const int clNone = 0x1FFFFFFF;

// TAlignment (Classes) — already defined in lazarus_db.dart
// (taLeftJustify/taRightJustify/taCenter); not redefined here.

// TTextLayout (Graphics)
enum TTextLayout { tlTop, tlCenter, tlBottom }

// TButtonLayout (Controls)
enum TButtonLayout { blGlyphLeft, blGlyphRight, blGlyphTop, blGlyphBottom }

// TPrefixOption (grids L174)
enum TPrefixOption { poNone, poHeaderClick }

// TImageIndex (ImgList)
typedef TImageIndex = int;

// aa !!! not fully translated
// Minimal TFont shim: LCL's TFont has a full model of font family/weight/
// style/pixel height etc.; only the parts grids actually uses are kept
// here, mapped to a TextStyle on the Flutter side.
// zz !!! not fully translated
class TFont {
  String name = '';
  int size = 0; // 0 = default
  TColor color = clWindowText;
  bool bold = false;
  bool italic = false;
  TNotifyEvent? onChange;

  void assign(TFont src) {
    name = src.name;
    size = src.size;
    color = src.color;
    bold = src.bold;
    italic = src.italic;
    onChange?.call(this);
  }
}

// ---- grids column-related enums (L154-174) ---------------------------------

// TColumnButtonStyle (grids L154-162)
enum TColumnButtonStyle {
  cbsAuto,
  cbsEllipsis,
  cbsNone,
  cbsPickList,
  cbsCheckboxColumn,
  cbsButton,
  cbsButtonColumn,
}

// TGridDrawState (grids L139) — the state flags for the widget layer while painting a cell
enum TGridDrawStateItem {
  gdSelected,
  gdFocused,
  gdFixed,
  gdHot,
  gdPushed,
  gdRowHighlight
}

typedef TGridDrawState = Set<TGridDrawStateItem>;

// TGridZone (grids L143)
enum TGridZone { gzNormal, gzFixedCols, gzFixedRows, gzFixedCells, gzInvalid }

// TSortOrder (grids L172)
enum TSortOrder { soAscending, soDescending }

// Column-width default sentinel (plays the role of TCustomGrid.DefaultColWidth; overridable at the widget layer)
const int kDefaultColWidth = 64;

// ═════════════════════════════════════════════════════════════════════════════
//  TGridColumnTitle (grids.pas L448-511)
//  ^TColor/^TAlignment/^TTextLayout "optional value" → nullable + fallback
// ═════════════════════════════════════════════════════════════════════════════
class TGridColumnTitle {
  final TGridColumn _column;

  String? _caption; // FCaption (nil = use GetDefaultCaption)
  TColor? _color; // FColor (nil = use the default)
  TAlignment? _alignment; // FAlignment
  TTextLayout? _layout; // FLayout
  late TFont _font;
  bool _isDefaultTitleFont = true;
  TImageIndex imageIndex = -1;
  TButtonLayout imageLayout = TButtonLayout.blGlyphRight;
  TPrefixOption prefixOption = TPrefixOption.poNone;
  bool multiLine = false;
  bool _isDefaultCaption = true;

  // constructor Create(TheColumn) (L493)
  TGridColumnTitle(this._column) {
    _font = TFont();
    _font.onChange = _fontChanged;
    fillTitleDefaultFont();
  }

  void _fontChanged(Object sender) {
    _isDefaultTitleFont = false;
    _column.columnChanged();
  }

  TGridColumn get column => _column;
  bool get isDefaultFont => _isDefaultTitleFont;

  // GetDefaultCaption (L484, virtual): base returns 'Title'; TColumnTitle
  // overrides it to the field's title (see dbgrids)
  String getDefaultCaption() => 'Title';

  // GetDefaultAlignment / GetDefaultColor / GetDefaultLayout (L485-487)
  TAlignment getDefaultAlignment() => TAlignment.taLeftJustify;
  TColor getDefaultColor() => clBtnFace;
  TTextLayout getDefaultLayout() => TTextLayout.tlCenter;

  // Caption (L489-490, 503): nil → default
  String get caption => _caption ?? getDefaultCaption();
  set caption(String value) {
    _caption = value;
    _isDefaultCaption = false;
    _column.columnChanged();
  }

  bool get isDefaultCaption => _isDefaultCaption;

  // Alignment (L463, 502)
  TAlignment get alignment => _alignment ?? getDefaultAlignment();
  set alignment(TAlignment value) {
    _alignment = value;
    _column.columnChanged();
  }

  // Color (L464, 504)
  TColor get color => _color ?? getDefaultColor();
  set color(TColor value) {
    _color = value;
    _column.columnChanged();
  }

  // Layout (L466, 508)
  TTextLayout get layout => _layout ?? getDefaultLayout();
  set layout(TTextLayout value) {
    _layout = value;
    _column.columnChanged();
  }

  // Font (L465, 505)
  TFont get font => _font;
  set font(TFont value) {
    _font.assign(value);
    _isDefaultTitleFont = false;
  }

  // FillTitleDefaultFont (L496): applies the default from the grid's title font
  void fillTitleDefaultFont() {
    _isDefaultTitleFont = true;
  }

  // IsDefault (L499): true if every property is still at its default value
  bool isDefault() {
    return _caption == null &&
        _color == null &&
        _alignment == null &&
        _layout == null &&
        _isDefaultTitleFont &&
        imageIndex == -1 &&
        imageLayout == TButtonLayout.blGlyphRight &&
        !multiLine &&
        prefixOption == TPrefixOption.poNone;
  }

  // Assign (L495)
  void assign(TGridColumnTitle source) {
    _caption = source._caption;
    _color = source._color;
    _alignment = source._alignment;
    _layout = source._layout;
    _font.assign(source._font);
    _isDefaultTitleFont = source._isDefaultTitleFont;
    imageIndex = source.imageIndex;
    imageLayout = source.imageLayout;
    prefixOption = source.prefixOption;
    multiLine = source.multiLine;
    _isDefaultCaption = source._isDefaultCaption;
    _column.columnChanged();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  TGridColumn (grids.pas L515-631)
// ═════════════════════════════════════════════════════════════════════════════
class TGridColumn extends TCollectionItem {
  TColumnButtonStyle buttonStyle = TColumnButtonStyle.cbsAuto;
  int dropDownRows = 7;
  late TGridColumnTitle _title;
  bool _widthChanged = false;

  // ^T "optional value" members → nullable (nil = use GetDefaultXxx)
  TAlignment? _alignment;
  TColor? _color;
  TTextLayout? _layout;
  bool? _visible;
  bool? _readOnly;
  int? _width;
  int? _minSize;
  int? _maxSize;
  int? _sizePriority;
  late TFont _font;
  bool _isDefaultFont = true;
  TStrings? _pickList;
  String? _valueChecked;
  String? _valueUnchecked;
  int tag = 0;

  // constructor Create (L598)
  TGridColumn(super.aCollection) {
    _font = TFont();
    _font.onChange = _fontChanged;
    _title = createTitle();
    _visible = null;
    _readOnly = null;
    _width = null;
  }

  void _fontChanged(Object sender) {
    _isDefaultFont = false;
    columnChanged();
  }

  // CreateTitle (L593, virtual): TColumn overrides this to a TColumnTitle
  TGridColumnTitle createTitle() => TGridColumnTitle(this);

  // GetGrid (L538): the grid of the owning collection — injected at the
  // widget layer; returns null here (column-width fallback uses kDefaultColWidth)
  dynamic get grid {
    final c = collection;
    if (c is TGridColumns) return c.grid;
    return null;
  }

  // ---- default values (L577-587, virtual) ------------------------------------
  TAlignment getDefaultAlignment() => TAlignment.taLeftJustify;
  TColor getDefaultColor() => clWindow;
  TTextLayout getDefaultLayout() => TTextLayout.tlCenter;
  int getDefaultMaxSize() => 0;
  int getDefaultMinSize() => 0;
  bool getDefaultReadOnly() => false;
  int getDefaultSizePriority() => 1;
  bool getDefaultVisible() => true;
  String getDefaultValueChecked() => '1';
  String getDefaultValueUnchecked() => '0';

  // GetDefaultWidth (L587): the grid's DefaultColWidth; -1 if there's no grid
  int getDefaultWidth() {
    final g = grid;
    if (g != null) {
      try {
        final w = (g as dynamic).defaultColWidth;
        if (w is int) return w;
      } catch (_) {}
    }
    return -1;
  }

  // ---- property getters/setters (nil → default fallback) --------------------------

  // Alignment (L534, 611)
  TAlignment get alignment => _alignment ?? getDefaultAlignment();
  set alignment(TAlignment value) {
    _alignment = value;
    columnChanged();
  }

  // Color (L535, 613)
  TColor get color => _color ?? getDefaultColor();
  set color(TColor value) {
    _color = value;
    columnChanged();
  }

  // Layout (L539, 617)
  TTextLayout get layout => _layout ?? getDefaultLayout();
  set layout(TTextLayout value) {
    _layout = value;
    columnChanged();
  }

  // Visible (L545, 626)
  bool get visible => _visible ?? getDefaultVisible();
  set visible(bool value) {
    _visible = value;
    columnChanged();
  }

  // ReadOnly (L543, 621)
  bool get readOnly => _readOnly ?? getDefaultReadOnly();
  set readOnly(bool value) {
    _readOnly = value;
    columnChanged();
  }

  // Width (L546, 625): nil→DefaultWidth; <0→grid.DefaultColWidth
  // (the fallback shown in grids.pas's GetWidth)
  int get width {
    var result = _width ?? getDefaultWidth();
    if (result < 0) {
      final g = grid;
      if (g != null) {
        try {
          final w = (g as dynamic).defaultColWidth;
          if (w is int) result = w;
        } catch (_) {
          result = kDefaultColWidth;
        }
      } else {
        result = kDefaultColWidth;
      }
    }
    return result;
  }

  set width(int value) {
    if (_width != value) {
      _width = value;
      _widthChanged = true;
      columnChanged();
    }
  }

  bool get widthChanged => _widthChanged;
  int get storedWidth => _width ?? -1;
  int get defaultWidth => getDefaultWidth();

  // MinSize / MaxSize / SizePriority (L540-542, 618-622)
  int get minSize => _minSize ?? getDefaultMinSize();
  set minSize(int value) {
    _minSize = value;
    columnChanged();
  }

  int get maxSize => _maxSize ?? getDefaultMaxSize();
  set maxSize(int value) {
    _maxSize = value;
    columnChanged();
  }

  int get sizePriority => _sizePriority ?? getDefaultSizePriority();
  set sizePriority(int value) {
    _sizePriority = value;
    columnChanged();
  }

  // ValueChecked / ValueUnchecked (L589-590, 627-630)
  String get valueChecked => _valueChecked ?? getDefaultValueChecked();
  set valueChecked(String value) {
    _valueChecked = value;
    columnChanged();
  }

  String get valueUnchecked => _valueUnchecked ?? getDefaultValueUnchecked();
  set valueUnchecked(String value) {
    _valueUnchecked = value;
    columnChanged();
  }

  // Font (L537, 616)
  TFont get font => _font;
  set font(TFont value) {
    _font.assign(value);
    _isDefaultFont = false;
  }

  bool get isDefaultFont => _isDefaultFont;

  // PickList (L588, 620): the dropdown list used by cbsPickList
  TStrings getPickList() {
    _pickList ??= TStringList();
    return _pickList!;
  }

  TStrings get pickList => getPickList();
  set pickList(TStrings value) {
    getPickList().assign(value);
  }

  // Title (L570, 624)
  TGridColumnTitle get title => _title;
  set title(TGridColumnTitle value) {
    _title.assign(value);
  }

  // ColumnChanged (L591, virtual): notifies the collection to update
  void columnChanged() {
    final c = collection;
    if (c is TGridColumns) {
      c.update(this);
    }
  }

  // GetDisplayName (L576)
  @override
  String get displayName {
    if (_title.caption.isNotEmpty) return _title.caption;
    return super.displayName;
  }

  // IsDefault (L604, virtual)
  bool isDefault() {
    return _alignment == null &&
        _color == null &&
        _layout == null &&
        _visible == null &&
        _readOnly == null &&
        _width == null &&
        _isDefaultFont &&
        _title.isDefault() &&
        buttonStyle == TColumnButtonStyle.cbsAuto;
  }

  // Assign (L600)
  @override
  void assign(TPersistent? source) {
    if (source is TGridColumn) {
      _alignment = source._alignment;
      _color = source._color;
      _layout = source._layout;
      _visible = source._visible;
      _readOnly = source._readOnly;
      _width = source._width;
      _minSize = source._minSize;
      _maxSize = source._maxSize;
      _sizePriority = source._sizePriority;
      _font.assign(source._font);
      _isDefaultFont = source._isDefaultFont;
      buttonStyle = source.buttonStyle;
      dropDownRows = source.dropDownRows;
      tag = source.tag;
      _valueChecked = source._valueChecked;
      _valueUnchecked = source._valueUnchecked;
      if (source._pickList != null) getPickList().assign(source._pickList!);
      _title.assign(source._title);
      columnChanged();
      return;
    }
    super.assign(source);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  TGridColumns (grids.pas L643-...)
// ═════════════════════════════════════════════════════════════════════════════
class TGridColumns extends TCollection {
  dynamic _grid; // TCustomGrid (widget layer); weakly typed injection here

  TGridColumns(this._grid, TCollectionItemFactory itemClass) : super(itemClass);

  // A grid-less convenience constructor for dbgrids' TDBGridColumns
  TGridColumns.plain(super.itemClass) : _grid = null;

  // ignore: unnecessary_getters_setters
  dynamic get grid => _grid;
  set grid(dynamic value) => _grid = value;

  TGridColumn operator [](int index) => getItem(index) as TGridColumn;
  void operator []=(int index, TGridColumn value) {
    getItem(index).assign(value);
  }

  // Add (L...)
  @override
  TGridColumn add() => super.add() as TGridColumn;

  // Update (virtual): notifies the grid to repaint when a column changes —
  // overridden/listened to at the widget layer; calls the grid's
  // columnsChanged (if present) here
  @override
  void update(TCollectionItem? item) {
    if (_grid != null) {
      try {
        (_grid as dynamic).columnsChanged(item);
      } catch (_) {}
    }
  }

  // VisibleCount: number of visible columns (used for widget layout)
  int get visibleCount {
    var n = 0;
    for (var i = 0; i < count; i++) {
      if (this[i].visible) n++;
    }
    return n;
  }
}
