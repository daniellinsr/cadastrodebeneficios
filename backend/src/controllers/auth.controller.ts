import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { OAuth2Client } from 'google-auth-library';
import { auth as firebaseAuth } from '../config/firebase-admin';
import pool from '../config/database';
import { generateTokens, verifyRefreshToken, revokeRefreshToken } from '../utils/jwt.utils';
import { AuthRequest } from '../types';

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export const loginWithEmail = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'Email and password are required',
      });
      return;
    }

    const result = await pool.query(
      `SELECT id, email, name, phone_number, cpf, birth_date, role, password_hash,
              email_verified, phone_verified, profile_completion_status, created_at
       FROM users WHERE email = $1 AND deleted_at IS NULL`,
      [email]
    );

    if (result.rows.length === 0) {
      res.status(401).json({
        error: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password',
      });
      return;
    }

    const user = result.rows[0];

    if (!user.password_hash) {
      res.status(401).json({
        error: 'INVALID_CREDENTIALS',
        message: 'This account uses Google login',
      });
      return;
    }

    const passwordMatch = await bcrypt.compare(password, user.password_hash);

    if (!passwordMatch) {
      res.status(401).json({
        error: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password',
      });
      return;
    }

    await pool.query(
      `UPDATE users SET last_login_at = NOW() WHERE id = $1`,
      [user.id]
    );

    // Garantir que created_at seja uma string ISO
    const userWithFormattedDate = {
      ...user,
      created_at: user.created_at ? new Date(user.created_at).toISOString() : new Date().toISOString(),
    };

    const tokens = await generateTokens(userWithFormattedDate);

    res.json(tokens);
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Internal server error',
    });
  }
};

export const loginWithGoogle = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id_token } = req.body;

    if (!id_token) {
      res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'Google ID token is required',
      });
      return;
    }

    let payload: { sub?: string; email?: string; name?: string; email_verified?: boolean } | null = null;

    // Tentar validar com Firebase Auth primeiro (tokens do Firebase)
    try {
      const decodedToken = await firebaseAuth.verifyIdToken(id_token);
      payload = {
        sub: decodedToken.uid,
        email: decodedToken.email,
        name: decodedToken.name,
        email_verified: decodedToken.email_verified,
      };
      console.log('Token validado com Firebase Auth');
    } catch (firebaseError) {
      // Se falhar, tentar com Google OAuth2Client (tokens diretos do Google)
      try {
        const ticket = await googleClient.verifyIdToken({
          idToken: id_token,
          audience: process.env.GOOGLE_CLIENT_ID,
        });
        payload = ticket.getPayload() || null;
        console.log('Token validado com Google OAuth2Client');
      } catch (googleError) {
        console.error('Erro ao validar token:', { firebaseError, googleError });
        res.status(401).json({
          error: 'INVALID_TOKEN',
          message: 'Invalid Google ID token',
        });
        return;
      }
    }

    if (!payload || !payload.email) {
      res.status(401).json({
        error: 'INVALID_TOKEN',
        message: 'Invalid Google ID token',
      });
      return;
    }

    let result = await pool.query(
      `SELECT id, email, name, phone_number, cpf, birth_date, role,
              email_verified, phone_verified, profile_completion_status, created_at
       FROM users
       WHERE google_id = $1 AND deleted_at IS NULL`,
      [payload.sub]
    );

    let user;

    if (result.rows.length === 0) {
      result = await pool.query(
        `SELECT id, email, name, phone_number, cpf, birth_date, role,
                email_verified, phone_verified, profile_completion_status, created_at
         FROM users
         WHERE email = $1 AND deleted_at IS NULL`,
        [payload.email]
      );

      if (result.rows.length > 0) {
        await pool.query(
          `UPDATE users SET google_id = $1 WHERE id = $2`,
          [payload.sub, result.rows[0].id]
        );
        user = result.rows[0];
      } else {
        const userId = uuidv4();
        const insertResult = await pool.query(
          `INSERT INTO users (id, email, name, google_id, email_verified, phone_number, role, profile_completion_status)
           VALUES ($1, $2, $3, $4, true, '', 'beneficiary', 'incomplete')
           RETURNING id, email, name, phone_number, cpf, birth_date, role,
                     email_verified, phone_verified, profile_completion_status, created_at`,
          [userId, payload.email, payload.name || '', payload.sub]
        );
        user = insertResult.rows[0];
      }
    } else {
      user = result.rows[0];
    }

    await pool.query(
      `UPDATE users SET last_login_at = NOW() WHERE id = $1`,
      [user.id]
    );

    // Garantir que created_at seja uma string ISO
    const userWithFormattedDate = {
      ...user,
      created_at: user.created_at ? new Date(user.created_at).toISOString() : new Date().toISOString(),
    };

    const tokens = await generateTokens(userWithFormattedDate);

    res.json(tokens);
  } catch (error) {
    console.error('Google login error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Internal server error',
    });
  }
};

export const register = async (req: Request, res: Response): Promise<void> => {
  try {
    const {
      name,
      email,
      password,
      phone_number,
      cpf,
      birth_date,
      cep,
      street,
      number,
      complement,
      neighborhood,
      city,
      state,
    } = req.body;

    if (!name || !email || !password || !phone_number) {
      res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'Name, email, password, and phone number are required',
      });
      return;
    }

    const existingUser = await pool.query(
      `SELECT id FROM users WHERE email = $1 OR (cpf IS NOT NULL AND cpf = $2)`,
      [email, cpf || null]
    );

    if (existingUser.rows.length > 0) {
      res.status(409).json({
        error: 'USER_EXISTS',
        message: 'User with this email or CPF already exists',
      });
      return;
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const userId = uuidv4();

    const result = await pool.query(
      `INSERT INTO users (
        id, email, name, password_hash, phone_number, cpf,
        birth_date, cep, street, number, complement, neighborhood, city, state,
        email_verified, role
      )
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, false, 'beneficiary')
       RETURNING id, email, name, phone_number, cpf, birth_date, role,
                 email_verified, phone_verified, profile_completion_status, created_at`,
      [
        userId,
        email,
        name,
        passwordHash,
        phone_number,
        cpf || null,
        birth_date || null,
        cep || null,
        street || null,
        number || null,
        complement || null,
        neighborhood || null,
        city || null,
        state || null,
      ]
    );

    const user = result.rows[0];

    // Garantir que created_at seja uma string ISO
    const userWithFormattedDate = {
      ...user,
      created_at: user.created_at ? new Date(user.created_at).toISOString() : new Date().toISOString(),
    };

    const tokens = await generateTokens(userWithFormattedDate);

    res.status(201).json(tokens);
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Internal server error',
    });
  }
};

export const refreshToken = async (req: Request, res: Response): Promise<void> => {
  try {
    const { refresh_token } = req.body;

    if (!refresh_token) {
      res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'Refresh token is required',
      });
      return;
    }

    const userId = await verifyRefreshToken(refresh_token);

    if (!userId) {
      res.status(401).json({
        error: 'INVALID_TOKEN',
        message: 'Invalid or expired refresh token',
      });
      return;
    }

    const result = await pool.query(
      `SELECT id, email, name, phone_number, cpf, birth_date, role,
              email_verified, phone_verified, profile_completion_status, created_at
       FROM users WHERE id = $1 AND deleted_at IS NULL`,
      [userId]
    );

    if (result.rows.length === 0) {
      res.status(401).json({
        error: 'USER_NOT_FOUND',
        message: 'User not found',
      });
      return;
    }

    await revokeRefreshToken(refresh_token);

    const user = result.rows[0];

    // Garantir que created_at seja uma string ISO
    const userWithFormattedDate = {
      ...user,
      created_at: user.created_at ? new Date(user.created_at).toISOString() : new Date().toISOString(),
    };

    const tokens = await generateTokens(userWithFormattedDate);

    res.json(tokens);
  } catch (error) {
    console.error('Refresh token error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Internal server error',
    });
  }
};

export const getCurrentUser = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        error: 'UNAUTHORIZED',
        message: 'User not authenticated',
      });
      return;
    }

    const result = await pool.query(
      `SELECT id, email, name, phone_number, cpf, birth_date, role,
              email_verified, phone_verified, profile_completion_status, created_at
       FROM users WHERE id = $1 AND deleted_at IS NULL`,
      [req.user.id]
    );

    if (result.rows.length === 0) {
      res.status(404).json({
        error: 'USER_NOT_FOUND',
        message: 'User not found',
      });
      return;
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get current user error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Internal server error',
    });
  }
};

export const logout = async (req: Request, res: Response): Promise<void> => {
  try {
    const { refresh_token } = req.body;

    if (refresh_token) {
      await revokeRefreshToken(refresh_token);
    }

    res.status(204).send();
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Internal server error',
    });
  }
};

export const completeProfile = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        error: 'UNAUTHORIZED',
        message: 'User not authenticated',
      });
      return;
    }

    const {
      cpf,
      phone_number,
      birth_date,
      cep,
      street,
      number,
      complement,
      neighborhood,
      city,
      state,
    } = req.body;

    // Validar campos obrigatórios
    if (!cpf || !phone_number || !cep) {
      res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'CPF, phone number, and CEP are required',
      });
      return;
    }

    // Atualizar perfil
    const result = await pool.query(
      `UPDATE users
       SET cpf = $1, phone_number = $2, birth_date = $3,
           cep = $4, street = $5, number = $6, complement = $7,
           neighborhood = $8, city = $9, state = $10,
           profile_completion_status = 'complete',
           updated_at = NOW()
       WHERE id = $11
       RETURNING id, email, name, phone_number, cpf, birth_date, role,
                 email_verified, phone_verified, profile_completion_status, created_at`,
      [
        cpf,
        phone_number,
        birth_date || null,
        cep,
        street,
        number,
        complement || null,
        neighborhood,
        city,
        state,
        req.user.id,
      ]
    );

    if (result.rows.length === 0) {
      res.status(404).json({
        error: 'USER_NOT_FOUND',
        message: 'User not found',
      });
      return;
    }

    const user = result.rows[0];

    const userWithFormattedDate = {
      ...user,
      created_at: user.created_at ? new Date(user.created_at).toISOString() : new Date().toISOString(),
    };

    res.json({ user: userWithFormattedDate });
  } catch (error) {
    console.error('Complete profile error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Internal server error',
    });
  }
};

export const forgotPassword = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email } = req.body;

    if (!email) {
      res.status(400).json({
        error: 'INVALID_REQUEST',
        message: 'Email is required',
      });
      return;
    }

    const result = await pool.query(
      `SELECT id FROM users WHERE email = $1 AND deleted_at IS NULL`,
      [email]
    );

    if (result.rows.length > 0) {
      const token = uuidv4();
      const expiresAt = new Date();
      expiresAt.setHours(expiresAt.getHours() + 1);

      await pool.query(
        `INSERT INTO password_reset_tokens (id, user_id, token, expires_at)
         VALUES ($1, $2, $3, $4)`,
        [uuidv4(), result.rows[0].id, token, expiresAt]
      );

      console.log(`Password reset token for ${email}: ${token}`);
    }

    res.status(204).send();
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Internal server error',
    });
  }
};
