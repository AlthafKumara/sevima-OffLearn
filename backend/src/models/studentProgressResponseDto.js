export const toStudentProgressResponse = (p) => ({
  user_id: p.user_id,
  nama: p.profiles?.nama,
  kelas: p.profiles?.kelas,
  status: p.status,
  client_timestamp: p.client_timestamp
});
export const toStudentProgressListResponse = (progresses) => progresses.map(toStudentProgressResponse);
export const toStudentProgressHistoryResponse = (progresses) => progresses.map(p => ({
  module_id: p.module_id,
  status: p.status,
  client_timestamp: p.client_timestamp
}));
