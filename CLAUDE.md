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

# Run the app. API_URL is a compile-time define (String.fromEnvironment)
# that defaults to "" when omitted; nothing reads it in local-first mode,
# so the --dart-define is only needed if/when the remote API is wired up.
flutter run
# flutter run --dart-define=API_URL=http://localhost:8080   # when using the remote API

# Build
flutter build apk
# flutter build apk --dart-define=API_URL=https://api.example.com

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

Relevant skills are under the `.agents/skills/` directory (Flutter/Dart architecture, testing, static analysis, etc.).

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

`lib/ui/core/themes/` — Centralized theme (Heritage Workshop / Garage Theme). Detail-page spec fields use `google_fonts` JetBrains Mono. When touching colors, typography, or the launcher icon, look here first rather than inlining theme values at the call site.

### Key Patterns

**`Result<T>`** (`lib/utils/result.dart`) — Sealed class (`Ok<T>` / `Error<T>`). Every repository method returns `Result<T>`. Always pattern-match exhaustively.

**`Command<T>`** (`lib/utils/command.dart`) — Wraps an async action returning `Result<T>`. Exposes `.running`, `.error`, `.completed`, `.result`. Use `Command0` for zero-arg actions, `Command1<T, A>` for one-arg. Call `.execute(...)` to trigger; call `.clearResult()` after consuming the result. ViewModels own Commands; widgets listen.

**Dependency injection** — `lib/config/dependencies.dart` exports `providersLocal` (active) and `providersRemote` (stub). `main.dart` passes `providersLocal` to `MultiProvider`. `AppDatabase` is a singleton Provider. `AuthRepository` is registered as a `ChangeNotifier` provider so it can be observed (e.g. by a future router redirect), but nothing currently listens to it.

**Routing** — GoRouter in `lib/routing/router.dart`. `initialLocation` is `/home`; the app boots straight to the home screen. There is **no** auth gating today — no `refreshListenable`, no `redirect`, no `/login` or `/register` routes. The auth UI under `lib/ui/auth/` (login, register, logout) is scaffolded but orphaned. ViewModels are instantiated in route builders via `context.read()`.

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

### Testing

- ViewModel/widget tests do not touch SQLite. Instead, they use in-memory fakes that implement the abstract repository interfaces — see `test/helpers/fake_jobs_repository.dart` and `test/helpers/fake_vehicle_repository.dart`. Each fake supports `seed(...)`, controllable `error`, and records the last mutation for assertions.
- When adding a new repository, add a matching fake under `test/helpers/` rather than mocking with a library.

## Project context docs

The repo root carries living design/context documents that are not autogenerated and not always reflected in code yet:

- `DESIGN.md` — overall product/UX direction.
- `tala_design_core.md` — typography, color, and component decisions (source of truth for the theme).
- `BACKLOG.md` — pending work items.

Consult these for *intent* (why a screen looks the way it does, what's planned) before guessing from code alone.
