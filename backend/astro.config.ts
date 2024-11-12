import { defineConfig } from "astro/config";
import node from "@astrojs/node";
import glob from "fast-glob";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { existsSync } from "node:fs";

export default defineConfig({
  output: "server",
  adapter: node({
    mode: "standalone",
  }),
  srcDir: "generated",
  integrations: [
    {
      name: "aor:views",
      hooks: {
        async "astro:config:setup"() {
          const referenceDir = new URL("app/views/", import.meta.url);
          const generatedDir = new URL("generated/", import.meta.url);
          const pagesDir = new URL("pages/", generatedDir);
          const viewsDir = new URL("views/", pagesDir);

          // Find all Astro views
          const views = await glob(["**/*.astro", "!pages/**/*.astro"], {
            cwd: fileURLToPath(referenceDir),
            onlyFiles: true,
          });

          // Create generated views directory
          await mkdir(viewsDir, { recursive: true });

          // Generate view wrappers
          for (const view of views) {
            const viewUrl = new URL(view, viewsDir);
            const viewRelativeToPage = path.relative(
              path.dirname(fileURLToPath(viewUrl)),
              fileURLToPath(new URL(view, referenceDir))
            );

            // Generate view wrapper with props handling
            const pageContent = `---
import View from ${JSON.stringify(viewRelativeToPage)};
const props = Astro.locals.rubyProps ?? {};
---

<View {...props} />`;

            await mkdir(path.dirname(fileURLToPath(viewUrl)), {
              recursive: true,
            });
            await writeFile(viewUrl, pageContent);
          }

          // Handle TypeScript environment
          const envdtsUrl = new URL("env.d.ts", referenceDir);
          if (!existsSync(envdtsUrl)) {
            const generatedEnvdtsUrl = new URL("env.d.ts", generatedDir);
            const relativePath = path.relative(
              path.dirname(fileURLToPath(envdtsUrl)),
              fileURLToPath(generatedEnvdtsUrl)
            );
            await writeFile(
              envdtsUrl,
              `/// <reference path=${JSON.stringify(relativePath)} />`
            );
          }

          // Copy the [...app].ts route handler
          await writeFile(
            new URL("[...app].ts", pagesDir),
            await readFile(new URL("[...app].ts", import.meta.url), "utf-8")
          );
        },
      },
    },
  ],
});