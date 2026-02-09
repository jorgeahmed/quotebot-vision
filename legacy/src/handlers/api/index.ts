import { Hono } from 'hono'
import { cors } from 'hono/cors'

const app = new Hono()

// Log startup to verification
console.log("Starting QuoteBot API v1.0.1 - Worker Init");

// Demo projects (hardcoded for testing)
const DEMO_PROJECTS = [
  {
    id: "proj_001",
    name: {
      es: "Torre Residencial Sunset",
      en: "Sunset Residential Tower"
    },
    description: {
      es: "Complejo residencial de 20 pisos en zona premium",
      en: "20-story residential complex in premium area"
    },
    location: "Av. Reforma 123, CDMX",
    created_at: "2025-01-01T00:00:00Z"
  },
  {
    id: "proj_002",
    name: {
      es: "Centro Comercial Plaza Norte",
      en: "North Plaza Shopping Center"
    },
    description: {
      es: "Centro comercial con 150 locales y estacionamiento",
      en: "Shopping mall with 150 stores and parking"
    },
    location: "Blvd. Norte 456, Monterrey",
    created_at: "2025-01-15T00:00:00Z"
  }
];

// In-memory storage for new projects and jobs
let projects = [...DEMO_PROJECTS];
let jobs: any[] = [];

// Helper function to get language
function getLang(c: any): string {
  const queryLang = c.req.query('lang');
  if (queryLang === 'en' || queryLang === 'es') return queryLang;

  const acceptLang = c.req.header('Accept-Language');
  if (acceptLang && acceptLang.toLowerCase().includes('en')) return 'en';

  return 'es'; // default
}

// Allow CORS for dashboard access
app.use('*', cors({
  origin: '*',
  allowMethods: ['GET', 'POST', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization', 'Accept-Language'],
}))

// Health Check for forced update
app.get('/health-check', (c) => c.text('ok'))

// Root route
app.get('/', (c) => {
  const lang = getLang(c);

  return c.json({
    status: lang === 'en' ? "online" : "en línea",
    service: lang === 'en' ? "QuoteBot API" : "API QuoteBot",
    version: "1.0.1",
    language: lang,
    endpoints: {
      dashboard: "/dashboard",
      projects: "/projects",
      createJob: "/createJob"
    }
  })
})

// Dashboard route
app.get('/dashboard', (c) => {
  const lang = getLang(c);

  const stats: any = {};
  if (lang === 'en') {
    stats["Active Jobs"] = jobs.length;
    stats["Total Projects"] = projects.length;
    stats["Version"] = "1.0.1";
  } else {
    stats["Trabajos Activos"] = jobs.length;
    stats["Proyectos Totales"] = projects.length;
    stats["Versión"] = "1.0.1";
  }

  return c.json({
    message: lang === 'en' ? "QuoteBot Dashboard" : "Panel de QuoteBot",
    language: lang,
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    stats: stats,
    recent_projects: projects.slice(0, 3)
  })
})

// GET /projects - List all projects
app.get('/projects', (c) => {
  const lang = getLang(c);

  // Localize projects
  const localizedProjects = projects.map(p => ({
    ...p,
    name: (p.name as any)[lang] || (p.name as any)['es'] || p.name, // Fallback chain
    description: (p.description as any)[lang] || (p.description as any)['es'] || p.description
  }));

  const response: any = {
    success: true,
    language: lang,
    projects: localizedProjects
  };

  if (lang === 'en') {
    response["Total Projects"] = projects.length;
  } else {
    response["Total de Proyectos"] = projects.length;
  }

  return c.json(response)
})

// GET /projects/:id - Get specific project
app.get('/projects/:id', (c) => {
  const lang = getLang(c);
  const id = c.req.param('id')
  const project = projects.find(p => p.id === id)

  if (!project) {
    return c.json({
      success: false,
      language: lang,
      error: lang === 'en' ? "Project not found" : "Proyecto no encontrado"
    }, 404)
  }

  const projectJobs = jobs.filter(j => j.project_id === id)

  // Localize single project
  const localizedProject = {
    ...project,
    name: (project.name as any)[lang] || (project.name as any)['es'] || project.name,
    description: (project.description as any)[lang] || (project.description as any)['es'] || project.description,
    jobs: projectJobs
  };

  return c.json({
    success: true,
    language: lang,
    project: localizedProject
  })
})

// POST /projects - Create new project
app.post('/projects', async (c) => {
  const lang = getLang(c);

  try {
    const body = await c.req.json() as any

    if (!body.name || !body.description || !body.location) {
      return c.json({
        success: false,
        language: lang,
        error: lang === 'en'
          ? "Missing required fields: name, description, location"
          : "Faltan campos requeridos: name, description, location"
      }, 400)
    }

    const newProject = {
      id: `proj_${String(projects.length + 1).padStart(3, '0')}`,
      name: { es: body.name, en: body.name }, // Store input for both languages
      description: { es: body.description, en: body.description },
      location: body.location,
      created_at: new Date().toISOString()
    }

    projects.push(newProject)

    // Return the created project localized for immediate display
    const localizedNewProject = {
      ...newProject,
      name: body.name,
      description: body.description
    };

    return c.json({
      success: true,
      language: lang,
      message: lang === 'en' ? "Project created successfully" : "Proyecto creado exitosamente",
      project: localizedNewProject
    }, 201)

  } catch (e: any) {
    console.error("Create project error:", e)
    return c.json({
      success: false,
      language: lang,
      error: lang === 'en' ? "Internal server error" : "Error interno del servidor"
    }, 500)
  }
})

// POST /createJob - Create job (with optional project association)
app.post('/createJob', async (c) => {
  const lang = getLang(c);

  try {
    const body = await c.req.json() as any
    const aiUrl = "http://216.238.87.125/predict"

    console.log("Procesando Job:", body)

    if (body.project_id) {
      const projectExists = projects.find(p => p.id === body.project_id)
      if (!projectExists) {
        return c.json({
          success: false,
          language: lang,
          error: lang === 'en'
            ? `Project not found: ${body.project_id}`
            : `Proyecto no encontrado: ${body.project_id}`
        }, 404)
      }
    }

    const payload = {
      description: body.description || "Sin descripción",
      category: body.category || "General",
      building_id: body.building_id || "000"
    }

    const aiRes = await fetch(aiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    })

    if (!aiRes.ok) {
      const errorMsg = lang === 'en' ? "AI Service Error" : "Error del Servicio de IA";
      throw new Error(`${errorMsg}: ${aiRes.statusText}`)
    }

    const aiData = await aiRes.json() as any

    const newJob = {
      id: `job_${Date.now()}`,
      description: payload.description,
      category: payload.category,
      building_id: payload.building_id,
      project_id: body.project_id || null,
      estimate: aiData.aiEstimate || aiData.estimate,
      created_at: new Date().toISOString()
    }

    jobs.push(newJob)

    try {
      if ((c.env as any).main) {
        await (c.env as any).main.query(
          `INSERT INTO jobs (id, description, estimate, project_id) VALUES (?, ?, ?, ?)`,
          [newJob.id, payload.description, newJob.estimate, newJob.project_id]
        );
      }
    } catch (e) { console.warn("DB Save failed, proceeding anyway", e) }

    return c.json({
      success: true,
      language: lang,
      message: lang === 'en' ? "Job created successfully" : "Trabajo creado exitosamente",
      job: newJob,
      data: {
        input: payload,
        estimate: newJob.estimate
      }
    })

  } catch (e: any) {
    console.error("API Error:", e)
    return c.json({
      success: false,
      language: lang,
      error: e.message
    }, 500)
  }
})

export default app
