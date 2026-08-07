// ═════════════════════════════════════════════════════════════════════════════
//  lazarus_dbctrls.dart
//
//  This file is a Dart translation (derivative work) of the following
//  Object Pascal upstream source:
//    Upstream project: Lazarus Component Library (LCL)
//    Upstream file: dbctrls.pp
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
//  lazarus_dbctrls.dart —— translation of the "data layer" of FPC/LCL dbctrls.pp
//  ─────────────────────────────────────────────────────────────────────────
//  Corresponds to: dbctrls.pp (LCL, 1,975 lines)
//
//  Translation scope (per the user's direction of "behavioral equivalence
//  + LCL naming"):
//    ✔ TFieldDataLink —— the shared data-binding core for every
//      single-field DB-aware control (TDBEdit/TDBText/TDBMemo/
//      TDBComboBox/TDBCheckBox…). It overrides TDataLink's event
//      callbacks, translating "the current record's field
//      changed/editable state/pending write" into four events:
//      OnDataChange/OnEditingChange/OnUpdateData/OnActiveChange. The
//      widget layer (TDBEdit, etc.) just hooks these four events to stay
//      two-way synced with the data. Translated faithfully, line by line.
//    ✘ The GUI of TDBEdit/TDBMemo/TDBNavigator… (inherits
//      TCustomMaskEdit/TCustomControl, Canvas/messages) —— implemented
//      Flutter-idiomatically by the Flutter widget layer
//      (lazarus_dbctrls_widget.dart), with property names aligned to LCL
//      (DataField/DataSource/ReadOnly/Field…).
//
//  Translation conventions carried over from earlier files. Property
//  names keep LCL naming (Pascal→Dart still uses lowerCamelCase, but
//  semantic names are aligned: fieldName/canModify/editing…).
//
//  Depends on: lazarus_db.dart (TDataLink/TField/TDataSet/extractFieldName…)
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // @@@ LogicalKeyboardKey / KeyDownEvent
import 'package:flutter/scheduler.dart'; // @@@ SchedulerPhase: if a data change happens during build, defer to post-frame before calling setState

import 'lazarus_db.dart';
// @@@ TDBRadioGroup's appearance is delegated to TRadioGroup (in LCL,
//     TDBRadioGroup also inherits from ExtCtrls' TCustomRadioGroup —
//     dbctrls.pp's uses clause includes ExtCtrls)
import 'lazarus_extctrls.dart' show TRadioGroup;

// ═════════════════════════════════════════════════════════════════════════════
//  TFieldDataLink (dbctrls.pp L43-101, implementation L1599-1943)
// ═════════════════════════════════════════════════════════════════════════════
class TFieldDataLink extends TDataLink {
  TField? _field;
  String _fieldName = '';
  Object? control; // FControl: the attached control (weakly-typed injection from the widget layer)

  // Callbacks (L49-52, 97-100)
  TNotifyEvent? onDataChange;
  TNotifyEvent? onEditingChange;
  TNotifyEvent? onUpdateData;
  TNotifyEvent? onActiveChange;

  // Current State (L54-57)
  bool _editing = false;
  bool _editingSourceSet = false;
  bool _editingSource = false;
  bool _isModified = false;

  // constructor Create (L1859-1865)
  TFieldDataLink() {
    visualControl = true;
  }

  // FieldCanModify (L1599-1625)
  bool fieldCanModify() {
    var result = _field != null;
    if (!result) return false;

    if (_field!.fieldKind == TFieldKind.fkLookup) {
      final fieldList = <TField>[];
      dataSet!.getFieldList(fieldList, _field!.keyFields);
      result = fieldList.isNotEmpty;
      var i = 0;
      while (result && i < fieldList.length) {
        result = fieldList[i].canModify;
        i++;
      }
    } else {
      result = _field!.canModify;
    }
    return result;
  }

  // IsKeyField (L1627-1644)
  bool isKeyField(TField aField) {
    final keyFields = _field!.keyFields;
    final strPos = TIntRef(0); // ExtractFieldName uses 0-based indexing (lazarus_db)
    while (strPos.value < keyFields.length) {
      final keyFieldName = extractFieldName(keyFields, strPos);
      if (aField.fieldName.toUpperCase() == keyFieldName.toUpperCase()) {
        return true;
      }
    }
    return false;
  }

  // GetCanModify (L1652-1658)
  bool get canModify {
    if (fieldCanModify()) {
      return !readOnly;
    }
    return false;
  }

  // Field (L88)
  TField? get field => _field;

  // FieldName (L89, L1664-1676)
  String get fieldName => _fieldName;
  set fieldName(String value) {
    if (_fieldName != value) {
      _fieldName = value;
      updateField();
      if (active) {
        editingChanged();
        reset();
      }
    }
  }

  bool get editing => _editing;
  bool get editingSource => _editingSource;

  // UpdateField (L1678-1684)
  void updateField() {
    if (active && _fieldName != '') {
      _field = dataSet!.fieldByName(_fieldName);
    } else {
      _field = null;
    }
  }

  // ValidateField (L1690-1694)
  void validateField() {
    if (dataSet!.findField(_fieldName) != _field) {
      updateField();
    }
  }

  // ResetEditingSource (L1696-1700)
  void resetEditingSource() {
    _editingSource = false;
    _editingSourceSet = false;
  }

  // ActiveChanged (L1715-1725)
  @override
  void activeChanged() {
    if (_fieldName != '') {
      updateField();
      editingChanged();
      reset();
    }
    onActiveChange?.call(this);
  }

  // EditingChanged (L1751-1768): the real editable state = CanModify &&
  // the underlying Editing; on a state change, resets IsModified and
  // fires OnEditingChange
  @override
  void editingChanged() {
    final realEditState = canModify && super.editing;

    if (_editing != realEditState) {
      _editing = realEditState;
      if (!_editing) {
        _isModified = false;
        resetEditingSource();
      }
      onEditingChange?.call(this);
    }
  }

  // LayoutChanged (L1780-1788)
  @override
  void layoutChanged() {
    validateField();
    if (_field != null) {
      editingChanged();
      recordChanged(null);
    }
  }

  // RecordChanged (L1802-1807): this field changed / the whole record
  // changed / a lookup's key field changed → Reset
  @override
  void recordChanged(TField? aField) {
    if (aField == null ||
        identical(aField, _field) ||
        (_field != null &&
            _field!.fieldKind == TFieldKind.fkLookup &&
            isKeyField(aField))) {
      reset();
    }
  }

  // UpdateData (L1819-1829): only fires OnUpdateData if there's a pending write
  @override
  void updateData() {
    if (!_isModified) return;
    try {
      onUpdateData?.call(this);
    } finally {
      _isModified = false;
    }
  }

  // FocusControl (L1842-1855): ??? TWinControl.SetFocus is LCL's focus
  // system. Flutter uses FocusNode, handled by the widget layer itself.
  // The semantics of "clear fieldRef on a successful match (to stop
  // other controls from stealing focus)" are kept here; the actual
  // setFocus is delegated to the attached control (if it provides a
  // requestFocus callback).
  @override
  void focusControl(TFieldRef? aField) {
    if (aField != null && identical(aField, _field)) {
      // The original code did aField^ := nil (clearing the var
      // parameter, to stop subsequent controls from stealing focus).
      // Dart has no var pointers; the widget layer calls requestFocus
      // if it has one attached.
      final c = control;
      if (c != null) {
        try {
          (c as dynamic).requestFocus();
        } catch (_) {}
      }
    }
  }

  // Edit (L1883-1900): attempts to enter edit state
  bool edit() {
    final editingSrc = !_editing &&
        dataSet != null &&
        !dsEditModes.contains(dataSet!.state);

    if (!_editing && canModify) {
      super.edit();
    }

    final result = _editing;

    if (!_editingSourceSet) {
      // Fires only once (when the edit succeeds)
      _editingSource = _editing && editingSrc;
      _editingSourceSet = true;
    }
    return result;
  }

  // Modified (L1922-1925)
  void modified() {
    _isModified = true;
  }

  // Reset (L1936-1943): fires OnDataChange (doesn't write back), clears IsModified
  void reset() {
    onDataChange?.call(this);
    _isModified = false;
    resetEditingSource();
  }
}

//aa TDBEdit widget (single-field DB-aware input box)
// aa !!! not fully translated
// The widgets below (TDBEdit / TDBNavigator) are 【not】 a line-by-line
// translation of dbctrls.pp, but a "behavior-aligned rewrite" — LCL's
// controls are built on native widgets and a self-painting model,
// Flutter is a widget tree, with no possibility of a line-by-line
// mapping.
// The first half of this file (the data layer: TFieldDataLink etc.) is
// the actual translation of dbctrls.pp. This part keeps LCL's published
// property names and event names, reimplementing the internals with
// Flutter components.
// ═════════════════════════════════════════════════════════════════════════════
//  TDBEdit —— single-field DB-aware input box (dbctrls.pp TDBEdit L177-274)
//  LCL published: DataSource / DataField / ReadOnly / Field / Alignment /
//  Font / MaxLength
// ═════════════════════════════════════════════════════════════════════════════
class TDBEdit extends StatefulWidget {
  final TDataSource? dataSource; // DataSource
  final String dataField; // DataField
  final bool readOnly; // ReadOnly
  final TextAlign textAlign; // Alignment (already a TextAlign on the widget side)
  final TextStyle? font; // Font
  final int? maxLength; // MaxLength
// aa ### flutter extension
  // @@@ maxLines: 1=single-line (TDBEdit's original behavior); null or
  //     >1 = multi-line (used by TDBMemo). In multi-line mode Enter
  //     inserts a newline instead of moving to the next field; text
  //     starts from the top edge.
  final int? maxLines;
  // @@@ minLines: the minimum number of lines to reserve when empty.
  //     A multi-line field with maxLines: null only takes up one line's
  //     height when it has no content, looking identical to a
  //     single-line TDBEdit (one of the main reasons the memo "didn't
  //     seem to take effect"). Setting minLines gives it real height
  //     even when empty. Must stay null for single-line fields.
  final int? minLines;
  // @@@ expands: fills the parent container's height (the SizedBox(height: 56) around _edit).
  //     TextField's assertion requires maxLines/minLines to both be null when expands is true.
  final bool expands;
  final bool autofocus;       // auto-focuses on entering the screen (used for the first editable field)
  final FocusNode? focusNode; // an externally-supplied FocusNode (lets other code hand focus in)
// zz ### flutter extension

  const TDBEdit({
    super.key,
    required this.dataSource,
    required this.dataField,
    this.readOnly = false,
    this.textAlign = TextAlign.left,
    this.font,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<TDBEdit> createState() => _TDBEditState();
}

class _TDBEditState extends State<TDBEdit> {
  late final TFieldDataLink _dataLink;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
// aa ### flutter extension
  bool _ownsFocusNode = false;   // only dispose a FocusNode we created ourselves
// zz ### flutter extension
  bool _syncingFromData = false; // prevents a DataChange↔onChanged loop
// aa ### flutter extension: select-all on entering edit mode
  // @@@ Records the timestamp of the last mouse-down. If focus is gained
  //     shortly after, this is judged to be "focus gained by clicking" →
  //     leave the cursor where clicked, don't select all; otherwise it's
  //     Tab/programmatic focus → select all (the Excel-style "move to a
  //     new cell and just start typing to replace" feel). A timestamp is
  //     used instead of a boolean flag, to avoid a stale flag from a
  //     "click without a focus change" mis-triggering the next Tab.
  DateTime? _lastPointerDown;
// zz ### flutter extension
// aa ??? issue
  // While the user is actively typing, block field→controller overwrites.
  // Without this: select-all-then-delete gets reverted by the old value,
  // and the first character typed after a backspace gets left behind.
  bool _userTyping = false;
// zz ??? issue

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // @@@ Use the externally-supplied focusNode if given (so other
    //     widgets can hand focus in), otherwise create one.
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _dataLink = TFieldDataLink();
    _dataLink.control = this;
    _dataLink.onDataChange = _onDataChange;     // field → widget
    _dataLink.onUpdateData = _onUpdateData;     // widget → field
    _dataLink.onActiveChange = _onActiveChange;
    _dataLink.onEditingChange = _onEditingChange;

    _dataLink.readOnly = widget.readOnly;
    _attach();

    // On blur, write back any pending edit (corresponds to LCL's WMKillFocus → UpdateData)
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _maybeSelectAllOnFocus(); // @@@ gained focus → select-all depending on the situation
      } else {
        _flush();
      }
    });
  }

  // @@@ Automatically selects all content when focus is gained, so
  //     typing immediately overwrites it (the Excel-style "move to a new
  //     cell and just start typing" feel). Excludes two cases:
  //     1) multi-line (memo): selecting the whole block then typing
  //        could accidentally delete the whole thing — never select all.
  //     2) focus gained via mouse click: the user wants to place the
  //        cursor exactly where they clicked for fine editing —
  //        shouldn't select all.
  void _maybeSelectAllOnFocus() {
    final singleLine = widget.maxLines == 1 && !widget.expands;
    if (!singleLine) return;
    final byMouse = _lastPointerDown != null &&
        DateTime.now().difference(_lastPointerDown!).inMilliseconds < 300;
    if (byMouse) return;
    // The content may have just been set by the field (onDataChange);
    // deferring the select-all to the next frame is more reliable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_focusNode.hasFocus) return;
      final len = _controller.text.length;
      if (len > 0) {
        _controller.selection =
            TextSelection(baseOffset: 0, extentOffset: len);
      }
    });
  }

  void _attach() {
    _dataLink.dataSource = widget.dataSource;
    _dataLink.fieldName = widget.dataField;
  }

  @override
  void didUpdateWidget(TDBEdit old) {
    super.didUpdateWidget(old);
    if (!identical(old.dataSource, widget.dataSource) ||
        old.dataField != widget.dataField) {
      _attach();
    }
    _dataLink.readOnly = widget.readOnly;
  }

  @override
  void dispose() {
    _dataLink.free(); // TDataLink.destroy → unregisters
    _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose(); // @@@ an externally-supplied one isn't released here
    super.dispose();
  }

  // OnDataChange: field value → input box (corresponds to TDBEdit.DataChange)
  void _onDataChange(Object sender) {
// aa ??? issue
    // While the user is actively typing (the deRecordChange callback
    // triggered by onChanged→edit), the controller must not be
    // overwritten with the field's old value, otherwise select-all-then-
    // delete gets reverted by the old value, and the first character
    // after a backspace gets left behind. During editing, the on-screen
    // controller is the source of truth; the field is only written back
    // when flushed.
    if (_userTyping) return;
// zz ??? issue
    final f = _dataLink.field;
    final text = f?.displayText ?? '';
    if (_controller.text != text) {
      _syncingFromData = true;
      // @@@ Set text+selection together via `value`, to avoid the old
      //     selection pointing past the end of the new (possibly
      //     shorter) text (triggering "Range end N out of text length 0" when cleared).
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      _syncingFromData = false;
    }
    if (mounted) setState(() {});
  }

  // OnUpdateData: input box → field (corresponds to TDBEdit.UpdateData)
  void _onUpdateData(Object sender) {
    final f = _dataLink.field;
    if (f != null) {
      f.text = _controller.text;
    }
  }

  void _onActiveChange(Object sender) {
    if (mounted) setState(() {});
  }

  void _onEditingChange(Object sender) {
    if (mounted) setState(() {});
  }

  // User edits text → enters edit state + marks modified (corresponds to TDBEdit.Change)
  void _onChanged(String value) {
    if (_syncingFromData) return;
    _userTyping = true;
    try {
      if (_dataLink.edit()) {
        _dataLink.modified();
// aa ??? issue
        // Writes back to the field immediately, so the data updates as
        // it's typed; this also puts the dataset into dsEdit → so the
        // navigator's save button lights up. It used to only flush on
        // editingComplete, so after a dropdown pick or typing the
        // navigator wouldn't reflect the "savable" state.
        // Intermediate states while typing a numeric field character by
        // character (like "-" or "1.") can throw on conversion; that's
        // caught and skipped here — the edit state is already
        // established, and the real write-back happens on flush
        // (editingComplete).
        final f = _dataLink.field;
        if (f != null) {
          try {
            f.text = value;
          } catch (_) {/* an intermediate format, not written back for now */}
        }
// zz ??? issue
      }
    } finally {
      _userTyping = false;
    }
  }

  // Writes back any pending edit (UpdateData only actually fires the event if IsModified)
  void _flush() {
    _dataLink.updateRecord(); // TDataLink.updateRecord → updateData
  }

  bool get _effectiveReadOnly => widget.readOnly || !_dataLink.canModify;

  @override
  Widget build(BuildContext context) {
    // @@@ Wraps a Listener to record the mouse-down time, for
    //     _maybeSelectAllOnFocus to judge whether focus came from the
    //     mouse (if so, don't select all). `behavior` defaults to not
    //     intercepting, so the TextField still receives the tap normally
    //     and cursor placement is unaffected.
    return Listener(
      onPointerDown: (_) => _lastPointerDown = DateTime.now(),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus, // @@@ auto-focuses on entering the screen
        readOnly: _effectiveReadOnly,
        textAlign: widget.textAlign,
        style: widget.font,
        maxLength: widget.maxLength,
        // @@@ Multi-line (TDBMemo): Enter inserts a newline, text starts at the top, scrollable
        // @@@ When expands is true, maxLines/minLines must both be null (TextField's assertion)
        maxLines: widget.expands ? null : widget.maxLines,
        minLines:
            (widget.expands || widget.maxLines == 1) ? null : widget.minLines,
        keyboardType:
            widget.maxLines == 1 ? null : TextInputType.multiline,
        textAlignVertical:
            widget.maxLines == 1 ? null : TextAlignVertical.top,
        expands: widget.expands,
        decoration: const InputDecoration(
          isDense: true,
          counterText: "",
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          border: OutlineInputBorder(),
        ),
        onChanged: _onChanged,
        onEditingComplete: () {
          _flush();
          // Enter should insert a newline in multi-line mode, not move to the next field
          if (widget.maxLines == 1) FocusScope.of(context).nextFocus();
        },
      ),
    );
  }
}

//zz TDBEdit widget

//aa TDBMemo widget (multi-line data field)
// ═════════════════════════════════════════════════════════════════════════════
//  TDBMemo —— dbctrls.pp's TDBMemo. A multi-line version of TDBEdit: binds
//  the same TFieldDataLink, differing only in that Enter inserts a
//  newline (doesn't move to the next field), text starts at the top, and
//  it's scrollable.
//  @@@ Implemented via composition rather than writing a separate
//      DataLink, to avoid two copies of the binding logic drifting apart.
// ═════════════════════════════════════════════════════════════════════════════
class TDBMemo extends StatelessWidget {
  final TDataSource? dataSource; // DataSource
  final String dataField; // DataField
  final bool readOnly; // ReadOnly
  final TextStyle? font; // Font
  final int? maxLength; // MaxLength
  final int? lines; // number of lines to display (null = scrolls with the container's height)
  final bool autofocus;
  final FocusNode? focusNode;

  const TDBMemo({
    super.key,
    required this.dataSource,
    required this.dataField,
    this.readOnly = false,
    this.font,
    this.maxLength,
    this.lines,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
// aa ??? issue
    // This used to pass `lines` straight through as maxLines; when
    // `lines` was null, the TextField would "grow with its content" —
    // with no content it's just one line tall, looking exactly like a
    // single-line TDBEdit. But _edit already locks the height via
    // SizedBox(height: 56), so minLines can't be used here to guess a
    // line count (3 lines crammed into 56px would overflow). The right
    // fix is `expands`: hand the height entirely to the parent
    // container, and let content that overflows scroll within the box.
    // minLines is only used when `lines` is explicitly given (i.e. the
    // parent container has no fixed height).
    final bool fill = lines == null;
// zz ??? issue
    return TDBEdit(
      dataSource: dataSource,
      dataField: dataField,
      readOnly: readOnly,
      font: font,
      maxLength: maxLength,
      maxLines: null, // unlimited lines: Enter inserts a newline, doesn't move to the next field
      minLines: fill ? null : lines,
      expands: fill, // fills the parent container (the SizedBox around _edit)
      autofocus: autofocus,
      focusNode: focusNode,
    );
  }
}
//zz TDBMemo widget

//aa TDBNavigator widget (dataset navigation bar)
// ═════════════════════════════════════════════════════════════════════════════
//  TDBNavigator —— dataset navigation bar (dbctrls.pp TDBNavigator L1471)
//  Binds directly to a TDataSource (doesn't need FieldDataLink, since it operates on the whole dataset)
// ═════════════════════════════════════════════════════════════════════════════

// TDBNavButtonType (dbctrls.pp L1329-1330)
enum TNavigateBtn {
  nbFirst,
  nbPrior,
  nbNext,
  nbLast,
  nbInsert,
  nbDelete,
  nbEdit,
  nbPost,
  nbCancel,
  nbRefresh,
}

// DefaultDBNavigatorButtons (L1344-1345)
const Set<TNavigateBtn> defaultDBNavigatorButtons = {
  TNavigateBtn.nbFirst,
  TNavigateBtn.nbPrior,
  TNavigateBtn.nbNext,
  TNavigateBtn.nbLast,
  TNavigateBtn.nbInsert,
  TNavigateBtn.nbDelete,
  TNavigateBtn.nbEdit,
  TNavigateBtn.nbPost,
  TNavigateBtn.nbCancel,
  TNavigateBtn.nbRefresh,
};

// ─────────────────────────────────────────────────────────────────────────────
//  TDBRadioGroup —— dbctrls.pp's TDBRadioGroup = class(TCustomRadioGroup)
//
//  LCL core properties: DataSource / DataField / Items / Values / ItemIndex /
//                     Columns / Caption / ReadOnly.
//
//  Values is a key LCL design: Items is "text shown to the person",
//  Values is "the value written into the field". They correspond by
//  index; if Values isn't given, Items is used directly as the value.
//  WapForm's <select field=><option value="P">Print</option></select> is
//  exactly this same pairing: value= → Values, the label text → Items.
//
//  Appearance is delegated entirely to lazarus_extctrls.dart's
//  TRadioGroup; this only handles data binding (the same approach as
//  TDBMemo composing TDBEdit).
// ─────────────────────────────────────────────────────────────────────────────
class TDBRadioGroup extends StatefulWidget {
  final TDataSource? dataSource; // DataSource
  final String dataField; // DataField
  final String caption; // Caption
  final List<String> items; // Items: display text
  final List<String>? values; // Values: the value actually written to the field (null → uses items)
  final int columns; // Columns
  final bool readOnly; // ReadOnly
  final double? width;
  final double? height;
  final TextStyle? font;

  const TDBRadioGroup({
    super.key,
    required this.dataSource,
    required this.dataField,
    this.caption = '',
    required this.items,
    this.values,
    this.columns = 1,
    this.readOnly = false,
    this.width,
    this.height,
    this.font,
  });

  @override
  State<TDBRadioGroup> createState() => _TDBRadioGroupState();
}

class _TDBRadioGroupState extends State<TDBRadioGroup> {
  late TFieldDataLink _dataLink;

  // Falls back to Items if Values isn't given (corresponds to LCL: when
  // Values is empty, ItemIndex maps directly onto Items)
  List<String> get _vals =>
      (widget.values != null && widget.values!.length == widget.items.length)
          ? widget.values!
          : widget.items;

  @override
  void initState() {
    super.initState();
    _dataLink = TFieldDataLink();
    _dataLink.control = this;
    _dataLink.onDataChange = _onDataChange;
    _dataLink.onActiveChange = _onDataChange;
    _dataLink.readOnly = widget.readOnly;
    _attach();
  }

  void _attach() {
    _dataLink.dataSource = widget.dataSource;
    _dataLink.fieldName = widget.dataField;
  }

  @override
  void didUpdateWidget(covariant TDBRadioGroup old) {
    super.didUpdateWidget(old);
    if (old.dataSource != widget.dataSource ||
        old.dataField != widget.dataField) {
      _attach();
    }
    _dataLink.readOnly = widget.readOnly;
  }

  @override
  void dispose() {
    _dataLink.free();
    super.dispose();
  }

  void _onDataChange(Object sender) {
    if (mounted) setState(() {});
  }

  // The field's current value → ItemIndex (returns -1 if not found,
  // corresponding to LCL's "if the value isn't in Values, nothing is selected")
  int get _itemIndex {
    final cur = _dataLink.field?.text ?? '';
    if (cur.isEmpty) return -1;
    final v = _vals;
    for (var i = 0; i < v.length; i++) {
      if (v[i] == cur) return i;
    }
    return -1;
  }

  bool get _effectiveReadOnly => widget.readOnly || !_dataLink.canModify;

  void _pick(int index) {
    if (_effectiveReadOnly) return;
    final v = _vals;
    if (index < 0 || index >= v.length) return;
    // Corresponds to LCL's Change → DataLink.Edit + Field.AsString := Values[ItemIndex]
    if (_dataLink.edit()) {
      _dataLink.field?.text = v[index];
      _dataLink.modified();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TRadioGroup(
      caption: widget.caption,
      items: widget.items,
      itemIndex: _itemIndex,
      columns: widget.columns,
      enabled: true,
      readOnly: _effectiveReadOnly,
      onSelectionChanged: _pick,
      width: widget.width,
      height: widget.height,
      font: widget.font,
    );
  }
}

class TDBNavigator extends StatefulWidget {
  final TDataSource? dataSource; // DataSource
  final Set<TNavigateBtn> visibleButtons; // VisibleButtons
  final bool confirmDelete; // ConfirmDelete

  // @@@ async action callbacks (post/insert/delete go through the
  // @@@ openAsync family's async boundary and need an await).
  // @@@ onNavClick corresponds to LCL's OnClick(Sender, Button).
  final Future<void> Function()? onPostAsync;
  final Future<void> Function()? onDeleteAsync;
  final Future<void> Function()? onInsertAsync;
  final void Function(Object sender, TNavigateBtn btn)? onNavClick;

  const TDBNavigator({
    super.key,
    required this.dataSource,
    this.visibleButtons = defaultDBNavigatorButtons,
    this.confirmDelete = true,
    this.onPostAsync,
    this.onDeleteAsync,
    this.onInsertAsync,
    this.onNavClick,
  });

  @override
  State<TDBNavigator> createState() => _TDBNavigatorState();
}

class _TDBNavigatorState extends State<TDBNavigator> {
  late final TDataLink _link;
// aa ### flutter extension
  // Treats the navigator as "a single Tab stop": the whole row is
  // wrapped in a Focus, with internal left/right-arrow-key movement
  // between buttons. LCL has no such concept (Delphi's navigator has
  // each button take its own Tab stop).
  final FocusNode _groupNode = FocusNode(); // the row's single external stop
  final List<FocusNode> _btnNodes = [];     // each button's focusNode
  int _focusedBtn = 0;                      // index of the currently focused button
// zz ### flutter extension

  @override
  void initState() {
    super.initState();
    // Attaches a DataLink to listen for dataset state changes, used to enable/disable buttons
    _link = _NavDataLink(() {
      // @@@ If a data change happens to occur during build (e.g. a grid
      //     on the same dataset is being built, or a cu is loading),
      //     calling setState directly crashes with "setState called
      //     during build" → defer until the end of this frame instead.
      if (!mounted) return;
      if (WidgetsBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      } else {
        setState(() {});
      }
    });
    _link.dataSource = widget.dataSource;
  }

  @override
  void didUpdateWidget(TDBNavigator old) {
    super.didUpdateWidget(old);
    if (!identical(old.dataSource, widget.dataSource)) {
      _link.dataSource = widget.dataSource;
    }
  }

  @override
  void dispose() {
    _link.free();
    _groupNode.dispose();
    for (final n in _btnNodes) {
      n.dispose();
    }
    super.dispose();
  }

  TDataSet? get _ds => widget.dataSource?.dataSet;

  static const Map<TNavigateBtn, IconData> _icons = {
    TNavigateBtn.nbFirst: Icons.first_page,
    TNavigateBtn.nbPrior: Icons.chevron_left,
    TNavigateBtn.nbNext: Icons.chevron_right,
    TNavigateBtn.nbLast: Icons.last_page,
    TNavigateBtn.nbInsert: Icons.add,
    TNavigateBtn.nbDelete: Icons.delete,
    TNavigateBtn.nbEdit: Icons.edit,
    TNavigateBtn.nbPost: Icons.check,
    TNavigateBtn.nbCancel: Icons.close,
    TNavigateBtn.nbRefresh: Icons.refresh,
  };

  // Whether each button is usable given the current dataset state
  // (corresponds to the enabled check LCL does before TDBNavigator.BtnClick)
  bool _enabled(TNavigateBtn btn) {
    final ds = _ds;
    if (ds == null || !ds.active) return false;
    final editing = dsEditModes.contains(ds.state);
    switch (btn) {
      case TNavigateBtn.nbFirst:
      case TNavigateBtn.nbPrior:
        return !editing && !ds.bof;
      case TNavigateBtn.nbNext:
      case TNavigateBtn.nbLast:
        return !editing && !ds.eof;
      case TNavigateBtn.nbInsert:
        return !editing && ds.canModify;
      case TNavigateBtn.nbDelete:
        return !editing && ds.canModify && !ds.isEmpty;
      case TNavigateBtn.nbEdit:
        return !editing && ds.canModify;
      case TNavigateBtn.nbPost:
      case TNavigateBtn.nbCancel:
        return editing;
      case TNavigateBtn.nbRefresh:
        return true;
    }
  }

  Future<void> _click(TNavigateBtn btn) async {
    final ds = _ds;
    if (ds == null) return;
    widget.onNavClick?.call(this, btn);
    switch (btn) {
      case TNavigateBtn.nbFirst:
        ds.first();
        break;
      case TNavigateBtn.nbPrior:
        ds.prior();
        break;
      case TNavigateBtn.nbNext:
        ds.next();
        break;
      case TNavigateBtn.nbLast:
        ds.last();
        break;
      case TNavigateBtn.nbInsert:
        if (widget.onInsertAsync != null) {
          await widget.onInsertAsync!();
        } else {
          ds.insert();
        }
        break;
      case TNavigateBtn.nbDelete:
        if (widget.confirmDelete) {
          final ok = await _confirmDelete();
          if (!ok) return;
        }
        if (widget.onDeleteAsync != null) {
          await widget.onDeleteAsync!();
        } else {
          ds.delete();
        }
        break;
      case TNavigateBtn.nbEdit:
        ds.edit();
        break;
      case TNavigateBtn.nbPost:
        if (widget.onPostAsync != null) {
          await widget.onPostAsync!();
        } else {
          ds.post();
        }
        break;
      case TNavigateBtn.nbCancel:
        ds.cancel();
        break;
      case TNavigateBtn.nbRefresh:
        ds.refresh();
        break;
    }
    if (mounted) setState(() {});
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("OK")),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // First compute the currently visible list of buttons
    final visible = <TNavigateBtn>[];
    for (final btn in TNavigateBtn.values) {
      if (widget.visibleButtons.contains(btn)) visible.add(btn);
    }
    // Make sure the number of focusNodes matches the number of buttons
    while (_btnNodes.length < visible.length) {
      _btnNodes.add(FocusNode());
    }
    if (_focusedBtn >= visible.length) _focusedBtn = 0;

    final btns = <Widget>[];
    for (var i = 0; i < visible.length; i++) {
      final btn = visible[i];
      final on = _enabled(btn);
      btns.add(IconButton(
        focusNode: _btnNodes[i],
        icon: Icon(_icons[btn], size: 18),
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: on ? () => _click(btn) : null,
      ));
    }

// aa ### flutter extension
    // The whole navigator row acts as "a single Tab stop":
    //   - the outer Focus catches Tab; on gaining focus it redirects
    //     focus to the current button
    //   - left/right arrow keys move between buttons; Tab is handed to
    //     the default traversal (leaves the navigator)
    //   - descendantsAreTraversable:false → the internal buttons don't
    //     each take their own Tab stop
    return FocusTraversalGroup(
      descendantsAreTraversable: false,
      child: Focus(
        focusNode: _groupNode,
        onFocusChange: (hasFocus) {
          if (hasFocus && _btnNodes.isNotEmpty) {
            // Focus lands on the navigator → redirect to the current button
            _btnNodes[_focusedBtn].requestFocus();
          }
        },
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          final k = event.logicalKey;
          if (k == LogicalKeyboardKey.arrowRight) {
            _focusedBtn = (_focusedBtn + 1) % _btnNodes.length;
            _btnNodes[_focusedBtn].requestFocus();
            return KeyEventResult.handled;
          }
          if (k == LogicalKeyboardKey.arrowLeft) {
            _focusedBtn = (_focusedBtn - 1 + _btnNodes.length) % _btnNodes.length;
            _btnNodes[_focusedBtn].requestFocus();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored; // Tab etc. go to the default handler → leaves the navigator
        },
        child: Row(mainAxisSize: MainAxisSize.min, children: btns),
      ),
    );
// zz ### flutter extension
  }
}

// The internal DataLink used by TDBNavigator: dataset state changes → repaint the button row
class _NavDataLink extends TDataLink {
  final void Function() _notify;
  _NavDataLink(this._notify) {
    visualControl = true;
  }

  @override
  void activeChanged() => _notify();
  @override
  void dataSetChanged() => _notify();
  @override
  void editingChanged() => _notify();
  @override
  void recordChanged(TField? field) => _notify();
  @override
  void dataSetScrolled(int distance) => _notify();
}

//zz TDBNavigator widget

// @@@ TButton has moved to lazarus_stdctrls.dart (it belongs to
//     stdctrls.pp, not dbctrls). Callers needing TButton should import
//     'lazarus_stdctrls.dart'.

// zz !!! not fully translated
