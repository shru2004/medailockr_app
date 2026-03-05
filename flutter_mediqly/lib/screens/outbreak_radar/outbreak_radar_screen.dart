// ─── Outbreak Radar Screen ───────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../widgets/page_wrapper.dart';

class OutbreakRadarScreen extends StatelessWidget {
  const OutbreakRadarScreen({super.key});

  static const _outbreaks = [
    _Outbreak('Dengue Alert', 'Delhi NCR & surrounding areas', 'High', Color(0xFFEF4444), 'Eliminate stagnant water. Use mosquito repellent when outdoors.', Icons.bug_report_rounded),
    _Outbreak('H3N2 Influenza', 'Mumbai, Pune, Thane', 'Moderate', Color(0xFFF59E0B), 'Get vaccinated. Wash hands frequently. Avoid crowded places.', Icons.coronavirus_rounded),
    _Outbreak('Cholera Advisory', 'Parts of Kolkata', 'Low', Color(0xFF10B981), 'Drink only purified water. Maintain food hygiene.', Icons.water_drop_rounded),
    _Outbreak('COVID-19 Watch', 'Pan-India (variant XBB.1.5)', 'Low', Color(0xFF10B981), 'Keep masks handy. Stay up-to-date with boosters.', Icons.masks_rounded),
  ];

  static const _news = [
    'WHO confirms seasonal flu strain shift — H3N2 replacing H1N1 in South Asia.',
    'Dengue cases up 34% year-over-year in Northern India metro areas.',
    'New rapid dengue detection kits now available at government health centres.',
    'India activates IDSP rapid response teams in 6 high-alert districts.',
  ];

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      backgroundColor: const Color(0xFF020617),
      title: 'Outbreak Radar',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Radar animation placeholder
          Container(
            height: 160, decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF22D3EE).withValues(alpha: 0.2))),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              TweenAnimationBuilder<double>(tween: Tween(begin: 0.6, end: 1.0), duration: const Duration(seconds: 2), curve: Curves.easeInOut, builder: (_, v, child) => Opacity(opacity: v, child: child), child: const Icon(Icons.radar_rounded, color: Color(0xFF22D3EE), size: 48)),
              const SizedBox(height: 8),
              const Text('Live Disease Surveillance Active', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 12, fontWeight: FontWeight.w500)),
              const Text('India · Updated: Just now', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
            ])),
          ),
          const SizedBox(height: 16),
          const Text('Current Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          ..._outbreaks.map((o) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12), border: Border.all(color: o.color.withValues(alpha: 0.25))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: o.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Icon(o.icon, color: o.color, size: 20)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(o.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(o.region, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: o.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)), child: Text(o.severity, style: TextStyle(fontSize: 10, color: o.color, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 8),
              Text(o.advice, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.4)),
            ]),
          )),
          const SizedBox(height: 12),
          const Text('Health News', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 8),
          ..._news.map((n) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF1E293B))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.article_rounded, size: 14, color: Color(0xFF22D3EE)), const SizedBox(width: 8), Expanded(child: Text(n, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.4)))]),
          )),
        ]),
      ),
    );
  }
}

class _Outbreak {
  final String name, region, severity, advice;
  final Color color;
  final IconData icon;
  const _Outbreak(this.name, this.region, this.severity, this.color, this.advice, this.icon);
}
