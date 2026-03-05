// ─── VitalCard Widget ────────────────────────────────────────────────────────
// Flutter port of health-twin/components/VitalCard.tsx
// Displays a single real-time vital with a sparkline area chart (fl_chart).

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants/app_colors.dart';
import '../models/vitals.dart';

class VitalCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String subLabel;
  final List<double> history;
  final Color color;
  final IconData icon;
  final bool isNormal;
  final List<VitalMarker> markers;

  const VitalCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.subLabel,
    required this.history,
    required this.color,
    required this.icon,
    this.isNormal = true,
    this.markers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.twinSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNormal
              ? color.withValues(alpha: 0.2)
              : AppColors.errorRed.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.twinMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isNormal ? color : AppColors.errorRed,
                  boxShadow: [
                    BoxShadow(
                      color: (isNormal ? color : AppColors.errorRed)
                          .withValues(alpha: 0.7),
                      blurRadius: 4,
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Value ────────────────────────────────────────────────────────────
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isNormal ? Colors.white : AppColors.errorRed,
                    fontFamily: 'Inter',
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.twinMuted,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Text(
            subLabel,
            style: const TextStyle(fontSize: 10, color: AppColors.twinMuted),
          ),
          const SizedBox(height: 8),

          // ── Sparkline ────────────────────────────────────────────────────────
          SizedBox(
            height: 40,
            child: history.length < 2
                ? const SizedBox()
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minY: history.reduce((a, b) => a < b ? a : b) * 0.95,
                      maxY: history.reduce((a, b) => a > b ? a : b) * 1.05,
                      lineBarsData: [
                        LineChartBarData(
                          spots: history
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: color,
                          barWidth: 1.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                      lineTouchData: const LineTouchData(enabled: false),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
