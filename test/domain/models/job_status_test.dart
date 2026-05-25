import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job_status.dart';

void main() {
  group('JobStatus.all', () {
    test('contains the three statuses in expected order', () {
      expect(JobStatus.all, [
        JobStatus.planned,
        JobStatus.inProgress,
        JobStatus.completed,
      ]);
    });

    test('inProgress is stored as snake_case', () {
      expect(JobStatus.inProgress, 'in_progress');
    });
  });

  group('JobStatus.isKnown', () {
    test('is true for a known status', () {
      expect(JobStatus.isKnown(JobStatus.completed), isTrue);
    });

    test('is false for null, empty, and unknown values', () {
      expect(JobStatus.isKnown(null), isFalse);
      expect(JobStatus.isKnown(''), isFalse);
      expect(JobStatus.isKnown('shelved'), isFalse);
    });
  });

  group('statusLabel', () {
    test('returns Unknown for null or empty', () {
      expect(statusLabel(null), 'Unknown');
      expect(statusLabel(''), 'Unknown');
    });

    test('humanizes each predefined constant', () {
      expect(statusLabel(JobStatus.planned), 'Planned');
      expect(statusLabel(JobStatus.inProgress), 'In progress');
      expect(statusLabel(JobStatus.completed), 'Completed');
    });

    test('returns unknown raw values as-is', () {
      expect(statusLabel('shelved'), 'shelved');
    });
  });
}
