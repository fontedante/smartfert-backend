# SmartFert — Soil Monitoring & Fertilizer Recommendation

SmartFert adalah aplikasi mobile berbasis Flutter yang dirancang untuk memantau kondisi tanah secara real-time dan memberikan rekomendasi pemupukan yang presisi. Aplikasi ini membantu petani, pelaku agribisnis, maupun pehobi tanaman untuk mengoptimalkan kesehatan tanah dan efisiensi penggunaan pupuk.

---

## 🌟 Fitur Utama

- **Real-time Soil Monitoring**: Memantau parameter penting tanah secara berkala seperti:
  - **pH Tanah** (Mengukur tingkat keasaman tanah untuk kesuburan optimal).
  - **Kelembaban Tanah** (Indikator kecukupan air dalam tanah).
  - **EC Tanah (Electrical Conductivity)** (Mengukur kadar salinitas/kandungan nutrisi tanah).
  - **Curah Hujan** (Estimasi air dari lingkungan luar).
- **Interactive Moisture Gauge**: Tampilan visual interaktif pada halaman utama yang menunjukkan tingkat kelembaban tanah saat ini beserta statusnya (misal: "Cukup", "Kurang", dll.).
- **Smart Fertilizer Recommendation**: Sistem kalkulasi otomatis untuk memberikan dosis pupuk yang tepat (contoh: gram per pokok tanaman) berdasarkan kondisi parameter tanah terbaru.
- **Pull-to-Refresh & Simulative Update**: Sinkronisasi data terkini dengan transisi animasi yang halus saat melakukan penyegaran (*refresh*) data.
- **Premium UI/UX Design**: Desain antarmuka modern yang bersih, menggunakan font *Outfit* dari Google Fonts, ikon dari *Iconsax*, transisi halaman kustom yang estetik, dan efek animasi *micro-interactions*.

---

## 🛠️ Teknologi & Pustaka

Aplikasi ini dibangun menggunakan teknologi terbaru di ekosistem Flutter:
- **Flutter SDK** (Versi SDK `>=3.10.7`)
- **Google Fonts (Outfit)** untuk tipografi modern dan premium.
- **Iconsax Flutter** untuk ikon navigasi dan informasi sensor yang seragam.
- **Percent Indicator** untuk visualisasi gauge kelembaban tanah.
- **Flutter Native Splash** untuk halaman pembuka (*splash screen*) aplikasi yang responsif.
- **Flutter Launcher Icons** untuk generator ikon aplikasi secara otomatis.

---

## 📂 Struktur Proyek

```text
lib/
├── core/
│   ├── app_colors.dart      # Definisi palet warna aplikasi (Primary, Accent, Text, dll.)
│   └── app_theme.dart       # Pengaturan tema global (Light Theme dengan Google Fonts Outfit)
├── pages/
│   ├── home_page.dart       # Halaman utama dengan Ringkasan Kelembaban & Menu Utama
│   ├── information_page.dart # Detail data sensor pH, Kelembaban, EC, dan Curah Hujan
│   └── recommendation_page.dart # Rekomendasi dosis pupuk & detail kondisi tanah
├── widgets/
│   ├── animated_list_item.dart # Pembungkus animasi masuk untuk daftar/widget
│   ├── menu_card.dart          # Komponen kartu menu interaktif
│   ├── moisture_gauge.dart     # Komponen gauge indikator kelembaban tanah
│   └── sensor_card.dart        # Komponen kartu penampil data sensor dan statusnya
└── main.dart                # Titik masuk utama (Main Entry Point) & Inisialisasi Splash
```

---

## 🚀 Memulai Pengembangan

### Prasyarat
Sebelum memulai, pastikan perangkat Anda telah terpasang:
- Flutter SDK (versi terbaru direkomendasikan)
- Java Development Kit (JDK) & Android SDK (untuk build Android)
- Xcode (untuk build iOS di macOS)

### Langkah Instalasi

1. **Clone Repository**
   ```bash
   git clone https://github.com/fontedante/smartfert.git  
   cd smart-fert
   ```

2. **Dapatkan Dependencies**
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi**
   Jalankan aplikasi pada emulator atau perangkat fisik yang terhubung:
   ```bash
   flutter run
   ```

4. **Build APK (Android)**
   Untuk membuild aplikasi ke dalam format APK produksi:
   ```bash
   flutter build apk --release
   ```
   *(Jika menggunakan FVM: `fvm flutter build apk --release`)*

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan monitoring dan otomasi pertanian presisi. Hak cipta dilindungi undang-undang.
