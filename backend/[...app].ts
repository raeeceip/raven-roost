// generated/pages/[...app].ts
import type { APIRoute } from "astro";

export const ALL: APIRoute = async (ctx) => {
  try {
    // Forward the request to Rails
    const rubyResponse = await fetch(
      new URL(ctx.url.pathname, "http://localhost:3000"),
      {
        method: ctx.request.method,
        headers: {
          ...ctx.request.headers,
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: ctx.request.method !== 'GET' && ctx.request.method !== 'HEAD' 
          ? await ctx.request.text() 
          : undefined
      }
    );

    // If Rails doesn't return a view header, just proxy the response
    const view = rubyResponse.headers.get("X-Astro-View");
    if (!view) {
      return new Response(rubyResponse.body, {
        status: rubyResponse.status,
        headers: rubyResponse.headers
      });
    }

    // Get the props from the Rails response
    let props = {};
    try {
      props = await rubyResponse.json();
    } catch (e) {
      console.error('Failed to parse JSON from Rails:', e);
    }

    // Construct the view path
    const viewPath = view
      .split('/')
      .filter(Boolean)
      .join('/');

    // Rewrite to the appropriate view
    const rewriteUrl = new URL(
      `/views/${viewPath}`,
      ctx.url.origin
    );

    // Set the props in locals for the view
    ctx.locals.rubyProps = props;

    // Log for debugging
    console.log('View Path:', viewPath);
    console.log('Rewrite URL:', rewriteUrl.toString());
    console.log('Props:', props);

    return ctx.rewrite(rewriteUrl);
  } catch (error) {
    console.error('Error in [...app].ts:', error);
    return new Response('Internal Server Error', { status: 500 });
  }
};