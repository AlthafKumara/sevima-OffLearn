# API Architecture Rules — `api_generated.md`

> **Living Reference** — All developers must follow these rules when creating a new API endpoint.
> No exceptions. No shortcuts.

---

## 📁 Required Folder Structure

```
src/
├── controllers/        # DB calls only (Prisma CRUD), one file per table
├── routes/             # Path + middleware + handler only, one file per table
├── models/             # Response DTO mapper functions, one file per endpoint
├── middlewares/        # Reusable middleware functions (auth, validation, etc.)
├── utils/
│   ├── functions/      # All business logic lives here
│   └── validators/     # Input validation schemas (Joi / Zod)
└── app.js              # Global middleware + route registration only
```

---

## ✅ The 4 Strict Rules

---

### Rule 1 — Every Database Call Lives in `/controllers`

- **All** Prisma client calls must be inside a controller file.
- No DB calls in routes, utils, middlewares, or models.
- A controller file maps **1:1 to a database table**.
- Controller functions are `async` and only do: validate input → call Prisma → call DTO → return response.
- Business logic (calculations, transformations, conditionals) → goes to `/utils/functions/`, **not** the controller.

**Naming convention:**
```
/controllers/{tableName}Controller.js

Examples:
  profileController.js        → profiles table
  moduleController.js         → modules table
  quizController.js           → quizzes table
  quizAttemptController.js    → quiz_attempts table
  studentProgressController.js → student_progress table
```

**Example — Correct ✅**
```js
// controllers/profileController.js
import prisma from '../configs/prisma.js';
import { toProfileResponse } from '../models/profileResponseDto.js';

export const getProfileById = async (req, res) => {
  try {
    const { id } = req.params;

    const profile = await prisma.profiles.findUnique({ where: { id } });

    if (!profile) {
      return res.status(404).json({ success: false, message: 'Profile not found' });
    }

    return res.status(200).json({ success: true, data: toProfileResponse(profile) });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};
```

**Example — Forbidden ❌**
```js
// ❌ DB call inside a route file
router.get('/profile/:id', async (req, res) => {
  const profile = await prisma.profiles.findUnique(...); // NEVER HERE
});

// ❌ Business logic inside a controller
export const submitQuiz = async (req, res) => {
  const score = answers.filter(a => a.is_benar).length / total * 100; // MOVE to /utils/functions/
};
```

---

### Rule 2 — Every Table Has 1 Controller File and 1 Route File

- Each database table must have **exactly one** dedicated controller and one dedicated route file.
- No shared controllers. No generic "resourceController.js".
- Cross-table operations (joins) → handled in the controller of the **primary/owner table** of the endpoint.

**Mapping (based on current schema):**

| Table | Controller File | Route File |
|---|---|---|
| `profiles` | `profileController.js` | `profileRoute.js` |
| `modules` | `moduleController.js` | `moduleRoute.js` |
| `subjects` | `subjectController.js` | `subjectRoute.js` |
| `quizzes` | `quizController.js` | `quizRoute.js` |
| `quiz_questions` | `quizQuestionController.js` | `quizQuestionRoute.js` |
| `quiz_options` | `quizOptionController.js` | `quizOptionRoute.js` |
| `quiz_attempts` | `quizAttemptController.js` | `quizAttemptRoute.js` |
| `quiz_answers` | `quizAnswerController.js` | `quizAnswerRoute.js` |
| `student_progress` | `studentProgressController.js` | `studentProgressRoute.js` |

---

### Rule 3 — Every HTTP Request Defines Its Middleware in `/routes`

- Route files register: **path + middleware chain + controller handler**. Nothing else.
- Middleware is applied **per-route inline** (not globally via `router.use()`).
- No logic, no conditionals, no helper functions inside a route file.
- Middleware files must live in `/middlewares/`. Validators live in `/utils/validators/`.

**Naming convention:**
```
/routes/{tableName}Route.js

Examples:
  profileRoute.js
  moduleRoute.js
  quizRoute.js
```

**Route registration in `app.js`:**
```
/api/v1/{tableName}    →    {tableName}Route.js
```

**Example — Correct ✅**
```js
// routes/profileRoute.js
import express from 'express';
import { authMiddleware } from '../middlewares/authMiddleware.js';
import { validateBody } from '../utils/validators/profileValidator.js';
import { getProfileById, updateProfile } from '../controllers/profileController.js';

const router = express.Router();

router.get('/:id', authMiddleware, getProfileById);
router.put('/:id', authMiddleware, validateBody, updateProfile);

export default router;
```

**Example — Forbidden ❌**
```js
// ❌ Logic inside a route file
router.get('/:id', authMiddleware, async (req, res) => {
  const profile = await prisma.profiles.findUnique(...); // NEVER HERE
});

// ❌ router.use() instead of per-route middleware
router.use(authMiddleware); // FORBIDDEN — use per-route instead
```

---

### Rule 4 — All Response Shapes Are Defined in `/models`

- Every endpoint must have a corresponding DTO mapper file in `/models/`.
- The DTO file exports a **plain mapper function** that shapes the raw Prisma result.
- One DTO file per **endpoint** (not per table) — different response shapes get different files.
- DTO functions **never** call the database, have side effects, or contain business logic.

**Naming convention:**
```
/models/{descriptiveName}ResponseDto.js

Pattern: {table}{Shape}ResponseDto.js

Examples:
  profileResponseDto.js               → GET /profile/:id
  profileListResponseDto.js           → GET /profile (list)
  quizDetailResponseDto.js            → GET /quiz/:id with questions
  quizAttemptResultResponseDto.js     → POST /quiz-attempt (submit result)
  studentProgressResponseDto.js       → GET /student-progress/:id
```

**Example — Correct ✅**
```js
// models/profileResponseDto.js
export const toProfileResponse = (profile) => ({
  id: profile.id,
  nama: profile.nama,
  role: profile.role,
  kelas: profile.kelas ?? null,
  createdAt: profile.created_at,
});
```

```js
// models/profileListResponseDto.js
export const toProfileListResponse = (profiles) =>
  profiles.map((profile) => ({
    id: profile.id,
    nama: profile.nama,
    role: profile.role,
  }));
```

**Example — Forbidden ❌**
```js
// ❌ DB call inside a DTO
export const toProfileResponse = async (id) => {
  const profile = await prisma.profiles.findUnique({ where: { id } }); // NEVER
  return { id: profile.id };
};

// ❌ Raw Prisma result sent directly to client (no DTO)
return res.status(200).json({ success: true, data: profile }); // MISSING DTO
```

---

## 📦 Standard Response Envelope

Every HTTP response — success or error — **must** use this envelope format.

### Success Response
```json
{
  "success": true,
  "data": { }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Human-readable error description"
}
```

> **Rule**: The DTO mapper shapes only the `data` field. The `success` wrapper is always added in the controller.

---

## 🌐 HTTP Status Code Mapping

All controllers must use the correct HTTP status code. No hardcoding arbitrary codes.

| Code | Name | When to Use |
|---|---|---|
| `200` | OK | Successful GET, PUT, PATCH |
| `201` | Created | Successful POST that creates a resource |
| `400` | Bad Request | Malformed request body or invalid parameters |
| `401` | Unauthorized | Missing or invalid authentication token |
| `403` | Forbidden | Authenticated but lacks permission |
| `404` | Not Found | Resource does not exist |
| `409` | Conflict | Duplicate resource (e.g. unique constraint violation) |
| `422` | Unprocessable Entity | Request is well-formed but fails business validation |
| `500` | Internal Server Error | Unexpected server/database error |

**Example — Correct Usage ✅**
```js
// 404 — not found
if (!profile) {
  return res.status(404).json({ success: false, message: 'Profile not found' });
}

// 409 — conflict (Prisma unique constraint)
if (error.code === 'P2002') {
  return res.status(409).json({ success: false, message: 'Resource already exists' });
}

// 401 — missing/invalid token (in middleware)
return res.status(401).json({ success: false, message: 'Unauthorized' });

// 403 — wrong role
return res.status(403).json({ success: false, message: 'Forbidden: insufficient permissions' });

// 500 — catch-all
return res.status(500).json({ success: false, message: 'Internal server error' });
```

---

## 🔁 Complete API Flow Diagram

```
HTTP Request
     │
     ▼
 [Route File]  (/routes/profileRoute.js)
 • Registers path
 • Applies middleware chain per-route
 • Points to controller handler
     │
     ▼
 [Middleware]  (/middlewares/authMiddleware.js)
 • Auth check, role check, input validation
     │
     ▼
 [Controller]  (/controllers/profileController.js)
 • Calls Prisma (CRUD only)
 • Calls util functions if needed
 • Calls DTO mapper
 • Returns response
     │
     ├──── [Utils/Functions]  (/utils/functions/)
     │      • Business logic only
     │      • No DB calls
     │
     └──── [DTO Mapper]  (/models/profileResponseDto.js)
            • Shapes the data field
            • No DB calls, no logic
            │
            ▼
     HTTP Response
     { success: true, data: { ... } }
```

---

## 📋 New Endpoint Checklist

When creating a new API endpoint, verify **all** of the following:

- [ ] Controller file exists for this table in `/controllers/`
- [ ] Route file exists for this table in `/routes/`
- [ ] Route is registered in `app.js` under `/api/v1/{tableName}`
- [ ] Middleware is applied **per-route inline** in the route file
- [ ] Controller only calls Prisma — no business logic inside it
- [ ] Business logic is extracted to `/utils/functions/`
- [ ] A DTO mapper file exists in `/models/` for this endpoint's response shape
- [ ] Controller calls the DTO mapper and wraps result in `{ success: true, data: ... }`
- [ ] Correct HTTP status code is used (from the mapping table above)
- [ ] Error responses use `{ success: false, message: '...' }` format

---

## 🚫 Global Forbidden Patterns

| Pattern | Reason |
|---|---|
| DB calls in `/routes` | Violates Rule 1 |
| DB calls in `/models` | Violates Rule 4 |
| DB calls in `/middlewares` | Violates Rule 1 |
| Logic inside a route file | Violates Rule 3 |
| `router.use()` for per-endpoint middleware | Violates Rule 3 |
| Raw Prisma result sent to client (no DTO) | Violates Rule 4 |
| Multiple tables in one controller file | Violates Rule 2 |
| HTTP status codes not in the mapping table | Violates HTTP standard |
| Missing `success` key in any response | Violates response envelope |

---

## 📝 Decision Log

| # | Decision | Alternatives Considered | Reason |
|---|---|---|---|
| 1 | DTO = plain mapper function | Class with static methods, JSDoc-only schema | Simplest, no overhead, easy to test |
| 2 | Middleware applied per-route inline | `router.use()`, global in `app.js` | Explicit per-endpoint control, easier to audit |
| 3 | Controllers = CRUD only, business logic → `/utils/functions/` | Controllers handle all logic, service layer | Keeps controllers thin and predictable |
| 4 | Response envelope: `{ success, data }` + DTO shapes `data` only | DTO returns full response, no envelope | Consistent client-side handling |
| 5 | One DTO file per endpoint | One DTO per table, one DTO per feature | Most granular, avoids bloated files |
| 6 | Route files: path + middleware + handler only | Allow validators in routes | Single responsibility, zero ambiguity |
| 7 | Doc is a living manual reference | Automation scripts, CLI scaffolding | Lightweight, no tooling dependency |
| 8 | Standard HTTP status code mapping table | Arbitrary codes, only 200/500 | Industry standard, predictable for clients |
| 9 | No pagination in list responses | Cursor pagination, offset pagination | YAGNI — not needed at current scale |
