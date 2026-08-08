import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job_part.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/ui/part/used/view_models/parts_used_viewmodel.dart';

import '../../../helpers/fake_parts_repository.dart';

Future<void> _settle(PartsUsedViewModel vm) async {
  while (vm.fetchUsage.running) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('PartsUsedViewModel', () {
    test('aggregates quantity + spend per part, sorted by spend', () async {
      final repo = FakePartsRepository()
        ..seedPart(const Part(id: 'p1', name: 'Oil filter'))
        ..seedPart(const Part(id: 'p2', name: 'Spark plug'))
        // p1 used across two jobs: 1×€10 + 2×€10 = €30, qty 3.
        ..seedJobPart(
          const JobPart(id: 'a', jobId: 'j1', partId: 'p1', unitCost: 10),
        )
        ..seedJobPart(
          const JobPart(
            id: 'b',
            jobId: 'j2',
            partId: 'p1',
            unitCost: 10,
            quantity: 2,
          ),
        )
        // p2: 4×€20 = €80, qty 4.
        ..seedJobPart(
          const JobPart(
            id: 'c',
            jobId: 'j1',
            partId: 'p2',
            unitCost: 20,
            quantity: 4,
          ),
        );
      final vm = PartsUsedViewModel(partsRepository: repo, vehicleId: 'v1');
      await _settle(vm);

      // Sorted by total spent desc → p2 (80) before p1 (30).
      expect(vm.usage.map((u) => u.part.id), ['p2', 'p1']);

      final p1 = vm.usage.firstWhere((u) => u.part.id == 'p1');
      expect(p1.totalQuantity, 3);
      expect(p1.totalSpent, closeTo(30, 1e-9));

      expect(vm.grandTotal, closeTo(110, 1e-9));
    });

    test('is empty when the vehicle has no parts', () async {
      final vm = PartsUsedViewModel(
        partsRepository: FakePartsRepository(),
        vehicleId: 'v1',
      );
      await _settle(vm);

      expect(vm.usage, isEmpty);
      expect(vm.grandTotal, 0);
    });
  });
}
