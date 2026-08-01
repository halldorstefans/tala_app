import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/domain/models/part.dart';
import 'package:tala_app/ui/part/form/view_models/part_form_view_model.dart';
import 'package:tala_app/ui/part/form/widgets/part_form_screen.dart';

import '../../../helpers/fake_parts_repository.dart';

void main() {
  testWidgets('PartFormScreen renders the part fields prefilled', (
    tester,
  ) async {
    final repo = FakePartsRepository()
      ..seedPart(
        const Part(id: 'p1', name: 'Oil filter', partNumber: 'W712/75'),
      );
    final vm = PartFormViewModel(partsRepository: repo);
    vm.fetchPart.execute('p1');

    await tester.pumpWidget(MaterialApp(home: PartFormScreen(viewModel: vm)));
    await tester.pump();
    await tester.pump();

    expect(find.text('Part name'), findsOneWidget);
    expect(find.text('Oil filter'), findsOneWidget);
    expect(find.text('W712/75'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Save Changes'),
      findsOneWidget,
    );
  });
}
