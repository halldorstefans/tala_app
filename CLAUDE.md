# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Android build requirements

The Android build uses **Java 21**. The toolchain is AGP 9.2.0 + KGP 2.2.20 + Gradle 9.4.1.

Set `org.gradle.java.home` in `android/local.properties` (gitignored) to point at your local Java 21 installation:

```
org.gradle.java.home=/usr/lib/jvm/java-21-openjdk
```

On Arch Linux: `sudo pacman -S jdk21-openjdk`

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (local-first; no network config needed)
flutter run

# Build
flutter build apk

# Regenerate Drift database code after schema changes
dart run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test

# Run a single test file
flutter test test/domain/models/job_test.dart

# Lint
flutter analyze

# Format
dart format lib/
```

## SKILLS

Relevant skills are under the `.agents/skills/` directory (Flutter/Dart architecture, testing, static analysis, etc.).

## Architecture

This is a **local-first** Flutter car-maintenance logbook. Data is stored in SQLite via Drift. There is no network layer — a future sync path to a Go/Postgres backend is a later concern (see `BACKLOG.md`), designed for (UUID PKs + `updated_at` on every table) but not built.

### Layers

**Domain** (`lib/domain/models/`) — Plain Dart classes (`Vehicle`, `Job`, `Project`, `Part`, `JobPart`, `Attachment`) plus small enums for the closed sets (`ProgressStatus` for job/project status, `AttachmentType`). No Flutter or database dependencies. Models include `toDrift()` / `fromDrift()` helpers for Drift interop; enums carry a `wire` value + `fromWire` for the DB/JSON boundary (parse once, then the compiler enforces the rest).

**Data** (`lib/data/`) — Three sub-layers:
- `database/` — Drift ORM: `AppDatabase` with tables `Vehicles`, `Jobs`, `Projects`, `Parts`, `JobParts`, and `Attachments`. Database file is `tala.db` in the app documents directory. After any schema change, regenerate with `build_runner`.
- `repositories/` — Abstract interfaces plus `*_local.dart` implementations backed by SQLite (jobs, vehicle, projects, parts, attachments). Every method returns `Result<T>`; errors are typed (`AppException` sealed hierarchy in `lib/utils/app_exception.dart`: `NotFoundException`, `StorageException`, `ValidationException`). `dependencies.dart` wires them up (`providersLocal`).
- `services/tala_api/api_config.dart` — Despite the folder name, all that remains here are photo-path helpers: `ApiConfig.getLocalPhotoPath(relativePath)` resolves a relative photo path to an absolute disk path, and `ApiConfig.isValidPhotoPath` validates it. (The former REST/auth API clients were removed with the rest of the unused remote layer.)

**UI** (`lib/ui/`) — Feature folders: `home/`, `vehicle/`, `job/`, `project/`, `part/`, `backup/`, `core/`. Each feature has:
- `view_models/` — `ChangeNotifier` classes that hold `Command` objects and expose state.
- `widgets/` — Screens and components that read from ViewModels via `Provider`/`context.watch`.

`lib/ui/core/widgets/app_image.dart` — Unified image widget. Resolves a relative path via `ApiConfig.getLocalPhotoPath()` → `Image.file` (it still tolerates an `http(s)://` path → `Image.network`, but nothing produces one in local-first mode). Pass `null` to show a placeholder icon.

`lib/ui/core/themes/` — Centralized theme (Heritage Workshop / Garage Theme). Detail-page spec fields use `google_fonts` JetBrains Mono. When touching colors, typography, or the launcher icon, look here first rather than inlining theme values at the call site.

### Key Patterns

**`Result<T>`** (`lib/utils/result.dart`) — Sealed class (`Ok<T>` / `Error<T>`). Every repository method returns `Result<T>`. Always pattern-match exhaustively.

**`Command<T>`** (`lib/utils/command.dart`) — Wraps an async action returning `Result<T>`. Exposes `.running`, `.error`, `.completed`, `.result`. Use `Command0` for zero-arg actions, `Command1<T, A>` for one-arg. Call `.execute(...)` to trigger; call `.clearResult()` after consuming the result. ViewModels own Commands; widgets listen.

**Dependency injection** — `lib/config/dependencies.dart` exports `providersLocal`. `main.dart` passes it to `MultiProvider`. `AppDatabase`, `SharedPreferencesService`, and each repository/service are registered as Providers. ViewModels are not registered here — they're constructed in route builders (see Routing).

**Routing** — GoRouter in `lib/routing/router.dart`. `initialLocation` is `/home`; the app boots straight to the home screen. There is no auth/sign-in — Tala is single-user and local by design. ViewModels are instantiated in route builders via `context.read()`.

### Attachments & file storage

Attachment files (images *and* documents) are stored locally in `<documents_dir>/photos/<uuid>.<ext>` (the dir name is historical; it holds any file type, and backup zips it). The relative path is persisted in the DB. On display, `ApiConfig.getLocalPhotoPath()` resolves it to the full path, which `AppImage` uses with `Image.file`. The copy/delete plumbing lives in one place — `AttachmentStorage` (`lib/data/services/attachment_storage.dart`). On delete, repositories remove the **files** from disk before the rows (see `deleteJob`, `deleteVehicle`, `deletePart`) so nothing is orphaned.

- **Attachments** (`attachments` table): a file owned by a vehicle, project, job, or part (four nullable owner columns; normally one set), with a `type` (photo/receipt/document/other) + optional caption. The `type` is a user label; whether a file renders as an image is inferred from its extension (`lib/utils/file_types.dart`). Images show a thumbnail + full-screen viewer; non-images (PDFs, etc.) show a file glyph and open via the OS share sheet. Every detail screen renders them through the shared `AttachmentsSection` (`lib/ui/core/attachments/`), backed by `AttachmentsRepository`. Generalizes the old `job_photos` / `part_photos` tables, folded in by the v3→v4 migration.
- **Vehicle cover photo**: a single `photoPath` field on the `Vehicles` table — kept separate from attachments as the hero image.
- **Cascade delete**: deleting a vehicle/job/part removes its attachment files from disk, then the rows.

### Drift / Database Notes

- Schema is in `lib/data/database/app_database.dart`. Drift generates `app_database.g.dart`.
- Any table or column change requires running `build_runner` (see Commands above).
- Uses `NativeDatabase.createInBackground()` for async DB init.
- Domain ↔ Drift conversion: `Vehicle.fromDrift(row)` and `vehicle.toDrift()` (returns `VehiclesCompanion`). Same pattern for `Job`.

### Testing

- **ViewModel/widget tests** use in-memory fakes that implement the abstract repository interfaces (`test/helpers/`) — they don't touch SQLite. Each fake supports `seed(...)`, a controllable `error`, and records the last mutation for assertions. When adding a new repository, add a matching fake here rather than mocking with a library.
- **Repository / migration tests** *do* run against real SQLite, via `AppDatabase.forTesting(NativeDatabase.memory())` (see `test/data/`). These cover the actual SQL, the v3→v4 migration, on-disk file cleanup, and error typing — the seams the fakes bypass. This is the right home for anything where the real database or filesystem behaviour matters.

## Project context docs

The repo root carries living design/context documents that are not autogenerated and not always reflected in code yet:

- `DESIGN.md` — overall product/UX direction.
- `tala_design_core.md` — typography, color, and component decisions (source of truth for the theme).
- `BACKLOG.md` — pending work items.

Consult these for *intent* (why a screen looks the way it does, what's planned) before guessing from code alone.
