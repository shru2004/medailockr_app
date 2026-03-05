// ─── Voice Access Screen ─────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

class VoiceAccessScreen extends StatefulWidget {
  const VoiceAccessScreen({super.key});
  @override
  State<VoiceAccessScreen> createState() => _VoiceAccessScreenState();
}

class _VoiceAccessScreenState extends State<VoiceAccessScreen> with SingleTickerProviderStateMixin {
  final _stt = SpeechToText();
  bool _listening = false;
  String _recognized = '';
  String? _response;
  late AnimationController _pulse;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final ok = await _stt.initialize();
    if (mounted) setState(() => _initialized = ok);
  }

  Future<void> _toggle() async {
    if (!_initialized) return;
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
      _processCommand(_recognized);
    } else {
      setState(() { _listening = true; _recognized = ''; _response = null; });
      await _stt.listen(onResult: (r) { if (mounted) setState(() => _recognized = r.recognizedWords); });
    }
  }

  void _processCommand(String cmd) {
    final lower = cmd.toLowerCase();
    setState(() {
      if (lower.contains('blood pressure') || lower.contains('bp')) {
        _response = 'Your last recorded BP is 118/76 mmHg — within normal range.';
      } else if (lower.contains('heart rate') || lower.contains('pulse')) {
        _response = 'Your current heart rate is 72 BPM — normal.';
      } else if (lower.contains('medication') || lower.contains('medicine')) {
        _response = 'Your next medication is Amlodipine 5mg at 8:00 AM tomorrow.';
      } else if (cmd.isNotEmpty) {
        _response = 'I understood: "$cmd". Please try asking about your vitals or medications.';
      }
    });
  }

  @override
  void dispose() { _pulse.dispose(); _stt.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Voice Access',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, child) => Transform.scale(
                scale: _listening ? 1.0 + _pulse.value * 0.12 : 1.0,
                child: child,
              ),
              child: GestureDetector(
                onTap: _toggle,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _listening ? const Color(0xFFEF4444) : AppColors.primaryBlue,
                    boxShadow: [BoxShadow(color: (_listening ? const Color(0xFFEF4444) : AppColors.primaryBlue).withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 4)],
                  ),
                  child: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 44),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(_listening ? 'Listening…' : 'Tap to speak', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _listening ? const Color(0xFFEF4444) : AppColors.textPrimary)),
            if (_recognized.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.bgColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)), child: Text('"$_recognized"', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontStyle: FontStyle.italic))),
            ],
            if (_response != null) ...[
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryBlue, size: 18), const SizedBox(width: 8), Expanded(child: Text(_response!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5)))])),
            ],
          ]),
        ),
      ),
    );
  }
}
