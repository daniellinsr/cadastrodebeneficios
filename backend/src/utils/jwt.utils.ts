import jwt from 'jsonwebtoken';
import { jwtConfig } from '../config/jwt';
import { UserPayload, AuthToken } from '../types';
import { v4 as uuidv4 } from 'uuid';
import pool from '../config/database';

export const generateTokens = async (user: {
  id: string;
  email: string;
  name: string;
  phone_number?: string;
  cpf?: string;
  birth_date?: string;
  role?: string;
  email_verified?: boolean;
  phone_verified?: boolean;
  profile_completion_status?: string;
  created_at?: Date;
}): Promise<AuthToken> => {
  const payload: UserPayload = {
    id: user.id,
    email: user.email,
    name: user.name,
  };

  const accessToken = jwt.sign(payload, jwtConfig.secret, {
    expiresIn: jwtConfig.expiresIn as any,
  });

  const refreshToken = uuidv4();

  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 30);

  await pool.query(
    `INSERT INTO refresh_tokens (id, user_id, token, expires_at)
     VALUES ($1, $2, $3, $4)`,
    [uuidv4(), user.id, refreshToken, expiresAt]
  );

  const expiresInSeconds = 7 * 24 * 60 * 60;

  return {
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
      phone_number: user.phone_number,
      cpf: user.cpf,
      birth_date: user.birth_date,
      role: user.role || 'beneficiary',
      is_email_verified: user.email_verified || false,
      is_phone_verified: user.phone_verified || false,
      profile_completion_status: user.profile_completion_status || 'complete',
      created_at: user.created_at,
    },
    access_token: accessToken,
    refresh_token: refreshToken,
    token_type: 'Bearer',
    expires_in: expiresInSeconds,
  };
};

export const verifyRefreshToken = async (
  token: string
): Promise<string | null> => {
  const result = await pool.query(
    `SELECT user_id FROM refresh_tokens
     WHERE token = $1 AND expires_at > NOW() AND revoked = false
     LIMIT 1`,
    [token]
  );

  if (result.rows.length === 0) {
    return null;
  }

  return result.rows[0].user_id;
};

export const revokeRefreshToken = async (token: string): Promise<void> => {
  await pool.query(
    `UPDATE refresh_tokens SET revoked = true WHERE token = $1`,
    [token]
  );
};
