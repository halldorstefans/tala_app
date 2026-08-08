import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tala_app/domain/models/job_part.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/ui/part/used/view_models/parts_used_viewmodel.dart';
import 'package:tala_app/ui/part/used/widgets/parts_used_screen.dart';

import '../../../helpers/fake_parts_repository.dart';

Widget _app(Widget home) => MaterialApp.router(
  routerConfig: GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => home)],
  ),
);

PartsUsedScreen _screen(FakePartsRepository repo) =>
    PartsUsedScreen(
      viewModel: PartsUsedViewModel(partsRepository: repo, vehicleId: 'v1'),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('PartsUsedScreen', () {
    testWidgets('lists parts used with total spent', (tester) async {
      final repo = FakePartsRepository()
        ..seedPart(const Part(id: 'p1', name: 'Oil filter'))
        ..seedJobPart(
          const JobPart(
            id: 'a',
            jobId: 'j1',
            partId: 'p1',
            unitCost: 10,
            quantity: 2,
          ),
        );

      await tester.pumpWidget(_app(_screen(repo)));
      await tester.pump();
      await tester.pump();

      expect(find.text('Oil filter'), findsOneWidget);
      expect(find.text('€20.00'), findsWidgets); // row + grand total
      expect(find.text('Total parts'), findsOneWidget);
    });

    testWidgets('shows the empty state', (tester) async {
      await tester.pumpWidget(_app(_screen(FakePartsRepository())));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('No parts logged for this vehicle yet.'),
        findsOneWidget,
      );
    });
  });
}
