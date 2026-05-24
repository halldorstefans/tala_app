import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/utils/command.dart';
import 'package:tala_app/utils/result.dart';

void main() {
  group('Command0', () {
    test('flips running true while action is in flight', () async {
      final completer = Completer<Result<int>>();
      final cmd = Command0<int>(() => completer.future);

      expect(cmd.running, isFalse);
      final fut = cmd.execute();
      expect(cmd.running, isTrue);

      completer.complete(Result.ok(1));
      await fut;
      expect(cmd.running, isFalse);
    });

    test('sets completed flag on Ok result', () async {
      final cmd = Command0<int>(() async => Result.ok(7));
      await cmd.execute();

      expect(cmd.completed, isTrue);
      expect(cmd.error, isFalse);
      expect((cmd.result as Ok<int>).value, 7);
    });

    test('sets error flag on Error result', () async {
      final cmd = Command0<int>(() async => Result.error(Exception('x')));
      await cmd.execute();

      expect(cmd.error, isTrue);
      expect(cmd.completed, isFalse);
    });

    test('clearResult() resets state', () async {
      final cmd = Command0<int>(() async => Result.ok(1));
      await cmd.execute();
      expect(cmd.completed, isTrue);

      cmd.clearResult();
      expect(cmd.completed, isFalse);
      expect(cmd.error, isFalse);
      expect(cmd.result, isNull);
    });

    test('ignores execute() while already running', () async {
      var calls = 0;
      final completer = Completer<Result<int>>();
      final cmd = Command0<int>(() {
        calls++;
        return completer.future;
      });

      final first = cmd.execute();
      final second = cmd.execute();

      expect(calls, 1);

      completer.complete(Result.ok(1));
      await Future.wait([first, second]);
      expect(calls, 1);
    });
  });

  group('Command1', () {
    test('passes argument through to action', () async {
      String? seen;
      final cmd = Command1<int, String>((arg) async {
        seen = arg;
        return Result.ok(arg.length);
      });

      await cmd.execute('hello');

      expect(seen, 'hello');
      expect((cmd.result as Ok<int>).value, 5);
    });
  });
}
