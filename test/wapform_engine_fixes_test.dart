// test/wapform_engine_fixes_test.dart
//
// Integer arithmetic, array range declarations, setvar() array writes,
// custom function registration and ROUND() precision.

import 'package:flutter_test/flutter_test.dart';
import 'package:wapform_flutter/wapform_flutter.dart';

void main() {
  late WapEvaluator ev;
  setUp(() {
    ev = WapEvaluator();
    useEngine(ev);
  });

  group('integer arithmetic', () {
    test('int + - * int stays int', () {
      expect(ev.eval('1+1'), 2);
      expect(ev.eval('7-2'), 5);
      expect(ev.eval('2*3'), 6);
      expect(ev.eval('1+1') is int, isTrue);
    });
    test('a float operand or / still gives a float', () {
      expect(ev.eval('1.5+1'), 2.5);
      expect(ev.eval('7/2'), 3.5);
    });
    test('a counter stays an integer, so STR() shows no .0', () {
      setvar('K', '0');
      setvar('K', 'K+1');
      expect(ev.getVar('K'), 1);
      expect(ev.eval('STR(K)'), '1');
    });
  });

  group('arrays', () {
    test('[lo..hi] declares a zero-filled array with indexes up to hi', () {
      setvar('X', '[1..999]');
      expect(ev.eval('HIGH(X)'), 999);
      expect(ev.eval('X[999]'), 0);
    });
    test('setvar("X[K]") writes at the counter index', () {
      setvar('X', '[0..9]');
      setvar('K', '0');
      setvar('K', 'K+1');
      setvar('X[K]', 'X[K]+5');
      expect(ev.eval('X[1]'), 5);
      expect(ev.eval('X[0]'), 0);
    });
    test('a float index is accepted', () {
      setvar('X', '[0..3]');
      ev.setVar('D', 2.0);
      setvar('X[D]', '7');
      expect(ev.eval('X[2]'), 7);
    });
    test('a typed Dart list is extended without a TypeError', () {
      ev.setVar('T', [1, 2]);
      setvar('T[4]', "'z'");
      expect(ev.getVar('T'), [1, 2, null, null, 'z']);
    });
  });

  test('custom functions can be registered on WapEvaluator', () {
    ev.addFunction1Param('TAXED', (v) => (v as num) * 1.05);
    expect(ev.eval('TAXED(100)'), 105.0);
  });

  group('ROUND', () {
    test('decimal places round exactly', () {
      expect(ev.eval('ROUND(6.6,1)'), 6.6);
      expect(ev.eval('ROUND(1.005,2)'), 1.01);
      expect(ev.eval('ROUND(1234.5678,2)'), 1234.57);
    });
    test('integer places and halves', () {
      expect(ev.eval('ROUND(-50.55,-2)'), -100);
      expect(ev.eval('ROUND(2.5,0)'), 3);
      expect(ev.eval('ROUND(-2.5,0)'), -3);
    });
  });
}
