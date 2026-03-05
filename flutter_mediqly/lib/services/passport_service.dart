// ─── Passport Service ────────────────────────────────────────────────────────
// Mirrors backend/routes/passport.js endpoint contract exactly.
// Every method gracefully falls back to null / [] on network failure so
// the UI can show cached / static data when the backend is offline.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_endpoints.dart';

class PassportService {
  PassportService._();

  static const _base = ApiEndpoints.baseUrl;
  static const _to   = Duration(seconds: 10);

  // ── Private helpers ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> _get(String path) async {
    try {
      final res = await http.get(Uri.parse('$_base$path')).timeout(_to);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<List<dynamic>?> _getList(String path) async {
    try {
      final res = await http.get(Uri.parse('$_base$path')).timeout(_to);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        if (body is List) return body;
        if (body is Map && body['records'] != null) return body['records'] as List;
        if (body is Map && body['devices']  != null) return body['devices']  as List;
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> _post(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse('$_base$path'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(body))
          .timeout(_to);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> _put(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .put(Uri.parse('$_base$path'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(body))
          .timeout(_to);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> _delete(String path) async {
    try {
      final res = await http.delete(Uri.parse('$_base$path')).timeout(_to);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {}
    return false;
  }

  // ── Summary ────────────────────────────────────────────────────────────────

  /// GET /api/passport/summary
  static Future<Map<String, dynamic>?> getSummary() =>
      _get(ApiEndpoints.passportSummary);

  // ── Profile ────────────────────────────────────────────────────────────────

  /// GET /api/passport/profile
  static Future<Map<String, dynamic>?> getProfile() =>
      _get(ApiEndpoints.passportProfile);

  /// PUT /api/passport/profile
  static Future<Map<String, dynamic>?> updateProfile(
          Map<String, dynamic> updates) =>
      _put(ApiEndpoints.passportProfile, updates);

  // ── Medical Records / Vault ────────────────────────────────────────────────

  /// GET /api/passport/records?category=&status=
  static Future<List<dynamic>> getRecords({
    String category = 'all',
    String? status,
  }) async {
    var path = '${ApiEndpoints.passportRecords}?category=$category';
    if (status != null) path += '&status=$status';
    return await _getList(path) ?? [];
  }

  /// POST /api/passport/records
  static Future<Map<String, dynamic>?> addRecord(
          Map<String, dynamic> record) =>
      _post(ApiEndpoints.passportRecords, record);

  /// DELETE /api/passport/records/:id
  static Future<bool> deleteRecord(int id) =>
      _delete('${ApiEndpoints.passportRecords}/$id');

  // ── Emergency QR ─────────────────────────────────────────────────────────

  /// GET /api/passport/emergency
  static Future<Map<String, dynamic>?> getEmergencyQr() =>
      _get(ApiEndpoints.passportEmergency);

  /// POST /api/passport/emergency/log — log a QR scan event
  static Future<Map<String, dynamic>?> logQrScan({
    String actor  = 'Unknown',
    String action = 'Scanned',
  }) =>
      _post(ApiEndpoints.passportEmergencyLog, {
        'actor':  actor,
        'action': action,
      });

  // ── Cross-border Sharing ──────────────────────────────────────────────────

  /// GET /api/passport/sharing
  static Future<Map<String, dynamic>?> getSharingSettings() =>
      _get(ApiEndpoints.passportSharing);

  /// PUT /api/passport/sharing
  static Future<Map<String, dynamic>?> updateSharingSettings(
          Map<String, dynamic> settings) =>
      _put(ApiEndpoints.passportSharing, settings);

  // ── Drug Compatibility ────────────────────────────────────────────────────

  /// GET /api/passport/compatibility
  static Future<Map<String, dynamic>?> getCompatibility() =>
      _get(ApiEndpoints.passportCompatibility);

  /// POST /api/passport/compatibility/check
  static Future<Map<String, dynamic>?> checkDrugCompatibility(
          String drugName) =>
      _post(ApiEndpoints.passportCompatCheck, {'drugName': drugName});

  // ── Health Credits ─────────────────────────────────────────────────────────

  /// GET /api/passport/credits
  static Future<Map<String, dynamic>?> getCredits() =>
      _get(ApiEndpoints.passportCredits);

  /// POST /api/passport/credits/earn
  static Future<Map<String, dynamic>?> earnCredits({
    required String desc,
    required int points,
  }) =>
      _post(ApiEndpoints.passportCreditsEarn, {
        'desc':   desc,
        'points': points,
      });

  /// POST /api/passport/credits/redeem
  static Future<Map<String, dynamic>?> redeemCredits({
    required String desc,
    required int points,
  }) =>
      _post(ApiEndpoints.passportCreditsRedeem, {
        'desc':   desc,
        'points': points,
      });

  // ── Blockchain ────────────────────────────────────────────────────────────

  /// GET /api/passport/blockchain
  static Future<Map<String, dynamic>?> getBlockchainStatus() =>
      _get(ApiEndpoints.passportBlockchain);

  /// POST /api/passport/blockchain/event
  static Future<Map<String, dynamic>?> addBlockchainEvent({
    required String event,
    required String detail,
    String color = 'gray',
  }) =>
      _post(ApiEndpoints.passportBlockchainEvent, {
        'event':  event,
        'detail': detail,
        'color':  color,
      });

  // ── Wearable ─────────────────────────────────────────────────────────────

  /// GET /api/passport/wearable
  static Future<Map<String, dynamic>?> getWearableStatus() =>
      _get(ApiEndpoints.passportWearable);

  /// PUT /api/passport/wearable/devices/:id
  static Future<Map<String, dynamic>?> updateWearableDevice(
          String deviceId, Map<String, dynamic> updates) =>
      _put('/api/passport/wearable/devices/$deviceId', updates);

  // ── Genomic Data ──────────────────────────────────────────────────────────

  /// GET /api/passport/genomic
  static Future<Map<String, dynamic>?> getGenomicData() =>
      _get(ApiEndpoints.passportGenomicData);

  // ── Discharge Records ─────────────────────────────────────────────────────

  /// GET /api/passport/discharge
  static Future<List<dynamic>> getDischargeRecords() async =>
      (await _getList(ApiEndpoints.passportDischarge)) ?? [];

  /// POST /api/passport/discharge
  static Future<Map<String, dynamic>?> addDischargeRecord(
          Map<String, dynamic> record) =>
      _post(ApiEndpoints.passportDischarge, record);
}
