# 🕌 Masjid App - Aplikasi Transparansi Masjid

Aplikasi mobile untuk transparansi dan pengelolaan aktivitas masjid dengan fitur lengkap untuk ibadah sehari-hari.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)
![License](https://img.shields.io/badge/License-MIT-blue)

## ✨ Fitur Utama

### 🔐 Autentikasi & Role
- Login admin dengan email/password via Supabase Auth
- Role-based access (Admin & User biasa)
- Session persistence & auto-redirect

### 📊 Pencatatan Zakat
- Pencatatan Zakat Maal & Fitrah
- Dashboard statistik dengan pie chart
- Riwayat transaksi lengkap
- Export laporan (Admin only)

### ⏰ Jadwal Sholat
- Jadwal 5 waktu sholat berdasarkan GPS
- Waktu countdown ke sholat berikutnya
- Berbasis lokasi real-time

### 🔔 Pengingat Sholat & Puasa
- Notifikasi 15 menit sebelum waktu sholat (Subuh, Dzuhur, Ashar, Maghrib, Isya)
- Pengingat sahur & berbuka puasa
- Konfigurasi waktu pengingat fleksibel

### 🧭 Kompas Kiblat
- Arah kiblat akurat berbasis GPS
- Kompas digital real-time
- **Kalkulator Ilmu Falak** untuk penentuan kiblat manual:
  - Input koordinat DMS (Derajat, Menit, Detik)
  - Perhitungan arah matahari & bayangan
  - Diagram kompas visual
  - Masa berlaku perhitungan

### 📅 Kalender Hijriah
- Konversi tanggal Masehi ke Hijriah
- Tampilan kalender bulanan
- Hari-hari penting Islam:
  - Tahun Baru Hijriah
  - Maulid Nabi
  - Isra Mi'raj
  - Awal Ramadan
  - Lailatul Qadr
  - Idul Fitri & Idul Adha

### 🍽️ Menu Buka Puasa
- Info lokasi takjil/buka bersama
- Detail menu, alamat, dan kapasitas

### 🕌 Profil Masjid
- Informasi masjid
- Fasilitas tersedia

## 🛠️ Tech Stack

| Teknologi | Kegunaan |
|-----------|----------|
| Flutter 3.9.2+ | Frontend Framework |
| Supabase | Backend (PostgreSQL + Auth) |
| flutter_compass | Sensor kompas |
| flutter_local_notifications | Push notifications |
| geolocator | GPS & lokasi |
| flutter_animate | Animasi UI |

## 📦 Dependencies

```yaml
dependencies:
  flutter_compass: ^0.8.0
  flutter_local_notifications: ^18.0.0
  timezone: ^0.9.2
  permission_handler: ^11.0.0
  geolocator: ^12.0.0
  geocoding: ^3.0.0
  supabase_flutter: ^2.5.4
  flutter_animate: ^4.5.0
  fl_chart: ^0.68.0
  google_fonts: ^6.2.1
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2+
- Android Studio / VS Code
- Supabase Account

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/ramadan_app.git
cd ramadan_app

# Install dependencies
flutter pub get

# Run app
flutter run
```

### Konfigurasi Supabase

Update `lib/config/supabase_config.dart`:
```dart
static String get supabaseUrl => 'YOUR_SUPABASE_URL';
static String get supabaseAnonKey => 'YOUR_SUPABASE_ANON_KEY';
```

## 📁 Project Structure

```
lib/
├── config/
│   └── supabase_config.dart
├── constants/
│   ├── app_colors.dart
│   └── app_dimensions.dart
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── calendar/
│   │   └── hijri_calendar_screen.dart
│   ├── qibla/
│   │   ├── qibla_screen.dart
│   │   └── falak_calculator_screen.dart
│   ├── jadwal/
│   │   └── jadwal_screen.dart
│   ├── zakat/
│   │   └── zakat_list_screen.dart
│   ├── settings/
│   │   └── reminder_settings_screen.dart
│   └── ...
├── services/
│   ├── auth_service.dart
│   ├── hijri_service.dart
│   ├── falak_service.dart
│   ├── qibla_service.dart
│   ├── notification_service.dart
│   ├── prayer_times_service.dart
│   └── location_service.dart
└── main.dart
```

## 📱 Screenshots

*Coming soon*

## 🗺️ Roadmap

- [x] Jadwal Sholat GPS-based
- [x] Kompas Kiblat
- [x] Kalkulator Ilmu Falak
- [x] Kalender Hijriah
- [x] Pengingat Sholat & Puasa
- [ ] Tasbih Digital
- [ ] Al-Quran Digital
- [ ] Dark Mode
- [ ] Multi-language (ID/EN/AR)

## 🤝 Contributing

1. Fork repository
2. Buat feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📞 Contact

Developed with ❤️ for Muslim Community
