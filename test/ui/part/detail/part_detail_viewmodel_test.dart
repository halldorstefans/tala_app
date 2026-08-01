import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/ui/part/detail/view_models/part_detail_viewmodel.dart';

import '../../../helpers/fake_parts_repository.dart';

Future<void> _settle(PartDetailViewModel vm) async {
  while (vm.load.running) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('PartDetailViewModel', () {
    test('load fetches the part', () async {
      final repo = FakePartsRepository()
        ..seedPart(
          const Part(id: 'p1', name: 'Oil filter', partNumber: 'W712/75'),
        );
      final vm = PartDetailViewModel(partsRepository: repo);

      vm.load.execute('p1');
      await _settle(vm);

      expect(vm.part?.name, 'Oil filter');
      expect(vm.part?.partNumber, 'W712/75');
    });

    test('delete removes the loaded part', () async {
      final repo = FakePartsRepository()
        ..seedPart(const Part(id: 'p1', name: 'Oil filter'));
      final vm = PartDetailViewModel(partsRepository: repo);
      vm.load.execute('p1');
      await _settle(vm);

      await vm.delete.execute();

      expect(vm.delete.completed, isTrue);
      expect(repo.lastDeletedPart, 'p1');
    });
  });
}
