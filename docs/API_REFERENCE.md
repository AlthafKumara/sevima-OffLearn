# Offlearn API Reference

This document provides a comprehensive guide to the Offlearn API. It reflects the strict API architecture implemented, including standard response envelopes, role-based access control, and batch synchronization endpoints.

---

## 1. Global Concepts

### 1.1 Standard Response Envelope
All API endpoints return a standard JSON envelope with `success`, `message`, and `data` properties.

**Success Response (2xx)**
```json
{
  "success": true,
  "message": "Human readable success message",
  "data": { ... } // Or Array [ ... ]
}
```

**Error Response (4xx, 5xx)**
```json
{
  "success": false,
  "message": "Human readable error message"
}
```

### 1.2 Authentication & Authorization (Role-Check)
This backend does not verify JWTs directly. It relies on the `user_id` (usually provided by Supabase Auth) sent by the client. 

For endpoints restricted by role (e.g., `guru`), the client must provide one of the following in the **Request Body** or **Query String**:
- `user_id`
- `requested_by`
- `created_by`

The server fetches the user's role from the database and checks if they are authorized to perform the action.

---

## 2. Profiles (`/profiles`)

### Create Profile
- **Endpoint**: `POST /profiles`
- **Auth**: None
- **Request Body**:
  ```json
  {
    "id": "uuid-from-supabase",
    "nama": "Budi Santoso",
    "role": "siswa",
    "kelas": "5A" // Optional
  }
  ```
- **Responses**: 
  - `201 Created`: Profile created successfully.
  - `409 Conflict`: Profile ID already exists.

### Get Profile by ID
- **Endpoint**: `GET /profiles/:id`
- **Auth**: None
- **Responses**: `200 OK`, `404 Not Found`

### Update Profile
- **Endpoint**: `PUT /profiles/:id`
- **Auth**: None
- **Request Body**:
  ```json
  {
    "nama": "Budi Revisi",
    "kelas": "6A"
  }
  ```
- **Responses**: `200 OK`, `404 Not Found`

---

## 3. Subjects (`/subjects`)

### List Subjects
- **Endpoint**: `GET /subjects`
- **Auth**: None
- **Responses**: `200 OK`

### Create Subject
- **Endpoint**: `POST /subjects`
- **Auth**: `[guru]`
- **Request Body**:
  ```json
  {
    "nama_subject": "Matematika",
    "created_by": "guru-uuid"
  }
  ```
- **Responses**: `201 Created`

---

## 4. Modules (`/modules`)

### List Modules
- **Endpoint**: `GET /modules`
- **Auth**: None
- **Query Params**: `created_by` (optional), `target_kelas` (optional), `subject_id` (optional), `status` (optional)
- **Responses**: `200 OK`

### Create Module
- **Endpoint**: `POST /modules`
- **Auth**: `[guru]`
- **Request Body**:
  ```json
  {
    "subject_id": "sub-uuid",
    "created_by": "guru-uuid",
    "judul": "Bab 1: Pecahan",
    "konten": "Isi materi...",
    "target_kelas": "Kelas 5",
    "status": "draft",
    "urutan": 1
  }
  ```
- **Responses**: `201 Created`

### Get Module Details
- **Endpoint**: `GET /modules/:id`
- **Auth**: None
- **Responses**: `200 OK`

### Update Module
- **Endpoint**: `PUT /modules/:id`
- **Auth**: `[guru]`
- **Request Body**:
  ```json
  {
    "requested_by": "guru-uuid", // Required for ownership validation
    "konten": "Revisi materi...",
    "status": "published"
  }
  ```
- **Responses**: `200 OK`

### Delete Module
- **Endpoint**: `DELETE /modules/:id`
- **Auth**: `[guru]`
- **Request Body**:
  ```json
  {
    "requested_by": "guru-uuid"
  }
  ```
- **Responses**: `200 OK`

### View Student Progress (Per Module)
- **Endpoint**: `GET /modules/:id/progress`
- **Auth**: `[guru]`
- **Query Params**: `requested_by` (guru-uuid)
- **Responses**: `200 OK`

---

## 5. Quizzes (`/quizzes`)

### List Quizzes
- **Endpoint**: `GET /quizzes`
- **Auth**: None
- **Query Params**: `target_kelas` (optional), `subject_id` (optional), `status` (optional)
- **Responses**: `200 OK`

### Create Quiz
- **Endpoint**: `POST /quizzes`
- **Auth**: `[guru]`
- **Request Body**:
  ```json
  {
    "subject_id": "sub-uuid",
    "created_by": "guru-uuid",
    "nama_quiz": "Kuis 1",
    "target_kelas": "Kelas 5",
    "status": "draft"
  }
  ```
- **Responses**: `201 Created`

### Get Quiz Detail
- **Endpoint**: `GET /quizzes/:id`
- **Auth**: None
- **Query Params**: `view` ("guru" or "siswa")
  - `view=guru` includes `is_benar` boolean in options.
  - `view=siswa` hides correct answers.
- **Responses**: `200 OK`

### Create Quiz Question
- **Endpoint**: `POST /quizzes/:quizId/questions`
- **Auth**: `[guru]`
- **Request Body**:
  ```json
  {
    "created_by": "guru-uuid",
    "pertanyaan": "1 + 1 = ?",
    "tipe_soal": "pilihan_ganda",
    "urutan": 1,
    "opsi": [
      { "teks_opsi": "2", "is_benar": true },
      { "teks_opsi": "3", "is_benar": false }
    ]
  }
  ```
- **Responses**: `201 Created`

### View Quiz Attempts
- **Endpoint**: `GET /quizzes/:id/attempts`
- **Auth**: `[guru]`
- **Query Params**: `requested_by` (guru-uuid)
- **Responses**: `200 OK`

---

## 6. Quiz Questions & Options Management

### Update Question
- **Endpoint**: `PUT /quiz-questions/:id`
- **Auth**: `[guru]`
- **Request Body**: `{ "requested_by": "guru-uuid", "pertanyaan": "Revisi soal...", "urutan": 1 }`
- **Responses**: `200 OK`

### Delete Question
- **Endpoint**: `DELETE /quiz-questions/:id`
- **Auth**: `[guru]`
- **Request Body**: `{ "requested_by": "guru-uuid" }`
- **Responses**: `200 OK`

### Update Option
- **Endpoint**: `PUT /quiz-options/:id`
- **Auth**: `[guru]`
- **Request Body**: `{ "requested_by": "guru-uuid", "teks_opsi": "Revisi", "is_benar": true }`
- **Responses**: `200 OK`

### Delete Option
- **Endpoint**: `DELETE /quiz-options/:id`
- **Auth**: `[guru]`
- **Request Body**: `{ "requested_by": "guru-uuid" }`
- **Responses**: `200 OK`

---

## 7. Sync & Batch (Offline-First for Siswa)

These endpoints are used by the mobile client to download initial cache and upload offline data in batches.

### Download All Content
- **Endpoint**: `GET /sync/download`
- **Auth**: None
- **Query Params**: `target_kelas` (optional), `updated_since` (optional)
- **Responses**: `200 OK`
  - Returns combined list of `modules` and `quizzes` (without correct answers).

### Sync Student Progress
- **Endpoint**: `POST /sync/student-progress`
- **Auth**: None
- **Request Body**:
  ```json
  {
    "user_id": "siswa-uuid",
    "items": [
      {
        "id": "progress-client-uuid",
        "module_id": "mod-uuid",
        "status": "selesai",
        "client_timestamp": "2026-09-26T12:00:00Z"
      }
    ]
  }
  ```
- **Responses**: `200 OK` (Performs Upsert operation safely).

### Sync Quiz Attempts
- **Endpoint**: `POST /sync/quiz-attempts`
- **Auth**: None
- **Description**: Submits quiz answers. **Score is calculated strictly on the backend**.
- **Request Body**:
  ```json
  {
    "user_id": "siswa-uuid",
    "items": [
      {
        "id": "attempt-client-uuid",
        "quiz_id": "quiz-uuid",
        "client_timestamp": "2026-09-26T12:00:00Z",
        "jawaban": [
          { "question_id": "q-uuid-1", "selected_option_id": "opt-uuid-1" }
        ]
      }
    ]
  }
  ```
- **Responses**: `200 OK`
  - Returns array of successful syncs including the backend-calculated `skor`.

---

## 8. View History (Siswa)

### Student Progress History
- **Endpoint**: `GET /student-progress`
- **Auth**: None
- **Query Params**: `user_id` (siswa-uuid)
- **Responses**: `200 OK`

### Quiz Attempts History
- **Endpoint**: `GET /quiz-attempts`
- **Auth**: None
- **Query Params**: `user_id` (siswa-uuid)
- **Responses**: `200 OK`

### View Answers for an Attempt
- **Endpoint**: `GET /quiz-attempts/:attemptId/answers`
- **Auth**: `[guru]`
- **Query Params**: `requested_by` (guru-uuid)
- **Responses**: `200 OK`
