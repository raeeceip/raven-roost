import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';
import prefetch from '@astrojs/prefetch';

import node from '@astrojs/node';

export default defineConfig({
  integrations: [
    react(),
    tailwind(),
    prefetch()
  ],

  output: 'hybrid',

  adapter: node({
    mode: 'standalone'
  })
});