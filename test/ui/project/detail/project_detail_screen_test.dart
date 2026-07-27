import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/job_status.dart';
import 'package:tala_app/domain/models/project.dart';
import 'package:tala_app/ui/project/detail/view_models/project_detail_viewmodel.dart';
import 'package:tala_app/ui/project/detail/widgets/project_detail_screen.dart';

import '../../../helpers/fake_projects_repository.dart';

/// The screen uses go_router navigation in callbacks, so a Router must be in
/// the tree even though nothing is tapped here.
Widget _app(Widget home) => MaterialApp.router(
  routerConfig: GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => home)],
  ),
);

ProjectDetailScreen _screen(FakeProjectsRepository repo) => ProjectDetailScreen(
  viewModel: ProjectDetailViewModel(
    projectsRepository: repo,
    vehicleId: 'v1',
    projectId: 'p1',
  ),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('ProjectDetailScreen', () {
    testWidgets('renders the project, its jobs, and stats', (tester) async {
      final repo = FakeProjectsRepository()
        ..seed(const Project(id: 'p1', vehicleId: 'v1', title: 'Disassembly'))
        ..seedJob(
          const Job(
            id: 'j1',
            vehicleId: 'v1',
            projectId: 'p1',
            title: 'Remove interior',
            status: JobStatus.planned,
          ),
        );

      await tester.pumpWidget(_app(_screen(repo)));
      await tester.pump();
      await tester.pump();

      expect(find.text('Disassembly'), findsOneWidget);
      expect(find.text('Remove interior'), findsOneWidget);
      expect(find.text('Planned: 1'), findsOneWidget);
    });

    testWidgets('shows the empty jobs message', (tester) async {
      final repo = FakeProjectsRepository()
        ..seed(const Project(id: 'p1', vehicleId: 'v1', title: 'Body prep'));

      await tester.pumpWidget(_app(_screen(repo)));
      await tester.pump();
      await tester.pump();

      expect(
        find.textContaining('No jobs in this project yet'),
        findsOneWidget,
      );
    });
  });
}
