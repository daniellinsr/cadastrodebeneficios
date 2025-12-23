import dotenv from 'dotenv';

dotenv.config();

export const jwtConfig = {
  secret: process.env.JWT_SECRET || 'your_secret_key',
  expiresIn: (process.env.JWT_EXPIRES_IN || '7d') as string,
  refreshExpiresIn: (process.env.REFRESH_TOKEN_EXPIRES_IN || '30d') as string,
};
