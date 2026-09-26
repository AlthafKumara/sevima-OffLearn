import prisma from '../configs/prisma.js';
import { toQuizOptionResponse } from '../models/quizOptionResponseDto.js';

export const updateQuizOption = async (req, res) => {
  try {
    const { teks_opsi, is_benar } = req.body;
    const o = await prisma.quiz_options.update({
      where: { id: req.params.id },
      data: { teks_opsi, is_benar }
    });
    return res.status(200).json({ success: true, message: 'Opsi berhasil diperbarui', data: toQuizOptionResponse(o) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const deleteQuizOption = async (req, res) => {
  try {
    await prisma.quiz_options.delete({ where: { id: req.params.id } });
    return res.status(200).json({ success: true, message: 'Opsi berhasil dihapus', data: null });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};
