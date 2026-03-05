// ─── Patient Profile Model ─────────────────────────────────────────────────
// Mirrors PatientProfile interface from health-twin/services/backendService.ts
// and /api/profile response shape exactly.

class PatientProfile {
  final String name;
  final int? age;
  final String? gender;
  final double? weightKg;
  final double? heightCm;
  final String? bloodType;
  final List<String>? conditions;
  final List<String>? medications;
  final String? createdAt;
  final String? updatedAt;

  const PatientProfile({
    required this.name,
    this.age,
    this.gender,
    this.weightKg,
    this.heightCm,
    this.bloodType,
    this.conditions,
    this.medications,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) => PatientProfile(
        name:       json['name']      as String,
        age:        json['age']       as int?,
        gender:     json['gender']    as String?,
        weightKg:   (json['weightKg']  as num?)?.toDouble(),
        heightCm:   (json['heightCm']  as num?)?.toDouble(),
        bloodType:  json['bloodType']  as String?,
        conditions:  (json['conditions']  as List?)?.cast<String>(),
        medications: (json['medications'] as List?)?.cast<String>(),
        createdAt:  json['createdAt'] as String?,
        updatedAt:  json['updatedAt'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name':       name,
        if (age       != null) 'age':        age,
        if (gender    != null) 'gender':     gender,
        if (weightKg  != null) 'weightKg':   weightKg,
        if (heightCm  != null) 'heightCm':   heightCm,
        if (bloodType != null) 'bloodType':  bloodType,
        if (conditions  != null) 'conditions':  conditions,
        if (medications != null) 'medications': medications,
      };
}

// ─── User Profile (for AI Health Passport) ─────────────────────────────────
// Mirrors UserProfile from ai-health-passport/types.ts

class UserProfile {
  final String name;
  final String id;
  final String dob;
  final String photoUrl;

  const UserProfile({
    required this.name,
    required this.id,
    required this.dob,
    required this.photoUrl,
  });

  UserProfile copyWith({String? name, String? id, String? dob, String? photoUrl}) =>
      UserProfile(
        name:     name     ?? this.name,
        id:       id       ?? this.id,
        dob:      dob      ?? this.dob,
        photoUrl: photoUrl ?? this.photoUrl,
      );
}
