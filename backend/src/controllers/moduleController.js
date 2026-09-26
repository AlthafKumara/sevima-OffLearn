import prisma from '../configs/prisma.js';
import { toModuleResponse, toModuleListResponse } from '../models/moduleResponseDto.js';

export const createModule = async (req, res) => {
  try {
    const m = await prisma.modules.create({ data: req.body });
    return res.status(201).json({ success: true, message: 'Modul berhasil dibuat', data: toModuleResponse(m) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const getModules = async (req, res) => {
  try {
    const { created_by, target_kelas, subject_id, status } = req.query;
    const where = {};
    if (created_by) where.created_by = created_by;
    if (target_kelas) where.target_kelas = target_kelas;
    if (subject_id) where.subject_id = subject_id;
    if (status) where.status = status;
    const modules = await prisma.modules.findMany({ where });
    return res.status(200).json({ success: true, message: 'Daftar modul berhasil diambil', data: toModuleListResponse(modules) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const getModuleById = async (req, res) => {
  try {
    const m = await prisma.modules.findUnique({ where: { id: req.params.id } });
    if (!m) return res.status(404).json({ success: false, message: 'Modul tidak ditemukan' });
    return res.status(200).json({ success: true, message: 'Detail modul berhasil diambil', data: toModuleResponse(m) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const updateModule = async (req, res) => {
  try {
    const { requested_by, konten, status } = req.body;
    const existing = await prisma.modules.findUnique({ where: { id: req.params.id } });
    if (!existing || existing.created_by !== requested_by) {
      return res.status(404).json({ success: false, message: 'Modul tidak ditemukan atau bukan milik guru ini' });
    }
    const updateData = { status };
    if (konten && konten !== existing.konten) {
      updateData.konten = konten;
      updateData.versi = (existing.versi || 1) + 1;
    }
    const m = await prisma.modules.update({ where: { id: req.params.id }, data: updateData });
    return res.status(200).json({ success: true, message: 'Modul berhasil diperbarui', data: toModuleResponse(m) });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

export const deleteModule = async (req, res) => {
  try {
    const { requested_by } = req.body;
    const existing = await prisma.modules.findUnique({ where: { id: req.params.id } });
    if (!existing || existing.created_by !== requested_by) {
      return res.status(404).json({ success: false, message: 'Modul tidak ditemukan atau bukan milik guru ini' });
    }
    await prisma.modules.delete({ where: { id: req.params.id } });
    return res.status(200).json({ success: true, message: 'Modul berhasil dihapus', data: null });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};
