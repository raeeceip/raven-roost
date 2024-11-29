import type { APIRoute } from "astro";
import { RoostDB } from "@/lib/db";

export const POST: APIRoute = async ({ request, locals }) => {
  try {
    const db = new RoostDB(locals.runtime.env);
    const { spaceId, userId } = await request.json();

    // Implement check-in logic here
    // For example:
    // await db.checkIn(spaceId, userId);

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (error) {
    return new Response(JSON.stringify({ success: false, error: 'Check-in failed' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
};