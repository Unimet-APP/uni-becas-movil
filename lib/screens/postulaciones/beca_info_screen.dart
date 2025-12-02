import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/configuracion_service.dart';
import '../../models/configuracion_beca.dart';

class BecaInfoScreen extends StatefulWidget {
  final String tipoBeca;

  const BecaInfoScreen({super.key, required this.tipoBeca});

  @override
  State<BecaInfoScreen> createState() => _BecaInfoScreenState();
}

class _BecaInfoScreenState extends State<BecaInfoScreen> {
  final ConfiguracionService _configuracionService = ConfiguracionService();
  late Future<ConfiguracionBeca?> _configFuture;

  @override
  void initState() {
    super.initState();
    _configFuture = _configuracionService.getConfiguracion(widget.tipoBeca);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.tipoBeca),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Diseño de fondo moderno con líneas naranjas
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            painter: ModernLinesPainter(),
          ),

          // Contenido
          FutureBuilder<ConfiguracionBeca?>(
            future: _configFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final config = snapshot.data;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildContentByTipoBeca(widget.tipoBeca, config),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContentByTipoBeca(String tipoBeca, ConfiguracionBeca? config) {
    switch (tipoBeca) {
      case 'Ayudantía':
        return _buildAyudantiaContent(config);
      case 'Impacto':
        return _buildImpactoContent(config);
      case 'Excelencia':
        return _buildExcelenciaContent(config);
      case 'Exoneración de Pago de Matrícula para Estudios del Personal e Hijos':
        return _buildExoneracionContent(config);
      case 'Formación Docente':
        return _buildFormacionDocenteContent(config);
      default:
        return [
          Text(
            'Información de $tipoBeca\n\nPor el momento no hay información disponible.',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ];
    }
  }

  List<Widget> _buildAyudantiaContent(ConfiguracionBeca? config) {
    return [
      _buildSection(
        'Programa de Ayudantía',
        Icons.people,
        config?.requisitosEspeciales ??
        'El Programa Ayudantía facilita el intercambio de valor entre el estudiante beneficiario y las unidades académicas y administrativas de la Universidad mediante el desarrollo de actividades relacionadas con el plan estratégico de la institución.',
      ),
      _buildSubsection('Requisitos para Postular'),
      if (config != null)
        _buildBulletPoint('IAA mínimo de ${config.promedioMinimo} puntos')
      else ...[
        _buildBulletPoint('IAA mínimo de 12.00 puntos para estudiantes de pregrado'),
        _buildBulletPoint('IAA mínimo de 14.00 puntos para estudiantes de postgrado'),
      ],
      _buildBulletPoint('Disponer preferiblemente de una plaza de ayudantía activa'),
      _buildBulletPoint('Tener el perfil de competencias acordes con las actividades'),
      _buildBulletPoint('Realizar la entrevista de evaluación de competencias'),
      if (config != null && config.documentosRequeridos.isNotEmpty) ...[
        _buildSubsection('Documentos Requeridos'),
        ...config.documentosRequeridos.map((doc) => _buildBulletPoint(doc)),
      ],
      _buildSubsection('Condiciones de Mantenimiento'),
      _buildBulletPoint('Cumplir con 120 horas de intercambio de valor en trimestres regulares'),
      _buildBulletPoint('Cumplir a cabalidad con el plan de trabajo establecido por el supervisor'),
      _buildBulletPoint('Entregar reporte de actividades a la Dirección de Desarrollo y Bienestar Estudiantil'),
    ];
  }

  List<Widget> _buildImpactoContent(ConfiguracionBeca? config) {
    return [
      _buildSection(
        'Beca Impacto',
        Icons.trending_up,
        config?.requisitosEspeciales ??
        'Programa orientado a fomentar la democratización e inclusión de bachilleres, promoviendo la conformación de una población estudiantil diversa socialmente.',
      ),
      _buildSubsection('Requisitos'),
      _buildBulletPoint('Ser bachiller o estar cursando el último año de bachillerato'),
      if (config != null)
        _buildBulletPoint('Tener hasta ${config.edadMaxima} años cumplidos o por cumplir')
      else
        _buildBulletPoint('Tener hasta 21 años cumplidos o por cumplir'),
      if (config != null)
        _buildBulletPoint('Promedio de notas mínimo de ${config.promedioMinimo} puntos')
      else
        _buildBulletPoint('Promedio de notas del 1ro al 4to año mínimo de 15.00 puntos'),
      _buildBulletPoint('Presentar la Prueba Diagnóstica de Ubicación (PDU)'),
      if (config != null && config.documentosRequeridos.isNotEmpty) ...[
        _buildSubsection('Documentos Requeridos'),
        ...config.documentosRequeridos.map((doc) => _buildBulletPoint(doc)),
      ],
      _buildSubsection('Condiciones de Mantenimiento'),
      _buildBulletPoint('Inscribir y aprobar mínimo 15 créditos por trimestre'),
      if (config != null)
        _buildBulletPoint('Mantener IAA igual o superior a ${config.promedioMinimo} puntos')
      else
        _buildBulletPoint('Mantener IAA igual o superior a 12.00 puntos'),
      _buildBulletPoint('Participar en el acompañamiento integral'),
    ];
  }

  List<Widget> _buildExcelenciaContent(ConfiguracionBeca? config) {
    return [
      _buildSection(
        'Programa de Excelencia',
        Icons.emoji_events,
        config?.requisitosEspeciales ??
        'Beneficios dirigidos a estudiantes activos de pregrado y postgrado que logren destacarse en su desempeño académico, deportivo, artístico, compromiso cívico y en emprendimiento.',
      ),
      _buildSubsection('Tipologías de Becas'),
      _buildInfoCard(
        'Académica',
        'IAA igual o superior a 16.50 puntos (pregrado) o 18 puntos (postgrado)',
        Icons.menu_book,
      ),
      _buildInfoCard(
        'Deportiva',
        'Estudiantes de selecciones deportivas. IAA mínimo 15.00 puntos',
        Icons.sports_soccer,
      ),
      _buildInfoCard(
        'Artística',
        'Competencias en áreas artísticas. IAA mínimo 15.00 puntos',
        Icons.palette,
      ),
      _buildInfoCard(
        'Compromiso Cívico',
        'Impacto social destacado. IAA mínimo 15.00 puntos',
        Icons.volunteer_activism,
      ),
      _buildInfoCard(
        'Emprendimiento',
        'Iniciativas emprendedoras avaladas. IAA mínimo 15.00 puntos',
        Icons.lightbulb,
      ),
      if (config != null && config.documentosRequeridos.isNotEmpty) ...[
        _buildSubsection('Documentos Requeridos'),
        ...config.documentosRequeridos.map((doc) => _buildBulletPoint(doc)),
      ],
      _buildSubsection('Condiciones Generales'),
      _buildBulletPoint('Inscribir y aprobar mínimo 15 créditos en período regular'),
      _buildBulletPoint('Mantener IAA según tipología'),
      _buildBulletPoint('Acompañamiento integral obligatorio'),
    ];
  }

  List<Widget> _buildExoneracionContent(ConfiguracionBeca? config) {
    return [
      _buildSection(
        'Exoneración de Pago de Matrícula',
        Icons.payment,
        config?.requisitosEspeciales ??
        'Beneficio para el personal académico y administrativo de la Universidad Metropolitana, sus descendientes directos y personas dependientes de entidades vinculadas.',
      ),
      _buildSubsection('Beneficios Incluidos'),
      _buildBulletPoint('Costo de preinscripción'),
      _buildBulletPoint('Costo de inscripción de asignaturas'),
      _buildBulletPoint('Costo de emisión de constancias (hasta 2 por año)'),
      _buildBulletPoint('Costo de la PDU o CPES (una sola vez)'),
      _buildBulletPoint('Arancel de derecho de grado'),
      if (config != null && config.documentosRequeridos.isNotEmpty) ...[
        _buildSubsection('Documentos Requeridos'),
        ...config.documentosRequeridos.map((doc) => _buildBulletPoint(doc)),
      ],
      _buildSubsection('Condiciones de Mantenimiento'),
      if (config != null)
        _buildBulletPoint('IAA mínimo de ${config.promedioMinimo} puntos')
      else ...[
        _buildBulletPoint('IAA mínimo de 12.00 puntos para pregrado'),
        _buildBulletPoint('IAA mínimo de 14.00 puntos para postgrado'),
      ],
      _buildBulletPoint('Aprobar mínimo 12 asignaturas por año (pregrado)'),
      _buildBulletPoint('Asistir a tutorías de orientación'),
      _buildBulletPoint('Personal debe permanecer activo 2 años luego del acto de grado'),
    ];
  }

  List<Widget> _buildFormacionDocenteContent(ConfiguracionBeca? config) {
    return [
      _buildSection(
        'Beca Formación Docente',
        Icons.menu_book,
        config?.requisitosEspeciales ??
        'Programa dirigido a docentes en ejercicio para proporcionarles la oportunidad de desarrollar las competencias necesarias para alcanzar altos niveles de eficacia y eficiencia en su rol como educadores.',
      ),
      _buildSubsection('Requisitos'),
      _buildInfoText('Ser docente en ejercicio al momento de la postulación y mantener esta condición durante el proceso formativo.'),
      if (config != null && config.documentosRequeridos.isNotEmpty) ...[
        _buildSubsection('Documentos Requeridos'),
        ...config.documentosRequeridos.map((doc) => _buildBulletPoint(doc)),
      ],
      _buildSubsection('Condiciones de Mantenimiento'),
      if (config != null)
        _buildBulletPoint('IAA igual o superior a ${config.promedioMinimo} puntos')
      else
        _buildBulletPoint('IAA igual o superior a 14.00 puntos'),
      _buildBulletPoint('Cursar mínimo 5 asignaturas por trimestre'),
      _buildBulletPoint('No retirar asignaturas sin autorización'),
      _buildBulletPoint('Observar conducta ética profesional'),
      _buildBulletPoint('Participar en acompañamiento integral obligatorio'),
    ];
  }

  Widget _buildSection(String title, IconData icon, String description) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.heading2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubsection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4),
      child: Text(
        title,
        style: AppTextStyles.heading3,
      ),
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 18, color: AppColors.primary),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// Painter para las líneas de fondo modernas
class ModernLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.12)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Líneas diagonales en la parte superior derecha
    for (int i = 0; i < 5; i++) {
      final path = Path();
      path.moveTo(size.width * 0.6 + (i * 40), 0);
      path.lineTo(size.width + (i * 40), size.height * 0.3);
      canvas.drawPath(path, paint);
    }

    // Líneas horizontales sutiles en el medio
    for (int i = 0; i < 3; i++) {
      final y = size.height * 0.4 + (i * 60);
      final path = Path();
      path.moveTo(0, y);
      path.lineTo(size.width * 0.3, y);
      canvas.drawPath(path, paint);
    }

    // Líneas diagonales en la parte inferior izquierda
    for (int i = 0; i < 4; i++) {
      final path = Path();
      path.moveTo(0 - (i * 50), size.height * 0.7);
      path.lineTo(size.width * 0.4 - (i * 50), size.height);
      canvas.drawPath(path, paint);
    }

    // Líneas verticales sutiles a la derecha
    for (int i = 0; i < 2; i++) {
      final x = size.width * 0.85 + (i * 30);
      final path = Path();
      path.moveTo(x, size.height * 0.5);
      path.lineTo(x, size.height * 0.8);
      canvas.drawPath(path, paint);
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
