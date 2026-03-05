const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { body, query, validationResult } = require('express-validator');
const ddb = require('../db/dynamo-db');

const router = express.Router();

// ── POST /api/vitals ── Save a vitals snapshot
router.post(
  '/',
  [
    body('heartRate').isInt({ min: 20, max: 300 }),
    body('systolicBP').isInt({ min: 50, max: 250 }),
    body('diastolicBP').isInt({ min: 30, max: 180 }),
    body('respRate').isInt({ min: 4, max: 60 }),
    body('temperature').isFloat({ min: 30, max: 45 }),
    body('oxygenSat').isInt({ min: 50, max: 100 }),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { heartRate, systolicBP, diastolicBP, respRate, temperature, oxygenSat, source = 'frontend' } = req.body;
    const id = uuidv4();
    const now = new Date().toISOString();

    await ddb.putVital({ id, heartRate, systolicBP, diastolicBP, respRate, temperature, oxygenSat, source, recordedAt: now });

    if (req.app.locals.broadcast) {
      req.app.locals.broadcast({ event: 'vitals', data: { id, heartRate, systolicBP, diastolicBP, respRate, temperature, oxygenSat, source, recordedAt: now } });
    }

    return res.status(201).json({ id, recordedAt: now });
  }
);

// ── GET /api/vitals ── Paginated vitals history
router.get(
  '/',
  [
    query('limit').optional().isInt({ min: 1, max: 1000 }).toInt(),
    query('offset').optional().isInt({ min: 0 }).toInt(),
    query('from').optional().isISO8601(),
    query('to').optional().isISO8601(),
  ],
  async (req, res) => {
    const { limit = 100 } = req.query;
    const rows = await ddb.queryVitals({ limit: Number(limit) });
    return res.json({ total: rows.length, limit: Number(limit), offset: 0, data: rows });
  }
);

// ── GET /api/vitals/latest ── Latest single snapshot
router.get('/latest', async (req, res) => {
  const rows = await ddb.queryVitals({ limit: 1 });
  if (!rows.length) return res.status(404).json({ message: 'No vitals recorded yet' });
  return res.json(rows[0]);
});

// ── POST /api/vitals/batch ── Save multiple snapshots at once
router.post('/batch', async (req, res) => {
  const { snapshots } = req.body;
  if (!Array.isArray(snapshots) || snapshots.length === 0)
    return res.status(400).json({ message: 'snapshots must be a non-empty array' });
  if (snapshots.length > 500)
    return res.status(400).json({ message: 'Max 500 snapshots per batch' });

  const now = new Date().toISOString();
  const ids = [];
  for (const v of snapshots) {
    const id = uuidv4();
    await ddb.putVital({ id, heartRate: v.heartRate, systolicBP: v.systolicBP, diastolicBP: v.diastolicBP, respRate: v.respRate, temperature: v.temperature, oxygenSat: v.oxygenSat, source: v.source || 'batch', recordedAt: v.recordedAt || now });
    ids.push(id);
  }
  return res.status(201).json({ saved: ids.length, ids });
});

module.exports = router;
