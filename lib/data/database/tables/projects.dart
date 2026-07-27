import 'package:drift/drift.dart';

import 'vehicles.dart';

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get title => text()();
  TextColumn get status => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
