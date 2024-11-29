import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';
import prefetch from '@astrojs/prefetch';
import cloudflare from '@astrojs/cloudflare';
import icon from "astro-icon";

export default defineConfig({
  integrations: [
    react({
      include: ['**/components/**/*.tsx'],
      experimentalReactChildren: true
    }),
    tailwind(),
    icon({
      include: {
        mdi: ['*'], // This includes all MDI icons
      },
    }),
    prefetch()
  ],
  output: 'server',
  adapter: cloudflare({
    mode: 'directory',
    runtime: {
      mode: 'local',
      type: 'modules',
      bindings: {
        // Reference your D1 database
        'DB': { type: 'kv' },
        // Reference your KV namespaces
        'SPACES_KV': { type: 'kv' },
        'USERS_KV': { type: 'kv' }
      }
    }
  })
});