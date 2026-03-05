// ─── Health Twin Provider ────────────────────────────────────────────────────
// Real-time vitals, AI insights, alerts, Bluetooth status, voice, logs.

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/vitals.dart';
import '../models/alert.dart';
import '../models/ai_insight.dart';
import '../services/backend_service.dart';
import '../services/websocket_service.dart';
import '../services/gemini_service.dart';

class HealthTwinProvider extends ChangeNotifier {
  // ── Vitals ──────────────────────────────────────────────────────────────────
  Vitals _vitals = Vitals.initial();
  Vitals get vitals => _vitals;

  final Map<String, List<double>> _history = {
    'heartRate':   [],
    'systolicBP':  [],
    'diastolicBP': [],
    'respRate':    [],
    'temperature': [],
    'oxygenSat':   [],
  };
  Map<String, List<double>> get history => _history;

  // ── AI insight ──────────────────────────────────────────────────────────────
  AIInsight? _insight;
  AIInsight? get insight => _insight;
  bool _analyzingInsight = false;
  bool get analyzingInsight => _analyzingInsight;

  // ── Alerts ──────────────────────────────────────────────────────────────────
  final List<Alert> _alerts = [];
  List<Alert> get alerts => List.unmodifiable(_alerts);

  // ── Bluetooth ───────────────────────────────────────────────────────────────
  bool _bluetoothConnected = false;
  bool get bluetoothConnected => _bluetoothConnected;
  String _bluetoothDevice = '';
  String get bluetoothDevice => _bluetoothDevice;

  // ── Voice interface ──────────────────────────────────────────────────────────
  bool _voiceActive = false;
  bool get voiceActive => _voiceActive;

  // ── Ingestion logs ───────────────────────────────────────────────────────────
  int _waterCount = 0;
  int get waterCount => _waterCount;
  String _lastMeal = '';
  String get lastMeal => _lastMeal;

  // ── Ambient sound ────────────────────────────────────────────────────────────
  bool _ambientOn = false;
  bool get ambientOn => _ambientOn;

  // ── Backend auto-save batch ──────────────────────────────────────────────────
  final List<Map<String, dynamic>> _unsavedBatch = [];

  // ── Timers ───────────────────────────────────────────────────────────────────
  Timer? _vitalsTimer;    // 500 ms vitals tick interval
  Timer? _saveTimer;      // 5 s  backend auto-save batch

  final WebSocketService _ws = WebSocketService();
  final _rng = Random();

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  void start() {
    _ws.connect(_onWsEvent);
    _startVitalsSimulation();
    _startAutoSave();
    _loadAlerts();
  }

  void stop() {
    _vitalsTimer?.cancel();
    _saveTimer?.cancel();
    _ws.dispose();
  }

  void _startVitalsSimulation() {
    _vitalsTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_bluetoothConnected) return; // Bluetooth overrides simulation
      _updateVitals(_simulate(_vitals));
    });
  }

  Vitals _simulate(Vitals prev) {
    double vary(double v, double min, double max, double step) {
      final delta = (_rng.nextDouble() - 0.5) * step;
      return (v + delta).clamp(min, max);
    }
    return Vitals(
      heartRate:   vary(prev.heartRate,   50,  120, 2),
      systolicBP:  vary(prev.systolicBP,  90,  160, 3),
      diastolicBP: vary(prev.diastolicBP, 60,  100, 2),
      respRate:    vary(prev.respRate,     12,   25, 1),
      temperature: vary(prev.temperature, 36.0, 37.5, 0.1),
      oxygenSat:   vary(prev.oxygenSat,   94,  100, 0.5),
    );
  }

  void _updateVitals(Vitals v) {
    _vitals = v;
    const maxHistory = 30;
    void push(String key, double val) {
      _history[key]!.add(val);
      if (_history[key]!.length > maxHistory) _history[key]!.removeAt(0);
    }
    push('heartRate',   v.heartRate);
    push('systolicBP',  v.systolicBP);
    push('diastolicBP', v.diastolicBP);
    push('respRate',    v.respRate);
    push('temperature', v.temperature);
    push('oxygenSat',   v.oxygenSat);
    _unsavedBatch.add({...v.toJson(), 'timestamp': DateTime.now().toIso8601String()});
    notifyListeners();
  }

  // ── WebSocket handler ───────────────────────────────────────────────────────
  void _onWsEvent(Map<String, dynamic> event) {
    final type = event['type'] as String?;
    if (type == 'vitals_update') {
      final data = event['data'] as Map<String, dynamic>?;
      if (data != null) {
        _updateVitals(Vitals.fromJson(data));
      }
    } else if (type == 'alert') {
      final data = event['data'] as Map<String, dynamic>?;
      if (data != null) {
        _alerts.insert(0, Alert.fromJson(data));
        notifyListeners();
      }
    }
  }

  // ── Auto-save to backend every 5s ───────────────────────────────────────────
  void _startAutoSave() {
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_unsavedBatch.isEmpty) return;
      final toSave = List<Map<String, dynamic>>.from(_unsavedBatch);
      _unsavedBatch.clear();
      try {
        await BackendService.batchSaveVitals(toSave);
      } catch (_) {
        // restore on failure
        _unsavedBatch.addAll(toSave);
      }
    });
  }

  // ── Load alerts ─────────────────────────────────────────────────────────────
  Future<void> _loadAlerts() async {
    try {
      final fetched = await BackendService.getActiveAlerts();
      _alerts
        ..clear()
        ..addAll(fetched);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> dismissAlert(String id) async {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();
    try {
      await BackendService.dismissAlert(id);
    } catch (_) {}
  }

  // ── AI analysis ─────────────────────────────────────────────────────────────
  Future<void> analyzeWithAI() async {
    if (!GeminiService.instance.hasKey) return;
    _analyzingInsight = true;
    notifyListeners();
    try {
      final result = await GeminiService.instance.analyzeVitals(_vitals);
      _insight = result;
      await BackendService.saveInsight(result, _vitals);
    } catch (_) {
      _insight = null;
    } finally {
      _analyzingInsight = false;
      notifyListeners();
    }
  }

  // ── Bluetooth mock ──────────────────────────────────────────────────────────
  void toggleBluetooth() {
    _bluetoothConnected = !_bluetoothConnected;
    _bluetoothDevice = _bluetoothConnected ? 'Polar H10' : '';
    notifyListeners();
  }

  // ── Ingestion ─────────────────────────────────────────────────────────────
  Future<void> logWater() async {
    _waterCount++;
    notifyListeners();
    try {
      await BackendService.logIngestion('water');
    } catch (_) {}
  }

  Future<void> logMeal(String meal) async {
    _lastMeal = meal;
    notifyListeners();
    try {
      await BackendService.logIngestion('food', notes: meal);
    } catch (_) {}
  }

  // ── Ambient ───────────────────────────────────────────────────────────────
  void toggleAmbient() {
    _ambientOn = !_ambientOn;
    notifyListeners();
  }

  // ── Voice ─────────────────────────────────────────────────────────────────
  void setVoiceActive(bool active) {
    _voiceActive = active;
    notifyListeners();
  }
}
