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

# Run the app (requires API_URL at compile time)
flutter run --dart-define=API_URL=http://localhost:8080

# Build
flutter build apk --dart-define=API_URL=https://api.example.com

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Lint
flutter analyze

# Format
dart format lib/
```

## Architecture

This is a Flutter app following a strict layered architecture. The three primary layers are:

**Domain** (`lib/domain/models/`) — Plain Dart classes (`User`, `Vehicle`, `Job`). No Flutter or API dependencies.

**Data** (`lib/data/`) — Two sub-layers:
- `models/` — API-shaped models (e.g., `VehicleApiModel`) that map to/from JSON. These are distinct from domain models.
- `repositories/` — Abstract interfaces (e.g., `VehicleRepository`) plus `*_remote.dart` implementations that talk to the backend via `ApiClient`. `dependencies.dart` wires up the concrete implementations.
- `services/tala_api/ApiClient` — The single HTTP client for all REST calls. It uses `dart:io`'s `HttpClient` directly (not the `http` package), except for multipart photo uploads which use `http.MultipartRequest`. The API base URL is injected at compile time via `--dart-define=API_URL=...` and read through `ApiConfig.baseUrl`.
- `AuthApiClient` handles login/register separately because it doesn't need the auth header injection that `ApiClient` does.

**UI** (`lib/ui/`) — Organized by feature (`auth/`, `home/`, `vehicle/`, `job/`). Each feature has:
- `view_models/` — `ChangeNotifier` classes that hold `Command` objects for async actions and expose state.
- `widgets/` — Screens and components that read from ViewModels via `Provider`/`context.watch`.

## Key Patterns

**`Result<T>`** (`lib/utils/result.dart`) — A sealed class (`Ok<T>` / `Error<T>`) used as the return type of every repository and API method. Always pattern-match on it.

**`Command<T>`** (`lib/utils/command.dart`) — Wraps an async action that returns `Result<T>`. Exposes `.running`, `.error`, `.completed`, and `.result`. Use `Command0` for zero-arg actions and `Command1<T, A>` for one-arg actions. Call `.execute(...)` to trigger and `.clearResult()` after consuming the result. ViewModels own Commands; widgets listen to them.

**Dependency injection** — `lib/config/dependencies.dart` exports `providersRemote`, a list of `Provider`/`ChangeNotifierProvider` entries passed to `MultiProvider` at app startup. `AuthRepository` is a `ChangeNotifier` because the router listens to it for auth state changes.

**Routing** — GoRouter in `lib/routing/router.dart`. The router takes `AuthRepository` as a `refreshListenable` so auth changes trigger redirects. The redirect guard in `_redirect` sends unauthenticated users to `/login`. ViewModels are created directly in route builders via `context.read()`.

**Photo uploads** — Use `http.MultipartRequest` (not the `dart:io` client) for multipart form data. The auth token is injected manually from `_authHeaderProvider` since the `dart:io`-based helper can't be reused.
