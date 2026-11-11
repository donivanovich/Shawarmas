import type { Request } from 'express';

export type Principal = {
  type: 'customer' | 'employee';
  id: number;
  role: 'customer' | 'writter' | 'editor' | 'admin';
  sessionId: string;
};

declare global {
  namespace Express {
    interface Request {
      requestId: string;
      principal?: Principal;
    }
  }
}

export type AuthedRequest = Request & { principal: Principal };
