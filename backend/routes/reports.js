const express = require('express');
const { query, validationResult } = require('express-validator');
const ddb = require('../db/dynamo-db');

const router = express.Router();

// ── GET /api/reports/summary ── Aggregated health summary
router.get(
  '/summary',
  [
    query('period').optional().isIn(['1h', '6h', '24h', '7d', '30d']),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const period = req.query.period || '24h';
    const periodMs = {
      '1h':  1 * 60 * 60 * 1000,
      '6h':  6 * 60 * 60 * 1000,
      '24h': 24 * 60 * 60 * 1000,
      '7d':  7 * 24 * 60 * 60 * 1000,
      '30d': 30 * 24 * 60 * 60 * 1000,
    };

    const from = new Date(Date.now() - periodMs[period]).toISOString();

    const allVitals  = await ddb.queryVitals({ limit: 1000 });
    const vitalsIn   = allVitals.filter(v => v.recordedAt >= from);
    const allAlerts  = await ddb.queryAlerts({ limit: 500 });
    const criticals  = allAlerts.filter(a => a.createdAt >= from && a.severity === 'warning').length;
    const latest     = vitalsIn[0] || null;
    const insightRows = await ddb.queryInsights({ limit: 1 });
    const latInsight = insightRows[0] || null;
    const profile    = await ddb.getProfile();

    // compute averages
    const avg = (arr, key) => arr.length ? +(arr.reduce((s, r) => s + (r[key] || 0), 0) / arr.length).toFixed(1) : null;
    const stats = vitalsIn.length ? {
      avg_heart_rate:  avg(vitalsIn, 'heartRate'),
      max_heart_rate:  Math.max(...vitalsIn.map(v => v.heartRate || 0)),
      min_heart_rate:  Math.min(...vitalsIn.map(v => v.heartRate || 0)),
      avg_systolic_bp: avg(vitalsIn, 'systolicBP'),
      avg_diastolic_bp: avg(vitalsIn, 'diastolicBP'),
      avg_resp_rate:   avg(vitalsIn, 'respRate'),
      avg_temperature: avg(vitalsIn, 'temperature'),
      avg_oxygen_sat:  avg(vitalsIn, 'oxygenSat'),
      min_oxygen_sat:  Math.min(...vitalsIn.map(v => v.oxygenSat || 100)),
      total_readings:  vitalsIn.length,
    } : null;

    // Derive risk score (0–100)
    let riskScore = 0;
    if (stats) {
      if (stats.avg_heart_rate > 100 || stats.avg_heart_rate < 55) riskScore += 20;
      if (stats.avg_systolic_bp > 140) riskScore += 25;
      if (stats.min_oxygen_sat < 92) riskScore += 30;
      if (stats.avg_resp_rate > 25) riskScore += 15;
      if (criticals > 3) riskScore += 10;
    }
    riskScore = Math.min(100, riskScore);

    return res.json({
      period,
      generatedAt: new Date().toISOString(),
      profile: profile ? { name: profile.name, bloodType: profile.bloodType } : null,
      riskScore,
      totalReadings: stats?.total_readings || 0,
      criticalAlertsInPeriod: criticals,
      averages: stats ? {
        heartRate:    stats.avg_heart_rate,
        maxHeartRate: stats.max_heart_rate,
        minHeartRate: stats.min_heart_rate,
        systolicBP:   stats.avg_systolic_bp,
        diastolicBP:  stats.avg_diastolic_bp,
        respRate:     stats.avg_resp_rate,
        temperature:  stats.avg_temperature,
        oxygenSat:    stats.avg_oxygen_sat,
        minOxygenSat: stats.min_oxygen_sat,
      } : null,
      latestVitals: latest || null,
      latestInsight: latInsight || null,
    });
  }
);

// ── GET /api/reports/export ── Full data export as JSON
router.get('/export', async (req, res) => {
  const vitals   = await ddb.queryVitals({ limit: 5000 });
  const insights = await ddb.queryInsights({ limit: 1000 });
  const alerts   = await ddb.queryAlerts({ limit: 1000 });
  const profile  = await ddb.getProfile();

  res.setHeader('Content-Disposition', 'attachment; filename="health_twin_export.json"');
  res.setHeader('Content-Type', 'application/json');

  return res.json({
    exportedAt: new Date().toISOString(),
    profile,
    vitals,
    insights,
    alerts,
  });
});

module.exports = router;
