# Ramadan App

Aplikasi mobile untuk membantu ibadah Ramadan dengan fitur:
- 📊 Kalkulator Zakat (Maal & Fitrah)
- 📅 Tracker Puasa Ramadan
- ⏰ Jadwal Sholat
- 🍽️ Info Menu Buka Puasa

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Supabase (PostgreSQL + Real-time + Auth)
- **State Management**: Flutter Bloc
- **Location**: Geolocator

## Getting Started

### Prerequisites

1. Flutter SDK (3.35.4 or higher)
2. Android Studio / Xcode (for mobile development)
3. Supabase Account

### Setup

1. Clone or open project:
```bash
cd ramadan_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Setup Supabase:
   - Create new project at [supabase.com](https://supabase.com)
   - Go to Project Settings > API
   - Copy your Project URL and Anon Key
   - Update `lib/config/supabase_config.dart`:
```dart
static String get supabaseUrl => 'YOUR_SUPABASE_URL';
static String get supabaseAnonKey => 'YOUR_SUPABASE_ANON_KEY';
```

4. Create tables in Supabase SQL Editor:
```sql
-- Zakat Table
CREATE TABLE zakat (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
  amount NUMERIC NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('maal', 'fitrah')),
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  note TEXT
);

-- Puasa Table
CREATE TABLE puasa (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  is_fasting BOOLEAN NOT NULL,
  type TEXT,
  note TEXT
);

-- Jadwal Sholat Table
CREATE TABLE jadwal_sholat (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  subuh TEXT NOT NULL,
  dzuhur TEXT NOT NULL,
  ashar TEXT NOT NULL,
  maghrib TEXT NOT NULL,
  isya TEXT NOT NULL,
  location TEXT
);

-- Menu Buka Table
CREATE TABLE menu_buka (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
  location_name TEXT NOT NULL,
  address TEXT,
  menu TEXT,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  contact TEXT,
  capacity INTEGER,
  image_url TEXT
);
```

5. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── config/
│   └── supabase_config.dart      # Supabase configuration
├── models/                        # Data models
│   ├── zakat.dart
│   ├── puasa.dart
│   ├── jadwal.dart
│   └── menu.dart
├── screens/                       # UI Screens
│   ├── home/
│   ├── zakat/
│   ├── puasa/
│   ├── jadwal/
│   └── menu_buka/
├── services/                      # Business logic & API
│   ├── zakat_service.dart
│   ├── puasa_service.dart
│   ├── jadwal_service.dart
│   └── menu_service.dart
├── widgets/                       # Reusable widgets
└── main.dart                      # App entry point
```

## Features

### 1. Kalkulator Zakat
- Hitung Zakat Maal (2.5% dari total harta)
- Hitung Zakat Fitrah (2.5 kg beras per orang)
- Tracking history zakat

### 2. Tracker Puasa
- Track 30 hari puasa Ramadan
- Progress indicator
- History tracking

### 3. Jadwal Sholat
- Jadwal 5 waktu sholat
- Berdasarkan lokasi
- Notifikasi sholat (coming soon)

### 4. Menu Buka Puasa
- Info lokasi masjid/rumah yang menyediakan takjil
- Detail menu dan kuota
- QR Code untuk konfirmasi (coming soon)

## Deployment

### Play Store (Android)
```bash
flutter build apk --release
flutter build appbundle --release
```
Upload AAB to Google Play Console ($25 one-time fee)

### App Store (iOS)
```bash
flutter build ios --release
```
Upload IPA via Xcode ($99/year)

## Notes

- Pastikan Flutter SDK sudah terinstall
- Untuk iOS development, diperlukan Mac
- Supabase free tier cukup untuk development dan small production
- Pastikan permission location sudah diatur di AndroidManifest.xml dan Info.plist

