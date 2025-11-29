
# Tala Car Logbook

Tala is a Flutter application for managing your vehicle maintenance and job history. It allows users to register, log in, add vehicles, track jobs/repairs, and upload photos for both vehicles and jobs.

## Features

- User authentication (register, login, logout)
- Add, edit, and delete vehicles
- Add, edit, and delete jobs/repairs for vehicles
- Upload and view photos for vehicles and jobs
- View job and vehicle details
- Responsive UI with custom Garage Theme
- State management with Provider
- Routing with go_router

## Project Structure

- `lib/`
  - `main.dart` — App entry point
  - `config/` — Dependency injection setup
  - `data/` — Data layer (repositories, services, models)
  - `domain/` — Domain models
  - `routing/` — App routes and router
  - `ui/` — UI screens and widgets (auth, home, job, user, vehicle, core)
  - `utils/` — Utility classes (e.g., Result, Command)

## Getting Started

1. **Install dependencies:**
	```bash
	flutter pub get
	```
2. **Run the app:**
	```bash
	flutter run
	```
3. **Run tests:**
	```bash
	flutter test
	```

## Dependencies

- [provider](https://pub.dev/packages/provider)
- [go_router](https://pub.dev/packages/go_router)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [image_picker](https://pub.dev/packages/image_picker)
- [flutter_image_compress](https://pub.dev/packages/flutter_image_compress)
- [photo_view](https://pub.dev/packages/photo_view)
- [logging](https://pub.dev/packages/logging)
- [jwt_decoder](https://pub.dev/packages/jwt_decoder)
- [bcrypt](https://pub.dev/packages/bcrypt)
- [http](https://pub.dev/packages/http)

## Design

The app uses a custom Garage Theme defined in `lib/ui/core/themes/garage_theme.dart`.
