/**
 * /api/events — System event log
 * Tracks bluetooth connections, voice sessions, sound toggles, and other
 * lifecycle events for audit and analytics.
 */
const router  = require('express').Router();
const { v4: uuidv4 } = require('uuid');
const ddb     = require('../db/dynamo-db');

// POST /api/events — log a single event
router.post('/', async (req, res) => {
  const { type, metadata = {} } = req.body;
  if (!type || typeof type !== 'string')
    return res.status(400).json({ message: '`type` is required (string)' });

  const doc = {
    id:         uuidv4(),
    type:       type.slice(0, 100),
    data:       typeof metadata === 'object' && metadata !== null ? metadata : {},
    recordedAt: new Date().toISOString(),
  };

  await ddb.putEvent(doc);
  req.app.locals.broadcast?.({ event: 'system_event', data: doc });

  res.status(201).json({ id: doc.id, type: doc.type, recordedAt: doc.recordedAt });
});

// GET /api/events — paginated history
router.get('/', async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit) || 50, 500);
  const rows  = await ddb.queryEvents({ limit });
  res.json({ total: rows.length, data: rows });
});

module.exports = router;
