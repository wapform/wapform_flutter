// test/wapform_expression_test.dart
//
// Unit tests for wapform_expression.dart's WapEvaluator ??the engine
// behind every $(...) expression in a WML file. Deliberately network-
// and database-free (see example/ for an end-to-end test that exercises
// the Lazarus data layer against the WapDb gateway) so these run fast
// and require no setup: `flutter test` from the package root is enough.
//
// A note on syntax: the `$` prefix (as in WML's `$(expr)` / `$S`) is a
// convention of expandText()/expandSql() in wapform_lazarus.dart, which
// scan literal WML text and splice in evaluated results. It is not part
// of MyParser's own grammar ??WapEvaluator.eval() takes a bare
// expression with no `$`, e.g. eval('greeting') or eval('sh.amount'),
// not eval(r'$greeting'). Passing a literal '$' to eval() is a lexer
// error ("Invalid character: $"), since MyParser's lexer has no case
// for that character at all.

import 'package:flutter_test/flutter_test.dart';
import 'package:wapform_flutter/wapform_flutter.dart';

void main() {
  group('WapEvaluator.eval ??arithmetic and strings', () {
    late WapEvaluator ev;
    setUp(() => ev = WapEvaluator());

    test('basic arithmetic', () {
      expect(ev.eval('1+1'), 2);
      expect(ev.eval('10-3*2'), 4);
      expect(ev.eval('(10-3)*2'), 14);
    });

    test('string concatenation', () {
      expect(ev.eval("'Hello, ' + 'World'"), 'Hello, World');
    });

    test('unknown function reports an error via lastError', () {
      final result = ev.eval('NOT_A_REAL_FUNCTION(1)');
      expect(result, isNull);
      expect(ev.lastError, isNotEmpty);
    });

    test('an undefined variable is treated as empty, not an error', () {
      // WML convention: an identifier not followed by '(' is treated
      // as an undefined variable rather than an error ??this is what
      // lets an unset fragment variable like WML's $S (which
      // expandText() would hand to eval() as the bare identifier 'S')
      // resolve to empty instead of blowing up the expression. See
      // wapform_lazarus.dart's note on this in _parseFunction.
      final result = ev.eval('UNDEFINED_VAR');
      expect(result, isNull);
      expect(ev.lastError, isEmpty);
    });
  });

  group('WapEvaluator.cond', () {
    late WapEvaluator ev;
    setUp(() => ev = WapEvaluator());

    test('numeric truthiness', () {
      expect(ev.cond('1'), isTrue);
      expect(ev.cond('0'), isFalse);
    });

    test('comparisons', () {
      expect(ev.cond('5>3'), isTrue);
      expect(ev.cond('5<3'), isFalse);
      expect(ev.cond("'A'='A'"), isTrue);
    });

    test('an empty condition is false, not an error', () {
      expect(ev.cond(''), isFalse);
    });
  });

  group('WapEvaluator variables ??setVar/getVar/setRow', () {
    late WapEvaluator ev;
    setUp(() => ev = WapEvaluator());

    test('setVar then read back via eval', () {
      ev.setVar('greeting', 'hi');
      expect(ev.eval('greeting'), 'hi');
    });

    test('setRow sets both table.field and the short field name', () {
      // Mirrors what a generated <onevent> handler does after a lookup
      // fills in a row: em.eno AND the bare eno both become readable.
      ev.setRow('em', {'eno': '001', 'ename': 'Test Employee'});
      expect(ev.eval('em.eno'), '001');
      expect(ev.eval('eno'), '001');
      expect(ev.eval('ename'), 'Test Employee');
    });

    test('clearVars removes user variables but keeps built-in functions', () {
      ev.setVar('x', '1');
      ev.clearVars();
      expect(ev.eval('x'), isNull);
      // A built-in function must still work after clearVars.
      expect(ev.eval("tt_PADL('7',3)"), '  7');
    });
  });

  group('tt_* built-in function library', () {
    late WapEvaluator ev;
    setUp(() => ev = WapEvaluator());

    test('tt_PADL / tt_PADR pad to width', () {
      expect(ev.eval("tt_PADL('7',3)"), '  7');
      expect(ev.eval("tt_PADR('7',3)"), '7  ');
    });

    test('tt_NUMFMT formats with thousands separators', () {
      expect(ev.eval('tt_NUMFMT(1234567,0)'), '1,234,567');
    });

    test('tt_CLAMP restricts a value to a range', () {
      expect(ev.eval('tt_CLAMP(15,0,10)'), 10);
      expect(ev.eval('tt_CLAMP(-5,0,10)'), 0);
      expect(ev.eval('tt_CLAMP(5,0,10)'), 5);
    });

    test('tt_NVL returns the default only when the value is Null', () {
      expect(ev.eval("tt_NVL(UNSET_VAR,'fallback')"), 'fallback');
      expect(ev.eval("tt_NVL('real value','fallback')"), 'real value');
    });

    test('tt_SPLIT / tt_SPLITCOUNT tokenize by delimiter', () {
      expect(ev.eval("tt_SPLITCOUNT('a,b,c',',')"), 3);
      expect(ev.eval("tt_SPLIT('a,b,c',',',2)"), 'b');
    });
  });

  group('WapEvaluator.datasetResolver ??dataset-backed expressions', () {
    // A minimal ExprDataSet stand-in, so this stays network/DB-free
    // while still exercising the "id.field" resolution path that
    // wapform_lazarus.dart's DataSetRegistry wires up for real datasets.
    test('dataset.field resolves through a registered resolver', () {
      final ev = WapEvaluator();
      final fake = _FakeExprDataSet({'amount': 1540});
      ev.datasetResolver = (name) => name == 'sh' ? fake : null;
      expect(ev.eval('sh.amount'), 1540);
    });

    test(
        'arithmetic on a resolved numeric field stays numeric, '
        'not string concatenation', () {
      // The parser's '+' operator does numeric addition when both
      // operands are numeric, string concatenation when either is a
      // String. ExprDataSet.fieldValue() passes the value through
      // as-is (int here), so this confirms dataset.field access
      // doesn't silently stringify it along the way. (The related
      // real-world defect this pattern guards against, at the
      // TDataSet-adapter layer rather than here, is documented on
      // _DataSetExprAdapter in wapform_lazarus.dart: an untyped WML
      // <field> reads back as a String from a real TField, and '+' on
      // two Strings concatenates instead of adding.)
      final ev = WapEvaluator();
      final fake = _FakeExprDataSet({'a': 1540, 'b': 77});
      ev.datasetResolver = (name) => fake;
      expect(ev.eval('sh.a + sh.b'), 1617);
    });
  });
}

class _FakeExprDataSet extends ExprDataSet {
  final Map<String, dynamic> _values;
  _FakeExprDataSet(this._values);

  @override
  int get recordCount => 1;
  @override
  bool get bof => true;
  @override
  bool get eof => false;
  @override
  String get state => 'BROWSE';
  @override
  bool hasField(String name) => _values.containsKey(name);
  @override
  dynamic fieldValue(String name) => _values[name];
}
