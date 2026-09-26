import prisma from '../configs/prisma.js';
import { toQuizQuestionResponse } from '../models/quizQuestionResponseDto.js';

export const createQuizQuestion = async (req, res) => {
  try {
    const { quizId } = req.params;
    const { created_by, pertanyaan, tipe_soal, urutan, opsi } = req.body;
    
    // Check ownership
    const quiz = await prisma.quizzes.findUnique({ where: { id: quizId } });
    if (!quiz || quiz.created_by !== created_by) {
      return res.status(404).json({ success: false, message: 'Quiz tidak ditemukan atau bukan milik guru ini' });
    }

    const question = await prisma.quiz_questions.create({
      data: {
        quiz_id: quizId,
        pertanyaan,
        tipe_soal,
        urutan,
        quiz_options: {
          create: opsi.map(o => ({ teks_opsi: o.teks_opsi, is_benar: o.is_benar }))
        }
      },
      include: { quiz_options: true }
    });

    return res.status(201).json({ success: true, message: 'Soal berhasil ditambahkan', data: toQuizQuestionResponse(question) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const updateQuizQuestion = async (req, res) => {
  try {
    const { pertanyaan, urutan } = req.body;
    const q = await prisma.quiz_questions.update({
      where: { id: req.params.id },
      data: { pertanyaan, urutan }
    });
    return res.status(200).json({ success: true, message: 'Soal berhasil diperbarui', data: toQuizQuestionResponse(q) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const deleteQuizQuestion = async (req, res) => {
  try {
    await prisma.quiz_questions.delete({ where: { id: req.params.id } });
    return res.status(200).json({ success: true, message: 'Soal berhasil dihapus beserta opsinya', data: null });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};
