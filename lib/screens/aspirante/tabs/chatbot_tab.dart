import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class ChatbotTab extends StatelessWidget {
  const ChatbotTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7C3AED),
                  const Color(0xFF7C3AED).withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.psychology, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Chatbot Vocacional',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Consulta con nuestra IA sobre tus intereses vocacionales y obtiene recomendaciones personalizadas.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tabs simulados
          _buildFeatureCard(
            title: 'Chat de Orientacion',
            description:
                'Conversa con nuestro asistente de IA para explorar tus intereses y recibir orientacion personalizada.',
            icon: Icons.chat_bubble_outline,
            color: const Color(0xFF7C3AED),
            onTap: () {
              // TODO: Implementar pantalla de chat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat - Proximamente')),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            title: 'Consulta LLM',
            description:
                'Realiza consultas especificas sobre carreras, perfiles y opciones academicas.',
            icon: Icons.question_answer_outlined,
            color: AppColors.info,
            onTap: () {
              // TODO: Implementar consulta LLM
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Consulta LLM - Proximamente')),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            title: 'Recomendaciones de Carrera',
            description:
                'Visualiza recomendaciones de carreras basadas en tu perfil, tests e intereses.',
            icon: Icons.school_outlined,
            color: AppColors.success,
            onTap: () {
              // TODO: Implementar recomendaciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Recomendaciones - Proximamente')),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
