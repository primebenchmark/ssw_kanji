# SSW Kanji

A Flutter app for learning Japanese kanji, powered by Supabase.

## Features

- Browse kanji organized by categories (IRODORI Kanji, Parts 1-11, Adverbs, Question Words, Basic Kanji 320, Verb Exceptions)
- Real-time search across kanji, readings, and meanings
- Dark/Light theme toggle with persistence
- Font selector (50+ fonts via Google Fonts)
- Responsive layout — single column on mobile, two-column grid on wider screens
- Expandable/collapsible category sections
- Settings screen with font, theme, and app config options
- Admin panel (PIN-protected, 10-tap unlock) for managing remote app configuration
- Daily push notifications via Firebase Cloud Messaging
- Privacy policy and support screens

## Setup

### 1. Supabase

1. Create a project at [supabase.com](https://supabase.com)
2. Run the SQL schema and seed data to create the `categories`, `kanji_items`, and `app_config` tables
3. Copy your **Project URL** and **Anon Key** from Settings > API

### 2. Configure the app

Create `lib/config/supabase_config.dart` (this file is gitignored):

```dart
class SupabaseConfig {
  static const String url = 'https://YOUR_PROJECT.supabase.co';
  static const String anonKey = 'YOUR_ANON_KEY';
}
```

### 3. Firebase (optional — for push notifications)

- Add `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` (both gitignored)
- These files are obtained from the Firebase console

### 4. Run

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart                        # Entry point, Supabase + notification init
├── app.dart                         # MaterialApp with Material 3 theming
├── config/
│   └── supabase_config.dart         # Supabase credentials (gitignored)
├── models/
│   ├── app_config.dart              # Remote app config model
│   ├── category.dart                # Category model
│   └── kanji_item.dart              # KanjiItem model
├── providers/
│   └── app_state.dart               # App state (theme, font, search, data, config)
├── screens/
│   ├── admin_panel_screen.dart      # PIN-protected admin panel
│   ├── home_screen.dart             # Main browsing screen
│   ├── privacy_policy_screen.dart   # Privacy policy
│   ├── settings_screen.dart         # User settings (font, theme)
│   └── support_screen.dart          # Support / contact screen
├── services/
│   ├── kanji_service.dart           # Supabase data fetching
│   └── notification_service.dart    # Firebase push notification setup
└── widgets/
    ├── category_card.dart           # Expandable category section
    ├── font_selector.dart           # Font picker
    ├── kanji_item_tile.dart         # Kanji display card
    ├── search_bar_widget.dart       # Search input
    └── theme_toggle.dart            # Dark/light toggle
```

## Tech Stack

- **Flutter** with Material 3
- **Supabase** for data storage and remote app config
- **Provider** for state management
- **Google Fonts** for Japanese font support
- **Firebase Cloud Messaging** for push notifications
