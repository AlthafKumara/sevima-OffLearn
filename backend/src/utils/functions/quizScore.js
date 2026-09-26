export function calculateQuizScore(jawaban, questionsBesertaOpsiBenar) {
  let benar = 0;
  if (!questionsBesertaOpsiBenar || questionsBesertaOpsiBenar.length === 0) return 0;
  for (const j of jawaban) {
    const soal = questionsBesertaOpsiBenar.find(q => q.id === j.question_id);
    const opsiBenar = soal?.quiz_options?.find(o => o.is_benar);
    if (opsiBenar && opsiBenar.id === j.selected_option_id) benar++;
  }
  return Math.round((benar / questionsBesertaOpsiBenar.length) * 100);
}
