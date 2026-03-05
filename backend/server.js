require('dotenv').config();
const express    = require('express');
const http       = require('http');
const cors       = require('cors');
const helmet     = require('helmet');
const morgan     = require('morgan');

const setupWebSocket = require('./websocket/wsHandler');

const vitalsRouter    = require('./routes/vitals');
const insightsRouter  = require('./routes/insights');
const alertsRouter    = require('./routes/alerts');
const reportsRouter   = require('./routes/reports');
const profileRouter   = require('./routes/profile');
const ingestionRouter = require('./routes/ingestion');
const eventsRouter    = require('./routes/events');
const passportRouter  = require('./routes/passport');
const medicosRouter   = require('./routes/medicos');

const app    = express();
const server = http.createServer(app);
const PORT   = process.env.PORT || 4000;

// ── WebSocket ─────────────────────────────────────────────────────────────────
const { broadcast } = setupWebSocket(server);
app.locals.broadcast = broadcast;

// ── Middleware ────────────────────────────────────────────────────────────────
app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Gemini-Key', 'Accept'],
  exposedHeaders: ['X-Total-Count'],
  credentials: false,
}));
app.options('*', cors()); // pre-flight for all routes
app.use(express.json({ limit: '2mb' }));
app.use(morgan('dev'));

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api/vitals',    vitalsRouter);
app.use('/api/insights',  insightsRouter);
app.use('/api/alerts',    alertsRouter);
app.use('/api/reports',   reportsRouter);
app.use('/api/profile',   profileRouter);
app.use('/api/ingestion', ingestionRouter);
app.use('/api/events',    eventsRouter);
app.use('/api/passport',  passportRouter);
app.use('/api/medicos',   medicosRouter);

// ── Health check ──────────────────────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({
    status: 'online',
    service: 'Health Twin Backend',
    version: '1.0.0',
    ts: new Date().toISOString(),
  });
});

// ── Root dashboard ────────────────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.setHeader('Content-Type', 'text/html');
  res.send(`<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>Health Twin Backend</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0}
  body{background:#020c18;color:#cbd5e1;font-family:'Segoe UI',system-ui,sans-serif;padding:2rem;line-height:1.6}
  h1{font-size:1.6rem;font-weight:700;background:linear-gradient(90deg,#22d3ee,#3b82f6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;margin-bottom:.25rem}
  .subtitle{color:#475569;font-size:.85rem;margin-bottom:2rem;font-family:monospace}
  .pill{display:inline-flex;align-items:center;gap:.4rem;padding:.2rem .75rem;border-radius:999px;font-size:.75rem;font-weight:600;font-family:monospace}
  .pill.online{background:#052e16;color:#4ade80;border:1px solid #166534}
  .pill.ws{background:#0c1a2e;color:#38bdf8;border:1px solid #0369a1}
  .card{background:#0f172a;border:1px solid #1e293b;border-radius:12px;padding:1.25rem 1.5rem;margin-bottom:1.25rem}
  .card h2{font-size:.7rem;font-weight:700;letter-spacing:.15em;color:#475569;text-transform:uppercase;margin-bottom:1rem}
  table{width:100%;border-collapse:collapse}
  td{padding:.45rem .5rem;font-size:.82rem;border-bottom:1px solid #1e293b;vertical-align:top}
  tr:last-child td{border-bottom:none}
  .method{font-family:monospace;font-weight:700;width:60px}
  .method.get{color:#22d3ee}.method.post{color:#a78bfa}.method.put{color:#fb923c}.method.del{color:#f87171}
  .path{font-family:monospace;color:#e2e8f0}
  .desc{color:#64748b;font-size:.78rem}
  a{color:#38bdf8;text-decoration:none}.a:hover{text-decoration:underline}
  .status-row{display:flex;align-items:center;gap:.75rem;margin-bottom:1.5rem;flex-wrap:wrap}
</style>
</head>
<body>
<h1>🩺 Health Twin Backend</h1>
<p class="subtitle">MedAILockr · v1.0.0 · running on port ${PORT}</p>

<div class="status-row">
  <span class="pill online">● API ONLINE</span>
  <span class="pill ws">⚡ WS ws://localhost:${PORT}/ws</span>
</div>

<div class="card">
  <h2>System</h2>
  <table>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/health">/api/health</a></td><td class="desc">Service health check</td></tr>
  </table>
</div>

<div class="card">
  <h2>Vitals</h2>
  <table>
    <tr><td class="method post">POST</td><td class="path">/api/vitals</td><td class="desc">Save vitals snapshot</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/vitals">/api/vitals</a></td><td class="desc">Vitals history</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/vitals/latest">/api/vitals/latest</a></td><td class="desc">Latest snapshot</td></tr>
    <tr><td class="method post">POST</td><td class="path">/api/vitals/batch</td><td class="desc">Bulk ingest</td></tr>
  </table>
</div>

<div class="card">
  <h2>Insights</h2>
  <table>
    <tr><td class="method post">POST</td><td class="path">/api/insights</td><td class="desc">Save AI insight</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/insights">/api/insights</a></td><td class="desc">Insight history</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/insights/latest">/api/insights/latest</a></td><td class="desc">Latest insight</td></tr>
  </table>
</div>

<div class="card">
  <h2>Alerts</h2>
  <table>
    <tr><td class="method post">POST</td><td class="path">/api/alerts</td><td class="desc">Create alert</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/alerts">/api/alerts</a></td><td class="desc">Active alerts</td></tr>
    <tr><td class="method del">DELETE</td><td class="path">/api/alerts/:id</td><td class="desc">Dismiss alert</td></tr>
    <tr><td class="method del">DELETE</td><td class="path">/api/alerts</td><td class="desc">Dismiss all</td></tr>
  </table>
</div>

<div class="card">
  <h2>Reports</h2>
  <table>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/reports/summary">/api/reports/summary</a></td><td class="desc">Aggregated stats</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/reports/export">/api/reports/export</a></td><td class="desc">Full JSON export</td></tr>
  </table>
</div>

<div class="card">
  <h2>Profile</h2>
  <table>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/profile">/api/profile</a></td><td class="desc">Patient profile</td></tr>
    <tr><td class="method put">PUT</td><td class="path">/api/profile</td><td class="desc">Update profile</td></tr>
  </table>
</div>

<div class="card">
  <h2>Ingestion &amp; Events</h2>
  <table>
    <tr><td class="method post">POST</td><td class="path">/api/ingestion</td><td class="desc">Log food / water</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/ingestion">/api/ingestion</a></td><td class="desc">Ingestion log</td></tr>
    <tr><td class="method post">POST</td><td class="path">/api/events</td><td class="desc">Log app event</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/events">/api/events</a></td><td class="desc">Event log</td></tr>
  </table>
</div>

<div class="card">
  <h2>AI Health Passport</h2>
  <table>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/passport/summary">/api/passport/summary</a></td><td class="desc">Aggregated passport summary</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/passport/profile">/api/passport/profile</a></td><td class="desc">Passport profile</td></tr>
    <tr><td class="method put">PUT</td><td class="path">/api/passport/profile</td><td class="desc">Update passport profile</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/passport/records">/api/passport/records</a></td><td class="desc">Medical vault records</td></tr>
    <tr><td class="method post">POST</td><td class="path">/api/passport/records</td><td class="desc">Add medical record</td></tr>
    <tr><td class="method del">DELETE</td><td class="path">/api/passport/records/:id</td><td class="desc">Delete record</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/passport/emergency">/api/passport/emergency</a></td><td class="desc">Emergency QR data</td></tr>
    <tr><td class="method post">POST</td><td class="path">/api/passport/emergency/log</td><td class="desc">Log QR scan event</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/passport/sharing">/api/passport/sharing</a></td><td class="desc">Data sharing settings</td></tr>
    <tr><td class="method put">PUT</td><td class="path">/api/passport/sharing</td><td class="desc">Update sharing consent</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/passport/compatibility">/api/passport/compatibility</a></td><td class="desc">Drug compatibility list</td></tr>
    <tr><td class="method post">POST</td><td class="path">/api/passport/compatibility/check</td><td class="desc">Check drug interaction</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/passport/credits">/api/passport/credits</a></td><td class="desc">Health credits balance</td></tr>
    <tr><td class="method post">POST</td><td class="path">/api/passport/credits/earn</td><td class="desc">Earn health credits</td></tr>
    <tr><td class="method post">POST</td><td class="path">/api/passport/credits/redeem</td><td class="desc">Redeem health credits</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/passport/blockchain">/api/passport/blockchain</a></td><td class="desc">Blockchain audit log</td></tr>
    <tr><td class="method post">POST</td><td class="path">/api/passport/blockchain/event</td><td class="desc">Log blockchain event</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/passport/wearable">/api/passport/wearable</a></td><td class="desc">Wearable devices status</td></tr>
    <tr><td class="method put">PUT</td><td class="path">/api/passport/wearable/devices/:id</td><td class="desc">Update wearable device</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/passport/genomic">/api/passport/genomic</a></td><td class="desc">Genomic data</td></tr>
    <tr><td class="method get">GET</td><td class="path"><a href="/api/passport/discharge">/api/passport/discharge</a></td><td class="desc">Discharge records</td></tr>
    <tr><td class="method post">POST</td><td class="path">/api/passport/discharge</td><td class="desc">Add discharge record</td></tr>
  </table>
</div>
</body>
</html>`);
});

// ── 404 ───────────────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ message: `Route ${req.method} ${req.path} not found` });
});

// ── Global error handler ──────────────────────────────────────────────────────
app.use((err, req, res, _next) => {
  console.error('[ERROR]', err);
  res.status(500).json({ message: err.message || 'Internal Server Error' });
});

// ── Start ─────────────────────────────────────────────────────────────────────
server.listen(PORT, () => {
  console.log(`\n🩺  Health Twin Backend running on http://localhost:${PORT}`);
  console.log(`🔌  WebSocket endpoint: ws://localhost:${PORT}/ws`);
  console.log(`\n  Endpoints:`);
  console.log(`    GET  /api/health`);
  console.log(`    POST /api/vitals          — save vitals snapshot`);
  console.log(`    GET  /api/vitals          — vitals history`);
  console.log(`    GET  /api/vitals/latest   — latest snapshot`);
  console.log(`    POST /api/vitals/batch    — bulk ingest`);
  console.log(`    POST /api/insights        — save AI insight`);
  console.log(`    GET  /api/insights        — insight history`);
  console.log(`    GET  /api/insights/latest — latest insight`);
  console.log(`    POST /api/alerts          — create alert`);
  console.log(`    GET  /api/alerts          — active alerts`);
  console.log(`    DELETE /api/alerts/:id    — dismiss alert`);
  console.log(`    DELETE /api/alerts        — dismiss all`);
  console.log(`    GET  /api/reports/summary — aggregated stats`);
  console.log(`    GET  /api/reports/export  — full JSON export`);
  console.log(`    GET  /api/profile         — patient profile`);
  console.log(`    PUT  /api/profile         — update profile`);
  console.log(`    POST /api/ingestion       — log food/water`);
  console.log(`    GET  /api/ingestion       — ingestion log`);
  console.log(`    GET  /api/passport/summary    — passport aggregate`);
  console.log(`    GET  /api/passport/records    — medical vault`);
  console.log(`    GET  /api/passport/blockchain — audit log`);
  console.log(`    GET  /api/passport/wearable   — device status`);
  console.log(`    GET  /api/passport/credits    — health credits\n`);
});
