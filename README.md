# First Klick — GPS Running Tracker

A Flutter app that records runs with GPS, connects to a Bluetooth heart rate monitor, and uploads completed activities to Strava.

---

## Features

- Live GPS tracking (route, distance, pace, speed)
- Bluetooth heart rate monitor (CooSpo H808S / standard GATT 0x180D)
- Foreground background service — continues recording when app is minimised
- Persistent notification with live stats
- Interactive live map (OpenStreetMap, no API key required)
- SQLite storage via Drift
- Strava OAuth 2.0 upload (GPX)

---

## Setup

### 1. Prerequisites

- Flutter SDK ≥ 3.5.0
- Android Studio / Xcode for device targets

### 2. Strava API credentials

1. Go to <https://www.strava.com/settings/api> and create an application.
2. Set the **Authorization Callback Domain** to `firstklick`.
3. Fill in your `.env` at the project root (already created as a template):

```
STRAVA_CLIENT_ID=12345
STRAVA_CLIENT_SECRET=your_secret_here
STRAVA_REDIRECT_SCHEME=firstklick
```

> `.env` is in `.gitignore` — never commit it.

### 3. Install dependencies & run code generation

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the app

```bash
flutter run
```

---

## Project structure

```
lib/
  main.dart                   # Entry point
  app.dart                    # MaterialApp + go_router
  core/
    database/                 # Drift DB, tables, DAOs
    background/               # Foreground service + IPC messages
    ble/                      # BLE + HR parsing (GATT 0x2A37)
    gps/                      # Geolocator + Haversine
    strava/                   # OAuth, token storage, API client, GPX
  features/
    home/                     # Activity list
    recording/                # Live recording screen
    activity_detail/          # Detail + splits + upload
    settings/                 # Strava connect + BLE scan modal
  shared/
    theme/                    # Dark theme, colours, text styles
```

---

## Permissions

**Android** (`AndroidManifest.xml`): `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `POST_NOTIFICATIONS`.

**iOS** (`Info.plist`): `NSLocationAlwaysAndWhenInUseUsageDescription`, `NSBluetoothAlwaysUsageDescription`, background modes `location` + `bluetooth-central`.

---

## Tech stack

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` + `riverpod_annotation` |
| Database | `drift` + `drift_flutter` |
| Background service | `flutter_background_service` |
| GPS | `geolocator` |
| BLE | `flutter_blue_plus` |
| Maps | `flutter_map` (OpenStreetMap) |
| HTTP | `dio` |
| Strava OAuth | `flutter_web_auth_2` |
| Secure storage | `flutter_secure_storage` |
| Navigation | `go_router` |
| Env variables | `flutter_dotenv` |

---

## Code generation

After any change to `@riverpod` or Drift-annotated files:

```bash
dart run build_runner build --delete-conflicting-outputs
# or in watch mode:
dart run build_runner watch --delete-conflicting-outputs
```
