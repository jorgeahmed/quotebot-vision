import backend from './src/api/index.js';
import http from 'http';

const PORT = 8080;

// Mock Environment
const env = {
    VULTR_INFERENCE_URL: "http://216.238.87.125/predict",
    main: {
        query: async (sql, params) => {
            console.log('📝 [MOCK DB] Query:', sql, params);
            return { success: true }; // Mock response
        }
    }
};

const server = http.createServer(async (req, res) => {
    console.log(`📥 ${req.method} ${req.url}`);

    const url = new URL(req.url, `http://${req.headers.host}`);

    // Adapt Node request to Web Standard Request
    const webReq = new Request(url, {
        method: req.method,
        headers: req.headers,
        body: (req.method !== 'GET' && req.method !== 'HEAD') ?
            await new Promise((resolve) => {
                let parts = [];
                req.on('data', chunk => parts.push(chunk));
                req.on('end', () => resolve(Buffer.concat(parts)));
            }) : null
    });

    try {
        const webRes = await backend.fetch(webReq, env, {});

        // Adapt Web Response to Node response
        res.statusCode = webRes.status;
        webRes.headers.forEach((value, key) => {
            res.setHeader(key, value);
        });

        const text = await webRes.text();
        res.end(text);
    } catch (err) {
        console.error('❌ Server Error:', err);
        res.statusCode = 500;
        res.end(JSON.stringify({ error: err.toString() }));
    }
});

server.listen(PORT, () => {
    console.log(`
🚀 Backend running locally on port ${PORT}
👉 http://localhost:${PORT}
  `);
});
