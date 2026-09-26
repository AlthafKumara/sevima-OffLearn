export const toQuizQuestionResponse = (q) => ({
  id: q.id,
  quiz_id: q.quiz_id,
  pertanyaan: q.pertanyaan,
  tipe_soal: q.tipe_soal,
  urutan: q.urutan,
  opsi: q.quiz_options ? q.quiz_options.map(opt => ({
    id: opt.id,
    teks_opsi: opt.teks_opsi,
    is_benar: opt.is_benar
  })) : []
});
