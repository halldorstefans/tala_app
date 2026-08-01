import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/ui/part/catalogue/view_models/parts_catalogue_viewmodel.dart';
import 'package:tala_app/ui/part/catalogue/widgets/parts_catalogue_screen.dart';

import '../../../helpers/fake_parts_repository.dart';

Widget _app(Widget home) => MaterialApp.router(
  routerConfig: GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => home)],
  ),
);

PartsCatalogueScreen _screen(List<Part> parts) {
  final repo = FakePartsRepository();
  for (final p in parts) {
    repo.seedPart(p);
  }
  return PartsCatalogueScreen(
    viewModel: PartsCatalogueViewModel(partsRepository: repo),
  );
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('PartsCatalogueScreen', () {
    testWidgets('lists parts and filters by the search field', (tester) async {
      await tester.pumpWidget(
        _app(
          _screen(const [
            Part(id: 'p1', name: 'Oil filter'),
            Part(id: 'p2', name: 'Spark plug'),
          ]),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Oil filter'), findsOneWidget);
      expect(find.text('Spark plug'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'spark');
      await tester.pump();

      expect(find.text('Oil filter'), findsNothing);
      expect(find.text('Spark plug'), findsOneWidget);
    });

    testWidgets('shows the empty state with no parts', (tester) async {
      await tester.pumpWidget(_app(_screen(const [])));
      await tester.pump();
      await tester.pump();

      expect(find.text('No parts yet.'), findsOneWidget);
    });
  });
}
