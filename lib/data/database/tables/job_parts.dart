import 'package:drift/drift.dart';

import 'jobs.dart';
import 'parts.dart';

/// Links a catalogue [Parts] entry to a job, with the per-use details. The
/// line total (unitCost * quantity) is computed in Dart, not stored.
class JobParts extends Table {
  TextColumn get id => text()();
  TextColumn get jobId => text().references(Jobs, #id)();
  TextColumn get partId => text().references(Parts, #id)();
  RealColumn get unitCost => real().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
