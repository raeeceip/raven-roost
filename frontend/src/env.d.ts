/// <reference path="../.astro/types.d.ts" />
/// <reference types="@cloudflare/workers-types" />
import type { KVNamespace, D1Database } from '@cloudflare/workers-types';

declare namespace App {
  interface Env {
    SPACES_KV: KVNamespace;
    USERS_KV: KVNamespace;
    DB: D1Database;
  }

  interface Locals extends App.Env {}
}

interface ImportMetaEnv {
  readonly SPACES_KV: KVNamespace;
  readonly USERS_KV: KVNamespace;
  readonly DB: D1Database;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}