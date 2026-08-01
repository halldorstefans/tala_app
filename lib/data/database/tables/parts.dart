import 'package:drift/drift.dart';

/// A reusable catalogue entry — the part itself, independent of any job or
/// vehicle. "Parts for a vehicle" is derived from usage via [JobParts].
class Parts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get partNumber => text().nullable()();
  TextColumn get brand => text().nullable()();
  TextColumn get supplier => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
