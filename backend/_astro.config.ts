import { defineConfig } from "astro/config";
import adapter from "./adapter/index.mjs";
import type { IncomingMessage, ServerResponse } from "node:http";
import { experimental_AstroContainer } from "astro/container";

export default defineConfig({
  output: "server",
  adapter: adapter(),
  srcDir: "./app/views",
  integrations: [
    {
      name: "aor:dev",
      hooks: {
        async "astro:server:setup"({ server }) {
          const container = await experimental_AstroContainer.create();

          server.middlewares.use(async function middleware(
            incomingMessage: IncomingMessage,
            res: ServerResponse,
            next: () => void
          ) {
            const request = toRequest(incomingMessage);
            if (!request.url) return next();

            const url = new URL(request.url);
            
            // Skip middleware for astro views
            if (url.pathname.startsWith('/views/')) {
              return next();
            }

            try {
              // Forward the request to Rails
              const rubyResponse = await fetch(
                new URL(url.pathname, "http://localhost:3000"),
                {
                  method: request.method,
                  headers: {
                    ...Object.fromEntries(request.headers),
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                  }
                }
              );

              const view = rubyResponse.headers.get("X-Astro-View");
              if (!view) {
                return writeResponse(rubyResponse, res);
              }

              // Parse props from Rails
              let props = {};
              try {
                const text = await rubyResponse.text();
                if (text) {
                  props = JSON.parse(text);
                }
              } catch (e) {
                console.error('Failed to parse JSON from Rails:', e);
              }

              // Load and render the Astro component directly
              const viewPath = `./app/views/${view}.astro`;
              console.log('Loading view:', viewPath);
              
              try {
                const page = await server.ssrLoadModule(viewPath);
                const astroResponse = await container.renderToResponse(page.default, {
                  props,
                  request
                });

                return writeResponse(astroResponse, res);
              } catch (e) {
                console.error('Failed to render Astro view:', e);
                return writeResponse(
                  new Response('Internal Server Error', { status: 500 }), 
                  res
                );
              }
            } catch (error) {
              console.error('Middleware error:', error);
              return writeResponse(
                new Response('Internal Server Error', { status: 500 }), 
                res
              );
            }
          });
        },
      },
    },
  ],
  vite: {
    server: {
      watch: {
        ignored: ['**/generated/**']
      }
    }
  }
});