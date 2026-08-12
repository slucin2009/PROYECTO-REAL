import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_fix/models/maintenance_report.dart';
import 'package:campus_fix/services/firestore_service.dart';

final _maintenanceReportProvider = FutureProvider.family<MaintenanceReport?, String>((ref, id) {
  return FirestoreService.instance.fetchMaintenanceReportById(id);
});

class MaintenanceDetailsScreen extends ConsumerWidget {
  final String reportId;
  final bool studentMode;

  const MaintenanceDetailsScreen({super.key, required this.reportId, required this.studentMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(_maintenanceReportProvider(reportId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del reporte')),
      body: reportAsync.when(
        data: (report) {
          if (report == null) {
            return const Center(child: Text('Reporte no encontrado.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(report.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(report.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('Estado: ${report.status}')),
                    Chip(label: Text('Prioridad: ${report.priority}')),
                    Chip(label: Text('Categoría: ${report.category}')),
                    Chip(label: Text('Ubicación: ${report.location}')),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Aula / Sector: ${report.classroom}'),
                const SizedBox(height: 8),
                Text('Código: ${report.code}'),
                const SizedBox(height: 8),
                const Text('Publicado por autoridad'),
                const SizedBox(height: 8),
                Text('Creado: ${report.createdAt.toLocal().toString().split(' ')[0]}'),
                const Spacer(),
                if (!studentMode)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop('changeStatus');
                          },
                          child: const Text('Cambiar estado'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop('delete');
                          },
                          child: const Text('Eliminar'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint('Firestore error: $error');
          return const Center(child: Text('No se pudo cargar el reporte.'));
        },
      ),
    );
  }
}
