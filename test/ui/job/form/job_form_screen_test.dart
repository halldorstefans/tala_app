import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/ui/job/form/view_models/job_form_view_model.dart';
import 'package:tala_app/ui/job/form/widgets/job_form_screen.dart';

import '../../../helpers/fake_jobs_repository.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('JobFormScreen smoke', () {
    testWidgets('renders Add Job title and core fields in add mode',
        (tester) async {
      final vm = JobFormViewModel(
        jobsRepository: FakeJobsRepository(),
        vehicleId: 'v1',
      );

      await tester.pumpWidget(_wrap(JobFormScreen(viewModel: vm)));

      expect(find.text('Add Job'), findsWidgets);
      expect(find.text('Job Title'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Cost'), findsOneWidget);
    });
  });
}
