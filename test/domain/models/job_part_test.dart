import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job_part.dart';

void main() {
  group('JobPart.totalCost', () {
    test('multiplies unit cost by quantity', () {
      const jp = JobPart(
        id: 'jp1',
        jobId: 'j1',
        partId: 'p1',
        unitCost: 12.5,
        quantity: 3,
      );
      expect(jp.totalCost, closeTo(37.5, 1e-9));
    });

    test('treats a null unit cost as zero', () {
      const jp = JobPart(id: 'jp1', jobId: 'j1', partId: 'p1', quantity: 4);
      expect(jp.totalCost, 0);
    });

    test('defaults quantity to 1', () {
      const jp = JobPart(id: 'jp1', jobId: 'j1', partId: 'p1', unitCost: 9.0);
      expect(jp.quantity, 1);
      expect(jp.totalCost, closeTo(9.0, 1e-9));
    });
  });
}
