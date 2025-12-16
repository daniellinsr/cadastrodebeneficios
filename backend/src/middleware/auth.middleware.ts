import { Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { jwtConfig } from '../config/jwt';
import { AuthRequest, UserPayload } from '../types';

export const authMiddleware = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      res.status(401).json({
        error: 'UNAUTHORIZED',
        message: 'No authorization header provided',
      });
      return;
    }

    const parts = authHeader.split(' ');

    if (parts.length !== 2 || parts[0] !== 'Bearer') {
      res.status(401).json({
        error: 'UNAUTHORIZED',
        message: 'Invalid authorization header format',
      });
      return;
    }

    const token = parts[1];

    const decoded = jwt.verify(token, jwtConfig.secret) as UserPayload;
    req.user = decoded;

    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      res.status(401).json({
        error: 'TOKEN_EXPIRED',
        message: 'Access token has expired',
      });
      return;
    }

    if (error instanceof jwt.JsonWebTokenError) {
      res.status(401).json({
        error: 'INVALID_TOKEN',
        message: 'Invalid access token',
      });
      return;
    }

    res.status(500).json({
      error: 'SERVER_ERROR',
      message: 'Internal server error',
    });
  }
};
