// ═════════════════════════════════════════════════════════════════════════════
//  lazarus_dbgrids.dart
//
//  @@@ 2026-08-10 fix: TDBGrid's detail-grid-stays-blank-after-requery bug.
//      See the notes at _TDBGridState.initState() and _onDataSetOpen()
//      below for the full root-cause writeup.
//
//  This file is a Dart translation (derivative work) of the following
//  Object Pascal upstream source:
//    Upstream project: Lazarus Component Library (LCL)
//    Upstream file: dbgrids.pas
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
//  lazarus_dbgrids.dart —— translation of the "data layer" of FPC/LCL dbgrids.pas
//  ─────────────────────────────────────────────────────────────────────────
//  Corresponds to: dbgrids.pas (LCL, 4,823 lines)
//
//  Translation scope (per the user's direction of "behavioral equivalence"):
//    ✔ TComponentDataLink —— the soul of dbgrids: overrides every one of
//      TDataLink's event callbacks, translating dataset changes
//      (RecordChanged/DataSetChanged/ActiveChanged/Scrolled/
//      LayoutChanged/EditingChanged/UpdateData) into a set of attachable
//      notification events. This sits directly on top of
//      lazarus_db.dart's TDataLink, translated faithfully, line by line.
//    ✔ TColumn / TColumnTitle / TDBGridColumns —— the column-definition
//      model: FieldName↔Field binding, DisplayFormat, default-value
//      fallbacks (Alignment/Visible/ReadOnly/Caption derived from field
//      properties). Built on top of lazarus_grids.dart's
//      TGridColumn/TGridColumns.
//    ✘ TCustomDBGrid/TDBGrid's painting/selection/mouse+keyboard/editors
//      —— that's TCustomGrid(TCustomControl)'s GUI infrastructure,
//      reimplemented Flutter-idiomatically by the Flutter widget layer
//      (lazarus_dbgrid_widget.dart). This file only keeps the "Grid
//      contract" abstraction the widget layer needs (IDBGridHost), so
//      TColumn/TDBGridColumns can ask the grid for the dataLink/
//      options/default column width.
//
//  Translation conventions carried over from earlier files (^T→nullable,
//  pointer→object, method names lowerCamelCase, ??? marks a simplified
//  point, @@@ marks newly-written bridging code).
//
//  Depends on: lazarus_db.dart (TDataLink/TField/TDataSet/TNumericField…),
//        lazarus_grids.dart (TGridColumn/TGridColumns/TGridColumnTitle)
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // @@@ Tab key handling

import 'lazarus_db.dart';
import 'lazarus_grids.dart';
import 'wapform_lookup_box.dart'; // @@@ the grid cell dropdown editor (WapLookupBox)

// ---- dbgrids event types (near dbgrids.pas L60-90) ------------------------------
typedef TDatasetNotifyEvent = void Function(TDataSet dataSet);
// @@@ Not a separate typedef: db.pas already declares TFieldNotifyEvent
// (imported from lazarus_db.dart) for Field.onChange/onValidate, where
// the field is never null. TComponentDataLink.recordChanged can be
// called with a null field (meaning "the whole record changed"), which
// needs a nullable-field signature — re-declaring a same-named typedef
// with a different signature here caused an ambiguous_export error when
// both files were re-exported from wapform_flutter.dart's barrel file.
// Declared inline instead; Dart's function types are structural, so
// this changes nothing about how callers use `onRecordChanged`.
typedef TDataSetScrolledEvent = void Function(TDataSet dataSet, int distance);
typedef TFocusControlEvent = void Function(TFieldRef? field);

// TDBGridOption (dbgrids.pas L50-) —— behavior options for the widget layer
enum TDBGridOption {
  dgEditing,
  dgTitles,
  dgIndicator,
  dgColumnResize,
  dgColumnMove,
  dgColLines,
  dgRowLines,
  dgTabs,
  dgAlwaysShowEditor,
  dgRowSelect,
  dgAlwaysShowSelection,
  dgConfirmDelete,
  dgCancelOnExit,
  dgMultiselect,
  dgHeaderHotTracking,
  dgHeaderPushedLook,
  dgAnyButtonCanSelect,
  dgDisableDelete,
  dgDisableInsert,
  dgCellHints,
  dgTruncCellHints,
  dgCellEllipsis,
  dgRowHighlight,
  dgThumbTracking,
  dgDisplayMemoText,
}

typedef TDBGridOptions = Set<TDBGridOption>;

//aa IDBGridHost (the grid contract injected by the widget layer)
// @@@ Grid contract (playing the role of IProviderSupport): the widget
// layer (the Flutter implementation of TCustomDBGrid) provides this
// interface, and TColumn/TDBGridColumns use it to ask the grid for the
// dataLink, options, default column width, and to trigger
// layoutChanged. In the original code TColumn directly accessed
// TCustomDBGrid(Grid).XXX; here that's abstracted into an interface to
// avoid the data layer depending back on the GUI widget.
abstract class IDBGridHost {
  TComponentDataLink get dataLink;
  bool get readOnly;
  TDBGridOptions get options;
  int get defaultColWidth;
  bool get isLoading; // csLoading in ComponentState
  void layoutChanged();
  void beginLayout();
  void endLayout();
  // DefaultEditorStyle (used by TColumn.GetDefaultAlignment): decides
  // the actual editor style based on the field type / ButtonStyle
  TColumnButtonStyle defaultEditorStyle(
      TColumnButtonStyle style, TField? field);
}

//zz IDBGridHost (the grid contract injected by the widget layer)

// ═════════════════════════════════════════════════════════════════════════════
//  TComponentDataLink (dbgrids.pas L191-241, implementation L3984-4134)
//  The soul of dbgrids: turns TDataLink's event callbacks into attachable notifications
// ═════════════════════════════════════════════════════════════════════════════
class TComponentDataLink extends TDataLink {
  TDataSet? _dataSet;
  String _dataSetName = '';
  bool modified = false;

  // Events (L226-237)
  void Function(TField? field)? onRecordChanged;
  TDatasetNotifyEvent? onDataSetChanged;
  TDatasetNotifyEvent? onNewDataSet;
  TDatasetNotifyEvent? onDataSetOpen;
  TDatasetNotifyEvent? onInvalidDataSet;
  TDatasetNotifyEvent? onInvalidDataSource;
  TFocusControlEvent? onFocusControl;
  TDatasetNotifyEvent? onLayoutChanged;
  TDatasetNotifyEvent? onDataSetClose;
  TDataSetScrolledEvent? onDataSetScrolled;
  TDatasetNotifyEvent? onEditingChanged;
  TDatasetNotifyEvent? onUpdateData;

  // GetFields (L3984-3991)
  TField? fields(int index) {
    final ds = dataSet;
    if (ds != null && index >= 0 && index < ds.fieldCount) {
      return ds.fields[index];
    }
    return null;
  }

  // GetDataSetName (L3993-4000)
  String get dataSetName {
    var result = _dataSetName;
    if (dataSet != null) result = dataSet!.name;
    return result;
  }

  // SetDataSetName (L4002-4008)
  set dataSetName(String value) {
    if (_dataSetName != value) _dataSetName = value;
  }

  // RecordChanged (L4010-4017)
  @override
  void recordChanged(TField? field) {
    onRecordChanged?.call(field);
  }

  // DataSetChanged (L4019-4026)
  @override
  void dataSetChanged() {
    if (dataSet != null) onDataSetChanged?.call(dataSet!);
  }

  // ActiveChanged (L4028-4063): when the dataset opens/closes,
  // distinguishes between the four states "new dataset / opened /
  // closed / invalidated" and fires the corresponding event
  @override
  void activeChanged() {
    if (active) {
      _dataSet = dataSet;
      if (dataSetName != _dataSetName) {
        _dataSetName = dataSetName;
        if (dataSet != null) onNewDataSet?.call(dataSet!);
      } else {
        if (dataSet != null) onDataSetOpen?.call(dataSet!);
      }
    } else {
      bufferCount = 0;
      if (dataSource == null) {
        if (_dataSet != null) onInvalidDataSource?.call(_dataSet!);
        _dataSet = null;
        _dataSetName = '[???]';
      } else {
        if (dataSet == null ||
            dataSet!.componentState
                .contains(TComponentStateItem.csDestroying)) {
          if (_dataSet != null) onInvalidDataSet?.call(_dataSet!);
          _dataSet = null;
          _dataSetName = '[???]';
        } else {
          if (dataSet != null) onDataSetClose?.call(dataSet!);
          if (dataSet != null) _dataSetName = dataSetName;
        }
      }
    }
  }

  // LayoutChanged (L4065-4075)
  @override
  void layoutChanged() {
    if (dataSet != null) onLayoutChanged?.call(dataSet!);
  }

  // DataSetScrolled (L4077-4084)
  @override
  void dataSetScrolled(int distance) {
    if (dataSet != null) onDataSetScrolled?.call(dataSet!, distance);
  }

  // FocusControl (L4086-4093)
  @override
  void focusControl(TFieldRef? field) {
    onFocusControl?.call(field);
  }

  // CheckBrowseMode (L4095-4101)

  // EditingChanged (L4103-4110)
  @override
  void editingChanged() {
    if (dataSet != null) onEditingChanged?.call(dataSet!);
  }

  // UpdateData (L4112-4119)
  @override
  void updateData() {
    if (dataSet != null) onUpdateData?.call(dataSet!);
  }

  // MoveBy (L4121-4134)
}

// ═════════════════════════════════════════════════════════════════════════════
//  TColumnTitle (dbgrids.pas L245-248, implementation L4564-4575)
//  Overrides GetDefaultCaption → uses the field's DisplayName / FieldName
// ═════════════════════════════════════════════════════════════════════════════
class TColumnTitle extends TGridColumnTitle {
  TColumnTitle(super.column);

  // GetDefaultCaption (L4564-4575)
  @override
  String getDefaultCaption() {
    final col = column;
    if (col is TColumn) {
      if (col.fieldName != '') {
        final f = col._field;
        if (f != null) {
          return f.displayName;
        }
        return col.fieldName;
      }
    }
    return super.getDefaultCaption();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  TColumn (dbgrids.pas L252-293, implementation L4309-4560)
// ═════════════════════════════════════════════════════════════════════════════
class TColumn extends TGridColumn {
  String _displayFormat = '';
  bool _displayFormatChanged = false;
  String _fieldName = '';
  TField? _field;
  bool _isAutomaticColumn = false;
  int _designIndex = 10000;

  // constructor Create (L4461-4476)
  TColumn(TCollection? aCollection) : super(aCollection) {
    final c = aCollection;
    if (c is TDBGridColumns) {
      final host = c.host;
      if (host != null && host.isLoading) {
        _designIndex = index;
      } else {
        _designIndex = 10000;
      }
    }
  }

  int get designIndex => _designIndex;
  bool get isAutomaticColumn => _isAutomaticColumn;
  set isAutomaticColumn(bool v) => _isAutomaticColumn = v;

  // GetIsDesignColumn (L4316-4319)
  bool get isDesignColumn => _designIndex >= 0 && _designIndex < 10000;

  // CreateTitle (L4456-4459)
  @override
  TGridColumnTitle createTitle() => TColumnTitle(this);

  // GetDataSet (L4399-4408): gets the dataLink's dataset via the host
  TDataSet? get dataSet {
    final host = _host;
    if (host != null) return host.dataLink.dataSet;
    return null;
  }

  IDBGridHost? get _host {
    final c = collection;
    if (c is TDBGridColumns) return c.host;
    return null;
  }

  // GetField (L4309-4314)
  TField? get field {
    if (_fieldName != '' && _field != null) linkField();
    return _field;
  }

  // SetField (L4381-4389)
  set field(TField? value) {
    if (!identical(_field, value)) {
      _field = value;
      if (_field != null) _fieldName = _field!.fieldName;
      columnChanged();
    }
  }

  // FieldName (L290, L4391-4397)
  String get fieldName => _fieldName;
  set fieldName(String value) {
    if (_fieldName == value) return;
    _fieldName = value;
    linkField();
    columnChanged();
  }

  // LinkField (L4483-4493)
  void linkField() {
    final host = _host;
    if (host != null && host.dataLink.active) {
      final ds = host.dataLink.dataSet;
      _field = ds?.findField(_fieldName);
      applyDisplayFormat();
    } else {
      _field = null;
    }
  }

  // ApplyDisplayFormat (L4349-4357)
  void applyDisplayFormat() {
    if (_field != null && _displayFormatChanged) {
      final f = _field!;
      if (f is TNumericField) {
        f.displayFormat = displayFormat;
      } else if (f is TDateTimeField) {
        f.displayFormat = displayFormat;
      }
    }
  }

  // GetDisplayFormat (L4359-4365)
  String get displayFormat {
    if (!_displayFormatChanged) return getDefaultDisplayFormat();
    return _displayFormat;
  }

  // SetDisplayFormat (L4372-4379)
  set displayFormat(String value) {
    if (!_displayFormatChanged ||
        value.toUpperCase() != _displayFormat.toUpperCase()) {
      _displayFormat = value;
      _displayFormatChanged = true;
      columnChanged();
    }
  }

  bool get isDisplayFormatStored => _displayFormatChanged;

  // GetDefaultDisplayFormat (L4495-4504)
  String getDefaultDisplayFormat() {
    var result = '';
    final f = _field;
    if (f != null) {
      if (f is TNumericField) {
        result = f.displayFormat;
      } else if (f is TDateTimeField) {
        result = f.displayFormat;
      }
    }
    return result;
  }

  // ---- Default-value overrides (derived from field properties) ------------------------------

  // GetDefaultAlignment (L4546-4560): checkbox/button columns are
  // centered, otherwise uses the field's alignment
  @override
  TAlignment getDefaultAlignment() {
    final bs = <TColumnButtonStyle>{buttonStyle};
    final host = _host;
    if (host != null) {
      bs.add(host.defaultEditorStyle(buttonStyle, _field));
    }
    if (bs.contains(TColumnButtonStyle.cbsCheckboxColumn) ||
        bs.contains(TColumnButtonStyle.cbsButtonColumn)) {
      return TAlignment.taCenter;
    }
    if (_field != null) return _field!.alignment;
    return TAlignment.taLeftJustify;
  }

  // GetDefaultReadOnly (L4522-4528)
  @override
  bool getDefaultReadOnly() {
    final host = _host;
    final gridRO = host != null && host.readOnly;
    final fieldRO = _field != null && _field!.readOnly;
    return gridRO || fieldRO;
  }

  // GetDefaultVisible (L4530-4536)
  @override
  bool getDefaultVisible() {
    if (_field != null) return _field!.visible;
    return true;
  }

  // GetDefaultValueChecked (L4506-4512)
  @override
  String getDefaultValueChecked() {
    if (_field != null && _field!.dataType == TFieldType.ftBoolean) {
      return boolToStr(true);
    }
    return '1';
  }

  // GetDefaultValueUnchecked (L4514-4520)
  @override
  String getDefaultValueUnchecked() {
    if (_field != null && _field!.dataType == TFieldType.ftBoolean) {
      return boolToStr(false);
    }
    return '0';
  }

  // GetDefaultWidth (L4428-4454): the original code measures the
  // field/title text width using Canvas (CalcColumnFieldWidth). ???
  // Measuring width via Canvas is the GUI widget's job (the Flutter
  // side would use TextPainter) — the data layer can't measure it, so
  // this falls back to the host's defaultColWidth; the widget layer
  // should override this if it needs a precisely calculated column width.
  @override
  int getDefaultWidth() {
    final host = _host;
    if (host != null) return host.defaultColWidth;
    return -1;
  }

  // GetDisplayName (L4538-4544)
  @override
  String get displayName {
    if (_fieldName != '') return _fieldName;
    return super.displayName;
  }

  // GetPickList (L4321-4347): the dropdown source for cbsPickList/lookup
  // columns. Lookup columns fetch the list of result-field values from
  // LookupDataSet.
  @override
  TStrings getPickList() {
    final result = super.getPickList();
    final f = field;
    if (f != null && f.fieldKind == TFieldKind.fkLookup) {
      if (f.lookupCache) {
        f.lookupList.valuesToStrings(result);
      } else {
        result.clear();
        final lds = f.lookupDataSet;
        if (lds != null) {
          // ??? The original code uses LookupGetBookMark/
          // LookupGotoBookMark to preserve the cursor position; this is
          // simplified to recording recNo and restoring it afterward
          // (the full bookmark mechanism already exists in the data
          // layer, but this scan is a read-only traversal, so it's just
          // wrapped in disable/enable)
          final bm = lds.getBookmark();
          lds.disableControls();
          try {
            lds.first();
            while (!lds.eof) {
              result.add(lds.fieldByName(f.lookupResultField).asString);
              lds.next();
            }
          } finally {
            if (bm != null && lds.bookmarkValid(bm)) {
              lds.gotoBookmark(bm);
            }
            lds.enableControls();
          }
        }
      }
    }
    return result;
  }

  // Assign (L4410-4426)
  @override
  void assign(TPersistent? source) {
    if (source is TColumn) {
      collection?.beginUpdate();
      try {
        super.assign(source);
        fieldName = source.fieldName;
        displayFormat = source.displayFormat;
        valueChecked = source.valueChecked;
        valueUnchecked = source.valueUnchecked;
      } finally {
        collection?.endUpdate();
      }
    } else {
      super.assign(source);
    }
  }

  // IsDefault (L4478-4481)
  @override
  bool isDefault() {
    return !_displayFormatChanged && super.isDefault();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  TDBGridColumns (dbgrids.pas L298-315, implementation L4138-4305)
// ═════════════════════════════════════════════════════════════════════════════
enum TColumnOrder { coDesignOrder, coFieldIndexOrder }

class TDBGridColumns extends TGridColumns {
  IDBGridHost?
      host; // the Flutter implementation of TCustomDBGrid (injected by the widget layer)

  TDBGridColumns([this.host]) : super.plain((c) => TColumn(c));

  // GetColumn (L4138-4141)
  @override
  TColumn operator [](int index) => getItem(index) as TColumn;

  // SetColumn (L4143-4146)
  @override
  void operator []=(int index, TGridColumn value) {
    getItem(index).assign(value);
  }

  // Update (L4148-4152): a column changed → grid.LayoutChanged (not while loading)
  @override
  void update(TCollectionItem? item) {
    if (host != null && !host!.isLoading) {
      host!.layoutChanged();
    }
  }

  // ColumnFromField (L4154-4165)
  TColumn? columnFromField(TField? field) {
    if (field != null) {
      for (var i = 0; i < count; i++) {
        final result = this[i];
        if (identical(result.field, field)) return result;
      }
    }
    return null;
  }

  // HasAutomaticColumns (L4167-4177)
  bool hasAutomaticColumns() {
    for (var i = 0; i < count; i++) {
      if (this[i].isAutomaticColumn) return true;
    }
    return false;
  }

  // HasDesignColumns (L4179-4189)
  bool hasDesignColumns() {
    for (var i = 0; i < count; i++) {
      if (this[i].isDesignColumn) return true;
    }
    return false;
  }

  // RemoveAutoColumns (L4191-4209)
  void removeAutoColumns() {
    if (hasAutomaticColumns()) {
      beginUpdate();
      try {
        for (var i = count - 1; i >= 0; i--) {
          if (this[i].isAutomaticColumn) delete(i);
        }
      } finally {
        endUpdate();
      }
    }
  }

  // ResetColumnsOrder (L4228-4258)
  void resetColumnsOrder(TColumnOrder columnOrder) {
    final l = <TColumn>[];
    for (var i = 0; i < count; i++) {
      l.add(this[i]);
    }
    switch (columnOrder) {
      case TColumnOrder.coDesignOrder:
        if (!hasDesignColumns()) return;
        // CompareDesignIndex (L4223-4226)
        l.sort((a, b) => a.designIndex - b.designIndex);
        break;
      case TColumnOrder.coFieldIndexOrder:
        // CompareFieldIndex (L4211-4221): a nil field sorts to the end
        l.sort((a, b) {
          if (identical(a, b)) return 0;
          if (a.field == null) return 1;
          if (b.field == null) return -1;
          return a.field!.index - b.field!.index;
        });
        break;
    }
    for (var i = 0; i < l.length; i++) {
      l[i].index = i;
    }
  }

  // Add (L4260-4274): removes automatic columns before adding a user column
  @override
  TColumn add() {
    if (host != null) {
      removeAutoColumns();
    }
    return super.add() as TColumn;
  }

  // ColumnByFieldname (L4276-4286)
  TColumn? columnByFieldname(String aFieldname) {
    for (var i = 0; i < count; i++) {
      if (this[i].fieldName.toUpperCase() == aFieldname.toUpperCase()) {
        return this[i];
      }
    }
    return null;
  }

  // ColumnByTitle (L4288-4291)
  TColumn? columnByTitle(String aTitle) {
    for (var i = 0; i < count; i++) {
      if (this[i].title.caption == aTitle) return this[i];
    }
    return null;
  }

  // LinkFields (L4293-4305)
  void linkFields() {
    host?.beginLayout();
    for (var i = 0; i < count; i++) {
      this[i].linkField();
    }
    host?.endLayout();
  }
}

// aa !!! not fully translated
// boolToStr: a SysUtils shim (upstream source unavailable); only
// implements the form TColumn actually uses.
// zz !!! not fully translated
String boolToStr(bool value) =>
    value ? '-1' : "0"; // Pascal BoolToStr's default

// aa !!! not fully translated
// The TDBGrid widget below is 【not】 a line-by-line translation of
// dbgrids.pas, but a "behavior-aligned rewrite" — LCL's DBGrid is built
// on self-painting (Canvas.TextRect / DrawCell) and a Win32/GTK message
// model, while Flutter is a widget tree + declarative rebuilding —
// there's no possibility of a line-by-line mapping between the two.
// The first half of this file (the data layer: TColumn / TDBGridColumns
// / TComponentDataLink etc.) is the actual translation of dbgrids.pas;
// from here on is the Flutter-side display implementation.
// ═════════════════════════════════════════════════════════════════════════════
//  TDBGrid widget
// ═════════════════════════════════════════════════════════════════════════════
// @@@ Lookup configuration for a grid cell (ag5006 provides dropdown
//     data for a particular column).
//     fieldName → that column's dropdown config; returning null means
//     the column uses plain-text editing.
class TDBGridLookupSpec {
  final Map<String, List<String>> rows; // {key: [display columns...]}
  final List<double> colWidths; // width of each dropdown column
  final void Function(String key)?
      onPicked; // extra linked action after picking (optional)
  const TDBGridLookupSpec({
    required this.rows,
    this.colWidths = const [100],
    this.onPicked,
  });
}

typedef TDBGridLookupResolver = TDBGridLookupSpec? Function(String fieldName);

class TDBGrid extends StatefulWidget {
  final TDataSource? dataSource; // DataSource
  final TDBGridColumns?
      columns; // Columns (an LCL collection; null = auto-generate all columns)
  final bool readOnly; // ReadOnly
  final TDBGridOptions options; // Options
  final double? width;
  final double? height;

  // @@@ ag5006 compatibility: callback fired when a row's post completes (fired after an inline edit writes back)
  final Future<void> Function()? onRowPost;

  // @@@ ag5006 compatibility: a column's lookup dropdown config (used to edit item-number columns etc. via WapLookupBox)
  final TDBGridLookupResolver? lookupResolver;

  // @@@ ag5006 compatibility: fires on double-clicking a row (passes the
  //     visual row index). Used by query pages to switch tabs.
  //     A grid with this callback set routes double-click to
  //     onRowActivate instead of inline editing.
  final void Function(int row)? onRowActivate;

// aa ### flutter extension
  // Pressing Tab on the last column of the last row (no next row left)
  // → notifies the outside world to hand focus to the next widget.
  // Doesn't use FocusScope.nextFocus(): by the time the edit cell is
  // removed, focus has already lost its landing spot and jumps around
  // unpredictably.
  final VoidCallback? onExitLastRow;
// aa ### flutter extension
  // @@@ Automatically inserts the next row when Tab moves past the last
  //     row (for continuous data entry). LCL's TDBGrid already has a
  //     dgDisableInsert option, implying that "auto-insert on moving
  //     past the last row" is the default behavior — this wires that
  //     back up.
  //     onRowInsert must use the page's onnewrecord handler (e.g.
  //     _snInsert) rather than calling ds.insert() directly — inserting
  //     a detail row needs to check the master record and carry over
  //     the document number first; skipping that produces incomplete
  //     records. Auto-insert is disabled when this is null.
  final Future<void> Function()? onRowInsert;
// zz ### flutter extension
// zz ### flutter extension

  const TDBGrid({
    super.key,
    required this.dataSource,
    this.columns,
    this.readOnly = false,
    this.options = const {
      TDBGridOption.dgEditing,
      TDBGridOption.dgTitles,
      TDBGridOption.dgColumnResize,
      TDBGridOption.dgColLines,
      TDBGridOption.dgRowLines,
    },
    this.width,
    this.height,
    this.onRowPost,
    this.lookupResolver,
    this.onRowActivate,
    this.onExitLastRow,
    this.onRowInsert,
  });

  @override
  State<TDBGrid> createState() => _TDBGridState();
}

class _TDBGridState extends State<TDBGrid> implements IDBGridHost {
  late final TComponentDataLink _dataLink;
  late final TDBGridColumns _columns;
  int _layoutLock = 0;

  // inline edit state
  int?
      _editingRow; // the visual row currently being edited (relative to the buffer)
  TColumn? _editingCol;
  final TextEditingController _editController = TextEditingController();
// aa ### flutter extension: Excel-style cell selection
  // @@@ The "selected cell" (blue outline) when not editing. Kept
  //     separate from _editingRow/_editingCol: selection = the cursor is
  //     just parked on this cell (single click); editing = an input box
  //     has actually been opened (Enter/F2/typing). Uses the same
  //     coordinate system as _editingRow (buffer-relative rowOffset).
  int? _selRow;
  TColumn? _selCol;
  // @@@ When not editing, keyboard events (Enter/F2/arrow keys/typing)
  //     are caught by this node. While editing, focus naturally moves to
  //     the cell's TextField, so this node doesn't receive them.
  final FocusNode _gridFocus = FocusNode(debugLabel: 'TDBGrid');
// zz ### flutter extension
  // @@@ horizontal/vertical scroll controllers for the body.
  final ScrollController _hScroll = ScrollController();
  final ScrollController _vScroll = ScrollController();
  // @@@ 2026-08-10 fix: the vertical scrollbar used to live INSIDE the
  // horizontally-scrolled region, so it visually tracked the horizontal
  // scroll position — if the grid's columns were wider than the visible
  // area, the vertical scrollbar was only reachable after scrolling all
  // the way to the right, instead of staying pinned to the grid's visible
  // right edge like a normal desktop window. Fixed by moving the vertical
  // Scrollbar/SingleChildScrollView outside the horizontal one. That
  // means the header row (which must still scroll horizontally in lockstep
  // with the body, but must NOT scroll vertically) can no longer share
  // _hScroll directly — a single ScrollController's positions don't
  // auto-mirror each other across two separate Scrollables. This second,
  // display-only controller for the header is kept in sync via a listener
  // on _hScroll (see initState below) instead.
  final ScrollController _hScrollHeader = ScrollController();
  // @@@ 2026-08-10 fix: a Scrollbar given only a `controller` with no real
  // scrollable as its own child turned out unreliable (didn't paint).
  // For the horizontal scrollbar strip pinned at the bottom (needs to
  // stay put regardless of vertical scroll position, so it can't be
  // nested inside the vertical scroll region), give it its own tiny real
  // SingleChildScrollView sized to the exact same totalWidth as the real
  // content, mirrored from _hScroll via a listener (same proven trick
  // already used for _hScrollHeader above). The vertical scrollbar
  // doesn't need this — it stays the outermost wrapper around the real
  // vertical SingleChildScrollView, which already keeps it correctly
  // pinned to the right regardless of horizontal scroll position.
  final ScrollController _hScrollBar = ScrollController();

  @override
  void initState() {
    super.initState();
    // @@@ 2026-08-10 fix: keep the header's display-only scroll position
    // mirroring the body's real horizontal scroll (see the field comment
    // on _hScrollHeader above for why they can't just share one controller
    // now that the vertical scrollbar sits outside the horizontal one).
    _hScroll.addListener(() {
      if (_hScrollHeader.hasClients &&
          _hScrollHeader.offset != _hScroll.offset) {
        _hScrollHeader.jumpTo(_hScroll.offset);
      }
      if (_hScrollBar.hasClients && _hScrollBar.offset != _hScroll.offset) {
        _hScrollBar.jumpTo(_hScroll.offset);
      }
    });
    _hScrollBar.addListener(() {
      if (_hScroll.hasClients && _hScroll.offset != _hScrollBar.offset) {
        _hScroll.jumpTo(_hScrollBar
            .offset); // dragging the pinned scrollbar itself must also scroll the content
      }
    });
    _dataLink = TComponentDataLink();
    // @@@ 2026-08-10 fix: _columns must be ready BEFORE _dataLink.dataSource
    // is assigned. Setting dataSource can synchronously trigger
    // activeChanged() (if the dataset is already open at that point),
    // which calls _onDataSetOpen() — and _onDataSetOpen() now calls
    // _columns.linkFields(). The original code created _columns last;
    // when activeChanged() fires early like this, _columns is still an
    // uninitialized `late final` field, throwing LateInitializationError.
    _columns = widget.columns ?? TDBGridColumns(this);
    _columns.host = this;
    _dataLink.onDataSetOpen = _onDataSetOpen;
    // @@@ 2026-08-10 fix: onNewDataSet was never wired up before. See the
    // full root-cause note above _onDataSetOpen() below for why this
    // caused the grid to silently stop re-rendering after a requery.
    _dataLink.onNewDataSet = _onDataSetOpen;
// aa ??? issue
    // Doesn't repaint on close: reloading a dataset is close→open; if
    // setState fired immediately on close, it would flash "no data"
    // first, then flash back. Repainting is deferred until open
    // completes (_onDataSetOpen), so the screen goes straight from the
    // old data to the new data with no flash.
    _dataLink.onDataSetClose = (_) {};
// zz ??? issue
    _dataLink.onDataSetChanged = _onChanged;
    _dataLink.onDataSetScrolled = (TDataSet ds, int dist) => _onChanged(ds);
    _dataLink.onRecordChanged = (TField? f) => _refresh();
    _dataLink.onEditingChanged = _onChanged;
    _dataLink.onLayoutChanged = _onChanged;
    _dataLink.dataSource = widget.dataSource;
// aa ??? issue
    // The buffer window needs to be a bit larger to display multiple
    // rows at once (the default is too small — the grid could only
    // paint a single row).
    _dataLink.bufferCount = 25;
// zz ??? issue

    _columns.linkFields();
  }

  @override
  void didUpdateWidget(TDBGrid old) {
    super.didUpdateWidget(old);
    if (!identical(old.dataSource, widget.dataSource)) {
      _dataLink.dataSource = widget.dataSource;
    }
  }

  @override
  void dispose() {
    // @@@ Safety net: if destroyed mid-edit (e.g. the user closes the
    //     screen directly), at least write the current cell's value back
    //     into the field and post it into the change log, so the outer
    //     save flow still has a chance to pick it up.
    //     Can't await here, so onRowPost isn't called (it's async, and
    //     the widget is already being destroyed).
    final ds = _dataLink.dataSet;
    final col = _editingCol;
    if (ds != null && col != null) {
      try {
        if (ds.state != TDataSetState.dsEdit &&
            ds.state != TDataSetState.dsInsert) {
          if (ds.canModify) ds.edit();
        }
        col.field?.text = _editController.text;
        if (ds.state == TDataSetState.dsEdit ||
            ds.state == TDataSetState.dsInsert) {
          ds.post();
        }
      } catch (_) {
        // The dataset may already be invalid mid-destruction; safe to swallow
      }
    }
    _dataLink.free();
    _editController.dispose();
    _gridFocus.dispose();
    _hScroll.dispose();
    _vScroll.dispose();
    _hScrollHeader.dispose();
    _hScrollBar.dispose();
    super.dispose();
  }

  void _onChanged(TDataSet ds) {
    if (mounted) setState(() {});
  }

  // @@@ When the dataset re-opens (e.g. _openSql's close→open reload),
  //     activeChanged zeroes out dataLink's bufferCount during the close
  //     phase. If this isn't restored, recalcBufListSize loads too small
  //     a buffer window on open → the grid shows empty. Restored here.
// aa ??? issue
  // When the dataset reloads (close→open), close zeroes out dataLink's
  // bufferCount; on open, recalcBufListSize then can't load data into
  // the buffer → the grid paints 0 rows (symptom: the data clearly
  // loaded successfully with rows=N, but the screen is blank). Restore
  // bufferCount once open completes.
  //
  // @@@ 2026-08-10 fix — root cause of "double-click locates the master
  // record correctly, the detail grid's data clearly loads (recordCount
  // is correct), but the grid stays visually blank until you switch tabs
  // away and back":
  //
  // TDBGrid links each column to its TField object (col.field) exactly
  // once, in initState() → _columns.linkFields(). But when a WML
  // <onevent type="afterscroll">/<go> handler triggers a dataset requery
  // (dbquery()'s close→open cycle), the dataset — running in default-
  // fields mode — creates a BRAND NEW set of TField objects to replace
  // the old ones. The grid's cached col.field references still point at
  // the old, now-detached TField objects, which are no longer connected
  // to the live dataset — so every cell reads back empty.
  //
  // Switching tabs away and back "fixes" it only because that tears down
  // and recreates the whole grid State, re-running initState() →
  // linkFields() against whatever TField objects are current at that
  // moment. The real fix is to re-run linkFields() every time the
  // dataset (re)opens, not just once at widget creation — that's the
  // _columns.linkFields() call added below.
  void _onDataSetOpen(TDataSet ds) {
    if (_dataLink.bufferCount < 25) {
      _dataLink.bufferCount =
          25; // the setter triggers recalcBufListSize + calcRange while active
    }
    _columns.linkFields();
    if (mounted) setState(() {});
  }
// zz ??? issue

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ---- IDBGridHost implementation ------------------------------------------------------
  @override
  TComponentDataLink get dataLink => _dataLink;

  @override
  bool get readOnly => widget.readOnly;

  @override
  TDBGridOptions get options => widget.options;

  @override
  int get defaultColWidth => kDefaultColWidth;

  @override
  bool get isLoading => false;

  @override
  void layoutChanged() {
    if (_layoutLock == 0 && mounted) setState(() {});
  }

  @override
  void beginLayout() => _layoutLock++;

  @override
  void endLayout() {
    if (_layoutLock > 0) _layoutLock--;
    if (_layoutLock == 0 && mounted) setState(() {});
  }

  @override
  TColumnButtonStyle defaultEditorStyle(
      TColumnButtonStyle style, TField? field) {
    // Decides the actual editor style based on the field type
    // (corresponds to TCustomDBGrid.DefaultEditorStyle)
    if (style != TColumnButtonStyle.cbsAuto) return style;
    if (field != null) {
      if (field.dataType == TFieldType.ftBoolean) {
        return TColumnButtonStyle.cbsCheckboxColumn;
      }
      final col = _columns.columnFromField(field);
      if (col != null && col.getPickList().count > 0) {
        return TColumnButtonStyle.cbsPickList;
      }
    }
    return TColumnButtonStyle.cbsAuto;
  }

  // ---- Column resolution: empty columns → auto-generate all columns from the dataset -----------------------
  List<TColumn> get _activeColumns {
    if (_columns.count > 0) {
      return [
        for (var i = 0; i < _columns.count; i++)
          if (_columns[i].visible) _columns[i]
      ];
    }
    // Automatic columns: in the dataset's field order
    final ds = _dataLink.dataSet;
    final result = <TColumn>[];
    if (ds != null) {
      for (var i = 0; i < ds.fieldCount; i++) {
        final f = ds.fields[i];
        if (!f.visible) continue;
        final col = _columns.add();
        col.fieldName = f.fieldName;
        col.isAutomaticColumn = true;
        result.add(col);
      }
    }
    return result;
  }

  // ---- Reads a given column's display value for a given row (relative to the buffer index) ----------------------------
  String _cellText(int rowOffset, TColumn col) {
    final ds = _dataLink.dataSet;
    if (ds == null) return '';
    // Temporarily move the active record to the target row to read the value (TDataLink.activeRecord)
    final savedActive = _dataLink.activeRecord;
    String text = '';
    try {
      _dataLink.activeRecord = rowOffset;
      final f = col.field;
      text = f?.displayText ?? '';
    } catch (_) {
      text = '';
    } finally {
      _dataLink.activeRecord = savedActive;
    }
    return text;
  }

  int get _rowCount => _dataLink.recordCount;

  // ---- Excel-style: single click selects a cell ----------------------------------------------------
  // @@@ Selects a cell (without entering edit mode): moves the cursor to
  //     this row, remembers the selected cell, and grabs focus for the
  //     grid, so Enter/F2/typing/arrow keys work afterward.
  Future<void> _selectCell(int rowOffset, TColumn col) async {
// aa ??? issue
    // On a double-click, onTap and onDoubleTap compete in the gesture
    // arena, and onTap sometimes fires after onDoubleTap — an edit box
    // just opened by _beginEdit would then get immediately closed by the
    // _commitEdit() below, with the symptom of "double-click sometimes
    // works, sometimes doesn't, can't enter edit mode".
    // If already editing this exact cell, just ignore — don't commit, don't move the cursor.
    if (_editingCol != null &&
        _editingRow == rowOffset &&
        identical(_editingCol, col)) {
      return;
    }
// zz ??? issue
    // @@@ Clicking a different cell while editing: commit the current
    //     edit first (including onRowPost to save) before moving the
    //     cursor, otherwise moveBy might race ahead of the write-back and
    //     the value gets lost or written to the wrong record.
    if (_editingCol != null) {
      await _commitEdit();
      if (!mounted) return;
    }
    _selectRow(rowOffset); // includes moveBy + setState
    _selRow = rowOffset;
    _selCol = col;
    _gridFocus.requestFocus();
    _focusGrid(); // @@@ safety net: if something else focusable steals focus later this frame, grab it back next frame
    if (mounted) setState(() {});
  }

  // @@@ The selected-cell outline (blue box). Not drawn for the cell
  //     currently being edited (it already has its own input-box border).
  Widget _selWrap(int rowOffset, TColumn col, Widget child) {
    final selected = _selRow == rowOffset &&
        identical(_selCol, col) &&
        !_isEditingCell(rowOffset, col);
    if (!selected) return child;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade600, width: 2),
      ),
      child: child,
    );
  }

  // @@@ Returns focus to the grid (used after editing ends, so the
  //     keyboard flow isn't interrupted). Deferred to the next frame:
  //     at this moment the edit cell's TextField may not have been
  //     removed yet, and grabbing focus now would just get snatched back.
  void _focusGrid() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Focus should stay on the cell's TextField while editing — don't steal it.
      if (mounted && _editingCol == null) _gridFocus.requestFocus();
    });
  }

  // @@@ Starting from col (inclusive), searches in the given direction
  //     for the first editable column and enters edit mode on it.
  //     Cell selection can land on a read-only column (Excel allows
  //     selecting a read-only cell too), but when Tab/Enter should enter
  //     edit mode, read-only columns must be skipped — otherwise
  //     _beginEdit just returns immediately and the key press looks like
  //     it did nothing.
  //     Returns false if no editable column is found, letting the caller
  //     let the key press through.
  bool _beginEditFrom(int rowOffset, TColumn col, {bool forward = true}) {
    final cols = _activeColumns;
    if (cols.isEmpty) return false;
    var i = cols.indexOf(col);
    if (i < 0) i = 0;
    while (i >= 0 && i < cols.length) {
      if (!cols[i].readOnly) {
        _selCol = cols[i];
        _beginEdit(rowOffset, cols[i]);
        return true;
      }
      i += forward ? 1 : -1;
    }
    return false;
  }

  // ---- Excel-style: keyboard handling while not editing ----------------------------------------
  KeyEventResult _onGridKey(FocusNode node, KeyEvent ev) {
    if (ev is! KeyDownEvent && ev is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final k = ev.logicalKey;
// aa ??? issue
    // This used to be "always return ignored while editing". But right
    // after the edit box opens, focus may not have actually moved there
    // yet (requestFocus has a one-frame delay on Web, or gets grabbed by
    // another node). At that moment Tab would fall through here and be
    // let through → the default traversal takes over and focus jumps
    // straight out of the grid, while the edit box is still visible on
    // screen — it looks like "Tab does absolutely nothing".
    // So Tab / Shift+Tab / Esc still need to be handled here while
    // editing; only other keys are passed on to the edit box.
    if (_editingCol != null) {
      if (k == LogicalKeyboardKey.tab) {
        _editNextCol(prev: HardwareKeyboard.instance.isShiftPressed);
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.escape) {
        _cancelEdit();
        _focusGrid();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
// zz ??? issue

    final cols = _activeColumns;
    if (cols.isEmpty) return KeyEventResult.ignored;
    // No cell selected yet → give it a starting point.
    _selCol ??= cols.first;
    _selRow ??= _dataLink.activeRecord;

    // Enter / F2 → enter edit mode (with the original value)
    if (k == LogicalKeyboardKey.enter ||
        k == LogicalKeyboardKey.numpadEnter ||
        k == LogicalKeyboardKey.f2) {
      if (_beginEditFrom(_selRow!, _selCol!)) return KeyEventResult.handled;
      return KeyEventResult.ignored;
    }
    // @@@ Tab / Shift+Tab: while a cell is selected, enter edit mode
    //     directly (read-only columns are automatically skipped in that
    //     direction), without letting focus jump out of the grid. Once
    //     editing, pressing Tab again goes through the editing-state
    //     _editNextCol instead.
    if (k == LogicalKeyboardKey.tab) {
      final fwd = !HardwareKeyboard.instance.isShiftPressed;
      if (!fwd) _moveSel(-1, 0);
      if (_beginEditFrom(_selRow!, _selCol!, forward: fwd)) {
        return KeyEventResult.handled;
      }
      return KeyEventResult
          .ignored; // the whole row is non-editable → let focus jump out of the grid normally
    }
    // Arrow keys → move the selected cell
    if (k == LogicalKeyboardKey.arrowUp) {
      _moveSel(0, -1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowDown) {
      _moveSel(0, 1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowLeft) {
      _moveSel(-1, 0);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowRight) {
      _moveSel(1, 0);
      return KeyEventResult.handled;
    }
    // Printable character → enter edit mode, replacing the original
    // value with the typed character (Excel-style direct-typing overwrite)
    final ch = ev.character;
    if (ch != null &&
        ch.length == 1 &&
        ch.codeUnitAt(0) >= 0x20 && // excludes control characters
        !HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isMetaPressed &&
        !HardwareKeyboard.instance.isAltPressed) {
      // @@@ Read-only columns are automatically skipped to the right;
      //     once an editable column is found, the first character is carried into it.
      if (_beginEditFrom(_selRow!, _selCol!)) {
        _editController.value = TextEditingValue(
          text: ch,
          selection: TextSelection.collapsed(offset: ch.length),
        );
        if (mounted) setState(() {});
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  // @@@ Moves the selected cell. dCol/dRow ∈ {-1,0,1}. Moving up/down also moves the dataset's cursor.
  void _moveSel(int dCol, int dRow) {
    final cols = _activeColumns;
    if (dCol != 0 && _selCol != null) {
      final idx = cols.indexOf(_selCol!);
      final ni = (idx + dCol).clamp(0, cols.length - 1);
      _selCol = cols[ni];
    }
    if (dRow != 0) {
      final target = _dataLink.activeRecord + dRow;
      if (target >= 0 && target < _rowCount) {
        _dataLink.moveBy(dRow);
        _selRow = _dataLink.activeRecord;
      }
    }
    if (mounted) setState(() {});
  }

  // ---- Selecting a row: moves the dataset's cursor to that row ----------------------------------------
  void _selectRow(int rowOffset) {
    final delta = rowOffset - _dataLink.activeRecord;
    if (delta != 0) _dataLink.moveBy(delta);
    if (mounted) setState(() {});
  }

  // ---- Entering inline edit mode (double-click / Enter / F2 / typing) ----------------------------
  void _beginEdit(int rowOffset, TColumn col, {String? initialChar}) {
    if (widget.readOnly || col.readOnly) return;
    if (!widget.options.contains(TDBGridOption.dgEditing)) return;
    _selectRow(rowOffset);
    final ds = _dataLink.dataSet;
    if (ds == null || !ds.canModify) return;
    ds.edit();
    _editingRow = rowOffset;
    _editingCol = col;
    // @@@ Syncs the selected cell to the edit cell, so the blue outline stays put after editing ends.
    _selRow = rowOffset;
    _selCol = col;
    if (initialChar != null) {
      // Excel-style: typing directly overwrites the original value, cursor lands at the end.
      _editController.value = TextEditingValue(
        text: initialChar,
        selection: TextSelection.collapsed(offset: initialChar.length),
      );
    } else {
      // @@@ Entering edit mode via double-click/Enter/F2: carries in the
      //     original value with everything selected, so typing directly overwrites it.
      _setEditTextSelectedAll(col.field?.text ?? '');
    }
    setState(() {});
  }

  // @@@ Sets the edit box's content and selects it all (used when
  //     entering edit mode / hopping fields via Tab). Selecting
  //     everything means typing directly overwrites it; the user can
  //     press Home or an arrow key to deselect if they want to fine-tune instead.
  void _setEditTextSelectedAll(String t) {
    _editController.value = TextEditingValue(
      text: t,
      selection: TextSelection(baseOffset: 0, extentOffset: t.length),
    );
  }

  // @@@ Makes sure the dataset is in edit/insert state before writing
  //     back to a field (selecting/tabbing through a WapLookupBox cell
  //     might not have gone through _beginEdit's ds.edit()).
  void _ensureEditing() {
    final ds = _dataLink.dataSet;
    if (ds == null) return;
    if (ds.state != TDataSetState.dsEdit &&
        ds.state != TDataSetState.dsInsert) {
      if (ds.canModify) ds.edit();
    }
  }

  Future<void> _commitEdit() async {
    final ds = _dataLink.dataSet;
    final col = _editingCol;
// aa ??? issue
    // This used to be "await onRowPost() before clearing
    // _editingRow/_editingCol". If onRowPost ever threw (save failure,
    // connection lost, etc.), the exception propagated outward and these
    // two fields were left set forever; and _onGridKey's first check is
    // `if (_editingCol != null) return ignored` — so left/right arrows,
    // typing-to-overwrite, and F2 all got blocked, with the symptom
    // being "the grid's keyboard suddenly stops responding entirely".
    // Changed to: write the field value back and post it, clear the edit
    // state immediately, then do the async save, wrapped in try/catch so
    // an exception can't prevent the UI state from being restored.
    _editingRow = null;
    _editingCol = null;
    if (ds != null && col != null) {
      _ensureEditing();
      col.field?.text = _editController.text;
      if (ds.state == TDataSetState.dsEdit ||
          ds.state == TDataSetState.dsInsert) {
        ds.post();
      }
    }
    if (mounted) setState(() {});
    if (ds != null && col != null && widget.onRowPost != null) {
      try {
        await widget.onRowPost!();
      } catch (e) {
        debugPrint('[TDBGrid] onRowPost failed: $e');
        rethrow; // lets the caller still see the error, but the edit state has already been restored
      }
    }
// zz ??? issue
  }

  // @@@ Writes back the current edit cell (without ending edit mode or
  //     clearing _editingRow), used to save before Tab hops to another column
  Future<void> _saveCurrentCell(String value) async {
    final ds = _dataLink.dataSet;
    final col = _editingCol;
    if (ds != null && col != null) {
      _ensureEditing();
      col.field?.text = value;
    }
  }

  // @@@ Tab: saves the current cell → moves to the next editable column
  //     in the same row; if there's no next column, posts and moves to the next row
  Future<void> _editNextCol({bool prev = false}) async {
    final cols = _activeColumns;
    final cur = _editingCol;
    final row = _editingRow;
    if (cur == null || row == null) return;
    await _saveCurrentCell(_editController.text);

    final curIdx = cols.indexOf(cur);
    if (curIdx < 0) return;

    // Find the next (or previous) non-read-only column
    int i = curIdx;
    while (true) {
      i += prev ? -1 : 1;
      if (i < 0 || i >= cols.length) {
        if (prev) {
          // Went past the start of the row: end editing
          await _commitEdit();
          return;
        }
// aa ??? issue
        // Tab past the end of the row: post this row, then **actually
        // save it**, and only then hop to the next row and keep editing.
        //
        // This used to deliberately not call onRowPost here, because it
        // would applyUpdates + reload the entire dataset, and the cursor
        // would jump unpredictably on the spot (symptom: moving between
        // rows jumps around erratically). But the cost of that was: moving
        // rows only went into the change log and never got written to the
        // DB — leaving the page mid-way meant the data was gone.
        // Now: the cursor position is remembered before saving, and moveBy
        // restores it after the await completes.
        final ds = _dataLink.dataSet;
        if (ds == null) {
          await _commitEdit();
          return;
        }
        // This cell's value has already been written to the field by _saveCurrentCell; post the whole row here.
        if (ds.state == TDataSetState.dsEdit ||
            ds.state == TDataSetState.dsInsert) {
          ds.post();
        }

        // @@@ Saves immediately on row change. If onRowPost is null
        //     (a non-main dataset that doesn't have an _XXXPost), this
        //     whole block is skipped, matching the pre-change behavior.
        if (widget.onRowPost != null) {
          final want =
              _dataLink.activeRecord; // the cursor position before saving
          await widget.onRowPost!();
          if (!mounted) return;
          // A reload usually resets the cursor to the first record → restore it to the original row.
          // @@@ _rowCount is a getter; what's read here is already the
          //     post-reload count, so it can't go out of range.
          //     clamp is used rather than "leave it alone if out of
          //     range": if saving reduced the row count (e.g. a record
          //     was deleted at the same time), the original index could
          //     be out of range, in which case moving to the nearest
          //     valid row is more natural than leaving the cursor on the
          //     first record.
          final now = _dataLink.activeRecord;
          final maxIndex = _rowCount - 1;
          if (maxIndex >= 0) {
            final target = want < 0 ? 0 : (want > maxIndex ? maxIndex : want);
            final delta = target - now;
            if (delta != 0) _dataLink.moveBy(delta);
          }
        }

        // First checks whether there IS a next row before deciding whether to move the cursor.
        // Must not call next() first and then check eof — that would leave
        // the cursor sitting at EOF, and afterward _commitEdit's
        // _ensureEditing would re-fetch the record for editing, and after
        // the reload it would land back on the last record again (symptom:
        // "jumps back to the last record" when tabbing out).
        final isLastRow = _dataLink.activeRecord >= _rowCount - 1;
        if (isLastRow) {
// aa ### flutter extension
          // Tab on the last row → automatically inserts the next record,
          // with the cursor landing on the first editable column, so data
          // entry can continue in one flow without touching the mouse.
          // Conditions: onRowInsert is set (the page's onnewrecord
          //       handler), editing is allowed, and dgDisableInsert isn't
          //       set (LCL uses this option to turn off auto-insert).
          final canAutoInsert = widget.onRowInsert != null &&
              !widget.readOnly &&
              widget.options.contains(TDBGridOption.dgEditing) &&
              !widget.options.contains(TDBGridOption.dgDisableInsert);
          if (canAutoInsert) {
            _editingRow = null;
            _editingCol = null;
            _editController.clear();
            if (mounted) setState(() {});
            // The row has already been posted + saved via onRowPost above; just insert here.
            await widget.onRowInsert!();
            if (!mounted) return;
            final firstNew = _firstEditableCol(cols);
            if (firstNew != null) {
              // After insert, the cursor lands on the new record
              _editingRow = _dataLink.activeRecord;
              _editingCol = firstNew;
              _selRow = _editingRow;
              _selCol = firstNew;
              _setEditTextSelectedAll(firstNew.field?.text ?? '');
              if (mounted) setState(() {});
            }
            return;
          }
// zz ### flutter extension
          // Last row → end editing, save, hand focus to the widget after the grid.
          _editingRow = null;
          _editingCol = null;
          _editController.clear();
          if (widget.onRowPost != null) await widget.onRowPost!();
          if (mounted) setState(() {});
          // @@@ Deferred until this frame finishes painting (the edit
          //     cell has been removed and the grid has re-rendered)
          //     before moving focus, otherwise focus is still stuck on
          //     the edit cell that's about to be destroyed and can't land
          //     on the destination.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (widget.onExitLastRow != null) {
              widget
                  .onExitLastRow!(); // the caller explicitly specified the next widget
            } else {
              FocusScope.of(context)
                  .nextFocus(); // no callback given, so hand off to the default traversal
            }
          });
          return;
// zz ??? issue
        }

        ds.next();
        // Starts from the first editable column
        final firstEditable = _firstEditableCol(cols);
        if (firstEditable == null) {
          _cancelEdit();
          return;
        }
        _editingRow = _dataLink.activeRecord;
        _editingCol = firstEditable;
        _selRow = _editingRow;
        _selCol = firstEditable;
        if (ds.state == TDataSetState.dsBrowse) {
          if (ds.canModify) ds.edit();
        }
        _setEditTextSelectedAll(firstEditable.field?.text ?? '');
        if (mounted) setState(() {});
        return;
      }
      final c = cols[i];
      if (!c.readOnly) {
        // Enters the next editable column (doesn't re-post, stays in the same edit state)
        _editingCol = c;
        _selCol = c; // @@@ the blue outline follows along
        _setEditTextSelectedAll(c.field?.text ?? '');
        if (mounted) setState(() {});
        return;
      }
    }
  }

  // @@@ Finds the first non-read-only column (used to land on an
  //     editable column at the start of a row after Tab moves to a new row)
  TColumn? _firstEditableCol(List<TColumn> cols) {
    for (final c in cols) {
      if (!c.readOnly) return c;
    }
    return null;
  }

  void _cancelEdit() {
    _dataLink.dataSet?.cancel();
    _editingRow = null;
    _editingCol = null;
    if (mounted) setState(() {});
  }

  // ---- build -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final ds = _dataLink.dataSet;
    final cols = _activeColumns;
    final showTitles = widget.options.contains(TDBGridOption.dgTitles);

    Widget table;
    if (ds == null || !ds.active) {
      table = const Center(child: Text("(no data)"));
    } else {
// aa ### flutter extension
      // @@@ 2026-08-10 fix: keep both scrollbars pinned to the grid's
      // visible edges (right / bottom) like a normal desktop window,
      // instead of scrolling out of view along with content on the other
      // axis. The vertical scrollbar directly wraps the real vertical
      // SingleChildScrollView (as the OUTERMOST layer) — since horizontal
      // scrolling happens entirely INSIDE it, the vertical scrollbar
      // never moves regardless of horizontal scroll position, and this is
      // the plain, well-tested Scrollbar+SingleChildScrollView pattern.
      // The horizontal scrollbar can't use that same trick (nesting it
      // inside the vertical scroll would drag it off-screen once you
      // scroll down), so it's pulled out as a separate, fixed strip below
      // the vertical-scroll area, wrapping its own tiny SingleChildScrollView
      // sized to the exact same totalWidth as the real content and kept in
      // sync with the real _hScroll via a listener (same proven trick
      // already used for the header row above).
      final totalWidth = _totalColsWidth(cols);
      final gridH = widget.height ?? 300;
      const kScrollbarThickness = 14.0;
      final bodyHeight =
          (gridH - (showTitles ? 28 : 0) - kScrollbarThickness - 2)
              .clamp(0.0, double.infinity);
      table = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitles)
            SingleChildScrollView(
              controller: _hScrollHeader,
              scrollDirection: Axis.horizontal,
              physics:
                  const NeverScrollableScrollPhysics(), // only follows the body's movement in sync, not directly draggable by the user
              child: SizedBox(width: totalWidth, child: _buildHeader(cols)),
            ),
          SizedBox(
            height: bodyHeight,
            child: Scrollbar(
              controller: _vScroll,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _vScroll,
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  controller: _hScroll,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var r = 0; r < _rowCount; r++) _buildRow(r, cols),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: kScrollbarThickness,
            child: Scrollbar(
              controller: _hScrollBar,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _hScrollBar,
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: totalWidth, height: kScrollbarThickness),
              ),
            ),
          ),
        ],
      );
// zz ### flutter extension
    }

    return Focus(
      focusNode: _gridFocus,
      onKeyEvent: _onGridKey,
      onFocusChange: (has) {
        // @@@ Tab'ing into the grid from elsewhere with nothing selected
        //     yet → pre-select (the current row, first column), so there's
        //     a landing point as soon as the keyboard flow arrives.
        if (has && _selCol == null) {
          final c = _activeColumns;
          if (c.isNotEmpty && mounted) {
            setState(() {
              _selRow = _dataLink.activeRecord;
              _selCol = c.first;
            });
          }
        }
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
          ),
// aa ??? issue
          // The grid's keyboard handling (left/right arrows to move
          // cells, typing to overwrite, Enter/F2) all depends on
          // _gridFocus actually gaining focus. This used to only request
          // focus when a "cell" was clicked (_selectCell) — clicking the
          // header, blank areas, or near the scrollbar wouldn't — so it
          // looked like the user had clicked the grid but the keyboard
          // just didn't respond. Changed to: any pointer-down anywhere
          // inside the grid grabs focus. Doesn't steal it while editing
          // (focus should stay in the edit box). Uses Listener rather
          // than GestureDetector, so it doesn't participate in the
          // gesture arena and doesn't interfere with the existing tap /
          // doubleTap handling.
          child: Listener(
            onPointerDown: (_) {
              if (_editingCol == null && !_gridFocus.hasFocus) {
                _gridFocus.requestFocus();
              }
            },
            // @@@ 2026-08-14 fix: the header row/content used to sit flush
            // against the outer frame (no gap at all between DecoratedBox's
            // border and the table), so the header row's gray background
            // looked like it was "crushing" the frame's border line. Added
            // 1px of padding to leave a visible gap.
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: table,
            ),
          ),
// zz ??? issue
        ),
      ),
    );
  }

  Widget _buildHeader(List<TColumn> cols) {
    return Container(
      color: Colors.grey.shade200,
      child: Row(
        children: [
          for (final col in cols)
            _cell(
              col.title.caption,
              col.width.toDouble(),
              alignment: _align(col.title.alignment),
              bold: true,
            ),
        ],
      ),
    );
  }

  Widget _buildRow(int rowOffset, List<TColumn> cols) {
    final isCurrent = rowOffset == _dataLink.activeRecord;
    final showColLines = widget.options.contains(TDBGridOption.dgColLines);
    final showRowLines = widget.options.contains(TDBGridOption.dgRowLines);

// aa ??? issue
    // Moves the cursor to this row once, reads every column's display
    // text, then moves it back (the cursor only moves once). Originally
    // each cell called _cellText separately (moving the cursor to read
    // the value, then moving it back) = 2 × column count moves, which got
    // slow to repaint with many rows. Here the whole row is read in one pass.
    final texts = <String>[];
    final savedActive = _dataLink.activeRecord;
    try {
      _dataLink.activeRecord = rowOffset;
      for (final col in cols) {
        try {
          texts.add(col.field?.displayText ?? '');
        } catch (_) {
          texts.add("");
        }
      }
    } finally {
      _dataLink.activeRecord = savedActive;
    }
// zz ??? issue

    return InkWell(
      // @@@ Key point: InkWell defaults to requestFocus'ing itself on tap,
      //     which would override the grid focus _selectCell just grabbed
      //     → a cell gets selected but typing does nothing.
      //     canRequestFocus: false makes it only do the ripple effect,
      //     leaving focus alone.
      canRequestFocus: false,
      onTap: () => _selectRow(rowOffset),
      onDoubleTap: widget.onRowActivate != null
          ? () {
              _selectRow(rowOffset); // positions activeRecord first
              widget.onRowActivate!(_dataLink.activeRecord);
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isCurrent ? Colors.blue.shade50 : null,
          border: showRowLines
              ? Border(bottom: BorderSide(color: Colors.grey.shade300))
              : null,
        ),
        child: Row(
          children: [
            for (var ci = 0; ci < cols.length; ci++)
              GestureDetector(
                // @@@ opaque: tapping the blank padding inside a cell
                //     (not just the text) should also count as selecting
                //     it, otherwise it only responds when the tap lands
                //     directly on the text.
                behavior: HitTestBehavior.opaque,
                // @@@ A single tap = Excel-style cell selection (doesn't
                //     enter edit mode). Also moves the cursor to this row
                //     and grabs grid focus back, so subsequent
                //     Enter/F2/typing/arrow keys work.
                //     A grid with onRowActivate set (double-click on the
                //     master record opens a window) keeps its original
                //     row-level behavior and doesn't wire up cell
                //     selection, to avoid interfering with double-click.
                onTap: widget.onRowActivate != null
                    ? null
                    : () => _selectCell(rowOffset, cols[ci]),
                onDoubleTap: widget.onRowActivate != null
                    ? null // handed to the row-level onRowActivate
                    : () => _beginEdit(rowOffset, cols[ci]),
                child: _isEditingCell(rowOffset, cols[ci])
                    ? _editCell(cols[ci])
                    : _selWrap(
                        rowOffset,
                        cols[ci],
                        _cell(
                          texts[ci],
                          cols[ci].width.toDouble(),
                          alignment: _align(cols[ci].alignment),
                          rightBorder: showColLines,
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isEditingCell(int rowOffset, TColumn col) =>
      _editingRow == rowOffset && identical(_editingCol, col);

// aa ??? issue
  // Column-hopping via Tab used to rely entirely on _editCell's
  // Focus.onKeyEvent to intercept it, but on Flutter Web this often never
  // arrives at the TextField — Web's text input goes through a hidden DOM
  // input, and Tab can get consumed by the browser's native traversal
  // before it ever reaches Flutter's key handler.
  // (TDBEdit's Tab in the first half of the file works fine, because it
  // goes through Flutter's default traversal rather than a custom intercept.)
  //
  // Fixed by intercepting at the Intent layer instead: the default Tab
  // shortcut already dispatches NextFocusIntent / PreviousFocusIntent —
  // these two Actions are overridden here, so the column-hopping logic is
  // guaranteed to be invoked. Actions are found as long as they're an
  // ancestor of the primary focus, so wrapping just the edit cell is enough.
  Widget _tabActions({required Widget child}) {
    return Actions(
      actions: <Type, Action<Intent>>{
        NextFocusIntent: CallbackAction<NextFocusIntent>(
          onInvoke: (_) {
            _editNextCol();
            return null;
          },
        ),
        PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
          onInvoke: (_) {
            _editNextCol(prev: true);
            return null;
          },
        ),
      },
      child: child,
    );
  }
// zz ??? issue

  Widget _editCell(TColumn col) {
    final w = col.width.toDouble();
    // @@@ Has a lookup config → uses WapLookupBox (forGrid); item-number
    //     columns etc. get a dropdown
    final spec = widget.lookupResolver?.call(col.fieldName);
    if (spec != null) {
      return _tabActions(
        child: SizedBox(
          width: w,
          height: 28,
          child: WapLookupBox(
            // @@@ key changes with "row+column": forces a rebuild on row
            //     change, so autofocus fires again.
            key: ValueKey("edit_${_dataLink.activeRecord}_${col.fieldName}"),
            value: col.field?.text ?? '',
            width: w,
            forGrid: true,
            autofocus:
                true, // @@@ auto-focuses on entering edit mode (including after a row change via Tab)
            lookupColumns: spec.rows,
            colWidths: spec.colWidths,
            onChanged: (k) async {
              await _saveCurrentCell(k);
              spec.onPicked?.call(k);
              // linked updates in the same row after picking (e.g.
              // description/unit filled in by onRowPost/linking logic), write back and refresh
              if (mounted) setState(() {});
            },
            onTab: () => _editNextCol(),
            onTabPrev: () => _editNextCol(prev: true),
          ),
        ),
      );
    }
    // @@@ No lookup config → plain text, intercepts Tab to hop columns
    return _tabActions(
      child: SizedBox(
        width: w,
        height: 28,
        child: Focus(
          // @@@ key changes with "row+column": forces a rebuild on row change, so autofocus fires again.
          key: ValueKey("edit_${_dataLink.activeRecord}_${col.fieldName}"),
          onKeyEvent: (node, ev) {
            if (ev is KeyDownEvent && ev.logicalKey == LogicalKeyboardKey.tab) {
              final prev = HardwareKeyboard.instance.isShiftPressed;
              _editNextCol(prev: prev);
              return KeyEventResult.handled;
            }
            // @@@ Esc → cancels editing, focus returns to the grid (keeps the Excel-style keyboard flow)
            if (ev is KeyDownEvent &&
                ev.logicalKey == LogicalKeyboardKey.escape) {
              _cancelEdit();
              _focusGrid();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: _CellTextField(
            controller: _editController,
            // @@@ After Enter submits, focus returns to the grid, with the
            //     cursor staying on the same cell, so arrow keys/Enter can
            //     be pressed again.
            onSubmitted: (_) async {
              await _commitEdit();
              _focusGrid();
            },
            // @@@ Submits when tapping elsewhere, but does "not" grab focus
            //     back (the user might be about to tap a widget outside the grid).
            onTapOutside: (_) => _commitEdit(),
          ),
        ),
      ),
    );
  }

  // @@@ Sums all column widths, used to stretch out a fixed total width so
  //     horizontal scrolling works and the header stays aligned with the data.
  double _totalColsWidth(List<TColumn> cols) {
    var w = 0.0;
    for (final c in cols) {
      w += c.width.toDouble();
    }
    return w;
  }

  Widget _cell(String text, double width,
      {Alignment alignment = Alignment.centerLeft,
      bool bold = false,
      bool rightBorder = false}) {
    return Container(
      width: width,
      height: 28,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: rightBorder
          ? BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)))
          : null,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
      ),
    );
  }

  Alignment _align(TAlignment a) {
    switch (a) {
      case TAlignment.taRightJustify:
        return Alignment.centerRight;
      case TAlignment.taCenter:
        return Alignment.center;
      case TAlignment.taLeftJustify:
        return Alignment.centerLeft;
    }
  }
}
// zz !!! not fully translated

// ─────────────────────────────────────────────────────────────────────────────
// aa ??? issue
//  _CellTextField —— the grid's inline edit box.
//
//  There is exactly one reason it exists: **to make the FocusNode's
//  lifecycle follow the widget's own lifecycle**.
//
//  Two earlier approaches, sharing a node held in the grid's State, both failed:
//    1. Using only autofocus: Flutter's autofocus only kicks in when
//       "no node in the owning FocusScope currently holds focus". The grid
//       grabs focus with _gridFocus first, so the scope already has a
//       holder → autofocus is skipped, and the edit box can never gain focus.
//    2. Sharing one node: when switching columns, the old edit box hadn't
//       been unmounted yet while the new one grabbed the same node —
//       the node ended up with primary focus, but EditableText never
//       finished TextInput.attach — the cursor and selection highlight
//       were there, but typing did absolutely nothing.
//
//  With the node now owned by this widget itself, whenever the outer
//  ValueKey("edit_<row>_<col>") changes, Flutter guarantees "the old
//  widget's dispose() runs first, then the new one's initState() runs" —
//  the old and new nodes can never overlap; requestFocus is called in
//  initState's post-frame, so EditableText runs through the full
//  TextInput.attach from scratch, guaranteeing the input channel gets
//  established. The grid side no longer has to manage the node manually.
// zz ??? issue
// ─────────────────────────────────────────────────────────────────────────────
class _CellTextField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final TapRegionCallback? onTapOutside;

  const _CellTextField({
    required this.controller,
    this.onSubmitted,
    this.onTapOutside,
  });

  @override
  State<_CellTextField> createState() => _CellTextFieldState();
}

class _CellTextFieldState extends State<_CellTextField> {
  // Every time editing starts, this is a brand-new, dedicated node
  final FocusNode _node = FocusNode(debugLabel: 'TDBGridCellEdit');

  @override
  void initState() {
    super.initState();
    // Doesn't rely on autofocus's scope check; requests focus actively once the old node is released and the scope switch is complete.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _node.requestFocus();
    });
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _node,
      controller: widget.controller,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        border: OutlineInputBorder(),
      ),
      onSubmitted: widget.onSubmitted,
      onTapOutside: widget.onTapOutside,
    );
  }
}
