// ─── DynamoDB Table Definitions ───────────────────────────────────────────────
// All 17 tables for MedAILockr.
// Used by:
//   • dynamo-setup.js  — creates the tables on AWS
//   • dynamo-client.js — referenced as table name constants at runtime
//
// Design principles:
//   • PK  = profileId   (all data is per-patient)
//   • SK  = meaningful sort key (timestamp, id, or entity sub-type)
//   • GSI added only where query-by-secondary-attribute is required
//   • All timestamps stored as ISO-8601 strings (DynamoDB has no Date type)
//   • BillingMode: PAY_PER_REQUEST  — no capacity planning needed for MVP

const REGION = process.env.AWS_REGION || 'us-east-1';
const PREFIX = process.env.DYNAMO_TABLE_PREFIX || 'medailockr';

// ─── Table name constants (import these everywhere) ───────────────────────────
const T = {
  PROFILES:             `${PREFIX}-profiles`,
  VITALS:               `${PREFIX}-vitals`,
  INSIGHTS:             `${PREFIX}-insights`,
  ALERTS:               `${PREFIX}-alerts`,
  INGESTION:            `${PREFIX}-ingestion`,
  EVENTS:               `${PREFIX}-events`,
  MEDICAL_RECORDS:      `${PREFIX}-medical-records`,
  EMERGENCY_QR:         `${PREFIX}-emergency-qr`,
  QR_ACCESS_LOG:        `${PREFIX}-qr-access-log`,
  SHARING:              `${PREFIX}-sharing`,
  COMPATIBILITY:        `${PREFIX}-compatibility`,
  CREDITS:              `${PREFIX}-credits`,
  CREDIT_TRANSACTIONS:  `${PREFIX}-credit-transactions`,
  BLOCKCHAIN:           `${PREFIX}-blockchain`,
  BLOCKCHAIN_EVENTS:    `${PREFIX}-blockchain-events`,
  WEARABLE_DEVICES:     `${PREFIX}-wearable-devices`,
  GENOMIC:              `${PREFIX}-genomic`,
  DISCHARGE:            `${PREFIX}-discharge`,
};

// ─── CreateTable parameter objects ────────────────────────────────────────────
// Pass each of these directly to DynamoDB.createTable()

const TABLE_DEFINITIONS = [

  // ── 1. Profiles ────────────────────────────────────────────────────────────
  // Single item per patient. PK: profileId (e.g. "user#default")
  {
    TableName: T.PROFILES,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
    ],
  },

  // ── 2. Vitals ──────────────────────────────────────────────────────────────
  // Time-series. SK = "recordedAt#uuid" so multiple readings per second are safe.
  // GSI on source for filtering by sensor origin.
  {
    TableName: T.VITALS,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId',  KeyType: 'HASH'  },
      { AttributeName: 'sortKey',    KeyType: 'RANGE' }, // recordedAt#uuid
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
      { AttributeName: 'sortKey',   AttributeType: 'S' },
      { AttributeName: 'source',    AttributeType: 'S' },
      { AttributeName: 'recordedAt',AttributeType: 'S' },
    ],
    GlobalSecondaryIndexes: [
      {
        IndexName: 'source-recordedAt-index',
        KeySchema: [
          { AttributeName: 'source',     KeyType: 'HASH'  },
          { AttributeName: 'recordedAt', KeyType: 'RANGE' },
        ],
        Projection: { ProjectionType: 'ALL' },
      },
    ],
  },

  // ── 3. AI Insights ─────────────────────────────────────────────────────────
  // SK = createdAt (ISO string, lexicographic sort = chronological sort)
  {
    TableName: T.INSIGHTS,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH'  },
      { AttributeName: 'createdAt', KeyType: 'RANGE' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
      { AttributeName: 'createdAt', AttributeType: 'S' },
    ],
  },

  // ── 4. Alerts ──────────────────────────────────────────────────────────────
  // SK = alertId (UUID). GSI on dismissed for fast active-alerts query.
  {
    TableName: T.ALERTS,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH'  },
      { AttributeName: 'alertId',   KeyType: 'RANGE' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
      { AttributeName: 'alertId',   AttributeType: 'S' },
      { AttributeName: 'dismissed', AttributeType: 'S' }, // 'true'|'false' (string for GSI)
      { AttributeName: 'createdAt', AttributeType: 'S' },
    ],
    GlobalSecondaryIndexes: [
      {
        IndexName: 'profileId-dismissed-index',
        KeySchema: [
          { AttributeName: 'profileId', KeyType: 'HASH'  },
          { AttributeName: 'dismissed', KeyType: 'RANGE' },
        ],
        Projection: { ProjectionType: 'ALL' },
      },
      {
        IndexName: 'profileId-createdAt-index',
        KeySchema: [
          { AttributeName: 'profileId', KeyType: 'HASH'  },
          { AttributeName: 'createdAt', KeyType: 'RANGE' },
        ],
        Projection: { ProjectionType: 'ALL' },
      },
    ],
  },

  // ── 5. Ingestion Log ───────────────────────────────────────────────────────
  {
    TableName: T.INGESTION,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH'  },
      { AttributeName: 'sortKey',   KeyType: 'RANGE' }, // recordedAt#uuid
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
      { AttributeName: 'sortKey',   AttributeType: 'S' },
    ],
  },

  // ── 6. App Events ──────────────────────────────────────────────────────────
  {
    TableName: T.EVENTS,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH'  },
      { AttributeName: 'sortKey',   KeyType: 'RANGE' }, // recordedAt#uuid
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
      { AttributeName: 'sortKey',   AttributeType: 'S' },
    ],
  },

  // ── 7. Medical Vault Records ───────────────────────────────────────────────
  // SK = recordId. GSI on category+recordDate for filtered browse.
  {
    TableName: T.MEDICAL_RECORDS,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH'  },
      { AttributeName: 'recordId',  KeyType: 'RANGE' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId',  AttributeType: 'S' },
      { AttributeName: 'recordId',   AttributeType: 'S' },
      { AttributeName: 'category',   AttributeType: 'S' },
      { AttributeName: 'recordDate', AttributeType: 'S' },
    ],
    GlobalSecondaryIndexes: [
      {
        IndexName: 'category-recordDate-index',
        KeySchema: [
          { AttributeName: 'category',   KeyType: 'HASH'  },
          { AttributeName: 'recordDate', KeyType: 'RANGE' },
        ],
        Projection: { ProjectionType: 'ALL' },
      },
    ],
  },

  // ── 8. Emergency QR ────────────────────────────────────────────────────────
  // Single item per patient (PK only). QR token stored as attribute.
  {
    TableName: T.EMERGENCY_QR,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
    ],
  },

  // ── 9. QR Access Log ───────────────────────────────────────────────────────
  {
    TableName: T.QR_ACCESS_LOG,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH'  },
      { AttributeName: 'scannedAt', KeyType: 'RANGE' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
      { AttributeName: 'scannedAt', AttributeType: 'S' },
    ],
  },

  // ── 10. Data Sharing Settings ──────────────────────────────────────────────
  // Single item per patient. Partners stored as a List attribute.
  {
    TableName: T.SHARING,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
    ],
  },

  // ── 11. Drug Compatibility ─────────────────────────────────────────────────
  // Single item per patient. currentMedications stored as a List attribute.
  {
    TableName: T.COMPATIBILITY,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
    ],
  },

  // ── 12. Health Credits Balance ─────────────────────────────────────────────
  // Single item per patient.
  {
    TableName: T.CREDITS,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
    ],
  },

  // ── 13. Credit Transactions ───────────────────────────────────────────────
  {
    TableName: T.CREDIT_TRANSACTIONS,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH'  },
      { AttributeName: 'sortKey',   KeyType: 'RANGE' }, // createdAt#uuid
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
      { AttributeName: 'sortKey',   AttributeType: 'S' },
    ],
  },

  // ── 14. Blockchain State ───────────────────────────────────────────────────
  // Single item per patient — chain metadata.
  {
    TableName: T.BLOCKCHAIN,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
    ],
  },

  // ── 15. Blockchain Audit Events ────────────────────────────────────────────
  {
    TableName: T.BLOCKCHAIN_EVENTS,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH'  },
      { AttributeName: 'sortKey',   KeyType: 'RANGE' }, // realTs#uuid
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
      { AttributeName: 'sortKey',   AttributeType: 'S' },
    ],
  },

  // ── 16. Wearable Devices ───────────────────────────────────────────────────
  {
    TableName: T.WEARABLE_DEVICES,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH'  },
      { AttributeName: 'deviceId',  KeyType: 'RANGE' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
      { AttributeName: 'deviceId',  AttributeType: 'S' },
    ],
  },

  // ── 17. Genomic Data ───────────────────────────────────────────────────────
  // Single item per patient. riskFactors + pharmacogenomics stored as Lists.
  {
    TableName: T.GENOMIC,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
    ],
  },

  // ── 18. Discharge Records ──────────────────────────────────────────────────
  {
    TableName: T.DISCHARGE,
    BillingMode: 'PAY_PER_REQUEST',
    KeySchema: [
      { AttributeName: 'profileId', KeyType: 'HASH'  },
      { AttributeName: 'recordId',  KeyType: 'RANGE' },
    ],
    AttributeDefinitions: [
      { AttributeName: 'profileId', AttributeType: 'S' },
      { AttributeName: 'recordId',  AttributeType: 'S' },
    ],
  },
];

module.exports = { T, TABLE_DEFINITIONS, REGION, PREFIX };
