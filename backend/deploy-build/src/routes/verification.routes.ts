import { Router } from 'express';
import {
  sendVerificationCode,
  verifyCode,
  getVerificationStatus,
  resendVerificationCode,
} from '../controllers/verification.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

// All verification routes require authentication
router.use(authMiddleware);

// Send verification code (email or phone)
router.post('/send', sendVerificationCode);

// Verify the code
router.post('/verify', verifyCode);

// Get current verification status
router.get('/status', getVerificationStatus);

// Resend verification code
router.post('/resend', resendVerificationCode);

export default router;
