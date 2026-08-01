import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/ui/part/catalogue/view_models/parts_catalogue_viewmodel.dart';

import '../../../helpers/fake_parts_repository.dart';

Future<void> _settle(PartsCatalogueViewModel vm) async {
  while (vm.fetchParts.running) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<PartsCatalogueViewModel> _vm(List<Part> seed) async {
  final repo = FakePartsRepository();
  for (final p in seed) {
    repo.seedPart(p);
  }
  final vm = PartsCatalogueViewModel(partsRepository: repo);
  await _settle(vm);
  return vm;
}

void main() {
  group('PartsCatalogueViewModel', () {
    test('fetch loads all parts', () async {
      final vm = await _vm(const [
        Part(id: 'p1', name: 'Oil filter'),
        Part(id: 'p2', name: 'Spark plug'),
      ]);

      expect(vm.filteredParts.map((p) => p.id), unorderedEquals(['p1', 'p2']));
      expect(vm.isEmpty, isFalse);
    });

    test('filters by name and part number', () async {
      final vm = await _vm(const [
        Part(id: 'p1', name: 'Oil filter', partNumber: 'W712/75'),
        Part(id: 'p2', name: 'Spark plug', partNumber: 'BKR6E'),
        Part(id: 'p3', name: 'Air filter', partNumber: 'C25114'),
      ]);

      vm.setQuery('filter');
      expect(vm.filteredParts.map((p) => p.id), unorderedEquals(['p1', 'p3']));

      vm.setQuery('bkr6e');
      expect(vm.filteredParts.map((p) => p.id), ['p2']);

      vm.setQuery('');
      expect(vm.filteredParts.length, 3);
    });

    test('isEmpty is true with no parts', () async {
      final vm = await _vm(const []);
      expect(vm.isEmpty, isTrue);
      expect(vm.filteredParts, isEmpty);
    });
  });
}
