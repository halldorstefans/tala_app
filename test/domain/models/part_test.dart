import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/part.dart';

void main() {
  group('Part', () {
    const base = Part(id: 'p1', name: 'Oil filter', partNumber: 'W712/75');

    test('copyWith overrides only the provided fields', () {
      final updated = base.copyWith(supplier: 'Mann', brand: 'Mann-Filter');

      expect(updated.id, 'p1');
      expect(updated.name, 'Oil filter');
      expect(updated.partNumber, 'W712/75');
      expect(updated.supplier, 'Mann');
      expect(updated.brand, 'Mann-Filter');
    });

    test('fromJson parses nullable fields', () {
      final part = Part.fromJson({
        'id': 'p1',
        'name': 'Spark plug',
        'partNumber': null,
        'brand': 'NGK',
        'supplier': null,
        'notes': 'gap 0.8mm',
      });

      expect(part.name, 'Spark plug');
      expect(part.partNumber, isNull);
      expect(part.brand, 'NGK');
      expect(part.notes, 'gap 0.8mm');
    });
  });
}
