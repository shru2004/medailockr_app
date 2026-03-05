const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { body, query, validationResult } = require('express-validator');
const ddb = require('../db/dynamo-db');

const router = express.Router();

// ── POST /api/insights ── Save an AI insight
router.post(
  '/',
  [
    body('status').isIn(['optimal', 'warning', 'critical']),
    body('message').isString().notEmpty(),
    body('confidence').isInt({ min: 0, max: 100 }),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const {
      status, message, confidence, analysis = '',
      correlations = [], immediateActions = [], recommendations = [],
      vitalsSnapshot = null,
    } = req.body;

    const id = uuidv4();
    const now = new Date().toISOString();

    await ddb.putInsight({ id, status, message, confidence, analysis, correlations, immediateActions, recommendations, vitalsSnapshot, createdAt: now });

    if (req.app.locals.broadcast) {
      req.app.locals.broadcast({ event: 'insight', data: { id, status, message, confidence, createdAt: now } });
    }

    return res.status(201).json({ id, createdAt: now });
  }
);

// ── GET /api/insights ── Paginated insight history
router.get(
  '/',
  [
    query('limit').optional().isInt({ min: 1, max: 200 }).toInt(),
    query('offset').optional().isInt({ min: 0 }).toInt(),
  ],
  async (req, res) => {
    const { limit = 20 } = req.query;
    const rows = await ddb.queryInsights({ limit: Number(limit) });
    return res.json({ total: rows.length, limit: Number(limit), offset: 0, data: rows });
  }
);

// ── GET /api/insights/latest ── Most recent insight
router.get('/latest', async (req, res) => {
  const rows = await ddb.queryInsights({ limit: 1 });
  if (!rows.length) return res.status(404).json({ message: 'No insights recorded yet' });
  return res.json(rows[0]);
});

module.exports = router;
