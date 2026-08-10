import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/utils/app_exception.dart';

void main() {
  test('every AppException is an Exception', () {
    const NotFoundException notFound = NotFoundException('Job');
    expect(notFound, isA<Exception>());
    expect(notFound, isA<AppException>());
  });

  test('NotFoundException builds its message from the entity name', () {
    expect(const NotFoundException('Vehicle').message, 'Vehicle not found');
    expect(const NotFoundException('Photo').message, 'Photo not found');
  });

  test('toString is the bare message (no "Exception:" prefix)', () {
    expect(const NotFoundException('Part').toString(), 'Part not found');
    expect(
      const StorageException('Failed to get part').toString(),
      'Failed to get part',
    );
  });

  test('StorageException preserves the underlying cause', () {
    final cause = StateError('db locked');
    final ex = StorageException('Failed to get job', cause: cause);
    expect(ex.cause, same(cause));
    expect(ex.message, 'Failed to get job');
  });

  test('NotFoundException has no cause', () {
    expect(const NotFoundException('Job').cause, isNull);
  });
}
