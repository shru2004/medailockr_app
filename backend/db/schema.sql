-- ═══════════════════════════════════════════════════════════════════════════
--  MedAILockr — PostgreSQL Schema
--  Target: Amazon RDS for PostgreSQL 16+
--  Run once against a fresh database:
--    psql -h <RDS_HOST> -U <DB_USER> -d <DB_NAME> -f schema.sql
-- ═══════════════════════════════════════════════════════════════════════════

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─── 1. PATIENT PROFILE ──────────────────────────────────────────────────────
--  One row per patient/user. Mirrors profileColl in database.js
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  external_id    TEXT        UNIQUE NOT NULL DEFAULT 'default',  -- kept for backwards-compat
  name           TEXT        NOT NULL DEFAULT 'Subject 01',
  age            SMALLINT,
  gender         TEXT,
  weight_kg      NUMERIC(5,2),
  height_cm      NUMERIC(5,2),
  blood_type     TEXT,
  nationality    TEXT,
  passport_id    TEXT,                        -- AI Health Passport ID
  dob            DATE,
  emergency_name TEXT,
  emergency_rel  TEXT,
  emergency_phone TEXT,
  primary_doctor TEXT,
  doctor_facility TEXT,
  doctor_phone    TEXT,
  conditions     TEXT[]      NOT NULL DEFAULT '{}',
  medications    TEXT[]      NOT NULL DEFAULT '{}',
  allergies      TEXT[]      NOT NULL DEFAULT '{}',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 2. VITALS ────────────────────────────────────────────────────────────────
--  Time-series vital signs. High insert rate — indexed by recorded_at.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vitals (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id     UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  heart_rate     NUMERIC(6,1) NOT NULL,
  systolic_bp    NUMERIC(6,1) NOT NULL,
  diastolic_bp   NUMERIC(6,1) NOT NULL,
  resp_rate      NUMERIC(5,1) NOT NULL,
  temperature    NUMERIC(5,2) NOT NULL,
  oxygen_sat     NUMERIC(5,1) NOT NULL,
  source         TEXT        NOT NULL DEFAULT 'simulation', -- 'simulation'|'bluetooth'|'manual'|'wearable'
  recorded_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vitals_recorded_at  ON vitals (recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_vitals_profile_id   ON vitals (profile_id);

-- ─── 3. AI INSIGHTS ───────────────────────────────────────────────────────────
--  Gemini AI analysis results for a vitals snapshot.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS insights (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id        UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  summary           TEXT        NOT NULL,
  status            TEXT        NOT NULL DEFAULT 'optimal',  -- 'optimal'|'warning'|'critical'
  recommendations   TEXT[]      NOT NULL DEFAULT '{}',
  alerts            TEXT[]      NOT NULL DEFAULT '{}',
  -- snapshot of vitals at time of analysis
  snapshot_heart_rate   NUMERIC(6,1),
  snapshot_systolic_bp  NUMERIC(6,1),
  snapshot_diastolic_bp NUMERIC(6,1),
  snapshot_resp_rate    NUMERIC(5,1),
  snapshot_temperature  NUMERIC(5,2),
  snapshot_oxygen_sat   NUMERIC(5,1),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_insights_created_at ON insights (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_insights_profile_id ON insights (profile_id);

-- ─── 4. ALERTS ────────────────────────────────────────────────────────────────
--  Health alerts (threshold breaches, AI-generated warnings).
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS alerts (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  type        TEXT        NOT NULL DEFAULT 'warning',  -- 'info'|'warning'|'critical'
  vital       TEXT,                                    -- e.g. 'heartRate'
  message     TEXT        NOT NULL,
  value       NUMERIC(8,2),                            -- the triggering value
  threshold   NUMERIC(8,2),                            -- the threshold breached
  dismissed   BOOLEAN     NOT NULL DEFAULT FALSE,
  dismissed_at TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alerts_dismissed   ON alerts (dismissed);
CREATE INDEX IF NOT EXISTS idx_alerts_created_at  ON alerts (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_alerts_profile_id  ON alerts (profile_id);

-- ─── 5. INGESTION LOG ─────────────────────────────────────────────────────────
--  Food and water logs.
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ingestion (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  type        TEXT        NOT NULL,   -- 'water'|'meal'
  notes       TEXT,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ingestion_recorded_at ON ingestion (recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_ingestion_profile_id  ON ingestion (profile_id);

-- ─── 6. APP EVENTS ────────────────────────────────────────────────────────────
--  Generic event log (navigation, feature usage, errors).
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS events (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  type        TEXT        NOT NULL,
  metadata    JSONB,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_events_type        ON events (type);
CREATE INDEX IF NOT EXISTS idx_events_recorded_at ON events (recorded_at DESC);

-- ═══════════════════════════════════════════════════════════════════════════
--  AI HEALTH PASSPORT TABLES
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 7. PASSPORT PROFILE (extends main profile) ──────────────────────────────
CREATE TABLE IF NOT EXISTS passport_profiles (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id      UUID        UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  passport_number TEXT        UNIQUE NOT NULL,
  issued_at       DATE,
  expires_at      DATE,
  consent_version TEXT        NOT NULL DEFAULT '1.0',
  consent_updated TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 8. MEDICAL VAULT RECORDS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS medical_records (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  diagnosis   TEXT        NOT NULL,
  treatment   TEXT,
  provider    TEXT,
  facility    TEXT,
  category    TEXT        NOT NULL DEFAULT 'visits', -- 'visits'|'lab results'|'vaccines'
  status      TEXT        NOT NULL DEFAULT 'verified', -- 'verified'|'results_ready'|'archived'
  notes       TEXT,
  record_date DATE,
  attachments JSONB       NOT NULL DEFAULT '[]',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_medical_records_profile   ON medical_records (profile_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_category  ON medical_records (category);
CREATE INDEX IF NOT EXISTS idx_medical_records_date      ON medical_records (record_date DESC);

-- ─── 9. EMERGENCY QR ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS emergency_qr (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id   UUID        UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  qr_token     TEXT        UNIQUE NOT NULL,
  qr_version   SMALLINT    NOT NULL DEFAULT 1,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at   TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS qr_access_log (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  qr_id      UUID        REFERENCES emergency_qr(id) ON DELETE CASCADE,
  actor      TEXT        NOT NULL DEFAULT 'Unknown',
  action     TEXT        NOT NULL DEFAULT 'Scanned',
  scanned_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_qr_access_log_qr_id ON qr_access_log (qr_id);

-- ─── 10. DATA SHARING CONSENT ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sharing_settings (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id       UUID        UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  sharing_enabled  BOOLEAN     NOT NULL DEFAULT TRUE,
  regions          TEXT[]      NOT NULL DEFAULT '{}',
  consent_updated  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS sharing_partners (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_id   UUID        REFERENCES sharing_settings(id) ON DELETE CASCADE,
  partner_name TEXT        NOT NULL,
  enabled      BOOLEAN     NOT NULL DEFAULT FALSE,
  scope        TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 11. DRUG COMPATIBILITY ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS compatibility_medications (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  name        TEXT        NOT NULL,
  dose        TEXT,
  frequency   TEXT,
  added_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS compatibility_checks (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id   UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  drug_name    TEXT        NOT NULL,
  is_safe      BOOLEAN     NOT NULL,
  interactions TEXT[]      NOT NULL DEFAULT '{}',
  checked_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── 12. HEALTH CREDITS ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS health_credits (
  id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id       UUID          UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  balance          INTEGER       NOT NULL DEFAULT 0,
  tier             TEXT          NOT NULL DEFAULT 'Bronze', -- 'Bronze'|'Silver'|'Gold'|'Platinum'
  lifetime_earned  INTEGER       NOT NULL DEFAULT 0,
  updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS credit_transactions (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  description TEXT        NOT NULL,
  points      INTEGER     NOT NULL,                -- positive=earn, negative=redeem
  type        TEXT        NOT NULL,                -- 'earn'|'redeem'
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_credit_tx_profile ON credit_transactions (profile_id);

-- ─── 13. BLOCKCHAIN AUDIT LOG ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS blockchain_state (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id     UUID        UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  chain_id       TEXT        NOT NULL DEFAULT 'medai-mainnet-v1',
  wallet_address TEXT,
  total_blocks   INTEGER     NOT NULL DEFAULT 0,
  last_synced_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS blockchain_events (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  event_name TEXT        NOT NULL,
  detail     TEXT,
  color      TEXT        NOT NULL DEFAULT 'gray',
  real_ts    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_blockchain_events_profile  ON blockchain_events (profile_id);
CREATE INDEX IF NOT EXISTS idx_blockchain_events_real_ts  ON blockchain_events (real_ts DESC);

-- ─── 14. WEARABLE DEVICES ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS wearable_devices (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  device_name TEXT        NOT NULL,
  device_type TEXT        NOT NULL,  -- 'smartwatch'|'hrm'|'scale'
  connected   BOOLEAN     NOT NULL DEFAULT FALSE,
  battery_pct SMALLINT,
  last_sync   TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS wearable_metrics (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  steps       INTEGER,
  steps_goal  INTEGER,
  calories    INTEGER,
  sleep_hrs   NUMERIC(4,1),
  hrv         INTEGER,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wearable_metrics_profile ON wearable_metrics (profile_id);

-- ─── 15. GENOMIC DATA ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS genomic_data (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id   UUID        UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  status       TEXT        NOT NULL DEFAULT 'not_uploaded', -- 'not_uploaded'|'analysed'
  provider     TEXT,
  analysed_at  TIMESTAMPTZ,
  ancestry     JSONB,                             -- { "European": 68, "Asian": 20 ... }
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS genomic_risk_factors (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  genomic_id  UUID        REFERENCES genomic_data(id) ON DELETE CASCADE,
  condition   TEXT        NOT NULL,
  risk_level  TEXT        NOT NULL,  -- 'Low'|'Moderate'|'High'
  percentile  SMALLINT
);

CREATE TABLE IF NOT EXISTS genomic_pharmacogenomics (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  genomic_id UUID        REFERENCES genomic_data(id) ON DELETE CASCADE,
  gene       TEXT        NOT NULL,
  drug       TEXT        NOT NULL,
  metabolism TEXT        NOT NULL
);

-- ─── 16. DISCHARGE RECORDS ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS discharge_records (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id          UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  facility            TEXT        NOT NULL,
  admitted_at         TIMESTAMPTZ,
  discharged_at       TIMESTAMPTZ,
  diagnosis           TEXT,
  discharge_summary   TEXT,
  follow_up           TEXT,
  discharge_meds      TEXT[]      NOT NULL DEFAULT '{}',
  status              TEXT        NOT NULL DEFAULT 'verified',
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_discharge_profile ON discharge_records (profile_id);

-- ═══════════════════════════════════════════════════════════════════════════
--  HELPER: auto-update updated_at columns
-- ═══════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE TRIGGER trg_passport_profiles_updated_at
  BEFORE UPDATE ON passport_profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ═══════════════════════════════════════════════════════════════════════════
--  SEED: default profile row (matches backend default in database.js)
-- ═══════════════════════════════════════════════════════════════════════════
INSERT INTO profiles (external_id, name)
VALUES ('default', 'Subject 01')
ON CONFLICT (external_id) DO NOTHING;
