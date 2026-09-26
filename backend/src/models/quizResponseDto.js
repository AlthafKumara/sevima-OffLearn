export const toQuizResponse = (q) => ({
  id: q.id,
  subject_id: q.subject_id,
  created_by: q.created_by,
  nama_quiz: q.nama_quiz,
  target_kelas: q.target_kelas,
  status: q.status,
  updated_at: q.updated_at,
});
export const toQuizListResponse = (quizzes) => quizzes.map(q => ({
  id: q.id,
  nama_quiz: q.nama_quiz,
}));
export const toQuizDetailGuruResponse = (q) => ({
  id: q.id,
  nama_quiz: q.nama_quiz,
  status: q.status,
  questions: q.quiz_questions.map(question => ({
    id: question.id,
    pertanyaan: question.pertanyaan,
    opsi: question.quiz_options.map(opt => ({
      id: opt.id,
      teks_opsi: opt.teks_opsi,
      is_benar: opt.is_benar
    }))
  }))
});
export const toQuizDetailSiswaResponse = (q) => ({
  id: q.id,
  nama_quiz: q.nama_quiz,
  questions: q.quiz_questions.map(question => ({
    id: question.id,
    pertanyaan: question.pertanyaan,
    opsi: question.quiz_options.map(opt => ({
      id: opt.id,
      teks_opsi: opt.teks_opsi
    }))
  }))
});
