import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job_category.dart';

void main() {
  group('JobCategory.predefined', () {
    test('contains exactly the seven expected constants in order', () {
      expect(JobCategory.predefined, [
        JobCategory.maintenance,
        JobCategory.repair,
        JobCategory.restoration,
        JobCategory.inspection,
        JobCategory.upgrade,
        JobCategory.electrical,
        JobCategory.bodywork,
      ]);
    });
  });

  group('JobCategory.isPredefined', () {
    test('is true for a predefined constant', () {
      expect(JobCategory.isPredefined('maintenance'), isTrue);
    });

    test('is false for null, empty, and unknown values', () {
      expect(JobCategory.isPredefined(null), isFalse);
      expect(JobCategory.isPredefined(''), isFalse);
      expect(JobCategory.isPredefined('timing belt'), isFalse);
    });
  });

  group('categoryLabel', () {
    test('returns Uncategorized for null or empty', () {
      expect(categoryLabel(null), 'Uncategorized');
      expect(categoryLabel(''), 'Uncategorized');
    });

    test('title-cases predefined constants', () {
      expect(categoryLabel(JobCategory.maintenance), 'Maintenance');
      expect(categoryLabel(JobCategory.bodywork), 'Bodywork');
    });

    test('returns custom values unchanged (passthrough)', () {
      expect(categoryLabel('timing belt'), 'timing belt');
      expect(categoryLabel('SU carburettors'), 'SU carburettors');
    });
  });
}
