import 'package:drift/drift.dart';

import 'parts.dart';

/// Photos of a part (the part itself, its packaging, the part-number label).
/// Mirrors [JobPhotos]; stored on disk under the app documents `photos/` dir.
class PartPhotos extends Table {
  TextColumn get id => text()();
  TextColumn get partId => text().references(Parts, #id)();
  TextColumn get photoPath => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
