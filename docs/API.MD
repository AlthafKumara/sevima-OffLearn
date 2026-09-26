# API CRUD — Offlearn (Revisi)

> Pendekatan: autentikasi (signup, login, session) ditangani penuh di Flutter lewat Supabase Auth.
> Backend Node.js **tidak memverifikasi token** — murni CRUD. Setiap request yang butuh identitas
> pengguna mengirim `user_id` secara eksplisit di body/query.
>
> Base URL (contoh): `https://api.offlearn.app`

## Format Response Standar

Semua response — baik sukses maupun error — mengikuti envelope yang sama:

```json
{
  "status": "success",
  "message": "Pesan singkat terkait endpoint",
  "data": { }
}
```

```json
{
  "status": "error",
  "message": "Pesan error (bisa dari error.message)"
}
```

- `data` **hanya muncul saat `status: "success"`**, berisi objek/array hasil endpoint. Untuk endpoint yang tidak mengembalikan data (misal delete), `data` diisi `null`.
- `message` untuk sukses: kalimat singkat deskriptif (misal `"Modul berhasil dibuat"`). Untuk error: pesan yang jelas ke pengguna, boleh langsung dari `error.message` kalau error-nya sudah cukup deskriptif.
- HTTP status code tetap dipakai seperti biasa (`200`, `201`, `400`, `403`, `404`, `500`, dst) — envelope ini pelengkap, bukan pengganti status code.

---

## 0. Catatan Desain

1. **Tidak ada JWT verification** — `user_id` di request sepenuhnya dipercaya dari client. Risikonya: siapa pun yang tahu `user_id` orang lain bisa kirim request atas nama mereka.
2. **Role-check diimplementasikan dari awal** (keputusan final): setiap endpoint yang butuh role tertentu akan query `role` dari tabel `profiles` berdasarkan `user_id` yang dikirim, lalu cek apakah role itu diizinkan. Ini tidak mencegah pemalsuan `user_id`, tapi mencegah siswa "mengaku" jadi guru di request. Endpoint yang butuh ini ditandai `[role-check: guru]` dst.
3. **Skor quiz dihitung di backend**, bukan dipercaya dari client — dari jumlah jawaban benar dibagi total soal. Client hanya mengirim `jawaban` (pilihan yang dipilih), bukan `skor`.
4. **Sync/offline-first hanya disediakan dalam bentuk batch**, dan hanya untuk aksi milik siswa (submit progres, submit quiz, download konten). Guru tidak butuh batch karena aksinya selalu online, satu-satu lewat CRUD biasa.
5. **Struktur kode backend**: semua response dihandle lewat 2 helper terpisah — `middleware/successHandler.js` dan `middleware/errorHandler.js`. Fungsi yang dipakai berulang (seperti pengecekan role) diletakkan di `/middleware/namaFungsi.js` masing-masing. Contoh implementasi ada di bagian 5.

---

## 1. CRUD Umum (Guru & Siswa)

### 1.1 Create Profile
```
POST /profiles
```

**Request:**
```json
{
  "id": "b3f1c2a0-...-uuid-dari-supabase-auth",
  "nama": "Budi Santoso",
  "role": "siswa",
  "kelas": "5A"
}
```

**Response `201`:**
```json
{
  "status": "success",
  "message": "Profile berhasil dibuat",
  "data": {
    "id": "b3f1c2a0-...",
    "nama": "Budi Santoso",
    "role": "siswa",
    "kelas": "5A",
    "created_at": "2026-09-26T10:00:00Z"
  }
}
```

**Response `409`:**
```json
{ "status": "error", "message": "Profile dengan id ini sudah ada" }
```

---

### 1.2 Get Profile
```
GET /profiles/:id
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Profile ditemukan",
  "data": {
    "id": "b3f1c2a0-...",
    "nama": "Budi Santoso",
    "role": "siswa",
    "kelas": "5A",
    "created_at": "2026-09-26T10:00:00Z"
  }
}
```

**Response `404`:**
```json
{ "status": "error", "message": "Profile tidak ditemukan" }
```

---

### 1.3 Update Profile
```
PUT /profiles/:id
```

**Request** (field opsional):
```json
{ "nama": "Budi Santoso", "kelas": "6A" }
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Profile berhasil diperbarui",
  "data": { "id": "b3f1c2a0-...", "nama": "Budi Santoso", "role": "siswa", "kelas": "6A" }
}
```

> `role` sengaja tidak bisa diubah lewat endpoint ini.

---

### 1.4 List Subjects (Read-only)
```
GET /subjects
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Daftar subject berhasil diambil",
  "data": [
    { "id": "sub-001", "nama_subject": "Matematika" },
    { "id": "sub-002", "nama_subject": "IPA" }
  ]
}
```

---

## 2. CRUD Khusus Guru

### 2.1 Create Subject `[role-check: guru]`
```
POST /subjects
```

**Request:**
```json
{ "created_by": "guru-uuid-123", "nama_subject": "Bahasa Indonesia" }
```

**Response `201`:**
```json
{
  "status": "success",
  "message": "Subject berhasil dibuat",
  "data": { "id": "sub-003", "nama_subject": "Bahasa Indonesia" }
}
```

**Response `403`** (kalau `created_by` bukan role guru):
```json
{ "status": "error", "message": "Role tidak diizinkan mengakses endpoint ini" }
```

---

### 2.2 Create Module `[role-check: guru]`
```
POST /modules
```

**Request:**
```json
{
  "subject_id": "sub-001",
  "created_by": "guru-uuid-123",
  "judul": "Pengenalan Pecahan",
  "konten": "Pecahan adalah bagian dari keseluruhan...",
  "target_kelas": "Kelas 5",
  "status": "draft",
  "urutan": 1
}
```

**Response `201`:**
```json
{
  "status": "success",
  "message": "Modul berhasil dibuat",
  "data": {
    "id": "mod-001",
    "subject_id": "sub-001",
    "created_by": "guru-uuid-123",
    "judul": "Pengenalan Pecahan",
    "konten": "Pecahan adalah bagian dari keseluruhan...",
    "target_kelas": "Kelas 5",
    "versi": 1,
    "status": "draft",
    "urutan": 1,
    "updated_at": "2026-09-26T10:05:00Z"
  }
}
```

---

### 2.3 List Modules Milik Guru `[role-check: guru]`
```
GET /modules?created_by=guru-uuid-123
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Daftar modul berhasil diambil",
  "data": [
    { "id": "mod-001", "judul": "Pengenalan Pecahan", "status": "draft", "versi": 1, "updated_at": "..." },
    { "id": "mod-002", "judul": "Perkalian Dasar", "status": "published", "versi": 2, "updated_at": "..." }
  ]
}
```

---

### 2.4 Get Module Detail (Guru)
```
GET /modules/:id
```

**Response `200`:** `data` berisi objek module lengkap (format sama seperti 2.2)

---

### 2.5 Update Module `[role-check: guru + created_by cocok]`
```
PUT /modules/:id
```

**Request:**
```json
{
  "requested_by": "guru-uuid-123",
  "konten": "Pecahan adalah bagian dari keseluruhan (revisi)...",
  "status": "published"
}
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Modul berhasil diperbarui",
  "data": {
    "id": "mod-001",
    "konten": "Pecahan adalah bagian dari keseluruhan (revisi)...",
    "status": "published",
    "versi": 2,
    "updated_at": "2026-09-26T11:00:00Z"
  }
}
```

> `requested_by` dikirim khusus untuk keperluan role-check + validasi kepemilikan (`created_by` module harus sama dengan `requested_by`). Kalau `konten` berubah, backend **wajib** increment `versi` otomatis.

---

### 2.6 Delete Module `[role-check: guru + created_by cocok]`
```
DELETE /modules/:id
```

**Request:**
```json
{ "requested_by": "guru-uuid-123" }
```

**Response `200`:**
```json
{ "status": "success", "message": "Modul berhasil dihapus", "data": null }
```

**Response `404`:**
```json
{ "status": "error", "message": "Modul tidak ditemukan atau bukan milik guru ini" }
```

---

### 2.7 Create Quiz `[role-check: guru]`
```
POST /quizzes
```

**Request:**
```json
{
  "subject_id": "sub-001",
  "created_by": "guru-uuid-123",
  "nama_quiz": "Kuis Pecahan Bab 1",
  "target_kelas": "Kelas 5",
  "status": "draft"
}
```

**Response `201`:**
```json
{
  "status": "success",
  "message": "Quiz berhasil dibuat",
  "data": {
    "id": "quiz-001",
    "subject_id": "sub-001",
    "created_by": "guru-uuid-123",
    "nama_quiz": "Kuis Pecahan Bab 1",
    "target_kelas": "Kelas 5",
    "status": "draft",
    "updated_at": "2026-09-26T10:10:00Z"
  }
}
```

---

### 2.8 Create Question + Options (Nested) `[role-check: guru]`
```
POST /quizzes/:quizId/questions
```

**Request:**
```json
{
  "created_by": "guru-uuid-123",
  "pertanyaan": "1/2 + 1/4 = ?",
  "tipe_soal": "pilihan_ganda",
  "urutan": 1,
  "opsi": [
    { "teks_opsi": "2/6", "is_benar": false },
    { "teks_opsi": "3/4", "is_benar": true },
    { "teks_opsi": "1/6", "is_benar": false },
    { "teks_opsi": "2/4", "is_benar": false }
  ]
}
```

**Response `201`:**
```json
{
  "status": "success",
  "message": "Soal berhasil ditambahkan",
  "data": {
    "id": "q-001",
    "quiz_id": "quiz-001",
    "pertanyaan": "1/2 + 1/4 = ?",
    "tipe_soal": "pilihan_ganda",
    "urutan": 1,
    "opsi": [
      { "id": "opt-001", "teks_opsi": "2/6", "is_benar": false },
      { "id": "opt-002", "teks_opsi": "3/4", "is_benar": true },
      { "id": "opt-003", "teks_opsi": "1/6", "is_benar": false },
      { "id": "opt-004", "teks_opsi": "2/4", "is_benar": false }
    ]
  }
}
```

---

### 2.9 Update Question `[role-check: guru]`
```
PUT /quiz-questions/:id
```

**Request:**
```json
{ "requested_by": "guru-uuid-123", "pertanyaan": "1/2 + 1/4 = ? (revisi)", "urutan": 1 }
```

**Response `200`:** `data` berisi question terbaru (tanpa opsi)

---

### 2.10 Update / Delete Option `[role-check: guru]`
```
PUT /quiz-options/:id
DELETE /quiz-options/:id
```

**Request PUT:**
```json
{ "requested_by": "guru-uuid-123", "teks_opsi": "3/4 (revisi)", "is_benar": true }
```

**Response PUT `200`:** `data` berisi option terbaru
**Response DELETE `200`:** `{ "status": "success", "message": "Opsi berhasil dihapus", "data": null }`

---

### 2.11 Delete Question `[role-check: guru]`
```
DELETE /quiz-questions/:id
```

**Request:**
```json
{ "requested_by": "guru-uuid-123" }
```

**Response `200`:**
```json
{ "status": "success", "message": "Soal berhasil dihapus beserta opsinya", "data": null }
```

---

### 2.12 Get Quiz Detail untuk Guru (Termasuk Jawaban Benar)
```
GET /quizzes/:id?view=guru
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Detail quiz berhasil diambil",
  "data": {
    "id": "quiz-001",
    "nama_quiz": "Kuis Pecahan Bab 1",
    "status": "draft",
    "questions": [
      {
        "id": "q-001",
        "pertanyaan": "1/2 + 1/4 = ?",
        "opsi": [
          { "id": "opt-001", "teks_opsi": "2/6", "is_benar": false },
          { "id": "opt-002", "teks_opsi": "3/4", "is_benar": true }
        ]
      }
    ]
  }
}
```

---

### 2.13 Lihat Progres Siswa per Modul `[role-check: guru]`
```
GET /modules/:id/progress?requested_by=guru-uuid-123
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Progres siswa berhasil diambil",
  "data": [
    { "user_id": "siswa-001", "nama": "Budi Santoso", "kelas": "5A", "status": "selesai", "client_timestamp": "..." },
    { "user_id": "siswa-002", "nama": "Ani Wijaya", "kelas": "5A", "status": "sedang_dibaca", "client_timestamp": "..." }
  ]
}
```

---

### 2.14 Lihat Hasil Quiz Siswa `[role-check: guru]`
```
GET /quizzes/:id/attempts?requested_by=guru-uuid-123
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Hasil quiz siswa berhasil diambil",
  "data": [
    { "attempt_id": "att-001", "user_id": "siswa-001", "nama": "Budi Santoso", "skor": 75, "client_timestamp": "..." },
    { "attempt_id": "att-002", "user_id": "siswa-002", "nama": "Ani Wijaya", "skor": 100, "client_timestamp": "..." }
  ]
}
```

---

### 2.15 Lihat Detail Jawaban Satu Attempt `[role-check: guru]`
```
GET /quiz-attempts/:attemptId/answers?requested_by=guru-uuid-123
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Detail jawaban berhasil diambil",
  "data": [
    { "question_id": "q-001", "pertanyaan": "1/2 + 1/4 = ?", "selected_option": "2/6", "is_benar": false },
    { "question_id": "q-002", "pertanyaan": "2 x 3 = ?", "selected_option": "6", "is_benar": true }
  ]
}
```

---

## 3. CRUD Khusus Siswa (Read & Riwayat)

> Aksi menulis (submit progres modul, submit quiz) dipindah seluruhnya ke endpoint **batch** di bagian 4, karena app siswa selalu offline-first — data ditulis ke Hive dulu, baru disinkronkan sekaligus.

### 3.1 List Modules untuk Kelas Siswa
```
GET /modules?target_kelas=Kelas%205&subject_id=sub-001&status=published
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Daftar modul berhasil diambil",
  "data": [
    { "id": "mod-001", "judul": "Pengenalan Pecahan", "versi": 2, "updated_at": "2026-09-26T11:00:00Z" }
  ]
}
```

---

### 3.2 Get Module Detail (Siswa)
```
GET /modules/:id
```

**Response `200`:** `data` berisi module detail — hanya bisa diakses kalau `status = "published"`, kalau tidak `404`.

---

### 3.3 List Quizzes untuk Kelas Siswa
```
GET /quizzes?target_kelas=Kelas%205&subject_id=sub-001&status=published
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Daftar quiz berhasil diambil",
  "data": [ { "id": "quiz-001", "nama_quiz": "Kuis Pecahan Bab 1" } ]
}
```

---

### 3.4 Get Quiz untuk Dikerjakan Siswa (Tanpa Jawaban Benar)
```
GET /quizzes/:id?view=siswa
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Detail quiz berhasil diambil",
  "data": {
    "id": "quiz-001",
    "nama_quiz": "Kuis Pecahan Bab 1",
    "questions": [
      {
        "id": "q-001",
        "pertanyaan": "1/2 + 1/4 = ?",
        "opsi": [
          { "id": "opt-001", "teks_opsi": "2/6" },
          { "id": "opt-002", "teks_opsi": "3/4" }
        ]
      }
    ]
  }
}
```

> `is_benar` **tidak** boleh muncul di response ini.

---

### 3.5 Lihat Riwayat Progres Sendiri
```
GET /student-progress?user_id=siswa-001
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Riwayat progres berhasil diambil",
  "data": [ { "module_id": "mod-001", "status": "selesai", "client_timestamp": "..." } ]
}
```

---

### 3.6 Lihat Riwayat Quiz Sendiri
```
GET /quiz-attempts?user_id=siswa-001
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "Riwayat quiz berhasil diambil",
  "data": [ { "attempt_id": "att-001", "quiz_id": "quiz-001", "skor": 75, "client_timestamp": "..." } ]
}
```

---

## 4. Endpoint Batch — Khusus Siswa (Offline-First)

Semua endpoint di bagian ini dirancang untuk dipanggil oleh `SyncWorker` di Flutter: sekali jalan untuk banyak item, dipicu saat koneksi terdeteksi kembali. **Hanya untuk siswa** — guru tidak menggunakan pola batch ini.

### 4.1 Download Konten untuk Cache Offline
```
GET /sync/download?target_kelas=Kelas%205&updated_since=2026-09-20T00:00:00Z
```

Satu panggilan mengambil semua modul **dan** quiz (beserta soal + opsi, tanpa `is_benar`) yang relevan untuk kelas siswa, supaya Flutter tidak perlu memanggil `/modules` dan `/quizzes` terpisah saat sinkronisasi awal.

**Response `200`:**
```json
{
  "status": "success",
  "message": "Konten berhasil diambil",
  "data": {
    "modules": [
      { "id": "mod-001", "judul": "Pengenalan Pecahan", "konten": "...", "versi": 2, "updated_at": "..." }
    ],
    "quizzes": [
      {
        "id": "quiz-001",
        "nama_quiz": "Kuis Pecahan Bab 1",
        "questions": [
          { "id": "q-001", "pertanyaan": "1/2 + 1/4 = ?", "opsi": [
            { "id": "opt-001", "teks_opsi": "2/6" },
            { "id": "opt-002", "teks_opsi": "3/4" }
          ]}
        ]
      }
    ]
  }
}
```

---

### 4.2 Sync Progres Modul (Batch)
```
POST /sync/student-progress
```

**Request:**
```json
{
  "user_id": "siswa-001",
  "items": [
    { "id": "prog-uuid-1", "module_id": "mod-001", "status": "selesai", "client_timestamp": "2026-09-26T09:30:00Z" },
    { "id": "prog-uuid-2", "module_id": "mod-002", "status": "sedang_dibaca", "client_timestamp": "2026-09-26T09:32:00Z" }
  ]
}
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "2 dari 2 progres berhasil disinkronkan",
  "data": {
    "success": ["prog-uuid-1", "prog-uuid-2"],
    "failed": []
  }
}
```

Upsert berdasarkan `id` (dibuat di client) — aman dipanggil ulang kalau request sebelumnya putus di tengah jalan.

---

### 4.3 Sync Quiz Attempts (Batch, Skor Dihitung Backend)
```
POST /sync/quiz-attempts
```

**Request** (perhatikan: **tidak ada field `skor`** — hanya jawaban):
```json
{
  "user_id": "siswa-001",
  "items": [
    {
      "id": "att-uuid-1",
      "quiz_id": "quiz-001",
      "client_timestamp": "2026-09-26T09:35:00Z",
      "jawaban": [
        { "question_id": "q-001", "selected_option_id": "opt-002" },
        { "question_id": "q-002", "selected_option_id": "opt-006" }
      ]
    }
  ]
}
```

**Response `200`:**
```json
{
  "status": "success",
  "message": "1 dari 1 quiz attempt berhasil disinkronkan",
  "data": {
    "success": [
      { "id": "att-uuid-1", "skor": 50, "created_at": "2026-09-26T12:01:00Z" }
    ],
    "failed": []
  }
}
```

**Logika perhitungan skor di backend** (per item, sebelum insert):
```javascript
function hitungSkor(jawaban, questionsBesertaOpsiBenar) {
  let benar = 0;
  for (const j of jawaban) {
    const soal = questionsBesertaOpsiBenar.find(q => q.id === j.question_id);
    const opsiBenar = soal?.opsi.find(o => o.is_benar);
    if (opsiBenar && opsiBenar.id === j.selected_option_id) benar++;
  }
  return Math.round((benar / questionsBesertaOpsiBenar.length) * 100);
}
```

Backend mengambil ulang `quiz_questions` + `quiz_options` (termasuk `is_benar`) dari database berdasarkan `quiz_id`, lalu hitung skor — bukan menerima skor dari client sama sekali.

---

## 5. Struktur Kode Backend (Response Handler & Reusable Function)

Sesuai kesepakatan, semua response melewati 2 helper terpisah, dan fungsi yang dipakai berulang (seperti role-check) diletakkan di `/middleware/namaFungsi.js`.

```
services/backend/
├── middleware/
│   ├── successHandler.js
│   ├── errorHandler.js
│   └── checkRole.js
├── routes/
│   ├── profiles.js
│   ├── modules.js
│   ├── quizzes.js
│   └── sync.js
└── index.js
```

**`middleware/successHandler.js`:**
```javascript
function successResponse(res, statusCode, message, data = null) {
  return res.status(statusCode).json({ status: 'success', message, data });
}
module.exports = successResponse;
```

**`middleware/errorHandler.js`:**
```javascript
function errorResponse(res, statusCode, message) {
  return res.status(statusCode).json({ status: 'error', message });
}
module.exports = errorResponse;
```

**`middleware/checkRole.js`** (fungsi reusable, dipanggil manual di tiap route yang butuh, karena `user_id` posisinya beda-beda per endpoint — body, query, atau param):
```javascript
const prisma = require('../prismaClient');

async function checkRole(userId, allowedRoles) {
  const profile = await prisma.profile.findUnique({ where: { id: userId } });
  if (!profile) {
    throw { statusCode: 404, message: 'Profile tidak ditemukan' };
  }
  if (!allowedRoles.includes(profile.role)) {
    throw { statusCode: 403, message: 'Role tidak diizinkan mengakses endpoint ini' };
  }
  return profile;
}
module.exports = checkRole;
```

**Contoh penggunaan di route (`routes/modules.js`):**
```javascript
const successResponse = require('../middleware/successHandler');
const errorResponse = require('../middleware/errorHandler');
const checkRole = require('../middleware/checkRole');

router.post('/modules', async (req, res) => {
  try {
    await checkRole(req.body.created_by, ['guru']);
    const modul = await prisma.module.create({ data: req.body });
    return successResponse(res, 201, 'Modul berhasil dibuat', modul);
  } catch (err) {
    return errorResponse(res, err.statusCode || 500, err.message || 'Terjadi kesalahan server');
  }
});
```

---

## 6. Ringkasan Tabel Endpoint

| Endpoint | Method | Role | Keterangan |
|---|---|---|---|
| `/profiles` | POST | Umum | Buat profile setelah signup |
| `/profiles/:id` | GET, PUT | Umum | Lihat/update profile sendiri |
| `/subjects` | GET | Umum | List mata pelajaran |
| `/subjects` | POST | Guru | Tambah mata pelajaran |
| `/modules` | POST, PUT, DELETE | Guru | CRUD modul |
| `/modules` | GET | Umum (query beda) | Guru: milik sendiri; Siswa: published + target_kelas |
| `/modules/:id` | GET | Umum | |
| `/quizzes` | POST | Guru | Buat quiz |
| `/quizzes` | GET | Umum (query beda) | |
| `/quizzes/:id` | GET | Umum (`?view=guru`/`siswa`) | |
| `/quizzes/:quizId/questions` | POST | Guru | Buat soal + opsi (nested) |
| `/quiz-questions/:id` | PUT, DELETE | Guru | |
| `/quiz-options/:id` | PUT, DELETE | Guru | |
| `/modules/:id/progress` | GET | Guru | Monitoring progres siswa |
| `/quizzes/:id/attempts` | GET | Guru | Monitoring hasil quiz |
| `/quiz-attempts/:id/answers` | GET | Guru | Detail jawaban siswa |
| `/student-progress` | GET | Siswa | Riwayat progres sendiri |
| `/quiz-attempts` | GET | Siswa | Riwayat quiz sendiri |
| `/sync/download` | GET | Siswa | Batch download modul + quiz untuk cache offline |
| `/sync/student-progress` | POST | Siswa | Batch sync progres modul dari Hive |
| `/sync/quiz-attempts` | POST | Siswa | Batch sync quiz attempt (skor dihitung backend) |

---

## 7. Keputusan Final (Hasil Revisi)

- ✅ Role-check diimplementasikan dari awal lewat `checkRole.js`.
- ✅ Skor quiz dihitung backend dari jawaban benar / total soal, client tidak mengirim skor.
- ✅ Sync siswa disediakan penuh dalam bentuk batch (`/sync/download`, `/sync/student-progress`, `/sync/quiz-attempts`); guru tetap pakai CRUD satu-satu.
- ✅ Tidak ada endpoint delete untuk `student-progress`/`quiz-attempts` di MVP.
- ✅ Semua response memakai envelope `{ status, message, data }`, dihandle lewat `successHandler.js` dan `errorHandler.js`.

FINAL NOTES : TETAP GUNAKAN PENULISAN TYPE : MODULE DI JAVASCRIPT