# Flutter Instagram Clone

A fully vibe-coded clone of the Instagram mobile app, built as a proof of concept with [opencode](https://opencode.ai) (GLM 5.3). No hand-written code — everything is AI-generated, piece by piece.

## Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter |
| State management | BLoC / Cubits (`flutter_bloc`) |
| Navigation | `go_router` |
| Models / immutability | `freezed` + `json_serializable` |
| DI | `get_it` |
| Functional error handling | `fpdart` (`Either`) |
| Backend | Firebase — Auth, Cloud Firestore, Cloud Storage |

## Feature Roadmap

Built incrementally, one phase at a time:

- [x] **Phase 1 — Foundation**: Firebase wiring, auth (email + Google), signup/login/onboarding, user profile creation
- [ ] **Phase 2 — Posts & Feed**: image posts (gallery/camera), home feed, like, comment
- [ ] **Phase 3 — Social Graph**: follow/unfollow, profile grid, followers/following lists
- [ ] **Phase 4 — Stories**: 24h stories, story creation, story viewer
- [ ] **Phase 5 — Explore & Search**: explore grid, user & hashtag search
- [ ] **Phase 6 — Notifications**: likes, comments, follows
- [ ] **Phase 7 — Reels**: short video posts, vertical feed
- [ ] **Phase 8 — Direct Messages**: 1:1 chat, real-time

## Firebase Setup

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password + Google providers)
3. Create a **Firestore** database (start in test mode for the POC)
4. Enable **Cloud Storage**
5. Configure the FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` (git-ignored) used by `main.dart`.

## Architecture

This project follows a **Feature-based Clean Architecture** pattern:

- **Data Layer**: DTOs, Data Sources, and Repository implementations.
- **Domain Layer**: Models, Repository interfaces, and Domain Services (Business Logic).
- **Presentation Layer**: Cubits (State Management), Screens, and Widgets.

Dependencies flow inward only: `presentation → domain ← data`.

## Project Structure

```text
lib/
├── main.dart              # runApp() only — no wiring, no logic
├── app.dart               # MaterialApp.router configuration
├── core/
│   ├── di/
│   │   └── service_locator.dart   # All DI wiring
│   ├── router/
│   │   ├── app_router.dart
│   │   └── route_constants.dart
│   ├── models/            # Shared domain models only (freezed)
│   └── utils/
└── features/
    └── [feature_name]/
        ├── data/
        │   ├── datasources/       # Local/remote data sources
        │   ├── models/            # DTOs (data transfer objects)
        │   └── repositories/      # Repository implementations
        ├── domain/
        │   ├── models/            # Feature models (freezed)
        │   ├── repositories/      # Repository interfaces
        │   └── services/          # Domain coordination logic
        └── presentation/
            ├── bloc/               # Cubits + states
            ├── screens/
            └── widgets/
```

## CLI Tools

The following utility scripts are available in the `scripts/` folder:

| Script | Purpose |
|--------|---------|
| `./scripts/fgen.sh "name"` | **Generate New Feature**: Creates all Clean Architecture boilerplate and runs code generation. |
| `./scripts/fstr.sh "key" "FR" "EN"` | **Add Localization**: Adds a new key to both French and English `.arb` files. |
| `./scripts/fanal.sh` | **Audit**: Generates a code quality and architecture report. |
| `./scripts/fdead.sh` | **Dead Code**: Identifies unused files in the project. |
| `./scripts/fimp.sh` | **Fix Imports**: Automatically converts package imports to relative imports. |

## Development Commands

```bash
# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run code generation (Freezed/JSON)
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Run the app
flutter run
```

## Adding a New Feature

To add a new feature, use the generation script:

```bash
./scripts/fgen.sh my_new_feature
```

After generation, register your new classes in `lib/core/di/service_locator.dart` and add routes in `lib/core/router/app_router.dart`.
