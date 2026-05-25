import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/job.dart';
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
        status: 'planned',
      );

      await tester.pumpWidget(_wrap(JobCard(job: job)));

      expect(find.text('Replace brake pads'), findsOneWidget);
      expect(find.text('Maintenance'), findsOneWidget);
      expect(find.text('planned'), findsOneWidget);
    });

    testWidgets('renders Uncategorized when category is null', (tester) async {
      final job = Job(id: 'j1', vehicleId: 'v1', title: 'Misc');

      await tester.pumpWidget(_wrap(JobCard(job: job)));

      expect(find.text('Uncategorized'), findsOneWidget);
    });

    testWidgets('shows chevron when photo count is 0 or 1', (tester) async {
      final noPhotos = Job(id: 'j1', vehicleId: 'v1', title: 'A');
      await tester.pumpWidget(_wrap(JobCard(job: noPhotos)));
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.textContaining('+'), findsNothing);

      final onePhoto = Job(
        id: 'j2',
        vehicleId: 'v1',
        title: 'B',
        photoPaths: ['photos/a.jpg'],
      );
      await tester.pumpWidget(_wrap(JobCard(job: onePhoto)));
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows +N badge when more than one photo', (tester) async {
      final job = Job(
        id: 'j1',
        vehicleId: 'v1',
        title: 'A',
        photoPaths: ['photos/a.jpg', 'photos/b.jpg', 'photos/c.jpg'],
      );

      await tester.pumpWidget(_wrap(JobCard(job: job)));

      expect(find.text('+2'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('prefers completion date when status is completed',
        (tester) async {
      final job = Job(
        id: 'j1',
        vehicleId: 'v1',
        title: 'Done',
        status: 'completed',
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
        status: 'planned',
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
