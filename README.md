# Dobovky

Flutter mobile application for my blog (iOS, Android, Windows).

## Project Structure

```
dobovky/
├── lib/
│   ├── main.dart                    # App entry point & routing
│   ├── models/
│   │   └── post_model.dart          # Post, User, Comment data models
│   ├── services/
│   │   └── api_service.dart         # HTTP client for backend API
│   └── screens/
│       ├── blog_list_screen.dart    # Posts list (home screen)
│       ├── post_detail_screen.dart  # Single post view
│       ├── add_post_screen.dart     # Create / edit post (admin)
│       └── login_screen.dart        # Admin JWT login
├── backend/
│   ├── server.js                    # Express REST API
│   ├── db.js                        # PostgreSQL connection
│   ├── schema.sql                   # Database schema
│   ├── package.json                 # Node.js dependencies
│   └── .env.example                 # Environment variables template
├── pubspec.yaml                     # Flutter dependencies
├── railway.json                     # Railway deployment config
└── Procfile                         # Process definition for Railway
```

## Flutter App Setup

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.x
- Dart SDK ≥ 2.17

### Installation

```bash
# Install Flutter dependencies
flutter pub get

# Run on connected device / emulator
flutter run

# Build for release (Android)
flutter build apk

# Build for release (iOS)
flutter build ios

# Build for Windows
flutter build windows
```

### API Configuration

By default the app connects to `http://localhost:3000`.

To point to your Railway deployment, build with the `API_BASE_URL` environment variable:

```bash
flutter run --dart-define=API_BASE_URL=https://<your-app>.railway.app
```

Or set it permanently in `lib/services/api_service.dart`:

```dart
static const String baseUrl =
    String.fromEnvironment('API_BASE_URL', defaultValue: 'https://<your-app>.railway.app');
```

## Backend Setup (Local)

```bash
cd backend
cp .env.example .env   # fill in your values
npm install
node server.js
```

## Railway Deployment

1. Push the repository to GitHub.
2. Connect the repo to a new Railway project.
3. Railway will detect `railway.json` and deploy the backend automatically.
4. Add a PostgreSQL plugin and set the `DATABASE_URL` environment variable.
5. Set `JWT_SECRET` in the Railway dashboard.

## Features

- 📋 Browse all blog posts
- 📄 Read full post content
- 🔐 Admin login with JWT authentication
- ✏️ Create new posts (admin)
- 🖊️ Edit existing posts (admin)
- 🗑️ Delete posts (admin)
- 🔄 Pull-to-refresh post list
- ⚠️ Error handling & loading states

