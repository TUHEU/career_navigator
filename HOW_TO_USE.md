# Career Navigator — Frontend DevOps Package

## What's inside
- .github/workflows/flutter.yml   → the CI/CD pipeline (replaces your old one)
- test/                           → 14 test files (one per source file)
- README_BADGE.md                 → optional build badge for your README

## Test files (14)
  validators_test.dart         core/utils/validators.dart
  helpers_test.dart            core/utils/helpers.dart
  user_model_test.dart         data/models/user_model.dart
  job_model_test.dart          data/models/job_model.dart
  chat_model_test.dart         data/models/chat_model.dart
  feedback_model_test.dart     data/models/feedback_model.dart
  mentor_model_test.dart       data/models/mentor_model.dart
  notification_model_test.dart data/models/notification_model.dart
  guest_provider_test.dart     providers/guest_provider.dart
  theme_provider_test.dart     providers/theme_provider.dart
  language_provider_test.dart  l10n/language_provider.dart
  app_strings_test.dart        l10n/app_strings.dart
  app_constants_test.dart      core/constants/app_constants.dart
  widget_test.dart             main.dart (app boots)

## Install (on your Flutter repo: TUHEU/career_navigator)
1. Delete the old test/ contents and copy in ALL files from this test/ folder.
2. Replace .github/workflows/flutter.yml with the one here.
3. (Optional) delete the stray deploy.yml from the Flutter repo — it's a backend file.
4. Commit & push:
     git add test .github
     git commit -m "Full frontend test suite + improved CI/CD"
     git push origin main
5. Open the Actions tab → watch it go green.

## Run tests locally first (recommended)
     flutter pub get
     flutter test
All tests should pass. If one fails on an exact string, tell me the message.
