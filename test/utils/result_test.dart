import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/utils/result.dart';

void main() {
  group('Result', () {
    test('Ok exposes value', () {
      final result = Result<int>.ok(42);
      expect(result, isA<Ok<int>>());
      expect((result as Ok<int>).value, 42);
    });

    test('Error exposes exception', () {
      final boom = Exception('boom');
      final result = Result<int>.error(boom);
      expect(result, isA<Error<int>>());
      expect((result as Error<int>).error, boom);
    });

    test('exhaustive pattern match on Ok', () {
      final Result<String> result = Result.ok('hi');
      final label = switch (result) {
        Ok<String>() => 'ok:${result.value}',
        Error<String>() => 'err',
      };
      expect(label, 'ok:hi');
    });

    test('exhaustive pattern match on Error', () {
      final Result<String> result = Result.error(Exception('nope'));
      final label = switch (result) {
        Ok<String>() => 'ok',
        Error<String>() => 'err',
      };
      expect(label, 'err');
    });

    test('toString includes value or error', () {
      expect(Result<int>.ok(1).toString(), contains('1'));
      expect(
        Result<int>.error(Exception('x')).toString(),
        contains('x'),
      );
    });
  });
}
