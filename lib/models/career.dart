import 'dart:convert';

class Career {
  final int id;
  final String name;
  final String faculty;
  final String? code;
  final String? area;
  final String? description;
  final String? profile;
  final String? jobField;
  final String? duration;
  final String? modality;
  final bool isActive;

  Career({
    required this.id,
    required this.name,
    required this.faculty,
    this.code,
    this.area,
    this.description,
    this.profile,
    this.jobField,
    this.duration,
    this.modality,
    required this.isActive,
  });

  factory Career.fromJson(Map<String, dynamic> json) {
    return Career(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      faculty: (json['faculty'] ?? '').toString(),
      code: json['code']?.toString(),
      area: json['area']?.toString(),
      description: json['description']?.toString(),
      profile: json['profile']?.toString(),
      jobField: json['job_field']?.toString(),
      duration: json['duration']?.toString(),
      modality: json['modality']?.toString(),
      // Support is_active (snake) and isActive (camel); default true if absent
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : json['isActive'] is bool
              ? json['isActive'] as bool
              : json['is_active'] != null
                  ? (json['is_active'].toString() == 'true' || json['is_active'] == 1)
                  : json['isActive'] != null
                      ? (json['isActive'].toString() == 'true' || json['isActive'] == 1)
                      : true, // absent → assume active
    );
  }

  static List<Career> listFromJsonString(String body) {
    final dynamic data = jsonDecode(body);
    if (data is List) {
      return data
          .map((e) => Career.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map && data['data'] is List) {
      // por si el backend envía { data: [...] }
      return (data['data'] as List)
          .map((e) => Career.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
