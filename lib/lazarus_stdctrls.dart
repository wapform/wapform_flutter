// ═════════════════════════════════════════════════════════════════════════════
//  lazarus_stdctrls.dart
//
//  This file is a Dart translation (derivative work) of the following
//  Object Pascal upstream source:
//    Upstream project: Lazarus Component Library (LCL)
//    Upstream file: stdctrls.pp (interface-aligned, not a line-by-line translation)
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
//  lazarus_stdctrls.dart —— Flutter port of FPC/LCL stdctrls.pp (community edition)
//  ─────────────────────────────────────────────────────────────────────────
//  Corresponds to: stdctrls.pp (LCL, 1,771 lines)
//
//  Translation approach ("behavioral equivalence", consistent with
//  dbgrids/dbctrls):
//    stdctrls.pp's controls are all TWinControl/TGraphicControl subclasses
//    — pure LCL GUI infrastructure (Canvas painting + Win32 LM_/WM_
//    messages). Flutter has no equivalent infrastructure, so translating
//    line-by-line would serve no purpose. So 【the controls' enums / core
//    properties / events (the data model) are kept faithfully, using LCL
//    naming】, while 【painting/messaging/focus are reimplemented with
//    Flutter widgets】. Appearance-related properties (Anchors/BidiMode/
//    DoubleBuffered/ParentColor…) have no direct Flutter equivalent and
//    are omitted; functionally relevant ones are kept (Text/Items/
//    ItemIndex/Checked/Caption/Alignment/ReadOnly/MaxLength/Enabled/
//    Visible/OnChange…).
//
// aa !!! not fully translated
//  This file 【as a whole】 is not a line-by-line translation of LCL, but a
//  "behavior-aligned rewrite" — LCL's controls are built on Win32/GTK
//  native widgets and a self-painting model; Flutter's widget tree is a
//  completely different architecture, with no possibility of a line-by-
//  line mapping.
//  This keeps LCL's "interface contract" (class names, property names,
//  event names) while reimplementing the internals with Flutter's
//  Material components. The goal is behavioral compatibility, not
//  identical implementation.
// zz !!! not fully translated
//
//  Controls covered: TScrollBar / TGroupBox / TComboBox / TListBox /
//    TEdit / TMemo / TStaticText / TButton / TCheckBox / TToggleBox /
//    TRadioButton / TLabel.
//  Depends on: flutter/material, lazarus_db.dart (TAlignment/TNotifyEvent shims, etc.)
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lazarus_db.dart' show TAlignment, TNotifyEvent;

// TEditCharCase (L39)
enum TEditCharCase { ecNormal, ecUppercase, ecLowerCase }

// TEchoMode (L40)
enum TEchoMode { emNormal, emNone, emPassword }

// TScrollStyle (L44)
enum TScrollStyle {
  ssNone,
  ssHorizontal,
  ssVertical,
  ssBoth,
  ssAutoHorizontal,
  ssAutoVertical,
  ssAutoBoth,
}

// TComboBoxStyle (L262): determines whether the combo box is editable / owner-drawn
enum TComboBoxStyle {
  csDropDown, // editable + dropdown
  csSimple, // editable + always-visible list
  csDropDownList, // read-only menu
  csOwnerDrawFixed,
  csOwnerDrawVariable,
}

// TListBoxStyle (L528)
enum TListBoxStyle {
  lbStandard,
  lbOwnerDrawFixed,
  lbOwnerDrawVariable,
  lbVirtual,
}

// TCheckBoxState (L1322)
enum TCheckBoxState { cbUnchecked, cbChecked, cbGrayed }

// TStaticBorderStyle (L1087)
enum TStaticBorderStyle { sbsNone, sbsSingle, sbsSunken }

// TTextLayout (Graphics shim: vertical alignment)
enum TTextLayoutStd { tlTop, tlCenter, tlBottom }

// TAlignment → Flutter TextAlign mapping (shared)
TextAlign textAlignOf(TAlignment a) {
  switch (a) {
    case TAlignment.taRightJustify:
      return TextAlign.right;
    case TAlignment.taCenter:
      return TextAlign.center;
    case TAlignment.taLeftJustify:
      return TextAlign.left;
  }
}

// LCL core properties: Text / Alignment / CharCase / EchoMode / MaxLength /
// ReadOnly / PasswordChar / NumbersOnly / TextHint / OnChange.
class TEdit extends StatefulWidget {
  final String text; // Text
  final TAlignment alignment; // Alignment
  final TEditCharCase charCase; // CharCase
  final TEchoMode echoMode; // EchoMode
  final int maxLength; // MaxLength (0 = unlimited)
  final bool readOnly; // ReadOnly
  final bool numbersOnly; // NumbersOnly
  final String textHint; // TextHint (placeholder)
  final bool enabled; // Enabled
  final TextStyle? font; // Font
  final void Function(String text)? onChange; // OnChange
  final VoidCallback? onEditingDone; // EditingDone

  const TEdit({
    super.key,
    this.text = '',
    this.alignment = TAlignment.taLeftJustify,
    this.charCase = TEditCharCase.ecNormal,
    this.echoMode = TEchoMode.emNormal,
    this.maxLength = 0,
    this.readOnly = false,
    this.numbersOnly = false,
    this.textHint = '',
    this.enabled = true,
    this.font,
    this.onChange,
    this.onEditingDone,
  });

  @override
  State<TEdit> createState() => _TEditState();
}

class _TEditState extends State<TEdit> {
  late final TextEditingController _c;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.text);
    _focus = FocusNode();
    _focus.addListener(() {
      if (!_focus.hasFocus) widget.onEditingDone?.call();
    });
  }

  @override
  void didUpdateWidget(TEdit old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text && widget.text != _c.text) {
      // @@@ Reset the cursor along with the text: setting only `text`
      //     would keep the old selection, and if the new text is
      //     shorter the offset would go out of range → a TextSelection
      //     assertion crash.
      _c.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  // CharCase: forces case while typing (corresponds to SetCharCase)
  String _applyCase(String s) {
    switch (widget.charCase) {
      case TEditCharCase.ecUppercase:
        return s.toUpperCase();
      case TEditCharCase.ecLowerCase:
        return s.toLowerCase();
      case TEditCharCase.ecNormal:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatters = <TextInputFormatter>[];
    if (widget.numbersOnly) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    return TextField(
      controller: _c,
      focusNode: _focus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      textAlign: textAlignOf(widget.alignment),
      obscureText: widget.echoMode == TEchoMode.emPassword,
      maxLength: widget.maxLength > 0 ? widget.maxLength : null,
      inputFormatters: formatters,
      style: widget.font,
      decoration: InputDecoration(
        isDense: true,
        counterText: "",
        hintText: widget.textHint.isNotEmpty ? widget.textHint : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        border: const OutlineInputBorder(),
      ),
      onChanged: (v) {
        final cased = _applyCase(v);
        if (cased != v) {
          _c.value = _c.value.copyWith(
            text: cased,
            selection: TextSelection.collapsed(offset: cased.length),
          );
        }
        widget.onChange?.call(cased);
      },
      onEditingComplete: widget.onEditingDone,
    );
  }
}

// LCL core properties: Lines (Text) / WordWrap / ReadOnly / ScrollBars / OnChange.
class TMemo extends StatefulWidget {
  final String text; // Lines.Text
  final bool wordWrap; // WordWrap
  final bool readOnly; // ReadOnly
  final int maxLength; // MaxLength
  final bool enabled;
  final TextStyle? font;
  final void Function(String text)? onChange;

  const TMemo({
    super.key,
    this.text = '',
    this.wordWrap = true,
    this.readOnly = false,
    this.maxLength = 0,
    this.enabled = true,
    this.font,
    this.onChange,
  });

  @override
  State<TMemo> createState() => _TMemoState();
}

class _TMemoState extends State<TMemo> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(TMemo old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text && widget.text != _c.text) {
      // @@@ Same as TEdit: reset the cursor along with the text, to
      //     avoid an out-of-range selection when the new text is shorter.
      _c.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: null,
      expands: false,
      keyboardType: TextInputType.multiline,
      maxLength: widget.maxLength > 0 ? widget.maxLength : null,
      style: widget.font,
      decoration: const InputDecoration(
        isDense: true,
        counterText: "",
        contentPadding: EdgeInsets.all(6),
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onChange,
    );
  }
}

// LCL core properties: Caption / Alignment / Layout / Font / Enabled / WordWrap.
class TLabel extends StatelessWidget {
  final String caption; // Caption
  final TAlignment alignment; // Alignment
  final TTextLayoutStd layout; // Layout (vertical)
  final bool wordWrap; // WordWrap
  final bool enabled; // Enabled
  final TextStyle? font; // Font

  const TLabel({
    super.key,
    required this.caption,
    this.alignment = TAlignment.taLeftJustify,
    this.layout = TTextLayoutStd.tlTop,
    this.wordWrap = false,
    this.enabled = true,
    this.font,
  });

  Alignment _align() {
    final ta = alignment == TAlignment.taRightJustify
        ? 1.0
        : alignment == TAlignment.taCenter
            ? 0.0
            : -1.0;
    final tl = layout == TTextLayoutStd.tlBottom
        ? 1.0
        : layout == TTextLayoutStd.tlCenter
            ? 0.0
            : -1.0;
    return Alignment(ta, tl);
  }

  @override
  Widget build(BuildContext context) {
    final style = (font ?? const TextStyle()).copyWith(
      color: enabled ? null : Theme.of(context).disabledColor,
    );
    return Align(
      alignment: _align(),
      child: Text(
        caption,
        textAlign: textAlignOf(alignment),
        softWrap: wordWrap,
        overflow: wordWrap ? TextOverflow.clip : TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}

// LCL core properties: Items / ItemIndex / Text / Style / DropDownCount /
// MaxLength / Enabled / OnChange / OnSelect.
class TComboBox extends StatefulWidget {
  final List<String> items; // Items
  final int itemIndex; // ItemIndex (-1 = none selected)
  final String text; // Text (editable when csDropDown)
  final TComboBoxStyle style; // Style
  final int dropDownCount; // DropDownCount (visible row count)
  final bool enabled;
  final TextStyle? font;
  final void Function(String text)? onChange; // OnChange
  final void Function(int index)? onSelect; // OnSelect

  const TComboBox({
    super.key,
    this.items = const [],
    this.itemIndex = -1,
    this.text = '',
    this.style = TComboBoxStyle.csDropDown,
    this.dropDownCount = 8,
    this.enabled = true,
    this.font,
    this.onChange,
    this.onSelect,
  });

  @override
  State<TComboBox> createState() => _TComboBoxState();
}

class _TComboBoxState extends State<TComboBox> {
  late int _index;
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _index = widget.itemIndex;
    _c = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(TComboBox old) {
    super.didUpdateWidget(old);
    if (old.itemIndex != widget.itemIndex) _index = widget.itemIndex;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  bool get _editable =>
      widget.style == TComboBoxStyle.csDropDown ||
      widget.style == TComboBoxStyle.csSimple;

  @override
  Widget build(BuildContext context) {
    // csDropDownList: read-only menu → DropdownButton
    if (!_editable) {
      return DropdownButton<int>(
        value: _index >= 0 && _index < widget.items.length ? _index : null,
        isDense: true,
        style: widget.font ??
            TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        items: [
          for (var i = 0; i < widget.items.length; i++)
            DropdownMenuItem(value: i, child: Text(widget.items[i])),
        ],
        onChanged: widget.enabled
            ? (v) {
                if (v == null) return;
                setState(() => _index = v);
                widget.onSelect?.call(v);
                widget.onChange?.call(widget.items[v]);
              }
            : null,
      );
    }
    // csDropDown / csSimple: editable → Autocomplete-style (TextField + dropdown)
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TextField(
            controller: _c,
            enabled: widget.enabled,
            style: widget.font,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              border: OutlineInputBorder(),
            ),
            onChanged: widget.onChange,
          ),
        ),
        PopupMenuButton<int>(
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          enabled: widget.enabled,
          itemBuilder: (ctx) => [
            for (var i = 0; i < widget.items.length; i++)
              PopupMenuItem(value: i, child: Text(widget.items[i])),
          ],
          onSelected: (i) {
            setState(() {
              _index = i;
              _c.text = widget.items[i];
            });
            widget.onSelect?.call(i);
            widget.onChange?.call(widget.items[i]);
          },
        ),
      ],
    );
  }
}

// LCL core properties: Items / ItemIndex / MultiSelect / OnClick / OnSelectionChange.
class TListBox extends StatefulWidget {
  final List<String> items; // Items
  final int itemIndex; // ItemIndex
  final bool multiSelect; // MultiSelect
  final bool enabled;
  final TextStyle? font;
  final void Function(int index)? onClick; // OnClick (single-item selection)
  final void Function(Set<int> selected)? onSelectionChange; // multi-select

  const TListBox({
    super.key,
    this.items = const [],
    this.itemIndex = -1,
    this.multiSelect = false,
    this.enabled = true,
    this.font,
    this.onClick,
    this.onSelectionChange,
  });

  @override
  State<TListBox> createState() => _TListBoxState();
}

class _TListBoxState extends State<TListBox> {
  late int _index;
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _index = widget.itemIndex;
    if (_index >= 0) _selected.add(_index);
  }

  @override
  void didUpdateWidget(TListBox old) {
    super.didUpdateWidget(old);
    // @@@ Keep up when itemIndex changes externally. In single-select mode
    //     the selection set is reset to just that item; in multi-select
    //     mode the set is left alone (the user picked it themselves —
    //     itemIndex shouldn't override it).
    if (old.itemIndex != widget.itemIndex) {
      _index = widget.itemIndex;
      if (!widget.multiSelect) {
        _selected.clear();
        if (_index >= 0) _selected.add(_index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (ctx, i) {
          final sel =
              widget.multiSelect ? _selected.contains(i) : i == _index;
          return InkWell(
            onTap: widget.enabled
                ? () {
                    setState(() {
                      if (widget.multiSelect) {
                        if (_selected.contains(i)) {
                          _selected.remove(i);
                        } else {
                          _selected.add(i);
                        }
                        widget.onSelectionChange?.call(_selected);
                      } else {
                        _index = i;
                        widget.onClick?.call(i);
                      }
                    });
                  }
                : null,
            child: Container(
              width: double.infinity,
              color: sel ? Colors.blue.shade100 : null,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(widget.items[i], style: widget.font),
            ),
          );
        },
      ),
    );
  }
}

// LCL core properties: Caption / Checked / State / AllowGrayed / OnChange.
class TCheckBox extends StatefulWidget {
  final String caption; // Caption
  final bool checked; // Checked
  final TCheckBoxState state; // State (includes grayed)
  final bool allowGrayed; // AllowGrayed
  final bool enabled;
  final void Function(bool checked)? onChange; // OnChange
  final TextStyle? font; // Font (LCL's TControl.Font)
// aa ### flutter extension
  // dense: shrinks the tap target and padding, same rationale as
  // TRadioButton (Flutter's default 48px touch target makes each row
  // too tall when laid out as a TCheckGroup).
  final bool dense;
// zz ### flutter extension

  const TCheckBox({
    super.key,
    required this.caption,
    this.checked = false,
    this.state = TCheckBoxState.cbUnchecked,
    this.allowGrayed = false,
    this.enabled = true,
    this.onChange,
    this.font,
    this.dense = false,
  });

  @override
  State<TCheckBox> createState() => _TCheckBoxState();
}

class _TCheckBoxState extends State<TCheckBox> {
  late bool? _value; // null = grayed

  @override
  void initState() {
    super.initState();
    _value = widget.allowGrayed && widget.state == TCheckBoxState.cbGrayed
        ? null
        : widget.checked;
  }

  @override
  void didUpdateWidget(TCheckBox old) {
    super.didUpdateWidget(old);
    // @@@ Must also watch `state`: when allowGrayed is set and the
    //     caller changes state to cbGrayed (_value = null) externally,
    //     `checked` doesn't change, so comparing only `checked` would
    //     miss that transition.
    if (old.checked != widget.checked || old.state != widget.state) {
      _value = widget.allowGrayed && widget.state == TCheckBoxState.cbGrayed
          ? null
          : widget.checked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.enabled
          ? () {
              setState(() {
                if (widget.allowGrayed) {
                  // Tri-state cycle: false → true → null
                  _value = _value == false
                      ? true
                      : _value == true
                          ? null
                          : false;
                } else {
                  _value = !(_value ?? false);
                }
              });
              widget.onChange?.call(_value ?? false);
            }
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: _value,
            tristate: widget.allowGrayed,
            visualDensity: widget.dense ? VisualDensity.compact : null,
            materialTapTargetSize:
                widget.dense ? MaterialTapTargetSize.shrinkWrap : null,
            onChanged: widget.enabled
                ? (v) {
                    setState(() => _value = v);
                    widget.onChange?.call(v ?? false);
                  }
                : null,
          ),
          Flexible(
            child: Text(
              widget.caption,
              style: widget.enabled
                  ? widget.font
                  : (widget.font ?? const TextStyle())
                      .copyWith(color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}

// Behaves like a CheckBox with a pressed state, styled as a button.
class TToggleBox extends StatefulWidget {
  final String caption;
  final bool checked;
  final bool enabled;
  final void Function(bool checked)? onChange;

  const TToggleBox({
    super.key,
    required this.caption,
    this.checked = false,
    this.enabled = true,
    this.onChange,
  });

  @override
  State<TToggleBox> createState() => _TToggleBoxState();
}

class _TToggleBoxState extends State<TToggleBox> {
  late bool _on;
  @override
  void initState() {
    super.initState();
    _on = widget.checked;
  }

  @override
  void didUpdateWidget(TToggleBox old) {
    super.didUpdateWidget(old);
    // @@@ Must keep up when `checked` changes externally (it used to
    //     only be read once in initState, so the button's pressed/
    //     released state wouldn't update after the parent changed it).
    if (old.checked != widget.checked) _on = widget.checked;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.enabled
          ? () {
              setState(() => _on = !_on);
              widget.onChange?.call(_on);
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _on ? Colors.blue.shade200 : null,
      ),
      child: Text(widget.caption),
    );
  }
}

// LCL: mutually exclusive within the same parent. Handled here via
// groupValue (the caller passes the same one to each button in the group).
class TRadioButton<T> extends StatelessWidget {
  final String caption; // Caption
  final T value; // the value this button represents
  final T? groupValue; // the currently selected value
  final bool enabled;
  final void Function(T value)? onChange; // OnChange (fires when selected)
  final TextStyle? font; // Font (LCL's TControl.Font)
// aa ### flutter extension
  // dense: shrinks the tap target and padding. LCL's per-button height is
  // determined by the Font/system theme; Flutter's Radio defaults to a
  // large 48px touch target, which makes each row too tall when laid out
  // as a group.
  final bool dense;
// zz ### flutter extension

  const TRadioButton({
    super.key,
    required this.caption,
    required this.value,
    required this.groupValue,
    this.enabled = true,
    this.onChange,
    this.font,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChange?.call(value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<T>(
            value: value,
            groupValue: groupValue,
            visualDensity: dense ? VisualDensity.compact : null,
            materialTapTargetSize:
                dense ? MaterialTapTargetSize.shrinkWrap : null,
            onChanged:
                enabled ? (v) { if (v != null) onChange?.call(v); } : null,
          ),
          Flexible(
            child: Text(
              caption,
              style: enabled
                  ? font
                  : (font ?? const TextStyle())
                      .copyWith(color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}

// LCL core properties: Caption / Default / Cancel / ModalResult / Enabled / OnClick.
class TButton extends StatelessWidget {
  final String caption; // Caption
  final VoidCallback? onClick; // OnClick
  final bool enabled; // Enabled
  final bool isDefault; // Default (triggered by Enter; maps to autofocus on the Flutter side)

  const TButton({
    super.key,
    required this.caption,
    this.onClick,
    this.enabled = true,
    this.isDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      autofocus: isDefault,
      onPressed: enabled ? onClick : null,
      child: Text(caption),
    );
  }
}

// LCL core properties: Caption / Alignment / BorderStyle.
class TStaticText extends StatelessWidget {
  final String caption;
  final TAlignment alignment;
  final TStaticBorderStyle borderStyle;
  final TextStyle? font;

  const TStaticText({
    super.key,
    required this.caption,
    this.alignment = TAlignment.taLeftJustify,
    this.borderStyle = TStaticBorderStyle.sbsNone,
    this.font,
  });

  @override
  Widget build(BuildContext context) {
    Widget txt = Text(caption, textAlign: textAlignOf(alignment), style: font);
    if (borderStyle != TStaticBorderStyle.sbsNone) {
      txt = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: borderStyle == TStaticBorderStyle.sbsSunken ? 2 : 1,
          ),
        ),
        child: txt,
      );
    }
    return txt;
  }
}

// LCL core properties: Caption + contained child controls.
class TGroupBox extends StatelessWidget {
  final String caption; // Caption
  final Widget? child; // contained control
  final bool enabled;

  const TGroupBox({
    super.key,
    required this.caption,
    this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(caption,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (child != null) child!,
        ],
      ),
    );
  }
}

// LCL core properties: Kind (horizontal/vertical) / Min / Max / Position / OnChange.
class TScrollBar extends StatefulWidget {
  final bool horizontal; // Kind = sbHorizontal
  final int min; // Min
  final int max; // Max
  final int position; // Position
  final bool enabled;
  final void Function(int position)? onChange; // OnChange

  const TScrollBar({
    super.key,
    this.horizontal = true,
    this.min = 0,
    this.max = 100,
    this.position = 0,
    this.enabled = true,
    this.onChange,
  });

  @override
  State<TScrollBar> createState() => _TScrollBarState();
}

class _TScrollBarState extends State<TScrollBar> {
  late double _pos;

  @override
  void initState() {
    super.initState();
    _pos = widget.position.toDouble();
  }

  @override
  void didUpdateWidget(TScrollBar old) {
    super.didUpdateWidget(old);
    if (old.position != widget.position) _pos = widget.position.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final slider = Slider(
      min: widget.min.toDouble(),
      max: widget.max.toDouble(),
      value: _pos.clamp(widget.min.toDouble(), widget.max.toDouble()),
      onChanged: widget.enabled
          ? (v) {
              setState(() => _pos = v);
              widget.onChange?.call(v.round());
            }
          : null,
    );
    return widget.horizontal
        ? slider
        : RotatedBox(quarterTurns: 3, child: slider);
  }
}
