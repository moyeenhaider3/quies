---
wave: 1
depends_on: []
files_modified:
  - lib/main.dart
  - pubspec.yaml
  - lib/core/
  - lib/features/onboarding/
autonomous: true
---

# Phase 1: Foundation & Onboarding Plan

## Goal
Establish the project structure, local storage, and the complete onboarding flow (Welcome -> Quiz -> Home Transition).

## Architecture
- **State Management:** flutter_bloc
- **Navigation:** go_router
- **DI:** get_it + injectable
- **Local Storage:** hive

## Tasks

### Wave 1: Project Setup & Core Infrastructure

<task>
<description>
Initialize project dependencies and core structure.
</description>
<steps>
1.  Add dependencies to `pubspec.yaml`:
    - `flutter_bloc`, `go_router`, `get_it`, `injectable`, `hive`, `hive_flutter`, `path_provider`
    - `google_fonts`, `flutter_animate` (for UI)
    - `build_runner`, `injectable_generator`, `hive_generator` (dev)
2.  Create folder structure: `lib/core`, `lib/features`, `lib/data`.
3.  Set up `get_it` and `injectable` configuration in `lib/core/di/injection.dart`.
4.  Configure `go_router` in `lib/core/router/app_router.dart` with initial routes (`/`, `/onboarding`, `/home`).
5.  Initialize `Hive` in `main.dart` and register adapters (even if empty for now).
</steps>
<verification>
- App runs without errors.
- `flutter packages get` succeeds.
</verification>
</task>

### Wave 2: Theming & Local Storage

<task>
<description>
Define the app theme and set up user preferences storage.
</description>
<steps>
1.  Create `AppTheme` class with light/dark modes using the palette (Deep Indigo, Soft Sage).
2.  Create `UserPreferencesService` (Hive wrapper) to store:
    - `onboarding_completed` (bool)
    - `mood` (String?)
    - `themes` (List<String>)
    - `goals` (List<String>)
3.  Register service in DI.
</steps>
<verification>
- Can save and read `onboarding_completed` flag from Hive.
- App displays correct background color from theme.
</verification>
</task>

### Wave 3: Onboarding Feature (UI & Logic)

<task>
<description>
Implement the Onboarding screens and logic.
</description>
<steps>
1.  Create `OnboardingCubit` to manage state (page index, selected options).
2.  Create `OnboardingPage` with `PageView`:
    - **Page 1 (Welcome):** "Take a deep breath" text + animation. "Start" button.
    - **Page 2 (Quiz):** Simple multi-select for "What brings you peace?" (Nature, Wisdom, etc).
    - **Page 3 (Completion):** "Your journey begins".
3.  Implement "Skip" button logic (sets `onboarding_completed = true`, navigates to `/home`).
4.  Implement "Finish" logic (saves preferences, sets `onboarding_completed`, navigates to `/home`).
5.  Add `HomeShell` (placeholder) to verify navigation works.
</steps>
<verification>
- Launching app -> Welcome Screen.
- "Skip" -> Home Screen.
- Relax/Restart -> Welcome Screen (if data cleared) or Home Screen (if persisted).
</verification>
</task>

## Verification Plan
1.  **Automated:** Run `flutter test` (setup basic smoke tests for Cubit).
2.  **Manual:**
    - Clean install: Verifies Onboarding flow.
    - Restart app: Verifies persistence (skips onboarding).
