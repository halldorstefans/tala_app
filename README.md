# Tala

Tala is a car-maintenance logbook for people who want a calm, durable record of the work they put into their vehicles. Add a car, log each job (oil change, brake pads, timing belt, MOT…), attach photos, and keep the history in one place. The design language — *Heritage Workshop* — draws from mid-century automotive manuals and restoration garages: warm paper surfaces, ink-weight typography, and JetBrains Mono for the spec fields you'd expect to see on a workshop ledger.

The app is **local-first**: everything lives on your device in a SQLite database. A remote API layer is scaffolded but not active.

---

## For users

What Tala does today:

- Add, edit, and delete vehicles (make, model, year, plate, photo).
- Log jobs against a vehicle with title, notes, date, mileage, and photos.
- View vehicle and job detail pages with all spec fields.
- All vehicle, job, and photo data stays on the device. No account, sign-in, or network connection is needed — the app opens straight to your garage.

Platforms: Android is the primary target. iOS, web, and desktop builds exist via Flutter but aren't actively tested.

---

## For developers

### Prerequisites

- Flutter SDK matching `environment.sdk: ^3.9.0` in `pubspec.yaml`.
- **Android builds require Java 21.** The toolchain (AGP 8.9.1 + KGP 2.2.0 + Gradle 8.12) is incompatible with Java 26+. On Arch Linux: `sudo pacman -S jdk21-openjdk`. Then point Gradle at it by adding to `android/local.properties` (gitignored):
  ```
  org.gradle.java.home=/usr/lib/jvm/java-21-openjdk
  ```

### Setup & run

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build a release APK
flutter build apk
```

The remote API base URL is read from the compile-time define `API_URL` (`String.fromEnvironment`). In local-first mode nothing reads it, so the define can be omitted. If/when you wire up the remote API, pass it explicitly:

```bash
flutter run --dart-define=API_URL=http://localhost:8080
flutter build apk --dart-define=API_URL=https://api.example.com
```

### Database codegen

The schema lives in `lib/data/database/app_database.dart` and is managed by Drift. After any table or column change, regenerate the `.g.dart` file:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Quality checks

```bash
flutter test           # all tests
flutter test test/path/to/file_test.dart   # single file
flutter analyze        # lint
dart format lib/       # format
```

### Architecture at a glance

- **Domain** (`lib/domain/models/`) — plain Dart models (`User`, `Vehicle`, `Job`) with `toDrift()` / `fromDrift()` helpers.
- **Data** (`lib/data/`) — Drift database, repositories (local SQLite implementations active; remote API stubs present), and the (currently unused) `tala_api` service layer.
- **UI** (`lib/ui/`) — feature folders (`auth/`, `home/`, `vehicle/`, `job/`, `core/`) each with `view_models/` (ChangeNotifier + Command) and `widgets/`.
- **Routing** — `go_router` in `lib/routing/`. Initial location is the home screen; no auth gating is wired up today (the auth UI exists under `lib/ui/auth/` but is not routed).
- **Key patterns** — `Result<T>` sealed class for repository returns, `Command<T>` for async UI actions, `Provider` for DI.
- **Testing** — ViewModel and widget tests use in-memory fakes that implement the abstract repository interfaces (`test/helpers/`); they do not touch SQLite.

For deeper context see:

- [`CLAUDE.md`](CLAUDE.md) — architecture, layering, patterns, and conventions.
- [`DESIGN.md`](DESIGN.md) — product/UX direction.
- [`tala_design_core.md`](tala_design_core.md) — theme source of truth (colors, typography, spacing).
- [`BACKLOG.md`](BACKLOG.md) — pending work.

### Key dependencies

- State & routing: [`provider`](https://pub.dev/packages/provider), [`go_router`](https://pub.dev/packages/go_router)
- Database: [`drift`](https://pub.dev/packages/drift), [`sqlite3_flutter_libs`](https://pub.dev/packages/sqlite3_flutter_libs), [`path_provider`](https://pub.dev/packages/path_provider), [`path`](https://pub.dev/packages/path)
- Photos: [`image_picker`](https://pub.dev/packages/image_picker), [`flutter_image_compress`](https://pub.dev/packages/flutter_image_compress), [`photo_view`](https://pub.dev/packages/photo_view)
- Auth: [`bcrypt`](https://pub.dev/packages/bcrypt), [`jwt_decoder`](https://pub.dev/packages/jwt_decoder), [`shared_preferences`](https://pub.dev/packages/shared_preferences)
- Misc: [`uuid`](https://pub.dev/packages/uuid), [`google_fonts`](https://pub.dev/packages/google_fonts), [`logging`](https://pub.dev/packages/logging), [`http`](https://pub.dev/packages/http)

## License

See [`LICENSE`](LICENSE).
