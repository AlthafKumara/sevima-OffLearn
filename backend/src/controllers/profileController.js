import prisma from '../configs/prisma.js';
import { toProfileResponse } from '../models/profileResponseDto.js';

export const createProfile = async (req, res) => {
  try {
    const {id, nama, role, kelas } = req.body;

    console.log(req.body);
    const existing = await prisma.profiles.findUnique({ where: { id: id } });
    if (existing) {
      return res.status(409).json({ success: false, message: 'Profile dengan id ini sudah ada' });
    }
    const profile = await prisma.profiles.create({data : { id : id, nama : nama, role : role, kelas : kelas }});
    return res.status(201).json({ success: true, message: 'Profile berhasil dibuat', data: toProfileResponse(profile) });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const getProfileById = async (req, res) => {
  try {
    const profile = await prisma.profiles.findUnique({ where: { id: req.params.id } });
    if (!profile) return res.status(404).json({ success: false, message: 'Profile tidak ditemukan' });
    return res.status(200).json({ success: true, message: 'Profile ditemukan', data: toProfileResponse(profile) });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const updateProfile = async (req, res) => {
  try {
    const { nama, kelas } = req.body;
    const profile = await prisma.profiles.update({
      where: { id: req.params.id },
      data: { nama, kelas }
    });
    return res.status(200).json({ success: true, message: 'Profile berhasil diperbarui', data: toProfileResponse(profile) });
  } catch (error) {
    if (error.code === 'P2025') return res.status(404).json({ success: false, message: 'Profile tidak ditemukan' });
    console.error(error);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};
