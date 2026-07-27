import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/job_status.dart';

Job _job({
  String? status,
  DateTime? startDate,
  DateTime? completionDate,
}) => Job(
      id: 'j1',
      vehicleId: 'v1',
      title: 'Test',
      status: status,
      startDate: startDate,
      completionDate: completionDate,
    );

void main() {
  group('Job.normalized', () {
    test('no-op when status is not completed', () {
      final future = DateTime(2027, 1, 1);
      final past = DateTime(2026, 1, 1);
      final job = _job(
        status: JobStatus.planned,
        startDate: future,
        completionDate: past,
      );

      final result = job.normalized();

      expect(result.startDate, future);
      expect(result.completionDate, past);
    });

    test('no-op when startDate is null', () {
      final completion = DateTime(2026, 5, 1);
      final job = _job(
        status: JobStatus.completed,
        completionDate: completion,
      );

      final result = job.normalized();

      expect(result.startDate, isNull);
      expect(result.completionDate, completion);
    });

    test('no-op when completionDate is null', () {
      final start = DateTime(2026, 5, 1);
      final job = _job(status: JobStatus.completed, startDate: start);

      final result = job.normalized();

      expect(result.startDate, start);
      expect(result.completionDate, isNull);
    });

    test('no-op when startDate equals completionDate', () {
      final same = DateTime(2026, 5, 1);
      final job = _job(
        status: JobStatus.completed,
        startDate: same,
        completionDate: same,
      );

      final result = job.normalized();

      expect(result.startDate, same);
    });

    test('no-op when startDate is before completionDate', () {
      final start = DateTime(2026, 5, 1);
      final completion = DateTime(2026, 5, 10);
      final job = _job(
        status: JobStatus.completed,
        startDate: start,
        completionDate: completion,
      );

      final result = job.normalized();

      expect(result.startDate, start);
      expect(result.completionDate, completion);
    });

    test('snaps startDate to completionDate when startDate is later', () {
      final futureStart = DateTime(2027, 1, 1);
      final completion = DateTime(2026, 7, 19);
      final job = _job(
        status: JobStatus.completed,
        startDate: futureStart,
        completionDate: completion,
      );

      final result = job.normalized();

      expect(result.startDate, completion);
      expect(result.completionDate, completion);
    });
  });

  group('Job project assignment', () {
    const job = Job(
      id: 'j1',
      vehicleId: 'v1',
      title: 'Test',
      projectId: 'p1',
    );

    test('withProject assigns a project id', () {
      final assigned = const Job(
        id: 'j1',
        vehicleId: 'v1',
        title: 'Test',
      ).withProject('p2');

      expect(assigned.projectId, 'p2');
    });

    test('withProject(null) unassigns — which copyWith cannot express', () {
      expect(job.withProject(null).projectId, isNull);
      // copyWith keeps the existing projectId (its `x ?? this.x` idiom).
      expect(job.copyWith(title: 'Renamed').projectId, 'p1');
    });
  });
}
