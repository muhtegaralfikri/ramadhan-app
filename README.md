# Masjid App - Aplikasi Transparansi Masjid

Aplikasi mobile untuk transparansi dan pengelolaan aktivitas masjid dengan fitur:
- 🔐 Autentikasi Admin untuk pengelolaan data
- 📊 Pencatatan Zakat (Maal & Fitrah) dengan tracking
- 📅 Tracker Puasa Ramadan 30 hari
- ⏰ Jadwal Sholat 5 waktu
- 🍽️ Info Menu Buka Puasa
- 👥 Role-based access (Admin & User biasa)

## Tech Stack

- **Frontend**: Flutter 3.9.2+
- **Backend**: Supabase (PostgreSQL + Real-time + Auth)
- **State Management**: StatefulWidget (native Flutter state)
- **Location**: Geolocator (untuk fitur jadwal sholat berbasis lokasi)
- **Date Formatting**: Intl
- **Local Storage**: Shared Preferences

## Getting Started

### Prerequisites

1. Flutter SDK (3.9.2 or higher)
2. Android Studio / VS Code (for development)
3. Supabase Account dan Project

### Setup

1. Clone atau buka proyek:
```bash
cd ramadan_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Setup Supabase:
   - Pastikan proyek Supabase sudah ada dengan table yang sesuai
   - Konfigurasi sudah ada di `lib/config/supabase_config.dart`
   - Jika menggunakan proyek sendiri, update `lib/config/supabase_config.dart`:
```dart
static String get supabaseUrl => 'YOUR_SUPABASE_URL';
static String get supabaseAnonKey => 'YOUR_SUPABASE_ANON_KEY';
```

4. Buat tables di Supabase SQL Editor:
```sql
-- Zakat Table
CREATE TABLE zakat (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
  amount NUMERIC NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('maal', 'fitrah')),
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  note TEXT
);

-- Enable RLS (Row Level Security)
ALTER TABLE zakat ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public select" ON zakat FOR SELECT TO public USING (true);
CREATE POLICY "Admin insert" ON zakat FOR INSERT TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Admin update" ON zakat FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Admin delete" ON zakat FOR DELETE TO authenticated USING (true);

-- Puasa Table (opsional, saat ini menggunakan local storage)
CREATE TABLE puasa (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  is_fasting BOOLEAN NOT NULL,
  type TEXT,
  note TEXT
);

-- Jadwal Sholat Table (opsional, saat ini menggunakan mock data)
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

-- Menu Buka Table (opsional, saat ini menggunakan mock data)
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
│   └── supabase_config.dart          # Supabase configuration
├── models/                            # Data models
│   ├── zakat.dart                    # Zakat model dengan kalkulator
│   ├── puasa.dart                    # Puasa model
│   ├── jadwal.dart                   # Jadwal sholat model
│   └── menu.dart                     # Menu buka puasa model
├── screens/                           # UI Screens
│   ├── auth/
│   │   └── login_screen.dart         # Login screen for admin
│   ├── home/
│   │   └── home_screen.dart          # Main home screen with role-based access
│   ├── zakat/
│   │   ├── zakat_list_screen.dart    # List & summary zakat
│   │   └── zakat_screen.dart         # Form tambah/edit zakat
│   ├── puasa/
│   │   └── puasa_screen.dart         # 30 hari puasa tracker
│   ├── jadwal/
│   │   └── jadwal_screen.dart        # Jadwal sholat 5 waktu
│   └── menu_buka/
│       └── menu_screen.dart          # Info lokasi takjil
├── services/                          # Business logic & API
│   ├── auth_service.dart              # Authentication service
│   ├── zakat_service.dart             # Zakat CRUD operations
│   ├── puasa_service.dart             # Puasa service
│   ├── jadwal_service.dart            # Jadwal sholat service
│   └── menu_service.dart              # Menu service
├── widgets/                           # Reusable widgets (kosong saat ini)
└── main.dart                          # App entry point & auth state management
```

## Features

### 1. Autentikasi Admin
- Login dengan email dan password via Supabase Auth
- Role-based access: Admin vs User biasa
- Session persistence dan logout
- Auto-redirect berdasarkan role

### 2. Pencatatan Zakat
- Tambah, lihat, dan hapus data zakat (untuk Admin)
- Support Zakat Maal & Fitrah
- Format currency Rupiah
- Summary total zakat maal dan fitrah
- List riwayat zakat dengan tanggal dan catatan
- Filter berdasarkan role (Admin: full CRUD, User: read-only)

### 3. Tracker Puasa
- Track 30 hari puasa Ramadan
- Progress indicator (persentase)
- Mark/unmark hari puasa dengan switch
- Statistik: total hari, selesai, progress

### 4. Jadwal Sholat
- Jadwal 5 waktu sholat (Subuh, Dzuhur, Ashar, Maghrib, Isya)
- Navigasi tanggal (previous/next day)
- Mock data untuk saat ini (akan diintegrasikan dengan API)
- Fitur notifikasi (coming soon)

### 5. Menu Buka Puasa
- Info lokasi masjid, musholla, posko, dan rumah yang menyediakan takjil
- Detail: alamat, menu, waktu, kuota
- Mock data untuk saat ini
- Fitur tambah lokasi (coming soon)
- Fitur QR Code untuk konfirmasi (coming soon)

## Deployment

### Play Store (Android)
```bash
flutter build apk --release
flutter build appbundle --release
```
Upload AAB ke Google Play Console ($25 one-time fee)

### App Store (iOS)
```bash
flutter build ios --release
```
Upload IPA via Xcode ($99/year)

### Web
```bash
flutter build web --release
```
Deploy ke Firebase Hosting, Vercel, atau Netlify

## Contributing

Kontribusi diperlukan untuk mengembangkan aplikasi ini. Langkah-langkah:

1. Fork proyek ini
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Roadmap

- [ ] Integrasi API jadwal sholat (Aladhan API atau sejenisnya)
- [ ] Notifikasi sholat
- [ ] Integrasi database untuk fitur Puasa dan Menu Buka
- [ ] Fitur tambah lokasi Menu Buka
- [ ] QR Code untuk konfirmasi Menu Buka
- [ ] Dark mode
- [ ] Multi-language support (Bahasa Indonesia, English)
- [ ] Export data ke PDF/Excel
- [ ] Analytics dashboard untuk admin

## Notes

- Pastikan Flutter SDK sudah terinstall (minimum 3.9.2)
- Untuk iOS development, diperlukan Mac dan Xcode
- Supabase free tier cukup untuk development dan production kecil
- Pastikan permission location sudah diatur di `android/app/src/main/AndroidManifest.xml` dan `ios/Runner/Info.plist`
- Aplikasi ini menggunakan StatelessWidget dan StatefulWidget untuk state management (tanpa provider/bloc)

