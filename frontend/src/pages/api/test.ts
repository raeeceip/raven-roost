// src/pages/api/test.ts
export async function GET({ env }: { env: { DB: any } }) {
    try {
      // Query the database
      const { results } = await env.DB.prepare(
        "SELECT * FROM study_spaces"
      ).all();
  
      // Get a count of spaces
      const { results: count } = await env.DB.prepare(
        "SELECT COUNT(*) as count FROM study_spaces"
      ).all();
  
      return new Response(JSON.stringify({
        success: true,
        message: "Database connection successful",
        spaceCount: count[0].count,
        spaces: results
      }), {
        headers: { 
          'Content-Type': 'application/json'
        }
      });
    } catch (error) {
      return new Response(JSON.stringify({
        success: false,
        message: "Database error",
        error: (error instanceof Error ? error.message : 'Unknown error')
      }), {
        status: 500,
        headers: { 
          'Content-Type': 'application/json'
        }
      });
    }
  }