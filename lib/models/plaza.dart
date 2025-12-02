import 'horario.dart';
import 'user.dart';

class Plaza {
  final String id;
  final String nombre; // Cambiado de 'materia' a 'nombre'
  final String ubicacion;
  final int capacidad;
  final int ocupadas;
  final List<Horario> horario;
  final String estado;
  final String tipoAyudantia;
  final String descripcionActividades;
  final List<String> requisitosEspeciales;
  final int horasSemana;
  final String periodoAcademico;
  final String? fechaInicio;
  final String? fechaFin;
  final String? supervisorResponsable;
  final User? supervisor;
  final String disponibilidad;
  final int plazasDisponibles;
  final double porcentajeOcupacion;

  Plaza({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.capacidad,
    required this.ocupadas,
    required this.horario,
    required this.estado,
    required this.tipoAyudantia,
    required this.descripcionActividades,
    required this.requisitosEspeciales,
    required this.horasSemana,
    required this.periodoAcademico,
    this.fechaInicio,
    this.fechaFin,
    this.supervisorResponsable,
    this.supervisor,
    required this.disponibilidad,
    required this.plazasDisponibles,
    required this.porcentajeOcupacion,
  });

  // Getters de conveniencia para compatibilidad
  String get materia => nombre;
  String get codigo => nombre; // Ya que el API no tiene código separado
  String get departamento => supervisor?.departamento ?? '';
  String get profesor => supervisor?.fullName ?? '';

  factory Plaza.fromJson(Map<String, dynamic> json) => Plaza(
        id: json['id'] ?? '',
        nombre: json['nombre'] ?? json['materia'] ?? '', // Soporta ambos campos
        ubicacion: json['ubicacion'] ?? '',
        capacidad: json['capacidad'] ?? 0,
        ocupadas: json['ocupadas'] ?? 0,
        horario: json['horario'] != null
            ? (json['horario'] as List)
                .map((h) => Horario.fromJson(h))
                .toList()
            : [],
        estado: json['estado'] ?? 'Inactiva',
        tipoAyudantia: json['tipoAyudantia'] ?? 'academica',
        descripcionActividades: json['descripcionActividades'] ?? '',
        requisitosEspeciales: json['requisitosEspeciales'] != null
            ? List<String>.from(json['requisitosEspeciales'])
            : [],
        horasSemana: json['horasSemana'] ?? 0,
        periodoAcademico: json['periodoAcademico'] ?? '',
        fechaInicio: json['fechaInicio'],
        fechaFin: json['fechaFin'],
        supervisorResponsable: json['supervisorResponsable'],
        supervisor: json['supervisor'] != null
            ? User.fromJson(json['supervisor'])
            : null,
        disponibilidad: json['disponibilidad'] ?? 'No Disponible',
        plazasDisponibles: json['plazasDisponibles'] ?? 0,
        porcentajeOcupacion:
            (json['porcentajeOcupacion'] ?? 0).toDouble(),
      );

  bool get isDisponible => plazasDisponibles > 0;
  bool get isActiva => estado == 'Activa';
}
