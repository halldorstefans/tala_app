import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tala_app/data/database/app_database.dart' show AppDatabase;
import 'package:tala_app/data/repositories/attachments/attachments_repository.dart';
import 'package:tala_app/data/repositories/attachments/attachments_repository_local.dart';
import 'package:tala_app/domain/models/attachment_type.dart';
import 'package:tala_app/utils/result.dart';

/// Real-SQLite + real-filesystem coverage for AttachmentsRepositoryLocal:
/// add writes a file + row, getFor filters by owner, captions update, and
/// delete removes both the row and the file.
class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.root);
  final String root;
  @override
  Future<String?> getApplicationDocumentsPath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docsDir;
  late AppDatabase db;
  late AttachmentsRepositoryLocal repo;

  T ok<T>(Result<T> r) => switch (r) {
    Ok<T>(:final value) => value,
    Error<T>(:final error) => throw error,
  };

  setUp(() async {
    docsDir = await Directory.systemTemp.createTemp('tala_attachments_');
    PathProviderPlatform.instance = _FakePathProvider(docsDir.path);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = AttachmentsRepositoryLocal(database: db);
  });

  tearDown(() async {
    await db.close();
    if (await docsDir.exists()) await docsDir.delete(recursive: true);
  });

  Future<File> makeSource() async {
    final f = File(p.join(docsDir.path, 'src.jpg'));
    await f.writeAsBytes(const [1, 2, 3]);
    return f;
  }

  File fileFor(String relativePath) => File(p.join(docsDir.path, relativePath));

  test('add stores a file and a row scoped to the owner', () async {
    final att = ok(
      await repo.add(
        const AttachmentOwner.vehicle('v1'),
        file: await makeSource(),
        type: AttachmentType.document,
        caption: 'Registration',
      ),
    );

    expect(att.vehicleId, 'v1');
    expect(att.type, AttachmentType.document);
    expect(att.caption, 'Registration');
    expect(await fileFor(att.storagePath).exists(), isTrue);

    final forVehicle = ok(await repo.getFor(const AttachmentOwner.vehicle('v1')));
    expect(forVehicle.single.id, att.id);
    // Scoped: a project with the same id sees nothing.
    final forProject = ok(await repo.getFor(const AttachmentOwner.project('v1')));
    expect(forProject, isEmpty);
  });

  test('updateCaption changes only the caption', () async {
    final att = ok(
      await repo.add(
        const AttachmentOwner.project('pr1'),
        file: await makeSource(),
        type: AttachmentType.photo,
      ),
    );
    ok(await repo.updateCaption(att.id, 'Wiring diagram'));

    final reloaded = ok(
      await repo.getFor(const AttachmentOwner.project('pr1')),
    ).single;
    expect(reloaded.caption, 'Wiring diagram');
    expect(reloaded.type, AttachmentType.photo);
  });

  test('delete removes the row and the file', () async {
    final att = ok(
      await repo.add(
        const AttachmentOwner.vehicle('v1'),
        file: await makeSource(),
        type: AttachmentType.photo,
      ),
    );
    expect(await fileFor(att.storagePath).exists(), isTrue);

    ok(await repo.delete(att.id));

    expect(await fileFor(att.storagePath).exists(), isFalse);
    expect(ok(await repo.getFor(const AttachmentOwner.vehicle('v1'))), isEmpty);
  });
}
