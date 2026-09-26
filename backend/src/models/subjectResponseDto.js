export const toSubjectListResponse = (subjects) => subjects.map(s => ({
  id: s.id,
  nama_subject: s.nama_subject
}));
export const toSubjectResponse = (s) => ({
  id: s.id,
  nama_subject: s.nama_subject
});
