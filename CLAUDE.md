# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Android build requirements

The Android build requires **Java 21**. The toolchain (AGP 8.9.1 + KGP 2.2.0 + Gradle 8.12) is incompatible with Java 26+.

Set `org.gradle.java.home` in `android/local.properties` (gitignored) to point at your local Java 21 installation:

```
org.gradle.java.home=/usr/lib/jvm/java-21-openjdk
```

On Arch Linux: `sudo pacman -S jdk21-openjdk`

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (API_URL is required at compile time even in local-first mode)
flutter run --dart-define=API_URL=http://localhost:8080

# Build
flutter build apk --dart-define=API_URL=https://api.example.com

# Regenerate Drift database code after schema changes
dart run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Lint
flutter analyze

# Format
dart format lib/
```

## SKILLS

Relevant skills are under the `.agents/` directory.

## Architecture

This is a **local-first** Flutter car-maintenance logbook. Data is stored in SQLite via Drift. There is a remote API layer (stub) that is not yet active.

### Layers

**Domain** (`lib/domain/models/`) — Plain Dart classes (`User`, `Vehicle`, `Job`). No Flutter or API dependencies. Domain models include `toDrift()` / `fromDrift()` helpers for Drift interop.

**Data** (`lib/data/`) — Three sub-layers:
- `database/` — Drift ORM: `AppDatabase` with three tables (`Vehicles`, `Jobs`, `JobPhotos`). Database file is `tala.db` in the app documents directory. After any schema change, regenerate with `build_runner`.
- `repositories/` — Abstract interfaces plus `*_local.dart` implementations backed by SQLite. `*_remote.dart` stubs exist but throw `UnimplementedError`. `dependencies.dart` wires up the active implementations (`providersLocal`).
- `services/tala_api/` — Unused in local-first mode. `ApiClient` uses `dart:io`'s `HttpClient` for REST; `AuthApiClient` handles login/register. `ApiConfig.baseUrl` reads the compile-time `API_URL` define. `ApiConfig.getLocalPhotoPath(relativePath)` resolves relative photo paths to absolute disk paths.

**UI** (`lib/ui/`) — Feature folders: `auth/`, `home/`, `vehicle/`, `job/`, `core/`. Each feature has:
- `view_models/` — `ChangeNotifier` classes that hold `Command` objects and expose state.
- `widgets/` — Screens and components that read from ViewModels via `Provider`/`context.watch`.

`lib/ui/core/widgets/app_image.dart` — Unified image widget. Checks if the path starts with `http(s)://` → `Image.network`; otherwise resolves via `ApiConfig.getLocalPhotoPath()` → `Image.file`. Pass `null` to show a placeholder icon.

### Key Patterns

**`Result<T>`** (`lib/utils/result.dart`) — Sealed class (`Ok<T>` / `Error<T>`). Every repository method returns `Result<T>`. Always pattern-match exhaustively.

**`Command<T>`** (`lib/utils/command.dart`) — Wraps an async action returning `Result<T>`. Exposes `.running`, `.error`, `.completed`, `.result`. Use `Command0` for zero-arg actions, `Command1<T, A>` for one-arg. Call `.execute(...)` to trigger; call `.clearResult()` after consuming the result. ViewModels own Commands; widgets listen.

**Dependency injection** — `lib/config/dependencies.dart` exports `providersLocal` (active) and `providersRemote` (stub). `main.dart` passes `providersLocal` to `MultiProvider`. `AppDatabase` is a singleton Provider. `AuthRepository` is a `ChangeNotifier` because the router listens to it.

**Routing** — GoRouter in `lib/routing/router.dart`. Uses `AuthRepository` as `refreshListenable`; `_redirect` guards routes and sends unauthenticated users to `/login`. ViewModels are instantiated in route builders via `context.read()`.

### Photo Storage

Photos are stored locally in `<documents_dir>/photos/<uuid>.<ext>`. The relative path (`photos/<uuid>.<ext>`) is persisted in the database. On display, `ApiConfig.getLocalPhotoPath()` resolves it to the full path, which `AppImage` uses with `Image.file`.

- **Vehicle photos**: single `photoPath` field in the `Vehicles` table.
- **Job photos**: one row per photo in the `JobPhotos` table; loaded as `List<String>` on the `Job` domain model.
- **Cascade delete**: deleting a vehicle deletes its jobs and all job photo files from disk, then database records.

### Drift / Database Notes

- Schema is in `lib/data/database/app_database.dart`. Drift generates `app_database.g.dart`.
- Any table or column change requires running `build_runner` (see Commands above).
- Uses `NativeDatabase.createInBackground()` for async DB init.
- Domain ↔ Drift conversion: `Vehicle.fromDrift(row)` and `vehicle.toDrift()` (returns `VehiclesCompanion`). Same pattern for `Job`.
