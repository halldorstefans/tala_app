import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tala_app/ui/home/widgets/home_vehicle_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('HomeVehicleCard', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_wrap(const HomeVehicleCard(title: 'MG B')));

      expect(find.text('MG B'), findsOneWidget);
    });

    testWidgets('combines nickname and registration into one subtitle',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HomeVehicleCard(
            title: 'MG B',
            nickname: 'Old Faithful',
            registration: 'ABC123',
          ),
        ),
      );

      expect(find.text('Old Faithful - Reg: ABC123'), findsOneWidget);
    });

    testWidgets('renders nickname alone when registration is missing',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HomeVehicleCard(title: 'MG B', nickname: 'Old Faithful'),
        ),
      );

      expect(find.text('Old Faithful'), findsOneWidget);
    });

    testWidgets('renders registration alone when nickname is missing',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HomeVehicleCard(title: 'MG B', registration: 'ABC123'),
        ),
      );

      expect(find.text('Reg: ABC123'), findsOneWidget);
    });

    testWidgets('shows placeholder car icon when no image', (tester) async {
      await tester.pumpWidget(_wrap(const HomeVehicleCard(title: 'MG B')));

      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('treats literal "null" string as missing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HomeVehicleCard(
            title: 'MG B',
            nickname: 'null',
            registration: 'null',
          ),
        ),
      );

      expect(find.textContaining('null'), findsNothing);
    });

    testWidgets('invokes onTap', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        _wrap(HomeVehicleCard(title: 'MG B', onTap: () => tapped++)),
      );
      await tester.tap(find.byType(InkWell));

      expect(tapped, 1);
    });
  });
}
