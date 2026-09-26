import express from 'express';
import { getStudentProgress } from '../controllers/studentProgressController.js';
const router = express.Router();
router.get('/', getStudentProgress);
export default router;
