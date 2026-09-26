import prisma from '../configs/prisma.js';
import { toQuizResponse, toQuizListResponse, toQuizDetailGuruResponse, toQuizDetailSiswaResponse } from '../models/quizResponseDto.js';

export const createQuiz = async (req, res) => {
  try {
    const q = await prisma.quizzes.create({ data: req.body });
    return res.status(201).json({ success: true, message: 'Quiz berhasil dibuat', data: toQuizResponse(q) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const getQuizzes = async (req, res) => {
  try {
    const { target_kelas, subject_id, status } = req.query;
    const where = {};
    if (target_kelas) where.target_kelas = target_kelas;
    if (subject_id) where.subject_id = subject_id;
    if (status) where.status = status;
    const quizzes = await prisma.quizzes.findMany({ where });
    return res.status(200).json({ success: true, message: 'Daftar quiz berhasil diambil', data: toQuizListResponse(quizzes) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const getQuizById = async (req, res) => {
  try {
    const { view } = req.query;
    const q = await prisma.quizzes.findUnique({
      where: { id: req.params.id },
      include: {
        quiz_questions: {
          include: { quiz_options: true }
        }
      }
    });
    if (!q) return res.status(404).json({ success: false, message: 'Quiz tidak ditemukan' });
    
    const data = view === 'guru' ? toQuizDetailGuruResponse(q) : toQuizDetailSiswaResponse(q);
    return res.status(200).json({ success: true, message: 'Detail quiz berhasil diambil', data });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};
