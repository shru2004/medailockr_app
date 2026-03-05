// ─── Backend Service ────────────────────────────────────────────────────────
// Mirrors health-twin/services/backendService.ts exactly.
// ALL API endpoints, request shapes, and response handling are preserved 1:1.

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';
import '../models/vitals.dart';
import '../models/alert.dart';
import '../models/ai_insight.dart';
import '../models/patient_profile.dart';

class BackendService {
  // ── Base URL (resolves dart-define or falls back to localhost:4000) ────────
  static const _base = ApiEndpoints.baseUrl;

  // ── Private HTTP helpers ─────────────────────────────────────────────────
  // All helpers accept a *path* (e.g. '/api/vitals') and prepend _base.

  static Future<Map<String, dynamic>> _get(String path) async {
    final url = '$_base$path';
    final res = await http.get(Uri.parse(url))
        .timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException('GET timed out: $url'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GET $url failed: ${res.statusCode} ${res.body}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final url = '$_base$path';
    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    ).timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException('POST timed out: $url'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('POST $url failed: ${res.statusCode} ${res.body}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body) async {
    final url = '$_base$path';
    final res = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    ).timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException('PUT timed out: $url'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('PUT $url failed: ${res.statusCode} ${res.body}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> _delete(String path) async {
    final url = '$_base$path';
    final res = await http.delete(Uri.parse(url))
        .timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException('DELETE timed out: $url'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('DELETE $url failed: ${res.statusCode} ${res.body}');
    }
    // alerts/:id returns empty body on success
    if (res.body.trim().isEmpty) return {'success': true};
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // ── Vitals ─────────────────────────────────────────────────────────────────

  /// POST /api/vitals
  static Future<Map<String, dynamic>> saveVitals(Vitals vitals, {String source = 'manual'}) async {
    return await _post(ApiEndpoints.vitals, {
      ...vitals.toJson(),
      'source': source,
    });
  }

  /// GET /api/vitals?limit=&offset=
  static Future<List<Map<String, dynamic>>> getVitalsHistory({int limit = 100, int offset = 0}) async {
    final path = '${ApiEndpoints.vitals}?limit=$limit&offset=$offset';
    final url = '$_base$path';
    final res = await http.get(Uri.parse(url))
        .timeout(const Duration(seconds: 10), onTimeout: () => throw TimeoutException('GET timed out: $url'));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GET $url failed: ${res.statusCode}');
    }
    final body = json.decode(res.body);
    if (body is List) return body.cast<Map<String, dynamic>>();
    return (body['vitals'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  /// GET /api/vitals/latest
  static Future<Map<String, dynamic>?> getLatestVitals() async {
    try {
      return await _get(ApiEndpoints.vitalsLatest);
    } catch (_) {
      return null;
    }
  }

  /// POST /api/vitals/batch
  static Future<Map<String, dynamic>> batchSaveVitals(List<Map<String, dynamic>> snapshots) async {
    return await _post(ApiEndpoints.vitalsBatch, {'vitals': snapshots});
  }

  // ── Insights ───────────────────────────────────────────────────────────────

  /// POST /api/insights
  static Future<Map<String, dynamic>> saveInsight(
    AIInsight insight,
    Vitals vitalsSnapshot,
  ) async {
    return await _post(ApiEndpoints.insights, {
      ...insight.toJson(),
      'vitalsSnapshot': vitalsSnapshot.toJson(),
    });
  }

  /// GET /api/insights/latest
  static Future<Map<String, dynamic>?> getLatestInsight() async {
    try {
      return await _get(ApiEndpoints.insightsLatest);
    } catch (_) {
      return null;
    }
  }

  // ── Alerts ─────────────────────────────────────────────────────────────────

  /// GET /api/alerts
  static Future<List<Alert>> getActiveAlerts() async {
    final url = '$_base${ApiEndpoints.alerts}';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode < 200 || res.statusCode >= 300) return [];
    final body = json.decode(res.body);
    final List raw = body is List ? body : (body['alerts'] as List? ?? []);
    return raw.map((e) => Alert.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /api/alerts
  static Future<Map<String, dynamic>> createAlert(Alert alert) async {
    return await _post(ApiEndpoints.alerts, alert.toJson());
  }

  /// DELETE /api/alerts/:id
  static Future<void> dismissAlert(String id) async {
    await _delete('${ApiEndpoints.alerts}/$id');
  }

  // ── Reports ────────────────────────────────────────────────────────────────

  /// GET /api/reports/summary?period=
  static Future<Map<String, dynamic>> getHealthSummary({String period = 'weekly'}) async {
    return await _get('${ApiEndpoints.reportsSummary}?period=$period');
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  /// GET /api/profile
  static Future<PatientProfile?> getProfile() async {
    try {
      final data = await _get(ApiEndpoints.profile);
      return PatientProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// PUT /api/profile
  static Future<PatientProfile> updateProfile(PatientProfile profile) async {
    final data = await _put(ApiEndpoints.profile, profile.toJson());
    return PatientProfile.fromJson(data);
  }

  // ── Ingestion ──────────────────────────────────────────────────────────────

  /// POST /api/ingestion
  static Future<Map<String, dynamic>> logIngestion(String type, {String? notes}) async {
    return await _post(ApiEndpoints.ingestion, {
      'type': type,
      if (notes != null) 'notes': notes,
    });
  }

  // ── Events ─────────────────────────────────────────────────────────────────

  /// POST /api/events
  static Future<Map<String, dynamic>> logEvent(
    String type, {
    Map<String, dynamic>? metadata,
  }) async {
    return await _post(ApiEndpoints.events, {
      'type': type,
      if (metadata != null) 'metadata': metadata,
    });
  }
}
