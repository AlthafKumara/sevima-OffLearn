# ERD & Skema Database — Offlearn

> Dokumen ini merangkum rancangan database awal untuk MVP Offlearn (modul teks + kuis).
> Database: PostgreSQL via Supabase. Status: draft — bisa berubah seiring development.

---

## 1. Detail Tabel

### 1.1 `profiles`
Menyimpan data tambahan pengguna di luar yang dikelola Supabase Auth (`auth.users`). `id` **menyimpan nilai yang sama** dengan `auth.users.id`, tapi **tanpa foreign key constraint** ke tabel `auth.users` — relasi dijaga secara manual di level aplikasi (bukan di database), karena tabel `auth` berada di luar kendali migrasi Prisma dan tidak boleh dimodifikasi. Sinkronisasi ID dilakukan lewat endpoint `POST /users` (lihat bagian 7).

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid (PK) | Nilai sama dengan `auth.users.id`, di-generate & di-assign manual saat user dibuat — bukan FK |
| `role` | text (check: `'siswa'`, `'guru'`, `'admin'`) | Menentukan hak akses |
| `nama` | text | Nama lengkap |
| `kelas` | text, nullable | Diisi kalau role = siswa (misal "5A") |
| `created_at` | timestamptz | Default `now()` |

> Konsekuensi: tidak ada `on delete cascade` otomatis. Kalau user dihapus dari `auth.users`, baris di `profiles` harus dihapus/di-nonaktifkan secara eksplisit lewat endpoint aplikasi juga.

### 1.2 `subjects`
Lookup mata pelajaran, dipakai bersama oleh modul dan quiz.

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid (PK) | |
| `nama_subject` | text, unique | Misal "Matematika", "IPA" |

### 1.3 `modules`
Materi belajar berbasis teks.

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid (PK) | |
| `subject_id` | uuid (FK → subjects.id) | |
| `created_by` | uuid (FK → profiles.id) | Guru pembuat |
| `judul` | text | |
| `konten` | text | Bisa markdown/plain text |
| `target_kelas` | text | Misal "Kelas 5" |
| `versi` | integer, default 1 | Naik setiap kali konten diedit — dipakai app untuk cek update |
| `status` | text (check: `'draft'`, `'published'`) | |
| `urutan` | integer, nullable | Urutan belajar dalam satu subject |
| `updated_at` | timestamptz | Dipakai untuk delta sync (`updated_since`) |

### 1.4 `quizzes`
Metadata quiz.

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid (PK) | |
| `subject_id` | uuid (FK → subjects.id) | |
| `created_by` | uuid (FK → profiles.id) | |
| `nama_quiz` | text | |
| `target_kelas` | text | |
| `status` | text (check: `'draft'`, `'published'`) | |
| `updated_at` | timestamptz | |

### 1.5 `quiz_questions`
Soal-soal dalam satu quiz. Dipisah dari `quizzes` agar satu quiz bisa punya banyak soal (relasi one-to-many via `quiz_id`).

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid (PK) | |
| `quiz_id` | uuid (FK → quizzes.id) | |
| `pertanyaan` | text | |
| `tipe_soal` | text (check: `'pilihan_ganda'`, `'benar_salah'`) | MVP: fokus pilihan ganda dulu |
| `urutan` | integer | |

### 1.6 `quiz_options`
Pilihan jawaban untuk tiap soal. Dipisah dari `quiz_questions` supaya jumlah opsi fleksibel (2 untuk benar/salah, 4+ untuk pilihan ganda).

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid (PK) | |
| `question_id` | uuid (FK → quiz_questions.id) | |
| `teks_opsi` | text | |
| `is_benar` | boolean, default false | |

### 1.7 `student_progress`
Progres siswa terhadap modul (bukan quiz).

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid (PK) | Dibuat sebagai UUID di client (device), bukan auto-increment — untuk idempotency saat sync |
| `user_id` | uuid (FK → profiles.id) | |
| `module_id` | uuid (FK → modules.id) | |
| `status` | text (check: `'belum_dibaca'`, `'sedang_dibaca'`, `'selesai'`) | |
| `client_timestamp` | timestamptz | Waktu asli dari device, dipakai untuk resolusi konflik |

### 1.8 `quiz_attempts`
Satu baris per percobaan pengerjaan quiz (histori, bukan cuma skor terakhir).

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid (PK) | Dibuat di client (UUID) untuk idempotency |
| `user_id` | uuid (FK → profiles.id) | |
| `quiz_id` | uuid (FK → quizzes.id) | |
| `skor` | numeric | |
| `client_timestamp` | timestamptz | |

### 1.9 `quiz_answers`
Detail jawaban siswa per soal dalam satu attempt — berguna untuk review "soal mana yang salah".

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | uuid (PK) | |
| `attempt_id` | uuid (FK → quiz_attempts.id) | |
| `question_id` | uuid (FK → quiz_questions.id) | |
| `selected_option_id` | uuid (FK → quiz_options.id) | |

---

## 3. DDL PostgreSQL (Supabase)

```sql
-- Profiles (id disinkronkan manual dengan auth.users.id, tanpa FK constraint,
-- agar tidak perlu memodelkan schema auth di Prisma)
create table profiles (
  id uuid primary key,
  role text not null check (role in ('siswa','guru')),
  nama text not null,
  kelas text,
  created_at timestamptz default now()
);

-- Subjects
create table subjects (
  id uuid primary key default gen_random_uuid(),
  nama_subject text unique not null
);

-- Modules
create table modules (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid references subjects(id),
  created_by uuid references profiles(id),
  judul text not null,
  konten text not null,
  target_kelas text,
  versi integer default 1,
  status text default 'draft' check (status in ('draft','published')),
  urutan integer,
  updated_at timestamptz default now()
);

-- Quizzes
create table quizzes (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid references subjects(id),
  created_by uuid references profiles(id),
  nama_quiz text not null,
  target_kelas text,
  status text default 'draft' check (status in ('draft','published')),
  updated_at timestamptz default now()
);

-- Quiz Questions
create table quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid references quizzes(id) on delete cascade,
  pertanyaan text not null,
  tipe_soal text default 'pilihan_ganda' check (tipe_soal in ('pilihan_ganda','benar_salah')),
  urutan integer
);

-- Quiz Options
create table quiz_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid references quiz_questions(id) on delete cascade,
  teks_opsi text not null,
  is_benar boolean default false
);

-- Student Progress (modul)
create table student_progress (
  id uuid primary key,
  user_id uuid references profiles(id),
  module_id uuid references modules(id),
  status text check (status in ('belum_dibaca','sedang_dibaca','selesai')),
  client_timestamp timestamptz not null,
);

-- Quiz Attempts
create table quiz_attempts (
  id uuid primary key,
  user_id uuid references profiles(id),
  quiz_id uuid references quizzes(id),
  skor numeric,
  client_timestamp timestamptz not null,
);

-- Quiz Answers
create table quiz_answers (
  id uuid primary key default gen_random_uuid(),
  attempt_id uuid references quiz_attempts(id) on delete cascade,
  question_id uuid references quiz_questions(id),
  selected_option_id uuid references quiz_options(id)
);
```

> Catatan: `student_progress.id` dan `quiz_attempts.id` sengaja **tidak** pakai `default gen_random_uuid()` karena ID-nya dibuat di sisi client (Flutter) sebelum data dikirim ke server — ini penting untuk idempotency saat proses sync (mencegah data dobel kalau request di-retry).

---

## 4. Index yang Disarankan

```sql
create index idx_modules_updated_at on modules(updated_at);
create index idx_quizzes_updated_at on quizzes(updated_at);
create index idx_student_progress_user on student_progress(user_id);
create index idx_quiz_attempts_user on quiz_attempts(user_id);
create index idx_quiz_questions_quiz on quiz_questions(quiz_id);
create index idx_quiz_options_question on quiz_options(question_id);
```

`idx_modules_updated_at` dan `idx_quizzes_updated_at` penting untuk mempercepat query delta sync (`GET /materials?updated_since=...`).

---

## 5. Catatan Row Level Security (RLS)

Supabase mengaktifkan RLS per tabel. Rancangan awal policy (perlu disesuaikan saat implementasi):

- **`profiles`**: user hanya bisa `select`/`update` baris miliknya sendiri (`id = auth.uid()`).
- **`modules` / `quizzes`**: siswa hanya boleh `select` dengan `status = 'published'`; guru boleh CRUD penuh pada baris yang `created_by = auth.uid()`.
- **`student_progress` / `quiz_attempts` / `quiz_answers`**: siswa hanya boleh insert/select data miliknya sendiri (`user_id = auth.uid()`); guru boleh `select` untuk siswa yang berada di kelas yang sama (butuh logika tambahan berdasarkan `kelas` di `profiles`).

---

## 6. Prisma Schema

Tabel `auth.users` **tidak** dimodelkan di Prisma — hanya `profiles` dan tabel lain di luar schema `auth`. Relasi ke `auth.users.id` dijaga manual di kode aplikasi, bukan lewat `@relation`.

```prisma
model Profile {
  id        String   @id @db.Uuid  // nilai sama dengan auth.users.id, tanpa FK
  role      Role
  nama      String
  kelas     String?
  createdAt DateTime @default(now()) @map("created_at")

  modules      Module[]
  quizzes      Quiz[]
  progress     StudentProgress[]
  quizAttempts QuizAttempt[]

  @@map("profiles")
}

enum Role {
  siswa
  guru
  admin
}
```

## 7. Endpoint: Sinkronisasi User dengan Supabase Auth

### `POST /users` — Create User

Karena tidak ada FK+cascade di database, urutan operasi dan rollback manual jadi tanggung jawab endpoint ini:

1. Buat user di `auth.users` lewat Supabase Admin API (`supabaseAdmin.auth.admin.createUser`).
2. Insert baris `profiles` lewat Prisma, pakai `id` yang sama dengan hasil langkah 1.
3. Kalau langkah 2 gagal, **rollback**: hapus user yang baru dibuat di `auth.users` (`supabaseAdmin.auth.admin.deleteUser`) supaya tidak ada data auth yang "menggantung" tanpa profile.

```javascript
app.post('/users', async (req, res) => {
  const { email, password, nama, role, kelas } = req.body;

  const { data: authUser, error: authError } = await supabaseAdmin.auth.admin.createUser({
    email, password, email_confirm: true,
  });
  if (authError) return res.status(400).json({ error: authError.message });

  try {
    const profile = await prisma.profile.create({
      data: { id: authUser.user.id, nama, role, kelas },
    });
    return res.status(201).json(profile);
  } catch (err) {
    await supabaseAdmin.auth.admin.deleteUser(authUser.user.id);
    return res.status(500).json({ error: 'Gagal membuat profile, auth user di-rollback' });
  }
});
```

> Endpoint lain yang menyentuh siklus hidup user (misal `DELETE /users/:id`) perlu pola serupa: hapus di kedua sisi (`auth.users` dan `profiles`) secara eksplisit, karena tidak ada cascade otomatis dari database.

## 8. Hal yang Masih Perlu Diputuskan

- [ ] Apakah `student_progress` dan `quiz_attempts` perlu kolom tambahan seperti `device_id` untuk audit multi-device?
- [ ] Apakah `quiz_questions.tipe_soal` perlu ditambah `'isian_singkat'` untuk fase berikutnya?
- [ ] Kebijakan RLS final untuk guru melihat progres siswa lintas kelas.
- [ ] Strategi endpoint `DELETE`/`UPDATE` user agar `auth.users` dan `profiles` tetap konsisten (mengingat tidak ada cascade otomatis).
- [ ] Perlu job/cron pengecekan berkala untuk mendeteksi data "orphan" (auth user tanpa profile atau sebaliknya) sebagai jaring pengaman tambahan di luar rollback endpoint.