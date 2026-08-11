import 'package:drift/drift.dart';

import 'jobs.dart';
import 'parts.dart';
import 'projects.dart';
import 'vehicles.dart';

/// A file attached to one owner — a vehicle, project, job, or part. Generalises
/// the old `job_photos` / `part_photos` tables: a [type] (photo, receipt,
/// document, other) plus an optional caption. Files live on disk under the app
/// documents `photos/` dir; [storagePath] is the relative path.
///
/// Exactly one owner column is normally set. The exception is a parts *receipt*,
/// which has no part link and attaches to the job instead.
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get storagePath => text()();
  TextColumn get caption => text().nullable()();

  TextColumn get vehicleId => text().nullable().references(Vehicles, #id)();
  TextColumn get projectId => text().nullable().references(Projects, #id)();
  TextColumn get jobId => text().nullable().references(Jobs, #id)();
  TextColumn get partId => text().nullable().references(Parts, #id)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
