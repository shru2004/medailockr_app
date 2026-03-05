// ─── AI Insight Model ─────────────────────────────────────────────────────
// Mirrors the AIInsight interface from health-twin/types.ts
// and /api/insights payload shape exactly.

import 'alert.dart';

class AIInsight {
  final String status;           // 'optimal' | 'moderate' | 'critical'
  final String message;
  final double confidence;
  final String? analysis;
  final List<String>? correlations;
  final List<String>? immediateActions;
  final List<String>? recommendations;
  final List<Alert>? alerts;
  final String? id;
  final String? createdAt;

  const AIInsight({
    required this.status,
    required this.message,
    required this.confidence,
    this.analysis,
    this.correlations,
    this.immediateActions,
    this.recommendations,
    this.alerts,
    this.id,
    this.createdAt,
  });

  factory AIInsight.fromJson(Map<String, dynamic> json) => AIInsight(
        status:           json['status']     as String,
        message:          json['message']    as String,
        confidence:       (json['confidence'] as num).toDouble(),
        analysis:         json['analysis']   as String?,
        correlations:     (json['correlations']     as List?)?.cast<String>(),
        immediateActions: (json['immediateActions']  as List?)?.cast<String>(),
        recommendations:  (json['recommendations']   as List?)?.cast<String>(),
        alerts: (json['alerts'] as List?)
            ?.map((e) => Alert.fromJson(e as Map<String, dynamic>))
            .toList(),
        id:        json['id']        as String?,
        createdAt: json['createdAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'status':     status,
        'message':    message,
        'confidence': confidence,
        if (analysis    != null) 'analysis':         analysis,
        if (correlations     != null) 'correlations':      correlations,
        if (immediateActions != null) 'immediateActions':  immediateActions,
        if (recommendations  != null) 'recommendations':   recommendations,
      };
}
