import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/progress_status.dart';
import 'package:tala_app/domain/models/project.dart';
import 'package:tala_app/domain/models/vehicle.dart';
import 'package:tala_app/ui/job/list/view_models/job_list_viewmodel.dart';
import 'package:tala_app/ui/project/list/view_models/project_list_viewmodel.dart';
import 'package:tala_app/ui/vehicle/detail/view_models/vehicle_detail_viewmodel.dart';
import 'package:tala_app/ui/vehicle/detail/widgets/vehicle_detail_screen.dart';

import '../../../helpers/fake_jobs_repository.dart';
import '../../../helpers/fake_projects_repository.dart';
import '../../../helpers/fake_vehicle_repository.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

Job _job(String id, String title, ProgressStatus status) => Job(
  id: id,
  vehicleId: 'v1',
  title: title,
  status: status,
);

/// Builds the screen with fetches kicked off (fire-and-forget). The fake repos
/// resolve on microtasks, so a `pump()` in the test drains them and rebuilds to
/// content — do not hand-settle with timers here, as the test's fake clock only
/// advances on pump.
VehicleDetailScreen _screen(
  List<Job> jobs, {
  List<Project> projects = const [],
}) {
  final vehicleRepo = FakeVehicleRepository()
    ..seededVehicle = const Vehicle(
      id: 'v1',
      make: 'Volvo',
      model: '240',
      year: 1989,
    );
  final detailVm = VehicleDetailViewModel(vehicleRepository: vehicleRepo);
  detailVm.fetchVehicle.execute('v1');

  final jobsRepo = FakeJobsRepository();
  for (final j in jobs) {
    jobsRepo.seed(j);
  }
  final jobListVm = JobListViewModel(jobsRepository: jobsRepo, vehicleId: 'v1');

  final projectsRepo = FakeProjectsRepository();
  for (final p in projects) {
    projectsRepo.seed(p);
  }
  final projectListVm = ProjectListViewModel(
    projectsRepository: projectsRepo,
    vehicleId: 'v1',
  );

  return VehicleDetailScreen(
    viewModel: detailVm,
    jobListViewModel: jobListVm,
    projectListViewModel: projectListVm,
  );
}

void main() {
  // The screen uses google_fonts (JetBrains Mono) in its stat tiles and spec
  // rows. Left on, runtime fetching attempts a network load and reschedules
  // frames; off, it falls back silently. Keeps pumps deterministic.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('VehicleDetailScreen Active Work section', () {
    testWidgets('shows only in-progress jobs', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _screen([
            _job('a', 'Engine top-end rebuild', ProgressStatus.inProgress),
            _job('b', 'Oil change planned', ProgressStatus.planned),
            _job('c', 'Brakes bled', ProgressStatus.completed),
            _job('d', 'Interior leather conditioning', ProgressStatus.inProgress),
          ]),
        ),
      );
      // Drain the fake-repo fetches and rebuild to the settled content.
      await tester.pump();
      await tester.pump();

      expect(find.text('Active Work'), findsOneWidget);
      // In-progress jobs are shown...
      expect(find.text('Engine top-end rebuild'), findsOneWidget);
      expect(find.text('Interior leather conditioning'), findsOneWidget);
      // ...planned and completed jobs are not.
      expect(find.text('Oil change planned'), findsNothing);
      expect(find.text('Brakes bled'), findsNothing);
    });

    testWidgets('shows the empty label when nothing is in progress',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          _screen([
            _job('a', 'Oil change planned', ProgressStatus.planned),
            _job('b', 'Brakes bled', ProgressStatus.completed),
          ]),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('No active work.'), findsOneWidget);
    });
  });

  group('VehicleDetailScreen Active Projects section', () {
    testWidgets('shows only in-progress projects', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _screen(
            const [],
            projects: const [
              Project(
                id: 'p1',
                vehicleId: 'v1',
                title: 'Electrical rewire',
                status: ProgressStatus.inProgress,
              ),
              Project(
                id: 'p2',
                vehicleId: 'v1',
                title: 'Future paint',
                status: ProgressStatus.planned,
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Active Projects'), findsOneWidget);
      expect(find.text('Electrical rewire'), findsOneWidget);
      expect(find.text('Future paint'), findsNothing);
    });

    testWidgets('shows the empty label when no project is in progress',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          _screen(
            const [],
            projects: const [
              Project(
                id: 'p1',
                vehicleId: 'v1',
                title: 'Future paint',
                status: ProgressStatus.planned,
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('No active projects.'), findsOneWidget);
    });
  });
}
