import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/ui/part/form/view_models/part_form_view_model.dart';

import '../../../helpers/fake_parts_repository.dart';

Future<void> _settle(PartFormViewModel vm) async {
  while (vm.fetchPart.running) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('PartFormViewModel', () {
    test('fetchPart loads the part to edit', () async {
      final repo = FakePartsRepository()
        ..seedPart(const Part(id: 'p1', name: 'Oil filter'));
      final vm = PartFormViewModel(partsRepository: repo);

      vm.fetchPart.execute('p1');
      await _settle(vm);

      expect(vm.part?.name, 'Oil filter');
    });

    test('updatePart stores the edited fields', () async {
      final repo = FakePartsRepository()
        ..seedPart(const Part(id: 'p1', name: 'Oil filter'));
      final vm = PartFormViewModel(partsRepository: repo);

      const edited = Part(
        id: 'p1',
        name: 'Oil filter (Mann)',
        brand: 'Mann-Filter',
      );
      await vm.updatePart.execute(edited);

      expect(vm.updatePart.completed, isTrue);
      expect(repo.lastUpdatedPart?.name, 'Oil filter (Mann)');
      expect(repo.lastUpdatedPart?.brand, 'Mann-Filter');
      expect(vm.part?.name, 'Oil filter (Mann)');
    });
  });
}
