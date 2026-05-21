import 'package:drift/drift.dart';

import 'vehicles.dart';

class Jobs extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get title => text()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get completionDate => dateTime().nullable()();
  IntColumn get odometer => integer().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get description => text().nullable()();
  RealColumn get cost => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}