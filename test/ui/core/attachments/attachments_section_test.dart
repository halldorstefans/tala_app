import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/data/repositories/attachments/attachments_repository.dart';
import 'package:tala_app/domain/models/attachment.dart';
import 'package:tala_app/domain/models/attachment_type.dart';
import 'package:tala_app/ui/core/attachments/view_models/attachments_view_model.dart';
import 'package:tala_app/ui/core/attachments/widgets/attachments_section.dart';

import '../../../helpers/fake_attachments_repository.dart';

void main() {
  Widget wrap(AttachmentsViewModel vm) =>
      MaterialApp(home: Scaffold(body: AttachmentsSection(viewModel: vm)));

  AttachmentsViewModel vmFor(FakeAttachmentsRepository repo) =>
      AttachmentsViewModel(
        repository: repo,
        owner: const AttachmentOwner.project('p1'),
        compressor: (file) async => null,
      );

  testWidgets('shows the empty state and an Add action', (tester) async {
    await tester.pumpWidget(wrap(vmFor(FakeAttachmentsRepository())));
    await tester.pump(); // drain load

    expect(find.text('Attachments'), findsOneWidget);
    expect(find.text('No attachments yet.'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Add'), findsOneWidget);
  });

  testWidgets('Add offers camera, gallery, and file sources', (tester) async {
    await tester.pumpWidget(wrap(vmFor(FakeAttachmentsRepository())));
    await tester.pump(); // drain load

    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
    expect(find.text('Choose file'), findsOneWidget);
  });

  testWidgets('a non-image attachment renders as a file tile, not a thumbnail', (
    tester,
  ) async {
    final repo = FakeAttachmentsRepository()
      ..seed(
        const Attachment(
          id: 'd1',
          type: AttachmentType.document,
          storagePath: 'photos/manual.pdf',
          caption: 'Workshop manual',
          projectId: 'p1',
        ),
      );

    await tester.pumpWidget(wrap(vmFor(repo)));
    await tester.pump(); // drain load

    expect(find.text('Workshop manual'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
  });

  testWidgets('renders a captioned attachment and hides the empty state', (
    tester,
  ) async {
    final repo = FakeAttachmentsRepository()
      ..seed(
        const Attachment(
          id: 'a1',
          type: AttachmentType.receipt,
          storagePath: 'photos/a1.jpg',
          caption: 'Brake pads receipt',
          projectId: 'p1',
        ),
      );

    await tester.pumpWidget(wrap(vmFor(repo)));
    await tester.pump(); // drain load

    expect(find.text('No attachments yet.'), findsNothing);
    expect(find.text('Brake pads receipt'), findsOneWidget);
    // Non-photo types show a type badge.
    expect(find.text('Receipt'), findsOneWidget);
  });
}
