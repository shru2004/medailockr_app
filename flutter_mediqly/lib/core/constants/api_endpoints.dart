// ─── API Endpoints ─────────────────────────────────────────────────────────
// Mirrors backend/server.js route configuration exactly.
// All paths, methods and payload shapes are kept identical to the React
// backendService.ts so no API contract is changed.

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL – mirrors VITE_BACKEND_URL env var
  static const String baseUrl  = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:4000',
  );
  static const String wsUrl    = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://localhost:4000/ws',
  );

  // ── System
  static const String health   = '/api/health';

  // ── Vitals    (mirrors routes/vitals.js)
  static const String vitals          = '/api/vitals';
  static const String vitalsLatest    = '/api/vitals/latest';
  static const String vitalsBatch     = '/api/vitals/batch';

  // ── Insights  (mirrors routes/insights.js)
  static const String insights        = '/api/insights';
  static const String insightsLatest  = '/api/insights/latest';

  // ── Alerts    (mirrors routes/alerts.js)
  static const String alerts          = '/api/alerts';

  // ── Reports   (mirrors routes/reports.js)
  static const String reportsSummary  = '/api/reports/summary';
  static const String reportsExport   = '/api/reports/export';

  // ── Profile   (mirrors routes/profile.js)
  static const String profile         = '/api/profile';

  // ── Ingestion (mirrors routes/ingestion.js)
  static const String ingestion       = '/api/ingestion';

  // ── Events    (mirrors routes/events.js)
  static const String events          = '/api/events';

  // ── Passport  (mirrors routes/passport.js)
  static const String passportSummary          = '/api/passport/summary';
  static const String passportProfile          = '/api/passport/profile';
  static const String passportRecords          = '/api/passport/records';
  static const String passportEmergency        = '/api/passport/emergency';
  static const String passportEmergencyLog     = '/api/passport/emergency/log';
  static const String passportSharing          = '/api/passport/sharing';
  static const String passportCompatibility    = '/api/passport/compatibility';
  static const String passportCompatCheck      = '/api/passport/compatibility/check';
  static const String passportCredits          = '/api/passport/credits';
  static const String passportCreditsEarn      = '/api/passport/credits/earn';
  static const String passportCreditsRedeem    = '/api/passport/credits/redeem';
  static const String passportBlockchain       = '/api/passport/blockchain';
  static const String passportBlockchainEvent  = '/api/passport/blockchain/event';
  static const String passportWearable         = '/api/passport/wearable';
  static const String passportGenomicData      = '/api/passport/genomic';
  static const String passportDischarge        = '/api/passport/discharge';

  // ── Medicos   (mirrors routes/medicos.js)
  static const String medicosFeed              = '/api/medicos/feed';
  static const String medicosPosts             = '/api/medicos/posts';
  static const String medicosSpecialties       = '/api/medicos/communities';
  static const String medicosCommunities       = '/api/medicos/communities';
  static String medicosPost(String id)         => '/api/medicos/posts/$id';
  static String medicosLike(String id)         => '/api/medicos/posts/$id/vote';  // kept for compat
  static String medicosVote(String id)         => '/api/medicos/posts/$id/vote';
  static String medicosAward(String id)        => '/api/medicos/posts/$id/award';
  static String medicosShare(String id)        => '/api/medicos/posts/$id/share';
  static String medicosComments(String id)     => '/api/medicos/posts/$id/comments';
  static String medicosCommentVote(String id)  => '/api/medicos/comments/$id/vote';
}

// ─── Mock data constants ─────────────────────────────────────────────────────

const Map<String, List<String>> kHospitalsByCity = {
  'New York':    ['Grandview Hospital', 'City General Hospital', 'Mount Sinai'],
  'Los Angeles': ['LA General', 'Cedars-Sinai', 'UCLA Medical Center'],
  'Chicago':     ['Northwestern Memorial', 'Rush University Medical', 'UChicago Medicine'],
};

const List<String> kLabTestCategories = [
  'Complete Blood Count (CBC)',
  'Basic Metabolic Panel',
  'Thyroid Panel (TSH)',
  'Lipid Profile',
  'Liver Function Test',
  'Urine Analysis',
];
