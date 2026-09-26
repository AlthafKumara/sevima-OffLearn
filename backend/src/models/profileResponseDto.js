export const toProfileResponse = (profile) => ({
  id: profile.id,
  nama: profile.nama,
  role: profile.role,
  kelas: profile.kelas ?? null,
  created_at: profile.created_at,
});
