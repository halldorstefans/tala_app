import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/job_status.dart';
import 'package:tala_app/domain/models/vehicle.dart';
import 'package:tala_app/ui/job/list/view_models/job_list_viewmodel.dart';
import 'package:tala_app/ui/vehicle/detail/view_models/vehicle_detail_viewmodel.dart';
import 'package:tala_app/ui/vehicle/detail/widgets/vehicle_detail_screen.dart';

import '../../../helpers/fake_jobs_repository.dart';
import '../../../helpers/fake_vehicle_repository.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

Job _job(String id, String title, String status) => Job(
  id: id,
  vehicleId: 'v1',
  title: title,
  status: status,
);

/// Builds the screen with both fetches kicked off (fire-and-forget). The
/// fake repos resolve on microtasks, so a `pump()` in the test drains them
/// and rebuilds to content — do not hand-settle with timers here, as the
/// test's fake clock only advances on pump.
VehicleDetailScreen _screen(List<Job> jobs) {
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

  return VehicleDetailScreen(viewModel: detailVm, jobListViewModel: jobListVm);
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
            _job('a', 'Engine top-end rebuild', JobStatus.inProgress),
            _job('b', 'Oil change planned', JobStatus.planned),
            _job('c', 'Brakes bled', JobStatus.completed),
            _job('d', 'Interior leather conditioning', JobStatus.inProgress),
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
            _job('a', 'Oil change planned', JobStatus.planned),
            _job('b', 'Brakes bled', JobStatus.completed),
          ]),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('No active work.'), findsOneWidget);
    });
  });
}
