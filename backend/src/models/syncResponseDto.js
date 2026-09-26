export const toSyncDownloadResponse = (modules, quizzes) => ({
  modules: modules.map(m => ({
    id: m.id,
    judul: m.judul,
    konten: m.konten,
    versi: m.versi,
    updated_at: m.updated_at
  })),
  quizzes: quizzes.map(q => ({
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
  }))
});
