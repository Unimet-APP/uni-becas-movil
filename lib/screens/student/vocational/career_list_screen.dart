import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../models/career.dart';
import '../../../utils/constants.dart';
import 'career_detail_screen.dart';

class CareerListScreen extends StatefulWidget {
  const CareerListScreen({super.key});

  @override
  State<CareerListScreen> createState() => _CareerListScreenState();
}

class _CareerListScreenState extends State<CareerListScreen> {
  late Future<List<Career>> _futureCareers;

  @override
  void initState() {
    super.initState();
    _futureCareers = _fetchCareers();
  }

  Future<List<Career>> _fetchCareers() async {
    try {
      // Ajusta esta baseURL si ya tienes algo en constants.dart
      // Por ahora asumo que el backend está así en dev:
      const String baseUrl = 'http://localhost:3001/API';

      final uri = Uri.parse('$baseUrl/careers');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(uri);
      // Si en móvil más adelante quieres mandar token:
      // request.headers.add(HttpHeaders.authorizationHeader, 'Bearer $token');

      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException(
          'Error al cargar carreras: ${response.statusCode}',
          uri: uri,
        );
      }

      final body = await response.transform(utf8.decoder).join();
      final careers = Career.listFromJsonString(body);
      return careers;
    } catch (e) {
      debugPrint('Error cargando carreras: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar carreras'),
      ),
      body: FutureBuilder<List<Career>>(
        future: _futureCareers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(context, snapshot.error);
          }

          final careers = snapshot.data ?? [];

          if (careers.isEmpty) {
            return const Center(
              child: Text('No se encontraron carreras.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureCareers = _fetchCareers();
              });
              await _futureCareers;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: careers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final career = careers[index];
                return _CareerCard(career: career);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object? error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'No se pudieron cargar las carreras',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _futureCareers = _fetchCareers();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareerCard extends StatelessWidget {
  final Career career;

  const _CareerCard({
    required this.career,
  });

  @override
  Widget build(BuildContext context) {
    final areaOrFaculty =
        career.area?.isNotEmpty == true ? career.area! : career.faculty;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CareerDetailScreen(career: career),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.15),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    career.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    areaOrFaculty,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if ((career.modality ?? '').isNotEmpty ||
                      (career.duration ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if ((career.modality ?? '').isNotEmpty) ...[
                          const Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            career.modality!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if ((career.modality ?? '').isNotEmpty &&
                            (career.duration ?? '').isNotEmpty)
                          const SizedBox(width: 12),
                        if ((career.duration ?? '').isNotEmpty) ...[
                          const Icon(
                            Icons.timelapse,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${career.duration} años',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
