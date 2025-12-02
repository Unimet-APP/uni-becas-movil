import 'package:flutter/material.dart';
import 'postulaciones/postulaciones_main_screen.dart';

class PostulacionesScreen extends StatelessWidget {
  final String tipo;

  const PostulacionesScreen({
    super.key,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    // Redirigir directamente a la pantalla principal de postulaciones
    return const PostulacionesMainScreen();
  }
}
