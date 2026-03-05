// ─── Insurance Recommender Screen ────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../services/gemini_service.dart';
import '../../widgets/page_wrapper.dart';

class InsuranceRecommenderScreen extends StatefulWidget {
  const InsuranceRecommenderScreen({super.key});
  @override
  State<InsuranceRecommenderScreen> createState() => _InsuranceRecommenderScreenState();
}

class _InsuranceRecommenderScreenState extends State<InsuranceRecommenderScreen> {
  int _step = 0;
  final Map<String, String> _answers = {};
  bool _loading = false;
  String? _recommendation;
  final _questions = const [
    _Q('What is your age range?', ['18-25', '26-35', '36-45', '46-60', '60+']),
    _Q('Do you have pre-existing conditions?', ['None', 'Diabetes', 'Hypertension', 'Heart Disease', 'Multiple']),
    _Q('Monthly insurance budget?', ['Under ₹500', '₹500-1000', '₹1000-2000', '₹2000+']),
    _Q('Coverage type needed?', ['Individual', 'Family', 'Senior Citizen', 'Critical Illness']),
  ];

  Future<void> _getRecommendation() async {
    setState(() => _loading = true);
    final appState = context.read<AppStateProvider>();
    final gs = GeminiService.instance;
    gs.setApiKey(appState.apiKey);
    final prompt = 'Based on these profile answers: ${_answers.entries.map((e) => "${e.key}: ${e.value}").join(", ")}, recommend the best health insurance plan in India. Keep response under 150 words.';
    try {
      final resp = await gs.ask(prompt);
      if (mounted) setState(() { _recommendation = resp; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _recommendation = 'Unable to generate recommendation. Please ensure your Gemini API key is set.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Insurance Recommender',
      child: _recommendation != null ? _RecoResult(text: _recommendation!, onReset: () => setState(() { _recommendation = null; _step = 0; _answers.clear(); }))
          : _loading ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Analyzing your profile…', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))]))
          : _step < _questions.length ? _QuestionView(q: _questions[_step], step: _step, total: _questions.length, onSelect: (v) {
              _answers[_questions[_step].question] = v;
              if (_step < _questions.length - 1) {
                setState(() => _step++);
              } else {
                _getRecommendation();
              }
            })
          : const SizedBox(),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final _Q q; final int step, total; final void Function(String) onSelect;
  const _QuestionView({required this.q, required this.step, required this.total, required this.onSelect});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LinearProgressIndicator(value: (step + 1) / total, backgroundColor: AppColors.border, color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(4)),
      const SizedBox(height: 4),
      Text('Question ${step + 1} of $total', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      const SizedBox(height: 20),
      Text(q.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 16),
      ...q.options.map((o) => GestureDetector(
        onTap: () => onSelect(o),
        child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: Row(children: [
          Expanded(child: Text(o, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
        ])),
      )),
    ]),
  );
}

class _RecoResult extends StatelessWidget {
  final String text; final VoidCallback onReset;
  const _RecoResult({required this.text, required this.onReset});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryBlue, size: 20)), const SizedBox(width: 10), const Text('AI Recommendation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary))]),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
        ])),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: OutlinedButton(onPressed: onReset, child: const Text('Try Again'))),
    ]),
  );
}

class _Q {
  final String question; final List<String> options;
  const _Q(this.question, this.options);
}
