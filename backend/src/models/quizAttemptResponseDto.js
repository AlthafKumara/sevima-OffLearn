export const toQuizAttemptResponse = (a) => ({
  attempt_id: a.id,
  user_id: a.user_id,
  nama: a.profiles?.nama,
  skor: a.skor,
  client_timestamp: a.client_timestamp
});
export const toQuizAttemptListResponse = (attempts) => attempts.map(toQuizAttemptResponse);
export const toQuizAttemptHistoryResponse = (attempts) => attempts.map(a => ({
  attempt_id: a.id,
  quiz_id: a.quiz_id,
  skor: a.skor,
  client_timestamp: a.client_timestamp
}));
export const toQuizAnswerListResponse = (answers) => answers.map(a => ({
  question_id: a.question_id,
  pertanyaan: a.quiz_questions?.pertanyaan,
  selected_option: a.quiz_options?.teks_opsi,
  is_benar: a.quiz_options?.is_benar
}));
