import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/ui/vehicle/form/view_models/vehicle_form_viewmodel.dart';
import 'package:tala_app/ui/vehicle/form/widgets/vehicle_form_screen.dart';

import '../../../helpers/fake_vehicle_repository.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('VehicleFormScreen smoke', () {
    testWidgets('renders core fields in add mode', (tester) async {
      final vm = VehicleFormViewmodel(
        vehicleRepository: FakeVehicleRepository(),
      );

      await tester.pumpWidget(_wrap(VehicleFormScreen(viewModel: vm)));

      expect(find.text('Make'), findsOneWidget);
      expect(find.text('Model'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
    });
  });
}
