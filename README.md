# SSW Kanji

A Flutter app for learning Japanese kanji, powered by Supabase.

## Features

- Browse kanji organized by categories (IRODORI Kanji, Parts 1-11, Adverbs, Question Words, Basic Kanji 320, Verb Exceptions)
- Real-time search across kanji, readings, and meanings
- Dark/Light theme toggle with persistence
- Font selector (Noto Sans JP, Noto Serif JP, Roboto)
- Responsive layout — single column on mobile, two-column grid on wider screens
- Expandable/collapsible category sections

## Setup

### 1. Supabase

1. Create a project at [supabase.com](https://supabase.com)
2. Run the SQL schema and seed data from the plan file or create the `categories` and `kanji_items` tables manually
3. Copy your **Project URL** and **Anon Key** from Settings > API

### 2. Configure the app

Create `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String url = 'https://YOUR_PROJECT.supabase.co';
  static const String anonKey = 'YOUR_ANON_KEY';
}
```

### 3. Run

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # Entry point, Supabase init
├── app.dart                     # MaterialApp with Material 3 theming
├── config/
│   └── supabase_config.dart     # Supabase credentials (gitignored)
├── models/
│   ├── category.dart            # Category model
│   └── kanji_item.dart          # KanjiItem model
├── services/
│   └── kanji_service.dart       # Supabase data fetching
├── providers/
│   └── app_state.dart           # App state (theme, search, data)
├── screens/
│   └── home_screen.dart         # Main screen
└── widgets/
    ├── category_card.dart       # Expandable category section
    ├── kanji_item_tile.dart     # Kanji display card
    ├── search_bar_widget.dart   # Search input
    ├── theme_toggle.dart        # Dark/light toggle
    └── font_selector.dart       # Font picker
```

## Tech Stack

- **Flutter** with Material 3
- **Supabase** for data storage
- **Provider** for state management
- **Google Fonts** for Japanese font support
