// ─── DynamoDB Client ──────────────────────────────────────────────────────────
// Creates two exports:
//   • dynamo  – raw DynamoDBClient (for CreateTable, DescribeTable, etc.)
//   • ddb     – DynamoDBDocumentClient (auto marshals/unmarshals JS objects)
//
// Config is read from environment variables. In development you can point this
// at DynamoDB Local by setting DYNAMO_ENDPOINT=http://localhost:8000.

const { DynamoDBClient }                   = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, TranslateConfig } = require('@aws-sdk/lib-dynamodb');

const region   = process.env.AWS_REGION       || 'us-east-1';
const endpoint = process.env.DYNAMO_ENDPOINT  || undefined; // leave undefined for real AWS

const clientConfig = {
  region,
  ...(endpoint ? { endpoint } : {}),
  // Credentials are read automatically from:
  //   1. Environment variables AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY
  //   2. ~/.aws/credentials / EC2 instance role
  // You can override by setting those env vars in backend/.env
};

// Raw DynamoDB client – used for admin operations (CreateTable etc.)
const dynamo = new DynamoDBClient(clientConfig);

// DocumentClient – automatically converts JS plain objects to/from DynamoDB's
// AttributeValue format (  { S: "foo" }  ↔  "foo"  ).
/** @type {import('@aws-sdk/lib-dynamodb').DynamoDBDocumentClient} */
const ddb = DynamoDBDocumentClient.from(dynamo, {
  marshallOptions: {
    // Convert undefined values to null so they get stored, not silently dropped
    convertEmptyValues: false,
    removeUndefinedValues: true,
    convertClassInstanceToMap: true,
  },
  unmarshallOptions: {
    wrapNumbers: false,
  },
});

module.exports = { dynamo, ddb };
