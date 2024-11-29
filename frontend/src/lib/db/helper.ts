import type { KVNamespace, D1Database } from '@cloudflare/workers-types';

export interface RuntimeEnv {
  SPACES_KV: KVNamespace;
  USERS_KV: KVNamespace;
  DB: D1Database;
}

export function getEnv(astroEnv: Record<string, any>): RuntimeEnv {
  // If we're in production (Cloudflare)
  if (astroEnv.locals?.DB) {
    return {
      DB: astroEnv.locals.DB,
      SPACES_KV: astroEnv.locals.SPACES_KV,
      USERS_KV: astroEnv.locals.USERS_KV,
    };
  }

  // If we're in development
  return {
    DB: import.meta.env.DB,
    SPACES_KV: import.meta.env.SPACES_KV,
    USERS_KV: import.meta.env.USERS_KV,
  };
}

export function createRoostDB(astroEnv: Record<string, any>) {
  const env = getEnv(astroEnv);
  return new RoostDB(env);
}