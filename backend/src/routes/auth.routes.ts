import { Router } from 'express';
import {
  loginWithEmail,
  loginWithGoogle,
  register,
  refreshToken,
  getCurrentUser,
  logout,
  forgotPassword,
} from '../controllers/auth.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

router.post('/login', loginWithEmail);

router.post('/login/google', loginWithGoogle);

router.post('/register', register);

router.post('/refresh', refreshToken);

router.post('/logout', logout);

router.post('/forgot-password', forgotPassword);

router.get('/me', authMiddleware, getCurrentUser);

export default router;
