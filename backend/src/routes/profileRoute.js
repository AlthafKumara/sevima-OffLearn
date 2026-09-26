import express from 'express';
import { createProfile, getProfileById, updateProfile } from '../controllers/profileController.js';
const router = express.Router();
router.post('/', createProfile);
router.get('/:id', getProfileById);
router.put('/:id', updateProfile);
export default router;
