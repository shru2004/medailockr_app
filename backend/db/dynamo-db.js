// ─── DynamoDB Data-Access Layer ───────────────────────────────────────────────
// Drop-in replacement for the JSON flat-file read/write helpers.
// All route handlers import from this file instead of touching JSON directly.
//
// Conventions:
//   • profileId defaults to 'user#default' (single-tenant MVP)
//   • sortKey  = "{isoTimestamp}#{uuid}"  for time-series tables
//   • Returns plain JS objects – DocumentClient handles marshalling

const { randomUUID } = require('crypto');
const {
  GetCommand,
  PutCommand,
  DeleteCommand,
  QueryCommand,
  UpdateCommand,
} = require('@aws-sdk/lib-dynamodb');
const { ddb }   = require('./dynamo-client');
const { T }     = require('./dynamo-tables');

const DEFAULT_PROFILE_ID = process.env.DEFAULT_PROFILE_ID || 'user#default';

// ─── tiny helpers ─────────────────────────────────────────────────────────────

const uid       = () => randomUUID();
const iso       = () => new Date().toISOString();
const sortKey   = (ts = iso()) => `${ts}#${uid()}`;
const profileId = () => DEFAULT_PROFILE_ID;

// ─── PROFILES ─────────────────────────────────────────────────────────────────

async function getProfile() {
  const res = await ddb.send(new GetCommand({
    TableName: T.PROFILES,
    Key: { profileId: profileId() },
  }));
  return res.Item || null;
}

async function saveProfile(data) {
  const item = { ...data, profileId: profileId(), updatedAt: iso() };
  await ddb.send(new PutCommand({ TableName: T.PROFILES, Item: item }));
  return item;
}

// ─── VITALS ───────────────────────────────────────────────────────────────────

async function queryVitals({ limit = 100 } = {}) {
  const res = await ddb.send(new QueryCommand({
    TableName: T.VITALS,
    KeyConditionExpression: 'profileId = :pid',
    ExpressionAttributeValues: { ':pid': profileId() },
    ScanIndexForward: false,         // most recent first
    Limit: limit,
  }));
  return res.Items || [];
}

async function putVital(data) {
  const ts   = data.recordedAt || iso();
  const item = { ...data, profileId: profileId(), sortKey: sortKey(ts), recordedAt: ts };
  await ddb.send(new PutCommand({ TableName: T.VITALS, Item: item }));
  return item;
}

// ─── INSIGHTS ─────────────────────────────────────────────────────────────────

async function queryInsights({ limit = 50 } = {}) {
  const res = await ddb.send(new QueryCommand({
    TableName: T.INSIGHTS,
    KeyConditionExpression: 'profileId = :pid',
    ExpressionAttributeValues: { ':pid': profileId() },
    ScanIndexForward: false,
    Limit: limit,
  }));
  return res.Items || [];
}

async function putInsight(data) {
  const ts   = data.createdAt || iso();
  const item = { ...data, profileId: profileId(), createdAt: ts };
  await ddb.send(new PutCommand({ TableName: T.INSIGHTS, Item: item }));
  return item;
}

// ─── ALERTS ───────────────────────────────────────────────────────────────────

async function queryAlerts({ limit = 100 } = {}) {
  const res = await ddb.send(new QueryCommand({
    TableName: T.ALERTS,
    KeyConditionExpression: 'profileId = :pid',
    ExpressionAttributeValues: { ':pid': profileId() },
    ScanIndexForward: false,
    Limit: limit,
  }));
  return res.Items || [];
}

async function putAlert(data) {
  const item = {
    ...data,
    profileId: profileId(),
    alertId:   data.alertId || uid(),
    createdAt: data.createdAt || iso(),
    dismissed: data.dismissed !== undefined ? String(data.dismissed) : 'false',
  };
  await ddb.send(new PutCommand({ TableName: T.ALERTS, Item: item }));
  return item;
}

async function dismissAlert(alertId) {
  await ddb.send(new UpdateCommand({
    TableName: T.ALERTS,
    Key: { profileId: profileId(), alertId },
    UpdateExpression: 'SET dismissed = :t, updatedAt = :now',
    ExpressionAttributeValues: { ':t': 'true', ':now': iso() },
  }));
}

async function deleteAlert(alertId) {
  await ddb.send(new DeleteCommand({
    TableName: T.ALERTS,
    Key: { profileId: profileId(), alertId },
  }));
}

// ─── INGESTION ────────────────────────────────────────────────────────────────

async function queryIngestion({ limit = 100 } = {}) {
  const res = await ddb.send(new QueryCommand({
    TableName: T.INGESTION,
    KeyConditionExpression: 'profileId = :pid',
    ExpressionAttributeValues: { ':pid': profileId() },
    ScanIndexForward: false,
    Limit: limit,
  }));
  return res.Items || [];
}

async function putIngestionRecord(data) {
  const ts   = data.recordedAt || iso();
  const item = { ...data, profileId: profileId(), sortKey: sortKey(ts), recordedAt: ts };
  await ddb.send(new PutCommand({ TableName: T.INGESTION, Item: item }));
  return item;
}

// ─── EVENTS ───────────────────────────────────────────────────────────────────

async function queryEvents({ limit = 100 } = {}) {
  const res = await ddb.send(new QueryCommand({
    TableName: T.EVENTS,
    KeyConditionExpression: 'profileId = :pid',
    ExpressionAttributeValues: { ':pid': profileId() },
    ScanIndexForward: false,
    Limit: limit,
  }));
  return res.Items || [];
}

async function putEvent(data) {
  const ts   = data.recordedAt || iso();
  const item = { ...data, profileId: profileId(), sortKey: sortKey(ts), recordedAt: ts };
  await ddb.send(new PutCommand({ TableName: T.EVENTS, Item: item }));
  return item;
}

// ─── MEDICAL RECORDS (Passport) ───────────────────────────────────────────────

async function queryMedicalRecords({ limit = 200 } = {}) {
  const res = await ddb.send(new QueryCommand({
    TableName: T.MEDICAL_RECORDS,
    KeyConditionExpression: 'profileId = :pid',
    ExpressionAttributeValues: { ':pid': profileId() },
    ScanIndexForward: false,
    Limit: limit,
  }));
  return res.Items || [];
}

async function getMedicalRecord(recordId) {
  const res = await ddb.send(new GetCommand({
    TableName: T.MEDICAL_RECORDS,
    Key: { profileId: profileId(), recordId },
  }));
  return res.Item || null;
}

async function putMedicalRecord(data) {
  const item = {
    ...data,
    profileId:  profileId(),
    recordId:   data.recordId || uid(),
    recordDate: data.recordDate || iso().slice(0, 10),
    createdAt:  data.createdAt || iso(),
    updatedAt:  iso(),
  };
  await ddb.send(new PutCommand({ TableName: T.MEDICAL_RECORDS, Item: item }));
  return item;
}

async function deleteMedicalRecord(recordId) {
  await ddb.send(new DeleteCommand({
    TableName: T.MEDICAL_RECORDS,
    Key: { profileId: profileId(), recordId },
  }));
}

// ─── EMERGENCY QR ─────────────────────────────────────────────────────────────

async function getEmergencyQR() {
  const res = await ddb.send(new GetCommand({
    TableName: T.EMERGENCY_QR,
    Key: { profileId: profileId() },
  }));
  return res.Item || null;
}

async function saveEmergencyQR(data) {
  const item = { ...data, profileId: profileId(), updatedAt: iso() };
  await ddb.send(new PutCommand({ TableName: T.EMERGENCY_QR, Item: item }));
  return item;
}

async function appendQRAccessLog(entry) {
  const item = {
    ...entry,
    profileId: profileId(),
    scannedAt: entry.scannedAt || iso(),
    logId:     uid(),
  };
  await ddb.send(new PutCommand({ TableName: T.QR_ACCESS_LOG, Item: item }));
  return item;
}

async function queryQRAccessLog({ limit = 50 } = {}) {
  const res = await ddb.send(new QueryCommand({
    TableName: T.QR_ACCESS_LOG,
    KeyConditionExpression: 'profileId = :pid',
    ExpressionAttributeValues: { ':pid': profileId() },
    ScanIndexForward: false,
    Limit: limit,
  }));
  return res.Items || [];
}

// ─── SHARING ──────────────────────────────────────────────────────────────────

async function getSharing() {
  const res = await ddb.send(new GetCommand({
    TableName: T.SHARING,
    Key: { profileId: profileId() },
  }));
  return res.Item || { profileId: profileId(), shareVitals: false, shareInsights: false, partners: [] };
}

async function saveSharing(data) {
  const item = { ...data, profileId: profileId(), updatedAt: iso() };
  await ddb.send(new PutCommand({ TableName: T.SHARING, Item: item }));
  return item;
}

// ─── COMPATIBILITY ────────────────────────────────────────────────────────────

async function getCompatibility() {
  const res = await ddb.send(new GetCommand({
    TableName: T.COMPATIBILITY,
    Key: { profileId: profileId() },
  }));
  return res.Item || { profileId: profileId(), currentMedications: [] };
}

async function saveCompatibility(data) {
  const item = { ...data, profileId: profileId(), updatedAt: iso() };
  await ddb.send(new PutCommand({ TableName: T.COMPATIBILITY, Item: item }));
  return item;
}

// ─── HEALTH CREDITS ───────────────────────────────────────────────────────────

async function getCredits() {
  const res = await ddb.send(new GetCommand({
    TableName: T.CREDITS,
    Key: { profileId: profileId() },
  }));
  return res.Item || { profileId: profileId(), balance: 0, totalEarned: 0, totalRedeemed: 0 };
}

async function saveCredits(data) {
  const item = { ...data, profileId: profileId(), updatedAt: iso() };
  await ddb.send(new PutCommand({ TableName: T.CREDITS, Item: item }));
  return item;
}

async function appendCreditTransaction(tx) {
  const ts   = iso();
  const item = {
    ...tx,
    profileId: profileId(),
    sortKey:   sortKey(ts),
    createdAt: ts,
    txId:      uid(),
  };
  await ddb.send(new PutCommand({ TableName: T.CREDIT_TRANSACTIONS, Item: item }));
  return item;
}

// ─── BLOCKCHAIN ───────────────────────────────────────────────────────────────

async function getBlockchain() {
  const res = await ddb.send(new GetCommand({
    TableName: T.BLOCKCHAIN,
    Key: { profileId: profileId() },
  }));
  return res.Item || null;
}

async function saveBlockchain(data) {
  const item = { ...data, profileId: profileId(), updatedAt: iso() };
  await ddb.send(new PutCommand({ TableName: T.BLOCKCHAIN, Item: item }));
  return item;
}

async function queryBlockchainEvents({ limit = 200 } = {}) {
  const res = await ddb.send(new QueryCommand({
    TableName: T.BLOCKCHAIN_EVENTS,
    KeyConditionExpression: 'profileId = :pid',
    ExpressionAttributeValues: { ':pid': profileId() },
    ScanIndexForward: false,
    Limit: limit,
  }));
  return res.Items || [];
}

async function appendBlockchainEvent(event) {
  const ts   = iso();
  const item = {
    ...event,
    profileId: profileId(),
    sortKey:   sortKey(ts),
    realTs:    ts,
    eventId:   uid(),
  };
  await ddb.send(new PutCommand({ TableName: T.BLOCKCHAIN_EVENTS, Item: item }));
  return item;
}

// ─── WEARABLE DEVICES ─────────────────────────────────────────────────────────

async function queryWearableDevices() {
  const res = await ddb.send(new QueryCommand({
    TableName: T.WEARABLE_DEVICES,
    KeyConditionExpression: 'profileId = :pid',
    ExpressionAttributeValues: { ':pid': profileId() },
  }));
  return res.Items || [];
}

async function getWearableDevice(deviceId) {
  const res = await ddb.send(new GetCommand({
    TableName: T.WEARABLE_DEVICES,
    Key: { profileId: profileId(), deviceId },
  }));
  return res.Item || null;
}

async function putWearableDevice(data) {
  const item = { ...data, profileId: profileId(), deviceId: data.deviceId || uid(), updatedAt: iso() };
  await ddb.send(new PutCommand({ TableName: T.WEARABLE_DEVICES, Item: item }));
  return item;
}

// ─── GENOMIC DATA ─────────────────────────────────────────────────────────────

async function getGenomic() {
  const res = await ddb.send(new GetCommand({
    TableName: T.GENOMIC,
    Key: { profileId: profileId() },
  }));
  return res.Item || null;
}

async function saveGenomic(data) {
  const item = { ...data, profileId: profileId(), updatedAt: iso() };
  await ddb.send(new PutCommand({ TableName: T.GENOMIC, Item: item }));
  return item;
}

// ─── DISCHARGE RECORDS ────────────────────────────────────────────────────────

async function queryDischarge({ limit = 50 } = {}) {
  const res = await ddb.send(new QueryCommand({
    TableName: T.DISCHARGE,
    KeyConditionExpression: 'profileId = :pid',
    ExpressionAttributeValues: { ':pid': profileId() },
    ScanIndexForward: false,
    Limit: limit,
  }));
  return res.Items || [];
}

async function putDischargeRecord(data) {
  const item = {
    ...data,
    profileId: profileId(),
    recordId:  data.recordId || uid(),
    createdAt: data.createdAt || iso(),
    updatedAt: iso(),
  };
  await ddb.send(new PutCommand({ TableName: T.DISCHARGE, Item: item }));
  return item;
}

// ─── exports ──────────────────────────────────────────────────────────────────
module.exports = {
  // profile
  getProfile, saveProfile,
  // vitals
  queryVitals, putVital,
  // insights
  queryInsights, putInsight,
  // alerts
  queryAlerts, putAlert, dismissAlert, deleteAlert,
  // ingestion
  queryIngestion, putIngestionRecord,
  // events
  queryEvents, putEvent,
  // medical records
  queryMedicalRecords, getMedicalRecord, putMedicalRecord, deleteMedicalRecord,
  // emergency
  getEmergencyQR, saveEmergencyQR, appendQRAccessLog, queryQRAccessLog,
  // sharing
  getSharing, saveSharing,
  // compatibility
  getCompatibility, saveCompatibility,
  // credits
  getCredits, saveCredits, appendCreditTransaction,
  // blockchain
  getBlockchain, saveBlockchain, queryBlockchainEvents, appendBlockchainEvent,
  // wearable
  queryWearableDevices, getWearableDevice, putWearableDevice,
  // genomic
  getGenomic, saveGenomic,
  // discharge
  queryDischarge, putDischargeRecord,
};
