# Kinrai-D Frontend

Flutter mobile application for Kinrai-D food menu management and recommendation system. Provides a modern, intuitive interface for users to browse menus, manage preferences, and receive personalized recommendations.

## 🚀 Quick Start

### Prerequisites
- Flutter 3.8.1+
- Dart 3.8.0+
- Android SDK or Xcode (depending on target platform)
- Git

### Installation

```bash
# Get Flutter dependencies
flutter pub get

# Generate code from build runners
flutter pub run build_runner build

# Run on development device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

## 📱 Running the App

### Android
```bash
# Run on Android emulator/device
flutter run

# Build APK
flutter build apk

# Build App Bundle (for Play Store)
flutter build aab
```

### iOS
```bash
# Run on iOS simulator/device
flutter run

# Build IPA
flutter build ios
```

### Web
```bash
# Run on web
flutter run -d web

# Build web
flutter build web
```

## 🎨 Features

### User Features
- 🔐 **Authentication** - Supabase email/password and Google Sign-In
- 📋 **Menu Browsing** - View canteen menus with multi-language support
- ⭐ **Favorites** - Save favorite menus for quick access
- 🍽️ **Protein Preferences** - Exclude unwanted protein types
- 👎 **Dislike Tracking** - Mark disliked menus
- ⭐ **Ratings** - Rate menus and leave feedback
- 📊 **Personalized Recommendations** - Get menu suggestions
- 🔍 **Search** - Full-text search across menus
- 🌍 **Multi-Language** - Thai and English support
- 📈 **User Stats** - Track eating habits

## 📚 Project Structure

```
lib/
├── main.dart                # App entry point
├── app.dart                 # App configuration
├── core/
│  ├── api/
│  │  ├── api_client.dart    # HTTP client
│  │  └── api_endpoints.dart # Endpoints
│  ├── config/
│  │  └── supabase_config.dart # Supabase setup
│  ├── cache/
│  │  └── cache_service.dart # Local cache
│  ├── di/
│  │  └── injection.dart     # Dependency injection
│  ├── providers/
│  │  ├── auth_provider.dart # Auth state
│  │  └── language_provider.dart # Language
│  ├── theme/
│  │  └── app_theme.dart     # Theme config
│  └── l10n/
│     └── Localization files
├── features/
│  ├── auth/
│  │  ├── presentation/
│  │  ├── data/
│  │  └── domain/
│  ├── menus/
│  ├── favorites/
│  ├── ratings/
│  └── ...
└── pubspec.yaml
```

## 📦 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0
  supabase_flutter: ^2.5.6
  provider: ^6.1.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

## 🔌 API Integration

### Configuration
- Supabase credentials: `lib/core/config/supabase_config.dart`
- API endpoints: `lib/core/api/api_endpoints.dart`
- API client handles auth tokens automatically

## 🔐 Authentication

### Supabase Setup
1. Create Supabase project
2. Enable email/password authentication
3. Set up Google OAuth provider
4. Update credentials in config

## 💾 Local Storage

- **Hive**: Cache API responses
- **SharedPreferences**: App settings
- **Secure Storage**: Sensitive data (tokens)

## 🌐 Localization

### Supported Languages
- 🇹🇭 Thai (th_TH)
- 🇬🇧 English (en_US)

### Usage
```dart
Text(AppLocalizations.of(context)!.menuLabel)
```

## 📊 State Management

Using Provider pattern:
```dart
// Auth state
context.watch<AuthProvider>().currentUser

// Language state
context.watch<LanguageProvider>().currentLanguage
```

## 🧪 Testing

```bash
flutter test              # Unit tests
flutter test integration_test/  # Integration tests
```

## 🎯 Build

### Android
```bash
flutter build apk --release
flutter build aab --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🔍 Debugging

### Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Logging
```dart
import 'package:kinrai_d/core/utils/logger.dart';

AppLogger.debug('Message');
AppLogger.info('Message');
AppLogger.error('Message');
```

## 📝 Code Style

- Follow Dart style guide
- Use meaningful names
- Add comments for complex logic
- Test before commit

## 🤝 Contributing

1. Follow Dart style guide
2. Test features before commit
3. Use feature branches
4. Write meaningful commit messages

## 📖 Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Root README](../README.md)
- [Backend API](../backend/README.md)

## 📄 License

UNLICENSED - Private Project

---

**Version**: 1.0.0  
**Flutter Version**: 3.8.1+  
**Last Updated**: March 6, 2026
