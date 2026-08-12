import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tala_app/data/repositories/attachments/attachments_repository.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/ui/core/attachments/view_models/attachments_view_model.dart';
import 'package:tala_app/ui/part/detail/view_models/part_detail_viewmodel.dart';
import 'package:tala_app/ui/part/detail/widgets/part_detail_screen.dart';

import '../../../helpers/fake_attachments_repository.dart';
import '../../../helpers/fake_parts_repository.dart';

Widget _app(Widget home) => MaterialApp.router(
  routerConfig: GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => home)],
  ),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('PartDetailScreen renders the part and empty attachments state', (
    tester,
  ) async {
    final repo = FakePartsRepository()
      ..seedPart(
        const Part(id: 'p1', name: 'Oil filter', supplier: 'Mann'),
      );
    final vm = PartDetailViewModel(partsRepository: repo);
    vm.load.execute('p1');

    await tester.pumpWidget(
      _app(
        PartDetailScreen(
          viewModel: vm,
          attachmentsViewModel: AttachmentsViewModel(
            repository: FakeAttachmentsRepository(),
            owner: const AttachmentOwner.part('p1'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Oil filter'), findsOneWidget);
    expect(find.text('Supplier: Mann'), findsOneWidget);
    expect(find.text('Attachments'), findsOneWidget);
    expect(find.text('No attachments yet.'), findsOneWidget);
  });
}
