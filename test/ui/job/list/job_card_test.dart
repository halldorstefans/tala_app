import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job.dart';
import 'package:tala_app/domain/models/progress_status.dart';
import 'package:tala_app/ui/job/list/widgets/job_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('JobCard', () {
    testWidgets('renders title and predefined category label', (tester) async {
      final job = Job(
        id: 'j1',
        vehicleId: 'v1',
        title: 'Replace brake pads',
        category: 'maintenance',
        status: ProgressStatus.planned,
      );

      await tester.pumpWidget(_wrap(JobCard(job: job)));

      expect(find.text('Replace brake pads'), findsOneWidget);
      expect(find.text('Maintenance'), findsOneWidget);
      expect(find.text('Planned'), findsOneWidget);
    });

    testWidgets('renders Uncategorized when category is null', (tester) async {
      final job = Job(id: 'j1', vehicleId: 'v1', title: 'Misc');

      await tester.pumpWidget(_wrap(JobCard(job: job)));

      expect(find.text('Uncategorized'), findsOneWidget);
    });

    testWidgets('shows checkbox only when onToggleDone is provided',
        (tester) async {
      final job = Job(id: 'j1', vehicleId: 'v1', title: 'T');

      await tester.pumpWidget(_wrap(JobCard(job: job)));
      expect(find.byType(Checkbox), findsNothing);

      await tester.pumpWidget(
        _wrap(JobCard(job: job, onToggleDone: (_) {})),
      );
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('checkbox reflects completed status and reports toggle',
        (tester) async {
      final planned = Job(
        id: 'j1',
        vehicleId: 'v1',
        title: 'Open',
        status: ProgressStatus.planned,
      );
      var lastValue = false;

      await tester.pumpWidget(
        _wrap(JobCard(job: planned, onToggleDone: (v) => lastValue = v)),
      );
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);

      await tester.tap(find.byType(Checkbox));
      expect(lastValue, isTrue);

      final done = Job(
        id: 'j2',
        vehicleId: 'v1',
        title: 'Done',
        status: ProgressStatus.completed,
      );
      await tester.pumpWidget(
        _wrap(JobCard(job: done, onToggleDone: (_) {})),
      );
      final doneCheckbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(doneCheckbox.value, isTrue);
    });

    testWidgets('prefers completion date when status is completed',
        (tester) async {
      final job = Job(
        id: 'j1',
        vehicleId: 'v1',
        title: 'Done',
        status: ProgressStatus.completed,
        startDate: DateTime(2026, 1, 1),
        completionDate: DateTime(2026, 5, 20),
      );

      await tester.pumpWidget(_wrap(JobCard(job: job)));

      expect(find.text('2026-05-20'), findsOneWidget);
      expect(find.text('2026-01-01'), findsNothing);
    });

    testWidgets('shows start date when not completed', (tester) async {
      final job = Job(
        id: 'j1',
        vehicleId: 'v1',
        title: 'Open',
        status: ProgressStatus.planned,
        startDate: DateTime(2026, 1, 1),
        completionDate: DateTime(2026, 5, 20),
      );

      await tester.pumpWidget(_wrap(JobCard(job: job)));

      expect(find.text('2026-01-01'), findsOneWidget);
      expect(find.text('2026-05-20'), findsNothing);
    });

    testWidgets('invokes onTap', (tester) async {
      var tapped = 0;
      final job = Job(id: 'j1', vehicleId: 'v1', title: 'T');

      await tester.pumpWidget(
        _wrap(JobCard(job: job, onTap: () => tapped++)),
      );
      await tester.tap(find.byType(InkWell));

      expect(tapped, 1);
    });
  });
}
