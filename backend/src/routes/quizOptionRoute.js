import express from 'express';
import { updateQuizOption, deleteQuizOption } from '../controllers/quizOptionController.js';
import { checkRole } from '../middlewares/checkRole.js';
const router = express.Router();
router.put('/:id', checkRole(['guru']), updateQuizOption);
router.delete('/:id', checkRole(['guru']), deleteQuizOption);
export default router;
