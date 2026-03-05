const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { body, param, validationResult } = require('express-validator');
const ddb = require('../db/dynamo-db');

const router = express.Router();

// ── POST /api/alerts ── Create an alert
router.post(
  '/',
  [
    body('type').isIn(['warning', 'info']),
    body('title').isString().notEmpty().trim(),
    body('description').isString().notEmpty().trim(),
    body('source').optional().isString(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { type, title, description, source = 'ai' } = req.body;
    const id = uuidv4();
    const now = new Date().toISOString();

    await ddb.putAlert({ id, type, title, description, source, createdAt: now });

    if (req.app.locals.broadcast) {
      req.app.locals.broadcast({ event: 'alert', data: { id, type, title, description, source, createdAt: now } });
    }

    return res.status(201).json({ id, createdAt: now });
  }
);

// ── GET /api/alerts ── Alerts
router.get('/', async (req, res) => {
  const { limit = 50 } = req.query;
  const rows = await ddb.queryAlerts({ limit: Number(limit) });
  const active = rows.filter(r => r.dismissed !== 'true');
  return res.json({ total: active.length, data: rows });
});

// ── DELETE /api/alerts/:id ── Dismiss a single alert
router.delete('/:id', async (req, res) => {
  await ddb.dismissAlert(req.params.id);
  return res.json({ dismissed: true });
});

// ── DELETE /api/alerts ── Dismiss all (marks each dismissed=true)
router.delete('/', async (req, res) => {
  const rows = await ddb.queryAlerts({ limit: 500 });
  for (const r of rows.filter(x => x.dismissed !== 'true')) {
    await ddb.dismissAlert(r.alertId);
  }
  return res.json({ dismissed: true });
});

module.exports = router;
