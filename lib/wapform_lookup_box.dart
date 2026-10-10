// ═════════════════════════════════════════════════════════════════════════════
//  wapform_lookup_box.dart
//  WapLookupBox —— lookup dropdown box
//
//  This file is original code (not translated from FPC/Lazarus sources).
//  But it depends on the LGPL translation modules in this repo, so it
//  carries the same license to keep the overall licensing simple.
//
//  License: GNU Lesser General Public License v2.1, with the static
//  linking exception (Modified LGPL). See the accompanying
//  COPYING.LGPL.txt and COPYING.modifiedLGPL.txt.
//
//  Copyright (c) 2026 Minhong Information Co., Ltd. (wapform.com)
// ═════════════════════════════════════════════════════════════════════════════

// lib/wap/wap_lookup_box.dart
//
// WapLookupBox — unified lookup dropdown input widget (standalone, reusable)
//
// Merged from two already-debugged implementations:
//   1. ag6006.dart  _LookupEdit          — for standalone input fields (with a readOnly mode)
//   2. dbgrids.dart _LookupAutoComplete  — for DBGrid cells (with keyboard handling)
//
// Union of both feature sets:
//   - Single-column / multi-column lookup (lookupItems / lookupColumns)
//   - Input filtering (key or any display column contains the search text)
//   - Overlay dropdown, multi-column aligned display, scrollbar
//   - readOnly mode (locked while a standalone field is not in edit mode)
//   - Keyboard handling: Enter to select, Tab/Shift+Tab to move fields,
//     End/Home crash prevention (for DBGrid)
//   - Fill-back on blur (for standalone fields)
//
// Two usage scenarios:
//
//   A. Standalone input field (corresponds to the old _LookupEdit):
//      WapLookupBox(
//        value:        currentKey,
//        width:        130,
//        readOnly:     !editing,
//        lookupItems:  {'001': 'Customer A', '002': 'Customer B'},   // single column
//        onChanged:    (key) => ...,                        // selection or fill-back on blur
//      )
//
//   B. DBGrid cell (corresponds to the old _LookupAutoComplete):
//      WapLookupBox(
//        value:          currentKey,
//        lookupColumns:  {'P01': ['Item name', 'ea', '100']},    // multi-column
//        colWidths:      [160, 40, 70],
//        forGrid:        true,                              // enables keyboard field-hopping, no border
//        onChanged:      (key) => ...,
//        onTab:          () => nextCell,
//        onTabPrev:      () => previousCell,
//      )
//
// File history (this file's own internal edit log — unrelated to the
// package version in pubspec.yaml):
//   2026-06-12  rev1  Merged _LookupEdit + _LookupAutoComplete
//   2026-08-22  rev2  Don't cache the lookup map while the dataset isn't
//                     open yet -- see the note above _cols below

/// The lookup drop-down ([WapLookupBox]) behind WML `<input lookup>`.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// @@@ Lazarus version: uses lazarus_sqldb's TSQLQuery (lookupMap is added on top of it)
import 'lazarus_sqldb.dart';

const _kBlue = Color(0xFF1A6FB5);
const _kBorder = Color(0xFFD3D1C7);
const _kReadOnly = Color(0xFFF0EFE9);

/// A lookup drop-down (WML `<input lookup>` / `<item lookup>`).
///
/// The list comes from [dataSet] + [keyField] + [displayFields], or from
/// fixed `lookupItems` / `lookupColumns`. Typing filters the list; picking an
/// item calls `onPicked` (WML `oncloseup`).
class WapLookupBox extends StatefulWidget {
  /// Current value (key)
  final String value;

  /// Field width (for standalone fields; ignored and filled to the cell when forGrid=true)
  final double width;

  /// Height (defaults to 28 for standalone fields; fills the cell when forGrid)
  final double height;

  /// Read-only (locked while a standalone field is not in edit state)
  final bool readOnly;

  /// Single-column lookup: key → display string
  final Map<String, String>? lookupItems;

  /// Multi-column lookup: key → [col1, col2, ...]
  final Map<String, List<String>>? lookupColumns;

  /// Dataset-driven (alternative to lookupColumns): pass the dataset +
  ///  key field + display fields directly, and WapLookupBox calls
  ///  dataSet.lookupMap(keyField, displayFields) itself to compute the list.
  ///  Corresponds to Delphi's TDBLookupComboBox.ListSource/KeyField/ListField.
  final TSQLQuery? dataSet;

  /// Field of [dataSet] that holds the code written back to [value].
  final String? keyField;

  /// Fields of [dataSet] shown as the list's columns.
  final List<String>? displayFields;

  /// Per-column width (px) for the multi-column case
  final List<double> colWidths;

  /// Callback on selection or fill-back on blur (passes the key)
  final ValueChanged<String>? onChanged;

  /// true → DBGrid cell mode: no border, Enter/Tab keyboard handling enabled
  final bool forGrid;

  /// DBGrid cell: Tab → next cell
  final VoidCallback? onTab;

  /// DBGrid cell: Shift+Tab → previous cell
  final VoidCallback? onTabPrev;

  /// Text style (a DBGrid cell can pass a style matching the rest of the table)
  final TextStyle? textStyle;

  /// TextFieldTapRegion group id (standalone fields can share one, to avoid
  /// taps on one blurring another)
  final String? tapRegionGroupId;

  /// Auto-focus when opened (used when a DBGrid Tab enters this cell)
  final bool autofocus;

  /// Callback when a dropdown item is picked (distinct from onChanged:
  /// onChanged = typing, onPicked = picking from the list)
  final ValueChanged<String>? onPicked;

  /// Creates a lookup box showing [value].
  const WapLookupBox({
    super.key,
    required this.value,
    this.width = 130,
    this.height = 28,
    this.readOnly = false,
    this.lookupItems,
    this.lookupColumns,
    this.dataSet,
    this.keyField,
    this.displayFields,
    this.colWidths = const [],
    this.onChanged,
    this.forGrid = false,
    this.onTab,
    this.onTabPrev,
    this.textStyle,
    this.tapRegionGroupId,
    this.autofocus = false,
    this.onPicked,
  });

  @override
  State<WapLookupBox> createState() => _WapLookupBoxState();
}

class _WapLookupBoxState extends State<WapLookupBox> {
  late TextEditingController _ctrl;
  final _focus = FocusNode();
  final _scrollCtrl = ScrollController();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
    _focus.addListener(_onFocus);
    _ctrl.addListener(_onText);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  void _onFocus() {
    if (!_focus.hasFocus) {
      _closeOverlay();
      // Standalone field: fill back the current text on blur (not needed
      // in DBGrid mode, which relies on selection/Enter/Tab instead)
      if (!widget.forGrid) widget.onChanged?.call(_ctrl.text);
    }
  }

  @override
  void didUpdateWidget(WapLookupBox old) {
    super.didUpdateWidget(old);
    // @@@ Data source changed → drop the _cols cache
    if (!identical(old.dataSet, widget.dataSet) ||
        old.keyField != widget.keyField ||
        old.lookupColumns != widget.lookupColumns ||
        old.lookupItems != widget.lookupItems) {
      _invalidateCols();
    }
    if (old.value != widget.value && !_focus.hasFocus) {
      // @@@ Set text+selection together to avoid an out-of-range
      // selection when the text is cleared
      _ctrl.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _ctrl.removeListener(_onText);
    _closeOverlay();
    _ctrl.dispose();
    _focus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Data normalization: unify everything into Map<key, List<displayColumns>> ──
  //  Prefers the dataset-driven source (dataSet.lookupMap), then
  //  lookupColumns, then lookupItems.
  //
  //  @@@ Performance: lookupMap() walks the "entire dataset" via
  //      first()→while(!eof) next(), doing one linear findField name
  //      lookup per column per row, plus a bookmark save/restore. And
  //      _cols is a getter that gets read several times per keystroke
  //      (_filtered(), _dropW, building the dropdown) — meaning every
  //      keystroke would scan the whole table multiple times, which
  //      grinds to a near-halt once the customer table gets large.
  //      So this is cached instead: only rebuilt when the "data source
  //      changes / open state changes / record count changes".
  Map<String, List<String>>? _colsCache;
  int _colsCount = -1; // recordCount at cache time (-1 = not open)
  Object? _colsDs; // dataset at cache time (rebuild if the dataset changes)

  Map<String, List<String>> get _cols {
    final ds = widget.dataSet;
    if (ds != null && widget.keyField != null && widget.displayFields != null) {
      // @@@ 2026-08-22: don't build the cache while the dataset isn't
      //   open yet. This used to compute and cache once regardless of
      //   open state -- while closed, lookupMap() returned empty and
      //   _colsCount got recorded as -1; once the dataset later actually
      //   opened, if its recordCount at that point happened to also make
      //   `_colsCount != n` false, it would never recompute, and the
      //   picker list would stay empty forever.
      //   Dynamically-created sources like lookup="sql;<id>;<SELECT>"
      //   are especially prone to this -- they open later than a dataset
      //   declared via <dbtable>.
      //   While closed, just return an empty Map without writing the
      //   cache, so the next build tries again.
      if (!ds.active) return const {};
      final n = ds.recordCount;
      if (_colsCache == null || _colsCount != n || !identical(_colsDs, ds)) {
        _colsCache = ds.lookupMap(widget.keyField!, widget.displayFields!);
        _colsCount = n;
        _colsDs = ds;
        _searchIdx = null; // data changed → rebuild the search index too
      }
      return _colsCache!;
    }
    return widget.lookupColumns ??
        (widget.lookupItems?.map((k, v) => MapEntry(k, [v])) ?? {});
  }

  // @@@ Search index: concatenate the key + each display column into one
  //     lowercase string up front, so filtering is just a contains() check.
  //     Otherwise every keystroke would call toLowerCase() on every column
  //     of every row (lots of string allocation).
  List<MapEntry<String, String>>? _searchIdx;

  List<MapEntry<String, String>> get _idx {
    final c =
        _cols; // make sure the cache is fresh first (may also clear _searchIdx as a side effect)
    return _searchIdx ??= [
      for (final e in c.entries)
        MapEntry(e.key, ('${e.key} ${e.value.join(' ')}').toLowerCase())
    ];
  }

  void _invalidateCols() {
    _colsCache = null;
    _colsCount = -1;
    _colsDs = null;
    _searchIdx = null;
  }

  List<String> _filtered() {
    final q = _ctrl.text.trim().toLowerCase();
    if (q.isEmpty) return _cols.keys.take(50).toList();
    // @@@ Match against the pre-built lowercase index, capped at 50
    //     results (consistent with the empty-query case): no need to
    //     scan the whole table or allocate tens of thousands of strings
    //     while typing against a large table.
    final out = <String>[];
    for (final e in _idx) {
      if (e.value.contains(q)) {
        out.add(e.key);
        if (out.length >= 50) break;
      }
    }
    return out;
  }

  double _colW(int i) =>
      i < widget.colWidths.length ? widget.colWidths[i] : 120.0;

  double get _dropW {
    final n = _cols.values.firstOrNull?.length ?? 0;
    double w = 80 + 20;
    for (int i = 0; i < n; i++) {
      w += 8 + _colW(i);
    }
    return w.clamp(160.0, 500.0);
  }

  void _onText() {
    if (!mounted) return;
    if (_focus.hasFocus) {
      _showOverlay();
    } else {
      _closeOverlay();
    }
  }

  void _showOverlay() {
    if (!mounted) return;
    _closeOverlay();
    final opts = _filtered();
    if (opts.isEmpty) return;
    _overlay = OverlayEntry(builder: (_) => _buildDropdown(opts));
    Overlay.of(context).insert(_overlay!);
  }

  void _closeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _select(String key) {
    _ctrl.value = TextEditingValue(
      text: key,
      selection: TextSelection.collapsed(offset: key.length),
    );
    (widget.onPicked ?? widget.onChanged)?.call(key);
    _closeOverlay();
    if (widget.forGrid) {
      widget.onTab?.call();
    } else {
      // Regular input: move focus to the next field after picking.
      // Uses _focus.nextFocus() (via the FocusNode's own scope) rather
      // than depending on context — onChanged's setState rebuilds the
      // widget, so context may no longer be valid.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.nextFocus();
      });
    }
  }

  // ── Dropdown list ───────────────────────────────────────────────────
  Widget _buildDropdown(List<String> opts) {
    final nCols = _cols.values.firstOrNull?.length ?? 0;
    final dropW = _dropW;
    final offset = widget.forGrid ? const Offset(0, 26) : const Offset(0, 30);
    final style = widget.textStyle?.copyWith(fontSize: 13) ??
        const TextStyle(fontSize: 12, color: Color(0xFF444441));

    return Positioned(
      width: dropW,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: offset,
        child: TextFieldTapRegion(
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            child: SizedBox(
              width: dropW,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: Scrollbar(
                  controller: _scrollCtrl,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: opts.length,
                    itemBuilder: (ctx, i) {
                      final k = opts[i];
                      final vals = _cols[k] ?? [];
                      return InkWell(
                        onTap: () => _select(k),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          child: Row(children: [
                            SizedBox(
                                width: 80,
                                child: Text(k,
                                    style: style.copyWith(
                                        color: _kBlue,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis)),
                            for (int ci = 0; ci < nCols; ci++) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                  width: _colW(ci),
                                  child: Text(ci < vals.length ? vals[ci] : "",
                                      style: style,
                                      overflow: TextOverflow.ellipsis)),
                            ],
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Keyboard handling (for DBGrid cells) ──────────────────────────────
  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    // End / Home: block native cursor movement, to avoid a crash from an
    // empty-string length conflict
    if (event.logicalKey == LogicalKeyboardKey.end ||
        event.logicalKey == LogicalKeyboardKey.home) {
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        // Enter: prefer an exact match, otherwise the first key that
        // starts with the typed text
        final text = _ctrl.text.trim();
        final key = _cols.containsKey(text)
            ? text
            : _cols.keys.firstWhere(
                (k) => k.toLowerCase().startsWith(text.toLowerCase()),
                orElse: () => text);
        _select(key);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.tab) {
        // Commit the current text (a value typed directly) before Tab,
        // to make sure it's written into dbRecords
        final text = _ctrl.text.trim();
        widget.onChanged?.call(text);
        _closeOverlay();
        if (HardwareKeyboard.instance.isShiftPressed) {
          widget.onTabPrev?.call();
        } else {
          widget.onTab?.call();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // ── build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // DBGrid cell mode: no border, fills the cell, includes keyboard handling
    if (widget.forGrid) {
      return CompositedTransformTarget(
        link: _layerLink,
        child: TextFieldTapRegion(
          child: Focus(
            onKeyEvent: _onKeyEvent,
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              style: widget.textStyle?.copyWith(fontSize: 13) ??
                  const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              onChanged: (v) {
                widget.onChanged
                    ?.call(v); // typing directly also writes back to the grid
                _showOverlay();
              },
              onTap: _showOverlay,
            ),
          ),
        ),
      );
    }

    // Standalone field mode: has a border
    final deco = InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      filled: widget.readOnly,
      fillColor: widget.readOnly ? _kReadOnly : null,
      border: OutlineInputBorder(
          borderSide: const BorderSide(color: _kBorder),
          borderRadius: BorderRadius.circular(3)),
      enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _kBorder),
          borderRadius: BorderRadius.circular(3)),
    );

    if (widget.readOnly) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: TextField(
          readOnly: true,
          controller: _ctrl,
          style: widget.textStyle ?? const TextStyle(fontSize: 12),
          decoration: deco,
        ),
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: TextFieldTapRegion(
          groupId: widget.tapRegionGroupId,
          child: TextField(
            controller: _ctrl,
            focusNode: _focus,
            style: widget.textStyle ?? const TextStyle(fontSize: 12),
            decoration: deco,
            onChanged: (v) {
              _showOverlay();
              // If, while typing, the text exactly matches a key (a full
              // code was entered), fill back the name immediately —
              // no need to wait for blur/Tab. This is what implements
              // "typing a code shows its name right away".
              final t = v.trim();
              if (t.isNotEmpty && _cols.containsKey(t)) {
                widget.onChanged?.call(t);
              }
            },
            onTap: _showOverlay,
          ),
        ),
      ),
    );
  }
}
