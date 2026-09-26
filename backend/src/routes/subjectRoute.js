import express from 'express';
import { getSubjects, createSubject } from '../controllers/subjectController.js';
import { checkRole } from '../middlewares/checkRole.js';
const router = express.Router();
router.get('/', getSubjects);
router.post('/', checkRole(['guru']), createSubject);
export default router;
