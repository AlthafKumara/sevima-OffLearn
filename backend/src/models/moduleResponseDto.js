export const toModuleResponse = (m) => ({
  id: m.id,
  subject_id: m.subject_id,
  created_by: m.created_by,
  judul: m.judul,
  konten: m.konten,
  target_kelas: m.target_kelas,
  versi: m.versi,
  status: m.status,
  urutan: m.urutan,
  updated_at: m.updated_at,
});
export const toModuleListResponse = (modules) => modules.map(m => ({
  id: m.id,
  judul: m.judul,
  status: m.status,
  versi: m.versi,
  updated_at: m.updated_at,
}));
