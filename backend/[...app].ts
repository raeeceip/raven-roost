import type { APIRoute } from "astro";

export const ALL: APIRoute = async (ctx) => {
  try {
    // Get the original path
    const pathname = ctx.url.pathname;
    
    // Forward the request to Rails
    const rubyResponse = await fetch(
      new URL(pathname, "http://localhost:3000"),
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

    console.log('Rails Response Status:', rubyResponse.status);
    console.log('Rails Response Headers:', Object.fromEntries(rubyResponse.headers));

    // Handle non-200 responses
    if (!rubyResponse.ok) {
      return new Response(rubyResponse.body, {
        status: rubyResponse.status,
        headers: rubyResponse.headers
      });
    }

    const view = rubyResponse.headers.get("X-Astro-View");
    if (!view) {
      console.log('No X-Astro-View header found');
      return new Response(rubyResponse.body, {
        status: rubyResponse.status,
        headers: rubyResponse.headers
      });
    }

    // Parse the response body
    let props = {};
    try {
      const text = await rubyResponse.text();
      if (text) {
        props = JSON.parse(text);
      }
    } catch (e) {
      console.error('Failed to parse JSON from Rails:', e);
    }

    // Store props in locals
    ctx.locals.rubyProps = props;

    // Construct the view path and rewrite URL
    const viewPath = view
      .split('/')
      .filter(Boolean)
      .join('/');

    const rewriteUrl = new URL(
      `/views/${viewPath}`,
      ctx.url.origin
    );

    // Log for debugging
    console.log('View Path:', viewPath);
    console.log('Props:', props);
    console.log('Rewrite URL:', rewriteUrl.toString());

    // Rewrite to the Astro view
    return ctx.rewrite(rewriteUrl);
  } catch (error) {
    console.error('Error in [...app].ts:', error);
    return new Response('Internal Server Error', { status: 500 });
  }
};