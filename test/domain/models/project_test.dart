import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job_status.dart';
import 'package:tala_app/domain/models/project.dart';

void main() {
  group('Project.copyWith', () {
    const base = Project(id: 'p1', vehicleId: 'v1', title: 'Disassembly');

    test('overrides only the provided fields', () {
      final updated = base.copyWith(
        title: 'Electrical rewire',
        status: JobStatus.inProgress,
      );

      expect(updated.id, 'p1');
      expect(updated.vehicleId, 'v1');
      expect(updated.title, 'Electrical rewire');
      expect(updated.status, JobStatus.inProgress);
    });

    test('returns an equal-valued copy when nothing is passed', () {
      final copy = base.copyWith();

      expect(copy.id, base.id);
      expect(copy.vehicleId, base.vehicleId);
      expect(copy.title, base.title);
      expect(copy.status, base.status);
    });
  });

  group('Project.fromJson', () {
    test('parses dates and nullable fields', () {
      final project = Project.fromJson({
        'id': 'p1',
        'vehicleId': 'v1',
        'title': 'Body prep',
        'status': JobStatus.planned,
        'description': 'Strip and prime',
        'startDate': '2026-07-01T00:00:00.000',
        'endDate': null,
      });

      expect(project.id, 'p1');
      expect(project.title, 'Body prep');
      expect(project.status, JobStatus.planned);
      expect(project.description, 'Strip and prime');
      expect(project.startDate, DateTime(2026, 7, 1));
      expect(project.endDate, isNull);
    });
  });
}
