# Offlearn (Offline Learning)

**Learning tech untuk siswa di wilayah minim sinyal — belajar tetap jalan meski koneksi internet tidak stabil.**

> Status: Ide/Proposal — dikembangkan untuk kompetisi (Hackathon)

---

## Latar Belakang

Siswa di daerah pedesaan atau wilayah 3T sering tertinggal dalam pembelajaran digital karena koneksi internet yang tidak stabil. Platform edtech arus utama umumnya rakus kuota dan membutuhkan koneksi terus-menerus, sehingga tidak dapat diandalkan di wilayah dengan sinyal terbatas.

**Offlearn** hadir sebagai solusi mobile learning dengan arsitektur **offline-first**: materi (modul teks dan kuis) dapat diunduh sekali saat ada jaringan, lalu diakses dan dikerjakan sepenuhnya secara luring. Progres belajar siswa disimpan secara lokal dan disinkronkan otomatis ke server begitu perangkat kembali terhubung ke internet.

## Target Pengguna

- **Siswa** jenjang SD dan SMP sebagai pengguna utama
- **Guru/Admin** sebagai pengelola materi dan pemantau progres siswa

## Fitur

### MVP (Prioritas Pengembangan Awal)
- [ ] Modul belajar berbasis teks (dapat diunduh & dibaca offline)
- [ ] Kuis interaktif (dikerjakan offline, hasil disimpan lokal)
- [ ] Sinkronisasi otomatis progres belajar saat perangkat online
- [ ] Login siswa & guru (menggunakan Supabase Auth)
- [ ] Dashboard sederhana untuk guru/admin mengelola materi

### Rencana Pengembangan Selanjutnya (Belum Dikerjakan di MVP)
- [ ] Modul video pembelajaran (menyusul setelah manajemen local storage & ukuran cache tertata rapi)
- [ ] Dashboard analitik progres siswa yang lebih lengkap
- [ ] Notifikasi pengingat belajar
- [ ] Dukungan multi-bahasa/multi-daerah

> Catatan: Detail arsitektur teknis (skema database, alur sync, dsb.) akan didokumentasikan terpisah menyusul — README ini fokus pada gambaran umum proyek dulu.

## Tech Stack

| Komponen | Teknologi |
|---|---|
| Mobile & Web App | Flutter |
| Local Storage (Offline) | Hive / Hive CE |
| Backend | Node.js |
| Database | PostgreSQL (via Supabase) |
| Autentikasi | Supabase Auth (bawaan) |

*Versi spesifik (Flutter, Node.js, dsb.) akan ditambahkan setelah environment development ditentukan.*

## Struktur Repository

Proyek ini menggunakan struktur **monorepo**:

```
offlearn/
├── apps/
│   └── mobile/          # Aplikasi Flutter (mobile & web)
├── services/
│   └── backend/         # Backend Node.js
├── docs/                # Dokumentasi tambahan (arsitektur, API, dsb.)
└── README.md
```

> Struktur folder di atas adalah rencana awal dan dapat berubah menyesuaikan kebutuhan development.

## Getting Started

> Bagian ini masih kerangka awal — perintah dan detail konfigurasi akan dilengkapi begitu setup proyek berjalan.

### Prasyarat
- Flutter SDK 
- Node.js 
- Akun & project Supabase (untuk PostgreSQL + Auth)

### Environment Variables
Buat file `.env` di masing-masing folder (`apps/mobile` dan `services/backend`) berdasarkan `.env.example` (akan ditambahkan), berisi antara lain:
```
SUPABASE_URL=
SUPABASE_ANON_KEY=
DATABASE_URL=
Dalam pengembangan manual

```

## Roadmap Singkat

1. Finalisasi ide & arsitektur teknis
2. Setup project (monorepo, Supabase, skeleton Flutter + Node.js)
3. Bangun MVP: modul teks + kuis + sinkronisasi offline
4. Uji coba dengan simulasi koneksi minim sinyal
5. Iterasi berdasarkan feedback (hackathon judging / pengguna uji)

## Tim & Kontribusi

> TODO: Tambahkan daftar kontributor/anggota tim di sini.

Panduan kontribusi (jika proyek dibuka untuk kolaborasi lebih lanjut) akan ditambahkan menyusul.

## Lisensi

> TODO: Lisensi belum ditentukan.


NOTES : TAMBAHAN 

PERSIAPAN HACKATON SEVIMA 2026 : 

1. PRODUCT = BACKEND (NODEJS) + MULTIPLATFORM (FLUTTER WEB + MOBILE)


KEY FOCUS : 
- Menggunakan Code Yang sudah dipahami dan dipelajari
- Package Yang sudah dipahami dan di pelajari


==> REQUIREMENT BACKEND : MVP, JELAS, SUPPORT FRONTEND
==> REQUIREMENT MOBILE : MVP, PACKAGE SUPPORT MULTIPLATFORM


PACKAGE BACKEND : 
- nodemon
- express
- cors
- morgan
- helmet
- "@prisma/adapter-pg": "^7.10.0",
- "@prisma/client": "^7.10.0",
- "@supabase/supabase-js": "^2.116.0",
- "pg": "^8.23.0"


PACKAGE MOBILE : 
- hive
- get
- flutter_dotenv
- flutter_screenutil
- supabase_flutter
- google_fonts
- Tambahan untuk network checker