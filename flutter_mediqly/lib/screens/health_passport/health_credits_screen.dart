// ─── Health Credits Screen + Modal ───────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/page_wrapper.dart';

// ─── Public helper ────────────────────────────────────────────────────────────
void showHealthCreditsModal(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const _HealthCreditsModal(),
  );
}

// ─── Data classes ─────────────────────────────────────────────────────────────
class _Goal {
  final String label, pts;
  final IconData icon;
  final Color color;
  final bool done;
  final double progress;
  const _Goal(this.label, this.pts, this.icon, this.color, this.done, this.progress);
}

class _Rwrd {
  final String label;
  final int pts;
  final IconData icon;
  final Color color;
  const _Rwrd(this.label, this.pts, this.icon, this.color);
}

// ─── Health Credits Modal ─────────────────────────────────────────────────────
class _HealthCreditsModal extends StatefulWidget {
  const _HealthCreditsModal();
  @override
  State<_HealthCreditsModal> createState() => _HealthCreditsModalState();
}

class _HealthCreditsModalState extends State<_HealthCreditsModal> {
  bool _showRedeem = false;
  final Set<String> _claimed = {};

  static const _kBalance = 1250;
  static const _kNavy    = Color(0xFF2D3A8C);
  static const _kBlue    = Color(0xFF3B82F6);
  static const _kGray900 = Color(0xFF111827);
  static const _kGray500 = Color(0xFF6B7280);
  static const _kGray100 = Color(0xFFF3F4F6);
  static const _kGray200 = Color(0xFFE5E7EB);
  static const _kOrange  = Color(0xFFF97316);
  static const _kGreen   = Color(0xFF22C55E);

  static const _goals = [
    _Goal('10,000 Steps',  '+50',  Icons.show_chart_rounded,        _kOrange,            false, 0.6),
    _Goal('Log Meals',     '',     Icons.smartphone_rounded,         _kGray500,           true,  1.0),
    _Goal('Water Intake',  '+20',  Icons.water_drop_outlined,        Color(0xFF0EA5E9),   false, 0.4),
    _Goal('Sleep 8 hrs',   '+30',  Icons.bedtime_outlined,           Color(0xFF8B5CF6),   false, 0.7),
  ];

  static const _rewards = [
    _Rwrd('Gym Day Pass',        300, Icons.fitness_center_rounded,     Color(0xFFF97316)),
    _Rwrd('Telehealth Consult',  800, Icons.health_and_safety_outlined,  Color(0xFF3B82F6)),
    _Rwrd('Vitamin Pack',        150, Icons.medication_outlined,         Color(0xFF22C55E)),
    _Rwrd('Premium Calm App',    500, Icons.nightlight_round,            Color(0xFF8B5CF6)),
    _Rwrd('Organic Meal Kit',    450, Icons.eco_outlined,                Color(0xFF10B981)),
  ];

  Widget _tabBtn(String label, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? _kNavy : Colors.white70,
            )),
      ),
    ),
  );

  Widget _buildGoals() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Today's Goals",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kGray900)),
      const SizedBox(height: 10),
      Expanded(
        child: ListView(
          padding: EdgeInsets.zero,
          children: _goals.map((g) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kGray200),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: g.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(g.icon, size: 16, color: g.color),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(g.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kGray900)),
                  if (g.done) const Text('Completed', style: TextStyle(fontSize: 11, color: _kGray500)),
                ])),
                g.done
                    ? const Icon(Icons.check_circle_rounded, color: _kGreen, size: 20)
                    : Text(g.pts, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: g.color)),
              ]),
              if (!g.done) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: g.progress,
                    minHeight: 4,
                    backgroundColor: g.color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(g.color),
                  ),
                ),
              ],
            ]),
          )).toList(),
        ),
      ),
    ],
  );

  Widget _buildRedeem() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        GestureDetector(
          onTap: () => setState(() => _showRedeem = false),
          child: const Icon(Icons.chevron_left, size: 20, color: _kGray500),
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: Text('Redeem Rewards',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _kGray900)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _kBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('$_kBalance HC',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kBlue)),
        ),
      ]),
      const SizedBox(height: 10),
      Expanded(
        child: ListView(
          padding: EdgeInsets.zero,
          children: _rewards.map((r) {
            final claimed = _claimed.contains(r.label);
            final canAfford = _kBalance >= r.pts;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kGray200),
              ),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: r.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(r.icon, size: 20, color: r.color),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kGray900)),
                  Text('${r.pts} Credits', style: const TextStyle(fontSize: 11, color: _kGray500)),
                ])),
                const SizedBox(width: 8),
                claimed
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _kGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Claimed',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kGreen)),
                      )
                    : ElevatedButton(
                        onPressed: canAfford ? () => setState(() => _claimed.add(r.label)) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _kGray200,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('Claim',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
              ]),
            );
          }).toList(),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 370, maxHeight: 580),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Row(children: [
                const Expanded(
                  child: Text('Health Credits',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kGray900)),
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
              const SizedBox(height: 14),

              // ── Balance Card ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D3A8C), Color(0xFF3B50C4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('AVAILABLE BALANCE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                          letterSpacing: 1, color: Colors.white70)),
                  const SizedBox(height: 4),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$_kBalance',
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
                      SizedBox(width: 6),
                      Text('HC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      _tabBtn('History', !_showRedeem, () => setState(() => _showRedeem = false)),
                      _tabBtn('Redeem',   _showRedeem,  () => setState(() => _showRedeem = true)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 14),

              // ── Body ──────────────────────────────────────────────────
              Expanded(child: _showRedeem ? _buildRedeem() : _buildGoals()),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class HealthCreditsScreen extends StatelessWidget {
  const HealthCreditsScreen({super.key});

  static const _activities = [
    _Act('Morning Walk · 30 min', '+15 pts', Icons.directions_walk_rounded, Color(0xFF10B981)),
    _Act('Blood Pressure Logged', '+10 pts', Icons.monitor_heart_rounded, AppColors.primaryBlue),
    _Act('Medication Taken on Time', '+5 pts', Icons.medication_rounded, Color(0xFF8B5CF6)),
    _Act('Hydration Goal Met', '+8 pts', Icons.water_drop_rounded, Color(0xFF0EA5E9)),
    _Act('Sleep Log: 7.5 hrs', '+12 pts', Icons.bedtime_rounded, Color(0xFF6366F1)),
  ];

  static const _rewards = [
    _Reward('15% off Lab Tests', 200, Icons.science_rounded),
    _Reward('Free Doctor Consultation', 500, Icons.person_rounded),
    _Reward('₹100 Pharmacy Discount', 350, Icons.local_pharmacy_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Health Credits',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your Credits', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('1,240 pts', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Level: Silver · Next: Gold at 2000 pts', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('Recent Activity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ..._activities.map((a) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Row(children: [Icon(a.icon, color: a.color, size: 20), const SizedBox(width: 10), Expanded(child: Text(a.label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))), Text(a.pts, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: a.color))]),
          )),
          const SizedBox(height: 12),
          const Text('Rewards Store', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ..._rewards.map((r) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(r.icon, color: const Color(0xFF8B5CF6), size: 20)), const SizedBox(width: 10), Expanded(child: Text(r.label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(20)), child: Text('${r.pts} pts', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)))]),
          )),
        ]),
      ),
    );
  }
}

class _Act { final String label, pts; final IconData icon; final Color color; const _Act(this.label, this.pts, this.icon, this.color); }
class _Reward { final String label; final int pts; final IconData icon; const _Reward(this.label, this.pts, this.icon); }
