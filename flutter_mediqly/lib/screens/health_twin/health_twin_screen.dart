// â”€â”€â”€ Health Twin Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

import 'dart:math' as math;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/navigation_provider.dart';
import '../../providers/health_twin_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../services/gemini_service.dart';

bool _bodyModelViewRegistered = false;

// â”€â”€â”€ Colour constants (Tailwind â†’ Dart) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const _slate950  = Color(0xFF020617);
const _slate900  = Color(0xFF0F172A);
const _slate800  = Color(0xFF1E293B);
const _slate700  = Color(0xFF334155);
const _slate600  = Color(0xFF475569);
const _slate500  = Color(0xFF64748B);
const _slate400  = Color(0xFF94A3B8);
const _slate300  = Color(0xFFCBD5E1);
const _slate200  = Color(0xFFE2E8F0);
const _cyan400   = Color(0xFF22D3EE);
const _cyan500   = Color(0xFF06B6D4);
const _cyan600   = Color(0xFF0891B2);
const _blue500   = Color(0xFF3B82F6);
const _emerald400= Color(0xFF34D399);
const _amber500  = Color(0xFFF59E0B);
const _red400    = Color(0xFFF87171);

// â”€â”€â”€ Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class HealthTwinScreen extends StatefulWidget {
  const HealthTwinScreen({super.key});
  @override State<HealthTwinScreen> createState() => _HealthTwinScreenState();
}

class _HealthTwinScreenState extends State<HealthTwinScreen> {
  late HealthTwinProvider _twin;
  bool _soundEnabled = false;
  bool _waterFlash   = false;
  bool _foodFlash    = false;
  String? _toastMsg;
  String _toastType  = 'info';          // 'success' | 'error' | 'info'

  @override
  void initState() {
    super.initState();
    _twin = context.read<HealthTwinProvider>();
    _twin.start();
  }

  @override
  void dispose() {
    _twin.stop();
    super.dispose();
  }

  void _toast(String msg, {String type = 'info'}) {
    setState(() { _toastMsg = msg; _toastType = type; });
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _toastMsg = null);
    });
  }

  void _logWater([int ml = 250]) {
    _twin.logWater();
    setState(() => _waterFlash = true);
    _toast('${ml}ml water logged', type: 'success');
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _waterFlash = false);
    });
  }

  Future<void> _pickWaterAmount() async {
    const picks = [150, 250, 350, 500, 750, 1000];
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _slate900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.local_drink_outlined, color: _blue500, size: 18),
              const SizedBox(width: 8),
              const Text('Log Water Intake',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close, color: _slate400, size: 18),
              ),
            ]),
            const SizedBox(height: 4),
            const Text('Select cup size', style: TextStyle(color: _slate400, fontSize: 12)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: picks.map((ml) => GestureDetector(
                onTap: () { Navigator.pop(ctx); _logWater(ml); },
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _slate800,
                    border: Border.all(color: _blue500.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.water_drop_outlined, color: _blue500, size: 22),
                    const SizedBox(height: 6),
                    Text('${ml}ml', style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ]),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMeal() async {
    final ctrl = TextEditingController();
    final meal = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSt) => AlertDialog(
          backgroundColor: _slate900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.restaurant_outlined, color: _amber500, size: 20),
            SizedBox(width: 8),
            Text('Log Meal',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('What did you eat?', style: TextStyle(color: _slate400, fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Chicken salad, brown rice...',
                  hintStyle: const TextStyle(color: _slate600),
                  filled: true,
                  fillColor: _slate800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _slate700),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _slate700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _amber500),
                  ),
                ),
                onSubmitted: (v) => Navigator.pop(ctx2, v.trim()),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Smoothie', 'Coffee']
                    .map((s) => GestureDetector(
                          onTap: () => setSt(() => ctrl.text = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _slate800,
                              border: Border.all(color: _amber500.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(s,
                                style: const TextStyle(color: _slate300, fontSize: 11)),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: const Text('Cancel', style: TextStyle(color: _slate400)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx2, ctrl.text.trim()),
              child: const Text('Log',
                  style: TextStyle(color: _amber500, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
    if (meal != null && meal.isNotEmpty) {
      _twin.logMeal(meal);
      setState(() => _foodFlash = true);
      _toast('Meal logged: $meal', type: 'success');
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _foodFlash = false);
      });
    }
  }

  Future<void> _openVoiceAssistant() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _slate900,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _VoiceAssistantSheet(
        vitalsContext:
            'HR: ${_twin.vitals.heartRate.toStringAsFixed(0)} bpm, '
            'BP: ${_twin.vitals.systolicBP.toStringAsFixed(0)}/${_twin.vitals.diastolicBP.toStringAsFixed(0)}, '
            'SpO2: ${_twin.vitals.oxygenSat.toStringAsFixed(0)}%, '
            'Temp: ${_twin.vitals.temperature.toStringAsFixed(1)}C, '
            'Resp: ${_twin.vitals.respRate.toStringAsFixed(0)}/min',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final twin = context.watch<HealthTwinProvider>();
    final nav  = context.read<NavigationProvider>();
    final hasKey = context.read<AppStateProvider>().hasApiKey;

    final isIntense = twin.vitals.heartRate > 115 ||
        twin.vitals.heartRate < 50 ||
        twin.vitals.systolicBP > 150 ||
        twin.vitals.oxygenSat < 92;

    return Scaffold(
      backgroundColor: _slate950,
      body: Stack(
        children: [
          // â”€â”€ Ambient blobs (fixed behind everything) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.2,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Color(0x14164E63), // cyan-900/20
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.2,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Color(0x141E3A8A), // blue-900/20
                shape: BoxShape.circle,
              ),
            ),
          ),

          // â”€â”€ Phone shell (max 390px centred) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                children: [
                  // sticky header
                  _Header(
                    isIntense: isIntense,
                    btConnected: twin.bluetoothConnected,
                    voiceActive: twin.voiceActive,
                    soundEnabled: _soundEnabled,
                    waterFlash: _waterFlash,
                    foodFlash: _foodFlash,
                    onBack: nav.goBack,
                    onBt: () {
                      final wasConnected = twin.bluetoothConnected;
                      twin.toggleBluetooth();
                      _toast(wasConnected ? 'Polar H10 disconnected.' : 'Connected: Polar H10',
                          type: wasConnected ? 'info' : 'success');
                    },
                    onVoice: _openVoiceAssistant,
                    onWater: _pickWaterAmount,
                    onFood: _pickMeal,
                    onSound: () {
                      final willEnable = !_soundEnabled;
                      setState(() => _soundEnabled = willEnable);
                      _toast(willEnable ? 'Ambient sound on' : 'Ambient sound off');
                    },
                  ),

                  // scrollable main
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // â”€â”€ VITALS section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                            _SectionLabel(label: 'Vitals', trailing: _DiagnosticButton(
                              loading: twin.analyzingInsight,
                              onTap: hasKey && !twin.analyzingInsight ? twin.analyzeWithAI : null,
                            )),
                            const SizedBox(height: 12),
                            _TwinVitalCard(
                              title: 'Heart Rate',
                              value: twin.vitals.heartRate.toStringAsFixed(0),
                              unit: 'bpm',
                              data: twin.history['heartRate'] ?? [],
                              color: (twin.vitals.heartRate > 100 || twin.vitals.heartRate < 50) ? _red400 : _cyan400,
                              btConnected: twin.bluetoothConnected,
                              showBtIcon: true,
                            ),
                            const SizedBox(height: 12),
                            _TwinVitalCard(
                              title: 'Blood Pressure',
                              value: '${twin.vitals.systolicBP.toStringAsFixed(0)} / ${twin.vitals.diastolicBP.toStringAsFixed(0)}',
                              unit: 'mmHg',
                              data: twin.history['systolicBP'] ?? [],
                              color: twin.vitals.systolicBP > 140 ? _amber500 : _cyan400,
                              icon: Icons.show_chart,
                            ),
                            const SizedBox(height: 12),
                            _TwinVitalCard(
                              title: 'Resp Rate',
                              value: twin.vitals.respRate.toStringAsFixed(0),
                              unit: '/min',
                              data: twin.history['respRate'] ?? [],
                              color: _cyan400,
                              icon: Icons.air,
                            ),
                            const SizedBox(height: 12),
                            _TwinVitalCard(
                              title: 'Oxygen Saturation',
                              value: twin.vitals.oxygenSat.toStringAsFixed(0),
                              unit: '%',
                              data: twin.history['oxygenSat'] ?? [],
                              color: twin.vitals.oxygenSat < 95 ? _red400 : _cyan400,
                              icon: Icons.water_drop_outlined,
                            ),
                            const SizedBox(height: 16),

                            // â”€â”€ BODY MODEL section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                            const _SectionLabel(label: 'Body Model', trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('SCANNING TARGET', style: TextStyle(fontSize: 10, color: _slate600, fontFamily: 'monospace')),
                                Text('SUBJECT_01', style: TextStyle(fontSize: 11, color: _cyan400, fontFamily: 'monospace')),
                              ],
                            )),
                            const SizedBox(height: 12),
                            Stack(
                              children: [
                                _BodyModelView(
                                  heartRate: twin.vitals.heartRate.toDouble(),
                                  spo2: twin.vitals.oxygenSat,
                                  temp: twin.vitals.temperature,
                                  status: twin.insight?.status ?? 'optimal',
                                ),
                                // Temp + SpO2 overlay — bottom overlay
                                Positioned(
                                  bottom: 16, left: 0, right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(children: [
                                        const Text('TEMP', style: TextStyle(
                                          fontSize: 10, color: _slate500,
                                          letterSpacing: 0.5, // matches React tracking-wider (0.05em)
                                        )),
                                        Text('${twin.vitals.temperature.toStringAsFixed(1)}°C',
                                          style: const TextStyle(
                                            fontSize: 24, fontFamily: 'monospace',
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF67E8F9), // cyan-300
                                          )),
                                      ]),
                                      const SizedBox(width: 40),
                                      Column(children: [
                                        const Text('SPO2', style: TextStyle(
                                          fontSize: 10, color: _slate500,
                                          letterSpacing: 0.5, // matches React tracking-wider (0.05em)
                                        )),
                                        Text('${twin.vitals.oxygenSat.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            fontSize: 24, fontFamily: 'monospace',
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF67E8F9), // cyan-300
                                          )),
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // â”€â”€ AI INSIGHTS section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                            const _SectionLabel(label: 'AI Insights'),
                            const SizedBox(height: 12),
                            _AlertSectionWidget(
                              alerts: twin.alerts,
                              insight: twin.insight,
                              loading: twin.analyzingInsight,
                            ),
                            const SizedBox(height: 16),

                            // â”€â”€ VISUAL INPUT (Camera) section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                            const _SectionLabel(label: 'Visual Input'),
                            const SizedBox(height: 12),
                            _CameraPlaceholder(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // â”€â”€ Header toast notification â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (_toastMsg != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 64,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _toastType == 'success' ? const Color(0xE6022C22)
                        : _toastType == 'error'   ? const Color(0xE6450A0A)
                        : const Color(0xE60F172A),
                    border: Border.all(
                      color: _toastType == 'success' ? const Color(0x6610B981)
                           : _toastType == 'error'   ? const Color(0x66EF4444)
                           : _slate700,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_toastType == 'success')
                        const Icon(Icons.check, size: 12, color: _emerald400),
                      if (_toastType == 'success') const SizedBox(width: 6),
                      Text(_toastMsg!,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          color: _toastType == 'success' ? _emerald400
                               : _toastType == 'error'   ? _red400
                               : _slate300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Sticky Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Mirrors: <header className="sticky top-0 z-50 bg-slate-950/95 backdrop-blur-md
//   border-b border-slate-800 px-4 py-3">
class _Header extends StatelessWidget {
  final bool isIntense, btConnected, voiceActive, soundEnabled, waterFlash, foodFlash;
  final VoidCallback onBack, onBt, onVoice, onWater, onFood, onSound;
  const _Header({
    required this.isIntense, required this.btConnected, required this.voiceActive,
    required this.soundEnabled, required this.waterFlash, required this.foodFlash,
    required this.onBack, required this.onBt, required this.onVoice,
    required this.onWater, required this.onFood, required this.onSound,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _slate950.withValues(alpha: 0.95),
          border: const Border(bottom: BorderSide(color: _slate800)),
        ),
        child: Row(
          children: [
            // â”€â”€ Left: back + title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // Back button: w-9 h-9 rounded-full bg-slate-900 border border-cyan-500/30
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _slate900,
                  shape: BoxShape.circle,
                  border: Border.all(color: _cyan500.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.arrow_back, color: _cyan400, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "HEALTH TWIN" gradient text
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [_cyan400, _blue500],
                  ).createShader(bounds),
                  child: const Text(
                    'HEALTH TWIN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    // Pulse dot: green = standard, amber = intense
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: isIntense ? _amber500 : _emerald400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isIntense ? 'ADAPTIVE MODE' : 'SYSTEM ONLINE',
                      style: const TextStyle(
                        fontSize: 10,
                        color: _slate500,
                        fontFamily: 'monospace',
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // â”€â”€ Right: action icon buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // All: w-8 h-8 rounded-full bg-slate-900 border border-slate-700
            _IconBtn(
              onTap: onBt,
              active: btConnected,
              activeColor: _emerald400,
              activeBg: const Color(0x33065F46),
              icon: btConnected ? Icons.watch : Icons.bluetooth,
              tooltip: btConnected ? 'Disconnect BT' : 'Connect Bluetooth',
            ),
            const SizedBox(width: 6),
            _IconBtn(
              onTap: onVoice,
              active: voiceActive,
              activeColor: _cyan400,
              activeBg: const Color(0x330E7490),
              icon: Icons.mic_none,
              tooltip: 'Voice Assistant',
            ),
            const SizedBox(width: 6),
            _IconBtn(
              onTap: onWater,
              active: waterFlash,
              activeColor: _blue500,
              activeBg: const Color(0x331D4ED8),
              icon: waterFlash ? Icons.check : Icons.local_drink_outlined,
              defaultIconColor: _blue500,
              tooltip: 'Log Water',
            ),
            const SizedBox(width: 6),
            _IconBtn(
              onTap: onFood,
              active: foodFlash,
              activeColor: _amber500,
              activeBg: const Color(0x33B45309),
              icon: foodFlash ? Icons.check : Icons.restaurant_outlined,
              defaultIconColor: _amber500,
              tooltip: 'Log Meal',
            ),
            const SizedBox(width: 6),
            _IconBtn(
              onTap: onSound,
              active: soundEnabled,
              activeColor: _cyan400,
              activeBg: const Color(0x330E7490),
              icon: soundEnabled ? Icons.volume_up_outlined : Icons.volume_off_outlined,
              defaultIconColor: _slate500,
              tooltip: soundEnabled ? 'Disable Sound' : 'Enable Sound',
            ),
          ],
        ),
      ),
    );
  }
}

// Circular icon button (small round header button)
class _IconBtn extends StatelessWidget {
  final VoidCallback onTap;
  final bool active;
  final Color activeColor, activeBg;
  final IconData icon;
  final Color? defaultIconColor;
  final String tooltip;
  const _IconBtn({
    required this.onTap, required this.active, required this.activeColor,
    required this.activeBg, required this.icon,
    this.defaultIconColor, required this.tooltip,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: active ? activeBg : _slate900,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? activeColor.withValues(alpha: 0.5) : _slate700,
          ),
        ),
        child: Icon(icon, size: 13,
          color: active ? activeColor : (defaultIconColor ?? _slate400)),
      ),
    ),
  );
}

// â”€â”€â”€ Section label â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// text-[11px] font-mono font-bold tracking-[0.2em] text-slate-500 uppercase
class _SectionLabel extends StatelessWidget {
  final String label;
  final Widget? trailing;
  const _SectionLabel({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w700,
          letterSpacing: 2.2,
          color: _slate500,
        ),
      ),
      if (trailing != null) trailing!,
    ],
  );
}

// â”€â”€â”€ DIAGNOSTIC button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DiagnosticButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onTap;
  const _DiagnosticButton({required this.loading, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _slate900,
        border: Border.all(color: _slate700),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            const SizedBox(width: 11, height: 11,
              child: CircularProgressIndicator(color: _cyan400, strokeWidth: 1.5))
          else
            const Icon(Icons.refresh, size: 11, color: _cyan400),
          const SizedBox(width: 6),
          const Text('DIAGNOSTIC', style: TextStyle(
            fontSize: 11, color: _cyan400, fontFamily: 'monospace',
            fontWeight: FontWeight.w700, letterSpacing: 0.55,
          )),
        ],
      ),
    ),
  );
}

// â”€â”€â”€ VitalCard â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Mirrors VitalCard.tsx:
//   bg-slate-900/40 border border-slate-800 rounded-2xl p-5 h-40
//   title xs slate-400 | value 3xl mono white | unit sm cyan-400 | icon cyan-500/80
//   sparkline area chart at bottom
class _TwinVitalCard extends StatelessWidget {
  final String title, value, unit;
  final List<double> data;
  final Color color;
  final IconData? icon;
  final bool showBtIcon;
  final bool btConnected;
  const _TwinVitalCard({
    required this.title, required this.value, required this.unit,
    required this.data, required this.color,
    this.icon, this.showBtIcon = false, this.btConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    // bg-slate-900/40 backdrop-blur border border-slate-800 rounded-2xl p-5 h-40
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _slate900.withValues(alpha: 0.4),
        border: Border.all(color: _slate800),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x1A0E7490), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: title/value + icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // text-xs text-slate-400 uppercase tracking-wider
                    Text(title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12, color: _slate400,
                        fontWeight: FontWeight.w600, letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        // text-3xl font-mono font-bold text-white tracking-tighter + cyan glow
                        Text(value,
                          style: const TextStyle(
                            fontSize: 30, fontFamily: 'monospace',
                            fontWeight: FontWeight.w700, color: Colors.white,
                            height: 1, letterSpacing: -1.5,
                            shadows: [Shadow(color: Color(0x8022D3EE), blurRadius: 5)],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // text-sm text-cyan-400 font-mono
                        Text(unit, style: const TextStyle(
                          fontSize: 14, color: _cyan400, fontFamily: 'monospace',
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              // icon â€“ text-cyan-500/80
              if (showBtIcon && btConnected)
                const Icon(Icons.bluetooth, size: 16, color: _emerald400)
              else if (icon != null)
                Icon(icon, size: 18, color: const Color.fromRGBO(6, 182, 212, 0.8)),
            ],
          ),

          const Spacer(),

          // Sparkline â€“ h-12
          if (data.length > 1)
            SizedBox(
              height: 48,
              child: LineChart(
                LineChartData(
                  minY: data.reduce(math.min) - 5,
                  maxY: data.reduce(math.max) + 5,
                  lineTouchData: const LineTouchData(enabled: false),
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(data.length,
                          (i) => FlSpot(i.toDouble(), data[i])),
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 500),
              ),
            ),
        ],
      ),
    );
  }
}
// --- Three.js Body Model (Web via HtmlElementView) -------------------------
class _BodyModelView extends StatefulWidget {
  final double heartRate, spo2, temp;
  final String status;
  const _BodyModelView({required this.heartRate, required this.spo2, required this.temp, required this.status});
  @override
  State<_BodyModelView> createState() => _BodyModelViewState();
}

class _BodyModelViewState extends State<_BodyModelView> {
  @override
  void initState() {
    super.initState();
    if (!_bodyModelViewRegistered) {
      _bodyModelViewRegistered = true;
      ui_web.platformViewRegistry.registerViewFactory(
        'body-model-view',
        (int viewId) => html.IFrameElement()
          ..src = 'body_model.html'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%',
      );
    }
  }

  @override
  void didUpdateWidget(_BodyModelView old) {
    super.didUpdateWidget(old);
    if (old.status != widget.status ||
        old.heartRate != widget.heartRate ||
        old.spo2 != widget.spo2 ||
        old.temp != widget.temp) {
      // Broadcast vitals update — the iframe listens via window.addEventListener('message',...)
      html.window.postMessage({
        'status': widget.status,
        'heartRate': widget.heartRate,
        'oxygenSat': widget.spo2,
        'temperature': widget.temp,
      }, '*');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      decoration: BoxDecoration(
        color: _slate900.withValues(alpha: 0.4), // matches React bg-slate-900/40
        border: Border.all(color: _slate800),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: const HtmlElementView(viewType: 'body-model-view'),
    );
  }
}

// _BodyPainter class removed — body model is now rendered via Three.js HtmlElementView

// â”€â”€â”€ AlertSection â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Mirrors AlertSection.tsx â€” "Active Protocols" + alerts + Neural Diagnostics
class _AlertSectionWidget extends StatelessWidget {
  final List alerts;
  final dynamic insight;
  final bool loading;
  const _AlertSectionWidget({required this.alerts, required this.insight, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [
              Icon(Icons.verified_user_outlined, size: 18, color: _cyan400),
              SizedBox(width: 8),
              Text('Active Protocols',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ]),
            if (insight != null && !loading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _slate900.withValues(alpha: 0.8),
                  border: Border.all(color: _slate700),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Confidence ', style: TextStyle(fontSize: 10, color: _slate400, letterSpacing: 0.5)),
                    Text(
                      '${insight.confidence?.toStringAsFixed(0) ?? 'â€“'}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: (insight.confidence ?? 0) > 80 ? _emerald400
                             : (insight.confidence ?? 0) > 50 ? _amber500 : _red400,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Alert stream
        if (loading && alerts.isEmpty) ...[
          _shimmer(), const SizedBox(height: 8), _shimmer(),
        ] else if (alerts.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: _slate800, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('No active anomalies detected.',
                style: TextStyle(color: _slate600, fontSize: 12)),
            ),
          )
        else
          ...alerts.map((alert) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _slate900.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              border: const Border(
                left: BorderSide(
                  color: _cyan500,
                  width: 2,
                ),
                top: BorderSide(color: _slate800),
                right: BorderSide(color: _slate800),
                bottom: BorderSide(color: _slate800),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  (alert.type == 'warning') ? Icons.warning_amber_outlined : Icons.bolt_outlined,
                  size: 16,
                  color: (alert.type == 'warning') ? _amber500 : _cyan500,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (alert.title ?? '').toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: (alert.type == 'warning') ? _amber500 : _cyan400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(alert.description ?? '',
                      style: const TextStyle(fontSize: 11, color: _slate400, height: 1.636)),
                  ],
                )),
              ],
            ),
          )),

        const SizedBox(height: 12),

        // Neural Diagnostics panel
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _slate950.withValues(alpha: 0.5),
            border: Border.all(color: _slate800),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.hub_outlined, size: 16, color: _cyan400),
                SizedBox(width: 8),
                Text('NEURAL DIAGNOSTICS',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: Colors.white, letterSpacing: 0.5)),
              ]),
              const SizedBox(height: 12),

              if (loading && insight == null) ...[
                _shimmerLine(1.0), const SizedBox(height: 8),
                _shimmerLine(0.85), const SizedBox(height: 8),
                _shimmerLine(0.7),
              ] else if (insight != null) ...[
                // STATUS badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusBg(insight.status),
                    border: Border.all(color: _statusColor(insight.status).withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'STATUS: ${(insight.status ?? '').toString().toUpperCase()} // ${insight.message ?? ''}',
                    style: TextStyle(fontSize: 12, fontFamily: 'monospace',
                      color: _statusColor(insight.status)),
                  ),
                ),

                if (insight.analysis != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _slate900.withValues(alpha: 0.5),
                      border: Border.all(color: _slate800),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: '>> ANALYSIS_LOG: ',
                            style: TextStyle(color: _cyan600, fontSize: 11, fontFamily: 'monospace'),
                          ),
                          TextSpan(
                            text: insight.analysis,
                            style: const TextStyle(color: _slate300, fontSize: 11,
                              fontFamily: 'monospace', height: 1.818),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if ((insight.correlations as List?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  const Text('CORRELATIONS DETECTED',
                    style: TextStyle(fontSize: 10, color: _slate500, letterSpacing: 0.5,
                      fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 6,
                    children: (insight.correlations as List<String>).map((c) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x1A164E63),
                          border: Border.all(color: const Color(0x66164E63)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(c, style: const TextStyle(fontSize: 10, color: Color(0xB322D3EE))),
                      ),
                    ).toList(),
                  ),
                ],

                if ((insight.immediateActions as List?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  const Divider(color: _slate800, height: 1),
                  const SizedBox(height: 12),
                  const Text('IMMEDIATE PROTOCOLS',
                    style: TextStyle(fontSize: 10, color: Color(0xCCF59E0B), letterSpacing: 0.5,
                      fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  ...(insight.immediateActions as List<String>).map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('! ', style: TextStyle(fontSize: 12, color: _amber500,
                          fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                        Expanded(child: Text(r,
                          style: const TextStyle(fontSize: 12, color: _slate200, height: 1.4))),
                      ],
                    ),
                  )),
                ],

                if ((insight.recommendations as List?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  const Divider(color: _slate800, height: 1),
                  const SizedBox(height: 12),
                  const Text('OPTIMIZATION STRATEGY',
                    style: TextStyle(fontSize: 10, color: Color(0x8034D399), letterSpacing: 0.5,
                      fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  ...(insight.recommendations as List<String>).map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('● ', style: TextStyle(fontSize: 12, color: Color(0x8034D399))),
                        Expanded(child: Text(r,
                          style: const TextStyle(fontSize: 12, color: _slate400, height: 1.4))),
                      ],
                    ),
                  )),
                ],
              ] else ...[
                const Text('Run a diagnostic to see AI health analysis.',
                  style: TextStyle(color: _slate600, fontSize: 12)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _statusColor(String? s) => s == 'optimal' ? _emerald400
      : s == 'critical' ? _red400 : _amber500;
  Color _statusBg(String? s) => s == 'optimal' ? const Color(0x1A052E16)
      : s == 'critical' ? const Color(0x1A450A0A) : const Color(0x1A451A00);

  Widget _shimmer() => Container(
    height: 64, margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: _slate900.withValues(alpha: 0.6),
      border: Border.all(color: _slate800),
      borderRadius: BorderRadius.circular(8),
    ),
  );

  Widget _shimmerLine(double wf) => Container(
    height: 8,
    width: double.infinity,
    decoration: BoxDecoration(
      color: _slate800,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

// â”€â”€â”€ Camera placeholder â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _CameraPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 200,
    decoration: BoxDecoration(
      color: _slate900.withValues(alpha: 0.4),
      border: Border.all(color: _slate800),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_outlined, size: 40, color: _slate600),
          SizedBox(height: 8),
          Text('Camera Feed', style: TextStyle(color: _slate500, fontSize: 12,
            fontFamily: 'monospace', letterSpacing: 1)),
        ],
      ),
    ),
  );
}
// ─────────────────────────────────────────────────────────────────────────
//  Voice Assistant Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────
class _VoiceAssistantSheet extends StatefulWidget {
  final String vitalsContext;
  const _VoiceAssistantSheet({required this.vitalsContext});
  @override
  State<_VoiceAssistantSheet> createState() => _VoiceAssistantSheetState();
}

class _VoiceAssistantSheetState extends State<_VoiceAssistantSheet> {
  final _speech = stt.SpeechToText();
  bool _listening = false;
  bool _speechAvailable = false;
  String _transcript = '';
  String _response = '';
  bool _thinking = false;
  final List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize();
    if (mounted) setState(() => _speechAvailable = ok);
  }

  Future<void> _toggleListen() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      if (_transcript.isNotEmpty) _ask(_transcript);
    } else {
      setState(() { _listening = true; _transcript = ''; });
      await _speech.listen(
        onResult: (r) => setState(() => _transcript = r.recognizedWords),
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(partialResults: true),
      );
    }
  }

  Future<void> _ask(String text) async {
    if (text.trim().isEmpty) return;
    setState(() { _thinking = true; _response = ''; });
    _history.add({'role': 'user', 'text': text});
    try {
      final prompt = 'Patient vitals: ${widget.vitalsContext}. '
          'Answer this health question concisely: $text';
      final reply = await GeminiService.instance.chatSymptom(_history, prompt);
      _history.add({'role': 'model', 'text': reply});
      if (mounted) {
        setState(() { _response = reply; _thinking = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _response = 'Sorry, could not get a response. Please try again.';
          _thinking = false;
        });
      }
    }
  }

  @override
  void dispose() { _speech.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, sc) => Container(
        decoration: const BoxDecoration(
          color: _slate900,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36, height: 4,
              decoration: BoxDecoration(color: _slate700, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _blue500.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.mic, color: _blue500, size: 18),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MediQ Voice Assistant',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('Ask about your vitals or symptoms',
                        style: TextStyle(color: _slate400, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: _slate400, size: 18),
                ),
              ]),
            ),
            const Divider(color: _slate800, height: 1),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.all(20),
                children: [
                  if (_transcript.isNotEmpty) _bubble(_transcript, isUser: true),
                  if (_thinking)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Row(children: [
                        SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: _blue500)),
                        SizedBox(width: 8),
                        Text('Thinking...', style: TextStyle(color: _slate400, fontSize: 13)),
                      ]),
                    ),
                  if (_response.isNotEmpty) _bubble(_response, isUser: false),
                  if (!_speechAvailable && _transcript.isEmpty && _response.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text('Microphone unavailable.\nType your question below.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _slate500, fontSize: 13)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 16, right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  top: 8),
              child: Row(children: [
                GestureDetector(
                  onTap: _speechAvailable ? _toggleListen : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _listening ? _blue500 : _blue500.withValues(alpha: 0.15),
                    ),
                    child: Icon(
                      _listening ? Icons.stop : Icons.mic,
                      color: _listening ? Colors.white : _blue500, size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _QuickTypeField(onSend: (t) {
                  setState(() => _transcript = t);
                  _ask(t);
                })),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(String text, {required bool isUser}) => Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(
        color: isUser ? _blue500 : _slate800,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: TextStyle(color: isUser ? Colors.white : _slate200, fontSize: 13)),
    ),
  );
}

class _QuickTypeField extends StatefulWidget {
  final ValueChanged<String> onSend;
  const _QuickTypeField({required this.onSend});
  @override
  State<_QuickTypeField> createState() => _QuickTypeFieldState();
}

class _QuickTypeFieldState extends State<_QuickTypeField> {
  final _ctrl = TextEditingController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => TextField(
    controller: _ctrl,
    style: const TextStyle(color: Colors.white, fontSize: 13),
    decoration: InputDecoration(
      hintText: 'Type a question...',
      hintStyle: const TextStyle(color: _slate500, fontSize: 13),
      filled: true, fillColor: _slate800,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: BorderSide.none),
      suffixIcon: IconButton(
        icon: const Icon(Icons.send_rounded, color: _blue500, size: 18),
        onPressed: () { final t = _ctrl.text.trim(); if (t.isNotEmpty) { _ctrl.clear(); widget.onSend(t); } },
      ),
    ),
    onSubmitted: (t) { if (t.trim().isNotEmpty) { _ctrl.clear(); widget.onSend(t.trim()); } },
  );
}
