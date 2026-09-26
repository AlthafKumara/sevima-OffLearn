import express from 'express';
import { updateQuizQuestion, deleteQuizQuestion } from '../controllers/quizQuestionController.js';
import { checkRole } from '../middlewares/checkRole.js';
const router = express.Router();
router.put('/:id', checkRole(['guru']), updateQuizQuestion);
router.delete('/:id', checkRole(['guru']), deleteQuizQuestion);
export default router;
