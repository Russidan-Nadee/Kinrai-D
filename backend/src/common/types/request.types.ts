import { Request } from 'express';

export interface AuthenticatedUser {
  id: string;
  email: string;
  user_metadata?: Record<string, unknown>;
}

export interface AuthRequest extends Request {
  user: AuthenticatedUser;
}

export interface TokenRequest extends Request {
  token: string;
}

export interface RequestWithUser extends Request {
  user: {
    id: string;
    email: string;
    [key: string]: unknown;
  };
}
