import express from 'express';
import { createModule, getModules, getModuleById, updateModule, deleteModule } from '../controllers/moduleController.js';
import { getModuleProgress } from '../controllers/studentProgressController.js';
import { checkRole } from '../middlewares/checkRole.js';


const router = express.Router();


router.post('/', checkRole(['guru']), createModule);
router.get('/', getModules);
router.get('/:id', getModuleById);
router.put('/:id', checkRole(['guru']), updateModule);
router.delete('/:id', checkRole(['guru']), deleteModule);
router.get('/:id/progress', checkRole(['guru']), getModuleProgress);
export default router;
