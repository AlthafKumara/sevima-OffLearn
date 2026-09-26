import prisma from '../configs/prisma.js';

export const checkRole = (allowedRoles) => {
  return async (req, res, next) => {
    try {
      // Determine user_id from body or query
      const userId = req.body.requested_by || req.query.requested_by || req.body.created_by || req.query.created_by || req.body.user_id || req.query.user_id;

      if (!userId) {
        return res.status(401).json({ success: false, message: 'Unauthorized: Missing user_id / requested_by in request' });
      }

      const profile = await prisma.profiles.findUnique({ where: { id: userId } });
      if (!profile) {
        return res.status(404).json({ success: false, message: 'Profile tidak ditemukan' });
      }

      if (!allowedRoles.includes(profile.role)) {
        return res.status(403).json({ success: false, message: 'Role tidak diizinkan mengakses endpoint ini' });
      }

      // Pass profile to next handlers if needed
      req.userProfile = profile;
      next();
    } catch (error) {
      console.error(error);
      return res.status(500).json({ success: false, message: 'Internal server error during role check' });
    }
  };
};
