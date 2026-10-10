// 1.6.x compatibility: the prefixed function names of 1.6.7 (tt_*, COB_*)
// still work next to the plain names.
import 'package:flutter_test/flutter_test.dart';
import 'package:wapform_flutter/wapform_expression.dart';

dynamic eval(String expr) {
  final p = MyParser();
  p.expression = expr;
  expect(p.analyzeExpression(), isTrue, reason: expr);
  return p.value;
}

void main() {
  test('tt_ names evaluate like the plain names', () {
    expect(eval('tt_PADL("ab", 5)'), eval('PADL("ab", 5)'));
    expect(eval('tt_REPEAT("x", 3)'), 'xxx');
    expect(eval('tt_ZFILL("7", 3)'), eval('ZFILL("7", 3)'));
  });

  test('COB_ names keep their COBOL behaviour', () {
    expect(eval('COB_CHAR(66)'), 'A'); // COBOL CHAR is 1-based
    expect(eval('COB_UPPER_CASE("abc")'), 'ABC');
    expect(eval('COB_MOD(-7, 3)'), 2);
  });

  test('the prefixed Dart functions are still public', () {
    expect(tt_PADL('ab', 5), padlCompat('ab', 5));
  });
}

// the plain-name Dart function was renamed in 1.6.8; compare through the parser
dynamic padlCompat(String s, int n) => eval('PADL("$s", $n)');
