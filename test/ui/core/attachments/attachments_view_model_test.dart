import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/data/repositories/attachments/attachments_repository.dart';
import 'package:tala_app/domain/models/attachment.dart';
import 'package:tala_app/domain/models/attachment_type.dart';
import 'package:tala_app/ui/core/attachments/view_models/attachments_view_model.dart';

import '../../../helpers/fake_attachments_repository.dart';

void main() {
  late FakeAttachmentsRepository repo;

  // No-op compressor so the VM doesn't reach for the platform image codec.
  AttachmentsViewModel buildVm() => AttachmentsViewModel(
    repository: repo,
    owner: const AttachmentOwner.vehicle('v1'),
    compressor: (file) async => null,
  );

  setUp(() => repo = FakeAttachmentsRepository());

  test('load populates attachments for the owner', () async {
    repo.seed(
      const Attachment(
        id: 'a1',
        type: AttachmentType.photo,
        storagePath: 'photos/a1.jpg',
        vehicleId: 'v1',
      ),
    );
    repo.seed(
      const Attachment(
        id: 'other',
        type: AttachmentType.photo,
        storagePath: 'photos/o.jpg',
        vehicleId: 'v2',
      ),
    );

    final vm = buildVm();
    await vm.load.execute();

    expect(vm.attachments.map((a) => a.id), ['a1']);
  });

  test('addPhoto adds via the repo and reloads', () async {
    final vm = buildVm();
    await vm.load.execute();

    await vm.addPhoto.execute((
      file: File('dummy.jpg'),
      type: AttachmentType.receipt,
      caption: 'Oil receipt',
    ));

    expect(repo.lastAdded?.type, AttachmentType.receipt);
    expect(repo.lastAdded?.caption, 'Oil receipt');
    expect(repo.uploadedFiles, hasLength(1));
    expect(vm.attachments.single.caption, 'Oil receipt');
  });

  test('updateCaption and remove flow through to the repo', () async {
    repo.seed(
      const Attachment(
        id: 'a1',
        type: AttachmentType.photo,
        storagePath: 'photos/a1.jpg',
        vehicleId: 'v1',
      ),
    );
    final vm = buildVm();
    await vm.load.execute();

    await vm.updateCaption.execute((id: 'a1', caption: 'Front bumper'));
    expect(repo.lastCaptionUpdate, ('a1', 'Front bumper'));
    expect(vm.attachments.single.caption, 'Front bumper');

    await vm.remove.execute('a1');
    expect(repo.lastDeleted, 'a1');
    expect(vm.attachments, isEmpty);
  });
}
