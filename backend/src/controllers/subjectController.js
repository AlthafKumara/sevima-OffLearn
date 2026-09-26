import prisma from '../configs/prisma.js';
import { toSubjectListResponse, toSubjectResponse } from '../models/subjectResponseDto.js';

export const getSubjects = async (req, res) => {
  try {
    const subjects = await prisma.subjects.findMany();
    return res.status(200).json({ success: true, message: 'Daftar subject berhasil diambil', data: toSubjectListResponse(subjects) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const createSubject = async (req, res) => {
  try {
    const { nama_subject } = req.body;
    const subject = await prisma.subjects.create({ data: { nama_subject } });
    return res.status(201).json({ success: true, message: 'Subject berhasil dibuat', data: toSubjectResponse(subject) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};
