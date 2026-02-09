export default {
  async fetch(request, env, ctx) {
    // CORS Headers
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
      "Content-Type": "application/json"
    };

    // Preflight
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    const url = new URL(request.url);

    // Endpoint Principal
    if (request.method === "POST" && url.pathname === "/createJob") {
      try {
        const body = await request.json();
        console.log("Worker Recibió:", body);

        // Usar variable de entorno
        const aiUrl = env.VULTR_INFERENCE_URL || "http://216.238.87.125/predict";
        
        const aiRes = await fetch(aiUrl, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            description: body.description || "Test",
            category: "General",
            building_id: "000"
          })
        });

        const aiData = await aiRes.json();
        const jobId = "job_" + Date.now();

        // Guardar en DB (Si existe conexión)
        try {
          if (env.main) {
             await env.main.query(
               `INSERT INTO jobs (id, description, estimate) VALUES (?, ?, ?)`,
               [jobId, body.description, aiData.aiEstimate]
             );
          }
        } catch (dbErr) { console.log("DB Warn:", dbErr); }

        return new Response(JSON.stringify({
          success: true,
          job_id: jobId,
          ai_estimate: aiData.aiEstimate,
          source: "Raindrop Native Worker"
        }), { headers: corsHeaders });

      } catch (e) {
        return new Response(JSON.stringify({ error: e.toString() }), { 
          status: 500, 
          headers: corsHeaders 
        });
      }
    }

    // Health Check
    return new Response(JSON.stringify({ status: "Online" }), { headers: corsHeaders });
  }
};
