// ─── Virtual Consultation Screen ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../services/gemini_service.dart';

class VirtualConsultationScreen extends StatefulWidget {
  const VirtualConsultationScreen({super.key});
  @override State<VirtualConsultationScreen> createState() => _VirtualConsultationScreenState();
}

class _VirtualConsultationScreenState extends State<VirtualConsultationScreen> {
  String _response = '';
  bool _loading = false;
  final _ctrl = TextEditingController();

  Future<void> _ask() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() { _loading = true; _response = ''; });
    try {
      final res = await GeminiService.instance.ask(
        'You are a virtual doctor. Patient says: "${_ctrl.text.trim()}". Provide a brief clinical assessment and recommendation.',
      );
      setState(() => _response = res);
    } catch (_) {
      setState(() => _response = 'Unable to connect. Please check your API key.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: context.read<NavigationProvider>().goBack,
        ),
        title: const Text('Virtual Consultation'),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: AppColors.border)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(children: [
              CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47')),
              SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Dr. AI Assistant', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                Text('Virtual General Physician', style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                  SizedBox(width: 4),
                  Text('Online', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ]),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('Describe your concern', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextField(controller: _ctrl, maxLines: 4, decoration: const InputDecoration(hintText: 'e.g. I have chest tightness and breathlessness...')),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _ask,
              child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Consult AI Doctor'),
            ),
          ),
          if (_response.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [Icon(Icons.psychology_rounded, color: Color(0xFF10B981), size: 16), SizedBox(width: 8), Text('AI Assessment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))]),
                const SizedBox(height: 10),
                Text(_response, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.6)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
