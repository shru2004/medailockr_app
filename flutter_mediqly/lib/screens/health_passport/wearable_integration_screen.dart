// ─── Wearable Integration Screen + Wearable Sync Modal ───────────────────────
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

// ─── Public helper ────────────────────────────────────────────────────────────
void showWearableSyncModal(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const _WearableSyncModal(),
  );
}

// ─── Wearable Sync Modal ──────────────────────────────────────────────────────
class _WearableSyncModal extends StatefulWidget {
  const _WearableSyncModal();
  @override
  State<_WearableSyncModal> createState() => _WearableSyncModalState();
}

class _WearableSyncModalState extends State<_WearableSyncModal> {
  int _tab = 0; // 0=Monitor 1=Insights 2=Guard
  bool _waterLogged = false;

  static const _kGray900 = Color(0xFF111827);
  static const _kGray500 = Color(0xFF6B7280);
  static const _kGray100 = Color(0xFFF3F4F6);
  static const _kGray200 = Color(0xFFE5E7EB);
  static const _kBlue    = Color(0xFF3B82F6);
  static const _kRed     = Color(0xFFEF4444);
  static const _kTeal    = Color(0xFF14B8A6);

  static const _tabs = ['Monitor', 'Insights', 'Guard'];

  // 24h heart rate trend points (hour index → BPM)
  static final _hrPoints = <FlSpot>[
    const FlSpot(0,  62), const FlSpot(2,  58), const FlSpot(4,  55),
    const FlSpot(6,  70), const FlSpot(8,  88), const FlSpot(10, 95),
    const FlSpot(12, 102),const FlSpot(14, 90), const FlSpot(16, 80),
    const FlSpot(18, 75), const FlSpot(20, 70), const FlSpot(22, 65),
    const FlSpot(24, 63),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 0),
              child: Row(children: [
                const Expanded(
                  child: Text('Wearable Sync',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                          color: _kGray900)),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(color: _kGray100, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 16, color: _kGray500),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // ── AI LifeScore Card ───────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B4FD8), Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('AI LIFESCORE',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                letterSpacing: 1, color: Colors.white70)),
                        const SizedBox(height: 4),
                        RichText(text: const TextSpan(
                          children: [
                            TextSpan(text: '842',
                                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            TextSpan(text: ' / 1000',
                                style: TextStyle(fontSize: 14, color: Colors.white60)),
                          ],
                        )),
                        const SizedBox(height: 6),
                        const Row(children: [
                          Icon(Icons.show_chart_rounded, size: 13, color: Colors.white70),
                          SizedBox(width: 4),
                          Text('Top 15% of your age group',
                              style: TextStyle(fontSize: 11, color: Colors.white70)),
                        ]),
                      ])),
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text('A+',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // ── Tab switcher ────────────────────────────────────────
                  Container(
                    height: 38,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: _kGray100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: List.generate(_tabs.length, (i) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _tab == i ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _tab == i
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4, offset: const Offset(0, 1))]
                                : null,
                          ),
                          child: Text(_tabs[i],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _tab == i ? _kGray900 : _kGray500,
                              )),
                        ),
                      ),
                    ))),
                  ),
                  const SizedBox(height: 14),

                  // ── Tab content ─────────────────────────────────────────
                  if (_tab == 0) _buildMonitor(),
                  if (_tab == 1) _buildInsights(),
                  if (_tab == 2) _buildGuard(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MONITOR TAB ──────────────────────────────────────────────────────────
  Widget _buildMonitor() => Column(children: [
    // 2-column vital grid
    GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.55,
      children: const [
        _VitalTile('Heart Rate', '63', 'BPM',     Icons.favorite_rounded,        Color(0xFFEF4444), Color(0xFFFFF1F2)),
        _VitalTile('SpO2',       '98%','Blood O2', Icons.water_drop_outlined,     Color(0xFF0EA5E9), Color(0xFFF0F9FF)),
        _VitalTile('Temp',       '98.6','°F',      Icons.thermostat_rounded,      Color(0xFFF97316), Color(0xFFFFF7ED)),
        _VitalTile('HRV',        '66', 'ms',       Icons.settings_input_antenna_rounded, Color(0xFF8B5CF6), Color(0xFFF5F3FF)),
        _VitalTile('Resp. Rate', '12', '/min',     Icons.air_rounded,             Color(0xFF14B8A6), Color(0xFFF0FDFA)),
        _VitalTile('BP',         '120/80','',      Icons.monitor_heart_outlined,  Color(0xFF6366F1), Color(0xFFEEF2FF)),
      ],
    ),
    const SizedBox(height: 10),

    // Hydration AI banner
    Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kTeal.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.water_drop_rounded, color: _kTeal, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Hydration AI',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
          const SizedBox(height: 2),
          const Text('You need +450ml water due to high temp.',
              style: TextStyle(fontSize: 11, color: Color(0xFF0F766E), height: 1.3)),
        ])),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => _waterLogged = !_waterLogged),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _waterLogged ? _kTeal.withValues(alpha: 0.15) : _kTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _waterLogged ? 'Logged ✓' : 'Log\nWater',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _waterLogged ? _kTeal : Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ),
      ]),
    ),
    const SizedBox(height: 14),

    // 24h Heart Rate Trend
    Row(children: [
      const Text('24h Heart Rate Trend',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kGray900)),
      const Spacer(),
      const Text('Peak: 102 BPM',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kRed)),
    ]),
    const SizedBox(height: 10),
    SizedBox(
      height: 100,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                interval: 6,
                getTitlesWidget: (val, _) {
                  final labels = {0.0: '12 AM', 6.0: '6 AM', 12.0: '12 PM', 18.0: '6 PM', 24.0: 'Now'};
                  return Text(labels[val] ?? '',
                      style: const TextStyle(fontSize: 9, color: _kGray500));
                },
              ),
            ),
          ),
          minX: 0, maxX: 24,
          minY: 40, maxY: 120,
          lineBarsData: [
            LineChartBarData(
              spots: _hrPoints,
              isCurved: true,
              curveSmoothness: 0.35,
              color: _kRed,
              barWidth: 2.2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [_kRed.withValues(alpha: 0.18), _kRed.withValues(alpha: 0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ]);

  // ── INSIGHTS TAB ─────────────────────────────────────────────────────────
  Widget _buildInsights() => Column(children: [
    _insightCard(Icons.bedtime_rounded, 'Sleep Quality', 'You averaged 7.2h this week — 94% sleep efficiency.', const Color(0xFF6366F1), const Color(0xFFEEF2FF)),
    const SizedBox(height: 8),
    _insightCard(Icons.directions_walk_rounded, 'Activity Score', 'Daily step goal met 5/7 days. Avg 8,400 steps.', const Color(0xFF10B981), const Color(0xFFF0FDF4)),
    const SizedBox(height: 8),
    _insightCard(Icons.favorite_rounded, 'Heart Health', 'Resting HR trending down — good cardiovascular signal.', _kRed, const Color(0xFFFFF1F2)),
    const SizedBox(height: 8),
    _insightCard(Icons.psychology_outlined, 'Stress Index', 'Low stress detected. HRV above your personal baseline.', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
  ]);

  Widget _insightCard(IconData icon, String title, String body, Color color, Color bg) =>
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 3),
          Text(body, style: const TextStyle(fontSize: 11, color: _kGray500, height: 1.4)),
        ])),
      ]),
    );

  // ── GUARD TAB ────────────────────────────────────────────────────────────
  Widget _buildGuard() => Column(children: [
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
      ),
      child: const Row(children: [
        Icon(Icons.shield_rounded, color: Color(0xFF22C55E), size: 24),
        SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Guard Active', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
          SizedBox(height: 2),
          Text('Monitoring 6 vitals in real-time. No anomalies detected.', style: TextStyle(fontSize: 11, color: Color(0xFF166534), height: 1.4)),
        ])),
      ]),
    ),
    const SizedBox(height: 10),
    ...[
      ('Heart Rate Threshold', '> 130 BPM alert', Icons.favorite_rounded, const Color(0xFFEF4444)),
      ('SpO2 Drop Alert',      '< 92% notify',    Icons.water_drop_outlined, const Color(0xFF0EA5E9)),
      ('Fall Detection',       'Motion-based',    Icons.personal_injury_outlined, const Color(0xFFF97316)),
      ('Inactivity Alert',     '> 2h no movement', Icons.directions_walk_rounded, const Color(0xFF8B5CF6)),
    ].map((g) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kGray200),
      ),
      child: Row(children: [
        Icon(g.$3, color: g.$4, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(g.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kGray900)),
          Text(g.$2, style: const TextStyle(fontSize: 11, color: _kGray500)),
        ])),
        Container(
          width: 10, height: 10,
          decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
        ),
      ]),
    )),
  ]);
}

// ─── Vital Tile ───────────────────────────────────────────────────────────────
class _VitalTile extends StatelessWidget {
  final String label, val, unit;
  final IconData icon;
  final Color color, bg;
  const _VitalTile(this.label, this.val, this.unit, this.icon, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.15)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Flexible(child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color), overflow: TextOverflow.ellipsis)),
      ]),
      const SizedBox(height: 5),
      RichText(text: TextSpan(
        children: [
          TextSpan(text: val,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          if (unit.isNotEmpty)
            TextSpan(text: ' $unit',
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        ],
      )),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
class WearableIntegrationScreen extends StatefulWidget {
  const WearableIntegrationScreen({super.key});
  @override
  State<WearableIntegrationScreen> createState() => _WearableIntegrationScreenState();
}

class _WearableIntegrationScreenState extends State<WearableIntegrationScreen> {
  final _connected = {
    'Fitbit Versa 4': true,
    'Apple Watch Series 9': false,
    'Samsung Galaxy Watch 6': false,
    'Garmin Forerunner 265': false,
  };

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Wearable Sync',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Connected device card
          if (_connected['Fitbit Versa 4']!)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3))),
              child: Row(children: [
                const Icon(Icons.watch_rounded, color: Color(0xFF10B981), size: 28),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Fitbit Versa 4', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text('Connected · Last sync: 2 min ago', style: TextStyle(fontSize: 11, color: Color(0xFF10B981))),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Text('Active', style: TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w600))),
              ]),
            ),
          // Live metrics from wearable
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.5,
            children: const [
              _MetricTile('Heart Rate', '72 BPM', Icons.favorite_rounded, Color(0xFFEF4444)),
              _MetricTile('Steps Today', '6,842', Icons.directions_walk_rounded, Color(0xFF10B981)),
              _MetricTile('Calories', '1,240 kcal', Icons.local_fire_department_rounded, Color(0xFFF59E0B)),
              _MetricTile('Sleep', '7h 12m', Icons.bedtime_rounded, Color(0xFF6366F1)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Other Devices', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ..._connected.entries.where((e) => !e.value).map((e) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              const Icon(Icons.watch_rounded, color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
              GestureDetector(
                onTap: () => setState(() => _connected[e.key] = true),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(20)), child: const Text('Connect', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
              ),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label, val; final IconData icon; final Color color;
  const _MetricTile(this.label, this.val, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 6),
      Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    ]),
  );
}
