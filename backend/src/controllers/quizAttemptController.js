import prisma from '../configs/prisma.js';
import { toQuizAttemptListResponse, toQuizAttemptHistoryResponse, toQuizAnswerListResponse } from '../models/quizAttemptResponseDto.js';

export const getQuizAttempts = async (req, res) => {
  try {
    const { user_id } = req.query;
    if (user_id) {
      const a = await prisma.quiz_attempts.findMany({ where: { user_id } });
      return res.status(200).json({ success: true, message: 'Riwayat quiz berhasil diambil', data: toQuizAttemptHistoryResponse(a) });
    }
    return res.status(400).json({ success: false, message: 'Missing user_id' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const getQuizAttemptsByQuiz = async (req, res) => {
  try {
    const { id } = req.params;
    const a = await prisma.quiz_attempts.findMany({
      where: { quiz_id: id },
      include: { profiles: true }
    });
    return res.status(200).json({ success: true, message: 'Hasil quiz siswa berhasil diambil', data: toQuizAttemptListResponse(a) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const getQuizAnswersByAttempt = async (req, res) => {
  try {
    const { attemptId } = req.params;
    const a = await prisma.quiz_answers.findMany({
      where: { attempt_id: attemptId },
      include: { quiz_questions: true, quiz_options: true }
    });
    return res.status(200).json({ success: true, message: 'Detail jawaban berhasil diambil', data: toQuizAnswerListResponse(a) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};
