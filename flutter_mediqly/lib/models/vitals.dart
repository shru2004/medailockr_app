// ─── Vitals Model ─────────────────────────────────────────────────────────
// Mirrors the Vitals interface from health-twin/types.ts
// and the /api/vitals payload shape exactly.

class Vitals {
  final double heartRate;
  final double systolicBP;
  final double diastolicBP;
  final double respRate;
  final double temperature;
  final double oxygenSat;

  const Vitals({
    required this.heartRate,
    required this.systolicBP,
    required this.diastolicBP,
    required this.respRate,
    required this.temperature,
    required this.oxygenSat,
  });

  factory Vitals.initial() => const Vitals(
        heartRate: 72,
        systolicBP: 120,
        diastolicBP: 80,
        respRate: 16,
        temperature: 36.6,
        oxygenSat: 98,
      );

  factory Vitals.fromJson(Map<String, dynamic> json) => Vitals(
        heartRate:    (json['heartRate']    as num).toDouble(),
        systolicBP:   (json['systolicBP']   as num).toDouble(),
        diastolicBP:  (json['diastolicBP']  as num).toDouble(),
        respRate:     (json['respRate']     as num).toDouble(),
        temperature:  (json['temperature']  as num).toDouble(),
        oxygenSat:    (json['oxygenSat']    as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'heartRate':   heartRate,
        'systolicBP':  systolicBP,
        'diastolicBP': diastolicBP,
        'respRate':    respRate,
        'temperature': temperature,
        'oxygenSat':   oxygenSat,
      };

  Vitals copyWith({
    double? heartRate,
    double? systolicBP,
    double? diastolicBP,
    double? respRate,
    double? temperature,
    double? oxygenSat,
  }) =>
      Vitals(
        heartRate:   heartRate   ?? this.heartRate,
        systolicBP:  systolicBP  ?? this.systolicBP,
        diastolicBP: diastolicBP ?? this.diastolicBP,
        respRate:    respRate    ?? this.respRate,
        temperature: temperature ?? this.temperature,
        oxygenSat:   oxygenSat   ?? this.oxygenSat,
      );
}

// ─── VitalDataPoint ────────────────────────────────────────────────────────
// Mirrors VitalDataPoint interface from health-twin/components/VitalCard.tsx
enum VitalMarker { ai, critical, warning }

class VitalDataPoint {
  final double value;
  final VitalMarker? marker;

  const VitalDataPoint({required this.value, this.marker});
}
