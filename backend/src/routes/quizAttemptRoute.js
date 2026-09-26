import express from 'express';
import { getQuizAttempts, getQuizAnswersByAttempt } from '../controllers/quizAttemptController.js';
import { checkRole } from '../middlewares/checkRole.js';


const router = express.Router();
router.get('/', getQuizAttempts);
router.get('/:attemptId/answers', checkRole(['guru']), getQuizAnswersByAttempt);

export default router;
