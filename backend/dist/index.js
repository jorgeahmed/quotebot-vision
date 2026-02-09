"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const hono_1 = require("hono");
const cors_1 = require("hono/cors");
const logger_1 = require("hono/logger");
const vertexai_1 = require("@google-cloud/vertexai");
const storage_1 = require("@google-cloud/storage");
const firestore_1 = require("@google-cloud/firestore");
const node_server_1 = require("@hono/node-server");
const pricing_engine_1 = require("./services/pricing-engine");
// Initialize GCP Clients
const firestore = new firestore_1.Firestore();
const storage = new storage_1.Storage();
const vertex = new vertexai_1.VertexAI({ project: process.env.GOOGLE_CLOUD_PROJECT, location: 'us-central1' });
const pricingEngine = new pricing_engine_1.PricingEngine();
const app = new hono_1.Hono();
app.use('*', (0, logger_1.logger)());
app.use('*', (0, cors_1.cors)({
    origin: '*',
    allowMethods: ['POST', 'GET', 'OPTIONS'],
}));
// Health Check
app.get('/', (c) => c.text('QuoteBot Vision Backend Online'));
/**
 * Endpoint: Get Upload URL
 * Generates a V4 Signed URL for calculating direct upload to GCS.
 */
app.get('/upload-url', async (c) => {
    try {
        const filename = c.req.query('filename');
        const contentType = c.req.query('contentType') || 'video/mp4';
        if (!filename)
            return c.json({ error: 'Missing filename query param' }, 400);
        const bucketName = `${process.env.GOOGLE_CLOUD_PROJECT}_videos`; // e.g. quotebot-vision-hackathon_videos
        const bucket = storage.bucket(bucketName);
        const file = bucket.file(filename);
        // Check if bucket exists, create if not (for Hackathon simplicity)
        const [exists] = await bucket.exists();
        if (!exists) {
            await bucket.create({ location: 'US-CENTRAL1' });
        }
        const [url] = await file.getSignedUrl({
            version: 'v4',
            action: 'write',
            expires: Date.now() + 15 * 60 * 1000, // 15 minutes
            contentType,
        });
        return c.json({
            uploadUrl: url,
            gcsUri: `gs://${bucketName}/${filename}`
        });
    }
    catch (error) {
        console.error("Signed URL Error:", error);
        return c.json({ error: error.message }, 500);
    }
});
/**
 * Endpoint: Analyze Video
 * Triggered by Flutter App after uploading video to GCS.
 *
 * Body: { "projectId": "...", "videoGcsUri": "gs://..." }
 */
app.post('/analyze', async (c) => {
    try {
        const { projectId, videoGcsUri } = await c.req.json();
        if (!projectId || !videoGcsUri) {
            return c.json({ error: 'Missing projectId or videoGcsUri' }, 400);
        }
        // 1. Create a "Job" entry in Firestore with status 'processing'
        const jobId = `job_${Date.now()}`;
        const jobRef = firestore.collection('jobs').doc(jobId);
        await jobRef.set({
            id: jobId,
            projectId,
            videoUri: videoGcsUri,
            status: 'processing',
            createdAt: new Date().toISOString(),
            analysis: null
        });
        // 2. Trigger Gemini Analysis (Async or Await depending on timeout needs)
        // For MVP/Hackathon, we await. For prod, use Cloud Tasks.
        console.log(`Starting analysis for ${videoGcsUri}...`);
        const model = vertex.getGenerativeModel({ model: 'gemini-1.5-pro-vision' }); // Or gemini-1.5-flash for speed
        // Construct the prompt
        const prompt = `
      You are an expert construction estimator. 
      Analyze this video. It shows a construction site or a room needing renovation.
      1. Identify the room/area dimensions if possible.
      2. List materials needed for renovation (e.g., paint, drywall, flooring).
      3. Estimate quantities.
      4. Provide a rough difficulty score (1-10).
      
      Return ONLY valid JSON.
      Structure:
      {
        "dimensions": "string description",
        "materials": [ {"name": "string", "quantity": "string", "unit": "string"} ],
        "difficulty": number,
        "summary": "string"
      }
    `;
        const videoPart = {
            fileData: {
                fileUri: videoGcsUri,
                mimeType: 'video/mp4', // Validate mime-type in real app
            }
        };
        const result = await model.generateContent({
            contents: [{ role: 'user', parts: [{ text: prompt }, videoPart] }]
        });
        const responseText = result.response.candidates?.[0].content.parts[0].text;
        // Clean markdown code blocks if present
        const cleanJson = responseText?.replace(/```json/g, '').replace(/```/g, '').trim();
        let analysisData;
        try {
            analysisData = JSON.parse(cleanJson || '{}');
        }
        catch (e) {
            console.error("Failed to parse AI response", responseText);
            analysisData = { error: "Failed to parse AI response", raw: responseText };
        }
        // 3. Update Job in Firestore
        await jobRef.update({
            status: 'completed',
            analysis: analysisData,
            completedAt: new Date().toISOString()
        });
        return c.json({ success: true, jobId, message: 'Analysis completed' });
    }
    catch (error) {
        console.error("Analysis Error:", error);
        return c.json({ error: error.message }, 500);
    }
});
/**
 * Endpoint: Get Job Status (Polling)
 * Allows the app to check status without full Firebase Client SDK setup.
 */
app.get('/jobs/:id', async (c) => {
    const jobId = c.req.param('id');
    try {
        const doc = await firestore.collection('jobs').doc(jobId).get();
        if (!doc.exists) {
            return c.json({ error: 'Job not found' }, 404);
        }
        return c.json(doc.data());
    }
    catch (error) {
        return c.json({ error: error.message }, 500);
    }
});
/**
 * Projects CRUD - Proxying to Firestore
 * For a real app, Flutter should access Firestore directly using Firebase SDK.
 * This is just for admin/management if needed.
 */
app.post('/projects', async (c) => {
    try {
        const data = await c.req.json();
        const docRef = firestore.collection('projects').doc(); // Auto ID
        await docRef.set({
            ...data,
            id: docRef.id,
            createdAt: new Date().toISOString()
        });
        return c.json({ id: docRef.id, success: true });
    }
    catch (error) {
        return c.json({ error: error.message }, 500);
    }
});
/**
 * QUOTATIONS - ML-Powered Pricing System
 */
/**
 * Generate quotation from completed job analysis
 */
app.post('/quotations/generate', async (c) => {
    try {
        const { jobId } = await c.req.json();
        if (!jobId) {
            return c.json({ error: 'Missing jobId' }, 400);
        }
        const quotation = await pricingEngine.generateQuotation(jobId);
        return c.json({
            success: true,
            quotation,
            message: 'Quotation generated successfully'
        });
    }
    catch (error) {
        console.error('Quotation Generation Error:', error);
        return c.json({ error: error.message }, 500);
    }
});
/**
 * Get quotation by ID
 */
app.get('/quotations/:id', async (c) => {
    const quotationId = c.req.param('id');
    try {
        const doc = await firestore.collection('quotations').doc(quotationId).get();
        if (!doc.exists) {
            return c.json({ error: 'Quotation not found' }, 404);
        }
        return c.json(doc.data());
    }
    catch (error) {
        return c.json({ error: error.message }, 500);
    }
});
/**
 * Get all quotations for a project
 */
app.get('/quotations/project/:projectId', async (c) => {
    const projectId = c.req.param('projectId');
    try {
        const snapshot = await firestore
            .collection('quotations')
            .where('projectId', '==', projectId)
            .orderBy('createdAt', 'desc')
            .get();
        const quotations = snapshot.docs.map(doc => doc.data());
        return c.json({ quotations, count: quotations.length });
    }
    catch (error) {
        return c.json({ error: error.message }, 500);
    }
});
/**
 * Seed material prices from catalog
 */
app.post('/material-prices/seed', async (c) => {
    try {
        const count = await pricingEngine.seedMaterialPrices();
        return c.json({
            success: true,
            materialsCreated: count,
            message: `Seeded ${count} materials into database`
        });
    }
    catch (error) {
        console.error('Seed Error:', error);
        return c.json({ error: error.message }, 500);
    }
});
/**
 * Get material price data
 */
app.get('/material-prices/:materialName', async (c) => {
    const materialName = c.req.param('materialName');
    try {
        const snapshot = await firestore
            .collection('material_prices')
            .where('normalizedName', '==', materialName.toLowerCase())
            .limit(1)
            .get();
        if (snapshot.empty) {
            return c.json({ error: 'Material not found' }, 404);
        }
        return c.json(snapshot.docs[0].data());
    }
    catch (error) {
        return c.json({ error: error.message }, 500);
    }
});
/**
 * Get all material prices (catalog)
 */
app.get('/material-prices', async (c) => {
    try {
        const snapshot = await firestore.collection('material_prices').get();
        const materials = snapshot.docs.map(doc => doc.data());
        return c.json({ materials, count: materials.length });
    }
    catch (error) {
        return c.json({ error: error.message }, 500);
    }
});
// Server initialization
const port = Number(process.env.PORT) || 8080;
console.log(`Server is running on port ${port}`);
(0, node_server_1.serve)({
    fetch: app.fetch,
    port
});
exports.default = app;
