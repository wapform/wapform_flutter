// ignore_for_file: non_constant_identifier_names -- WML function names (ABS, IIF, ...) keep their WML spelling
// ═════════════════════════════════════════════════════════════════════════════
//  wapform_expression.dart
//  WML expression engine (MyParser / WapEvaluator)
//
//  This file is original code (not translated from FPC/Lazarus sources).
//  But it depends on the LGPL translation modules in this repo, so it carries the same license to keep the overall licensing simple.
//
//  License: GNU Lesser General Public License v2.1, with the static linking exception (Modified LGPL)
//        See the accompanying COPYING.LGPL.txt and COPYING.modifiedLGPL.txt.
//
//  Copyright (c) 2026 Minhong Information Co., Ltd. (wapform.com)
// ═════════════════════════════════════════════════════════════════════════════

// wapform_expression.dart — WML expression engine (MyParser / WapEvaluator; merged from myexp_flutter)
// Merged from myexp_flutter/lib/src/*.dart
// Depends on: pubspec.yaml needs crypto: ^3.0.3 added
//
// Usage:
//   final p = MyParser();
//   p.setVar('x', 10);
//   p.expression = 'x * 2 + PADL("abc", 6)';
//   if (p.analyzeExpression()) print(p.value);
//
// Revision History:
//   2026-06-03  V1.0  Merged from myexp_flutter V1.6.0

/// The WapForm expression engine ([WapEvaluator]): variables, operators and
/// the built-in function library used by WML `$(...)`, `cnd=` and `value=`.
library;

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

// ══ expr_types.dart ══
// ============================================================
// myexp.pas → Flutter/Dart converted version
// expr_types.dart  —  Token types, identifier records, function type definitions
// ============================================================

/// Corresponds to Pascal TExprToken
enum ExprToken {
  /// `=`
  equal, // =
  /// `<>`
  ne, // <>
  /// `<`
  lt, // <
  /// `>`
  gt, // >
  /// `<=`
  le, // <=
  /// `>=`
  ge, // >=
  /// `+`
  plus, // +
  /// `-`
  minus, // -
  /// `OR`
  or_, // OR
  /// `*`
  star, // *
  /// `/`
  slash, // /
  /// `DIV`
  div_, // DIV
  /// `MOD`
  mod_, // MOD
  /// `AND`
  and_, // AND
  /// A variable, field or function name.
  identifier,

  /// A numeric literal.
  number,

  /// A hexadecimal literal.
  hex,

  /// A quoted string literal.
  string_,

  /// `.` (dataset.field)
  dot,

  /// `NOT`
  not_, // NOT
  /// `(`
  lParen, // (
  /// `)`
  rParen, // )
  /// `[`
  lArray, // [
  /// `]`
  rArray, // ]
  /// A dotted name.
  name,

  /// `,`
  comma,

  /// End of the expression.
  end_,
}

/// Identifier kind
enum IdentKind { constant, array_, variable, function_ }

/// Function type aliases
typedef Func0 = dynamic Function();

/// A custom function taking one argument (see [WapEvaluator.addFunction1Param]).
typedef Func1 = dynamic Function(dynamic v);

/// A custom function taking two arguments.
typedef Func2 = dynamic Function(dynamic v1, dynamic v2);

/// A custom function taking three arguments.
typedef Func3 = dynamic Function(dynamic v1, dynamic v2, dynamic v3);

/// A custom function taking four arguments.
typedef Func4 = dynamic Function(
    dynamic v1, dynamic v2, dynamic v3, dynamic v4);

/// A custom function taking any number of arguments, passed as a list.
typedef FuncA = dynamic Function(List<dynamic> values);

/// Corresponds to Pascal TStIdentRec
class IdentRecord {
  /// Upper-case identifier name.
  final String name;

  /// Whether this is a variable or a function.
  IdentKind kind;

  /// Value of a variable.
  dynamic value;

  // Function-related
  /// Number of parameters of a function (-1 = any).
  int pCount;

  /// Implementation of a function without parameters.
  Func0? func0;

  /// Implementation of a one-parameter function.
  Func1? func1;

  /// Implementation of a two-parameter function.
  Func2? func2;

  /// Implementation of a three-parameter function.
  Func3? func3;

  /// Implementation of a four-parameter function.
  Func4? func4;

  /// Implementation of a variadic function.
  FuncA? funcA;

  /// Creates an identifier entry.
  IdentRecord({
    required this.name,
    required this.kind,
    this.value,
    this.pCount = 0,
    this.func0,
    this.func1,
    this.func2,
    this.func3,
    this.func4,
    this.funcA,
  });
}

// ══ expr_utils.dart ══
// ============================================================
// myexp.pas → Flutter/Dart converted version
// expr_utils.dart  —  Helper functions (encryption, string conversion, rounding)
// ============================================================

// ──────────────────────────────────────────────────────────────
// StrToHex / HexToStr
// ──────────────────────────────────────────────────────────────

/// String → UTF-8 hex string
String strToHex(String source) {
  final bytes = utf8.encode(source);
  return bytes
      .map((b) => b.toRadixString(16).padLeft(2, "0").toUpperCase())
      .join();
}

/// UTF-8 hex string → string
String hexToStr(String source) {
  final bytes = <int>[];
  for (var i = 0; i < source.length; i += 2) {
    bytes.add(int.parse(source.substring(i, i + 2), radix: 16));
  }
  return utf8.decode(bytes);
}

// ──────────────────────────────────────────────────────────────
// XOR Encrypt / Decrypt (corresponds to Pascal Encrypt/Decrypt)
// ──────────────────────────────────────────────────────────────

/// XOR encrypt; returns an empty string directly for an empty password
dynamic encrypt(dynamic value1, dynamic value2) {
  final str = value1.toString();
  final pwd = value2.toString();
  if (pwd.isEmpty) return '';
  final k = pwd.length;
  var j = 0;
  final buf = StringBuffer();
  for (var i = 0; i < str.length; i++) {
    final b = str.codeUnitAt(i) & 0xFF;
    final p = pwd.codeUnitAt(j) & 0xFF;
    buf.write((b ^ p).toRadixString(16).padLeft(2, "0").toUpperCase());
    j = (j + 1) % k;
  }
  return buf.toString();
}

/// XOR decrypt; returns an empty string directly for an empty password
dynamic decrypt(dynamic value1, dynamic value2) {
  final str = value1.toString();
  final pwd = value2.toString();
  if (pwd.isEmpty) return '';
  final k = pwd.length;
  var j = 0;
  final buf = StringBuffer();
  for (var i = 0; i < str.length ~/ 2; i++) {
    final hex = str.substring(i * 2, i * 2 + 2);
    final b = int.parse(hex, radix: 16);
    final p = pwd.codeUnitAt(j) & 0xFF;
    buf.write(String.fromCharCode(b ^ p));
    j = (j + 1) % k;
  }
  return buf.toString();
}

// ──────────────────────────────────────────────────────────────
// IIF (ternary function)
// ──────────────────────────────────────────────────────────────

/// IIF(condition, trueVal, falseVal)
dynamic iif(dynamic condition, dynamic trueVal, dynamic falseVal) {
  final b = _toBool(condition);
  return b ? trueVal : falseVal;
}

// ──────────────────────────────────────────────────────────────
// Rounding helpers
// ──────────────────────────────────────────────────────────────

/// Round to nearest (corresponds to Pascal Shisha)
double shisha(double x, int n) {
  x = x * pow(10, n - 1);
  x = (x + 0.5).truncateToDouble();
  return x * pow(10, 1 - n).toDouble();
}

/// Round down / truncate (corresponds to Pascal Kirisute)
double kirisute(double x, int n) {
  x = x * pow(10, n - 1);
  x = x.truncateToDouble();
  return x * pow(10, 1 - n).toDouble();
}

/// Round up / ceiling (corresponds to Pascal Kiriage)
double kiriage(double x, int n) {
  x = x * pow(10, n - 1);
  if (x - x.truncateToDouble() > 0.0001) {
    x = x.truncateToDouble() + 1;
  } else {
    x = x.truncateToDouble();
  }
  return x * pow(10, 1 - n).toDouble();
}

/// Simple rounding (corresponds to Pascal MySimpleRoundTo)
double mySimpleRoundTo(double value, int digit) {
  if (digit < 0) {
    // Rounding to decimal places: scale by an exact power of ten, then trim
    // binary noise to 15 significant digits (1.005*100 = 100.49999…) before
    // rounding half away from zero, so ROUND(1.005,2) = 1.01 and
    // ROUND(6.6,1) = 6.6 exactly.
    final m = pow(10.0, -digit).toDouble();
    final s = double.parse((value.abs() * m).toStringAsPrecision(15));
    final r = (s + 0.5).floorToDouble();
    return (value < 0 ? -r : r) / m;
  }
  final factor = pow(10.0, digit).toDouble();
  final e = pow(10.0, digit - 1).toDouble() * 5;
  double f;
  if (value < 0) {
    f = (value - e) / factor;
    f = f.truncateToDouble();
  } else {
    f = (value + e) / factor;
    f = f.truncateToDouble();
  }
  return f * factor;
}

// ──────────────────────────────────────────────────────────────
// Type conversion helpers (shared across the whole library)
// ──────────────────────────────────────────────────────────────

bool _toBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.toLowerCase();
    return s == 'true' || s == '1' || s == 'y' || s == 't';
  }
  return false;
}

// aa ??? issue
// Renamed to private (was a public top-level `isNull`): unused anywhere
// in this codebase, and its name collided with package:matcher's
// `isNull` — any file importing this package alongside flutter_test
// (e.g. a test file that also needs an expression-engine helper) would
// hit an ambiguous_export compile error on `expect(x, isNull)`.
// zz ??? issue

/// Converts an expression value to a string (null becomes '').
String varToStr(dynamic v) {
  if (v == null) return '';
  return v.toString();
}

/// Converts an expression value to a double (0 when not numeric).
double varToDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is bool) return v ? 1.0 : 0.0;
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

/// Converts an expression value to an int (0 when not numeric).
int varToInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is bool) return v ? 1 : 0;
  if (v is String) return int.tryParse(v) ?? (double.tryParse(v)?.toInt() ?? 0);
  return 0;
}

/// Converts an expression value to a DateTime, or null.
DateTime? varToDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

// ══ expr_builtins.dart ══
// ============================================================
// myexp.pas → Flutter/Dart converted version
// expr_builtins.dart  —  Built-in functions (corresponds to Pascal's _XXX function group)
// ============================================================

// ──────────────────────────────────────────────────────────────
// ANSI / UTF8 (unified to String under Flutter; UTF-8 is handled transparently)
// ──────────────────────────────────────────────────────────────

/// Expression function `ANSI(s)`: UTF-8 to ANSI. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnANSI(dynamic value) => value?.toString() ?? '';

/// Expression function `UTF8(s)`: ANSI to UTF-8. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnUTF8(dynamic value) => value?.toString() ?? '';

// ──────────────────────────────────────────────────────────────
// AnsiDelete / AnsiInsert / AnsiLength / AnsiMid / AnsiPos
// (String is already Unicode in Flutter, indexed by character)
// ──────────────────────────────────────────────────────────────

/// Expression function `AnsiDelete(s,p,n)`: Deletes a substring (ANSI count).
dynamic fnAnsiDelete(dynamic v1, dynamic v2, dynamic v3) {
  var s = varToStr(v1);
  final index = varToInt(v2) - 1; // 1-based → 0-based
  final count = varToInt(v3);
  if (index < 0 || index >= s.length) return s;
  final end_ = (index + count).clamp(0, s.length);
  return s.substring(0, index) + s.substring(end_);
}

/// Expression function `AnsiInsert(s,p,new)`: Inserts a string (ANSI count). The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnAnsiInsert(dynamic v1, dynamic v2, dynamic v3) {
  final substr = varToStr(v1);
  var s = varToStr(v2);
  final i = varToInt(v3) - 1; // 1-based → 0-based
  final pos = i.clamp(0, s.length);
  return s.substring(0, pos) + substr + s.substring(pos);
}

/// Expression function `AnsiLength(s)`: ANSI byte length. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnAnsiLength(dynamic value) => varToStr(value).length;

/// Expression function `AnsiMid(s,p,n)`: Extracts a substring (ANSI count).
dynamic fnAnsiMid(dynamic v1, dynamic v2, dynamic v3) {
  final s = varToStr(v1);
  final index = varToInt(v2) - 1;
  final count = varToInt(v3);
  if (index < 0 || index >= s.length) return '';
  final end_ = (index + count).clamp(0, s.length);
  return s.substring(index, end_);
}

/// Expression function `AnsiPos(sub,s)`: Finds a substring's position (ANSI count).
dynamic fnAnsiPos(dynamic v1, dynamic v2) {
  final substr = varToStr(v1);
  final s = varToStr(v2);
  final pos = s.indexOf(substr);
  return pos < 0 ? 0 : pos + 1; // 1-based
}

// ──────────────────────────────────────────────────────────────
// Numeric
// ──────────────────────────────────────────────────────────────

/// Expression function `ABS(x)`: Absolute value.
dynamic fnAbs(dynamic value) => varToDouble(value).abs();

/// Expression function `CEIL(x)`: Rounds up.
dynamic fnCeil(dynamic value) => varToDouble(value).ceil();

/// Expression function `FLOOR(x)`: Rounds down.
dynamic fnFloor(dynamic value) => varToDouble(value).floor();

/// Expression function `FRAC(x)`: Takes the decimal portion.
dynamic fnFrac(dynamic value) {
  final v = varToDouble(value);
  return v - v.truncateToDouble();
}

/// Expression function `TRUNC(x)`: Truncates the decimal portion, rounding toward zero (regardless of sign).
dynamic fnTrunc(dynamic value) => varToDouble(value).truncate();

/// Expression function `INT(x)`: Takes the integer part (truncated toward zero).
dynamic fnInt(dynamic value) => varToDouble(value).truncate();

/// Expression function `FLOAT(x)`: Forces conversion to a float type.
dynamic fnFloat(dynamic value) => varToDouble(value);

/// Expression function `SQR(x)`: Square.
dynamic fnSqr(dynamic value) {
  final v = varToDouble(value);
  return v * v;
}

/// Expression function `SQRT(x)`: Square root.
dynamic fnSqrt(dynamic value) => sqrt(varToDouble(value));

/// Expression function `EXP(x)`: e raised to the power.
dynamic fnExp(dynamic value) => exp(varToDouble(value));

/// Expression function `LN(x)`: Natural logarithm.
dynamic fnLn(dynamic value) => log(varToDouble(value));

/// Expression function `POWER(x,n)`: x raised to the power n.
dynamic fnPower(dynamic v1, dynamic v2) =>
    pow(varToDouble(v1), varToDouble(v2)).toDouble();

/// Expression function `SIN(x)`: Sine.
dynamic fnSin(dynamic value) => sin(varToDouble(value));

/// Expression function `COS(x)`: Cosine.
dynamic fnCos(dynamic value) => cos(varToDouble(value));

/// Expression function `TAN(x)`: Tangent.
dynamic fnTan(dynamic value) => tan(varToDouble(value));

/// Expression function `ArcSin(x1)`: Arc sine (same as ASIN).
dynamic fnArcSin(dynamic value) => asin(varToDouble(value));

/// Expression function `ArcCos(x1)`: Arc cosine (same as ACOS).
dynamic fnArcCos(dynamic value) => acos(varToDouble(value));

/// Expression function `ArcTan(x1)`: Arc tangent (same as ATAN).
dynamic fnArcTan(dynamic value) => atan(varToDouble(value));

/// Expression function `PI`: The constant pi.
dynamic fnPi() => pi;

/// Expression function `ROUND(x,d)`: Rounds to d decimal places (standard rounding).
dynamic fnRound(dynamic v) {
  final e = varToDouble(v);
  return mySimpleRoundTo(e, 0).round();
}

/// Expression function `ROUNDTO(x,digits)`: Rounds to digits decimal places.
dynamic fnRoundTo(dynamic v1, dynamic v2) {
  final e = varToDouble(v1);
  final d = varToInt(v2);
  // WapForm's public-facing ROUND/ROUNDTO follows the spreadsheet
  // convention: a positive d means decimal places, negative means integer
  // places (e.g. ROUND(-50.55,-2) → -100). But mySimpleRoundTo follows
  // Delphi's native RoundTo convention, where the sign is exactly
  // inverted (Delphi's RoundTo(x,-2) is what actually means "round to 2
  // decimal places"), so the sign has to be flipped here first.
  return mySimpleRoundTo(e, -d);
}

/// Expression function `Odd(n)`: Whether it's odd.
dynamic fnOdd(dynamic value) {
  final i = varToInt(value);
  return i.isOdd;
}

/// Expression function `MAX(a,b)`: Returns the larger of the two.
dynamic fnMax(dynamic v1, dynamic v2) {
  return varToDouble(v1) > varToDouble(v2) ? v1 : v2;
}

/// Expression function `MIN(a,b)`: Returns the smaller of the two.
dynamic fnMin(dynamic v1, dynamic v2) {
  return varToDouble(v1) < varToDouble(v2) ? v1 : v2;
}

/// Expression function `RANDOM(lo,hi)`: Random integer in [lo,hi).
dynamic fnRandom(dynamic value) {
  final rng = Random();
  final n = varToInt(value);
  if (n == 0) return rng.nextDouble();
  return rng.nextInt(n);
}

/// Expression function `RANDOMRANGE(lo,hi)`: Random integer in [lo,hi).
dynamic fnRandomRange(dynamic v1, dynamic v2) {
  final rng = Random();
  final lo = varToInt(v1);
  final hi = varToInt(v2);
  if (hi <= lo) return lo;
  return lo + rng.nextInt(hi - lo);
}

// ──────────────────────────────────────────────────────────────
// String
// ──────────────────────────────────────────────────────────────

/// Expression function `ASC(c)`: Character to code point.
dynamic fnAsc(dynamic value) {
  final s = varToStr(value);
  if (s.isEmpty) return 0;
  return s.codeUnitAt(0);
}

/// Expression function `CHR(n)`: Code point to character.
dynamic fnCHR(dynamic value) {
  final i = varToInt(value);
  return String.fromCharCode(i);
}

/// Expression function `COPY(x1, x2, x3)`: Substring (same as Pascal Copy).
dynamic fnCOPY(dynamic v1, dynamic v2, dynamic v3) {
  final s = varToStr(v1);
  final index = varToInt(v2) - 1;
  final count = varToInt(v3);
  if (index < 0 || index >= s.length) return '';
  return s.substring(index, (index + count).clamp(0, s.length));
}

/// Expression function `DELETE(s,p,n)`: Deletes a substring (byte).
dynamic fnDELETE(dynamic v1, dynamic v2, dynamic v3) =>
    fnAnsiDelete(v1, v2, v3);

/// Expression function `INSERT(s,p,n,new)`: Inserts a string (byte). The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnINSERT(dynamic v1, dynamic v2, dynamic v3) {
  final substr = varToStr(v1);
  var s = varToStr(v2);
  final i = varToInt(v3) - 1;
  final pos = i.clamp(0, s.length);
  return s.substring(0, pos) + substr + s.substring(pos);
}

/// Expression function `LENGTH(s)`: String length.
dynamic fnLENGTH(dynamic value) => varToStr(value).length;

/// Expression function `LOWER(s)`: Converts to lowercase.
dynamic fnLOWER(dynamic value) => varToStr(value).toLowerCase();

/// Expression function `UPPER(s)`: Converts to uppercase.
dynamic fnUPPER(dynamic value) => varToStr(value).toUpperCase();

/// Expression function `UPPERA(s)`: Converts to uppercase (Ansi version).
dynamic fnUPPERA(dynamic value) => varToStr(value).toUpperCase();

/// Expression function `LTRIM(s)`: Removes leading whitespace.
dynamic fnLTRIM(dynamic value) => varToStr(value).trimLeft();

/// Expression function `RTRIM(s)`: Removes trailing whitespace.
dynamic fnRTRIM(dynamic value) => varToStr(value).trimRight();

/// Expression function `TRIM(s)`: Removes leading and trailing whitespace.
dynamic fnTRIM(dynamic value) => varToStr(value).trim();

/// Expression function `TrimLeft(x1)`: Removes leading spaces.
dynamic fnTrimLeft(dynamic value) => varToStr(value).trimLeft();

/// Expression function `TrimRight(x1)`: Removes trailing spaces.
dynamic fnTrimRight(dynamic value) => varToStr(value).trimRight();

/// Expression function `MID(s,p,n)`: Extracts a substring (byte count).
dynamic fnMID(dynamic v1, dynamic v2, dynamic v3) => fnAnsiMid(v1, v2, v3);

/// Expression function `POS(sub,s)`: Finds a substring's position (byte count).
dynamic fnPOS(dynamic v1, dynamic v2) {
  final sub = varToStr(v1);
  final s = varToStr(v2);
  if (sub.isEmpty || s.isEmpty) return 0;
  final i = s.indexOf(sub);
  return i < 0 ? 0 : i + 1;
}

/// Expression function `LOCATE(sub,s)`: Position of a substring.
dynamic fnLOCATE(dynamic v1, dynamic v2) => fnPOS(v1, v2);

/// Expression function `INSTR(s,sub)`: Finds a string's position.
dynamic fnINSTR(dynamic v1, dynamic v2) => fnPOS(v2, v1); // INSTR(str, sub)

/// Expression function `REPLACE(s,old,new)`: Replaces text within a string.
dynamic fnREPLACE(dynamic v1, dynamic v2, dynamic v3) {
  return varToStr(v1).replaceAll(varToStr(v2), varToStr(v3));
}

/// Expression function `REPLACEAT(s,p,new)`: Replaces at a specified position. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnReplaceAt(dynamic v1, dynamic v2, dynamic v3) {
  var s1 = varToStr(v1);
  final s2 = varToStr(v2);
  final i = varToInt(v3) - 1;
  final j = s2.length;
  if (i < 0 || i >= s1.length) return s1;
  s1 = s1.substring(0, i) + s1.substring((i + j).clamp(0, s1.length));
  return s1.substring(0, i) + s2 + s1.substring(i);
}

/// Expression function `IntToStr(n)`: Converts an integer to a string.
dynamic fnIntToStr(dynamic value) => varToInt(value).toString();

/// Expression function `FloatToStr(n)`: Converts a float to a string.
dynamic fnFloatToStr(dynamic value) => varToDouble(value).toString();

/// Expression function `StrToInt(s)`: Converts a string to an integer.
dynamic fnStrToInt(dynamic value) => int.tryParse(varToStr(value)) ?? 0;

/// Expression function `StrToFloat(s)`: Converts a string to a float.
dynamic fnStrToFloat(dynamic value) => double.tryParse(varToStr(value)) ?? 0.0;

/// Expression function `StrToHex(s)`: Converts a string to hex encoding.
dynamic fnStrToHex(dynamic value) => strToHex(varToStr(value));

/// Expression function `HexToStr(s)`: Converts hex encoding to a string.
dynamic fnHexToStr(dynamic value) => hexToStr(varToStr(value));

/// Expression function `IntToHex(n,d)`: Converts an integer to a hex string.
dynamic fnIntToHex(dynamic v1, dynamic v2) {
  final n = varToInt(v1);
  final width = varToInt(v2);
  return n.toRadixString(16).toUpperCase().padLeft(width, "0");
}

/// Expression function `HEX(n,d)`: Converts an integer to a hex string.
dynamic fnHex(dynamic v1, dynamic v2) => fnIntToHex(v1, v2);

/// Expression function `HexToInt(s)`: Converts a hex string to an integer.
dynamic fnHexToInt(dynamic value) {
  final s = varToStr(value);
  return int.tryParse(s, radix: 16) ?? 0;
}

/// Expression function `ORD(c)`: Character's ordinal value (same as ASC).
dynamic fnORD(dynamic value) {
  final s = varToStr(value);
  if (s.isEmpty) return 0;
  return s.codeUnitAt(0);
}

// ──────────────────────────────────────────────────────────────
// FORMAT / FormatDateTime / FormatFloat
// ──────────────────────────────────────────────────────────────

/// Expression function `FORMAT(fmt,x)`: Formatted output. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnFORMAT(dynamic v1, dynamic v2) {
  // Simplified version: sprintf-style, only supports basic %d, %f, %s
  if (v2 == null) return '';
  final fmt = varToStr(v1);
  return _sprintfSimple(fmt, v2);
}

String _sprintfSimple(String fmt, dynamic value) {
  // Basic implementation: replaces common formats like %d, %f, %s, %2.2d
  return fmt.replaceAllMapped(
    RegExp(
        r"%(\d*\.?\d*)([dfsxXnmge])"), // @@@ added n = thousands-separated number
    (m) {
      final spec = m.group(2)!;
      final width = m.group(1) ?? '';
      switch (spec) {
        case 'd':
        case 'i':
          final n = varToInt(value);
          return _padWidth(n.toString(), width);
        case 'f':
          final f = varToDouble(value);
          final parts = width.split(".");
          final dec = parts.length > 1 ? int.tryParse(parts[1]) ?? 2 : 2;
          return f.toStringAsFixed(dec);
        case 's':
          return varToStr(value);
        case 'x':
          return varToInt(value).toRadixString(16);
        case 'X':
          return varToInt(value).toRadixString(16).toUpperCase();
        case 'n': // @@@ Delphi %w.pn: thousands separator, p decimal places (%7.0n → 2,448)
        case 'm':
          final f = varToDouble(value);
          final parts = width.split(".");
          final dec = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
          return _thousandsSep(f, dec);
        default:
          return m.group(0)!;
      }
    },
  );
}

// @@@ Thousands-separator formatting: takes dec decimal places, inserts a comma every 3 digits in the integer part. %7.0n=2,448.
String _thousandsSep(double f, int dec) {
  final neg = f < 0;
  final fixed = f.abs().toStringAsFixed(dec);
  final dot = fixed.indexOf('.');
  final intPart = dot >= 0 ? fixed.substring(0, dot) : fixed;
  final decPart = dot >= 0 ? fixed.substring(dot) : '';
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  return (neg ? '-' : '') + buf.toString() + decPart;
}

String _padWidth(String s, String width) {
  if (width.isEmpty) return s;
  // Delphi FORMAT's %2.2d: '2.2' means width.precision.
  // For integers, precision = minimum digit count (zero-padded if short), width = total column width (space-padded if short).
  // Simplified here: takes the larger of the two as the zero-pad width (%4.4d→4, %2.2d→2).
  int w;
  if (width.contains(".")) {
    final parts = width.split(".");
    final wd = int.tryParse(parts[0]) ?? 0;
    final pr = int.tryParse(parts.length > 1 ? parts[1] : "") ?? 0;
    w = wd > pr ? wd : pr;
  } else {
    w = int.tryParse(width) ?? 0;
  }
  return s.padLeft(w, "0");
}

/// Expression function `FormatDateTime(fmt,d)`: Formats a date/time according to a custom pattern string.
dynamic fnFormatDateTime(dynamic v1, dynamic v2) {
  if (v2 == null) return '';
  DateTime? dt;
  if (v2 is DateTime) {
    dt = v2;
  } else {
    dt = DateTime.tryParse(varToStr(v2));
  }
  if (dt == null) return '';
  return _formatDateTime(varToStr(v1), dt);
}

String _formatDateTime(String fmt, DateTime dt) {
  // Mapping for basic Delphi/Pascal format codes
  return fmt
      .replaceAll("yyyy", dt.year.toString().padLeft(4, "0"))
      .replaceAll("yy", (dt.year % 100).toString().padLeft(2, "0"))
      .replaceAll("mm", dt.month.toString().padLeft(2, "0"))
      .replaceAll("dd", dt.day.toString().padLeft(2, "0"))
      .replaceAll("hh", dt.hour.toString().padLeft(2, "0"))
      .replaceAll("nn", dt.minute.toString().padLeft(2, "0"))
      .replaceAll("ss", dt.second.toString().padLeft(2, "0"))
      .replaceAll("zzz", dt.millisecond.toString().padLeft(3, "0"))
      .replaceAll("m", dt.month.toString())
      .replaceAll("d", dt.day.toString())
      .replaceAll("h", dt.hour.toString())
      .replaceAll("n", dt.minute.toString())
      .replaceAll("s", dt.second.toString());
}

/// Expression function `FormatFloat(fmt,n)`: Formats a floating-point number according to a custom pattern string.
dynamic fnFormatFloat(dynamic v1, dynamic v2) {
  if (v2 == null) return '';
  final val = varToDouble(v2);
  // Supports basic formats like '#,##0.00'
  return _formatFloat(varToStr(v1), val);
}

String _formatFloat(String fmt, double val) {
  final neg = val < 0;
  final absVal = val.abs();
  final decPos = fmt.indexOf(".");
  final intFmt = decPos >= 0 ? fmt.substring(0, decPos) : fmt;
  final decFmt = decPos >= 0 ? fmt.substring(decPos + 1) : "";
  final decPlaces = decFmt.replaceAll(RegExp(r"[^0#]"), "").length;

  final intPart = absVal.truncate().toString();
  final decPart = decPlaces > 0
      ? ((absVal - absVal.truncateToDouble()) * pow(10, decPlaces))
          .round()
          .toString()
          .padLeft(decPlaces, "0")
      : "";

  final useComma = intFmt.contains(",");
  String result;
  if (useComma) {
    result = _commaFormat(intPart);
  } else {
    result = intPart;
  }
  if (decPlaces > 0) result = '$result.$decPart';
  return (neg ? '-' : "") + result;
}

String _commaFormat(String s) {
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(",");
    buf.write(s[i]);
  }
  return buf.toString();
}

// ──────────────────────────────────────────────────────────────
// Date/time
// ──────────────────────────────────────────────────────────────

/// Expression function `DATE`: Current date (no parameters, changes with the run date).
dynamic fnDATE() => DateTime.now()
    .toLocal()
    .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);

/// Expression function `NOW`: The current date and time (in a different format).
dynamic fnNOW() => DateTime.now();

/// Expression function `TODAY`: Today's date.
dynamic fnTODAY() => DateTime.now()
    .toLocal()
    .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);

/// Expression function `TIME`: The current time (the time portion of CURRENT_DATE).
dynamic fnTIME() => DateTime.now();

/// Expression function `YEAR(d)`: Extracts the year.
dynamic fnYEAR(dynamic value) {
  final dt = _toDateTime(value);
  return dt?.year ?? 0;
}

/// Expression function `MONTH(d)`: Extracts the month.
dynamic fnMONTH(dynamic value) {
  final dt = _toDateTime(value);
  return dt?.month ?? 0;
}

/// Expression function `DAY(d)`: Extracts the day.
dynamic fnDAY(dynamic value) {
  final dt = _toDateTime(value);
  return dt?.day ?? 0;
}

/// Expression function `DAYOFMONTH(d)`: Extracts the "day" of a date (same as DAY).
dynamic fnDAYOFMONTH(dynamic value) => fnDAY(value);

/// Expression function `DAYOFWEEK(d)`: Extracts the day of the week (uses DateUtils.DayOfTheWeek underneath, 1=Monday...7=Sunday).
dynamic fnDAYOFWEEK(dynamic value) {
  final dt = _toDateTime(value);
  if (dt == null) return 0;
  // ISO: Mon=1 .. Sun=7
  return dt.weekday;
}

/// Expression function `DAYOFYEAR(d)`: Extracts the day of the year.
dynamic fnDAYOFYEAR(dynamic value) {
  final dt = _toDateTime(value);
  if (dt == null) return 0;
  return dt.difference(DateTime(dt.year, 1, 1)).inDays + 1;
}

/// Expression function `HOUR(d)`: Extracts the hour. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnHOUR(dynamic value) {
  final dt = _toDateTime(value);
  return dt?.hour ?? 0;
}

/// Expression function `MINUTE(d)`: Extracts the minute. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnMINUTE(dynamic value) {
  final dt = _toDateTime(value);
  return dt?.minute ?? 0;
}

/// Expression function `SECOND(d)`: Extracts the second.
dynamic fnSECOND(dynamic value) {
  final dt = _toDateTime(value);
  return dt?.second ?? 0;
}

/// Expression function `WEEK(d)`: Extracts the week number.
dynamic fnWEEK(dynamic value) {
  final dt = _toDateTime(value);
  if (dt == null) return 0;
  // ISO week number
  final startOfYear = DateTime(dt.year, 1, 1);
  return ((dt.difference(startOfYear).inDays + startOfYear.weekday - 1) ~/ 7) +
      1;
}

/// Expression function `DaysInAMonth(y,m)`: Gets the number of days in a given year and month.
dynamic fnDaysInAMonth(dynamic v1, dynamic v2) {
  final year = varToInt(v1);
  final month = varToInt(v2);
  return DateTime(year, month + 1, 0).day;
}

/// Expression function `IsLeapYear(y)`: Whether it's a leap year.
dynamic fnIsLeapYear(dynamic value) {
  final y = varToInt(value);
  return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
}

/// Expression function `DateTimeToStr(d)`: Converts a date/time to a string (formatted per the system's regional settings).
dynamic fnDateTimeToStr(dynamic value) {
  final dt = _toDateTime(value);
  if (dt == null) return '';
  return dt.toString();
}

/// Expression function `DateToStr(d)`: Converts a date to a string (formatted per the system's regional settings).
dynamic fnDateToStr(dynamic value) {
  final dt = _toDateTime(value);
  if (dt == null) return '';
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

/// Expression function `TimeToStr(t)`: Converts a time to a string. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnTimeToStr(dynamic value) {
  final dt = _toDateTime(value);
  if (dt == null) return '';
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
}

/// Expression function `StrToDate(s)`: Converts a string to a date. In this Dart engine it returns a date serial number (days since 1899-12-30); see the manual, Appendix C.2.
dynamic fnStrToDate(dynamic value) {
  var s = varToStr(value).replaceAll("/", "-");
  final dt = DateTime.tryParse(s);
  if (dt == null) return null;
  // Takes only the date portion, zeroing the time, so that if the string
  // carries a time component it doesn't get counted into the fractional part.
  return _toDelphiSerial(DateTime(dt.year, dt.month, dt.day));
}

/// Expression function `StrToDateTime(s)`: Converts a string to a date/time. In this Dart engine it returns a date serial number (days since 1899-12-30); see the manual, Appendix C.2.
dynamic fnStrToDateTime(dynamic value) {
  var s = varToStr(value).replaceAll("/", "-");
  final dt = DateTime.tryParse(s);
  if (dt == null) return null;
  return _toDelphiSerial(dt);
}

/// Expression function `StrToTime(s)`: Converts a string to a time. In this Dart engine it returns a date serial number (days since 1899-12-30); see the manual, Appendix C.2.
dynamic fnStrToTime(dynamic value) {
  final dt = DateTime.tryParse("1970-01-01T${varToStr(value)}");
  if (dt == null) return null;
  // Pure time: counts only what fraction of the day the time-of-day is,
  // no date-serial component.
  return (dt.hour * 3600 + dt.minute * 60 + dt.second) / 86400.0;
}

/// Expression function `DateSerialValue(y, m, d)`: Combines year, month, day into a TDateTime. In this Dart engine it returns a date serial number (days since 1899-12-30); see the manual, Appendix C.2.
dynamic fnDateSerialValue(dynamic y, dynamic m, dynamic d) {
  final dt = DateTime(varToInt(y), varToInt(m), varToInt(d));
  return _toDelphiSerial(dt);
}

/// Expression function `TimeSerialValue(h, m, s)`: Combines hour, minute, second into a TDateTime. In this Dart engine it returns a date serial number (days since 1899-12-30); see the manual, Appendix C.2.
dynamic fnTimeSerialValue(dynamic h, dynamic m, dynamic s) {
  final hh = varToInt(h), mm = varToInt(m), ss = varToInt(s);
  return (hh * 3600 + mm * 60 + ss) / 86400.0;
}

/// Expression function `MyDate(d)`: Custom date formatting (ROC-calendar format). The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnMyDate(dynamic value) {
  final dt = _toDateTime(value);
  if (dt == null) return '';
  return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

/// Expression function `MyDateTime(d)`: Custom date/time formatting (ROC-calendar format). The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnMyDateTime(dynamic value) {
  final dt = _toDateTime(value);
  if (dt == null) return '';
  return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
}

/// Expression function `TDATE`: An alias for the system date.
dynamic fnTDATE() {
  final dt = DateTime.now();
  final roc = dt.year - 1911;
  return '${roc.toString().padLeft(3, '0')}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}';
}

/// Expression function `BDATE(x1)`: Date conversion (for compatibility).
dynamic fnBDATE(dynamic value) {
  final s = varToStr(value);
  if (s.isEmpty) return '';
  final parts = s.split("/");
  if (parts.length < 3) return '';
  final y = int.tryParse(parts[2]) ?? 0;
  final m = int.tryParse(parts[0]) ?? 0;
  final d = int.tryParse(parts[1]) ?? 0;
  final roc = y + 11 - 1911;
  return roc.toString().padLeft(2, "0") +
      m.toString().padLeft(2, "0") +
      d.toString().padLeft(2, "0");
}

/// Expression function `yesterday`: Yesterday's date.
dynamic fnYesterday() {
  final now = DateTime.now();
  return now.subtract(const Duration(days: 1));
}

/// Expression function `last-night()`: The time point corresponding to last night.
dynamic fnLastNight() {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
}

/// Expression function `last-month()`: The first day of last month.
dynamic fnLastMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month - 1, now.day);
}

/// Expression function `last-week`: The same day last week.
dynamic fnLastWeek() {
  return DateTime.now().subtract(const Duration(days: 7));
}

/// Expression function `last-year()`: The first day of last year.
dynamic fnLastYear() {
  final now = DateTime.now();
  return DateTime(now.year - 1, now.month, now.day);
}

DateTime? _toDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

/// Dart DateTime → Delphi TDateTime numeric serial (epoch 1899-12-30,
/// integer part is the day count, fractional part is what fraction of
/// the day the time-of-day is).
double _toDelphiSerial(DateTime dt) {
  final epoch = DateTime(1899, 12, 30);
  return dt.difference(epoch).inMicroseconds / (24 * 60 * 60 * 1000000.0);
}

// ──────────────────────────────────────────────────────────────
// Logic / type-checking
// ──────────────────────────────────────────────────────────────

/// Expression function `Assigned(x)`: Whether the object has been assigned.
dynamic fnAssigned(dynamic value) => value != null;

dynamic fnISSEVEN(dynamic value) => (varToInt(value) % 2) == 0;

/// Expression function `ISODD(x)`: Whether it's odd.
dynamic fnISODD(dynamic value) => (varToInt(value) % 2) != 0;

/// Expression function `ISNULL(x)`: Whether it's NULL. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnISNULL(dynamic value) => value == null;

/// Expression function `ISNUMBER(x)`: Whether it's a numeric type.
dynamic fnISNUMBER(dynamic value) {
  final s = varToStr(value);
  return double.tryParse(s) != null || int.tryParse(s) != null;
}

/// Expression function `DEFINE(request.foo)`: Checks whether a request parameter exists.
dynamic fnDEFINE(dynamic value) => value != null;

/// Expression function `VarIsNull(x)`: Whether the Variant is Null. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnVarIsNull(dynamic value) => value == null;

/// Expression function `VarToStr(v)`: Converts a Variant to a string.
dynamic fnVarToStr(dynamic value) => varToStr(value);

/// Expression function `VARTYPE(v)`: Returns the type name as a string (same as TYPE).
dynamic fnVarType(dynamic value) {
  if (value == null) return 'varNull';
  if (value is bool) return 'varBoolean';
  if (value is int) return 'varInteger';
  if (value is double) return 'varDouble';
  if (value is String) return 'varString';
  if (value is DateTime) return 'varDate';
  return 'varUnknown';
}

/// Expression function `STR(n)`: Converts a number to a string.
dynamic fnSTR(dynamic value) {
  if (value == null) return '';
  if (value is int) return value.toString();
  if (value is double) return value.toString();
  return varToStr(value);
}

// ──────────────────────────────────────────────────────────────
// HTML / misc
// ──────────────────────────────────────────────────────────────

/// Expression function `HTML(s)`: HTML special-character escaping. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnHTML(dynamic value) {
  final lines = varToStr(value).split("\n");
  return lines.map((l) => '$l<br/>').join("");
}

/// Expression function `NBSP`: Non-breaking space.
dynamic fnNBSP() => '&#160;';

/// Expression function `NULL`: The Null constant.
dynamic fnNULL() => null;

/// Expression function `TRUE`: The boolean true constant.
dynamic fnTRUE() => true;

/// Expression function `FALSE`: The boolean false constant.
dynamic fnFALSE() => false;

/// Expression function `DBX`: The multi-tier architecture flag.
dynamic fnDBX() => false; // not an N-Tier environment

/// Expression function `GetUrlContent(url)`: Fetches the content of a URL.
dynamic fnGetUrlContent(dynamic value) {
  // Would need the http package under Flutter; returns a placeholder here
  return '(fnGetUrlContent: use http package in Flutter)';
}

/// Expression function `GetFreeRes`: Gets the available resources.
dynamic fnGetFreeRes() => '(fnGetFreeRes: not available on Flutter)';

/// Expression function `GetPhysMem`: Gets the physical memory size.
dynamic fnGetPhysMem() => '(fnGetPhysMem: not available on Flutter)';

/// Expression function `GetMacPhysicalAddress`: Gets the MAC physical address.
dynamic fnGetMacPhysicalAddress() =>
    '(fnGetMacPhysicalAddress: not available on Flutter)';

/// Expression function `CPU`: (no matching registration/use found in the source).
dynamic fnCPU() => '(fnCPU: not available on Flutter)';

/// Expression function `loCaseInsensitive`: Locate option: case-insensitive.
dynamic fnLoCaseInsensitive() => true;

/// Expression function `loPartialKey`: Locate option: partial key.
dynamic fnLoPartialKey() => true;

/// Expression function `ColorToHex(n)`: Converts a color value to hex. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnColorToHex(dynamic value) {
  final color = varToInt(value);
  // Delphi's TColor is internally stored as 0x00BBGGRR (BGR, R in the
  // low byte), not the intuitively-expected 0xRRGGBB -- the r/b byte
  // positions were previously swapped.
  final r = color & 0xFF;
  final g = (color >> 8) & 0xFF;
  final b = (color >> 16) & 0xFF;
  return '${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
}

/// Expression function `HexToColor(s)`: Converts hex to a color value. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnHexToColor(dynamic value) {
  var s = varToStr(value).trim().replaceAll("#", "");
  if (s.length != 6) return 0x00FFFFFF;
  final r = int.tryParse(s.substring(0, 2), radix: 16) ?? 255;
  final g = int.tryParse(s.substring(2, 4), radix: 16) ?? 255;
  final b = int.tryParse(s.substring(4, 6), radix: 16) ?? 255;
  // Delphi's TColor is a 24-bit 0x00BBGGRR (BGR, no alpha channel),
  // not Flutter's 0xAARRGGBB -- an alpha byte was previously being added
  // that shouldn't be there, and the input RGB wasn't being converted to
  // Delphi's BGR byte order.
  return (b << 16) | (g << 8) | r;
}

/// Expression function `MD5(s)`: Computes the MD5 hash of a string.
dynamic fnMD5(dynamic value) {
  final s = varToStr(value);
  final bytes = utf8.encode(s);
  return md5.convert(bytes).toString().toUpperCase();
}

/// Expression function `name`: (optional). The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnNAME(dynamic value) {
  final s = varToStr(value);
  final p = s.indexOf("=");
  if (p < 0) return '';
  return s.substring(0, p);
}

/// Expression function `CODE(s)`: Parses the "code" portion of a formatted field. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnCODE(dynamic value) {
  final s = varToStr(value);
  final p = s.indexOf("=");
  if (p < 0) return '';
  return s.substring(p + 1);
}

/// Expression function `value`: (optional).
dynamic fnVALUE(dynamic value) {
  final s = varToStr(value);
  final p = s.indexOf("=");
  if (p < 0) return s;
  return s.substring(p + 1);
}

/// Expression function `count`: (opt.).
dynamic fnCOUNT(List<dynamic> values) => values.length;

/// Expression function `high(arr)`: Returns the array's upper-bound index.
dynamic fnHigh(dynamic value) {
  if (value is List) return value.length - 1;
  return 0;
}

/// Expression function `low(arr)`: Returns the array's lower-bound index.
dynamic fnLow(dynamic value) {
  if (value is List) return 0;
  return 0;
}

/// Expression function `ARRAY(s)`: Splits a string on whitespace, composing a display string resembling an array literal (description corrected to match the actual source behavior, verified via testing).
dynamic fnARRAY(dynamic value) {
  final s = varToStr(value);
  final parts = s.split(" ").where((p) => p.isNotEmpty).toList();
  return '[${parts.map((p) => "'$p'").join(',')}]';
}

/// Expression function `CELL(x1, x2)`: Crosstab cell value (for compatibility).
dynamic fnCELL(dynamic v1, dynamic v2) {
  final c = varToInt(v1);
  final r = varToInt(v2);
  return c > r ? c : r;
}

/// Expression function `LIKE(s,pat)`: Wildcard pattern matching. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnLIKE(dynamic v1, dynamic v2) {
  if (v1 == null || v2 == null) return '';
  final s1 = varToStr(v1);
  final s2 = varToStr(v2);
  String best = '';
  for (var i = 0; i < s1.length; i++) {
    for (var j = 0; j < s2.length; j++) {
      if (s1[i] == s2[j]) {
        var k = 0;
        while (
            i + k < s1.length && j + k < s2.length && s1[i + k] == s2[j + k]) {
          k++;
        }
        if (k > best.length) {
          best = s2.substring(j, j + k);
        }
      }
    }
  }
  return best;
}

dynamic fnINCVal(dynamic v1, dynamic v2) => varToDouble(v1) + varToDouble(v2);
dynamic fnDECVal(dynamic v1, dynamic v2) => varToDouble(v1) - varToDouble(v2);

/// Expression function `CompareStr(a,b)`: String comparison (case-sensitive).
dynamic fnCompareStr(dynamic v1, dynamic v2) =>
    varToStr(v1).compareTo(varToStr(v2));

/// Expression function `CompareText(a,b)`: Locale-aware string comparison.
dynamic fnCompareText(dynamic v1, dynamic v2) =>
    varToStr(v1).toLowerCase().compareTo(varToStr(v2).toLowerCase());

/// Expression function `AnsiCompareStr(a,b)`: ANSI case-sensitive comparison.
dynamic fnAnsiCompareStr(dynamic v1, dynamic v2) =>
    varToStr(v1).compareTo(varToStr(v2));

/// Expression function `AnsiCompareText(a,b)`: ANSI case-insensitive comparison.
dynamic fnAnsiCompareText(dynamic v1, dynamic v2) =>
    varToStr(v1).toLowerCase().compareTo(varToStr(v2).toLowerCase());

/// Expression function `AnsiLowerCase(s)`: ANSI convert to lowercase.
dynamic fnAnsiLowerCase(dynamic value) => varToStr(value).toLowerCase();

/// Expression function `AnsiUpperCase(s)`: ANSI convert to uppercase.
dynamic fnAnsiUpperCase(dynamic value) => varToStr(value).toUpperCase();

/// Expression function `LEADBYTE(s,p)`: Determines whether it's the lead byte of a double-byte character. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnLeadByte(dynamic v1, dynamic v2) =>
    false; // Flutter uses UTF-16, no LeadBytes concept

/// Expression function `IMG(name,size)`: Image path handling. The Dart result differs from the Windows engine; see the manual, Appendix C.3.
dynamic fnImg(dynamic v1, dynamic v2) => varToStr(v1); // simplified version

int _lastPathSep(String s) {
  final a = s.lastIndexOf("/");
  final b = s.lastIndexOf("\\");
  return a > b ? a : b;
}

/// Expression function `ExtractFilePath(s)`: Gets the full path.
dynamic fnExtractFilePath(dynamic value) {
  final s = varToStr(value);
  final i = _lastPathSep(s);
  return i < 0 ? '' : s.substring(0, i + 1);
}

/// Expression function `ExtractFileDir(s)`: Gets the directory path.
dynamic fnExtractFileDir(dynamic value) {
  final s = varToStr(value);
  final i = _lastPathSep(s);
  return i < 0 ? '' : s.substring(0, i);
}

/// Expression function `ExtractFileDrive(s)`: Gets the drive letter.
dynamic fnExtractFileDrive(dynamic value) {
  final s = varToStr(value);
  final i = s.indexOf(":");
  return i < 0 ? '' : s.substring(0, i + 1);
}

/// Expression function `ExtractFileName(s)`: Gets the file name (including extension).
dynamic fnExtractFileName(dynamic value) {
  final s = varToStr(value);
  final i = _lastPathSep(s);
  return i < 0 ? s : s.substring(i + 1);
}

/// Expression function `ExtractFileNameNoExt(s)`: Gets the file name (without extension).
dynamic fnExtractFileNameNoExt(dynamic value) {
  final name = varToStr(fnExtractFileName(value));
  final dot = name.lastIndexOf(".");
  return dot < 0 ? name : name.substring(0, dot);
}

/// Expression function `ExtractFileExt(s)`: Gets the file extension.
dynamic fnExtractFileExt(dynamic value) {
  final s = varToStr(value);
  final dot = s.lastIndexOf(".");
  return dot < 0 ? '' : s.substring(dot);
}

// ══ Extended functions ══
// ============================================================
// myexp.pas → Flutter/Dart converted version
// Extended function library V1.3~V1.6
// ============================================================

// ──────────────────────────────────────────────────────────────
// String — advanced processing
// ──────────────────────────────────────────────────────────────

/// PADL(str, len): left-pads with spaces to width len
dynamic extPADL(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final n = varToInt(v2);
  return s.length < n ? s.padLeft(n) : s;
}

/// PADR(str, len): right-pads with spaces to width len
dynamic extPADR(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final n = varToInt(v2);
  return s.length < n ? s.padRight(n) : s;
}

/// PADC(str, len): center-pads with spaces to width len
dynamic extPADC(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final n = varToInt(v2);
  if (s.length >= n) return s;
  final leftPad = (n - s.length) ~/ 2;
  final rightPad = n - s.length - leftPad;
  return ' ' * leftPad + s + ' ' * rightPad;
}

/// LPAD(str, len, ch): left-pads with the given character to width len
dynamic extLPAD(dynamic v1, dynamic v2, dynamic v3) {
  var s = varToStr(v1);
  final n = varToInt(v2);
  var ch = varToStr(v3);
  if (ch.isEmpty) ch = ' ';
  while (s.length < n) {
    s = ch[0] + s;
  }
  return s.substring(s.length - n);
}

/// RPAD(str, len, ch): right-pads with the given character to width len
dynamic extRPAD(dynamic v1, dynamic v2, dynamic v3) {
  var s = varToStr(v1);
  final n = varToInt(v2);
  var ch = varToStr(v3);
  if (ch.isEmpty) ch = ' ';
  while (s.length < n) {
    s = s + ch[0];
  }
  return s.substring(0, n);
}

/// REPEAT(str, n): repeats the string n times
dynamic extREPEAT(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final n = varToInt(v2);
  return s * n;
}

/// COUNTSTR(substr, str): counts occurrences of a substring
dynamic extCOUNTSTR(dynamic v1, dynamic v2) {
  final sub = varToStr(v1);
  var s = varToStr(v2);
  if (sub.isEmpty) return 0;
  int count = 0;
  int p = s.indexOf(sub);
  while (p >= 0) {
    count++;
    s = s.substring(p + sub.length);
    p = s.indexOf(sub);
  }
  return count;
}

/// STARTSWITH(str, prefix): whether the string starts with prefix
dynamic extSTARTSWITH(dynamic v1, dynamic v2) =>
    varToStr(v1).startsWith(varToStr(v2));

/// ENDSWITH(str, suffix): whether the string ends with suffix
dynamic extENDSWITH(dynamic v1, dynamic v2) =>
    varToStr(v1).endsWith(varToStr(v2));

/// CONTAINS(str, substr): whether the string contains the substring
dynamic extCONTAINS(dynamic v1, dynamic v2) =>
    varToStr(v1).contains(varToStr(v2));

/// WRAP(str, width): inserts a line break (CRLF) every width characters
dynamic extWRAP(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  var w = varToInt(v2);
  if (w <= 0) w = 80;
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i += w) {
    if (i > 0) buf.write("\r\n");
    buf.write(s.substring(i, (i + w).clamp(0, s.length)));
  }
  return buf.toString();
}

// ──────────────────────────────────────────────────────────────
// String — numeric formatting
// ──────────────────────────────────────────────────────────────

/// ZFILL(n, width): zero-pads an integer to width digits
dynamic extZFILL(dynamic v1, dynamic v2) {
  final n = varToInt(v1);
  final w = varToInt(v2);
  final neg = n < 0;
  final s = n.abs().toString().padLeft(w, "0");
  return neg ? '-$s' : s;
}

/// NUMFMT(value, decimals): numeric formatting, thousands separator + decimal places
dynamic extNUMFMT(dynamic v1, dynamic v2) {
  final val = varToDouble(v1);
  final d = varToInt(v2);
  final fixed = val.toStringAsFixed(d < 0 ? 0 : d);
  final parts = fixed.split(".");
  final intPart = _commaStr(parts[0]);
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}

String _commaStr(String s) {
  final neg = s.startsWith("-");
  final digits = neg ? s.substring(1) : s;
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(",");
    buf.write(digits[i]);
  }
  return (neg ? '-' : "") + buf.toString();
}

/// COMMAFMT(value): adds thousands separators to a number (integer)
dynamic extCOMMAFMT(dynamic value) =>
    _commaStr(varToDouble(value).truncate().toString());

// ──────────────────────────────────────────────────────────────
// Math — advanced operations
// ──────────────────────────────────────────────────────────────

/// GCD(a, b): greatest common divisor
dynamic extGCD(dynamic v1, dynamic v2) {
  var a = varToInt(v1).abs();
  var b = varToInt(v2).abs();
  while (b != 0) {
    final t = b;
    b = a % b;
    a = t;
  }
  return a;
}

/// LCM(a, b): least common multiple
dynamic extLCM(dynamic v1, dynamic v2) {
  final a = varToInt(v1).abs();
  final b = varToInt(v2).abs();
  if (a == 0 || b == 0) return 0;
  var x = a, y = b;
  while (y != 0) {
    final t = y;
    y = x % y;
    x = t;
  }
  final g = x;
  return a ~/ g * b;
}

/// CLAMP(value, lo, hi): clamps a value to the [lo, hi] range
dynamic extCLAMP(dynamic v1, dynamic v2, dynamic v3) {
  final val = varToDouble(v1);
  final lo = varToDouble(v2);
  final hi = varToDouble(v3);
  if (val < lo) return lo;
  if (val > hi) return hi;
  return val;
}

/// LERP(a, b, t): linear interpolation a + (b-a)*t
dynamic extLERP(dynamic v1, dynamic v2, dynamic v3) {
  final a = varToDouble(v1);
  final b = varToDouble(v2);
  final t = varToDouble(v3);
  return a + (b - a) * t;
}

/// BETWEEN(value, lo, hi): whether a value is within the [lo, hi] range
dynamic extBETWEEN(dynamic v1, dynamic v2, dynamic v3) {
  final val = varToDouble(v1);
  final lo = varToDouble(v2);
  final hi = varToDouble(v3);
  return val >= lo && val <= hi;
}

/// PERCENT(part, total): percentage calculation
dynamic extPERCENT(dynamic v1, dynamic v2) {
  final part = varToDouble(v1);
  final total = varToDouble(v2);
  if (total == 0) return 0.0;
  return part / total * 100.0;
}

/// ROUNDBANK(value, decimals): banker's rounding (round half to even)
dynamic extROUNDBANK(dynamic v1, dynamic v2) {
  final val = varToDouble(v1);
  final d = varToInt(v2);
  final factor = pow(10, d).toDouble();
  final scaled = val * factor;
  final frac = scaled - scaled.truncateToDouble();
  final intPart = scaled.truncate();
  if ((frac - 0.5).abs() < 1e-10) {
    // exactly 0.5: round to even
    if (intPart.isOdd) {
      return (intPart + 1) / factor;
    } else {
      return intPart / factor;
    }
  }
  return (scaled + 0.5).truncateToDouble() / factor;
}

// ──────────────────────────────────────────────────────────────
// Date — advanced operations
// ──────────────────────────────────────────────────────────────

DateTime? _vToDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

/// DATEADD(date, n, unit): adds/subtracts from a date; unit='D'/'M'/'Y'/'W'
dynamic extDATEADD(dynamic v1, dynamic v2, dynamic v3) {
  final d = _vToDateTime(v1);
  if (d == null) return null;
  final n = varToInt(v2);
  var u = varToStr(v3).trim().toUpperCase();
  if (u.isEmpty) u = 'D';
  switch (u[0]) {
    case 'D':
      return d.add(Duration(days: n));
    case 'W':
      return d.add(Duration(days: n * 7));
    case 'M':
      return DateTime(d.year, d.month + n, d.day, d.hour, d.minute, d.second);
    case 'Y':
      return DateTime(d.year + n, d.month, d.day, d.hour, d.minute, d.second);
    default:
      return d.add(Duration(days: n));
  }
}

/// DATEDIFF(date1, date2, unit): date difference
dynamic extDATEDIFF(dynamic v1, dynamic v2, dynamic v3) {
  final d1 = _vToDateTime(v1);
  final d2 = _vToDateTime(v2);
  if (d1 == null || d2 == null) return 0;
  var u = varToStr(v3).trim().toUpperCase();
  if (u.isEmpty) u = 'D';
  switch (u[0]) {
    case 'D':
      return d2.difference(d1).inDays;
    case 'W':
      return d2.difference(d1).inDays ~/ 7;
    case 'M':
      return (d2.year - d1.year) * 12 + (d2.month - d1.month);
    case 'Y':
      return d2.year - d1.year;
    default:
      return d2.difference(d1).inDays;
  }
}

/// DATESTART(date, unit): start of a period; unit='M'=start of month/'Y'=start of year/'W'=Monday
dynamic extDATESTART(dynamic v1, dynamic v2) {
  final d = _vToDateTime(v1);
  if (d == null) return null;
  var u = varToStr(v2).trim().toUpperCase();
  if (u.isEmpty) u = 'M';
  switch (u[0]) {
    case 'M':
      return DateTime(d.year, d.month, 1);
    case 'Y':
      return DateTime(d.year, 1, 1);
    case 'W':
      // go back to Monday of this week
      final diff = d.weekday - 1; // Mon=1
      return d.subtract(Duration(days: diff));
    default:
      return d;
  }
}

/// DATEEND(date, unit): end of a period; unit='M'=end of month/'Y'=end of year
dynamic extDATEEND(dynamic v1, dynamic v2) {
  final d = _vToDateTime(v1);
  if (d == null) return null;
  var u = varToStr(v2).trim().toUpperCase();
  if (u.isEmpty) u = 'M';
  switch (u[0]) {
    case 'M':
      return DateTime(d.year, d.month + 1, 0);
    case 'Y':
      return DateTime(d.year, 12, 31);
    default:
      return d;
  }
}

/// WORKDAYS(date1, date2): counts working days (excludes Sat/Sun)
dynamic extWORKDAYS(dynamic v1, dynamic v2) {
  final d1 = _vToDateTime(v1);
  final d2 = _vToDateTime(v2);
  if (d1 == null || d2 == null) return 0;
  int count = 0;
  DateTime cur = DateTime(d1.year, d1.month, d1.day);
  final end = DateTime(d2.year, d2.month, d2.day);
  while (!cur.isAfter(end)) {
    if (cur.weekday <= 5) count++; // Mon=1..Fri=5
    cur = cur.add(const Duration(days: 1));
  }
  return count;
}

/// QUARTER(date): gets the quarter (1~4)
dynamic extQUARTER(dynamic value) {
  final dt = _vToDateTime(value);
  if (dt == null) return 0;
  return (dt.month - 1) ~/ 3 + 1;
}

/// RDATE(date): ROC-calendar-year date string YYY/MM/DD
dynamic extRDATE(dynamic value) {
  final dt = _vToDateTime(value);
  if (dt == null) return '';
  return '${(dt.year - 1911).toString().padLeft(3, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
}

/// RDATETIME(date): ROC-calendar-year date-time string YYY/MM/DD HH:MM:SS
dynamic extRDATETIME(dynamic value) {
  final dt = _vToDateTime(value);
  if (dt == null) return '';
  return '${(dt.year - 1911).toString().padLeft(3, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
}

// ──────────────────────────────────────────────────────────────
// Type checking / safe conversion
// ──────────────────────────────────────────────────────────────

/// NVL(value, default): returns default if value is Null
dynamic extNVL(dynamic v1, dynamic v2) => v1 ?? v2;

/// NVL2(value, notNullVal, nullVal)：Oracle NVL2
dynamic extNVL2(dynamic v1, dynamic v2, dynamic v3) => v1 != null ? v2 : v3;

/// COALESCE: returns the first non-Null value (variadic)
dynamic extCOALESCE(List<dynamic> values) {
  for (final v in values) {
    if (v != null) return v;
  }
  return null;
}

/// TOINT: safely converts to integer
dynamic extTOINT(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(varToStr(value)) ?? 0;
}

/// TOFLOAT: safely converts to float
dynamic extTOFLOAT(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(varToStr(value)) ?? 0.0;
}

/// TODATE: safely converts to date
dynamic extTODATE(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(varToStr(value));
}

/// TYPENAME: the type's name
dynamic extTYPENAME(dynamic value) {
  if (value == null) return 'null';
  if (value is bool) return 'Boolean';
  if (value is int) return 'Integer';
  if (value is double) return 'Float';
  if (value is String) return 'String';
  if (value is DateTime) return 'DateTime';
  if (value is List) return 'Array';
  return value.runtimeType.toString();
}

// ──────────────────────────────────────────────────────────────
// Logic / control flow
// ──────────────────────────────────────────────────────────────

/// SWITCH(val, case1, result1, case2, result2, ..., defaultVal)
dynamic extSWITCH(List<dynamic> values) {
  if (values.isEmpty) return null;
  final val = values[0];
  for (var i = 1; i + 1 < values.length; i += 2) {
    if (varToStr(values[i]) == varToStr(val)) return values[i + 1];
  }
  // if the argument count is even, the last one is the default
  if (values.length.isEven) return values.last;
  return null;
}

/// DECODE(val, case1, result1, ..., default)：Oracle DECODE
dynamic extDECODE(List<dynamic> values) => extSWITCH(values);

// ──────────────────────────────────────────────────────────────
// String, advanced (V1.4)
// ──────────────────────────────────────────────────────────────

/// SPLIT(str, delim, n): splits and takes the nth token (1-based)
dynamic extSPLIT(dynamic v1, dynamic v2, dynamic v3) {
  final s = varToStr(v1);
  final delim = varToStr(v2);
  final n = varToInt(v3) - 1; // 0-based
  if (delim.isEmpty) return s;
  final parts = s.split(delim);
  if (n < 0 || n >= parts.length) return '';
  return parts[n];
}

/// SPLITCOUNT(str, delim): number of tokens after splitting
dynamic extSPLITCOUNT(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final delim = varToStr(v2);
  if (delim.isEmpty) return 1;
  return s.split(delim).length;
}

/// JOIN(values, delim): merges after cleaning up extra whitespace
dynamic extJOIN(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final delim = varToStr(v2);
  final parts = s.split(RegExp(r"\s+")).where((p) => p.isNotEmpty).toList();
  return parts.join(delim);
}

/// TOKENAT(str, delims, n): takes a token using multi-character delimiters (1-based)
dynamic extTOKENAT(dynamic v1, dynamic v2, dynamic v3) {
  final s = varToStr(v1);
  final delims = varToStr(v2);
  final n = varToInt(v3) - 1;
  if (delims.isEmpty) return s;
  final parts = s.split(RegExp("[${RegExp.escape(delims)}]"));
  if (n < 0 || n >= parts.length) return '';
  return parts[n];
}

/// ELLIPSIS(str, maxLen): truncates and adds '...'
dynamic extELLIPSIS(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final maxLen = varToInt(v2);
  if (s.length <= maxLen) return s;
  return '${s.substring(0, (maxLen - 3).clamp(0, s.length))}...';
}

/// CAPWORDS(str): capitalizes the first letter of each word
dynamic extCAPWORDS(dynamic value) {
  final s = varToStr(value);
  return s
      .split(" ")
      .map((w) =>
          w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(" ");
}

/// CHARAT(str, n): gets the nth character (1-based)
dynamic extCHARAT(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final n = varToInt(v2) - 1;
  if (n < 0 || n >= s.length) return '';
  return s[n];
}

/// INDEXOF(str, sub, start): finds a substring starting from `start` (1-based)
dynamic extINDEXOF(dynamic v1, dynamic v2, dynamic v3) {
  final s = varToStr(v1);
  final sub = varToStr(v2);
  final start = (varToInt(v3) - 1).clamp(0, s.length);
  final i = s.indexOf(sub, start);
  return i < 0 ? 0 : i + 1;
}

/// LASTINDEXOF(str, sub): finds a substring searching from the right (1-based)
dynamic extLASTINDEXOF(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final sub = varToStr(v2);
  final i = s.lastIndexOf(sub);
  return i < 0 ? 0 : i + 1;
}

/// REMOVECHARS(str, chars): removes the given set of characters
dynamic extREMOVECHARS(dynamic v1, dynamic v2) {
  final chars = varToStr(v2);
  return varToStr(v1).split("").where((c) => !chars.contains(c)).join();
}

/// KEEPCHARS(str, chars): keeps only the given set of characters
dynamic extKEEPCHARS(dynamic v1, dynamic v2) {
  final chars = varToStr(v2);
  return varToStr(v1).split("").where((c) => chars.contains(c)).join();
}

/// ONLYDIGITS(str): keeps only digits
dynamic extONLYDIGITS(dynamic value) =>
    varToStr(value).split("").where((c) => RegExp(r"\d").hasMatch(c)).join();

/// ONLYALPHA(str): keeps only English letters
dynamic extONLYALPHA(dynamic value) => varToStr(value)
    .split("")
    .where((c) => RegExp(r"[A-Za-z]").hasMatch(c))
    .join();

/// MASK(str, mask, placeholder): mask formatting (placeholder defaults to '#')
dynamic extMASK(dynamic v1, dynamic v2, dynamic v3) {
  final src = varToStr(v1).replaceAll(RegExp(r"\D"), "");
  final mask = varToStr(v2);
  final phStr = varToStr(v3);
  final ph = phStr.isNotEmpty ? phStr[0] : '#';
  var si = 0;
  final buf = StringBuffer();
  for (final c in mask.split("")) {
    if (c == ph) {
      buf.write(si < src.length ? src[si++] : '_');
    } else {
      buf.write(c);
    }
  }
  return buf.toString();
}

/// UNMASK(str, mask, placeholder): removes the mask, keeping only the characters at placeholder positions (placeholder defaults to '#')
dynamic extUNMASK(dynamic v1, dynamic v2, dynamic v3) {
  final s = varToStr(v1);
  final mask = varToStr(v2);
  final phStr = varToStr(v3);
  final ph = phStr.isNotEmpty ? phStr[0] : '#';
  final buf = StringBuffer();
  for (var i = 0; i < mask.length && i < s.length; i++) {
    if (mask[i] == ph) buf.write(s[i]);
  }
  return buf.toString();
}

/// SLUGIFY(str): converts to a URL slug
dynamic extSLUGIFY(dynamic value) {
  return varToStr(value)
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r"[^a-z0-9\s-]"), "")
      .replaceAll(RegExp(r"\s+"), "-")
      .replaceAll(RegExp(r"-+"), "-");
}

/// TRUNCWORDS(str, n): truncates to the first n words
dynamic extTRUNCWORDS(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final n = varToInt(v2);
  final words = s.split(RegExp(r"\s+"));
  if (words.length <= n) return s;
  return '${words.take(n).join(" ")}...';
}

/// CRLF2BR(str): newline → <br/>
dynamic extCRLF2BR(dynamic value) =>
    varToStr(value).replaceAll("\r\n", "<br/>").replaceAll("\n", "<br/>");

/// BR2CRLF(str): <br/> → newline
dynamic extBR2CRLF(dynamic value) => varToStr(value)
    .replaceAll(RegExp(r"<br\s*/?>", caseSensitive: false), "\r\n");

/// HTMLENCODE(str): HTML special-character encoding
dynamic extHTMLENCODE(dynamic value) {
  return varToStr(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;");
}

/// HTMLDECODE(str): HTML special-character decoding
dynamic extHTMLDECODE(dynamic value) {
  return varToStr(value)
      .replaceAll("&amp;", "&")
      .replaceAll("&lt;", "<")
      .replaceAll("&gt;", ">")
      .replaceAll("&quot;", '"')
      .replaceAll("&#39;", "'")
      .replaceAll("&#160;", "\u00A0");
}

/// URLENCODE(str): URL percent-encoding
dynamic extURLENCODE(dynamic value) {
  return Uri.encodeComponent(varToStr(value));
}

// ──────────────────────────────────────────────────────────────
// Math, advanced
// ──────────────────────────────────────────────────────────────

/// ISPRIME(n): whether n is prime
dynamic extISPRIME(dynamic value) {
  final n = varToInt(value);
  if (n < 2) return false;
  if (n == 2) return true;
  if (n % 2 == 0) return false;
  for (var i = 3; i * i <= n; i += 2) {
    if (n % i == 0) return false;
  }
  return true;
}

/// FIB(n): the nth Fibonacci number (0-based)
dynamic extFIB(dynamic value) {
  final n = varToInt(value);
  if (n < 0) return 0;
  if (n == 0) return 0;
  int a = 0, b = 1;
  for (var i = 2; i <= n; i++) {
    final c = a + b;
    a = b;
    b = c;
  }
  return b;
}

/// LOG2(x): base-2 logarithm
dynamic extLOG2(dynamic value) {
  final x = varToDouble(value);
  if (x <= 0) return 0.0;
  return log(x) / log(2);
}

/// LOGN(base, x): logarithm base `base`
dynamic extLOGN(dynamic v1, dynamic v2) {
  final base = varToDouble(v1);
  final x = varToDouble(v2);
  if (base <= 0 || base == 1 || x <= 0) return 0.0;
  return log(x) / log(base);
}

/// HYPOT(a, b): hypotenuse of a right triangle, sqrt(a²+b²)
dynamic extHYPOT(dynamic v1, dynamic v2) {
  final a = varToDouble(v1);
  final b = varToDouble(v2);
  return sqrt(a * a + b * b);
}

/// DEG2RAD(deg): degrees → radians
dynamic extDEG2RAD(dynamic value) => varToDouble(value) * pi / 180.0;

/// RAD2DEG(rad): radians → degrees
dynamic extRAD2DEG(dynamic value) => varToDouble(value) * 180.0 / pi;

/// CBRT(x): cube root
dynamic extCBRT(dynamic value) {
  final x = varToDouble(value);
  return x >= 0 ? pow(x, 1 / 3) : -pow(-x, 1 / 3);
}

/// EVEN(n): the smallest even number ≥ n
dynamic extEVEN(dynamic value) {
  final n = varToInt(value);
  return n.isOdd ? n + 1 : n;
}

/// ODD(n): the smallest odd number ≥ n
dynamic extODD(dynamic value) {
  final n = varToInt(value);
  return n.isEven ? n + 1 : n;
}

/// SUMSQ(values): sum of squares Σ(xᵢ²)
dynamic extSUMSQ(List<dynamic> values) {
  double s = 0;
  for (final v in values) {
    final x = varToDouble(v);
    s += x * x;
  }
  return s;
}

/// PRODUCT(values): product of the values Π(xᵢ)
dynamic extPRODUCT(List<dynamic> values) {
  double p = 1;
  for (final v in values) {
    p *= varToDouble(v);
  }
  return p;
}

/// HARMEAN(values): harmonic mean
dynamic extHARMEAN(List<dynamic> values) {
  final n = values.length;
  if (n == 0) return 0.0;
  double s = 0;
  for (final v in values) {
    final x = varToDouble(v);
    if (x == 0) return 0.0;
    s += 1.0 / x;
  }
  return n / s;
}

/// GEOMEAN(values): geometric mean
dynamic extGEOMEAN(List<dynamic> values) {
  final n = values.length;
  if (n == 0) return 0.0;
  double logSum = 0;
  for (final v in values) {
    final x = varToDouble(v);
    if (x <= 0) return 0.0;
    logSum += log(x);
  }
  final r = exp(logSum / n);
  // @@@ a log/exp round trip produces tiny floating-point noise (e.g.
  //     (1*3*9)^(1/3) is theoretically exactly 3, but actually computes
  //     to 3.0000000000000004) -- rounded to 12 decimal places to clear
  //     the noise. The log/exp algorithm itself is kept (rather than
  //     switching to direct multiply-then-root) because with many input
  //     values at large magnitudes, direct multiplication can overflow;
  //     log/exp is more numerically robust.
  return double.parse(r.toStringAsFixed(12));
}

/// QUARTILE(values, q): quartile; q=1 Q1, q=2 median, q=3 Q3
dynamic extQUARTILE(List<dynamic> values) {
  final n = values.length;
  if (n < 2) return 0.0;
  final q = varToInt(values.last);
  final data = values.sublist(0, n - 1).map(varToDouble).toList()..sort();
  final pos = q * (data.length - 1) / 4.0;
  final lo = pos.floor();
  final hi = lo + 1;
  if (hi >= data.length) return data.last;
  return data[lo] + (pos - lo) * (data[hi] - data[lo]);
}

/// NPV(rate, values): net present value
dynamic extNPV(List<dynamic> values) {
  if (values.length < 2) return 0.0;
  final rate = varToDouble(values[0]);
  double npv = 0;
  for (var i = 1; i < values.length; i++) {
    npv += varToDouble(values[i]) / pow(1 + rate, i);
  }
  return npv;
}

/// IRR(values, guess): internal rate of return (Newton-Raphson iteration)
dynamic extIRR(List<dynamic> values) {
  final n = values.length;
  if (n < 2) return 0.0;
  var rate = varToDouble(values.last); // guess
  final cashFlows = values.sublist(0, n - 1).map(varToDouble).toList();
  for (var iter = 0; iter < 100; iter++) {
    double npv = 0, dnpv = 0;
    for (var i = 0; i < cashFlows.length; i++) {
      final v = cashFlows[i];
      npv += v / pow(1 + rate, i);
      if (i > 0) dnpv -= i * v / pow(1 + rate, i + 1);
    }
    if (dnpv.abs() < 1e-10) break;
    rate -= npv / dnpv;
    if (npv.abs() < 1e-8) break;
  }
  return rate;
}

// ──────────────────────────────────────────────────────────────
// Date, advanced
// ──────────────────────────────────────────────────────────────

/// ISWEEKEND(date): whether it's Saturday or Sunday
dynamic extISWEEKEND(dynamic value) {
  final dt = _vToDateTime(value);
  if (dt == null) return false;
  return dt.weekday == DateTime.saturday || dt.weekday == DateTime.sunday;
}

/// ISWEEKDAY(date): whether it's a weekday (Monday~Friday)
dynamic extISWEEKDAY(dynamic value) => !extISWEEKEND(value);

/// NEXTWDAY(date, dow): finds the next occurrence of the given weekday from date (dow=1 Mon..7 Sun)
dynamic extNEXTWDAY(dynamic v1, dynamic v2) {
  final d = _vToDateTime(v1);
  if (d == null) return null;
  final target = varToInt(v2);
  var diff = target - d.weekday;
  if (diff <= 0) diff += 7;
  return d.add(Duration(days: diff));
}

/// PREVWDAY(date, dow): finds the previous occurrence of the given weekday before date
dynamic extPREVWDAY(dynamic v1, dynamic v2) {
  final d = _vToDateTime(v1);
  if (d == null) return null;
  final target = varToInt(v2);
  var diff = d.weekday - target;
  if (diff <= 0) diff += 7;
  return d.subtract(Duration(days: diff));
}

/// EOMDATE(year, month): the last day of the given year/month
dynamic extEOMDATE(dynamic v1, dynamic v2) {
  final y = varToInt(v1);
  final m = varToInt(v2);
  return DateTime(y, m + 1, 0);
}

/// BOMDATE(year, month): the first day of the given year/month
dynamic extBOMDATE(dynamic v1, dynamic v2) =>
    DateTime(varToInt(v1), varToInt(v2), 1);

/// ADDWORKDAYS(date, n): adds n working days (skips Sat/Sun)
dynamic extADDWORKDAYS(dynamic v1, dynamic v2) {
  var d = _vToDateTime(v1);
  if (d == null) return null;
  var n = varToInt(v2);
  final step = n >= 0 ? 1 : -1;
  n = n.abs();
  while (n > 0) {
    d = d!.add(Duration(days: step));
    if (d.weekday <= 5) n--;
  }
  return d;
}

/// YEARFRAC(date1, date2): the fraction of a year between two dates (Actual/365)
dynamic extYEARFRAC(dynamic v1, dynamic v2) {
  final d1 = _vToDateTime(v1);
  final d2 = _vToDateTime(v2);
  if (d1 == null || d2 == null) return 0.0;
  return d2.difference(d1).inDays / 365.0;
}

/// AGE(birthdate, asofdate): calculates age in full years from a birthdate
dynamic extAGE(dynamic v1, dynamic v2) {
  final birth = _vToDateTime(v1);
  final asof = _vToDateTime(v2);
  if (birth == null || asof == null) return 0;
  int age = asof.year - birth.year;
  if (asof.month < birth.month ||
      (asof.month == birth.month && asof.day < birth.day)) {
    age--;
  }
  return age;
}

/// FISCALQUARTER(date, fiscalStartMonth): fiscal quarter
dynamic extFISCALQUARTER(dynamic v1, dynamic v2) {
  final dt = _vToDateTime(v1);
  if (dt == null) return 0;
  final startM = varToInt(v2);
  final offset = (dt.month - startM + 12) % 12;
  return offset ~/ 3 + 1;
}

/// FISCALYEAR(date, fiscalStartMonth): fiscal year
dynamic extFISCALYEAR(dynamic v1, dynamic v2) {
  final dt = _vToDateTime(v1);
  if (dt == null) return 0;
  final startM = varToInt(v2);
  var y = dt.year;
  if (dt.month < startM) y--;
  return y;
}

/// DAYNAME(date): weekday name (returned in Chinese — this is a data
/// value used by WML output, not a comment, so it is intentionally left
/// untranslated; translating it would change the function's runtime behavior)
dynamic extDAYNAME(dynamic value) {
  const names = ['週一', "週二", "週三", "週四", "週五", "週六", "週日"];
  final dt = _vToDateTime(value);
  if (dt == null) return '';
  return names[dt.weekday - 1];
}

/// MONTHNAME(date): month name (returned in Chinese — see the note on
/// DAYNAME above)
dynamic extMONTHNAME(dynamic value) {
  const names = [
    '一月',
    "二月",
    "三月",
    "四月",
    "五月",
    "六月",
    "七月",
    "八月",
    "九月",
    "十月",
    "十一月",
    "十二月"
  ];
  final dt = _vToDateTime(value);
  if (dt == null) return '';
  return names[dt.month - 1];
}

/// DATESERIAL(y, m, d): builds a DateTime from year/month/day
dynamic extDATESERIAL(dynamic v1, dynamic v2, dynamic v3) =>
    DateTime(varToInt(v1), varToInt(v2), varToInt(v3));

/// TIMESERIAL(h, m, s): builds a DateTime from hour/minute/second
dynamic extTIMESERIAL(dynamic v1, dynamic v2, dynamic v3) =>
    DateTime(1970, 1, 1, varToInt(v1), varToInt(v2), varToInt(v3));

// ──────────────────────────────────────────────────────────────
// Array / collection
// ──────────────────────────────────────────────────────────────

/// ARRJOIN(values, delim): the last argument is delim
dynamic extARRJOIN(List<dynamic> values) {
  if (values.isEmpty) return '';
  final delim = varToStr(values.last);
  final parts = values.sublist(0, values.length - 1);
  return parts.map(varToStr).join(delim);
}

/// ARRMAX(values): the maximum of several values
dynamic extARRMAX(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  return values.map(varToDouble).reduce((a, b) => a > b ? a : b);
}

/// ARRMIN(values): the minimum of several values
dynamic extARRMIN(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  return values.map(varToDouble).reduce((a, b) => a < b ? a : b);
}

/// ARRSUM(values): the sum of several values
dynamic extARRSUM(List<dynamic> values) =>
    values.fold(0.0, (sum, v) => sum + varToDouble(v));

/// ARRAVG(values): the average of several values
dynamic extARRAVG(List<dynamic> values) {
  final n = values.length;
  if (n == 0) return 0.0;
  return extARRSUM(values) / n;
}

/// ARRCONTAINS(values, target): the last argument is target
dynamic extARRCONTAINS(List<dynamic> values) {
  if (values.length < 2) return false;
  final target = varToStr(values.last);
  return values.sublist(0, values.length - 1).any((v) => varToStr(v) == target);
}

/// ARRUNIQ(values): removes duplicate values, returns joined by commas
dynamic extARRUNIQ(List<dynamic> values) {
  final seen = <String>{};
  final buf = <String>[];
  for (final v in values) {
    final s = varToStr(v);
    if (seen.add(s)) buf.add(s);
  }
  return buf.join(",");
}

/// CHOOSE(index, values): picks a value from the list by (1-based) index
dynamic extCHOOSE(List<dynamic> values) {
  if (values.length < 2) return null;
  final idx = varToInt(values[0]);
  if (idx >= 1 && idx < values.length) return values[idx];
  return null;
}

// ──────────────────────────────────────────────────────────────
// System / misc
// ──────────────────────────────────────────────────────────────

/// GUID: generates a new GUID string
dynamic extGUID() {
  final rng = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0F) | 0x40;
  bytes[8] = (bytes[8] & 0x3F) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, "0")).toList();
  return '${hex.sublist(0, 4).join()}-${hex.sublist(4, 6).join()}-${hex.sublist(6, 8).join()}-${hex.sublist(8, 10).join()}-${hex.sublist(10).join()}';
}

/// RANDOMSTR(len, chars): generates a random string of the given length
dynamic extRANDOMSTR(dynamic v1, dynamic v2) {
  final len = varToInt(v1);
  var chars = varToStr(v2);
  if (chars.isEmpty) {
    chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  }
  final rng = Random();
  return List.generate(len, (_) => chars[rng.nextInt(chars.length)]).join();
}

/// TOHEX(n): converts an integer to a hex string (no padding)
dynamic extTOHEX(dynamic value) =>
    varToInt(value).toRadixString(16).toUpperCase();

/// FROMHEX(str): converts a hex string to an integer
dynamic extFROMHEX(dynamic value) {
  var s = varToStr(value).trim();
  if (s.length >= 2 && s[0] == '0' && s[1].toUpperCase() == 'X') {
    s = s.substring(2);
  }
  return int.tryParse(s, radix: 16) ?? 0;
}

/// TOBIN(n, width): converts an integer to a binary string
dynamic extTOBIN(dynamic v1, dynamic v2) {
  var n = varToInt(v1);
  final w = varToInt(v2);
  if (n == 0) return '0'.padLeft(w, "0");
  var buf = '';
  while (n > 0) {
    buf = '${n & 1}$buf';
    n >>= 1;
  }
  return buf.padLeft(w, "0");
}

/// FROMBIN(str): converts a binary string to an integer
dynamic extFROMBIN(dynamic value) {
  final s = varToStr(value).trim();
  int r = 0;
  for (final c in s.split("")) {
    r = (r << 1) | (c == '1' ? 1 : 0);
  }
  return r;
}

/// BITOR(a, b): bitwise OR
dynamic extBITOR(dynamic v1, dynamic v2) => varToInt(v1) | varToInt(v2);

/// BITAND(a, b): bitwise AND
dynamic extBITAND(dynamic v1, dynamic v2) => varToInt(v1) & varToInt(v2);

/// BITXOR(a, b): bitwise XOR
dynamic extBITXOR(dynamic v1, dynamic v2) => varToInt(v1) ^ varToInt(v2);

/// BITNOT(a): bitwise NOT (uses the pure-arithmetic equivalent -x-1
/// instead of the ~ operator, to guard against possible bitwise-op
/// discrepancies under Web compilation)
dynamic extBITNOT(dynamic value) => -varToInt(value) - 1;

/// BITSHL(a, n): shift left n bits
dynamic extBITSHL(dynamic v1, dynamic v2) => varToInt(v1) << varToInt(v2);

/// BITSHR(a, n): shift right n bits
dynamic extBITSHR(dynamic v1, dynamic v2) => varToInt(v1) >> varToInt(v2);

/// BYTESIZE(n): returns how many bytes are needed to store n bits
dynamic extBYTESIZE(dynamic value) => (varToInt(value) + 7) ~/ 8;

/// HASH(str): a simple djb2 hash (32-bit, returned as a hex string)
dynamic extHASH(dynamic value) {
  final s = varToStr(value);
  int h = 5381;
  for (final c in s.codeUnits) {
    h = ((h << 5) + h + c) & 0xFFFFFFFF;
  }
  return h.toUnsigned(32).toRadixString(16).padLeft(8, "0").toUpperCase();
}

/// CHECKSUM(str): XOR checksum
dynamic extCHECKSUM(dynamic value) {
  final s = varToStr(value);
  int cs = 0;
  for (final c in s.codeUnits) {
    cs ^= c;
  }
  return cs;
}

// ──────────────────────────────────────────────────────────────
// Finance, advanced
// ──────────────────────────────────────────────────────────────

/// PMT(rate, nper, pv): the equal payment amount
dynamic extPMT(dynamic v1, dynamic v2, dynamic v3) {
  final rate = varToDouble(v1);
  final nper = varToInt(v2);
  final pv = varToDouble(v3);
  if (rate == 0) return -pv / nper;
  return -pv * rate / (1 - pow(1 + rate, -nper));
}

/// PV(rate, nper, pmt): present value
dynamic extPV(dynamic v1, dynamic v2, dynamic v3) {
  final rate = varToDouble(v1);
  final nper = varToInt(v2);
  final pmt = varToDouble(v3);
  if (rate == 0) return -pmt * nper;
  return -pmt / rate * (1 - pow(1 + rate, -nper));
}

/// FV(rate, nper, pmt, pv): future value
dynamic extFV(dynamic v1, dynamic v2, dynamic v3, dynamic v4) {
  final rate = varToDouble(v1);
  final nper = varToInt(v2);
  final pmt = varToDouble(v3);
  final pv = varToDouble(v4);
  if (rate == 0) return -(pv + pmt * nper);
  return -(pv * pow(1 + rate, nper) + pmt * (pow(1 + rate, nper) - 1) / rate);
}

/// NPER(rate, pmt, pv): number of payment periods
dynamic extNPER(dynamic v1, dynamic v2, dynamic v3) {
  final rate = varToDouble(v1);
  final pmt = varToDouble(v2);
  final pv = varToDouble(v3);
  if (rate == 0) return -pv / pmt;
  return log(pmt / (pmt + pv * rate)) / log(1 + rate);
}

/// RATE(nper, pmt, pv): interest rate per period (Newton-Raphson approximation)
dynamic extRATE(dynamic v1, dynamic v2, dynamic v3) {
  final nper = varToInt(v1);
  final pmt = varToDouble(v2);
  final pv = varToDouble(v3);
  var rate = 0.1;
  for (var i = 0; i < 100; i++) {
    final f = pv * pow(1 + rate, nper) + pmt * (pow(1 + rate, nper) - 1) / rate;
    final df = pv * nper * pow(1 + rate, nper - 1) +
        pmt *
            (nper * rate * pow(1 + rate, nper - 1) * rate -
                (pow(1 + rate, nper) - 1)) /
            (rate * rate);
    if (df.abs() < 1e-12) break;
    rate -= f / df;
    if (f.abs() < 1e-8) break;
  }
  return rate;
}

/// IPMT(rate, per, nper, pv): interest portion of payment n
dynamic extIPMT(dynamic v1, dynamic v2, dynamic v3, dynamic v4) {
  final rate = varToDouble(v1);
  final per = varToInt(v2);
  final nper = varToInt(v3);
  final pv = varToDouble(v4);
  double balance = pv;
  final pmt = extPMT(rate, nper, pv);
  for (var i = 1; i < per; i++) {
    balance = balance - (pmt - balance * rate);
  }
  return -balance * rate;
}

/// PPMT(rate, per, nper, pv): principal portion of payment n
dynamic extPPMT(dynamic v1, dynamic v2, dynamic v3, dynamic v4) {
  final ipmt = extIPMT(v1, v2, v3, v4);
  final pmt = extPMT(v1, v3, v4);
  return pmt - ipmt;
}

/// CUMIPMT(rate, nper, pv, startPeriod, endPeriod): cumulative interest
dynamic extCUMIPMT(List<dynamic> values) {
  if (values.length < 4) return 0.0;
  final rate = varToDouble(values[0]);
  final nper = varToInt(values[1]);
  final pv = varToDouble(values[2]);
  final start = varToInt(values[3]);
  final end = values.length >= 5 ? varToInt(values[4]) : nper;
  double total = 0;
  for (var i = start; i <= end; i++) {
    total += extIPMT(rate, i, nper, pv);
  }
  return total;
}

// ──────────────────────────────────────────────────────────────
// AsXxx series: type conversion / formatted output
// ──────────────────────────────────────────────────────────────

/// AsString(v)：Variant → String
dynamic extAsString(dynamic value) => varToStr(value);

/// AsInt(v)：Variant → Integer
dynamic extAsInt(dynamic value) => varToInt(value);

/// AsFloat(v)：Variant → Float
dynamic extAsFloat(dynamic value) => varToDouble(value);

/// AsBool(v)：Variant → Boolean
dynamic extAsBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final s = varToStr(value).toLowerCase();
  return s == 'true' || s == '1' || s == 'y' || s == 't';
}

/// AsDate(v): Variant → date (DateTime)
dynamic extAsDate(dynamic value) {
  if (value is DateTime) return DateTime(value.year, value.month, value.day);
  final dt = DateTime.tryParse(varToStr(value));
  if (dt == null) return null;
  return DateTime(dt.year, dt.month, dt.day);
}

/// AsTime(v): Variant → time
dynamic extAsTime(dynamic value) {
  final dt = _vToDateTime(value);
  return dt;
}

/// AsDateTime(v): Variant → date-time
dynamic extAsDateTime(dynamic value) => _vToDateTime(value);

/// AsFixed(v, d): fixed-decimal-place string
dynamic extAsFixed(dynamic v1, dynamic v2) {
  final val = varToDouble(v1);
  final d = varToInt(v2);
  return val.toStringAsFixed(d.clamp(0, 20));
}

/// AsCurr(v, d): thousands-separated currency string
dynamic extAsCurr(dynamic v1, dynamic v2) {
  final val = varToDouble(v1);
  final d = varToInt(v2);
  final fixed = val.toStringAsFixed(d.clamp(0, 20));
  final parts = fixed.split(".");
  final intPart = _commaStr(parts[0]);
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}

/// AsPct(v, d): percentage string
dynamic extAsPct(dynamic v1, dynamic v2) {
  final val = varToDouble(v1) * 100;
  final d = varToInt(v2);
  return '${val.toStringAsFixed(d.clamp(0, 20))}%';
}

/// AsSci(v, d): scientific-notation string, formatted as 1.23E+04 (uppercase E, exponent zero-padded to 2 digits)
dynamic extAsSci(dynamic v1, dynamic v2) {
  final val = varToDouble(v1);
  final d = varToInt(v2);
  final s =
      val.toStringAsExponential(d.clamp(0, 20)); // e.g. "1.23e+4" or "1.23e-4"
  final parts = s.split('e');
  final mantissa = parts[0];
  final expNum = int.parse(parts[1]);
  final sign = expNum < 0 ? '-' : '+';
  final expStr = expNum.abs().toString().padLeft(2, '0');
  return '${mantissa}E$sign$expStr';
}

/// AsYN(v)：Boolean → 'Y'/'N'
dynamic extAsYN(dynamic value) => extAsBool(value) ? 'Y' : "N";

/// AsTF(v)：Boolean → 'T'/'F'
dynamic extAsTF(dynamic value) => extAsBool(value) ? 'T' : "F";

/// As10(v)：Boolean → '1'/'0'
dynamic extAs10(dynamic value) => extAsBool(value) ? '1' : "0";

/// AsBit(v): integer → '1'/'0'
dynamic extAsBit(dynamic value) => varToInt(value) != 0 ? '1' : "0";

/// AsHex(v, width): integer → hexadecimal
dynamic extAsHex(dynamic v1, dynamic v2) {
  final n = varToInt(v1);
  final w = varToInt(v2);
  return n.toRadixString(16).toUpperCase().padLeft(w, "0");
}

/// AsOct(v): integer → octal
dynamic extAsOct(dynamic value) => varToInt(value).toRadixString(8);

/// AsISO(v): ISO 8601 date string
dynamic extAsISO(dynamic value) {
  final dt = _vToDateTime(value);
  if (dt == null) return '';
  // @@@ this used to truncate to 10 characters, keeping only the date and
  //     cutting off the time entirely -- the function's own documentation
  //     specifies the format as 'YYYY-MM-DDTHH:MM:SS' (19 characters),
  //     not a plain date.
  return dt.toIso8601String().substring(0, 19);
}

/// AsRDate(v): ROC-calendar-year date
dynamic extAsRDate(dynamic value) => extRDATE(value);

/// AsRDateTime(v): ROC-calendar-year date-time
dynamic extAsRDateTime(dynamic value) => extRDATETIME(value);

/// AsSlug(v)：URL slug
dynamic extAsSlug(dynamic value) => extSLUGIFY(value);

/// AsUpper(v): all uppercase
dynamic extAsUpper(dynamic value) => varToStr(value).toUpperCase();

/// AsLower(v): all lowercase
dynamic extAsLower(dynamic value) => varToStr(value).toLowerCase();

/// AsTrimmed(v): trims whitespace from both ends
dynamic extAsTrimmed(dynamic value) => varToStr(value).trim();

/// AsQuoted(v): wrapped in single quotes, internal quotes doubled (escaped)
dynamic extAsQuoted(dynamic value) =>
    "'${varToStr(value).replaceAll("'", "''")}'";

/// AsDQuoted(v): wrapped in double quotes, internal quotes backslash-escaped
dynamic extAsDQuoted(dynamic value) =>
    '"${varToStr(value).replaceAll('"', '\\"')}"';

/// AsSQLStr(v): SQL-safe string (inside single quotes, ' becomes '')
dynamic extAsSQLStr(dynamic value) =>
    "'${varToStr(value).replaceAll("'", "''")}'";

/// AsNullable(v): empty→NULL, otherwise quoted
dynamic extAsNullable(dynamic value) {
  final s = varToStr(value);
  if (s.isEmpty || value == null) return 'NULL';
  return "'${s.replaceAll("'", "''")}'";
}

/// AsDefault(v, default): uses the default value when Null
dynamic extAsDefault(dynamic v1, dynamic v2) => v1 ?? v2;

/// AsJson(v): a single value → a plain JSON value
dynamic extAsJson(dynamic value) {
  if (value == null) return 'null';
  if (value is bool) return value.toString();
  if (value is int) return value.toString();
  if (value is double) return value.toString();
  if (value is DateTime) return '"${value.toIso8601String()}"';
  final s = varToStr(value)
      .replaceAll("\\", "\\\\")
      .replaceAll('"', '\\"')
      .replaceAll("\r", "\\r")
      .replaceAll("\n", "\\n")
      .replaceAll("\t", "\\t");
  return '"$s"';
}

/// AsCsv(values): multiple values → a single CSV line
dynamic extAsCsv(List<dynamic> values) {
  final cells = values.map((v) {
    final s = varToStr(v);
    final needQuote = s.contains(",") ||
        s.contains('"') ||
        s.contains("\r") ||
        s.contains("\n");
    if (needQuote) return '"${s.replaceAll('"', '""')}"';
    return s;
  });
  return cells.join(",");
}

// ──────────────────────────────────────────────────────────────
// Added functions: these have no corresponding version among the extended functions -- genuinely missing implementations
// ──────────────────────────────────────────────────────────────

/// ConcatenateStr(values): concatenates multiple strings (no separator)
dynamic fnConcatenateStr(List<dynamic> values) => values.map(varToStr).join();

/// StoredCharLength(str): the effective length after trimming trailing whitespace
dynamic fnStoredCharLength(dynamic value) {
  final s = varToStr(value);
  var end = s.length;
  while (end > 0 && s[end - 1] == ' ') {
    end--;
  }
  return end;
}

/// ReverseStr(str): reverses a string
dynamic fnReverseStr(dynamic value) =>
    String.fromCharCodes(varToStr(value).runes.toList().reversed);

/// SubstituteStr(values): [str, old1, new1, old2, new2, ...] replaces each pair in sequence, case-sensitive
dynamic fnSubstituteStr(List<dynamic> values) {
  if (values.isEmpty) return '';
  var s = varToStr(values[0]);
  for (var i = 1; i + 1 < values.length; i += 2) {
    s = s.replaceAll(varToStr(values[i]), varToStr(values[i + 1]));
  }
  return s;
}

/// SubstituteCaseStr(values): same as SubstituteStr, but case-insensitive matching
dynamic fnSubstituteCaseStr(List<dynamic> values) {
  if (values.isEmpty) return '';
  var s = varToStr(values[0]);
  for (var i = 1; i + 1 < values.length; i += 2) {
    final oldS = varToStr(values[i]);
    final newS = varToStr(values[i + 1]);
    if (oldS.isEmpty) continue;
    final re = RegExp(RegExp.escape(oldS), caseSensitive: false);
    s = s.replaceAll(re, newS);
  }
  return s;
}

/// Factorial(n): factorial n!
dynamic fnFactorial(dynamic value) {
  final n = varToInt(value);
  if (n < 0) return 0;
  var r = 1;
  for (var i = 2; i <= n; i++) {
    r *= i;
  }
  return r;
}

/// EulerNumber: Euler's number e (no arguments)
dynamic fnEulerNumber() => e;

/// SignOf(n): returns -1, 0, or 1
dynamic fnSignOf(dynamic value) {
  final n = varToDouble(value);
  if (n > 0) return 1;
  if (n < 0) return -1;
  return 0;
}

/// Annuity(rate, periods): present-value annuity factor per period (capital recovery factor)
dynamic fnAnnuity(dynamic v1, dynamic v2) {
  final rate = varToDouble(v1);
  final n = varToInt(v2);
  if (rate == 0) return n == 0 ? 0.0 : 1.0 / n;
  return rate / (1 - pow(1 + rate, -n));
}

/// MeanValue(values): arithmetic mean
dynamic fnMeanValue(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  return values.map(varToDouble).reduce((a, b) => a + b) / values.length;
}

/// MedianValue(values): median
dynamic fnMedianValue(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  final nums = values.map(varToDouble).toList()..sort();
  final n = nums.length;
  if (n.isOdd) return nums[n ~/ 2];
  return (nums[n ~/ 2 - 1] + nums[n ~/ 2]) / 2;
}

/// MidRangeValue(values): (max + min) / 2
dynamic fnMidRangeValue(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  final nums = values.map(varToDouble);
  return (nums.reduce((a, b) => a > b ? a : b) +
          nums.reduce((a, b) => a < b ? a : b)) /
      2;
}

/// RangeValue(values): range (max - min)
dynamic fnRangeValue(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  final nums = values.map(varToDouble);
  return nums.reduce((a, b) => a > b ? a : b) -
      nums.reduce((a, b) => a < b ? a : b);
}

/// VarianceValue(values): variance (population, divided by N)
dynamic fnVarianceValue(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  final nums = values.map(varToDouble).toList();
  final mean = nums.reduce((a, b) => a + b) / nums.length;
  final sq = nums.map((x) => (x - mean) * (x - mean));
  return sq.reduce((a, b) => a + b) / nums.length;
}

/// StandardDeviation(values): standard deviation (population)
dynamic fnStandardDeviation(List<dynamic> values) =>
    sqrt(varToDouble(fnVarianceValue(values)));

/// OrdMax(values): the 1-based position of the maximum value in the argument list
dynamic fnOrdMax(List<dynamic> values) {
  if (values.isEmpty) return 0;
  final nums = values.map(varToDouble).toList();
  var idx = 0;
  for (var i = 1; i < nums.length; i++) {
    if (nums[i] > nums[idx]) idx = i;
  }
  return idx + 1;
}

/// OrdMin(values): the 1-based position of the minimum value in the argument list
dynamic fnOrdMin(List<dynamic> values) {
  if (values.isEmpty) return 0;
  final nums = values.map(varToDouble).toList();
  var idx = 0;
  for (var i = 1; i < nums.length; i++) {
    if (nums[i] < nums[idx]) idx = i;
  }
  return idx + 1;
}

/// HighestAlgebraic(n): returns the maximum value representable by the argument's data type (this engine's numeric types can't be reliably distinguished, so it always returns the Int32 upper bound)
dynamic fnHighestAlgebraic(dynamic value) => 2147483647;

/// LowestAlgebraic(n): returns the minimum value representable by the argument's data type (this engine's numeric types can't be reliably distinguished, so it always returns the Int32 lower bound)
dynamic fnLowestAlgebraic(dynamic value) => -2147483648;

/// LOG(n): base-10 logarithm
dynamic fnLog10Value(dynamic value) => log(varToDouble(value)) / log(10);

/// RemainderValue(a, b): floating-point remainder, with the same sign as the dividend
dynamic fnRemainderValue(dynamic v1, dynamic v2) {
  final a = varToDouble(v1);
  final b = varToDouble(v2);
  if (b == 0) return 0.0;
  return a - b * (a / b).truncateToDouble();
}

/// ToIntegerValue(n): the largest integer not exceeding the argument (rounds down)
dynamic fnToIntegerValue(dynamic value) => varToDouble(value).floor();

/// DateToYyyymmdd(yymmdd, pivot): converts a 6-digit date to 8 digits using a pivot year
dynamic fnDateToYyyymmdd(dynamic v1, dynamic v2) {
  final yymmdd = varToInt(v1);
  var pivot = varToInt(v2);
  if (pivot == 0) pivot = 50;
  final yy = yymmdd ~/ 10000;
  final rest = yymmdd % 10000;
  final century = yy <= pivot ? 2000 : 1900;
  return (century + yy) * 10000 + rest;
}

/// YearToYyyy(yy, pivot): converts a 2-digit year to 4 digits using a pivot year
dynamic fnYearToYyyy(dynamic v1, dynamic v2) {
  final yy = varToInt(v1);
  var pivot = varToInt(v2);
  if (pivot == 0) pivot = 50;
  return (yy <= pivot ? 2000 : 1900) + yy;
}

/// TestDateYyyymmdd(yyyymmdd): validates whether it's a legal date; 0=valid, 1=invalid
dynamic fnTestDateYyyymmdd(dynamic value) {
  final n = varToInt(value);
  final y = n ~/ 10000;
  final m = (n ~/ 100) % 100;
  final d = n % 100;
  if (m < 1 || m > 12 || d < 1) return 1;
  try {
    final dt = DateTime(y, m, d);
    return (dt.year == y && dt.month == m && dt.day == d) ? 0 : 1;
  } catch (_) {
    return 1;
  }
}

/// TestDayYyyyddd(yyyyddd): validates whether it's a legal year-day; 0=valid, 1=invalid
dynamic fnTestDayYyyyddd(dynamic value) {
  final n = varToInt(value);
  final y = n ~/ 1000;
  final d = n % 1000;
  if (y < 1601 || d < 1) return 1;
  final isLeap = (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;
  final maxDay = isLeap ? 366 : 365;
  return d <= maxDay ? 0 : 1;
}

/// StandardCompare(a, b): ordinal string comparison, returns '<'/'='/'>'
dynamic fnStandardCompare(dynamic v1, dynamic v2) {
  final c = varToStr(v1).compareTo(varToStr(v2));
  return c < 0 ? '<' : (c > 0 ? '>' : '=');
}

/// Ord(v): converts a character to its ordinal value; returns as-is if already an integer
dynamic fnOrd(dynamic value) {
  if (value is String && value.length == 1) return value.codeUnitAt(0);
  return varToInt(value);
}

/// AsSqlStr(v): escapes single quotes (doesn't add the surrounding quotes)
dynamic fnAsSqlStr(dynamic value) => varToStr(value).replaceAll("'", "''");

/// ByteLength(str): the string's UTF-8 byte length
dynamic fnByteLength(dynamic value) => utf8.encode(varToStr(value)).length;

// ──────────────────────────────────────────────────────────────
// A few extended functions return a raw DateTime, but the WML tests
// expect a Delphi numeric serial -- wrapped with a conversion layer
// without touching the original extended functions (to avoid affecting other call sites).
// ──────────────────────────────────────────────────────────────

dynamic fnBomDateSerial(dynamic v1, dynamic v2) {
  final dt = extBOMDATE(v1, v2) as DateTime;
  return _toDelphiSerial(dt);
}

dynamic fnEomDateSerial(dynamic v1, dynamic v2) {
  final dt = extEOMDATE(v1, v2) as DateTime;
  return _toDelphiSerial(dt);
}

dynamic fnDateAddValueSerial(dynamic v1, dynamic v2, dynamic v3) {
  final dt = extDATEADD(v1, v2, v3) as DateTime?;
  if (dt == null) return null;
  return _toDelphiSerial(dt);
}

dynamic fnDatePeriodEndSerial(dynamic v1, dynamic v2) {
  final dt = extDATEEND(v1, v2) as DateTime?;
  if (dt == null) return null;
  return _toDelphiSerial(dt);
}

dynamic fnDatePeriodStartSerial(dynamic v1, dynamic v2) {
  final dt = extDATESTART(v1, v2) as DateTime?;
  if (dt == null) return null;
  return _toDelphiSerial(dt);
}

dynamic fnNextWeekDaySerial(dynamic v1, dynamic v2) {
  final dt = extNEXTWDAY(v1, v2) as DateTime?;
  if (dt == null) return null;
  return _toDelphiSerial(dt);
}

dynamic fnPrevWeekDaySerial(dynamic v1, dynamic v2) {
  final dt = extPREVWDAY(v1, v2) as DateTime?;
  if (dt == null) return null;
  return _toDelphiSerial(dt);
}

dynamic fnAddWorkDaysSerial(dynamic v1, dynamic v2) {
  final dt = extADDWORKDAYS(v1, v2) as DateTime?;
  if (dt == null) return null;
  return _toDelphiSerial(dt);
}

// ──────────────────────────────────────────────────────────────
// COBOL internal date integer = Delphi date serial + 109205
// ──────────────────────────────────────────────────────────────
const int _kCobolDateOffset = 109205;

/// CombinedDateTime(dateInt, seconds): combines a COBOL internal date integer and seconds into a serial
dynamic fnCombinedDateTime(dynamic v1, dynamic v2) =>
    varToInt(v1) * 86400 + varToInt(v2);

/// DateOfInteger(cobolInt): converts a COBOL internal date integer to YYYYMMDD
dynamic fnDateOfInteger(dynamic value) {
  final serial = varToInt(value) - _kCobolDateOffset;
  final dt = DateTime(1899, 12, 30).add(Duration(days: serial));
  return dt.year * 10000 + dt.month * 100 + dt.day;
}

/// DayOfInteger(cobolInt): converts a COBOL internal date integer to YYYYDDD
dynamic fnDayOfInteger(dynamic value) {
  final serial = varToInt(value) - _kCobolDateOffset;
  final dt = DateTime(1899, 12, 30).add(Duration(days: serial));
  final doy = dt.difference(DateTime(dt.year, 1, 1)).inDays + 1;
  return dt.year * 1000 + doy;
}

/// IntegerOfDate(yyyymmdd): converts YYYYMMDD to a COBOL internal date integer
dynamic fnIntegerOfDate(dynamic value) {
  final n = varToInt(value);
  final y = n ~/ 10000, m = (n ~/ 100) % 100, d = n % 100;
  final serial = _toDelphiSerial(DateTime(y, m, d));
  return serial.round() + _kCobolDateOffset;
}

/// IntegerOfDay(yyyyddd): converts YYYYDDD to a COBOL internal date integer
dynamic fnIntegerOfDay(dynamic value) {
  final n = varToInt(value);
  final y = n ~/ 1000, doy = n % 1000;
  final dt = DateTime(y, 1, 1).add(Duration(days: doy - 1));
  final serial = _toDelphiSerial(dt);
  return serial.round() + _kCobolDateOffset;
}

// ──────────────────────────────────────────────────────────────
// A few other miscellaneous added functions
// ──────────────────────────────────────────────────────────────

/// FillChar(count, ch): fills a string of length count with the given character
dynamic fnFillChar(dynamic v1, dynamic v2) {
  final n = varToInt(v1);
  final ch = varToStr(v2);
  return (ch.isNotEmpty ? ch[0] : ' ') * (n < 0 ? 0 : n);
}

/// Exp10Value(n): 10 raised to the argument's power
dynamic fnExp10Value(dynamic value) => pow(10, varToDouble(value));

/// ToIntSafe(v): safely converts to an integer, returning 0 on failure
dynamic fnToIntSafe(dynamic value) => int.tryParse(varToStr(value)) ?? 0;

/// ToFloatSafe(v): safely converts to a float, returning 0 on failure
dynamic fnToFloatSafe(dynamic value) => double.tryParse(varToStr(value)) ?? 0.0;

/// NumValC(str, currencySymbol): converts a string with a currency symbol and thousands-separator commas to a number
dynamic fnNumValC(dynamic v1, dynamic v2) {
  var s = varToStr(v1);
  final sym = varToStr(v2);
  if (sym.isNotEmpty) s = s.replaceAll(sym, '');
  s = s.replaceAll(',', '').trim();
  return double.tryParse(s) ?? 0.0;
}

/// NumValF(str): converts a floating-point string in scientific notation to a number
dynamic fnNumValF(dynamic value) => double.tryParse(varToStr(value)) ?? 0.0;

/// TestNumVal(str): tests whether a string can safely convert to a number; 0=yes, 1=no
dynamic fnTestNumVal(dynamic value) =>
    double.tryParse(varToStr(value)) != null ? 0 : 1;

/// TestNumValC(str, currencySymbol): the currency-symbol-aware version of the safety test
dynamic fnTestNumValC(dynamic v1, dynamic v2) {
  var s = varToStr(v1);
  final sym = varToStr(v2);
  if (sym.isNotEmpty) s = s.replaceAll(sym, '');
  s = s.replaceAll(',', '').trim();
  return double.tryParse(s) != null ? 0 : 1;
}

/// HIGH(values): the array's maximum index (0-based)
dynamic fnHIGH(List<dynamic> values) => values.length - 1;

/// LOW(values): the array's minimum index (always 0)
dynamic fnLOW(List<dynamic> values) => 0;

// ══ Standard intrinsic functions ══
// ============================================================
// myexp.pas → Flutter/Dart converted version
// Standard intrinsic functions: math, string, date and financial
// ============================================================

// ──────────────────────────────────────────────────────────────
// Math operations
// ──────────────────────────────────────────────────────────────

/// Expression function `ABS(x)`: absolute value.
dynamic stdABS(dynamic value) => varToDouble(value).abs();

/// Expression function `ACOS(x)`: arc cosine.
dynamic stdACOS(dynamic value) => acos(varToDouble(value));

/// Expression function `ASIN(x)`: arc sine.
dynamic stdASIN(dynamic value) => asin(varToDouble(value));

/// Expression function `ATAN(x)`: arc tangent.
dynamic stdATAN(dynamic value) => atan(varToDouble(value));

/// Expression function `COS(x)`: cosine.
dynamic stdCOS(dynamic value) => cos(varToDouble(value));

/// Expression function `SIN(x)`: sine.
dynamic stdSIN(dynamic value) => sin(varToDouble(value));

/// Expression function `TAN(x)`: tangent.
dynamic stdTAN(dynamic value) => tan(varToDouble(value));

/// Expression function `SQRT(x)`: square root.
dynamic stdSQRT(dynamic value) => sqrt(varToDouble(value));

/// Expression function `EXP(x)`: e to the power x.
dynamic stdEXP(dynamic value) => exp(varToDouble(value));

/// Expression function `EXP10(x)`: 10 to the power x.
dynamic stdEXP10(dynamic value) => pow(10, varToDouble(value)).toDouble();

/// Expression function `LOG(x)`: natural logarithm.
dynamic stdLOG(dynamic value) => log(varToDouble(value));

/// Expression function `LOG10(x)`: base-10 logarithm.
dynamic stdLOG10(dynamic value) => log(varToDouble(value)) / ln10;

/// MOD: result's sign matches the divisor (COBOL standard)
dynamic stdMOD(dynamic v1, dynamic v2) {
  final n = varToInt(v1);
  final d = varToInt(v2);
  if (d == 0) return 0;
  var r = n % d;
  if (r != 0 && (r < 0) != (d < 0)) r += d;
  return r;
}

/// REM: result's sign matches the dividend
dynamic stdREM(dynamic v1, dynamic v2) {
  final n = varToDouble(v1);
  final d = varToDouble(v2);
  if (d == 0) return 0.0;
  return n - (n / d).truncateToDouble() * d;
}

/// INTEGER: rounds down (floor)
dynamic stdINTEGER(dynamic value) => varToDouble(value).floor();

/// INTEGER-PART: truncates toward zero
dynamic stdINTEGER_PART(dynamic value) => varToDouble(value).truncate();

/// FRACTION-PART: the fractional part
dynamic stdFRACTION_PART(dynamic value) {
  final v = varToDouble(value);
  return v - v.truncateToDouble();
}

/// FACTORIAL：n!
dynamic stdFACTORIAL(dynamic value) {
  final n = varToInt(value);
  if (n < 0) return 0;
  int r = 1;
  for (var i = 2; i <= n; i++) {
    r *= i;
  }
  return r;
}

/// Expression function `E`: the constant e.
dynamic stdE() => exp(1.0);

/// Expression function `PI`: the constant pi.
dynamic stdPI() => pi;

/// Expression function `SIGN(x)`: -1, 0 or 1.
dynamic stdSIGN(dynamic value) {
  final e = varToDouble(value);
  if (e > 0) return 1;
  if (e < 0) return -1;
  return 0;
}

/// ANNUITY(rate, periods)
dynamic stdANNUITY(dynamic v1, dynamic v2) {
  final rate = varToDouble(v1);
  final n = varToInt(v2);
  if (n <= 0) return 0.0;
  if (rate == 0) return 1.0 / n;
  return rate / (1 - pow(1 + rate, -n));
}

/// PRESENT-VALUE(rate, amt1, amt2, ...)
dynamic stdPRESENT_VALUE(List<dynamic> values) {
  if (values.length < 2) return 0.0;
  final rate = varToDouble(values[0]);
  double pv = 0;
  for (var i = 1; i < values.length; i++) {
    pv += varToDouble(values[i]) / pow(1 + rate, i);
  }
  return pv;
}

// ──────────────────────────────────────────────────────────────
// Statistical aggregates
// ──────────────────────────────────────────────────────────────

/// Expression function `MAX(...)`: largest value.
dynamic stdMAX(List<dynamic> values) {
  if (values.isEmpty) return null;
  return values.reduce((a, b) {
    return varToDouble(a) >= varToDouble(b) ? a : b;
  });
}

/// Expression function `MIN(...)`: smallest value.
dynamic stdMIN(List<dynamic> values) {
  if (values.isEmpty) return null;
  return values.reduce((a, b) {
    return varToDouble(a) <= varToDouble(b) ? a : b;
  });
}

/// Expression function `MEAN(...)`: arithmetic mean.
dynamic stdMEAN(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  final s = values.fold(0.0, (sum, v) => sum + varToDouble(v));
  return s / values.length;
}

/// Expression function `MEDIAN(...)`: median.
dynamic stdMEDIAN(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  final sorted = values.map(varToDouble).toList()..sort();
  final n = sorted.length;
  if (n.isOdd) return sorted[n ~/ 2];
  return (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2.0;
}

/// Expression function `MIDRANGE(...)`: average of the largest and smallest value.
dynamic stdMIDRANGE(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  final nums = values.map(varToDouble).toList();
  final lo = nums.reduce((a, b) => a < b ? a : b);
  final hi = nums.reduce((a, b) => a > b ? a : b);
  return (lo + hi) / 2.0;
}

/// Expression function `RANGE(...)`: largest minus smallest value.
dynamic stdRANGE(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  final nums = values.map(varToDouble).toList();
  final lo = nums.reduce((a, b) => a < b ? a : b);
  final hi = nums.reduce((a, b) => a > b ? a : b);
  return hi - lo;
}

/// Expression function `SUM(...)`: sum.
dynamic stdSUM(List<dynamic> values) =>
    values.fold(0.0, (sum, v) => sum + varToDouble(v));

/// Expression function `VARIANCE(...)`: variance.
dynamic stdVARIANCE(List<dynamic> values) {
  final n = values.length;
  if (n < 2) return 0.0;
  double s = 0, ss = 0;
  for (final v in values) {
    final x = varToDouble(v);
    s += x;
    ss += x * x;
  }
  return (ss - s * s / n) / n;
}

/// Expression function `STANDARD_DEVIATION(...)`: standard deviation.
dynamic stdSTANDARD_DEVIATION(List<dynamic> values) =>
    sqrt(stdVARIANCE(values));

/// ORD-MAX: returns the 1-based index of the maximum value
dynamic stdORD_MAX(List<dynamic> values) {
  if (values.isEmpty) return 0;
  int bestIdx = 0;
  for (var i = 1; i < values.length; i++) {
    if (varToDouble(values[i]) > varToDouble(values[bestIdx])) bestIdx = i;
  }
  return bestIdx + 1;
}

/// ORD-MIN: returns the 1-based index of the minimum value
dynamic stdORD_MIN(List<dynamic> values) {
  if (values.isEmpty) return 0;
  int bestIdx = 0;
  for (var i = 1; i < values.length; i++) {
    if (varToDouble(values[i]) < varToDouble(values[bestIdx])) bestIdx = i;
  }
  return bestIdx + 1;
}

/// HIGHEST-ALGEBRAIC: the type's maximum value (based on the runtime type)
dynamic stdHIGHEST_ALGEBRAIC(dynamic value) {
  if (value is int) return 9007199254740991; // JS Number.MAX_SAFE_INTEGER
  if (value is double) return double.maxFinite;
  return null;
}

/// LOWEST-ALGEBRAIC: the type's minimum value
dynamic stdLOWEST_ALGEBRAIC(dynamic value) {
  if (value is int) return -9223372036854775808; // int64 min
  if (value is double) return -double.maxFinite;
  return null;
}

// ──────────────────────────────────────────────────────────────
// String processing
// ──────────────────────────────────────────────────────────────

/// Expression function `CONCATENATE(...)`: joins all arguments.
dynamic stdCONCATENATE(List<dynamic> values) => values.map(varToStr).join();

/// Expression function `LENGTH(s)`: string length.
dynamic stdLENGTH(dynamic value) => varToStr(value).length;

/// Expression function `BYTE_LENGTH(s)`: length in bytes.
dynamic stdBYTE_LENGTH(dynamic value) {
  // UTF-8 bytes
  final bytes = _utf8Bytes(varToStr(value));
  return bytes.length;
}

List<int> _utf8Bytes(String s) {
  final result = <int>[];
  for (final c in s.codeUnits) {
    if (c < 0x80) {
      result.add(c);
    } else if (c < 0x800) {
      result.add(0xC0 | (c >> 6));
      result.add(0x80 | (c & 0x3F));
    } else {
      result.add(0xE0 | (c >> 12));
      result.add(0x80 | ((c >> 6) & 0x3F));
      result.add(0x80 | (c & 0x3F));
    }
  }
  return result;
}

/// Expression function `STORED_CHAR_LENGTH(s)`: length without trailing spaces.
dynamic stdSTORED_CHAR_LENGTH(dynamic value) =>
    varToStr(value).trimRight().length;

/// Expression function `LOWER_CASE(s)`: lower-case copy.
dynamic stdLOWER_CASE(dynamic value) => varToStr(value).toLowerCase();

/// Expression function `UPPER_CASE(s)`: upper-case copy.
dynamic stdUPPER_CASE(dynamic value) => varToStr(value).toUpperCase();

/// Expression function `REVERSE(s)`: reversed string.
dynamic stdREVERSE(dynamic value) => varToStr(value).split("").reversed.join();

/// TRIM(str, mode)  mode: 'LEADING' | 'TRAILING' | '' (both ends)
dynamic stdTRIM(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final mode = varToStr(v2).toUpperCase().trim();
  if (mode == 'LEADING') return s.trimLeft();
  if (mode == 'TRAILING') return s.trimRight();
  return s.trim();
}

/// SUBSTITUTE(str, from1, to1, from2, to2, ...)
dynamic stdSUBSTITUTE(List<dynamic> values) {
  if (values.isEmpty) return '';
  var s = varToStr(values[0]);
  var i = 1;
  while (i + 1 < values.length) {
    final f = varToStr(values[i]);
    final t = varToStr(values[i + 1]);
    s = s.replaceAll(f, t);
    i += 2;
  }
  return s;
}

/// SUBSTITUTE-CASE (case-insensitive)
dynamic stdSUBSTITUTE_CASE(List<dynamic> values) {
  if (values.isEmpty) return '';
  var s = varToStr(values[0]);
  var i = 1;
  while (i + 1 < values.length) {
    final f = varToStr(values[i]);
    final t = varToStr(values[i + 1]);
    s = s.replaceAll(RegExp(RegExp.escape(f), caseSensitive: false), t);
    i += 2;
  }
  return s;
}

/// CHAR(n): ordinal n → character (COBOL ordinal = ASCII + 1)
dynamic stdCHAR(dynamic value) {
  final n = varToInt(value);
  if (n >= 1 && n <= 256) return String.fromCharCode(n - 1);
  return '';
}

/// ORD(c): character → ordinal (= ASCII + 1)
dynamic stdORD(dynamic value) {
  final s = varToStr(value);
  if (s.isEmpty) return 0;
  return s.codeUnitAt(0) + 1;
}

// ──────────────────────────────────────────────────────────────
// Numeric conversion
// ──────────────────────────────────────────────────────────────

/// Expression function `NUMVAL(s)`: string to number.
dynamic stdNUMVAL(dynamic value) {
  final s = varToStr(value).replaceAll(",", "").trim();
  return double.tryParse(s) ?? 0.0;
}

/// Expression function `NUMVAL_C(s, symbol)`: string with a currency symbol to number.
dynamic stdNUMVAL_C(dynamic v1, dynamic v2) {
  var s = varToStr(v1).trim();
  final sym = varToStr(v2);
  if (sym.isNotEmpty) s = s.replaceAll(sym, "");
  s = s.replaceAll(",", "");
  return double.tryParse(s) ?? 0.0;
}

/// Expression function `NUMVAL_F(s)`: floating-point string (e.g. `1.5E2`) to number.
dynamic stdNUMVAL_F(dynamic value) {
  final s = varToStr(value).trim();
  return double.tryParse(s) ?? 0.0;
}

/// Expression function `TEST_NUMVAL(s)`: 0 when [stdNUMVAL] can convert the string.
dynamic stdTEST_NUMVAL(dynamic value) {
  final s = varToStr(value).replaceAll(",", "").trim();
  return double.tryParse(s) != null ? 0 : 1;
}

/// Expression function `TEST_NUMVAL_C(s, symbol)`: 0 when [stdNUMVAL_C] can convert the string.
dynamic stdTEST_NUMVAL_C(dynamic v1, dynamic v2) {
  var s = varToStr(v1).trim();
  final sym = varToStr(v2);
  if (sym.isNotEmpty) s = s.replaceAll(sym, "");
  s = s.replaceAll(",", "");
  return double.tryParse(s) != null ? 0 : 1;
}

/// Expression function `TEST_NUMVAL_F(s)`: 0 when [stdNUMVAL_F] can convert the string.
dynamic stdTEST_NUMVAL_F(dynamic value) {
  return double.tryParse(varToStr(value).trim()) != null ? 0 : 1;
}

// ──────────────────────────────────────────────────────────────
// Date/time
// ──────────────────────────────────────────────────────────────

/// Internal: TDateTime integer day (Pascal-style) → Dart DateTime
/// 1 = 1601-01-01 (the COBOL epoch)
DateTime _cobIntToDateTime(int n) {
  // simplified: 1 = 0001-01-01
  return DateTime(1, 1, 1).add(Duration(days: n - 1));
}

int _cobDateTimeToInt(DateTime dt) {
  return dt.difference(DateTime(1, 1, 1)).inDays + 1;
}

/// CURRENT-DATE (returns a full timestamp string yyyyMMddHHmmsscc+HHmm)
dynamic stdCURRENT_DATE() {
  final now = DateTime.now();
  final offset = now.timeZoneOffset;
  final sign = offset.isNegative ? '-' : "+";
  final absOffset = offset.abs();
  final bh = absOffset.inHours;
  final bm = absOffset.inMinutes % 60;
  return '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
      '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}'
      '${(now.millisecond ~/ 10).toString().padLeft(2, '0')}$sign${bh.toString().padLeft(2, '0')}${bm.toString().padLeft(2, '0')}';
}

/// WHEN-COMPILED: same as CURRENT-DATE
dynamic stdWHEN_COMPILED() => stdCURRENT_DATE();

/// DATE-OF-INTEGER(n) → YYYYMMDD
dynamic stdDATE_OF_INTEGER(dynamic value) {
  final dt = _cobIntToDateTime(varToInt(value));
  return dt.year * 10000 + dt.month * 100 + dt.day;
}

/// INTEGER-OF-DATE(YYYYMMDD) → integer day
dynamic stdINTEGER_OF_DATE(dynamic value) {
  final n = varToInt(value);
  final y = n ~/ 10000;
  final m = (n % 10000) ~/ 100;
  final d = n % 100;
  return _cobDateTimeToInt(DateTime(y, m, d));
}

/// DAY-OF-INTEGER(n) → YYYYDDD
dynamic stdDAY_OF_INTEGER(dynamic value) {
  final dt = _cobIntToDateTime(varToInt(value));
  final doy = dt.difference(DateTime(dt.year, 1, 1)).inDays + 1;
  return dt.year * 1000 + doy;
}

/// INTEGER-OF-DAY(YYYYDDD) → integer day
dynamic stdINTEGER_OF_DAY(dynamic value) {
  final n = varToInt(value);
  final y = n ~/ 1000;
  final doy = n % 1000;
  final dt = DateTime(y, 1, 1).add(Duration(days: doy - 1));
  return _cobDateTimeToInt(dt);
}

/// SECONDS-PAST-MIDNIGHT
dynamic stdSECONDS_PAST_MIDNIGHT() {
  final now = DateTime.now();
  return now.hour * 3600 + now.minute * 60 + now.second;
}

/// COMBINED-DATETIME(date_int, time_secs)
dynamic stdCOMBINED_DATETIME(dynamic v1, dynamic v2) =>
    varToInt(v1) * 86400.0 + varToInt(v2);

/// DATE-TO-YYYYMMDD(yymmdd, pivot)
dynamic stdDATE_TO_YYYYMMDD(dynamic v1, dynamic v2) {
  final n = varToInt(v1);
  var pivot = varToInt(v2);
  if (pivot == 0) pivot = 50;
  final yy = n ~/ 10000;
  final mm = (n % 10000) ~/ 100;
  final dd = n % 100;
  final yyyy = yy <= pivot ? 2000 + yy : 1900 + yy;
  return yyyy * 10000 + mm * 100 + dd;
}

/// YEAR-TO-YYYY(yy, pivot)
dynamic stdYEAR_TO_YYYY(dynamic v1, dynamic v2) {
  final yy = varToInt(v1);
  var pivot = varToInt(v2);
  if (pivot == 0) pivot = 50;
  return yy <= pivot ? 2000 + yy : 1900 + yy;
}

/// TEST-DATE-YYYYMMDD: 0=valid
dynamic stdTEST_DATE_YYYYMMDD(dynamic value) {
  final n = varToInt(value);
  final y = n ~/ 10000;
  final m = (n % 10000) ~/ 100;
  final d = n % 100;
  try {
    DateTime(y, m, d);
    return 0;
  } catch (_) {
    return 1;
  }
}

/// TEST-DAY-YYYYDDD: 0=valid
dynamic stdTEST_DAY_YYYYDDD(dynamic value) {
  final n = varToInt(value);
  final y = n ~/ 1000;
  final doy = n % 1000;
  final isLeap = (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
  final maxDoy = isLeap ? 366 : 365;
  if (y >= 1601 && doy >= 1 && doy <= maxDoy) return 0;
  return 1;
}

// ──────────────────────────────────────────────────────────────
// Localization
// ──────────────────────────────────────────────────────────────

/// Expression function `LOCALE_DATE(d)`: date formatted for the locale.
dynamic stdLOCALE_DATE(dynamic value) {
  final dt = _cobIntToDateTime(varToInt(value));
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

/// Expression function `LOCALE_TIME(t)`: time formatted for the locale.
dynamic stdLOCALE_TIME(dynamic value) {
  final secs = varToInt(value);
  final h = secs ~/ 3600;
  final m = (secs % 3600) ~/ 60;
  final s = secs % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// LOCALE-COMPARE(s1, s2) → '<' '=' '>'
dynamic stdLOCALE_COMPARE(dynamic v1, dynamic v2) {
  final c = varToStr(v1).compareTo(varToStr(v2));
  if (c < 0) return '<';
  if (c > 0) return '>';
  return '=';
}

/// Expression function `CURRENCY_SYMBOL`: the currency symbol.
dynamic stdCURRENCY_SYMBOL() => '\$'; // default, could be locale-determined

/// Expression function `MONETARY_DECIMAL_POINT`: monetary decimal point.
dynamic stdMONETARY_DECIMAL_POINT() => '.';

/// Expression function `MONETARY_THOUSANDS_SEPARATOR`: monetary thousands separator.
dynamic stdMONETARY_THOUSANDS_SEPARATOR() => ',';

/// Expression function `NUMERIC_DECIMAL_POINT`: numeric decimal point.
dynamic stdNUMERIC_DECIMAL_POINT() => '.';

/// Expression function `NUMERIC_THOUSANDS_SEPARATOR`: numeric thousands separator.
dynamic stdNUMERIC_THOUSANDS_SEPARATOR() => ',';

// ──────────────────────────────────────────────────────────────
// Misc / internationalization
// ──────────────────────────────────────────────────────────────

/// RANDOM([seed]): doesn't reset when seed=0
dynamic stdRANDOM(dynamic value) {
  final rng = value != null && varToInt(value) != 0
      ? Random(varToInt(value))
      : Random();
  return rng.nextDouble();
}

/// BOOLEAN-OF-INTEGER(n, len): converts an integer to a bit string
dynamic stdBOOLEAN_OF_INTEGER(dynamic v1, dynamic v2) {
  final n = varToInt(v1);
  final len = varToInt(v2);
  return List.generate(len, (i) => ((n >> (len - 1 - i)) & 1) == 1 ? '1' : "0")
      .join();
}

/// INTEGER-OF-BOOLEAN(s): converts a bit string to an integer
dynamic stdINTEGER_OF_BOOLEAN(dynamic value) {
  final s = varToStr(value);
  int r = 0;
  for (final c in s.split("")) {
    r = (r << 1) | (c == '1' ? 1 : 0);
  }
  return r;
}

/// STANDARD-COMPARE(s1, s2) → '<' '=' '>'
dynamic stdSTANDARD_COMPARE(dynamic v1, dynamic v2) {
  final c = varToStr(v1).compareTo(varToStr(v2));
  if (c < 0) return '<';
  if (c > 0) return '>';
  return '=';
}

// ══ my_parser.dart ══
// ============================================================
// myexp.pas → Flutter/Dart converted version
// my_parser.dart  —  the MyParser main class (lexing + parsing + stack)
// ============================================================

/// Corresponds to Pascal TmyParser
/// Corresponds to Delphi's TDataSet/TField: the evaluator can register datasets, and expressions read values via
/// Dataset.COUNT / .BOF / .EOF / .STATE / .field (FindField).
abstract class ExprDataSet {
  /// Number of records.
  int get recordCount; // RecordCount
  /// Whether the cursor is before the first record.
  bool get bof; // Bof
  /// Whether the cursor is after the last record.
  bool get eof; // Eof
  /// Edit state: `BROWSE`, `EDIT`, `INSERT` or `INACTIVE`.
  String get state; // State（BROWSE/INSERT/EDIT…）
  /// Whether the dataset has a field called [name].
  bool hasField(String name); // FindField <> nil
  /// Value of field [name] in the current record.
  dynamic fieldValue(String name); // Field.Value
  /// Value of the field at 0-based [index] in the current record.
  dynamic fieldValueAt(int index) => null; // Fields[index].Value (0-based)
}

/// The expression parser behind [WapEvaluator]; use [WapEvaluator] instead.
class MyParser {
  // ── Public properties ──────────────────────────────────────────────────
  /// The expression to evaluate.
  String expression = '';

  /// Null-substitution mode: unknown names evaluate to null instead of failing.
  bool nul = false; // Null-substitution mode
  /// Error message of the last evaluation ('' when none).
  String error = '';

  /// Result of the last evaluation.
  dynamic value;

  // ── Internal state ──────────────────────────────────────────────────
  final List<IdentRecord> _identList = [];
  final List<dynamic> _stack = [];

  late String _source;
  late int _pos;
  ExprToken _token = ExprToken.end_;
  String _tokenString = '';

  // ──────────────────────────────────────────────────────────────
  // Construction / initialization
  // ──────────────────────────────────────────────────────────────

  /// Creates a parser with the built-in functions registered.
  MyParser() {
    addInternalFunctions();
  }

  // ──────────────────────────────────────────────────────────────
  // Identifier management
  // ──────────────────────────────────────────────────────────────

  /// Removes every variable and function.
  void clearIdentifiers() => _identList.clear();

  /// Clears only user variables (variable/constant), keeps built-in functions (function_)
  void clearUserVars() {
    _identList.removeWhere(
        (r) => r.kind == IdentKind.variable || r.kind == IdentKind.constant);
  }

  /// Gets all user-set variables
  Map<String, dynamic> getUserVars() {
    final result = <String, dynamic>{};
    for (final r in _identList) {
      if (r.kind == IdentKind.variable || r.kind == IdentKind.constant) {
        result[r.name] = r.value;
      }
    }
    return result;
  }

  // ── Dataset resolution (delegated to an external object list) ──────────────────────────────────────────
  // No longer maintains its own datasets list; the resolver is now provided externally (by agp102's dbq object list).
  // Once datasetResolver is set, an expression encountering 'cust.balance' asks the external object list instead,
  // achieving a "single list" — the list only exists in agp102; wapform_expression doesn't hold a copy.
  /// Resolves dataset names used in expressions (`ds.field`).
  ExprDataSet? Function(String name)? datasetResolver;

  /// The dataset called [name], or null.
  ExprDataSet? findDataSet(String name) {
    final r = datasetResolver;
    if (r != null) return r(name);
    // Falls back to the built-in Map when there's no external resolver (backward compatibility; not normally used)
    return _legacyDatasets[name.toUpperCase()];
  }

  // The built-in Map used for backward compatibility (only used when datasetResolver isn't set)
  final Map<String, ExprDataSet> _legacyDatasets = {};

  /// Makes [ds] available to expressions as [name].
  void registerDataSet(String name, ExprDataSet ds) =>
      _legacyDatasets[name.toUpperCase()] = ds;

  /// Removes the dataset registered as [name].
  void unregisterDataSet(String name) =>
      _legacyDatasets.remove(name.toUpperCase());

  /// Removes every registered dataset.
  void clearDataSets() => _legacyDatasets.clear();

  /// Index of identifier [name], or -1.
  int findIdent(String name) {
    final upper = name.toUpperCase();
    for (var i = 0; i < _identList.length; i++) {
      if (_identList[i].name.toUpperCase() == upper) return i;
    }
    return -1;
  }

  /// Deletes variable [name].
  void delVar(String name) {
    final i = findIdent(name);
    if (i >= 0) _identList.removeAt(i);
  }

  /// Value of variable [name], or null.
  dynamic getVar(String name) {
    final i = findIdent(name);
    if (i >= 0) return _identList[i].value;
    return null;
  }

  /// Sets variable [name] to [value] (not evaluated).
  void setVar(String name, dynamic value) {
    final i = findIdent(name);
    if (i >= 0) {
      _identList[i].value = value;
    } else {
      _identList.add(IdentRecord(
        name: name.toUpperCase(),
        kind: IdentKind.constant,
        value: value,
      ));
    }
  }

  /// Sets element [index] of array variable [name].
  void setAry(String name, int index, dynamic val) {
    final i = findIdent(name);
    if (i >= 0) {
      final v = _identList[i].value;
      if (v is List) {
        if (index >= 0 && index < v.length) v[index] = val;
      }
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Function registration
  // ──────────────────────────────────────────────────────────────

  /// Registers a function without parameters; an existing one of the same name is kept.
  void addFunction0Param(String name, Func0 fn) {
    if (findIdent(name) >= 0) return;
    _identList.add(IdentRecord(
      name: name.toUpperCase(),
      kind: IdentKind.function_,
      pCount: 0,
      func0: fn,
    ));
  }

  /// Registers a one-parameter function; an existing one of the same name is kept.
  void addFunction1Param(String name, Func1 fn) {
    if (findIdent(name) >= 0) return;
    _identList.add(IdentRecord(
      name: name.toUpperCase(),
      kind: IdentKind.function_,
      pCount: 1,
      func1: fn,
    ));
  }

  /// Registers a two-parameter function; an existing one of the same name is kept.
  void addFunction2Param(String name, Func2 fn) {
    if (findIdent(name) >= 0) return;
    _identList.add(IdentRecord(
      name: name.toUpperCase(),
      kind: IdentKind.function_,
      pCount: 2,
      func2: fn,
    ));
  }

  /// Registers a three-parameter function; an existing one of the same name is kept.
  void addFunction3Param(String name, Func3 fn) {
    if (findIdent(name) >= 0) return;
    _identList.add(IdentRecord(
      name: name.toUpperCase(),
      kind: IdentKind.function_,
      pCount: 3,
      func3: fn,
    ));
  }

  /// Registers a four-parameter function; an existing one of the same name is kept.
  void addFunction4Param(String name, Func4 fn) {
    if (findIdent(name) >= 0) return;
    _identList.add(IdentRecord(
      name: name.toUpperCase(),
      kind: IdentKind.function_,
      pCount: 4,
      func4: fn,
    ));
  }

  /// Registers a variadic function; an existing one of the same name is kept.
  void addFunctionAParam(String name, FuncA fn) {
    if (findIdent(name) >= 0) return;
    _identList.add(IdentRecord(
      name: name.toUpperCase(), kind: IdentKind.function_,
      pCount: -1, // -1 means variadic
      funcA: fn,
    ));
  }

  // ──────────────────────────────────────────────────────────────
  // Stack operations
  // ──────────────────────────────────────────────────────────────

  void _stackClear() => _stack.clear();
  int _stackCount() => _stack.length;

  void _push(dynamic v) => _stack.add(v);

  dynamic _pop() {
    if (_stack.isEmpty) {
      _raiseError("Stack count error");
      return null;
    }
    return _stack.removeLast();
  }

  // ──────────────────────────────────────────────────────────────
  // Error handling
  // ──────────────────────────────────────────────────────────────

  void _raiseError(String msg) {
    if (error.isEmpty) error = msg;
    _stackClear();
  }

  // ──────────────────────────────────────────────────────────────
  // Main entry point: parses and evaluates the expression
  // ──────────────────────────────────────────────────────────────

  /// Evaluates [expression] into [value]; returns false and sets [error] on failure.
  bool analyzeExpression() {
    error = '';
    value = null;

    if (expression.isEmpty) {
      _raiseError("Empty expression");
      return false;
    }

    _stackClear();
    _source = expression;
    _pos = 0;

    _nextToken();
    _parseExpression();

    if (_token != ExprToken.end_ || _stackCount() != 1) {
      if (error.isEmpty) _raiseError("Invalid end token");
      return false;
    }

    value = _pop();
    return error.isEmpty;
  }

  // ──────────────────────────────────────────────────────────────
  // Lexer: NextToken
  // ──────────────────────────────────────────────────────────────

  void _nextToken() {
    _tokenString = '';

    // skip whitespace
    while (_pos < _source.length && _source[_pos].codeUnitAt(0) <= 32) {
      _pos++;
    }

    // skip /* ... */ comments
    if (_pos < _source.length - 1 &&
        _source[_pos] == '/' &&
        _source[_pos + 1] == '*') {
      _pos += 2;
      while (_pos < _source.length) {
        if (_pos < _source.length - 1 &&
            _source[_pos] == '*' &&
            _source[_pos + 1] == '/') {
          _pos += 2;
          break;
        }
        _pos++;
      }
      while (_pos < _source.length && _source[_pos].codeUnitAt(0) <= 32) {
        _pos++;
      }
    }

    if (_pos >= _source.length) {
      _token = ExprToken.end_;
      return;
    }

    final c = _source[_pos];

    // identifier
    if (RegExp(r"[A-Za-z_\u0080-\uFFFE]").hasMatch(c)) {
      final start = _pos;
      _pos++;
      while (_pos < _source.length &&
          RegExp(r"[A-Za-z0-9_.]").hasMatch(_source[_pos])) {
        _pos++;
      }
      _tokenString = _source.substring(start, _pos);
      final upper = _tokenString.toUpperCase();
      if (upper == 'DIV') {
        _token = ExprToken.div_;
      } else if (upper == 'MOD') {
        _token = ExprToken.mod_;
      } else if (upper == 'AND') {
        _token = ExprToken.and_;
      } else if (upper == 'OR') {
        _token = ExprToken.or_;
      } else if (upper == 'NOT') {
        _token = ExprToken.not_;
      } else {
        _token = ExprToken.identifier;
      }
      return;
    }

    // string (single-quoted)
    if (c == "'") {
      _pos++;
      final buf = StringBuffer();
      while (_pos < _source.length) {
        if (_source[_pos] == "'") {
          _pos++;
          if (_pos < _source.length && _source[_pos] == "'") {
            buf.write("'");
            _pos++;
          } else {
            break;
          }
        } else {
          buf.write(_source[_pos]);
          _pos++;
        }
      }
      _tokenString = buf.toString();
      _token = ExprToken.string_;
      return;
    }

    // string (backtick)
    if (c == '`') {
      _pos++;
      final buf = StringBuffer();
      while (_pos < _source.length) {
        if (_source[_pos] == '`') {
          _pos++;
          if (_pos < _source.length && _source[_pos] == '`') {
            buf.write("`");
            _pos++;
          } else {
            break;
          }
        } else {
          buf.write(_source[_pos]);
          _pos++;
        }
      }
      _tokenString = buf.toString();
      _token = ExprToken.string_;
      return;
    }

    // string (double-quoted) — same semantics as single-quoted; "" represents one "
    if (c == '"') {
      _pos++;
      final buf = StringBuffer();
      while (_pos < _source.length) {
        if (_source[_pos] == '"') {
          _pos++;
          if (_pos < _source.length && _source[_pos] == '"') {
            buf.write('"');
            _pos++;
          } else {
            break;
          }
        } else {
          buf.write(_source[_pos]);
          _pos++;
        }
      }
      _tokenString = buf.toString();
      _token = ExprToken.string_;
      return;
    }

    // number
    if (RegExp(r"[0-9]").hasMatch(c)) {
      final start = _pos;
      while (
          _pos < _source.length && RegExp(r"[0-9.]").hasMatch(_source[_pos])) {
        _pos++;
      }
      _tokenString = _source.substring(start, _pos);
      _token = ExprToken.number;
      return;
    }

    // color hex #RRGGBB
    if (c == '#') {
      _pos++;
      final start = _pos;
      while (_pos < _source.length &&
          RegExp(r"[0-9A-Fa-f]").hasMatch(_source[_pos])) {
        _pos++;
      }
      _tokenString = '#${_source.substring(start, _pos)}';
      _token = ExprToken.hex;
      return;
    }

    // single-character token
    _pos++;
    switch (c) {
      case '(':
        _token = ExprToken.lParen;
        break;
      case ')':
        _token = ExprToken.rParen;
        break;
      case '[':
        _token = ExprToken.lArray;
        break;
      case ']':
        _token = ExprToken.rArray;
        break;
      case ',':
        _token = ExprToken.comma;
        break;
      case '+':
        _token = ExprToken.plus;
        break;
      case '-':
        _token = ExprToken.minus;
        break;
      case '*':
        _token = ExprToken.star;
        break;
      case '/':
        _token = ExprToken.slash;
        break;
      case '.':
        _token = ExprToken.dot;
        break;
      case '=':
        _token = ExprToken.equal;
        _tokenString = '=';
        break;
      case '<':
        if (_pos < _source.length) {
          if (_source[_pos] == '=') {
            _pos++;
            _token = ExprToken.le;
          } else if (_source[_pos] == '>') {
            _pos++;
            _token = ExprToken.ne;
          } else {
            _token = ExprToken.lt;
          }
        } else {
          _token = ExprToken.lt;
        }
        break;
      case '>':
        if (_pos < _source.length && _source[_pos] == '=') {
          _pos++;
          _token = ExprToken.ge;
        } else {
          _token = ExprToken.gt;
        }
        break;
      default:
        _raiseError("Invalid character: $c");
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Parser: ParseExpression (comparison operators)
  // ──────────────────────────────────────────────────────────────

  void _parseExpression() {
    _parseSimpleExpression();

    if (_token == ExprToken.equal ||
        _token == ExprToken.ne ||
        _token == ExprToken.lt ||
        _token == ExprToken.gt ||
        _token == ExprToken.le ||
        _token == ExprToken.ge) {
      final op = _token;
      _nextToken();
      _parseSimpleExpression();

      final operand2 = _pop();
      final operand1 = _pop();

      // string comparison
      dynamic a = operand1;
      dynamic b = operand2;
      if (a is String || b is String) {
        a = varToStr(a);
        b = varToStr(b);
      }

      switch (op) {
        case ExprToken.equal:
          _push(_compare(a, b) == 0);
          break;
        case ExprToken.ne:
          _push(_compare(a, b) != 0);
          break;
        case ExprToken.lt:
          _push(_compare(a, b) < 0);
          break;
        case ExprToken.gt:
          _push(_compare(a, b) > 0);
          break;
        case ExprToken.le:
          _push(_compare(a, b) <= 0);
          break;
        case ExprToken.ge:
          _push(_compare(a, b) >= 0);
          break;
        default:
          break;
      }
    }
  }

  int _compare(dynamic a, dynamic b) {
    if (a is String && b is String) return a.compareTo(b);
    if (a is num && b is num) {
      if (a < b) return -1;
      if (a > b) return 1;
      return 0;
    }
    return a.toString().compareTo(b.toString());
  }

  // ──────────────────────────────────────────────────────────────
  // ParseSimpleExpression (add/subtract, OR, unary plus/minus)
  // ──────────────────────────────────────────────────────────────

  void _parseSimpleExpression() {
    ExprToken unaryOp = ExprToken.plus;
    if (_token == ExprToken.plus || _token == ExprToken.minus) {
      unaryOp = _token;
      _nextToken();
    }

    _parseTerm();

    if (unaryOp == ExprToken.minus) {
      final v = _pop();
      if (v is num) {
        _push(-v);
      } else {
        _push(0 - varToDouble(v));
      }
    }

    while (_token == ExprToken.plus ||
        _token == ExprToken.minus ||
        _token == ExprToken.or_) {
      final op = _token;
      _nextToken();
      _parseTerm();

      final operand2 = _pop();
      final operand1 = _pop();

      switch (op) {
        case ExprToken.plus:
          if (operand1 is String || operand2 is String) {
            _push(varToStr(operand1) + varToStr(operand2));
          } else if (operand1 is int && operand2 is int) {
            _push(operand1 + operand2);
          } else {
            _push(varToDouble(operand1) + varToDouble(operand2));
          }
          break;
        case ExprToken.minus:
          if (operand1 is int && operand2 is int) {
            _push(operand1 - operand2);
          } else {
            _push(varToDouble(operand1) - varToDouble(operand2));
          }
          break;
        case ExprToken.or_:
          _push(varToInt(operand1) | varToInt(operand2));
          break;
        default:
          break;
      }
    }
  }

  // ──────────────────────────────────────────────────────────────
  // ParseTerm (multiply/divide, DIV, MOD, AND)
  // ──────────────────────────────────────────────────────────────

  void _parseTerm() {
    _parseFactor();

    while (_token == ExprToken.star ||
        _token == ExprToken.slash ||
        _token == ExprToken.div_ ||
        _token == ExprToken.mod_ ||
        _token == ExprToken.and_) {
      final op = _token;
      _nextToken();
      _parseFactor();

      final operand2 = _pop();
      final operand1 = _pop();
      final d2 = varToDouble(operand2);
      final d1 = varToDouble(operand1);

      switch (op) {
        case ExprToken.star:
          if (operand1 is int && operand2 is int) {
            _push(operand1 * operand2);
          } else {
            _push(d1 * d2);
          }
          break;
        case ExprToken.slash:
          _push(d2 != 0 ? d1 / d2 : 0.0);
          break;
        case ExprToken.div_:
          _push(d2 != 0 ? varToInt(operand1) ~/ varToInt(operand2) : 0);
          break;
        case ExprToken.mod_:
          _push(d2 != 0 ? varToInt(operand1) % varToInt(operand2) : 0);
          break;
        case ExprToken.and_:
          _push(varToInt(operand1) & varToInt(operand2));
          break;
        default:
          break;
      }
    }
  }

  // ──────────────────────────────────────────────────────────────
  // ParseFactor (numbers, strings, identifiers, NOT, parentheses, arrays)
  // ──────────────────────────────────────────────────────────────

  void _parseFactor() {
    switch (_token) {
      case ExprToken.identifier:
        _parseFunction();
        break;

      case ExprToken.number:
        if (_tokenString.contains(".")) {
          _push(double.tryParse(_tokenString) ?? 0.0);
        } else {
          _push(int.tryParse(_tokenString) ?? 0);
        }
        _nextToken();
        break;

      case ExprToken.hex:
        {
          var s = _tokenString.replaceAll("#", "");
          if (s.length == 6) {
            final r = int.tryParse(s.substring(0, 2), radix: 16) ?? 0;
            final g = int.tryParse(s.substring(2, 4), radix: 16) ?? 0;
            final b = int.tryParse(s.substring(4, 6), radix: 16) ?? 0;
            _push((0xFF << 24) | (r << 16) | (g << 8) | b);
          }
          _nextToken();
        }
        break;

      case ExprToken.string_:
        _push(_tokenString);
        _nextToken();
        break;

      case ExprToken.not_:
        _nextToken();
        _parseFactor();
        final v = _pop();
        _push(!(v == true || (v is num && v != 0)));
        break;

      case ExprToken.lParen:
        _nextToken();
        _parseExpression();
        if (_token == ExprToken.rParen) _nextToken();
        break;

      case ExprToken.lArray:
        _parseArrayLiteral();
        break;

      default:
        break;
    }
  }

  void _parseArrayLiteral() {
    final items = <dynamic>[];
    _nextToken();
    // [lo..hi] range declaration: a zero-filled array whose indexes lo..hi
    // are all valid (Dart lists start at 0, so the length is hi+1)
    if (_token == ExprToken.number) {
      final m = RegExp(r'^(\d+)\.\.(\d+)$').firstMatch(_tokenString);
      if (m != null) {
        final hi = int.parse(m.group(2)!);
        _nextToken();
        if (_token == ExprToken.rArray) _nextToken();
        _push(List<dynamic>.filled(hi + 1, 0, growable: true));
        return;
      }
    }
    while (_token != ExprToken.rArray && _token != ExprToken.end_) {
      _parseExpression();
      items.add(_pop());
      if (_token == ExprToken.comma) _nextToken();
    }
    if (_token == ExprToken.rArray) _nextToken();
    _push(items);
  }

  // ──────────────────────────────────────────────────────────────
  // ParseFunction (identifier resolution)
  // ──────────────────────────────────────────────────────────────

  void _parseFunction() {
    final st = _tokenString;
    _nextToken();

    // Dataset.Field (corresponds to Delphi: FDataSets.IndexOf(DS) →
    // RecordCount / Bof / Eof / State / FindField）
    final dot = st.indexOf(".");
    if (dot > 0) {
      final ds = findDataSet(st.substring(0, dot));
      if (ds != null) {
        final fld = st.substring(dot + 1);
        final u = fld.toUpperCase();
        if (u == 'COUNT' || u == 'RECORDCOUNT') {
          _push(ds.recordCount);
        } else if (u == 'BOF') {
          _push(ds.bof);
        } else if (u == 'EOF') {
          _push(ds.eof);
        } else if (u == 'STATE') {
          _push(ds.state);
        } else if (u == 'FIELDS' && _token == ExprToken.lArray) {
          // ds.FIELDS[n]: field value by position, 1-based like WapForm
          _nextToken();
          _parseExpression();
          final idx = _pop();
          if (_token == ExprToken.rArray) _nextToken();
          final n = (idx is num) ? idx.toInt() : int.tryParse("$idx") ?? 0;
          var v = ds.fieldValueAt(n - 1);
          if (nul && v == null) v = '';
          _push(v);
        } else if (ds.hasField(fld)) {
          var v = ds.fieldValue(fld);
          if (nul && v == null) {
            v = ''; // Null mode: a Null field → an empty string
          }
          _push(v);
        } else {
          _raiseError("Field not found: $fld"); // corresponds to aField = nil
          _push(null);
        }
        return;
      }
    }

    final i = findIdent(st);
    if (i < 0) {
      // @@@ If not followed by '(' → treated as an undefined variable, returns null (WapForm convention: an undefined variable is treated as empty,
      //     e.g. an unset SQL fragment variable like $S is treated as an empty string). Only truly unknown functions (followed by '(') raise an error.
      if (_token != ExprToken.lParen) {
        _push(null);
        return;
      }
      _raiseError("Unknown function identifier: $st");
      return;
    }

    final ident = _identList[i];

    switch (ident.kind) {
      case IdentKind.constant:
        // the value is a List followed by [index] → array element access
        // (variables written by setVar are all stored as constant; setvar('arr[i]')'s array is read here)
        if (_token == ExprToken.lArray && ident.value is List) {
          _nextToken();
          _parseExpression();
          final idx = _pop();
          if (_token == ExprToken.rArray) _nextToken();
          final arr = ident.value as List;
          final iIdx = (idx is int)
              ? idx
              : (idx is num ? idx.toInt() : int.tryParse("$idx") ?? -1);
          if (iIdx >= 0 && iIdx < arr.length) {
            _push(arr[iIdx]);
          } else {
            _push(null);
          }
        } else {
          _push(ident.value);
        }
        break;

      case IdentKind.variable:
        // a variable value that's a List followed by [index] → array element access (the counterpart to what setvar('arr[i]') writes)
        if (_token == ExprToken.lArray && ident.value is List) {
          _nextToken();
          _parseExpression();
          final idx = _pop();
          if (_token == ExprToken.rArray) _nextToken();
          final arr = ident.value as List;
          final iIdx = (idx is int)
              ? idx
              : (idx is num ? idx.toInt() : int.tryParse("$idx") ?? -1);
          if (iIdx >= 0 && iIdx < arr.length) {
            _push(arr[iIdx]);
          } else {
            _push(null);
          }
        } else {
          _push(ident.value);
        }
        break;

      case IdentKind.array_:
        if (_token == ExprToken.lArray) {
          _nextToken();
          _parseExpression();
          final idx = _pop();
          if (_token == ExprToken.rArray) _nextToken();
          final arr = ident.value;
          if (arr is List && idx is int) {
            _push(arr[idx]);
          } else {
            _push(null);
          }
        } else {
          _push(ident.value);
        }
        break;

      case IdentKind.function_:
        _callFunction(ident, st);
        break;
    }
  }

  void _callFunction(IdentRecord ident, String name) {
    // variadic (pCount == -1)
    if (ident.pCount == -1) {
      final params = _collectVarParams();
      try {
        _push(ident.funcA!(params));
      } catch (e) {
        _raiseError("Function error in ${ident.name}: $e");
      }
      return;
    }

    // fixed arguments
    _getParams(ident.pCount);

    try {
      final upper = name.toUpperCase();
      switch (ident.pCount) {
        case 0:
          _push(ident.func0!());
          break;
        case 1:
          final p1 = _pop();
          _push(ident.func1!(p1));
          break;
        case 2:
          final p2 = _pop();
          final p1 = _pop();
          if (upper == 'VAR') {
            setVar(varToStr(p1), p2);
            _push(getVar(varToStr(p1)));
          } else if (upper == 'INC') {
            final v = getVar(varToStr(p1));
            final newV = varToInt(v) + varToInt(p2);
            setVar(varToStr(p1), newV);
            _push(newV);
          } else if (upper == 'DEC') {
            final v = getVar(varToStr(p1));
            final newV = varToInt(v) - varToInt(p2);
            setVar(varToStr(p1), newV);
            _push(newV);
          } else {
            _push(ident.func2!(p1, p2));
          }
          break;
        case 3:
          final p3 = _pop();
          final p2 = _pop();
          final p1 = _pop();
          _push(ident.func3!(p1, p2, p3));
          break;
        case 4:
          final p4 = _pop();
          final p3 = _pop();
          final p2 = _pop();
          final p1 = _pop();
          _push(ident.func4!(p1, p2, p3, p4));
          break;
      }
    } catch (e) {
      _raiseError("Function error in ${ident.name}: $e");
    }
  }

  void _getParams(int n) {
    if (n <= 0) return;
    if (_token != ExprToken.lParen) {
      _raiseError("Left parenthesis expected");
      return;
    }
    var remaining = n;
    while (remaining > 0) {
      _nextToken();
      _parseExpression();
      remaining--;
      if (remaining > 0 && _token != ExprToken.comma) {
        _raiseError("List separator expected");
        return;
      }
    }
    if (_token != ExprToken.rParen) {
      _raiseError("Right parenthesis expected");
      return;
    }
    _nextToken();
  }

  List<dynamic> _collectVarParams() {
    final params = <dynamic>[];
    if (_token != ExprToken.lParen) return params;
    _nextToken();
    while (_token != ExprToken.rParen && _token != ExprToken.end_) {
      _parseExpression();
      params.add(_pop());
      if (_token == ExprToken.comma) _nextToken();
    }
    if (_token == ExprToken.rParen) _nextToken();
    // @@@ WapForm convention: array-like/variadic functions are always
    //     called with a single array literal, e.g. SumOfSquares([1,2,3]),
    //     SwitchValue([2,1,'One',2,'Two']). The loop above only looks at
    //     commas at the "outermost parenthesis" level; commas inside an
    //     array literal sit inside square brackets and don't get treated
    //     as separating multiple arguments, so only "one expression" (the
    //     whole array itself) gets parsed, landing in params as
    //     params=[[1,2,3]] -- the array was never unpacked, and the
    //     function received "one element, which is an array" instead of
    //     "three elements". This adds: when there's exactly one argument
    //     and it's itself a List, unpack it into genuinely multiple values.
    if (params.length == 1 && params[0] is List) {
      return List<dynamic>.from(params[0] as List);
    }
    return params;
  }

  // ──────────────────────────────────────────────────────────────
  // AddInternalFunctions (corresponds to Pascal TmyParser.AddInternalFunctions)
  // ──────────────────────────────────────────────────────────────

  /// Registers the built-in function library.
  void addInternalFunctions() {
    // encryption / decryption
    addFunction2Param("ENCRYPT", encrypt);
    addFunction2Param("DECRYPT", decrypt);

    // ── Date/time ────────────────────────────────────────────────
    addFunction0Param("NOW", fnNOW);
    addFunction0Param("yesterday", fnYesterday);
    addFunction0Param("last-night", fnLastNight);
    addFunction0Param("last-month", fnLastMonth);
    addFunction0Param("last-week", fnLastWeek);
    addFunction0Param("last-year", fnLastYear);
    addFunction0Param("DATE", fnDATE);
    addFunction1Param("DAY", fnDAY);
    addFunction1Param("DAYOFMONTH", fnDAYOFMONTH);
    addFunction1Param("DAYOFWEEK", fnDAYOFWEEK);
    addFunction1Param("DAYOFYEAR", fnDAYOFYEAR);
    addFunction2Param("DaysInAMonth", fnDaysInAMonth);
    addFunction1Param("HOUR", fnHOUR);
    addFunction1Param("MINUTE", fnMINUTE);
    addFunction1Param("MONTH", fnMONTH);
    addFunction1Param("SECOND", fnSECOND);
    addFunction0Param("TIME", fnTIME);
    addFunction0Param("TODAY", fnTODAY);
    addFunction1Param("WEEK", fnWEEK);
    addFunction1Param("YEAR", fnYEAR);

    // ── String processing ────────────────────────────────────────────────
    addFunction1Param("ASC", fnAsc);
    addFunction1Param("ANSI", fnANSI);
    addFunction1Param("UTF8", fnUTF8);
    addFunction3Param("AnsiDelete", fnAnsiDelete);
    addFunction3Param("AnsiInsert", fnAnsiInsert);
    addFunction1Param("AnsiLength", fnAnsiLength);
    addFunction3Param("AnsiMid", fnAnsiMid);
    addFunction2Param("AnsiPos", fnAnsiPos);
    addFunction1Param("CHR", fnCHR);
    addFunction1Param("CHAR", fnCHR);
    addFunction1Param("CODE", fnCODE);
    addFunction3Param("DELETE", fnDELETE);
    addFunction3Param("DEL", fnDELETE);
    addFunction3Param("DELA", fnAnsiDelete);
    addFunction3Param("DELB", fnAnsiDelete);
    addFunction2Param("FIND", fnPOS);
    addFunction2Param("FINDA", fnAnsiPos);
    addFunction2Param("FINDB", fnAnsiPos);
    addFunction2Param("FORMAT", fnFORMAT);
    addFunction2Param("FormatDateTime", fnFormatDateTime);
    addFunction2Param("FormatFloat", fnFormatFloat);
    addFunction2Param("HEX", fnHex);
    addFunction3Param("INSERT", fnINSERT);
    addFunction3Param("INS", fnINSERT);
    addFunction3Param("INSA", fnAnsiInsert);
    addFunction3Param("INSB", fnAnsiInsert);
    addFunction1Param("LEN", fnLENGTH);
    addFunction1Param("LENA", fnAnsiLength);
    addFunction1Param("LENB", fnAnsiLength);
    addFunction1Param("LENGTH", fnLENGTH);
    addFunction1Param("LOWER", fnLOWER);
    addFunction1Param("LTRIM", fnLTRIM);
    addFunction3Param("MID", fnMID);
    addFunction3Param("MIDA", fnAnsiMid);
    addFunction3Param("MIDB", fnAnsiMid);
    addFunction2Param("POS", fnPOS);
    addFunction3Param("REPLACE", fnREPLACE);
    addFunction3Param("REPLACEA", fnREPLACE);
    addFunction3Param("REPLACEB", fnREPLACE);
    addFunction3Param("REPLACEAT", fnReplaceAt);
    addFunction2Param("REPT", (v1, v2) => varToStr(v1) * varToInt(v2));
    addFunction1Param("RTRIM", fnRTRIM);
    addFunction1Param("TRIM", fnTRIM);
    addFunction1Param("TrimLeft", fnTrimLeft);
    addFunction1Param("TrimRight", fnTrimRight);
    addFunction1Param("UPPER", fnUPPER);
    addFunction1Param("UPPERA", fnUPPERA);
    addFunction2Param("AnsiCompareStr", fnAnsiCompareStr);
    addFunction2Param("AnsiCompareText", fnAnsiCompareText);
    addFunction1Param("AnsiLowerCase", fnAnsiLowerCase);
    addFunction1Param("AnsiUpperCase", fnAnsiUpperCase);
    addFunction2Param("CompareStr", fnCompareStr);
    addFunction2Param("CompareText", fnCompareText);
    addFunction3Param("COPY", fnCOPY);
    addFunction3Param("COPYB", fnCOPY);
    addFunction2Param("INSTR", fnINSTR);
    addFunction2Param("LOCATE", fnLOCATE);
    addFunction2Param("LIKE", fnLIKE);
    addFunction1Param("STR", fnSTR);
    addFunction1Param("VarToStr", fnVarToStr);
    addFunction1Param("IntToStr", fnIntToStr);
    addFunction1Param("FloatToStr", fnFloatToStr);
    addFunction1Param("StrToInt", fnStrToInt);
    addFunction1Param("StrToFloat", fnStrToFloat);
    addFunction1Param("StrToDate", fnStrToDate);
    addFunction1Param("StrToDateTime", fnStrToDateTime);
    addFunction1Param("StrToTime", fnStrToTime);
    addFunction3Param("DateSerialValue", fnDateSerialValue);
    addFunction3Param("TimeSerialValue", fnTimeSerialValue);
    addFunction1Param("StrToHex", fnStrToHex);
    addFunction1Param("HexToStr", fnHexToStr);
    addFunction2Param("IntToHex", fnIntToHex);
    addFunction1Param("HexToInt", fnHexToInt);
    addFunction1Param("ColorToHex", fnColorToHex);
    addFunction1Param("HexToColor", fnHexToColor);
    addFunction1Param("HTML", fnHTML);
    addFunction2Param("LEADBYTE", fnLeadByte);
    addFunction2Param("LEADBYTEB", fnLeadByte);

    // ── Numeric ────────────────────────────────────────────────────
    addFunction1Param("ABS", fnAbs);
    addFunction1Param("CEIL", fnCeil);
    addFunction1Param("FLOOR", fnFloor);
    addFunction1Param("FRAC", fnFrac);
    addFunction1Param("TRUNC", fnTrunc);
    addFunction1Param("INT", fnInt);
    addFunction1Param("float", fnFloat);
    addFunction1Param("SQR", fnSqr);
    addFunction1Param("SQRT", fnSqrt);
    addFunction1Param("EXP", fnExp);
    addFunction1Param("LN", fnLn);
    addFunction2Param("POWER", fnPower);
    addFunction1Param("SIN", fnSin);
    addFunction1Param("COS", fnCos);
    addFunction1Param("TAN", fnTan);
    addFunction1Param("ArcSin", fnArcSin);
    addFunction1Param("ArcCos", fnArcCos);
    addFunction1Param("ArcTan", fnArcTan);
    addFunction0Param("Pi", fnPi);
    addFunctionAParam(
        "Round",
        (args) => args.length >= 2
            ? fnRoundTo(args[0], args[1])
            : fnRound(args.isNotEmpty ? args[0] : 0));
    addFunction2Param("RoundTo", fnRoundTo);
    addFunction1Param("Odd", fnOdd);
    addFunction2Param("MAX", fnMax);
    addFunction2Param("MIN", fnMin);
    addFunction1Param("Random", fnRandom);
    addFunction2Param("RandomRange", fnRandomRange);

    // ── Type ────────────────────────────────────────────────────
    addFunction1Param("Assigned", fnAssigned);
    addFunction1Param("ISEVEN", fnISSEVEN);
    addFunction1Param("ISODD", fnISODD);
    addFunction1Param("ISNULL", fnISNULL);
    addFunction1Param("ISNUMBER", fnISNUMBER);
    addFunction1Param("ISTEXT", (v) => v is String);
    addFunction1Param("DEFINE", fnDEFINE);
    addFunction1Param("VarIsNull", fnVarIsNull);
    addFunction1Param("VarType", fnVarType);
    addFunction1Param("TYPENAME", extTYPENAME);

    // ── Logic ────────────────────────────────────────────────────
    addFunction0Param("TRUE", fnTRUE);
    addFunction0Param("FALSE", fnFALSE);
    addFunction0Param("NULL", fnNULL);
    addFunction0Param("NBSP", fnNBSP);
    addFunction0Param("DBX", fnDBX);
    addFunction0Param("NTIER", fnDBX);

    // ── Date helpers ────────────────────────────────────────────────
    addFunction1Param("DateTimeToStr", fnDateTimeToStr);
    addFunction1Param("DateToStr", fnDateToStr);
    addFunction1Param("TimeToStr", fnTimeToStr);
    addFunction1Param("MyDate", fnMyDate);
    addFunction1Param("MyDateTime", fnMyDateTime);
    addFunction0Param("TDATE", fnTDATE);
    addFunction1Param("BDATE", fnBDATE);
    addFunction1Param("IsLeapYear", fnIsLeapYear);
    addFunction1Param("ISWEEKEND", extISWEEKEND);
    addFunction1Param("ISWEEKDAY", extISWEEKDAY);

    // ── Misc ────────────────────────────────────────────────────
    addFunction1Param("MD5", fnMD5);
    addFunction1Param("GetUrlContent", fnGetUrlContent);
    addFunction0Param("GetFreeRes", fnGetFreeRes);
    addFunction0Param("GetPhysMem", fnGetPhysMem);
    addFunction0Param("GetMacPhysicalAddress", fnGetMacPhysicalAddress);
    addFunction0Param("CPU", fnCPU);
    addFunction0Param("loCaseInsensitive", fnLoCaseInsensitive);
    addFunction0Param("loPartialKey", fnLoPartialKey);
    addFunction1Param("NAME", fnNAME);
    addFunction1Param("VALUE", fnVALUE);
    addFunction1Param("ARRAY", fnARRAY);
    addFunction2Param("CELL", fnCELL);
    addFunction2Param("img", fnImg);
    addFunction1Param("ExtractFilePath", fnExtractFilePath);
    addFunction1Param("ExtractFileDir", fnExtractFileDir);
    addFunction1Param("ExtractFileDrive", fnExtractFileDrive);
    addFunction1Param("ExtractFileName", fnExtractFileName);
    addFunction1Param("ExtractFileNameNoExt", fnExtractFileNameNoExt);
    addFunction1Param("ExtractFileExt", fnExtractFileExt);
    addFunction2Param("INC", fnINCVal);
    addFunction2Param("dec", fnDECVal);

    // ── IIF ─────────────────────────────────────────────────────
    addFunction3Param("IIF", iif);
    addFunction3Param("IF", iif);

    // ============================================================
    // Extended function library V1.3
    // ============================================================

    // String — advanced
    addFunction2Param("PADL", extPADL);
    addFunction2Param("PADR", extPADR);
    addFunction2Param("PADC", extPADC);
    addFunction3Param("LPAD", extLPAD);
    addFunction3Param("RPAD", extRPAD);
    addFunction2Param("REPEAT", extREPEAT);
    addFunction2Param("COUNTSTR", extCOUNTSTR);
    addFunction2Param("STARTSWITH", extSTARTSWITH);
    addFunction2Param("ENDSWITH", extENDSWITH);
    addFunction2Param("CONTAINS", extCONTAINS);
    addFunction2Param("WRAP", extWRAP);

    // String — numeric formatting
    addFunction2Param("ZFILL", extZFILL);
    addFunction2Param("NUMFMT", extNUMFMT);
    addFunction1Param("COMMAFMT", extCOMMAFMT);

    // Math — advanced
    addFunction2Param("GCD", extGCD);
    addFunction2Param("LCM", extLCM);
    addFunction3Param("CLAMP", extCLAMP);
    addFunction3Param("LERP", extLERP);
    addFunction3Param("BETWEEN", extBETWEEN);
    addFunction2Param("PERCENT", extPERCENT);
    addFunction2Param("ROUNDBANK", extROUNDBANK);

    // Date — advanced
    addFunction3Param("DATEADD", extDATEADD);
    addFunction3Param("DATEDIFF", extDATEDIFF);
    addFunction2Param("DATESTART", extDATESTART);
    addFunction2Param("DATEEND", extDATEEND);
    addFunction2Param("WORKDAYS", extWORKDAYS);
    addFunction1Param("QUARTER", extQUARTER);
    addFunction1Param("RDATE", extRDATE);
    addFunction1Param("RDATETIME", extRDATETIME);

    // Type checking / safe conversion
    addFunction2Param("NVL", extNVL);
    addFunction3Param("NVL2", extNVL2);
    addFunctionAParam("COALESCE", extCOALESCE);
    addFunction1Param("TOINT", extTOINT);
    addFunction1Param("TOFLOAT", extTOFLOAT);
    addFunction1Param("TODATE", extTODATE);

    // Logic / control flow
    addFunctionAParam("SWITCH", extSWITCH);
    addFunctionAParam("DECODE", extDECODE);

    // ============================================================
    // Extended function library V1.4
    // ============================================================

    // String, advanced
    addFunction3Param("SPLIT", extSPLIT);
    addFunction2Param("JOIN", extJOIN);
    addFunction2Param("ELLIPSIS", extELLIPSIS);
    addFunction3Param("INDEXOF", extINDEXOF);
    addFunction2Param("LASTINDEXOF", extLASTINDEXOF);
    addFunction3Param("MASK", extMASK);
    addFunction3Param("UNMASK", extUNMASK);
    addFunction1Param("SLUGIFY", extSLUGIFY);
    addFunction1Param("CRLF2BR", extCRLF2BR);
    addFunction1Param("BR2CRLF", extBR2CRLF);
    addFunction1Param("HTMLENCODE", extHTMLENCODE);
    addFunction1Param("HTMLDECODE", extHTMLDECODE);
    addFunction1Param("URLENCODE", extURLENCODE);

    // Math, advanced
    addFunction1Param("ISPRIME", extISPRIME);
    addFunction1Param("FIB", extFIB);
    addFunction1Param("LOG2", extLOG2);
    addFunction2Param("LOGN", extLOGN);
    addFunction2Param("HYPOT", extHYPOT);
    addFunction1Param("DEG2RAD", extDEG2RAD);
    addFunction1Param("RAD2DEG", extRAD2DEG);
    addFunction1Param("CBRT", extCBRT);
    addFunction1Param("EVEN", extEVEN);
    addFunctionAParam("SUMSQ", extSUMSQ);
    addFunctionAParam("PRODUCT", extPRODUCT);
    addFunctionAParam("HARMEAN", extHARMEAN);
    addFunctionAParam("GEOMEAN", extGEOMEAN);
    addFunctionAParam("QUARTILE", extQUARTILE);
    addFunctionAParam("NPV", extNPV);
    addFunctionAParam("IRR", extIRR);

    // Date, advanced
    addFunction2Param("NEXTWDAY", extNEXTWDAY);
    addFunction2Param("PREVWDAY", extPREVWDAY);
    addFunction2Param("YEARFRAC", extYEARFRAC);
    addFunction2Param("AGE", extAGE);
    addFunction1Param("MONTHNAME", extMONTHNAME);
    addFunction3Param("DATESERIAL", extDATESERIAL);
    addFunction3Param("TIMESERIAL", extTIMESERIAL);

    // Array / collection
    addFunctionAParam("ARRJOIN", extARRJOIN);
    addFunctionAParam("ARRMAX", extARRMAX);
    addFunctionAParam("ARRMIN", extARRMIN);
    addFunctionAParam("ARRSUM", extARRSUM);
    addFunctionAParam("ARRAVG", extARRAVG);
    addFunctionAParam("ARRCONTAINS", extARRCONTAINS);
    addFunctionAParam("ARRUNIQ", extARRUNIQ);
    addFunctionAParam("CHOOSE", extCHOOSE);

    // System / misc
    addFunction0Param("GUID", extGUID);
    addFunction2Param("RANDOMSTR", extRANDOMSTR);
    addFunction1Param("TOHEX", extTOHEX);
    addFunction2Param("TOBIN", extTOBIN);
    addFunction1Param("FROMBIN", extFROMBIN);
    addFunction2Param("BITOR", extBITOR);
    addFunction2Param("BITAND", extBITAND);
    addFunction2Param("BITXOR", extBITXOR);
    addFunction1Param("BITNOT", extBITNOT);
    addFunction2Param("BITSHL", extBITSHL);
    addFunction2Param("BITSHR", extBITSHR);
    addFunction1Param("BYTESIZE", extBYTESIZE);
    addFunction1Param("HASH", extHASH);
    addFunction1Param("CHECKSUM", extCHECKSUM);

    // Finance, advanced
    addFunction3Param("PMT", extPMT);
    addFunction3Param("PV", extPV);
    addFunction4Param("FV", extFV);
    addFunction3Param("NPER", extNPER);
    addFunction3Param("RATE", extRATE);
    addFunction4Param("IPMT", extIPMT);
    addFunction4Param("PPMT", extPPMT);
    addFunctionAParam("CUMIPMT", extCUMIPMT);

    // AsXxx series
    addFunction1Param("AsString", extAsString);
    addFunction1Param("AsDate", extAsDate);
    addFunction1Param("AsTime", extAsTime);
    addFunction1Param("AsDateTime", extAsDateTime);
    addFunction2Param("AsPct", extAsPct);
    addFunction2Param("AsSci", extAsSci);
    addFunction1Param("AsYN", extAsYN);
    addFunction1Param("AsTF", extAsTF);
    addFunction1Param("As10", extAs10);
    addFunction1Param("AsOct", extAsOct);
    addFunction1Param("AsISO", extAsISO);
    addFunction1Param("AsRDate", extAsRDate);
    addFunction1Param("AsRDateTime", extAsRDateTime);

    // ============================================================
    // Standard intrinsic functions
    // ============================================================

    addFunction1Param("EXP10", stdEXP10);
    addFunction1Param("LOG10", stdLOG10);
    addFunction2Param("MOD", stdMOD);
    addFunction2Param("REM", stdREM);
    addFunction1Param("INTEGER", stdINTEGER);
    addFunction1Param("INTEGER_PART", stdINTEGER_PART);
    addFunction1Param("FRACTION_PART", stdFRACTION_PART);
    addFunction0Param("E", stdE);
    addFunction1Param("SIGN", stdSIGN);
    addFunctionAParam("PRESENT_VALUE", stdPRESENT_VALUE);
    addFunctionAParam("MEAN", stdMEAN);
    addFunctionAParam("MEDIAN", stdMEDIAN);
    addFunctionAParam("MIDRANGE", stdMIDRANGE);
    addFunctionAParam("RANGE", stdRANGE);
    addFunctionAParam("SUM", stdSUM);
    addFunctionAParam("VARIANCE", stdVARIANCE);
    addFunctionAParam("STANDARD_DEVIATION", stdSTANDARD_DEVIATION);
    addFunctionAParam("ORD_MAX", stdORD_MAX);
    addFunctionAParam("ORD_MIN", stdORD_MIN);
    addFunction1Param("HIGHEST_ALGEBRAIC", stdHIGHEST_ALGEBRAIC);
    addFunction1Param("LOWEST_ALGEBRAIC", stdLOWEST_ALGEBRAIC);
    addFunctionAParam("CONCATENATE", stdCONCATENATE);
    addFunction1Param("BYTE_LENGTH", stdBYTE_LENGTH);
    addFunction1Param("STORED_CHAR_LENGTH", stdSTORED_CHAR_LENGTH);
    addFunction1Param("LOWER_CASE", stdLOWER_CASE);
    addFunction1Param("UPPER_CASE", stdUPPER_CASE);
    addFunction1Param("REVERSE", stdREVERSE);
    addFunctionAParam("SUBSTITUTE", stdSUBSTITUTE);
    addFunctionAParam("SUBSTITUTE_CASE", stdSUBSTITUTE_CASE);
    addFunction2Param("NUMVAL_C", stdNUMVAL_C);
    addFunction1Param("NUMVAL_F", stdNUMVAL_F);
    addFunction1Param("TEST_NUMVAL", stdTEST_NUMVAL);
    addFunction2Param("TEST_NUMVAL_C", stdTEST_NUMVAL_C);
    addFunction1Param("TEST_NUMVAL_F", stdTEST_NUMVAL_F);
    addFunction0Param("CURRENT_DATE", stdCURRENT_DATE);
    addFunction0Param("WHEN_COMPILED", stdWHEN_COMPILED);
    addFunction1Param("DATE_OF_INTEGER", stdDATE_OF_INTEGER);
    addFunction1Param("INTEGER_OF_DATE", stdINTEGER_OF_DATE);
    addFunction1Param("DAY_OF_INTEGER", stdDAY_OF_INTEGER);
    addFunction1Param("INTEGER_OF_DAY", stdINTEGER_OF_DAY);
    addFunction0Param("SECONDS_PAST_MIDNIGHT", stdSECONDS_PAST_MIDNIGHT);
    addFunction2Param("COMBINED_DATETIME", stdCOMBINED_DATETIME);
    addFunction2Param("DATE_TO_YYYYMMDD", stdDATE_TO_YYYYMMDD);
    addFunction2Param("YEAR_TO_YYYY", stdYEAR_TO_YYYY);
    addFunction1Param("TEST_DATE_YYYYMMDD", stdTEST_DATE_YYYYMMDD);
    addFunction1Param("TEST_DAY_YYYYDDD", stdTEST_DAY_YYYYDDD);
    addFunction1Param("LOCALE_DATE", stdLOCALE_DATE);
    addFunction1Param("LOCALE_TIME", stdLOCALE_TIME);
    addFunction2Param("LOCALE_COMPARE", stdLOCALE_COMPARE);
    addFunction0Param("CURRENCY_SYMBOL", stdCURRENCY_SYMBOL);
    addFunction0Param("MONETARY_DECIMAL_POINT", stdMONETARY_DECIMAL_POINT);
    addFunction0Param(
        "MONETARY_THOUSANDS_SEPARATOR", stdMONETARY_THOUSANDS_SEPARATOR);
    addFunction0Param("NUMERIC_DECIMAL_POINT", stdNUMERIC_DECIMAL_POINT);
    addFunction0Param(
        "NUMERIC_THOUSANDS_SEPARATOR", stdNUMERIC_THOUSANDS_SEPARATOR);
    addFunction2Param("BOOLEAN_OF_INTEGER", stdBOOLEAN_OF_INTEGER);
    addFunction1Param("INTEGER_OF_BOOLEAN", stdINTEGER_OF_BOOLEAN);
    addFunction2Param("STANDARD_COMPARE", stdSTANDARD_COMPARE);

    // ── WML function aliases ────────────────────────────────
    // The function names WML uses differ from the registered names; aliases are filled in here
    addFunction1Param("ACOS", fnArcCos);
    addFunction1Param("ASIN", fnArcSin);
    addFunction1Param("ATAN", fnArcTan);
    addFunction0Param("PI", fnPi);
    addFunction2Param("RAND", fnRandomRange);
    // ROUND and Round are case-insensitive; Round is registered as a FuncA, ROUND inherits it automatically
    addFunction1Param("VAL", fnStrToFloat);
    addFunction1Param("COLOR2HEX", fnColorToHex);
    addFunction1Param("HEX2COLOR", fnHexToColor);
    addFunction1Param("DATE2STR", fnDateToStr);
    addFunction1Param("DATETIME2STR", fnDateTimeToStr);
    addFunction1Param("TIME2STR", fnTimeToStr);
    addFunction1Param("STR2DATE", fnStrToDate);
    addFunction1Param("STR2DATETIME", fnStrToDateTime);
    addFunction1Param("STR2TIME", fnStrToTime);
    addFunction2Param("INT2HEX", fnIntToHex);
    addFunction1Param("HEX2INT", fnHexToInt);
    addFunction1Param("HEX2STR", fnHexToStr);
    addFunction1Param("STR2HEX", fnStrToHex);
    addFunction1Param("DAYNAME", extDAYNAME);
    addFunction1Param("LOWERA", fnLOWER);
    addFunction1Param("UPPERA", fnUPPER);
    addFunction1Param("LENA", fnAnsiLength);
    addFunction3Param("MIDA", fnAnsiMid);
    // VAR is handled specially in _callFunction; it needs a placeholder so findIdent can find it
    addFunction2Param("VAR", (v1, v2) => v2);

    // ══════════════════════════════════════════════════════════════
    // Adds functions that were never registered before (gaps found by
    // cross-referencing the self-test report). Most of the underlying
    // logic already exists among the extended functions -- this just adds the
    // official names the test cases expect; a few extended versions return a
    // DateTime instead of a Delphi numeric serial, so those use the new
    // wrapper functions above instead; logic that was genuinely entirely
    // missing was written fresh.
    // ══════════════════════════════════════════════════════════════

    // -- String functions --
    addFunction2Param("LeftPad2", extPADL);
    // 1.6.x compatibility: prefixed names (removed in 2.0.0)
    addFunction1Param("COB_ABS", COB_ABS);
    addFunction1Param("COB_ACOS", COB_ACOS);
    addFunction2Param("COB_ANNUITY", COB_ANNUITY);
    addFunction1Param("COB_ASIN", COB_ASIN);
    addFunction1Param("COB_ATAN", COB_ATAN);
    addFunction2Param("COB_BOOLEAN_OF_INTEGER", COB_BOOLEAN_OF_INTEGER);
    addFunction1Param("COB_BYTE_LENGTH", COB_BYTE_LENGTH);
    addFunction1Param("COB_CHAR", COB_CHAR);
    addFunction2Param("COB_COMBINED_DATETIME", COB_COMBINED_DATETIME);
    addFunctionAParam("COB_CONCATENATE", COB_CONCATENATE);
    addFunction1Param("COB_COS", COB_COS);
    addFunction0Param("COB_CURRENCY_SYMBOL", COB_CURRENCY_SYMBOL);
    addFunction0Param("COB_CURRENT_DATE", COB_CURRENT_DATE);
    addFunction1Param("COB_DATE_OF_INTEGER", COB_DATE_OF_INTEGER);
    addFunction2Param("COB_DATE_TO_YYYYMMDD", COB_DATE_TO_YYYYMMDD);
    addFunction1Param("COB_DAY_OF_INTEGER", COB_DAY_OF_INTEGER);
    addFunction0Param("COB_E", COB_E);
    addFunction1Param("COB_EXP", COB_EXP);
    addFunction1Param("COB_EXP10", COB_EXP10);
    addFunction1Param("COB_FACTORIAL", COB_FACTORIAL);
    addFunction1Param("COB_FRACTION_PART", COB_FRACTION_PART);
    addFunction1Param("COB_HIGHEST_ALGEBRAIC", COB_HIGHEST_ALGEBRAIC);
    addFunction1Param("COB_INTEGER", COB_INTEGER);
    addFunction1Param("COB_INTEGER_OF_BOOLEAN", COB_INTEGER_OF_BOOLEAN);
    addFunction1Param("COB_INTEGER_OF_DATE", COB_INTEGER_OF_DATE);
    addFunction1Param("COB_INTEGER_OF_DAY", COB_INTEGER_OF_DAY);
    addFunction1Param("COB_INTEGER_PART", COB_INTEGER_PART);
    addFunction1Param("COB_LENGTH", COB_LENGTH);
    addFunction2Param("COB_LOCALE_COMPARE", COB_LOCALE_COMPARE);
    addFunction1Param("COB_LOCALE_DATE", COB_LOCALE_DATE);
    addFunction1Param("COB_LOCALE_TIME", COB_LOCALE_TIME);
    addFunction1Param("COB_LOG", COB_LOG);
    addFunction1Param("COB_LOG10", COB_LOG10);
    addFunction1Param("COB_LOWER_CASE", COB_LOWER_CASE);
    addFunction1Param("COB_LOWEST_ALGEBRAIC", COB_LOWEST_ALGEBRAIC);
    addFunctionAParam("COB_MAX", COB_MAX);
    addFunctionAParam("COB_MEAN", COB_MEAN);
    addFunctionAParam("COB_MEDIAN", COB_MEDIAN);
    addFunctionAParam("COB_MIDRANGE", COB_MIDRANGE);
    addFunctionAParam("COB_MIN", COB_MIN);
    addFunction2Param("COB_MOD", COB_MOD);
    addFunction0Param("COB_MONETARY_DECIMAL_POINT", COB_MONETARY_DECIMAL_POINT);
    addFunction0Param("COB_NUMERIC_DECIMAL_POINT", COB_NUMERIC_DECIMAL_POINT);
    addFunction1Param("COB_NUMVAL", COB_NUMVAL);
    addFunction2Param("COB_NUMVAL_C", COB_NUMVAL_C);
    addFunction1Param("COB_NUMVAL_F", COB_NUMVAL_F);
    addFunction1Param("COB_ORD", COB_ORD);
    addFunctionAParam("COB_ORD_MAX", COB_ORD_MAX);
    addFunctionAParam("COB_ORD_MIN", COB_ORD_MIN);
    addFunction0Param("COB_PI", COB_PI);
    addFunctionAParam("COB_PRESENT_VALUE", COB_PRESENT_VALUE);
    addFunction1Param("COB_RANDOM", COB_RANDOM);
    addFunctionAParam("COB_RANGE", COB_RANGE);
    addFunction2Param("COB_REM", COB_REM);
    addFunction1Param("COB_REVERSE", COB_REVERSE);
    addFunction0Param("COB_SECONDS_PAST_MIDNIGHT", COB_SECONDS_PAST_MIDNIGHT);
    addFunction1Param("COB_SIGN", COB_SIGN);
    addFunction1Param("COB_SIN", COB_SIN);
    addFunction1Param("COB_SQRT", COB_SQRT);
    addFunction2Param("COB_STANDARD_COMPARE", COB_STANDARD_COMPARE);
    addFunctionAParam("COB_STANDARD_DEVIATION", COB_STANDARD_DEVIATION);
    addFunction1Param("COB_STORED_CHAR_LENGTH", COB_STORED_CHAR_LENGTH);
    addFunctionAParam("COB_SUBSTITUTE", COB_SUBSTITUTE);
    addFunctionAParam("COB_SUBSTITUTE_CASE", COB_SUBSTITUTE_CASE);
    addFunctionAParam("COB_SUM", COB_SUM);
    addFunction1Param("COB_TAN", COB_TAN);
    addFunction1Param("COB_TEST_DATE_YYYYMMDD", COB_TEST_DATE_YYYYMMDD);
    addFunction1Param("COB_TEST_DAY_YYYYDDD", COB_TEST_DAY_YYYYDDD);
    addFunction1Param("COB_TEST_NUMVAL", COB_TEST_NUMVAL);
    addFunction2Param("COB_TEST_NUMVAL_C", COB_TEST_NUMVAL_C);
    addFunction1Param("COB_TEST_NUMVAL_F", COB_TEST_NUMVAL_F);
    addFunction2Param("COB_TRIM", COB_TRIM);
    addFunction1Param("COB_UPPER_CASE", COB_UPPER_CASE);
    addFunctionAParam("COB_VARIANCE", COB_VARIANCE);
    addFunction0Param("COB_WHEN_COMPILED", COB_WHEN_COMPILED);
    addFunction2Param("COB_YEAR_TO_YYYY", COB_YEAR_TO_YYYY);
    addFunction2Param("tt_ADDWORKDAYS", tt_ADDWORKDAYS);
    addFunction2Param("tt_AGE", tt_AGE);
    addFunctionAParam("tt_ARRAVG", tt_ARRAVG);
    addFunctionAParam("tt_ARRCONTAINS", tt_ARRCONTAINS);
    addFunctionAParam("tt_ARRJOIN", tt_ARRJOIN);
    addFunctionAParam("tt_ARRMAX", tt_ARRMAX);
    addFunctionAParam("tt_ARRMIN", tt_ARRMIN);
    addFunctionAParam("tt_ARRSUM", tt_ARRSUM);
    addFunctionAParam("tt_ARRUNIQ", tt_ARRUNIQ);
    addFunction1Param("tt_As10", tt_As10);
    addFunction1Param("tt_AsBit", tt_AsBit);
    addFunction1Param("tt_AsBool", tt_AsBool);
    addFunctionAParam("tt_AsCsv", tt_AsCsv);
    addFunction2Param("tt_AsCurr", tt_AsCurr);
    addFunction1Param("tt_AsDQuoted", tt_AsDQuoted);
    addFunction1Param("tt_AsDate", tt_AsDate);
    addFunction1Param("tt_AsDateTime", tt_AsDateTime);
    addFunction2Param("tt_AsDefault", tt_AsDefault);
    addFunction2Param("tt_AsFixed", tt_AsFixed);
    addFunction1Param("tt_AsFloat", tt_AsFloat);
    addFunction2Param("tt_AsHex", tt_AsHex);
    addFunction1Param("tt_AsISO", tt_AsISO);
    addFunction1Param("tt_AsInt", tt_AsInt);
    addFunction1Param("tt_AsJson", tt_AsJson);
    addFunction1Param("tt_AsLower", tt_AsLower);
    addFunction1Param("tt_AsNullable", tt_AsNullable);
    addFunction1Param("tt_AsOct", tt_AsOct);
    addFunction2Param("tt_AsPct", tt_AsPct);
    addFunction1Param("tt_AsQuoted", tt_AsQuoted);
    addFunction1Param("tt_AsRDate", tt_AsRDate);
    addFunction1Param("tt_AsRDateTime", tt_AsRDateTime);
    addFunction1Param("tt_AsSQLStr", tt_AsSQLStr);
    addFunction2Param("tt_AsSci", tt_AsSci);
    addFunction1Param("tt_AsSlug", tt_AsSlug);
    addFunction1Param("tt_AsString", tt_AsString);
    addFunction1Param("tt_AsTF", tt_AsTF);
    addFunction1Param("tt_AsTime", tt_AsTime);
    addFunction1Param("tt_AsTrimmed", tt_AsTrimmed);
    addFunction1Param("tt_AsUpper", tt_AsUpper);
    addFunction1Param("tt_AsYN", tt_AsYN);
    addFunction3Param("tt_BETWEEN", tt_BETWEEN);
    addFunction2Param("tt_BITAND", tt_BITAND);
    addFunction1Param("tt_BITNOT", tt_BITNOT);
    addFunction2Param("tt_BITOR", tt_BITOR);
    addFunction2Param("tt_BITSHL", tt_BITSHL);
    addFunction2Param("tt_BITSHR", tt_BITSHR);
    addFunction2Param("tt_BITXOR", tt_BITXOR);
    addFunction2Param("tt_BOMDATE", tt_BOMDATE);
    addFunction1Param("tt_BR2CRLF", tt_BR2CRLF);
    addFunction1Param("tt_BYTESIZE", tt_BYTESIZE);
    addFunction1Param("tt_CAPWORDS", tt_CAPWORDS);
    addFunction1Param("tt_CBRT", tt_CBRT);
    addFunction2Param("tt_CHARAT", tt_CHARAT);
    addFunction1Param("tt_CHECKSUM", tt_CHECKSUM);
    addFunctionAParam("tt_CHOOSE", tt_CHOOSE);
    addFunction3Param("tt_CLAMP", tt_CLAMP);
    addFunctionAParam("tt_COALESCE", tt_COALESCE);
    addFunction1Param("tt_COMMAFMT", tt_COMMAFMT);
    addFunction2Param("tt_CONTAINS", tt_CONTAINS);
    addFunction2Param("tt_COUNTSTR", tt_COUNTSTR);
    addFunction1Param("tt_CRLF2BR", tt_CRLF2BR);
    addFunctionAParam("tt_CUMIPMT", tt_CUMIPMT);
    addFunction3Param("tt_DATEADD", tt_DATEADD);
    addFunction3Param("tt_DATEDIFF", tt_DATEDIFF);
    addFunction2Param("tt_DATEEND", tt_DATEEND);
    addFunction3Param("tt_DATESERIAL", tt_DATESERIAL);
    addFunction2Param("tt_DATESTART", tt_DATESTART);
    addFunction1Param("tt_DAYNAME", tt_DAYNAME);
    addFunctionAParam("tt_DECODE", tt_DECODE);
    addFunction1Param("tt_DEG2RAD", tt_DEG2RAD);
    addFunction2Param("tt_ELLIPSIS", tt_ELLIPSIS);
    addFunction2Param("tt_ENDSWITH", tt_ENDSWITH);
    addFunction2Param("tt_EOMDATE", tt_EOMDATE);
    addFunction1Param("tt_EVEN", tt_EVEN);
    addFunction1Param("tt_FIB", tt_FIB);
    addFunction2Param("tt_FISCALQUARTER", tt_FISCALQUARTER);
    addFunction2Param("tt_FISCALYEAR", tt_FISCALYEAR);
    addFunction1Param("tt_FROMBIN", tt_FROMBIN);
    addFunction1Param("tt_FROMHEX", tt_FROMHEX);
    addFunction4Param("tt_FV", tt_FV);
    addFunction2Param("tt_GCD", tt_GCD);
    addFunctionAParam("tt_GEOMEAN", tt_GEOMEAN);
    addFunction0Param("tt_GUID", tt_GUID);
    addFunctionAParam("tt_HARMEAN", tt_HARMEAN);
    addFunction1Param("tt_HASH", tt_HASH);
    addFunction1Param("tt_HTMLDECODE", tt_HTMLDECODE);
    addFunction1Param("tt_HTMLENCODE", tt_HTMLENCODE);
    addFunction2Param("tt_HYPOT", tt_HYPOT);
    addFunction3Param("tt_INDEXOF", tt_INDEXOF);
    addFunction4Param("tt_IPMT", tt_IPMT);
    addFunctionAParam("tt_IRR", tt_IRR);
    addFunction1Param("tt_ISPRIME", tt_ISPRIME);
    addFunction1Param("tt_ISWEEKDAY", tt_ISWEEKDAY);
    addFunction1Param("tt_ISWEEKEND", tt_ISWEEKEND);
    addFunction2Param("tt_JOIN", tt_JOIN);
    addFunction2Param("tt_KEEPCHARS", tt_KEEPCHARS);
    addFunction2Param("tt_LASTINDEXOF", tt_LASTINDEXOF);
    addFunction2Param("tt_LCM", tt_LCM);
    addFunction3Param("tt_LERP", tt_LERP);
    addFunction1Param("tt_LOG2", tt_LOG2);
    addFunction2Param("tt_LOGN", tt_LOGN);
    addFunction3Param("tt_LPAD", tt_LPAD);
    addFunction3Param("tt_MASK", tt_MASK);
    addFunction1Param("tt_MONTHNAME", tt_MONTHNAME);
    addFunction2Param("tt_NEXTWDAY", tt_NEXTWDAY);
    addFunction3Param("tt_NPER", tt_NPER);
    addFunctionAParam("tt_NPV", tt_NPV);
    addFunction2Param("tt_NUMFMT", tt_NUMFMT);
    addFunction2Param("tt_NVL", tt_NVL);
    addFunction3Param("tt_NVL2", tt_NVL2);
    addFunction1Param("tt_ODD", tt_ODD);
    addFunction1Param("tt_ONLYALPHA", tt_ONLYALPHA);
    addFunction1Param("tt_ONLYDIGITS", tt_ONLYDIGITS);
    addFunction2Param("tt_PADC", tt_PADC);
    addFunction2Param("tt_PADL", tt_PADL);
    addFunction2Param("tt_PADR", tt_PADR);
    addFunction2Param("tt_PERCENT", tt_PERCENT);
    addFunction3Param("tt_PMT", tt_PMT);
    addFunction4Param("tt_PPMT", tt_PPMT);
    addFunction2Param("tt_PREVWDAY", tt_PREVWDAY);
    addFunctionAParam("tt_PRODUCT", tt_PRODUCT);
    addFunction3Param("tt_PV", tt_PV);
    addFunction1Param("tt_QUARTER", tt_QUARTER);
    addFunctionAParam("tt_QUARTILE", tt_QUARTILE);
    addFunction1Param("tt_RAD2DEG", tt_RAD2DEG);
    addFunction2Param("tt_RANDOMSTR", tt_RANDOMSTR);
    addFunction3Param("tt_RATE", tt_RATE);
    addFunction1Param("tt_RDATE", tt_RDATE);
    addFunction1Param("tt_RDATETIME", tt_RDATETIME);
    addFunction2Param("tt_REMOVECHARS", tt_REMOVECHARS);
    addFunction2Param("tt_REPEAT", tt_REPEAT);
    addFunction2Param("tt_ROUNDBANK", tt_ROUNDBANK);
    addFunction3Param("tt_RPAD", tt_RPAD);
    addFunction1Param("tt_SLUGIFY", tt_SLUGIFY);
    addFunction3Param("tt_SPLIT", tt_SPLIT);
    addFunction2Param("tt_SPLITCOUNT", tt_SPLITCOUNT);
    addFunction2Param("tt_STARTSWITH", tt_STARTSWITH);
    addFunctionAParam("tt_SUMSQ", tt_SUMSQ);
    addFunctionAParam("tt_SWITCH", tt_SWITCH);
    addFunction3Param("tt_TIMESERIAL", tt_TIMESERIAL);
    addFunction2Param("tt_TOBIN", tt_TOBIN);
    addFunction1Param("tt_TODATE", tt_TODATE);
    addFunction1Param("tt_TOFLOAT", tt_TOFLOAT);
    addFunction1Param("tt_TOHEX", tt_TOHEX);
    addFunction1Param("tt_TOINT", tt_TOINT);
    addFunction3Param("tt_TOKENAT", tt_TOKENAT);
    addFunction2Param("tt_TRUNCWORDS", tt_TRUNCWORDS);
    addFunction1Param("tt_TYPENAME", tt_TYPENAME);
    addFunction3Param("tt_UNMASK", tt_UNMASK);
    addFunction1Param("tt_URLENCODE", tt_URLENCODE);
    addFunction2Param("tt_WORKDAYS", tt_WORKDAYS);
    addFunction2Param("tt_WRAP", tt_WRAP);
    addFunction2Param("tt_YEARFRAC", tt_YEARFRAC);
    addFunction2Param("tt_ZFILL", tt_ZFILL);
    addFunction2Param("RightPad2", extPADR);
    addFunction2Param("CenterPad", extPADC);
    addFunction3Param("LeftPad", extLPAD);
    addFunction3Param("RightPad", extRPAD);
    addFunction2Param("RepeatStr", extREPEAT);
    addFunction2Param("CountStrOccur", extCOUNTSTR);
    addFunction2Param("StartsWithStr", extSTARTSWITH);
    addFunction2Param("EndsWithStr", extENDSWITH);
    addFunction2Param("ContainsStr2", extCONTAINS);
    addFunction3Param("SplitStr", extSPLIT);
    addFunction2Param("SplitCount", extSPLITCOUNT);
    addFunction2Param("JoinStr", extJOIN);
    addFunction3Param("TokenAt", extTOKENAT);
    addFunction1Param("CapWords", extCAPWORDS);
    addFunction2Param("CharAt", extCHARAT);
    addFunction3Param("IndexOfStr", (v1, v2, v3) => extINDEXOF(v2, v1, v3));
    addFunction2Param("LastIndexOfStr", (v1, v2) => extLASTINDEXOF(v2, v1));
    addFunction2Param("RemoveChars", extREMOVECHARS);
    addFunction2Param("KeepChars", extKEEPCHARS);
    addFunction1Param("OnlyDigits", extONLYDIGITS);
    addFunction1Param("OnlyAlpha", extONLYALPHA);
    addFunction3Param("MaskStr", extMASK);
    addFunction3Param("UnmaskStr", extUNMASK);
    addFunction1Param("SlugifyStr", extSLUGIFY);
    addFunction1Param("HtmlEncodeStr", extHTMLENCODE);
    addFunction1Param("HtmlDecodeStr", extHTMLDECODE);
    addFunction1Param("UrlEncodeStr", extURLENCODE);
    addFunctionAParam("ConcatenateStr", fnConcatenateStr);
    addFunction1Param("StoredCharLength", fnStoredCharLength);
    addFunction1Param("LowerCaseValue", extAsLower);
    addFunction1Param("UpperCaseValue", extAsUpper);
    addFunction1Param("ReverseStr", fnReverseStr);
    addFunctionAParam("SubstituteStr", fnSubstituteStr);
    addFunctionAParam("SubstituteCaseStr", fnSubstituteCaseStr);
    addFunction1Param("AsQuoted", extAsQuoted);
    addFunction1Param("AsSqlStr", fnAsSqlStr);
    addFunction2Param("FillChar", fnFillChar);
    addFunction2Param("EllipsisStr", extELLIPSIS);
    addFunction2Param("TruncWords", extTRUNCWORDS);
    addFunction1Param("INT2STR", fnIntToStr);
    addFunction1Param("STR2FLOAT", fnStrToFloat);
    addFunction1Param("STR2INT", fnStrToInt);
    addFunction1Param("FLOAT2STR", fnFloatToStr);
    addFunction1Param("ByteLength", fnByteLength);

    // -- Math functions --
    addFunction1Param("FIX", fnFloor);
    addFunction2Param("GreatestCommonDivisor", extGCD);
    addFunction3Param("ClampValue", extCLAMP);
    addFunction3Param("LerpValue", extLERP);
    addFunction3Param("IsBetween", extBETWEEN);
    addFunction2Param("PercentOf", extPERCENT);
    addFunction2Param("RoundBankers", extROUNDBANK);
    addFunction1Param("IsPrimeNumber", extISPRIME);
    addFunction1Param("Fibonacci", extFIB);
    addFunction1Param("Log2Value", extLOG2);
    addFunction2Param("LogNValue", extLOGN);
    addFunction2Param("HypotOf", extHYPOT);
    addFunction1Param("DegreeToRad", extDEG2RAD);
    addFunction1Param("RadToDegree", extRAD2DEG);
    addFunction1Param("CubeRoot", extCBRT);
    addFunction1Param("EvenCeil", extEVEN);
    addFunctionAParam("SumOfSquares", extSUMSQ);
    addFunctionAParam("ProductOf", extPRODUCT);
    addFunctionAParam("HarmMeanValue", extHARMEAN);
    addFunctionAParam("GeoMeanValue", extGEOMEAN);
    addFunctionAParam("QuartileOf", extQUARTILE);
    addFunction1Param("Exp10Value", fnExp10Value);
    addFunction1Param("Log10Value", fnLog10Value);
    addFunction1Param("LOG", fnLog10Value);
    addFunction2Param("RemainderValue", fnRemainderValue);
    addFunction1Param("ToIntegerValue", fnToIntegerValue);
    addFunction1Param("IntegerPart", fnTrunc);
    addFunction1Param("FractionPart", fnFrac);
    addFunction1Param("Factorial", fnFactorial);
    addFunction0Param("EulerNumber", fnEulerNumber);
    addFunction1Param("SignOf", fnSignOf);
    addFunction2Param("Annuity", fnAnnuity);
    addFunctionAParam("PresentValue", extNPV);
    addFunctionAParam("MeanValue", fnMeanValue);
    addFunctionAParam("MedianValue", fnMedianValue);
    addFunctionAParam("MidRangeValue", fnMidRangeValue);
    addFunctionAParam("RangeValue", fnRangeValue);
    addFunctionAParam("SumOfValues", extARRSUM);
    addFunctionAParam("VarianceValue", fnVarianceValue);
    addFunctionAParam("StandardDeviation", fnStandardDeviation);
    addFunctionAParam("OrdMax", fnOrdMax);
    addFunctionAParam("OrdMin", fnOrdMin);
    addFunction1Param("HighestAlgebraic", fnHighestAlgebraic);
    addFunction1Param("LowestAlgebraic", fnLowestAlgebraic);
    addFunction1Param("Ord", fnOrd);

    // -- Date and time functions --
    addFunction3Param("DateDiffValue", extDATEDIFF);
    addFunction2Param("WorkDaysBetween", extWORKDAYS);
    addFunction1Param("QuarterOf", extQUARTER);
    addFunction1Param("RocDateOf", extRDATE);
    addFunction1Param("RocDateTimeOf", extRDATETIME);
    addFunction2Param("YearFraction", extYEARFRAC);
    addFunction2Param("CalcAge", extAGE);
    addFunction2Param("FiscalQuarter", extFISCALQUARTER);
    addFunction2Param("FiscalYear", extFISCALYEAR);
    addFunction2Param("DateToYyyymmdd", fnDateToYyyymmdd);
    addFunction2Param("YearToYyyy", fnYearToYyyy);
    addFunction1Param("TestDateYyyymmdd", fnTestDateYyyymmdd);
    addFunction1Param("TestDayYyyyddd", fnTestDayYyyyddd);
    addFunction2Param("AddWorkDays", fnAddWorkDaysSerial);
    addFunction2Param("BomDate", fnBomDateSerial);
    addFunction2Param("CombinedDateTime", fnCombinedDateTime);
    addFunction3Param("DateAddValue", fnDateAddValueSerial);
    addFunction1Param("DateOfInteger", fnDateOfInteger);
    addFunction2Param("DatePeriodEnd", fnDatePeriodEndSerial);
    addFunction2Param("DatePeriodStart", fnDatePeriodStartSerial);
    addFunction1Param("DayNameOf", extDAYNAME);
    addFunction1Param("DayOfInteger", fnDayOfInteger);
    addFunction2Param("EomDate", fnEomDateSerial);
    addFunction1Param("IntegerOfDate", fnIntegerOfDate);
    addFunction1Param("IntegerOfDay", fnIntegerOfDay);
    addFunction1Param("MonthNameOf", extMONTHNAME);
    addFunction2Param("NextWeekDay", fnNextWeekDaySerial);
    addFunction2Param("PrevWeekDay", fnPrevWeekDaySerial);

    // -- Conditional functions --
    addFunction2Param("NvlValue", extNVL);
    addFunctionAParam("CoalesceValue", extCOALESCE);
    addFunction1Param("ToIntSafe", fnToIntSafe);
    addFunction1Param("ToFloatSafe", fnToFloatSafe);
    addFunction1Param("TypeNameOf", extTYPENAME);
    addFunctionAParam("SwitchValue", extSWITCH);
    addFunctionAParam("DecodeValue", extDECODE);
    addFunction1Param("TYPE", fnVarType);
    addFunction3Param("Nvl2Value", extNVL2);

    // -- Encoding and conversion functions --
    addFunction2Param("ZeroFill", extZFILL);
    addFunction2Param("NumberFormat", extNUMFMT);
    addFunction1Param("CommaFormat", extCOMMAFMT);
    addFunction1Param("AsStringValue", extAsString);
    addFunction1Param("AsInt", extAsInt);
    addFunction1Param("AsFloat", extAsFloat);
    addFunction1Param("AsBool", extAsBool);
    addFunction2Param("AsFixed", extAsFixed);
    addFunction2Param("AsCurr", extAsCurr);
    addFunction2Param("AsPercent", extAsPct);
    addFunction2Param("AsScientific", extAsSci);
    addFunction1Param("AsYesNo", extAsYN);
    addFunction1Param("AsTrueFalse", extAsTF);
    addFunction1Param("AsZeroOne", extAs10);
    addFunction1Param("AsBit", extAsBit);
    addFunction2Param("AsHex", extAsHex);
    addFunction1Param("AsOctal", extAsOct);
    addFunction1Param("AsISO8601", extAsISO);
    addFunction1Param("AsRocDate", extAsRDate);
    addFunction1Param("AsRocDateTime", extAsRDateTime);
    addFunction1Param("AsSlug", extAsSlug);
    addFunction1Param("AsUpper", extAsUpper);
    addFunction1Param("AsLower", extAsLower);
    addFunction1Param("AsTrimmed", extAsTrimmed);
    addFunction1Param("AsDQuoted", extAsDQuoted);
    addFunction1Param("AsNullable", extAsNullable);
    addFunction2Param("AsDefault", extAsDefault);
    addFunction1Param("AsJson", extAsJson);
    addFunctionAParam("AsCsv", extAsCsv);
    addFunction1Param("NumVal", fnStrToFloat);
    addFunction2Param("NumValC", fnNumValC);
    addFunction1Param("NumValF", fnNumValF);
    addFunction1Param("TestNumVal", fnTestNumVal);
    addFunction2Param("TestNumValC", fnTestNumValC);
    addFunction1Param("TestNumValF", fnTestNumVal);

    // -- Other functions --
    addFunctionAParam("ArrayJoin", extARRJOIN);
    addFunctionAParam("ArrayMax", extARRMAX);
    addFunctionAParam("ArrayMin", extARRMIN);
    addFunctionAParam("ArraySum", extARRSUM);
    addFunctionAParam("ArrayAverage", extARRAVG);
    addFunctionAParam("ArrayContains", extARRCONTAINS);
    addFunctionAParam("ArrayUnique", extARRUNIQ);
    addFunctionAParam("ChooseValue", extCHOOSE);
    addFunction1Param("ToHexStr", extTOHEX);
    addFunction1Param("FromHex", extFROMHEX);
    addFunction2Param("ToBinary", extTOBIN);
    addFunction1Param("FromBinary", extFROMBIN);
    addFunction2Param("BitOrValue", extBITOR);
    addFunction2Param("BitAndValue", extBITAND);
    addFunction2Param("BitXorValue", extBITXOR);
    addFunction1Param("BitNotValue", extBITNOT);
    addFunction2Param("BitShiftLeft", extBITSHL);
    addFunction2Param("BitShiftRight", extBITSHR);
    addFunction1Param("ByteSizeOf", extBYTESIZE);
    addFunction1Param("CheckSumOf", extCHECKSUM);
    addFunction3Param("PaymentValue", extPMT);
    addFunction3Param("PresentValueOf", extPV);
    addFunction4Param("FutureValue", extFV);
    addFunction3Param("NumOfPeriods", extNPER);
    addFunction3Param("RateOf", extRATE);
    addFunction4Param("InterestPmt", extIPMT);
    addFunction4Param("PrincipalPmt", extPPMT);
    addFunction2Param("LocaleCompare", fnStandardCompare);
    addFunction0Param("CurrencySymbol", () => 'NT\$');
    addFunction0Param("MonetaryDecimalPoint", () => '.');
    addFunction0Param("MonetaryThousandsSeparator", () => ',');
    addFunction0Param("NumericDecimalPoint", () => '.');
    addFunction0Param("NumericThousandsSeparator", () => ',');
    addFunction2Param("BooleanOfInteger", extTOBIN);
    addFunction1Param("IntegerOfBoolean", extFROMBIN);
    addFunction2Param("StandardCompare", fnStandardCompare);
    addFunction1Param("HashOf", extHASH);
    addFunctionAParam("COUNT", fnCOUNT);
    addFunctionAParam("HIGH", fnHIGH);
    addFunctionAParam("LOW", fnLOW);
  }
}

// ══════════════════════════════════════════════════════════════════════════
// WapEvaluator — corresponds to WapForm's TCard.Expression / TCard.Condition
//
// Wraps MyParser, providing:
//   eval(expr)      → dynamic    corresponds to TCard.Expression(Str, false)
//   evalNul(expr)   → dynamic    corresponds to TCard.Expression(Str, true)  (Null mode)
//   cond(expr)      → bool       corresponds to TCard.Condition(Str)
//   setVar(k, v)    → void       sets a variable (syncs the datasource field)
//   getVar(k)       → dynamic    gets a variable
//   setRow(Map)     → void       sets a whole row of datasource fields at once
//
// Usage example:
//   final ev = WapEvaluator();
//   ev.setVar('sys.company', 'Taiwan Transcend Life');
//   ev.setVar('em.eno', '01');
//   print(ev.eval(r'$sys.company'));          // → 'Taiwan Transcend Life'
//   print(ev.cond("em.eno='01'"));           // → true
//   ev.setVar('i', 0);
//   while (ev.cond('i<6')) { ev.setVar('i', ev.eval('i+1')); }
//   print(ev.getVar('i'));                    // → 6
// ══════════════════════════════════════════════════════════════════════════
/// Evaluates WapForm expressions (WML `$(...)`, `cnd=`, `value=`).
///
/// Holds the variables of one card and nearly 600 built-in functions;
/// custom functions can be added with `addFunction*Param`. Comparisons on
/// both sides of `AND`/`OR` need parentheses: `(qty>0) AND (price<100)`.
class WapEvaluator {
  final MyParser _p = MyParser();

  // ── Corresponds to TCard.Expression(Str, N) ────────────────────────
  /// Evaluates the expression, returns the result. Returns null on failure and sets lastError.
  dynamic eval(String expr, {bool nul = false}) {
    if (expr.isEmpty) return null;
    lastError =
        ''; // clears the previous error before every evaluation (avoids a stale value causing a false hasError)
    _p.expression = expr;
    _p.nul = nul;
    if (_p.analyzeExpression()) return _p.value;
    lastError = '[ERROR] $expr # ${_p.error}';
    return null;
  }

  /// eval's Null mode (corresponds to Expression(Str, True))
  dynamic evalNul(String expr) => eval(expr, nul: true);

  // ── Corresponds to TCard.Condition(Str) ────────────────────────────
  /// Evaluates a condition expression, returns bool. Returns false on failure.
  bool cond(String expr) {
    if (expr.isEmpty) return false;
    lastError = ''; // clears the previous error before every evaluation
    _p.expression = expr;
    if (_p.analyzeExpression()) {
      final v = _p.value;
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.toLowerCase();
        return s == 'true' || s == '1' || s == 'y';
      }
      return false;
    }
    lastError = '[ERROR] $expr # ${_p.error}';
    return false;
  }

  // ── Variable management ─────────────────────────────────────────────
  /// Sets variable [name] to [value] as is (not evaluated).
  void setVar(String name, dynamic value) => _p.setVar(name, value);

  /// Value of variable [name], or null.
  dynamic getVar(String name) => _p.getVar(name);

  /// Sets a whole row of data at once (the Map's keys are variable names; supports the 'table.field' format)
  void setRow(String table, Map<String, dynamic> row) {
    row.forEach((k, v) {
      _p.setVar("$table.$k", v); // em.eno, em.ename, ...
      _p.setVar(k, v); // also sets the short name eno, ename, ...
    });
  }

  /// Clears all variables (keeps built-in functions)
  void clearVars() => _p.clearUserVars();

  // ── Custom functions (an existing name is kept, not replaced) ─────────
  /// Registers function [name] without parameters.
  void addFunction0Param(String name, Func0 fn) =>
      _p.addFunction0Param(name, fn);

  /// Registers function [name] with one parameter.
  void addFunction1Param(String name, Func1 fn) =>
      _p.addFunction1Param(name, fn);

  /// Registers function [name] with two parameters.
  void addFunction2Param(String name, Func2 fn) =>
      _p.addFunction2Param(name, fn);

  /// Registers function [name] with three parameters.
  void addFunction3Param(String name, Func3 fn) =>
      _p.addFunction3Param(name, fn);

  /// Registers function [name] with four parameters.
  void addFunction4Param(String name, Func4 fn) =>
      _p.addFunction4Param(name, fn);

  /// Registers function [name] taking any number of arguments.
  void addFunctionAParam(String name, FuncA fn) =>
      _p.addFunctionAParam(name, fn);

  /// Gets all user-set variables (of type variable/constant)
  Map<String, dynamic> getUserVars() => _p.getUserVars();

  // ── Dataset resolution (delegated to an external object list) ────────────────────────────────────────
  /// Sets the external dataset resolver: when an expression encounters 'id.field',
  /// this function is called back to fetch the dataset from the external object list (agp102's dbq object list).
  /// This way the datasets list exists in exactly one place externally; WapEvaluator holds no copy of it.
  set datasetResolver(ExprDataSet? Function(String name)? resolver) =>
      _p.datasetResolver = resolver;

  /// Resolves dataset names used in expressions; [useEngine] sets it to [DataSetRegistry.resolveDataSet].
  ExprDataSet? Function(String name)? get datasetResolver => _p.datasetResolver;

  // Below is for backward compatibility (the built-in Map used when no resolver is set)
  /// Makes [ds] available to expressions as [name].
  void registerDataSet(String name, ExprDataSet ds) =>
      _p.registerDataSet(name, ds);

  /// Removes the dataset registered as [name].
  void unregisterDataSet(String name) => _p.unregisterDataSet(name);

  /// Removes every registered dataset.
  void clearDataSets() => _p.clearDataSets();

  // ── The last error message ────────────────────────────────
  /// Error message of the last evaluation ('' when none).
  String lastError = '';

  /// Whether the last evaluation failed.
  bool get hasError => lastError.isNotEmpty;
}

// ════════════════════════════════════════════════════════════════════════════
//  1.6.x compatibility: the prefixed function names (tt_*, COB_*) of 1.6.7,
//  kept unchanged for existing WML and Dart code. New code should use the
//  plain names; the prefixed ones are removed in 2.0.0.
// ════════════════════════════════════════════════════════════════════════════

dynamic COB_ABS(dynamic value) => varToDouble(value).abs();

dynamic COB_ACOS(dynamic value) => acos(varToDouble(value));

/// ANNUITY(rate, periods)
dynamic COB_ANNUITY(dynamic v1, dynamic v2) {
  final rate = varToDouble(v1);
  final n = varToInt(v2);
  if (n <= 0) return 0.0;
  if (rate == 0) return 1.0 / n;
  return rate / (1 - pow(1 + rate, -n));
}

dynamic COB_ASIN(dynamic value) => asin(varToDouble(value));

dynamic COB_ATAN(dynamic value) => atan(varToDouble(value));

/// BOOLEAN-OF-INTEGER(n, len): converts an integer to a bit string
dynamic COB_BOOLEAN_OF_INTEGER(dynamic v1, dynamic v2) {
  final n = varToInt(v1);
  final len = varToInt(v2);
  return List.generate(len, (i) => ((n >> (len - 1 - i)) & 1) == 1 ? '1' : "0")
      .join();
}

dynamic COB_BYTE_LENGTH(dynamic value) {
  // UTF-8 bytes
  final bytes = _utf8Bytes(varToStr(value));
  return bytes.length;
}

/// CHAR(n): ordinal n → character (COBOL ordinal = ASCII + 1)
dynamic COB_CHAR(dynamic value) {
  final n = varToInt(value);
  if (n >= 1 && n <= 256) return String.fromCharCode(n - 1);
  return '';
}

/// COMBINED-DATETIME(date_int, time_secs)
dynamic COB_COMBINED_DATETIME(dynamic v1, dynamic v2) =>
    varToInt(v1) * 86400.0 + varToInt(v2);

dynamic COB_CONCATENATE(List<dynamic> values) => values.map(varToStr).join();

dynamic COB_COS(dynamic value) => cos(varToDouble(value));

dynamic COB_CURRENCY_SYMBOL() => '\$'; // default, could be locale-determined

/// CURRENT-DATE (returns a full timestamp string yyyyMMddHHmmsscc+HHmm)
dynamic COB_CURRENT_DATE() {
  final now = DateTime.now();
  final offset = now.timeZoneOffset;
  final sign = offset.isNegative ? '-' : "+";
  final absOffset = offset.abs();
  final bh = absOffset.inHours;
  final bm = absOffset.inMinutes % 60;
  return '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
      '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}'
      '${(now.millisecond ~/ 10).toString().padLeft(2, '0')}$sign${bh.toString().padLeft(2, '0')}${bm.toString().padLeft(2, '0')}';
}

/// DATE-OF-INTEGER(n) → YYYYMMDD
dynamic COB_DATE_OF_INTEGER(dynamic value) {
  final dt = _cobIntToDateTime(varToInt(value));
  return dt.year * 10000 + dt.month * 100 + dt.day;
}

/// DATE-TO-YYYYMMDD(yymmdd, pivot)
dynamic COB_DATE_TO_YYYYMMDD(dynamic v1, dynamic v2) {
  final n = varToInt(v1);
  var pivot = varToInt(v2);
  if (pivot == 0) pivot = 50;
  final yy = n ~/ 10000;
  final mm = (n % 10000) ~/ 100;
  final dd = n % 100;
  final yyyy = yy <= pivot ? 2000 + yy : 1900 + yy;
  return yyyy * 10000 + mm * 100 + dd;
}

/// DAY-OF-INTEGER(n) → YYYYDDD
dynamic COB_DAY_OF_INTEGER(dynamic value) {
  final dt = _cobIntToDateTime(varToInt(value));
  final doy = dt.difference(DateTime(dt.year, 1, 1)).inDays + 1;
  return dt.year * 1000 + doy;
}

dynamic COB_E() => exp(1.0);

dynamic COB_EXP(dynamic value) => exp(varToDouble(value));

dynamic COB_EXP10(dynamic value) => pow(10, varToDouble(value)).toDouble();

/// FACTORIAL：n!
dynamic COB_FACTORIAL(dynamic value) {
  final n = varToInt(value);
  if (n < 0) return 0;
  int r = 1;
  for (var i = 2; i <= n; i++) {
    r *= i;
  }
  return r;
}

/// FRACTION-PART: the fractional part
dynamic COB_FRACTION_PART(dynamic value) {
  final v = varToDouble(value);
  return v - v.truncateToDouble();
}

/// HIGHEST-ALGEBRAIC: the type's maximum value (based on the runtime type)
dynamic COB_HIGHEST_ALGEBRAIC(dynamic value) {
  if (value is int) return 9007199254740991; // JS Number.MAX_SAFE_INTEGER
  if (value is double) return double.maxFinite;
  return null;
}

/// INTEGER: rounds down (floor)
dynamic COB_INTEGER(dynamic value) => varToDouble(value).floor();

/// INTEGER-OF-BOOLEAN(s): converts a bit string to an integer
dynamic COB_INTEGER_OF_BOOLEAN(dynamic value) {
  final s = varToStr(value);
  int r = 0;
  for (final c in s.split("")) {
    r = (r << 1) | (c == '1' ? 1 : 0);
  }
  return r;
}

/// INTEGER-OF-DATE(YYYYMMDD) → integer day
dynamic COB_INTEGER_OF_DATE(dynamic value) {
  final n = varToInt(value);
  final y = n ~/ 10000;
  final m = (n % 10000) ~/ 100;
  final d = n % 100;
  return _cobDateTimeToInt(DateTime(y, m, d));
}

/// INTEGER-OF-DAY(YYYYDDD) → integer day
dynamic COB_INTEGER_OF_DAY(dynamic value) {
  final n = varToInt(value);
  final y = n ~/ 1000;
  final doy = n % 1000;
  final dt = DateTime(y, 1, 1).add(Duration(days: doy - 1));
  return _cobDateTimeToInt(dt);
}

/// INTEGER-PART: truncates toward zero
dynamic COB_INTEGER_PART(dynamic value) => varToDouble(value).truncate();

dynamic COB_LENGTH(dynamic value) => varToStr(value).length;

/// LOCALE-COMPARE(s1, s2) → '<' '=' '>'
dynamic COB_LOCALE_COMPARE(dynamic v1, dynamic v2) {
  final c = varToStr(v1).compareTo(varToStr(v2));
  if (c < 0) return '<';
  if (c > 0) return '>';
  return '=';
}

dynamic COB_LOCALE_DATE(dynamic value) {
  final dt = _cobIntToDateTime(varToInt(value));
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

dynamic COB_LOCALE_TIME(dynamic value) {
  final secs = varToInt(value);
  final h = secs ~/ 3600;
  final m = (secs % 3600) ~/ 60;
  final s = secs % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

dynamic COB_LOG(dynamic value) => log(varToDouble(value));

dynamic COB_LOG10(dynamic value) => log(varToDouble(value)) / ln10;

dynamic COB_LOWER_CASE(dynamic value) => varToStr(value).toLowerCase();

/// LOWEST-ALGEBRAIC: the type's minimum value
dynamic COB_LOWEST_ALGEBRAIC(dynamic value) {
  if (value is int) return -9223372036854775808; // int64 min
  if (value is double) return -double.maxFinite;
  return null;
}

dynamic COB_MAX(List<dynamic> values) {
  if (values.isEmpty) return null;
  return values.reduce((a, b) {
    return varToDouble(a) >= varToDouble(b) ? a : b;
  });
}

dynamic COB_MEAN(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  final s = values.fold(0.0, (sum, v) => sum + varToDouble(v));
  return s / values.length;
}

dynamic COB_MEDIAN(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  final sorted = values.map(varToDouble).toList()..sort();
  final n = sorted.length;
  if (n.isOdd) return sorted[n ~/ 2];
  return (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2.0;
}

dynamic COB_MIDRANGE(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  final nums = values.map(varToDouble).toList();
  final lo = nums.reduce((a, b) => a < b ? a : b);
  final hi = nums.reduce((a, b) => a > b ? a : b);
  return (lo + hi) / 2.0;
}

dynamic COB_MIN(List<dynamic> values) {
  if (values.isEmpty) return null;
  return values.reduce((a, b) {
    return varToDouble(a) <= varToDouble(b) ? a : b;
  });
}

/// MOD: result's sign matches the divisor (COBOL standard)
dynamic COB_MOD(dynamic v1, dynamic v2) {
  final n = varToInt(v1);
  final d = varToInt(v2);
  if (d == 0) return 0;
  var r = n % d;
  if (r != 0 && (r < 0) != (d < 0)) r += d;
  return r;
}

dynamic COB_MONETARY_DECIMAL_POINT() => '.';

dynamic COB_NUMERIC_DECIMAL_POINT() => '.';

dynamic COB_NUMVAL(dynamic value) {
  final s = varToStr(value).replaceAll(",", "").trim();
  return double.tryParse(s) ?? 0.0;
}

dynamic COB_NUMVAL_C(dynamic v1, dynamic v2) {
  var s = varToStr(v1).trim();
  final sym = varToStr(v2);
  if (sym.isNotEmpty) s = s.replaceAll(sym, "");
  s = s.replaceAll(",", "");
  return double.tryParse(s) ?? 0.0;
}

dynamic COB_NUMVAL_F(dynamic value) {
  final s = varToStr(value).trim();
  return double.tryParse(s) ?? 0.0;
}

/// ORD(c): character → ordinal (= ASCII + 1)
dynamic COB_ORD(dynamic value) {
  final s = varToStr(value);
  if (s.isEmpty) return 0;
  return s.codeUnitAt(0) + 1;
}

/// ORD-MAX: returns the 1-based index of the maximum value
dynamic COB_ORD_MAX(List<dynamic> values) {
  if (values.isEmpty) return 0;
  int bestIdx = 0;
  for (var i = 1; i < values.length; i++) {
    if (varToDouble(values[i]) > varToDouble(values[bestIdx])) bestIdx = i;
  }
  return bestIdx + 1;
}

/// ORD-MIN: returns the 1-based index of the minimum value
dynamic COB_ORD_MIN(List<dynamic> values) {
  if (values.isEmpty) return 0;
  int bestIdx = 0;
  for (var i = 1; i < values.length; i++) {
    if (varToDouble(values[i]) < varToDouble(values[bestIdx])) bestIdx = i;
  }
  return bestIdx + 1;
}

dynamic COB_PI() => pi;

/// PRESENT-VALUE(rate, amt1, amt2, ...)
dynamic COB_PRESENT_VALUE(List<dynamic> values) {
  if (values.length < 2) return 0.0;
  final rate = varToDouble(values[0]);
  double pv = 0;
  for (var i = 1; i < values.length; i++) {
    pv += varToDouble(values[i]) / pow(1 + rate, i);
  }
  return pv;
}

/// RANDOM([seed]): doesn't reset when seed=0
dynamic COB_RANDOM(dynamic value) {
  final rng = value != null && varToInt(value) != 0
      ? Random(varToInt(value))
      : Random();
  return rng.nextDouble();
}

dynamic COB_RANGE(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  final nums = values.map(varToDouble).toList();
  final lo = nums.reduce((a, b) => a < b ? a : b);
  final hi = nums.reduce((a, b) => a > b ? a : b);
  return hi - lo;
}

/// REM: result's sign matches the dividend
dynamic COB_REM(dynamic v1, dynamic v2) {
  final n = varToDouble(v1);
  final d = varToDouble(v2);
  if (d == 0) return 0.0;
  return n - (n / d).truncateToDouble() * d;
}

dynamic COB_REVERSE(dynamic value) => varToStr(value).split("").reversed.join();

/// SECONDS-PAST-MIDNIGHT
dynamic COB_SECONDS_PAST_MIDNIGHT() {
  final now = DateTime.now();
  return now.hour * 3600 + now.minute * 60 + now.second;
}

dynamic COB_SIGN(dynamic value) {
  final e = varToDouble(value);
  if (e > 0) return 1;
  if (e < 0) return -1;
  return 0;
}

dynamic COB_SIN(dynamic value) => sin(varToDouble(value));

dynamic COB_SQRT(dynamic value) => sqrt(varToDouble(value));

/// STANDARD-COMPARE(s1, s2) → '<' '=' '>'
dynamic COB_STANDARD_COMPARE(dynamic v1, dynamic v2) {
  final c = varToStr(v1).compareTo(varToStr(v2));
  if (c < 0) return '<';
  if (c > 0) return '>';
  return '=';
}

dynamic COB_STANDARD_DEVIATION(List<dynamic> values) =>
    sqrt(COB_VARIANCE(values));

dynamic COB_STORED_CHAR_LENGTH(dynamic value) =>
    varToStr(value).trimRight().length;

/// SUBSTITUTE(str, from1, to1, from2, to2, ...)
dynamic COB_SUBSTITUTE(List<dynamic> values) {
  if (values.isEmpty) return '';
  var s = varToStr(values[0]);
  var i = 1;
  while (i + 1 < values.length) {
    final f = varToStr(values[i]);
    final t = varToStr(values[i + 1]);
    s = s.replaceAll(f, t);
    i += 2;
  }
  return s;
}

/// SUBSTITUTE-CASE (case-insensitive)
dynamic COB_SUBSTITUTE_CASE(List<dynamic> values) {
  if (values.isEmpty) return '';
  var s = varToStr(values[0]);
  var i = 1;
  while (i + 1 < values.length) {
    final f = varToStr(values[i]);
    final t = varToStr(values[i + 1]);
    s = s.replaceAll(RegExp(RegExp.escape(f), caseSensitive: false), t);
    i += 2;
  }
  return s;
}

dynamic COB_SUM(List<dynamic> values) =>
    values.fold(0.0, (sum, v) => sum + varToDouble(v));

dynamic COB_TAN(dynamic value) => tan(varToDouble(value));

/// TEST-DATE-YYYYMMDD: 0=valid
dynamic COB_TEST_DATE_YYYYMMDD(dynamic value) {
  final n = varToInt(value);
  final y = n ~/ 10000;
  final m = (n % 10000) ~/ 100;
  final d = n % 100;
  try {
    DateTime(y, m, d);
    return 0;
  } catch (_) {
    return 1;
  }
}

/// TEST-DAY-YYYYDDD: 0=valid
dynamic COB_TEST_DAY_YYYYDDD(dynamic value) {
  final n = varToInt(value);
  final y = n ~/ 1000;
  final doy = n % 1000;
  final isLeap = (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
  final maxDoy = isLeap ? 366 : 365;
  if (y >= 1601 && doy >= 1 && doy <= maxDoy) return 0;
  return 1;
}

dynamic COB_TEST_NUMVAL(dynamic value) {
  final s = varToStr(value).replaceAll(",", "").trim();
  return double.tryParse(s) != null ? 0 : 1;
}

dynamic COB_TEST_NUMVAL_C(dynamic v1, dynamic v2) {
  var s = varToStr(v1).trim();
  final sym = varToStr(v2);
  if (sym.isNotEmpty) s = s.replaceAll(sym, "");
  s = s.replaceAll(",", "");
  return double.tryParse(s) != null ? 0 : 1;
}

dynamic COB_TEST_NUMVAL_F(dynamic value) {
  return double.tryParse(varToStr(value).trim()) != null ? 0 : 1;
}

/// TRIM(str, mode)  mode: 'LEADING' | 'TRAILING' | '' (both ends)
dynamic COB_TRIM(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final mode = varToStr(v2).toUpperCase().trim();
  if (mode == 'LEADING') return s.trimLeft();
  if (mode == 'TRAILING') return s.trimRight();
  return s.trim();
}

dynamic COB_UPPER_CASE(dynamic value) => varToStr(value).toUpperCase();

dynamic COB_VARIANCE(List<dynamic> values) {
  final n = values.length;
  if (n < 2) return 0.0;
  double s = 0, ss = 0;
  for (final v in values) {
    final x = varToDouble(v);
    s += x;
    ss += x * x;
  }
  return (ss - s * s / n) / n;
}

/// WHEN-COMPILED: same as CURRENT-DATE
dynamic COB_WHEN_COMPILED() => COB_CURRENT_DATE();

/// YEAR-TO-YYYY(yy, pivot)
dynamic COB_YEAR_TO_YYYY(dynamic v1, dynamic v2) {
  final yy = varToInt(v1);
  var pivot = varToInt(v2);
  if (pivot == 0) pivot = 50;
  return yy <= pivot ? 2000 + yy : 1900 + yy;
}

/// tt_ADDWORKDAYS(date, n): adds n working days (skips Sat/Sun)
dynamic tt_ADDWORKDAYS(dynamic v1, dynamic v2) {
  var d = _vToDateTime(v1);
  if (d == null) return null;
  var n = varToInt(v2);
  final step = n >= 0 ? 1 : -1;
  n = n.abs();
  while (n > 0) {
    d = d!.add(Duration(days: step));
    if (d.weekday <= 5) n--;
  }
  return d;
}

/// tt_AGE(birthdate, asofdate): calculates age in full years from a birthdate
dynamic tt_AGE(dynamic v1, dynamic v2) {
  final birth = _vToDateTime(v1);
  final asof = _vToDateTime(v2);
  if (birth == null || asof == null) return 0;
  int age = asof.year - birth.year;
  if (asof.month < birth.month ||
      (asof.month == birth.month && asof.day < birth.day)) {
    age--;
  }
  return age;
}

/// tt_ARRAVG(values): the average of several values
dynamic tt_ARRAVG(List<dynamic> values) {
  final n = values.length;
  if (n == 0) return 0.0;
  return tt_ARRSUM(values) / n;
}

/// tt_ARRCONTAINS(values, target): the last argument is target
dynamic tt_ARRCONTAINS(List<dynamic> values) {
  if (values.length < 2) return false;
  final target = varToStr(values.last);
  return values.sublist(0, values.length - 1).any((v) => varToStr(v) == target);
}

/// tt_ARRJOIN(values, delim): the last argument is delim
dynamic tt_ARRJOIN(List<dynamic> values) {
  if (values.isEmpty) return '';
  final delim = varToStr(values.last);
  final parts = values.sublist(0, values.length - 1);
  return parts.map(varToStr).join(delim);
}

/// tt_ARRMAX(values): the maximum of several values
dynamic tt_ARRMAX(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  return values.map(varToDouble).reduce((a, b) => a > b ? a : b);
}

/// tt_ARRMIN(values): the minimum of several values
dynamic tt_ARRMIN(List<dynamic> values) {
  if (values.isEmpty) return 0.0;
  return values.map(varToDouble).reduce((a, b) => a < b ? a : b);
}

/// tt_ARRSUM(values): the sum of several values
dynamic tt_ARRSUM(List<dynamic> values) =>
    values.fold(0.0, (sum, v) => sum + varToDouble(v));

/// tt_ARRUNIQ(values): removes duplicate values, returns joined by commas
dynamic tt_ARRUNIQ(List<dynamic> values) {
  final seen = <String>{};
  final buf = <String>[];
  for (final v in values) {
    final s = varToStr(v);
    if (seen.add(s)) buf.add(s);
  }
  return buf.join(",");
}

/// tt_As10(v)：Boolean → '1'/'0'
dynamic tt_As10(dynamic value) => tt_AsBool(value) ? '1' : "0";

/// tt_AsBit(v): integer → '1'/'0'
dynamic tt_AsBit(dynamic value) => varToInt(value) != 0 ? '1' : "0";

/// tt_AsBool(v)：Variant → Boolean
dynamic tt_AsBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final s = varToStr(value).toLowerCase();
  return s == 'true' || s == '1' || s == 'y' || s == 't';
}

/// tt_AsCsv(values): multiple values → a single CSV line
dynamic tt_AsCsv(List<dynamic> values) {
  final cells = values.map((v) {
    final s = varToStr(v);
    final needQuote = s.contains(",") ||
        s.contains('"') ||
        s.contains("\r") ||
        s.contains("\n");
    if (needQuote) return '"${s.replaceAll('"', '""')}"';
    return s;
  });
  return cells.join(",");
}

/// tt_AsCurr(v, d): thousands-separated currency string
dynamic tt_AsCurr(dynamic v1, dynamic v2) {
  final val = varToDouble(v1);
  final d = varToInt(v2);
  final fixed = val.toStringAsFixed(d.clamp(0, 20));
  final parts = fixed.split(".");
  final intPart = _commaStr(parts[0]);
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}

/// tt_AsDQuoted(v): wrapped in double quotes, internal quotes backslash-escaped
dynamic tt_AsDQuoted(dynamic value) =>
    '"${varToStr(value).replaceAll('"', '\\"')}"';

/// tt_AsDate(v): Variant → date (DateTime)
dynamic tt_AsDate(dynamic value) {
  if (value is DateTime) return DateTime(value.year, value.month, value.day);
  final dt = DateTime.tryParse(varToStr(value));
  if (dt == null) return null;
  return DateTime(dt.year, dt.month, dt.day);
}

/// tt_AsDateTime(v): Variant → date-time
dynamic tt_AsDateTime(dynamic value) => _vToDateTime(value);

/// tt_AsDefault(v, default): uses the default value when Null
dynamic tt_AsDefault(dynamic v1, dynamic v2) => v1 ?? v2;

/// tt_AsFixed(v, d): fixed-decimal-place string
dynamic tt_AsFixed(dynamic v1, dynamic v2) {
  final val = varToDouble(v1);
  final d = varToInt(v2);
  return val.toStringAsFixed(d.clamp(0, 20));
}

/// tt_AsFloat(v)：Variant → Float
dynamic tt_AsFloat(dynamic value) => varToDouble(value);

/// tt_AsHex(v, width): integer → hexadecimal
dynamic tt_AsHex(dynamic v1, dynamic v2) {
  final n = varToInt(v1);
  final w = varToInt(v2);
  return n.toRadixString(16).toUpperCase().padLeft(w, "0");
}

/// tt_AsISO(v): ISO 8601 date string
dynamic tt_AsISO(dynamic value) {
  final dt = _vToDateTime(value);
  if (dt == null) return '';
  // @@@ this used to truncate to 10 characters, keeping only the date and
  //     cutting off the time entirely -- the function's own documentation
  //     specifies the format as 'YYYY-MM-DDTHH:MM:SS' (19 characters),
  //     not a plain date.
  return dt.toIso8601String().substring(0, 19);
}

/// tt_AsInt(v)：Variant → Integer
dynamic tt_AsInt(dynamic value) => varToInt(value);

/// tt_AsJson(v): a single value → a plain JSON value
dynamic tt_AsJson(dynamic value) {
  if (value == null) return 'null';
  if (value is bool) return value.toString();
  if (value is int) return value.toString();
  if (value is double) return value.toString();
  if (value is DateTime) return '"${value.toIso8601String()}"';
  final s = varToStr(value)
      .replaceAll("\\", "\\\\")
      .replaceAll('"', '\\"')
      .replaceAll("\r", "\\r")
      .replaceAll("\n", "\\n")
      .replaceAll("\t", "\\t");
  return '"$s"';
}

/// tt_AsLower(v): all lowercase
dynamic tt_AsLower(dynamic value) => varToStr(value).toLowerCase();

/// tt_AsNullable(v): empty→NULL, otherwise quoted
dynamic tt_AsNullable(dynamic value) {
  final s = varToStr(value);
  if (s.isEmpty || value == null) return 'NULL';
  return "'${s.replaceAll("'", "''")}'";
}

/// tt_AsOct(v): integer → octal
dynamic tt_AsOct(dynamic value) => varToInt(value).toRadixString(8);

/// tt_AsPct(v, d): percentage string
dynamic tt_AsPct(dynamic v1, dynamic v2) {
  final val = varToDouble(v1) * 100;
  final d = varToInt(v2);
  return '${val.toStringAsFixed(d.clamp(0, 20))}%';
}

/// tt_AsQuoted(v): wrapped in single quotes, internal quotes doubled (escaped)
dynamic tt_AsQuoted(dynamic value) =>
    "'${varToStr(value).replaceAll("'", "''")}'";

/// tt_AsRDate(v): ROC-calendar-year date
dynamic tt_AsRDate(dynamic value) => tt_RDATE(value);

/// tt_AsRDateTime(v): ROC-calendar-year date-time
dynamic tt_AsRDateTime(dynamic value) => tt_RDATETIME(value);

/// tt_AsSQLStr(v): SQL-safe string (inside single quotes, ' becomes '')
dynamic tt_AsSQLStr(dynamic value) =>
    "'${varToStr(value).replaceAll("'", "''")}'";

/// tt_AsSci(v, d): scientific-notation string, formatted as 1.23E+04 (uppercase E, exponent zero-padded to 2 digits)
dynamic tt_AsSci(dynamic v1, dynamic v2) {
  final val = varToDouble(v1);
  final d = varToInt(v2);
  final s =
      val.toStringAsExponential(d.clamp(0, 20)); // e.g. "1.23e+4" or "1.23e-4"
  final parts = s.split('e');
  final mantissa = parts[0];
  final expNum = int.parse(parts[1]);
  final sign = expNum < 0 ? '-' : '+';
  final expStr = expNum.abs().toString().padLeft(2, '0');
  return '${mantissa}E$sign$expStr';
}

/// tt_AsSlug(v)：URL slug
dynamic tt_AsSlug(dynamic value) => tt_SLUGIFY(value);

/// tt_AsString(v)：Variant → String
dynamic tt_AsString(dynamic value) => varToStr(value);

/// tt_AsTF(v)：Boolean → 'T'/'F'
dynamic tt_AsTF(dynamic value) => tt_AsBool(value) ? 'T' : "F";

/// tt_AsTime(v): Variant → time
dynamic tt_AsTime(dynamic value) {
  final dt = _vToDateTime(value);
  return dt;
}

/// tt_AsTrimmed(v): trims whitespace from both ends
dynamic tt_AsTrimmed(dynamic value) => varToStr(value).trim();

/// tt_AsUpper(v): all uppercase
dynamic tt_AsUpper(dynamic value) => varToStr(value).toUpperCase();

/// tt_AsYN(v)：Boolean → 'Y'/'N'
dynamic tt_AsYN(dynamic value) => tt_AsBool(value) ? 'Y' : "N";

/// tt_BETWEEN(value, lo, hi): whether a value is within the [lo, hi] range
dynamic tt_BETWEEN(dynamic v1, dynamic v2, dynamic v3) {
  final val = varToDouble(v1);
  final lo = varToDouble(v2);
  final hi = varToDouble(v3);
  return val >= lo && val <= hi;
}

/// tt_BITAND(a, b): bitwise AND
dynamic tt_BITAND(dynamic v1, dynamic v2) => varToInt(v1) & varToInt(v2);

/// tt_BITNOT(a): bitwise NOT (uses the pure-arithmetic equivalent -x-1
/// instead of the ~ operator, to guard against possible bitwise-op
/// discrepancies under Web compilation)
dynamic tt_BITNOT(dynamic value) => -varToInt(value) - 1;

/// tt_BITOR(a, b): bitwise OR
dynamic tt_BITOR(dynamic v1, dynamic v2) => varToInt(v1) | varToInt(v2);

/// tt_BITSHL(a, n): shift left n bits
dynamic tt_BITSHL(dynamic v1, dynamic v2) => varToInt(v1) << varToInt(v2);

/// tt_BITSHR(a, n): shift right n bits
dynamic tt_BITSHR(dynamic v1, dynamic v2) => varToInt(v1) >> varToInt(v2);

/// tt_BITXOR(a, b): bitwise XOR
dynamic tt_BITXOR(dynamic v1, dynamic v2) => varToInt(v1) ^ varToInt(v2);

/// tt_BOMDATE(year, month): the first day of the given year/month
dynamic tt_BOMDATE(dynamic v1, dynamic v2) =>
    DateTime(varToInt(v1), varToInt(v2), 1);

/// tt_BR2CRLF(str): <br/> → newline
dynamic tt_BR2CRLF(dynamic value) => varToStr(value)
    .replaceAll(RegExp(r"<br\s*/?>", caseSensitive: false), "\r\n");

/// tt_BYTESIZE(n): returns how many bytes are needed to store n bits
dynamic tt_BYTESIZE(dynamic value) => (varToInt(value) + 7) ~/ 8;

/// tt_CAPWORDS(str): capitalizes the first letter of each word
dynamic tt_CAPWORDS(dynamic value) {
  final s = varToStr(value);
  return s
      .split(" ")
      .map((w) =>
          w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(" ");
}

/// tt_CBRT(x): cube root
dynamic tt_CBRT(dynamic value) {
  final x = varToDouble(value);
  return x >= 0 ? pow(x, 1 / 3) : -pow(-x, 1 / 3);
}

/// tt_CHARAT(str, n): gets the nth character (1-based)
dynamic tt_CHARAT(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final n = varToInt(v2) - 1;
  if (n < 0 || n >= s.length) return '';
  return s[n];
}

/// tt_CHECKSUM(str): XOR checksum
dynamic tt_CHECKSUM(dynamic value) {
  final s = varToStr(value);
  int cs = 0;
  for (final c in s.codeUnits) {
    cs ^= c;
  }
  return cs;
}

/// tt_CHOOSE(index, values): picks a value from the list by (1-based) index
dynamic tt_CHOOSE(List<dynamic> values) {
  if (values.length < 2) return null;
  final idx = varToInt(values[0]);
  if (idx >= 1 && idx < values.length) return values[idx];
  return null;
}

/// tt_CLAMP(value, lo, hi): clamps a value to the [lo, hi] range
dynamic tt_CLAMP(dynamic v1, dynamic v2, dynamic v3) {
  final val = varToDouble(v1);
  final lo = varToDouble(v2);
  final hi = varToDouble(v3);
  if (val < lo) return lo;
  if (val > hi) return hi;
  return val;
}

/// tt_COALESCE: returns the first non-Null value (variadic)
dynamic tt_COALESCE(List<dynamic> values) {
  for (final v in values) {
    if (v != null) return v;
  }
  return null;
}

/// tt_COMMAFMT(value): adds thousands separators to a number (integer)
dynamic tt_COMMAFMT(dynamic value) =>
    _commaStr(varToDouble(value).truncate().toString());

/// tt_CONTAINS(str, substr): whether the string contains the substring
dynamic tt_CONTAINS(dynamic v1, dynamic v2) =>
    varToStr(v1).contains(varToStr(v2));

/// tt_COUNTSTR(substr, str): counts occurrences of a substring
dynamic tt_COUNTSTR(dynamic v1, dynamic v2) {
  final sub = varToStr(v1);
  var s = varToStr(v2);
  if (sub.isEmpty) return 0;
  int count = 0;
  int p = s.indexOf(sub);
  while (p >= 0) {
    count++;
    s = s.substring(p + sub.length);
    p = s.indexOf(sub);
  }
  return count;
}

/// tt_CRLF2BR(str): newline → <br/>
dynamic tt_CRLF2BR(dynamic value) =>
    varToStr(value).replaceAll("\r\n", "<br/>").replaceAll("\n", "<br/>");

/// tt_CUMIPMT(rate, nper, pv, startPeriod, endPeriod): cumulative interest
dynamic tt_CUMIPMT(List<dynamic> values) {
  if (values.length < 4) return 0.0;
  final rate = varToDouble(values[0]);
  final nper = varToInt(values[1]);
  final pv = varToDouble(values[2]);
  final start = varToInt(values[3]);
  final end = values.length >= 5 ? varToInt(values[4]) : nper;
  double total = 0;
  for (var i = start; i <= end; i++) {
    total += tt_IPMT(rate, i, nper, pv);
  }
  return total;
}

/// tt_DATEADD(date, n, unit): adds/subtracts from a date; unit='D'/'M'/'Y'/'W'
dynamic tt_DATEADD(dynamic v1, dynamic v2, dynamic v3) {
  final d = _vToDateTime(v1);
  if (d == null) return null;
  final n = varToInt(v2);
  var u = varToStr(v3).trim().toUpperCase();
  if (u.isEmpty) u = 'D';
  switch (u[0]) {
    case 'D':
      return d.add(Duration(days: n));
    case 'W':
      return d.add(Duration(days: n * 7));
    case 'M':
      return DateTime(d.year, d.month + n, d.day, d.hour, d.minute, d.second);
    case 'Y':
      return DateTime(d.year + n, d.month, d.day, d.hour, d.minute, d.second);
    default:
      return d.add(Duration(days: n));
  }
}

/// tt_DATEDIFF(date1, date2, unit): date difference
dynamic tt_DATEDIFF(dynamic v1, dynamic v2, dynamic v3) {
  final d1 = _vToDateTime(v1);
  final d2 = _vToDateTime(v2);
  if (d1 == null || d2 == null) return 0;
  var u = varToStr(v3).trim().toUpperCase();
  if (u.isEmpty) u = 'D';
  switch (u[0]) {
    case 'D':
      return d2.difference(d1).inDays;
    case 'W':
      return d2.difference(d1).inDays ~/ 7;
    case 'M':
      return (d2.year - d1.year) * 12 + (d2.month - d1.month);
    case 'Y':
      return d2.year - d1.year;
    default:
      return d2.difference(d1).inDays;
  }
}

/// tt_DATEEND(date, unit): end of a period; unit='M'=end of month/'Y'=end of year
dynamic tt_DATEEND(dynamic v1, dynamic v2) {
  final d = _vToDateTime(v1);
  if (d == null) return null;
  var u = varToStr(v2).trim().toUpperCase();
  if (u.isEmpty) u = 'M';
  switch (u[0]) {
    case 'M':
      return DateTime(d.year, d.month + 1, 0);
    case 'Y':
      return DateTime(d.year, 12, 31);
    default:
      return d;
  }
}

/// tt_DATESERIAL(y, m, d): builds a DateTime from year/month/day
dynamic tt_DATESERIAL(dynamic v1, dynamic v2, dynamic v3) =>
    DateTime(varToInt(v1), varToInt(v2), varToInt(v3));

/// tt_DATESTART(date, unit): start of a period; unit='M'=start of month/'Y'=start of year/'W'=Monday
dynamic tt_DATESTART(dynamic v1, dynamic v2) {
  final d = _vToDateTime(v1);
  if (d == null) return null;
  var u = varToStr(v2).trim().toUpperCase();
  if (u.isEmpty) u = 'M';
  switch (u[0]) {
    case 'M':
      return DateTime(d.year, d.month, 1);
    case 'Y':
      return DateTime(d.year, 1, 1);
    case 'W':
      // go back to Monday of this week
      final diff = d.weekday - 1; // Mon=1
      return d.subtract(Duration(days: diff));
    default:
      return d;
  }
}

/// tt_DAYNAME(date): weekday name (returned in Chinese — this is a data
/// value used by WML output, not a comment, so it is intentionally left
/// untranslated; translating it would change the function's runtime behavior)
dynamic tt_DAYNAME(dynamic value) {
  const names = ['週一', "週二", "週三", "週四", "週五", "週六", "週日"];
  final dt = _vToDateTime(value);
  if (dt == null) return '';
  return names[dt.weekday - 1];
}

/// tt_DECODE(val, case1, result1, ..., default)：Oracle DECODE
dynamic tt_DECODE(List<dynamic> values) => tt_SWITCH(values);

/// tt_DEG2RAD(deg): degrees → radians
dynamic tt_DEG2RAD(dynamic value) => varToDouble(value) * pi / 180.0;

/// tt_ELLIPSIS(str, maxLen): truncates and adds '...'
dynamic tt_ELLIPSIS(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final maxLen = varToInt(v2);
  if (s.length <= maxLen) return s;
  return '${s.substring(0, (maxLen - 3).clamp(0, s.length))}...';
}

/// tt_ENDSWITH(str, suffix): whether the string ends with suffix
dynamic tt_ENDSWITH(dynamic v1, dynamic v2) =>
    varToStr(v1).endsWith(varToStr(v2));

/// tt_EOMDATE(year, month): the last day of the given year/month
dynamic tt_EOMDATE(dynamic v1, dynamic v2) {
  final y = varToInt(v1);
  final m = varToInt(v2);
  return DateTime(y, m + 1, 0);
}

/// tt_EVEN(n): the smallest even number ≥ n
dynamic tt_EVEN(dynamic value) {
  final n = varToInt(value);
  return n.isOdd ? n + 1 : n;
}

/// tt_FIB(n): the nth Fibonacci number (0-based)
dynamic tt_FIB(dynamic value) {
  final n = varToInt(value);
  if (n < 0) return 0;
  if (n == 0) return 0;
  int a = 0, b = 1;
  for (var i = 2; i <= n; i++) {
    final c = a + b;
    a = b;
    b = c;
  }
  return b;
}

/// tt_FISCALQUARTER(date, fiscalStartMonth): fiscal quarter
dynamic tt_FISCALQUARTER(dynamic v1, dynamic v2) {
  final dt = _vToDateTime(v1);
  if (dt == null) return 0;
  final startM = varToInt(v2);
  final offset = (dt.month - startM + 12) % 12;
  return offset ~/ 3 + 1;
}

/// tt_FISCALYEAR(date, fiscalStartMonth): fiscal year
dynamic tt_FISCALYEAR(dynamic v1, dynamic v2) {
  final dt = _vToDateTime(v1);
  if (dt == null) return 0;
  final startM = varToInt(v2);
  var y = dt.year;
  if (dt.month < startM) y--;
  return y;
}

/// tt_FROMBIN(str): converts a binary string to an integer
dynamic tt_FROMBIN(dynamic value) {
  final s = varToStr(value).trim();
  int r = 0;
  for (final c in s.split("")) {
    r = (r << 1) | (c == '1' ? 1 : 0);
  }
  return r;
}

/// tt_FROMHEX(str): converts a hex string to an integer
dynamic tt_FROMHEX(dynamic value) {
  var s = varToStr(value).trim();
  if (s.length >= 2 && s[0] == '0' && s[1].toUpperCase() == 'X') {
    s = s.substring(2);
  }
  return int.tryParse(s, radix: 16) ?? 0;
}

/// tt_FV(rate, nper, pmt, pv): future value
dynamic tt_FV(dynamic v1, dynamic v2, dynamic v3, dynamic v4) {
  final rate = varToDouble(v1);
  final nper = varToInt(v2);
  final pmt = varToDouble(v3);
  final pv = varToDouble(v4);
  if (rate == 0) return -(pv + pmt * nper);
  return -(pv * pow(1 + rate, nper) + pmt * (pow(1 + rate, nper) - 1) / rate);
}

/// tt_GCD(a, b): greatest common divisor
dynamic tt_GCD(dynamic v1, dynamic v2) {
  var a = varToInt(v1).abs();
  var b = varToInt(v2).abs();
  while (b != 0) {
    final t = b;
    b = a % b;
    a = t;
  }
  return a;
}

/// tt_GEOMEAN(values): geometric mean
dynamic tt_GEOMEAN(List<dynamic> values) {
  final n = values.length;
  if (n == 0) return 0.0;
  double logSum = 0;
  for (final v in values) {
    final x = varToDouble(v);
    if (x <= 0) return 0.0;
    logSum += log(x);
  }
  final r = exp(logSum / n);
  // @@@ a log/exp round trip produces tiny floating-point noise (e.g.
  //     (1*3*9)^(1/3) is theoretically exactly 3, but actually computes
  //     to 3.0000000000000004) -- rounded to 12 decimal places to clear
  //     the noise. The log/exp algorithm itself is kept (rather than
  //     switching to direct multiply-then-root) because with many input
  //     values at large magnitudes, direct multiplication can overflow;
  //     log/exp is more numerically robust.
  return double.parse(r.toStringAsFixed(12));
}

/// tt_GUID: generates a new GUID string
dynamic tt_GUID() {
  final rng = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0F) | 0x40;
  bytes[8] = (bytes[8] & 0x3F) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, "0")).toList();
  return '${hex.sublist(0, 4).join()}-${hex.sublist(4, 6).join()}-${hex.sublist(6, 8).join()}-${hex.sublist(8, 10).join()}-${hex.sublist(10).join()}';
}

/// tt_HARMEAN(values): harmonic mean
dynamic tt_HARMEAN(List<dynamic> values) {
  final n = values.length;
  if (n == 0) return 0.0;
  double s = 0;
  for (final v in values) {
    final x = varToDouble(v);
    if (x == 0) return 0.0;
    s += 1.0 / x;
  }
  return n / s;
}

/// tt_HASH(str): a simple djb2 hash (32-bit, returned as a hex string)
dynamic tt_HASH(dynamic value) {
  final s = varToStr(value);
  int h = 5381;
  for (final c in s.codeUnits) {
    h = ((h << 5) + h + c) & 0xFFFFFFFF;
  }
  return h.toUnsigned(32).toRadixString(16).padLeft(8, "0").toUpperCase();
}

/// tt_HTMLDECODE(str): HTML special-character decoding
dynamic tt_HTMLDECODE(dynamic value) {
  return varToStr(value)
      .replaceAll("&amp;", "&")
      .replaceAll("&lt;", "<")
      .replaceAll("&gt;", ">")
      .replaceAll("&quot;", '"')
      .replaceAll("&#39;", "'")
      .replaceAll("&#160;", "\u00A0");
}

/// tt_HTMLENCODE(str): HTML special-character encoding
dynamic tt_HTMLENCODE(dynamic value) {
  return varToStr(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;");
}

/// tt_HYPOT(a, b): hypotenuse of a right triangle, sqrt(a²+b²)
dynamic tt_HYPOT(dynamic v1, dynamic v2) {
  final a = varToDouble(v1);
  final b = varToDouble(v2);
  return sqrt(a * a + b * b);
}

/// tt_INDEXOF(str, sub, start): finds a substring starting from `start` (1-based)
dynamic tt_INDEXOF(dynamic v1, dynamic v2, dynamic v3) {
  final s = varToStr(v1);
  final sub = varToStr(v2);
  final start = (varToInt(v3) - 1).clamp(0, s.length);
  final i = s.indexOf(sub, start);
  return i < 0 ? 0 : i + 1;
}

/// tt_IPMT(rate, per, nper, pv): interest portion of payment n
dynamic tt_IPMT(dynamic v1, dynamic v2, dynamic v3, dynamic v4) {
  final rate = varToDouble(v1);
  final per = varToInt(v2);
  final nper = varToInt(v3);
  final pv = varToDouble(v4);
  double balance = pv;
  final pmt = tt_PMT(rate, nper, pv);
  for (var i = 1; i < per; i++) {
    balance = balance - (pmt - balance * rate);
  }
  return -balance * rate;
}

/// tt_IRR(values, guess): internal rate of return (Newton-Raphson iteration)
dynamic tt_IRR(List<dynamic> values) {
  final n = values.length;
  if (n < 2) return 0.0;
  var rate = varToDouble(values.last); // guess
  final cashFlows = values.sublist(0, n - 1).map(varToDouble).toList();
  for (var iter = 0; iter < 100; iter++) {
    double npv = 0, dnpv = 0;
    for (var i = 0; i < cashFlows.length; i++) {
      final v = cashFlows[i];
      npv += v / pow(1 + rate, i);
      if (i > 0) dnpv -= i * v / pow(1 + rate, i + 1);
    }
    if (dnpv.abs() < 1e-10) break;
    rate -= npv / dnpv;
    if (npv.abs() < 1e-8) break;
  }
  return rate;
}

/// tt_ISPRIME(n): whether n is prime
dynamic tt_ISPRIME(dynamic value) {
  final n = varToInt(value);
  if (n < 2) return false;
  if (n == 2) return true;
  if (n % 2 == 0) return false;
  for (var i = 3; i * i <= n; i += 2) {
    if (n % i == 0) return false;
  }
  return true;
}

/// tt_ISWEEKDAY(date): whether it's a weekday (Monday~Friday)
dynamic tt_ISWEEKDAY(dynamic value) => !tt_ISWEEKEND(value);

/// tt_ISWEEKEND(date): whether it's Saturday or Sunday
dynamic tt_ISWEEKEND(dynamic value) {
  final dt = _vToDateTime(value);
  if (dt == null) return false;
  return dt.weekday == DateTime.saturday || dt.weekday == DateTime.sunday;
}

/// tt_JOIN(values, delim): merges after cleaning up extra whitespace
dynamic tt_JOIN(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final delim = varToStr(v2);
  final parts = s.split(RegExp(r"\s+")).where((p) => p.isNotEmpty).toList();
  return parts.join(delim);
}

/// tt_KEEPCHARS(str, chars): keeps only the given set of characters
dynamic tt_KEEPCHARS(dynamic v1, dynamic v2) {
  final chars = varToStr(v2);
  return varToStr(v1).split("").where((c) => chars.contains(c)).join();
}

/// tt_LASTINDEXOF(str, sub): finds a substring searching from the right (1-based)
dynamic tt_LASTINDEXOF(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final sub = varToStr(v2);
  final i = s.lastIndexOf(sub);
  return i < 0 ? 0 : i + 1;
}

/// tt_LCM(a, b): least common multiple
dynamic tt_LCM(dynamic v1, dynamic v2) {
  final a = varToInt(v1).abs();
  final b = varToInt(v2).abs();
  if (a == 0 || b == 0) return 0;
  var x = a, y = b;
  while (y != 0) {
    final t = y;
    y = x % y;
    x = t;
  }
  final g = x;
  return a ~/ g * b;
}

/// tt_LERP(a, b, t): linear interpolation a + (b-a)*t
dynamic tt_LERP(dynamic v1, dynamic v2, dynamic v3) {
  final a = varToDouble(v1);
  final b = varToDouble(v2);
  final t = varToDouble(v3);
  return a + (b - a) * t;
}

/// tt_LOG2(x): base-2 logarithm
dynamic tt_LOG2(dynamic value) {
  final x = varToDouble(value);
  if (x <= 0) return 0.0;
  return log(x) / log(2);
}

/// tt_LOGN(base, x): logarithm base `base`
dynamic tt_LOGN(dynamic v1, dynamic v2) {
  final base = varToDouble(v1);
  final x = varToDouble(v2);
  if (base <= 0 || base == 1 || x <= 0) return 0.0;
  return log(x) / log(base);
}

/// tt_LPAD(str, len, ch): left-pads with the given character to width len
dynamic tt_LPAD(dynamic v1, dynamic v2, dynamic v3) {
  var s = varToStr(v1);
  final n = varToInt(v2);
  var ch = varToStr(v3);
  if (ch.isEmpty) ch = ' ';
  while (s.length < n) {
    s = ch[0] + s;
  }
  return s.substring(s.length - n);
}

/// tt_MASK(str, mask, placeholder): mask formatting (placeholder defaults to '#')
dynamic tt_MASK(dynamic v1, dynamic v2, dynamic v3) {
  final src = varToStr(v1).replaceAll(RegExp(r"\D"), "");
  final mask = varToStr(v2);
  final phStr = varToStr(v3);
  final ph = phStr.isNotEmpty ? phStr[0] : '#';
  var si = 0;
  final buf = StringBuffer();
  for (final c in mask.split("")) {
    if (c == ph) {
      buf.write(si < src.length ? src[si++] : '_');
    } else {
      buf.write(c);
    }
  }
  return buf.toString();
}

/// tt_MONTHNAME(date): month name (returned in Chinese — see the note on
/// tt_DAYNAME above)
dynamic tt_MONTHNAME(dynamic value) {
  const names = [
    '一月',
    "二月",
    "三月",
    "四月",
    "五月",
    "六月",
    "七月",
    "八月",
    "九月",
    "十月",
    "十一月",
    "十二月"
  ];
  final dt = _vToDateTime(value);
  if (dt == null) return '';
  return names[dt.month - 1];
}

/// tt_NEXTWDAY(date, dow): finds the next occurrence of the given weekday from date (dow=1 Mon..7 Sun)
dynamic tt_NEXTWDAY(dynamic v1, dynamic v2) {
  final d = _vToDateTime(v1);
  if (d == null) return null;
  final target = varToInt(v2);
  var diff = target - d.weekday;
  if (diff <= 0) diff += 7;
  return d.add(Duration(days: diff));
}

/// tt_NPER(rate, pmt, pv): number of payment periods
dynamic tt_NPER(dynamic v1, dynamic v2, dynamic v3) {
  final rate = varToDouble(v1);
  final pmt = varToDouble(v2);
  final pv = varToDouble(v3);
  if (rate == 0) return -pv / pmt;
  return log(pmt / (pmt + pv * rate)) / log(1 + rate);
}

/// tt_NPV(rate, values): net present value
dynamic tt_NPV(List<dynamic> values) {
  if (values.length < 2) return 0.0;
  final rate = varToDouble(values[0]);
  double npv = 0;
  for (var i = 1; i < values.length; i++) {
    npv += varToDouble(values[i]) / pow(1 + rate, i);
  }
  return npv;
}

/// tt_NUMFMT(value, decimals): numeric formatting, thousands separator + decimal places
dynamic tt_NUMFMT(dynamic v1, dynamic v2) {
  final val = varToDouble(v1);
  final d = varToInt(v2);
  final fixed = val.toStringAsFixed(d < 0 ? 0 : d);
  final parts = fixed.split(".");
  final intPart = _commaStr(parts[0]);
  return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
}

/// tt_NVL(value, default): returns default if value is Null
dynamic tt_NVL(dynamic v1, dynamic v2) => v1 ?? v2;

/// tt_NVL2(value, notNullVal, nullVal)：Oracle NVL2
dynamic tt_NVL2(dynamic v1, dynamic v2, dynamic v3) => v1 != null ? v2 : v3;

/// tt_ODD(n): the smallest odd number ≥ n
dynamic tt_ODD(dynamic value) {
  final n = varToInt(value);
  return n.isEven ? n + 1 : n;
}

/// tt_ONLYALPHA(str): keeps only English letters
dynamic tt_ONLYALPHA(dynamic value) => varToStr(value)
    .split("")
    .where((c) => RegExp(r"[A-Za-z]").hasMatch(c))
    .join();

/// tt_ONLYDIGITS(str): keeps only digits
dynamic tt_ONLYDIGITS(dynamic value) =>
    varToStr(value).split("").where((c) => RegExp(r"\d").hasMatch(c)).join();

/// tt_PADC(str, len): center-pads with spaces to width len
dynamic tt_PADC(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final n = varToInt(v2);
  if (s.length >= n) return s;
  final leftPad = (n - s.length) ~/ 2;
  final rightPad = n - s.length - leftPad;
  return ' ' * leftPad + s + ' ' * rightPad;
}

/// tt_PADL(str, len): left-pads with spaces to width len
dynamic tt_PADL(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final n = varToInt(v2);
  return s.length < n ? s.padLeft(n) : s;
}

/// tt_PADR(str, len): right-pads with spaces to width len
dynamic tt_PADR(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final n = varToInt(v2);
  return s.length < n ? s.padRight(n) : s;
}

/// tt_PERCENT(part, total): percentage calculation
dynamic tt_PERCENT(dynamic v1, dynamic v2) {
  final part = varToDouble(v1);
  final total = varToDouble(v2);
  if (total == 0) return 0.0;
  return part / total * 100.0;
}

/// tt_PMT(rate, nper, pv): the equal payment amount
dynamic tt_PMT(dynamic v1, dynamic v2, dynamic v3) {
  final rate = varToDouble(v1);
  final nper = varToInt(v2);
  final pv = varToDouble(v3);
  if (rate == 0) return -pv / nper;
  return -pv * rate / (1 - pow(1 + rate, -nper));
}

/// tt_PPMT(rate, per, nper, pv): principal portion of payment n
dynamic tt_PPMT(dynamic v1, dynamic v2, dynamic v3, dynamic v4) {
  final ipmt = tt_IPMT(v1, v2, v3, v4);
  final pmt = tt_PMT(v1, v3, v4);
  return pmt - ipmt;
}

/// tt_PREVWDAY(date, dow): finds the previous occurrence of the given weekday before date
dynamic tt_PREVWDAY(dynamic v1, dynamic v2) {
  final d = _vToDateTime(v1);
  if (d == null) return null;
  final target = varToInt(v2);
  var diff = d.weekday - target;
  if (diff <= 0) diff += 7;
  return d.subtract(Duration(days: diff));
}

/// tt_PRODUCT(values): product of the values Π(xᵢ)
dynamic tt_PRODUCT(List<dynamic> values) {
  double p = 1;
  for (final v in values) {
    p *= varToDouble(v);
  }
  return p;
}

/// tt_PV(rate, nper, pmt): present value
dynamic tt_PV(dynamic v1, dynamic v2, dynamic v3) {
  final rate = varToDouble(v1);
  final nper = varToInt(v2);
  final pmt = varToDouble(v3);
  if (rate == 0) return -pmt * nper;
  return -pmt / rate * (1 - pow(1 + rate, -nper));
}

/// tt_QUARTER(date): gets the quarter (1~4)
dynamic tt_QUARTER(dynamic value) {
  final dt = _vToDateTime(value);
  if (dt == null) return 0;
  return (dt.month - 1) ~/ 3 + 1;
}

/// tt_QUARTILE(values, q): quartile; q=1 Q1, q=2 median, q=3 Q3
dynamic tt_QUARTILE(List<dynamic> values) {
  final n = values.length;
  if (n < 2) return 0.0;
  final q = varToInt(values.last);
  final data = values.sublist(0, n - 1).map(varToDouble).toList()..sort();
  final pos = q * (data.length - 1) / 4.0;
  final lo = pos.floor();
  final hi = lo + 1;
  if (hi >= data.length) return data.last;
  return data[lo] + (pos - lo) * (data[hi] - data[lo]);
}

/// tt_RAD2DEG(rad): radians → degrees
dynamic tt_RAD2DEG(dynamic value) => varToDouble(value) * 180.0 / pi;

/// tt_RANDOMSTR(len, chars): generates a random string of the given length
dynamic tt_RANDOMSTR(dynamic v1, dynamic v2) {
  final len = varToInt(v1);
  var chars = varToStr(v2);
  if (chars.isEmpty) {
    chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  }
  final rng = Random();
  return List.generate(len, (_) => chars[rng.nextInt(chars.length)]).join();
}

/// tt_RATE(nper, pmt, pv): interest rate per period (Newton-Raphson approximation)
dynamic tt_RATE(dynamic v1, dynamic v2, dynamic v3) {
  final nper = varToInt(v1);
  final pmt = varToDouble(v2);
  final pv = varToDouble(v3);
  var rate = 0.1;
  for (var i = 0; i < 100; i++) {
    final f = pv * pow(1 + rate, nper) + pmt * (pow(1 + rate, nper) - 1) / rate;
    final df = pv * nper * pow(1 + rate, nper - 1) +
        pmt *
            (nper * rate * pow(1 + rate, nper - 1) * rate -
                (pow(1 + rate, nper) - 1)) /
            (rate * rate);
    if (df.abs() < 1e-12) break;
    rate -= f / df;
    if (f.abs() < 1e-8) break;
  }
  return rate;
}

/// tt_RDATE(date): ROC-calendar-year date string YYY/MM/DD
dynamic tt_RDATE(dynamic value) {
  final dt = _vToDateTime(value);
  if (dt == null) return '';
  return '${(dt.year - 1911).toString().padLeft(3, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
}

/// tt_RDATETIME(date): ROC-calendar-year date-time string YYY/MM/DD HH:MM:SS
dynamic tt_RDATETIME(dynamic value) {
  final dt = _vToDateTime(value);
  if (dt == null) return '';
  return '${(dt.year - 1911).toString().padLeft(3, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
}

/// tt_REMOVECHARS(str, chars): removes the given set of characters
dynamic tt_REMOVECHARS(dynamic v1, dynamic v2) {
  final chars = varToStr(v2);
  return varToStr(v1).split("").where((c) => !chars.contains(c)).join();
}

/// tt_REPEAT(str, n): repeats the string n times
dynamic tt_REPEAT(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final n = varToInt(v2);
  return s * n;
}

/// tt_ROUNDBANK(value, decimals): banker's rounding (round half to even)
dynamic tt_ROUNDBANK(dynamic v1, dynamic v2) {
  final val = varToDouble(v1);
  final d = varToInt(v2);
  final factor = pow(10, d).toDouble();
  final scaled = val * factor;
  final frac = scaled - scaled.truncateToDouble();
  final intPart = scaled.truncate();
  if ((frac - 0.5).abs() < 1e-10) {
    // exactly 0.5: round to even
    if (intPart.isOdd) {
      return (intPart + 1) / factor;
    } else {
      return intPart / factor;
    }
  }
  return (scaled + 0.5).truncateToDouble() / factor;
}

/// tt_RPAD(str, len, ch): right-pads with the given character to width len
dynamic tt_RPAD(dynamic v1, dynamic v2, dynamic v3) {
  var s = varToStr(v1);
  final n = varToInt(v2);
  var ch = varToStr(v3);
  if (ch.isEmpty) ch = ' ';
  while (s.length < n) {
    s = s + ch[0];
  }
  return s.substring(0, n);
}

/// tt_SLUGIFY(str): converts to a URL slug
dynamic tt_SLUGIFY(dynamic value) {
  return varToStr(value)
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r"[^a-z0-9\s-]"), "")
      .replaceAll(RegExp(r"\s+"), "-")
      .replaceAll(RegExp(r"-+"), "-");
}

/// tt_SPLIT(str, delim, n): splits and takes the nth token (1-based)
dynamic tt_SPLIT(dynamic v1, dynamic v2, dynamic v3) {
  final s = varToStr(v1);
  final delim = varToStr(v2);
  final n = varToInt(v3) - 1; // 0-based
  if (delim.isEmpty) return s;
  final parts = s.split(delim);
  if (n < 0 || n >= parts.length) return '';
  return parts[n];
}

/// tt_SPLITCOUNT(str, delim): number of tokens after splitting
dynamic tt_SPLITCOUNT(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final delim = varToStr(v2);
  if (delim.isEmpty) return 1;
  return s.split(delim).length;
}

/// tt_STARTSWITH(str, prefix): whether the string starts with prefix
dynamic tt_STARTSWITH(dynamic v1, dynamic v2) =>
    varToStr(v1).startsWith(varToStr(v2));

/// tt_SUMSQ(values): sum of squares Σ(xᵢ²)
dynamic tt_SUMSQ(List<dynamic> values) {
  double s = 0;
  for (final v in values) {
    final x = varToDouble(v);
    s += x * x;
  }
  return s;
}

/// tt_SWITCH(val, case1, result1, case2, result2, ..., defaultVal)
dynamic tt_SWITCH(List<dynamic> values) {
  if (values.isEmpty) return null;
  final val = values[0];
  for (var i = 1; i + 1 < values.length; i += 2) {
    if (varToStr(values[i]) == varToStr(val)) return values[i + 1];
  }
  // if the argument count is even, the last one is the default
  if (values.length.isEven) return values.last;
  return null;
}

/// tt_TIMESERIAL(h, m, s): builds a DateTime from hour/minute/second
dynamic tt_TIMESERIAL(dynamic v1, dynamic v2, dynamic v3) =>
    DateTime(1970, 1, 1, varToInt(v1), varToInt(v2), varToInt(v3));

/// tt_TOBIN(n, width): converts an integer to a binary string
dynamic tt_TOBIN(dynamic v1, dynamic v2) {
  var n = varToInt(v1);
  final w = varToInt(v2);
  if (n == 0) return '0'.padLeft(w, "0");
  var buf = '';
  while (n > 0) {
    buf = '${n & 1}$buf';
    n >>= 1;
  }
  return buf.padLeft(w, "0");
}

/// tt_TODATE: safely converts to date
dynamic tt_TODATE(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(varToStr(value));
}

/// tt_TOFLOAT: safely converts to float
dynamic tt_TOFLOAT(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(varToStr(value)) ?? 0.0;
}

/// tt_TOHEX(n): converts an integer to a hex string (no padding)
dynamic tt_TOHEX(dynamic value) =>
    varToInt(value).toRadixString(16).toUpperCase();

/// tt_TOINT: safely converts to integer
dynamic tt_TOINT(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(varToStr(value)) ?? 0;
}

/// tt_TOKENAT(str, delims, n): takes a token using multi-character delimiters (1-based)
dynamic tt_TOKENAT(dynamic v1, dynamic v2, dynamic v3) {
  final s = varToStr(v1);
  final delims = varToStr(v2);
  final n = varToInt(v3) - 1;
  if (delims.isEmpty) return s;
  final parts = s.split(RegExp("[${RegExp.escape(delims)}]"));
  if (n < 0 || n >= parts.length) return '';
  return parts[n];
}

/// tt_TRUNCWORDS(str, n): truncates to the first n words
dynamic tt_TRUNCWORDS(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  final n = varToInt(v2);
  final words = s.split(RegExp(r"\s+"));
  if (words.length <= n) return s;
  return '${words.take(n).join(" ")}...';
}

/// tt_TYPENAME: the type's name
dynamic tt_TYPENAME(dynamic value) {
  if (value == null) return 'null';
  if (value is bool) return 'Boolean';
  if (value is int) return 'Integer';
  if (value is double) return 'Float';
  if (value is String) return 'String';
  if (value is DateTime) return 'DateTime';
  if (value is List) return 'Array';
  return value.runtimeType.toString();
}

/// tt_UNMASK(str, mask, placeholder): removes the mask, keeping only the characters at placeholder positions (placeholder defaults to '#')
dynamic tt_UNMASK(dynamic v1, dynamic v2, dynamic v3) {
  final s = varToStr(v1);
  final mask = varToStr(v2);
  final phStr = varToStr(v3);
  final ph = phStr.isNotEmpty ? phStr[0] : '#';
  final buf = StringBuffer();
  for (var i = 0; i < mask.length && i < s.length; i++) {
    if (mask[i] == ph) buf.write(s[i]);
  }
  return buf.toString();
}

/// tt_URLENCODE(str): URL percent-encoding
dynamic tt_URLENCODE(dynamic value) {
  return Uri.encodeComponent(varToStr(value));
}

/// tt_WORKDAYS(date1, date2): counts working days (excludes Sat/Sun)
dynamic tt_WORKDAYS(dynamic v1, dynamic v2) {
  final d1 = _vToDateTime(v1);
  final d2 = _vToDateTime(v2);
  if (d1 == null || d2 == null) return 0;
  int count = 0;
  DateTime cur = DateTime(d1.year, d1.month, d1.day);
  final end = DateTime(d2.year, d2.month, d2.day);
  while (!cur.isAfter(end)) {
    if (cur.weekday <= 5) count++; // Mon=1..Fri=5
    cur = cur.add(const Duration(days: 1));
  }
  return count;
}

/// tt_WRAP(str, width): inserts a line break (CRLF) every width characters
dynamic tt_WRAP(dynamic v1, dynamic v2) {
  final s = varToStr(v1);
  var w = varToInt(v2);
  if (w <= 0) w = 80;
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i += w) {
    if (i > 0) buf.write("\r\n");
    buf.write(s.substring(i, (i + w).clamp(0, s.length)));
  }
  return buf.toString();
}

/// tt_YEARFRAC(date1, date2): the fraction of a year between two dates (Actual/365)
dynamic tt_YEARFRAC(dynamic v1, dynamic v2) {
  final d1 = _vToDateTime(v1);
  final d2 = _vToDateTime(v2);
  if (d1 == null || d2 == null) return 0.0;
  return d2.difference(d1).inDays / 365.0;
}

/// tt_ZFILL(n, width): zero-pads an integer to width digits
dynamic tt_ZFILL(dynamic v1, dynamic v2) {
  final n = varToInt(v1);
  final w = varToInt(v2);
  final neg = n < 0;
  final s = n.abs().toString().padLeft(w, "0");
  return neg ? '-$s' : s;
}
