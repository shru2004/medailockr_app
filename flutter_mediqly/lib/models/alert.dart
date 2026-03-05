// ─── Alert Model ─────────────────────────────────────────────────────────
// Mirrors the Alert type from health-twin/types.ts
// and /api/alerts payload exactly.

class Alert {
  final String? id;
  final String type;        // 'warning' | 'info'
  final String title;
  final String description;
  final bool dismissed;
  final String source;
  final String? createdAt;

  const Alert({
    this.id,
    required this.type,
    required this.title,
    required this.description,
    this.dismissed = false,
    this.source = 'ai',
    this.createdAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        id:          json['id']   as String?,
        type:        json['type'] as String,
        title:       json['title'] as String,
        description: json['description'] as String,
        dismissed:   json['dismissed'] as bool? ?? false,
        source:      json['source'] as String? ?? 'ai',
        createdAt:   json['createdAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'type':        type,
        'title':       title,
        'description': description,
        'source':      source,
      };
}
