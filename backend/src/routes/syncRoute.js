import express from 'express';
import { syncDownload, syncStudentProgress, syncQuizAttempts } from '../controllers/syncController.js';
const router = express.Router();
router.get('/download', syncDownload);
router.post('/student-progress', syncStudentProgress);
router.post('/quiz-attempts', syncQuizAttempts);
export default router;
