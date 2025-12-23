import { Response } from 'express';
import pool from '../config/database';
import { AuthRequest } from '../types';
import { sendVerificationEmail } from '../services/email.service';

/**
 * Generate a random 6-digit verification code
 */
const generateVerificationCode = (): string => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

/**
 * Send verification code to user's email or phone
 * POST /api/verification/send
 */
export const sendVerificationCode = async (
  req: AuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { type } = req.body; // 'email' or 'phone'
    const userId = req.user!.id;

    // Validate type
    if (!type || !['email', 'phone'].includes(type)) {
      res.status(400).json({
        error: 'INVALID_TYPE',
        message: 'Type must be either "email" or "phone"',
      });
      return;
    }

    // Get user details
    const userResult = await pool.query(
      'SELECT id, email, name, phone_number, email_verified, phone_verified FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      res.status(404).json({
        error: 'USER_NOT_FOUND',
        message: 'User not found',
      });
      return;
    }

    const user = userResult.rows[0];

    // Check if already verified
    if (type === 'email' && user.email_verified) {
      res.status(400).json({
        error: 'ALREADY_VERIFIED',
        message: 'Email is already verified',
      });
      return;
    }

    if (type === 'phone' && user.phone_verified) {
      res.status(400).json({
        error: 'ALREADY_VERIFIED',
        message: 'Phone number is already verified',
      });
      return;
    }

    // Check for recent codes (rate limiting)
    const recentCodeResult = await pool.query(
      `SELECT created_at FROM verification_codes
       WHERE user_id = $1 AND type = $2 AND created_at > NOW() - INTERVAL '1 minute'
       ORDER BY created_at DESC LIMIT 1`,
      [userId, type]
    );

    if (recentCodeResult.rows.length > 0) {
      res.status(429).json({
        error: 'RATE_LIMIT',
        message: 'Please wait 1 minute before requesting a new code',
      });
      return;
    }

    // Invalidate any existing unverified codes for this user and type
    await pool.query(
      `UPDATE verification_codes
       SET verified = false, expires_at = NOW()
       WHERE user_id = $1 AND type = $2 AND verified = false`,
      [userId, type]
    );

    // Generate new verification code
    const code = generateVerificationCode();

    // Set expiration (15 minutes from now)
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    // Save code to database
    await pool.query(
      `INSERT INTO verification_codes (user_id, code, type, expires_at)
       VALUES ($1, $2, $3, $4)`,
      [userId, code, type, expiresAt]
    );

    // Send code via email or SMS
    if (type === 'email') {
      try {
        await sendVerificationEmail(user.email, code, user.name);
      } catch (error) {
        console.error('Failed to send verification email:', error);
        res.status(500).json({
          error: 'EMAIL_SEND_FAILED',
          message: 'Failed to send verification email',
        });
        return;
      }
    } else if (type === 'phone') {
      // TODO: Implement SMS sending with Twilio
      // For now, we'll just log it (development)
      console.log(`📱 SMS Verification Code for ${user.phone_number}: ${code}`);

      // In production, this would call Twilio API:
      // await sendVerificationSMS(user.phone_number, code);
    }

    res.json({
      message: `Verification code sent to your ${type}`,
      expiresAt: expiresAt.toISOString(),
    });
  } catch (error) {
    console.error('Send verification code error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Failed to send verification code',
    });
  }
};

/**
 * Verify the code entered by the user
 * POST /api/verification/verify
 */
export const verifyCode = async (
  req: AuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { type, code } = req.body; // 'email' or 'phone', and the 6-digit code
    const userId = req.user!.id;

    // Validate input
    if (!type || !['email', 'phone'].includes(type)) {
      res.status(400).json({
        error: 'INVALID_TYPE',
        message: 'Type must be either "email" or "phone"',
      });
      return;
    }

    if (!code || !/^\d{6}$/.test(code)) {
      res.status(400).json({
        error: 'INVALID_CODE',
        message: 'Code must be a 6-digit number',
      });
      return;
    }

    // Find the verification code
    const codeResult = await pool.query(
      `SELECT id, verified, expires_at FROM verification_codes
       WHERE user_id = $1 AND type = $2 AND code = $3
       ORDER BY created_at DESC LIMIT 1`,
      [userId, type, code]
    );

    if (codeResult.rows.length === 0) {
      res.status(400).json({
        error: 'INVALID_CODE',
        message: 'Invalid verification code',
      });
      return;
    }

    const verificationCode = codeResult.rows[0];

    // Check if already verified
    if (verificationCode.verified) {
      res.status(400).json({
        error: 'CODE_ALREADY_USED',
        message: 'This verification code has already been used',
      });
      return;
    }

    // Check if expired
    if (new Date() > new Date(verificationCode.expires_at)) {
      res.status(400).json({
        error: 'CODE_EXPIRED',
        message: 'Verification code has expired. Please request a new one.',
      });
      return;
    }

    // Mark code as verified
    await pool.query(
      `UPDATE verification_codes
       SET verified = true, verified_at = NOW()
       WHERE id = $1`,
      [verificationCode.id]
    );

    // Update user verification status
    if (type === 'email') {
      await pool.query(
        `UPDATE users SET email_verified = true, email_verified_at = NOW() WHERE id = $1`,
        [userId]
      );
    } else {
      await pool.query(
        `UPDATE users SET phone_verified = true, phone_verified_at = NOW() WHERE id = $1`,
        [userId]
      );
    }

    // Get updated user
    const userResult = await pool.query(
      `SELECT id, email, name, phone_number, email_verified, phone_verified,
              profile_completion_status, created_at
       FROM users WHERE id = $1`,
      [userId]
    );

    const user = userResult.rows[0];

    res.json({
      message: `${type === 'email' ? 'Email' : 'Phone number'} verified successfully`,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        phoneNumber: user.phone_number,
        emailVerified: user.email_verified,
        phoneVerified: user.phone_verified,
        profileCompletionStatus: user.profile_completion_status,
        createdAt: user.created_at,
      },
    });
  } catch (error) {
    console.error('Verify code error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Failed to verify code',
    });
  }
};

/**
 * Get verification status for the current user
 * GET /api/verification/status
 */
export const getVerificationStatus = async (
  req: AuthRequest,
  res: Response
): Promise<void> => {
  try {
    const userId = req.user!.id;

    const userResult = await pool.query(
      'SELECT email_verified, phone_verified FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      res.status(404).json({
        error: 'USER_NOT_FOUND',
        message: 'User not found',
      });
      return;
    }

    const user = userResult.rows[0];

    res.json({
      emailVerified: user.email_verified,
      phoneVerified: user.phone_verified,
    });
  } catch (error) {
    console.error('Get verification status error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Failed to get verification status',
    });
  }
};

/**
 * Resend verification code
 * POST /api/verification/resend
 */
export const resendVerificationCode = async (
  req: AuthRequest,
  res: Response
): Promise<void> => {
  // This is just an alias for sendVerificationCode
  await sendVerificationCode(req, res);
};
