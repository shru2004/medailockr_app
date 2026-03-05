#!/usr/bin/env node
// ─── DynamoDB Table Provisioning Script ───────────────────────────────────────
// Run once to create all MedAILockr tables on AWS (or DynamoDB Local):
//
//   cd backend
//   node db/dynamo-setup.js
//
// Idempotent – skips tables that already exist.
// Pass --seed to also write default profile + seed records.

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const {
  CreateTableCommand,
  DescribeTableCommand,
  waitUntilTableExists,
} = require('@aws-sdk/client-dynamodb');
const { PutCommand } = require('@aws-sdk/lib-dynamodb');
const { dynamo, ddb }          = require('./dynamo-client');
const { T, TABLE_DEFINITIONS } = require('./dynamo-tables');

const SEED = process.argv.includes('--seed');

// ─── helpers ──────────────────────────────────────────────────────────────────

async function tableExists(name) {
  try {
    await dynamo.send(new DescribeTableCommand({ TableName: name }));
    return true;
  } catch (e) {
    if (e.name === 'ResourceNotFoundException') return false;
    throw e;
  }
}

async function createTable(def) {
  const exists = await tableExists(def.TableName);
  if (exists) {
    console.log(`  ✓  ${def.TableName}  (already exists, skipped)`);
    return;
  }
  await dynamo.send(new CreateTableCommand(def));
  // Wait until ACTIVE before moving on (avoids seeding before table is ready)
  await waitUntilTableExists(
    { client: dynamo, maxWaitTime: 60 },
    { TableName: def.TableName },
  );
  console.log(`  ✓  ${def.TableName}  (created)`);
}

// ─── seed data ────────────────────────────────────────────────────────────────

async function seedDefaultData() {
  console.log('\n── Seeding default data ──');

  const profileId = 'user#default';
  const now = new Date().toISOString();

  // Profile
  await ddb.send(new PutCommand({
    TableName: T.PROFILES,
    ConditionExpression: 'attribute_not_exists(profileId)',
    Item: {
      profileId,
      name:          'Sarah Johnson',
      dateOfBirth:   '1985-03-15',
      bloodType:     'A+',
      weight:        68,
      height:        165,
      allergies:     ['Penicillin', 'Shellfish'],
      conditions:    ['Type 2 Diabetes', 'Hypertension'],
      emergencyContact: {
        name:  'Michael Johnson',
        phone: '+1-555-0123',
        relation: 'Spouse',
      },
      createdAt: now,
      updatedAt: now,
    },
  }).catch(e => { if (e.name !== 'ConditionalCheckFailedException') throw e; }));
  console.log('  ✓  profiles  (default user seeded)');

  // Credits balance
  await ddb.send(new PutCommand({
    TableName: T.CREDITS,
    ConditionExpression: 'attribute_not_exists(profileId)',
    Item: {
      profileId,
      balance:    1250,
      totalEarned: 1850,
      totalRedeemed: 600,
      updatedAt:  now,
    },
  }).catch(e => { if (e.name !== 'ConditionalCheckFailedException') throw e; }));
  console.log('  ✓  credits  (default balance seeded)');

  // Blockchain state
  await ddb.send(new PutCommand({
    TableName: T.BLOCKCHAIN,
    ConditionExpression: 'attribute_not_exists(profileId)',
    Item: {
      profileId,
      blockCount:      147,
      lastBlockHash:   '0x8f4a2b9c1e6d3f7a',
      consensusStatus: 'verified',
      networkNodes:    12,
      threatLevel:     'low',
      updatedAt:       now,
    },
  }).catch(e => { if (e.name !== 'ConditionalCheckFailedException') throw e; }));
  console.log('  ✓  blockchain  (state seeded)');

  // Drug compatibility
  await ddb.send(new PutCommand({
    TableName: T.COMPATIBILITY,
    ConditionExpression: 'attribute_not_exists(profileId)',
    Item: {
      profileId,
      currentMedications: ['Metformin 500mg', 'Lisinopril 10mg', 'Atorvastatin 20mg'],
      updatedAt: now,
    },
  }).catch(e => { if (e.name !== 'ConditionalCheckFailedException') throw e; }));
  console.log('  ✓  compatibility  (medications seeded)');

  // Sharing defaults
  await ddb.send(new PutCommand({
    TableName: T.SHARING,
    ConditionExpression: 'attribute_not_exists(profileId)',
    Item: {
      profileId,
      shareVitals:    true,
      shareInsights:  false,
      shareGenomics:  false,
      shareLocation:  false,
      partners:       [],
      updatedAt:      now,
    },
  }).catch(e => { if (e.name !== 'ConditionalCheckFailedException') throw e; }));
  console.log('  ✓  sharing  (defaults seeded)');
}

// ─── main ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log(`\n═══════════════════════════════════════════`);
  console.log(` MedAILockr – DynamoDB Table Provisioning  `);
  console.log(`═══════════════════════════════════════════`);
  console.log(` Region   : ${process.env.AWS_REGION || 'us-east-1'}`);
  console.log(` Endpoint : ${process.env.DYNAMO_ENDPOINT || 'AWS (production)'}`);
  console.log(` Tables   : ${TABLE_DEFINITIONS.length}`);
  console.log(` Seed     : ${SEED}`);
  console.log(`───────────────────────────────────────────\n`);

  for (const def of TABLE_DEFINITIONS) {
    await createTable(def);
  }

  if (SEED) await seedDefaultData();

  console.log('\n✅  All done.\n');
}

main().catch(err => {
  console.error('\n❌ Setup failed:', err.message);
  process.exit(1);
});
