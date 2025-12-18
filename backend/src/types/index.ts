import { Request } from 'express';

export interface UserPayload {
  id: string;
  email: string;
  name: string;
}

export interface AuthRequest extends Request {
  user?: UserPayload;
}

export interface User {
  id: string;
  email: string;
  name: string;
  phone_number: string;
  cpf?: string;
  google_id?: string;
  password_hash?: string;
  email_verified: boolean;
  phone_verified: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface AuthToken {
  user: {
    id: string;
    email: string;
    name: string;
    phone_number?: string;
    cpf?: string;
    birth_date?: string;
    role?: string;
    is_email_verified?: boolean;
    is_phone_verified?: boolean;
    profile_completion_status?: string;
    created_at?: Date;
  };
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
}
