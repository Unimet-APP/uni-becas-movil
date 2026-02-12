import 'package:flutter/material.dart';

import '../../../models/career.dart';
import '../../../services/api_client.dart';
import '../../../utils/constants.dart';
import 'career_detail_screen.dart';

class CareerListScreen extends StatefulWidget {
  const CareerListScreen({super.key});

  @override
  State<CareerListScreen> createState() => _CareerListScreenState();
}

class _CareerListScreenState extends State<CareerListScreen> {
  final ApiClient _api = ApiClient();
  late Future<List<Career>> _futureCareers;

  List<Career> _all = [];
  List<Career> _filtered = [];
  String _query = '';
  String? _selectedFaculty;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureCareers = _fetchCareers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Career>> _fetchCareers() async {
    // React uses limit=200 to fetch the full catalog in one request
    final response = await _api.dio.get('/careers', queryParameters: {'limit': 200});
    final data = response.data;
    List<dynamic> raw;
    if (data is List) {
      raw = data;
    } else if (data is Map && data['data'] is List) {
      // Paginated: { data: [...], total: N, page: 1, ... }
      raw = data['data'] as List;
    } else {
      raw = [];
    }
    final careers = raw
        .map((e) => Career.fromJson(e as Map<String, dynamic>))
        .where((c) => c.isActive)
        .toList();
    _all = careers;
    _applyFilter();
    return careers;
  }

  void _applyFilter() {
    final q = _query.toLowerCase();
    setState(() {
      _filtered = _all.where((c) {
        final matchQuery = q.isEmpty ||
            c.name.toLowerCase().contains(q) ||
            c.faculty.toLowerCase().contains(q) ||
            (c.area ?? '').toLowerCase().contains(q);
        final matchFaculty =
            _selectedFaculty == null || c.faculty == _selectedFaculty;
        return matchQuery && matchFaculty;
      }).toList();
    });
  }

  void _onSearch(String value) {
    _query = value;
    _applyFilter();
  }

  void _onFacultySelected(String? faculty) {
    _selectedFaculty = faculty;
    _applyFilter();
  }

  List<String> get _faculties {
    final set = <String>{};
    for (final c in _all) {
      set.add(c.faculty);
    }
    return set.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar carreras'),
      ),
      body: FutureBuilder<List<Career>>(
        future: _futureCareers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              error: snapshot.error.toString(),
              onRetry: () => setState(() => _futureCareers = _fetchCareers()),
            );
          }

          return Column(
            children: [
              _SearchBar(
                controller: _searchController,
                onChanged: _onSearch,
              ),
              if (_faculties.isNotEmpty)
                _FacultyChips(
                  faculties: _faculties,
                  selected: _selectedFaculty,
                  onSelected: _onFacultySelected,
                ),
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(child: Text('No se encontraron carreras.'))
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            _query = '';
                            _selectedFaculty = null;
                            _searchController.clear();
                            _futureCareers = _fetchCareers();
                          });
                          await _futureCareers;
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _CareerCard(career: _filtered[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o facultad…',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class _FacultyChips extends StatelessWidget {
  final List<String> faculties;
  final String? selected;
  final ValueChanged<String?> onSelected;
  const _FacultyChips(
      {required this.faculties,
      required this.selected,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Todas'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          ...faculties.map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f, overflow: TextOverflow.ellipsis),
                  selected: selected == f,
                  onSelected: (v) => onSelected(v ? f : null),
                ),
              )),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 40),
          const SizedBox(height: 12),
          const Text('No se pudieron cargar las carreras',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(error,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ]),
      ),
    );
  }
}

class _CareerCard extends StatelessWidget {
  final Career career;
  const _CareerCard({required this.career});

  @override
  Widget build(BuildContext context) {
    final areaOrFaculty =
        career.area?.isNotEmpty == true ? career.area! : career.faculty;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CareerDetailScreen(career: career)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book_outlined,
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(career.name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(areaOrFaculty,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  if ((career.modality ?? '').isNotEmpty ||
                      (career.duration ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      if ((career.modality ?? '').isNotEmpty) ...[
                        const Icon(Icons.schedule,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(career.modality!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                      if ((career.modality ?? '').isNotEmpty &&
                          (career.duration ?? '').isNotEmpty)
                        const SizedBox(width: 12),
                      if ((career.duration ?? '').isNotEmpty) ...[
                        const Icon(Icons.timelapse,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${career.duration} años',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ]),
                  ],
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
