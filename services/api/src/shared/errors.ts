import type { ErrorRequestHandler } from 'express';
import { ZodError } from 'zod';

export class ApiError extends Error {
  constructor(public readonly status: number, public readonly code: string, message: string, public readonly details?: unknown) {
    super(message);
  }
}

export const errorHandler: ErrorRequestHandler = (error, request, response, _next) => {
  const requestId = request.requestId;
  if (error instanceof ZodError) {
    const details = error.issues.map((issue) => ({ path: issue.path, code: issue.code, message: issue.message }));
    response.status(400).json({ error: { code: 'VALIDATION_ERROR', message: 'Request validation failed', details, requestId } });
    return;
  }
  if (error instanceof ApiError) {
    response.status(error.status).json({ error: { code: error.code, message: error.message, ...(error.details ? { details: error.details } : {}), requestId } });
    return;
  }
  if (error instanceof Error && 'type' in error && error.type === 'entity.too.large') {
    response.status(413).json({ error: { code: 'BODY_TOO_LARGE', message: 'Request body exceeds the allowed size', requestId } });
    return;
  }
  console.error({ requestId, error: error instanceof Error ? error.message : 'Unknown error' });
  response.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'An unexpected server error occurred', requestId } });
};
