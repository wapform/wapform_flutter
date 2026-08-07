// ═════════════════════════════════════════════════════════════════════════════
//  wapform_colors.dart
//  CSS class → color mapping for screens/reports (row / row1 / row2 / td1…)
//  Source: the CSS in assets/wapform.htm; falls back to built-in defaults
//  if that asset fails to load.
//
//  This file is original code (not translated from FPC/Lazarus sources).
//  License: GNU Lesser General Public License v2.1, with the static
//  linking exception (Modified LGPL).
//
//  Copyright (c) 2026 Minhong Information Co., Ltd. (wapform.com)
// ═════════════════════════════════════════════════════════════════════════════
// Revision History:
//   2026-06-06  V2.0  Removed PdfColor; now HTML/CSS only, Flutter Color remains
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WapColors {
  WapColors._();

  static final Map<String, int> _map = {};
  static bool _loaded = false;

  static const Map<String, int> _defaults = {
    'row':  0xFFCDCDCD,
    'row1': 0xFFFFFFFF,
    'row2': 0xFFEEEEEE,
    'td1':  0xFFEFEFEF,
    'td2':  0xFFDEE3E7,
    'td3':  0xFFD1D7DC,
  };

  static Future<void> load({String asset = 'assets/wapform.htm'}) async {
    if (_loaded) return;
    try {
      final src = await rootBundle.loadString(asset);
      _parseCSS(src);
    } catch (_) {
      _map.addAll(_defaults);
    }
    _loaded = true;
  }

  static void _parseCSS(String src) {
    final ruleRx = RegExp(
      r'([a-z]+)\.(\w+)\s*\{[^}]*background-color\s*:\s*(#[0-9a-fA-F]{3,8})',
      multiLine: true, caseSensitive: false,
    );
    for (final m in ruleRx.allMatches(src)) {
      _map[m.group(2)!.toLowerCase()] = _hexToInt(m.group(3)!);
    }
    final plainRx = RegExp(
      r'\.(\w+)\s*\{[^}]*background-color\s*:\s*(#[0-9a-fA-F]{3,8})',
      multiLine: true, caseSensitive: false,
    );
    for (final m in plainRx.allMatches(src)) {
      final cls = m.group(1)!.toLowerCase();
      if (!_map.containsKey(cls)) _map[cls] = _hexToInt(m.group(2)!);
    }
    for (final e in _defaults.entries) _map.putIfAbsent(e.key, () => e.value);
  }

  static int _hexToInt(String hex) {
    var h = hex.replaceFirst('#', '');
    if (h.length == 3) h = '${h[0]}${h[0]}${h[1]}${h[1]}${h[2]}${h[2]}';
    if (h.length == 6) h = 'FF$h';
    return int.parse(h, radix: 16);
  }

  /// Flutter Color (for on-screen display)
  static Color flutter(String cls) {
    final v = _map[cls.toLowerCase()] ?? _defaults[cls.toLowerCase()] ?? 0xFFFFFFFF;
    return Color(v);
  }

  /// CSS hex string (for HTML/PDF)
  static String hex(String cls) {
    final c = flutter(cls);
    return '#${c.red.toRadixString(16).padLeft(2,'0')}'
            '${c.green.toRadixString(16).padLeft(2,'0')}'
            '${c.blue.toRadixString(16).padLeft(2,'0')}';
  }

  static List<String> get classes => _map.keys.toList()..sort();

  static Color get trRow  => flutter('row');
  static Color get trRow1 => flutter('row1');
  static Color get trRow2 => flutter('row2');
  static Color get tdRow1 => flutter('td1');
  static Color get tdRow2 => flutter('td2');
  static Color get tdRow3 => flutter('td3');

  static String get hexTrRow  => hex('row');
  static String get hexTrRow1 => hex('row1');
  static String get hexTrRow2 => hex('row2');
}
