// ─── Gemini Service ─────────────────────────────────────────────────────────
// Mirrors health-twin/services/geminiService.ts using the Dart SDK.

import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/vitals.dart';
import '../models/ai_insight.dart';

class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  String _apiKey = '';
  void setApiKey(String key) => _apiKey = key;
  bool get hasKey   => _apiKey.isNotEmpty;
  String get apiKey => _apiKey;

  // ── Vitals analysis ─────────────────────────────────────────────────────────
  Future<AIInsight> analyzeVitals(Vitals v, {String? profileContext}) async {
    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);
    final prompt = '''
You are a medical AI assistant analyzing real-time patient vitals.
${profileContext != null ? 'Patient context: $profileContext\n' : ''}
Current vitals:
- Heart Rate: ${v.heartRate.toStringAsFixed(0)} bpm
- Blood Pressure: ${v.systolicBP.toStringAsFixed(0)}/${v.diastolicBP.toStringAsFixed(0)} mmHg
- Respiratory Rate: ${v.respRate.toStringAsFixed(0)} breaths/min
- Temperature: ${v.temperature.toStringAsFixed(1)} °C
- Oxygen Saturation: ${v.oxygenSat.toStringAsFixed(0)}%

Respond ONLY with valid JSON (no markdown fences):
{
  "status": "optimal|moderate|critical",
  "message": "one-sentence summary",
  "confidence": 0-100,
  "analysis": "detailed analysis",
  "correlations": ["c1"],
  "immediateActions": ["a1"],
  "recommendations": ["r1"]
}''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = (response.text ?? '{}').replaceAll(RegExp(r'```(?:json)?'), '').trim();

    try {
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      final clean = (start != -1 && end != -1) ? text.substring(start, end + 1) : '{}';
      final data = json.decode(clean) as Map<String, dynamic>;
      return AIInsight.fromJson({
        'status':           data['status']     ?? 'moderate',
        'message':          data['message']    ?? 'Analysis complete',
        'confidence':       (data['confidence'] as num?)?.toDouble() ?? 85.0,
        'analysis':         data['analysis'],
        'correlations':     data['correlations'],
        'immediateActions': data['immediateActions'],
        'recommendations':  data['recommendations'],
      });
    } catch (_) {
      return AIInsight(
        status: 'moderate',
        message: text.length > 200 ? '${text.substring(0, 200)}...' : text,
        confidence: 80,
      );
    }
  }

  // ── Symptom chat ─────────────────────────────────────────────────────────────
  Future<String> chatSymptom(
    List<Map<String, String>> history,
    String userMessage,
  ) async {
    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);
    final chat = model.startChat(
      history: history
          .map((m) => Content(m['role']!, [TextPart(m['text']!)]))
          .toList(),
    );
    final response = await chat.sendMessage(Content.text(userMessage));
    return response.text ?? 'I was unable to process that. Please try again.';
  }

  // ── General purpose ──────────────────────────────────────────────────────────
  Future<String> ask(String prompt) async {
    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  // ── Image analysis ────────────────────────────────────────────────────────────
  Future<String> analyzeImage(
    List<int> imageBytes,
    String mimeType,
    String prompt,
  ) async {
    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);
    final bytes = Uint8List.fromList(imageBytes);
    final response = await model.generateContent([
      Content.multi([
        DataPart(mimeType, bytes),
        TextPart(prompt),
      ]),
    ]);
    return response.text ?? '';
  }

  // ── Government ID scanning ──────────────────────────────────────────────────
  /// Extracts structured data from a government-issued ID photo.
  /// Returns a map with keys: name, dob, idNumber, country, idType.
  Future<Map<String, String>> scanGovernmentId(
    List<int> imageBytes,
    String mimeType,
  ) async {
    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);
    final bytes = Uint8List.fromList(imageBytes);

    const prompt = '''
You are a secure identity verification AI. Analyze this government-issued ID document image.
Extract all visible text fields carefully.

Respond ONLY with a raw JSON object (no markdown, no explanation):
{
  "name": "Full name as printed on ID",
  "dob": "Date of birth as YYYY-MM-DD or as printed",
  "idNumber": "ID/passport/license number",
  "country": "Issuing country",
  "idType": "passport|driving_licence|national_id|other"
}

If a field is not visible or cannot be determined, use an empty string ("").''';

    final response = await model.generateContent([
      Content.multi([
        DataPart(mimeType, bytes),
        TextPart(prompt),
      ]),
    ]);

    final raw = (response.text ?? '').replaceAll(RegExp(r'```(?:json)?'), '').trim();
    try {
      final start = raw.indexOf('{');
      final end   = raw.lastIndexOf('}');
      if (start == -1 || end == -1) throw const FormatException('No JSON');
      final data = json.decode(raw.substring(start, end + 1)) as Map<String, dynamic>;
      return {
        'name':     (data['name']     ?? '').toString(),
        'dob':      (data['dob']      ?? '').toString(),
        'idNumber': (data['idNumber'] ?? '').toString(),
        'country':  (data['country']  ?? '').toString(),
        'idType':   (data['idType']   ?? '').toString(),
      };
    } catch (_) {
      return {'name': '', 'dob': '', 'idNumber': '', 'country': '', 'idType': ''};
    }
  }
}
