import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/progress_status.dart';

void main() {
  group('ProgressStatus.values', () {
    test('contains the three statuses in lifecycle order', () {
      expect(ProgressStatus.values, [
        ProgressStatus.planned,
        ProgressStatus.inProgress,
        ProgressStatus.completed,
      ]);
    });

    test('wire values are the stored (snake_case) strings', () {
      expect(ProgressStatus.planned.wire, 'planned');
      expect(ProgressStatus.inProgress.wire, 'in_progress');
      expect(ProgressStatus.completed.wire, 'completed');
    });
  });

  group('ProgressStatus.fromWire', () {
    test('parses each known wire value', () {
      expect(ProgressStatus.fromWire('planned'), ProgressStatus.planned);
      expect(ProgressStatus.fromWire('in_progress'), ProgressStatus.inProgress);
      expect(ProgressStatus.fromWire('completed'), ProgressStatus.completed);
    });

    test('returns null for null, empty, and unrecognized values', () {
      expect(ProgressStatus.fromWire(null), isNull);
      expect(ProgressStatus.fromWire(''), isNull);
      expect(ProgressStatus.fromWire('shelved'), isNull);
    });

    test('round-trips wire <-> enum', () {
      for (final status in ProgressStatus.values) {
        expect(ProgressStatus.fromWire(status.wire), status);
      }
    });
  });

  group('statusLabel', () {
    test('returns Unknown for a null status', () {
      expect(statusLabel(null), 'Unknown');
    });

    test('humanizes each status', () {
      expect(statusLabel(ProgressStatus.planned), 'Planned');
      expect(statusLabel(ProgressStatus.inProgress), 'In progress');
      expect(statusLabel(ProgressStatus.completed), 'Completed');
    });
  });
}
