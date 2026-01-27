import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/supervisor_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/report_card.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SupervisorProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reportes Pendientes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.pendingReports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay reportes pendientes',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Todos los reportes han sido revisados',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: provider.pendingReports.length,
                  itemBuilder: (context, index) {
                    final report = provider.pendingReports[index];
                    return ReportCard(
                      report: report,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReportDetailScreen(report: report),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
