import prisma from '../configs/prisma.js';
import { toStudentProgressListResponse, toStudentProgressHistoryResponse } from '../models/studentProgressResponseDto.js';

export const getStudentProgress = async (req, res) => {
  try {
    const { user_id } = req.query;
    if (user_id) {
      const p = await prisma.student_progress.findMany({ where: { user_id } });
      return res.status(200).json({ success: true, message: 'Riwayat progres berhasil diambil', data: toStudentProgressHistoryResponse(p) });
    }
    return res.status(400).json({ success: false, message: 'Missing user_id' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const getModuleProgress = async (req, res) => {
  try {
    const { id } = req.params;
    const p = await prisma.student_progress.findMany({
      where: { module_id: id },
      include: { profiles: true }
    });
    return res.status(200).json({ success: true, message: 'Progres siswa berhasil diambil', data: toStudentProgressListResponse(p) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};
