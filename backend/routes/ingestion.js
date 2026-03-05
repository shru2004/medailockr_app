const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { body, query, validationResult } = require('express-validator');
const ddb = require('../db/dynamo-db');

const router = express.Router();

// ── POST /api/ingestion ── Log food/water event
router.post(
  '/',
  [
    body('type').isIn(['food', 'water']),
    body('notes').optional().isString().trim(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { type, notes = '' } = req.body;
    const id = uuidv4();
    const now = new Date().toISOString();

    await ddb.putIngestionRecord({ id, type, notes, recordedAt: now });

    if (req.app.locals.broadcast) {
      req.app.locals.broadcast({ event: 'ingestion', data: { id, type, recordedAt: now } });
    }

    return res.status(201).json({ id, type, recordedAt: now });
  }
);

// ── GET /api/ingestion ── Get ingestion log
router.get(
  '/',
  [
    query('limit').optional().isInt({ min: 1, max: 200 }).toInt(),
    query('offset').optional().isInt({ min: 0 }).toInt(),
  ],
  async (req, res) => {
    const { limit = 50 } = req.query;
    const rows = await ddb.queryIngestion({ limit: Number(limit) });
    return res.json({ data: rows });
  }
);

module.exports = router;
