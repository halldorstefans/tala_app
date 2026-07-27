import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tala_app/domain/models/project.dart';
import 'package:tala_app/ui/project/list/view_models/project_list_viewmodel.dart';
import 'package:tala_app/ui/project/list/widgets/project_list_screen.dart';

import '../../../helpers/fake_projects_repository.dart';

/// The screen uses go_router's `context.push` in callbacks, so it needs a
/// Router in the tree even though we don't tap anything here.
Widget _app(Widget home) => MaterialApp.router(
  routerConfig: GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => home)],
  ),
);

ProjectListScreen _screen(List<Project> projects) {
  final repo = FakeProjectsRepository();
  for (final p in projects) {
    repo.seed(p);
  }
  final vm = ProjectListViewModel(projectsRepository: repo, vehicleId: 'v1');
  return ProjectListScreen(viewModel: vm);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('ProjectListScreen', () {
    testWidgets('lists the vehicle\'s projects', (tester) async {
      await tester.pumpWidget(
        _app(
          _screen(const [
            Project(id: 'a', vehicleId: 'v1', title: 'Disassembly'),
            Project(id: 'b', vehicleId: 'v1', title: 'Electrical rewire'),
          ]),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Disassembly'), findsOneWidget);
      expect(find.text('Electrical rewire'), findsOneWidget);
    });

    testWidgets('shows the empty state with no projects', (tester) async {
      await tester.pumpWidget(_app(_screen(const [])));
      await tester.pump();
      await tester.pump();

      expect(find.text('No projects yet.'), findsOneWidget);
    });
  });
}
