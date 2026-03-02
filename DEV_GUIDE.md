# Hamster's Stash — Developer Guide

## Prerequisites
- **Flutter** 3.41.x (stable channel)
- **Dart** 3.11.x
- **Xcode** (for iOS) — after install:
  ```bash
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  ```
- **Android Studio** (for Android):
  ```bash
  brew install --cask android-studio
  flutter doctor --android-licenses
  ```
- **CocoaPods** (for iOS plugins):
  ```bash
  brew install cocoapods
  ```

## Getting Started

```bash
# Clone the repo
git clone git@github.com:yun-20459/Hamster-Stash.git
cd Hamster-Stash

# Install dependencies
flutter pub get

# Generate Isar code (required after modifying any @collection)
dart run build_runner build --delete-conflicting-outputs

# Verify setup
flutter doctor
flutter test
flutter run -d chrome
```

## Git Workflow

1. Work on the `erin_develop` branch (or your own feature branch off it).
2. **Never commit directly to `main`.**
3. Commit after completing each logical task.
4. Create PRs from your branch → `main`.

```bash
git checkout erin_develop
# ... make changes ...
git add <files>
git commit -m "Description of changes"
git push origin erin_develop
```

## Code Generation (Isar)

Isar v3 uses `build_runner` to generate `.g.dart` files from `@collection` annotated classes. After modifying any collection in `lib/core/database/collections/`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Important:** The generated `.g.dart` files are committed to the repo so that other developers don't need to run build_runner just to build the app.

## Project Architecture

### Feature-First Structure
Each feature under `lib/features/<feature>/` follows clean architecture:

```
feature/
  data/
    datasources/    # Local/remote data sources
    models/         # Data models (DTOs)
    repositories/   # Repository implementations
  domain/
    entities/       # Business entities
    repositories/   # Repository interfaces (abstract)
    usecases/       # Business logic
  presentation/
    providers/      # Riverpod providers
    screens/        # Full-page screens
    widgets/        # Reusable UI components
```

### State Management (Riverpod)
We use `flutter_riverpod` **without code generation**. Define providers manually:

```dart
// Example: a simple state provider
final counterProvider = StateProvider<int>((ref) => 0);

// Example: an async provider
final accountsProvider = FutureProvider<List<Account>>((ref) async {
  final isar = await DatabaseHelper.instance;
  return isar.accounts.where().findAll();
});
```

> `riverpod_generator` and `@riverpod` annotations are NOT available due to analyzer version conflicts with Isar v3.

### Navigation (go_router)
Routes are defined in `lib/app.dart` using `StatefulShellRoute.indexedStack` for 4 bottom tabs:
- `/accounts` — Accounts
- `/transactions` — Transactions
- `/budget` — Budget
- `/reports` — Reports

To add a new route, edit the `GoRouter` definition in `app.dart`.

### Database (Isar v3)
- Collections are in `lib/core/database/collections/`
- Enums are in `lib/core/database/enums.dart`
- Database is initialized via `DatabaseHelper.instance` (singleton, lazy)
- Encryption key is stored in `flutter_secure_storage`

To add a new collection:
1. Create a new file in `lib/core/database/collections/`
2. Define the class with `@collection` annotation
3. Add the schema to `DatabaseHelper._openDatabase()` schemas list
4. Run `dart run build_runner build --delete-conflicting-outputs`

### Theme
- Colors: `AppColors` in `lib/core/theme/app_colors.dart`
- Theme: `AppTheme.light` in `lib/core/theme/app_theme.dart`
- Use `Theme.of(context)` to access theme data in widgets

## Testing

```bash
# Run unit/widget tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

Use `mocktail` for mocking (not `mockito`):

```dart
import 'package:mocktail/mocktail.dart';

class MockIsar extends Mock implements Isar {}
```

## Building

```bash
# Web
flutter build web

# Android (requires Android Studio setup)
flutter build apk

# iOS (requires Xcode setup)
flutter build ios
```

## Troubleshooting

### `build_runner` fails with analyzer errors
Isar v3 requires `analyzer <6.0.0`. If you add a dependency that needs a newer analyzer, it will conflict. Check compatibility before adding new codegen packages.

### `flutter doctor` shows Xcode/Android issues
These are required only for iOS/Android builds. Web builds work without them:
```bash
flutter run -d chrome
```

### Isar encryption key issues
The encryption key is stored in `flutter_secure_storage`. If the key is lost (e.g. app reinstall on a real device), the database cannot be decrypted. This is expected — the database will need to be recreated.
