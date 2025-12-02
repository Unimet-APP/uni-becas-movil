import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../utils/constants.dart';
import '../../models/postulacion.dart';
import '../../services/postulacion_service.dart';
import '../../services/configuracion_service.dart';
import '../../models/configuracion_beca.dart';

class UnifiedApplicationForm extends StatefulWidget {
  final String tipoBeca;
  final String? subtipoExcelencia;

  const UnifiedApplicationForm({
    super.key,
    required this.tipoBeca,
    this.subtipoExcelencia,
  });

  @override
  State<UnifiedApplicationForm> createState() => _UnifiedApplicationFormState();
}

class _UnifiedApplicationFormState extends State<UnifiedApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final PostulacionService _postulacionService = PostulacionService();
  final ConfiguracionService _configuracionService = ConfiguracionService();

  ConfiguracionBeca? _configuracion;
  bool _loadingConfig = true;

  // Controladores
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _iaaController = TextEditingController();
  final _promedioBachilleratoController = TextEditingController();
  final _asignaturasAprobadasController = TextEditingController();
  final _creditosInscritosController = TextEditingController();

  // Valores de selects
  String _tipoCedula = 'V';
  String? _estadoCivil;
  String? _tipoPostulante;
  String? _carrera;
  DateTime? _fechaNacimiento;

  // Opcionales expandidos
  bool _mostrarDatosOpcionales = false;

  // Archivos seleccionados
  Map<String, File> _archivosSeleccionados = {};

  // Loading
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConfiguracion();
  }

  Future<void> _loadConfiguracion() async {
    try {
      final config = await _configuracionService.getConfiguracion(widget.tipoBeca);
      setState(() {
        _configuracion = config;
        _loadingConfig = false;
      });
    } catch (e) {
      print('Error loading configuration: $e');
      setState(() {
        _loadingConfig = false;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _iaaController.dispose();
    _promedioBachilleratoController.dispose();
    _asignaturasAprobadasController.dispose();
    _creditosInscritosController.dispose();
    super.dispose();
  }

  List<String> _getDocumentosRequeridos() {
    // Si hay configuración con documentos requeridos, usarlos
    if (_configuracion != null && _configuracion!.documentosRequeridos.isNotEmpty) {
      return _configuracion!.documentosRequeridos;
    }

    // Fallback: documentos por defecto
    List<String> docs = [
      'Cédula de Identidad',
      'Histórico de Notas',
      'Flujograma de Carrera',
      'Plan de Carrera Avalado',
    ];

    if (widget.tipoBeca == 'Excelencia' || widget.tipoBeca == 'Ayudantía') {
      docs.add('Curriculum Vitae');
    }

    return docs;
  }

  String _getDocumentoLabel(String tipo) {
    // Los documentos ya vienen con su nombre descriptivo del backend
    return tipo;
  }

  Future<void> _seleccionarArchivo(String tipoDocumento) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        // Validar tamaño (10MB)
        if (fileSize > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El archivo no puede superar los 10MB'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        setState(() {
          _archivosSeleccionados[tipoDocumento] = file;
        });
      }
    } catch (e) {
      print('Error selecting file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _enviarPostulacion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar documentos requeridos
    final documentosRequeridos = _getDocumentosRequeridos();
    for (final doc in documentosRequeridos) {
      if (!_archivosSeleccionados.containsKey(doc)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falta el documento: ${_getDocumentoLabel(doc)}'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // PASO 1: Crear postulación
      final postulacion = Postulacion(
        nombre: _nombreController.text.trim(),
        cedula: '$_tipoCedula-${_cedulaController.text.trim()}',
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        fechaNacimiento: _fechaNacimiento!,
        estadoCivil: _estadoCivil!,
        tipoPostulante: _tipoPostulante!,
        carrera: _getCarreraNombre(_carrera!),
        tipoBeca: widget.tipoBeca,
        subtipoExcelencia: widget.subtipoExcelencia,
        trimestre: null,
        iaa: _iaaController.text.trim().isNotEmpty
            ? double.tryParse(_iaaController.text.trim())
            : null,
        promedioBachillerato: _promedioBachilleratoController.text.trim().isNotEmpty
            ? double.tryParse(_promedioBachilleratoController.text.trim())
            : null,
        asignaturasAprobadas: _asignaturasAprobadasController.text.trim().isNotEmpty
            ? int.tryParse(_asignaturasAprobadasController.text.trim())
            : null,
        creditosInscritos: _creditosInscritosController.text.trim().isNotEmpty
            ? int.tryParse(_creditosInscritosController.text.trim())
            : null,
      );

      final postulacionId = await _postulacionService.crearPostulacion(postulacion);

      // PASO 2: Subir documentos
      for (final entry in _archivosSeleccionados.entries) {
        await _postulacionService.subirDocumento(
          postulacionId,
          entry.key,
          entry.value,
        );
      }

      // PASO 3: Verificar documentos
      await _postulacionService.verificarDocumentos(postulacionId);

      setState(() => _isLoading = false);

      if (mounted) {
        // Mostrar diálogo de éxito
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 32),
                SizedBox(width: 12),
                Text('¡Postulación Exitosa!'),
              ],
            ),
            content: const Text(
              'Tu postulación ha sido enviada correctamente. Recibirás una notificación cuando sea revisada.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar diálogo
                  Navigator.of(context).pop(); // Volver a la pantalla anterior
                  Navigator.of(context).pop(); // Volver a postulaciones main
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar postulación: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getCarreraNombre(String carreraKey) {
    final carreras = {
      'ingenieria-sistemas': 'Ingeniería de Sistemas',
      'ingenieria-industrial': 'Ingeniería Industrial',
      'ingenieria-civil': 'Ingeniería Civil',
      'administracion': 'Administración de Empresas',
      'comunicacion': 'Comunicación Social',
      'psicologia': 'Psicología',
      'derecho': 'Derecho',
      'contaduria': 'Contaduría Pública',
    };
    return carreras[carreraKey] ?? carreraKey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Postular a ${widget.tipoBeca}${widget.subtipoExcelencia != null ? ' - ${widget.subtipoExcelencia}' : ''}',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loadingConfig
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando formulario...'),
                ],
              ),
            )
          : _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Enviando postulación...'),
                    ],
                  ),
                )
              : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // SECCIÓN 1: Datos Personales
                  _buildSectionHeader('Datos Personales', Icons.person),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Completo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: DropdownButtonFormField<String>(
                          value: _tipoCedula,
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'V', child: Text('V')),
                            DropdownMenuItem(value: 'E', child: Text('E')),
                          ],
                          onChanged: (value) {
                            setState(() => _tipoCedula = value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _cedulaController,
                          decoration: const InputDecoration(
                            labelText: 'Cédula',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.badge),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Campo requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Campo requerido';
                      if (!value!.contains('@')) return 'Email inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _fechaNacimiento = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Nacimiento',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _fechaNacimiento != null
                            ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _estadoCivil,
                    decoration: const InputDecoration(
                      labelText: 'Estado Civil',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.family_restroom),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'soltero', child: Text('Soltero/a')),
                      DropdownMenuItem(value: 'casado', child: Text('Casado/a')),
                      DropdownMenuItem(value: 'divorciado', child: Text('Divorciado/a')),
                      DropdownMenuItem(value: 'viudo', child: Text('Viudo/a')),
                      DropdownMenuItem(value: 'union-estable', child: Text('Unión Estable')),
                    ],
                    onChanged: (value) => setState(() => _estadoCivil = value),
                    validator: (value) => value == null ? 'Campo requerido' : null,
                  ),

                  const SizedBox(height: 32),

                  // SECCIÓN 2: Tipo de Postulante
                  _buildSectionHeader('Tipo de Postulante', Icons.school),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _tipoPostulante,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Postulante',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'estudiante-pregrado',
                        child: Text('Estudiante regular de pregrado'),
                      ),
                      DropdownMenuItem(
                        value: 'estudiante-postgrado',
                        child: Text('Estudiante de postgrado'),
                      ),
                      DropdownMenuItem(
                        value: 'estudiante-nuevo',
                        child: Text('Estudiante nuevo'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _tipoPostulante = value),
                    validator: (value) => value == null ? 'Campo requerido' : null,
                  ),

                  const SizedBox(height: 32),

                  // SECCIÓN 3: Datos Académicos
                  _buildSectionHeader('Datos Académicos', Icons.book),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _carrera,
                    decoration: const InputDecoration(
                      labelText: 'Carrera',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'ingenieria-sistemas',
                        child: Text('Ingeniería de Sistemas'),
                      ),
                      DropdownMenuItem(
                        value: 'ingenieria-industrial',
                        child: Text('Ingeniería Industrial'),
                      ),
                      DropdownMenuItem(
                        value: 'ingenieria-civil',
                        child: Text('Ingeniería Civil'),
                      ),
                      DropdownMenuItem(
                        value: 'administracion',
                        child: Text('Administración de Empresas'),
                      ),
                      DropdownMenuItem(
                        value: 'comunicacion',
                        child: Text('Comunicación Social'),
                      ),
                      DropdownMenuItem(
                        value: 'psicologia',
                        child: Text('Psicología'),
                      ),
                      DropdownMenuItem(
                        value: 'derecho',
                        child: Text('Derecho'),
                      ),
                      DropdownMenuItem(
                        value: 'contaduria',
                        child: Text('Contaduría Pública'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _carrera = value),
                    validator: (value) => value == null ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _promedioBachilleratoController,
                    decoration: const InputDecoration(
                      labelText: 'Promedio Bachillerato',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grade),
                      helperText: 'Escala 0-20',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_tipoPostulante == 'estudiante-nuevo' &&
                          (value?.isEmpty ?? true)) {
                        return 'Campo requerido para nuevos ingresos';
                      }
                      if (value != null && value.isNotEmpty) {
                        final val = double.tryParse(value);
                        if (val == null || val < 0 || val > 20) {
                          return 'Debe estar entre 0 y 20';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Datos opcionales expandibles
                  ExpansionTile(
                    title: const Text('Mostrar datos académicos opcionales'),
                    initiallyExpanded: _mostrarDatosOpcionales,
                    onExpansionChanged: (expanded) {
                      setState(() => _mostrarDatosOpcionales = expanded);
                    },
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _iaaController,
                              decoration: const InputDecoration(
                                labelText: 'IAA',
                                border: OutlineInputBorder(),
                                helperText: 'Escala 0-20',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _asignaturasAprobadasController,
                              decoration: const InputDecoration(
                                labelText: 'Asignaturas Aprobadas',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _creditosInscritosController,
                              decoration: const InputDecoration(
                                labelText: 'Créditos Inscritos',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // SECCIÓN 4: Documentos
                  _buildSectionHeader('Documentos Requeridos', Icons.upload_file),
                  const SizedBox(height: 8),
                  Text(
                    'PDF, JPG, PNG (máx. 10MB)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  ..._getDocumentosRequeridos().map((doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildDocumentoPicker(doc),
                      )),

                  const SizedBox(height: 16),

                  // Documentos seleccionados
                  if (_archivosSeleccionados.isNotEmpty) ...[
                    Text(
                      '✓ Documentos Seleccionados (${_archivosSeleccionados.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: _archivosSeleccionados.entries.map((entry) {
                          final fileName = entry.value.path.split('/').last;
                          final fileSize =
                              (entry.value.lengthSync() / 1024 / 1024).toStringAsFixed(2);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.description,
                                    color: AppColors.success, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_getDocumentoLabel(entry.key)} - $fileName ($fileSize MB)',
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _archivosSeleccionados.remove(entry.key);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _enviarPostulacion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Enviar Postulación'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentoPicker(String tipoDocumento) {
    final hasFile = _archivosSeleccionados.containsKey(tipoDocumento);

    return OutlinedButton.icon(
      onPressed: () => _seleccionarArchivo(tipoDocumento),
      icon: Icon(
        hasFile ? Icons.check_circle : Icons.folder_open,
        color: hasFile ? AppColors.success : AppColors.primary,
      ),
      label: Text(_getDocumentoLabel(tipoDocumento)),
      style: OutlinedButton.styleFrom(
        foregroundColor: hasFile ? AppColors.success : AppColors.primary,
        side: BorderSide(
          color: hasFile ? AppColors.success : AppColors.primary,
          width: hasFile ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
