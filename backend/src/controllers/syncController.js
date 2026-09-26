import prisma from '../configs/prisma.js';
import { toSyncDownloadResponse } from '../models/syncResponseDto.js';
import { calculateQuizScore } from '../utils/functions/quizScore.js';

export const syncDownload = async (req, res) => {
  try {
    const { target_kelas, updated_since } = req.query;
    const whereModules = { status: 'published' };
    const whereQuizzes = { status: 'published' };
    if (target_kelas) {
      whereModules.target_kelas = target_kelas;
      whereQuizzes.target_kelas = target_kelas;
    }
    
    const modules = await prisma.modules.findMany({ where: whereModules });
    const quizzes = await prisma.quizzes.findMany({
      where: whereQuizzes,
      include: {
        quiz_questions: {
          include: { quiz_options: true }
        }
      }
    });

    return res.status(200).json({ success: true, message: 'Konten berhasil diambil', data: toSyncDownloadResponse(modules, quizzes) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const syncStudentProgress = async (req, res) => {
  try {
    const { user_id, items } = req.body;
    const successIds = [];
    for (const item of items) {
      await prisma.student_progress.upsert({
        where: { id: item.id },
        update: { status: item.status, client_timestamp: new Date(item.client_timestamp) },
        create: {
          id: item.id,
          user_id,
          module_id: item.module_id,
          status: item.status,
          client_timestamp: new Date(item.client_timestamp)
        }
      });
      successIds.push(item.id);
    }
    return res.status(200).json({ success: true, message: `${successIds.length} dari ${items.length} progres berhasil disinkronkan`, data: { success: successIds, failed: [] } });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const syncQuizAttempts = async (req, res) => {
  try {
    const { user_id, items } = req.body;
    const successList = [];
    
    for (const item of items) {
      // Hitung skor
      const quiz = await prisma.quizzes.findUnique({
        where: { id: item.quiz_id },
        include: { quiz_questions: { include: { quiz_options: true } } }
      });
      
      const skor = calculateQuizScore(item.jawaban, quiz.quiz_questions);

      const attempt = await prisma.quiz_attempts.create({
        data: {
          id: item.id,
          user_id,
          quiz_id: item.quiz_id,
          skor,
          client_timestamp: new Date(item.client_timestamp),
          quiz_answers: {
            create: item.jawaban.map(j => ({
              question_id: j.question_id,
              selected_option_id: j.selected_option_id
            }))
          }
        }
      });
      successList.push({ id: attempt.id, skor, created_at: attempt.client_timestamp });
    }
    
    return res.status(200).json({ success: true, message: `${successList.length} dari ${items.length} quiz attempt berhasil disinkronkan`, data: { success: successList, failed: [] } });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};
