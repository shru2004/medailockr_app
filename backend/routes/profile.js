const express = require('express');
const { body, validationResult } = require('express-validator');
const ddb = require('../db/dynamo-db');

const router = express.Router();

// ── GET /api/profile ── Get patient profile
router.get('/', async (req, res) => {
  const profile = await ddb.getProfile();
  if (!profile) return res.status(404).json({ message: 'Profile not found' });
  return res.json(profile);
});

// ── PUT /api/profile ── Update patient profile
router.put(
  '/',
  [
    body('name').optional().isString().trim().notEmpty(),
    body('age').optional().isInt({ min: 0, max: 150 }),
    body('gender').optional().isIn(['male', 'female', 'other', 'prefer not to say']),
    body('weightKg').optional().isFloat({ min: 1, max: 500 }),
    body('heightCm').optional().isFloat({ min: 30, max: 300 }),
    body('bloodType').optional().isIn(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
    body('conditions').optional().isArray(),
    body('medications').optional().isArray(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const current = await ddb.getProfile() || {};
    const patch = {
      ...current,
      ...req.body,
    };
    await ddb.saveProfile(patch);
    return res.json({ updated: true });
  }
);

module.exports = router;
