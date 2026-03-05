// ─── Symptom Checker Screen ──────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/page_wrapper.dart';

class SymptomCheckerScreen extends StatelessWidget {
  const SymptomCheckerScreen({super.key});

  static const _commonSymptoms = ['Headache', 'Fever', 'Cough', 'Fatigue', 'Nausea', 'Chest Pain', 'Shortness of Breath', 'Dizziness'];

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final app = context.watch<AppStateProvider>();

    return PageWrapper(
      title: 'Symptom Checker',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.psychology_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AI Symptom Analysis', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('Powered by Gemini AI', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ]),
                SizedBox(height: 12),
                Text('Describe your symptoms in detail for accurate AI-powered analysis and recommendations.',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 16),

            // Symptom input
            const Text('Describe Your Symptoms', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'e.g. I have a headache and slight fever for 2 days...'),
              onChanged: app.setSymptomInput,
            ),
            const SizedBox(height: 12),

            // Common symptoms chips
            const Text('Common Symptoms', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonSymptoms.map((s) => GestureDetector(
                onTap: () { app.setSymptomInput(app.symptomInput.isEmpty ? s : '${app.symptomInput}, $s'); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                  child: Text(s, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: app.symptomInput.isNotEmpty ? () => nav.navigateTo('symptom-chat') : null,
                child: const Text('Analyze Symptoms with AI'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
