import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_fix/core/constants/app_strings.dart';
import 'package:campus_fix/models/maintenance_report.dart';
import 'package:campus_fix/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:campus_fix/services/firestore_service.dart';
import 'package:campus_fix/widgets/animated_list_item.dart';

final maintenanceReportsProvider = FutureProvider.autoDispose.family<List<MaintenanceReport>, (String?, bool)>((ref, params) {
  final (userId, studentMode) = params;
  final id = userId ?? 'estudiante_anonimo';
  final onlyMine = studentMode;
  return FirestoreService.instance.fetchMaintenanceReports(id, onlyMine: onlyMine);
});

final userNameProvider = FutureProvider.autoDispose.family<String, String>((ref, userId) async {
  return FirestoreService.instance.fetchUserNameOrId(userId);
});

class MaintenanceListScreen extends ConsumerWidget {
  final bool studentMode;
  final String? studentSessionId;

  const MaintenanceListScreen({
    super.key,
    required this.studentMode,
    this.studentSessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = studentMode
      ? (studentSessionId ?? 'estudiante_anonimo')
      : ref.watch(currentUserProvider).maybeWhen(data: (user) => user?.id, orElse: () => null);
    final reportsAsync = ref.watch(maintenanceReportsProvider((userId, studentMode)));

    return Scaffold(
      floatingActionButton: studentMode
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Nuevo reporte'),
              onPressed: () => _showReportDialog(context, ref),
            )
          : null,
      body: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return Center(child: Text(AppStrings.noDataMessage));
          }
          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(maintenanceReportsProvider((userId, studentMode)));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final report = reports[index];
                return AnimatedListItem(
                  index: index,
                  child: _MaintenanceReportCard(
                    report: report,
                    studentMode: studentMode,
                    userId: userId,
                    ref: ref,
                    context: context,
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: reports.length,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(AppStrings.errorGeneral)),
      ),
    );
  }

  Future<void> _showReportDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final classroomController = TextEditingController();
    String priority = 'Media';
    final formKey = GlobalKey<FormState>();
    final userId = studentSessionId ?? 'estudiante_anonimo';

    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reportar mantenimiento'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa un título.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 4,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa una descripción.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Lugar'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa el lugar.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: classroomController,
                    decoration: const InputDecoration(labelText: 'Aula / sector'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: priority,
                    items: const [
                      DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                      DropdownMenuItem(value: 'Media', child: Text('Media')),
                      DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                    ],
                    onChanged: (value) {
                      if (value != null) priority = value;
                    },
                    decoration: const InputDecoration(labelText: 'Prioridad'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    if (accepted != true) return;

    try {
      final report = MaintenanceReport(
        id: '',
        code: 'REP-${DateTime.now().millisecondsSinceEpoch}',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: 'General',
        location: locationController.text.trim(),
        classroom: classroomController.text.trim(),
        priority: priority,
        status: 'Pendiente',
        imageUrl: '',
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await FirestoreService.instance.createMaintenanceReport(report);
      // Refresh the provider so the new report appears immediately
      ref.invalidate(maintenanceReportsProvider((userId, true)));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte enviado correctamente.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo enviar el reporte.')));
    }
  }
}

class _MaintenanceReportCard extends ConsumerWidget {
  final MaintenanceReport report;
  final bool studentMode;
  final String? userId;
  final WidgetRef ref;
  final BuildContext context;

  const _MaintenanceReportCard({
    required this.report,
    required this.studentMode,
    required this.userId,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userNameAsync = studentMode
        ? const AsyncValue<String>.data('Estudiante')
        : ref.watch(userNameProvider(report.userId));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!studentMode)
                  Text(
                    report.code,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(report.description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            if (!studentMode)
              userNameAsync.when(
                data: (name) => Text(
                  'Reportado por: $name',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
                loading: () => const Text('Reportado por: Cargando...'),
                error: (_, __) => Text('Reportado por: ${report.userId}'),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _InfoChip(label: report.location, icon: Icons.location_on),
                _InfoChip(label: report.priority, icon: Icons.priority_high),
                _InfoChip(label: DateFormat.yMMMMd().add_Hm().format(report.createdAt.toLocal()), icon: Icons.schedule),
                if (!studentMode)
                  _StatusChip(
                    label: report.status,
                    icon: Icons.info_outline,
                    report: report,
                    userId: userId,
                    studentMode: studentMode,
                    ref: ref,
                    context: context,
                  ),
                if (studentMode)
                  _InfoChip(label: report.status, icon: Icons.info_outline),
              ],
            ),
            if (!studentMode) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Eliminar reporte',
                  onPressed: () => _showDeleteConfirmation(context, ref, report),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref, MaintenanceReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar reporte?'),
        content: const Text('Esta acción eliminará permanentemente el reporte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

        if (confirmed == true && context.mounted) {
      try {
        await FirestoreService.instance.deleteMaintenanceReport(report.id);
        if (!context.mounted) return;
        ref.invalidate(maintenanceReportsProvider((userId, studentMode)));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte eliminado correctamente.')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el reporte.')),
        );
      }
    }
  }
}

class _StatusChip extends ConsumerWidget {
  final String label;
  final IconData icon;
  final MaintenanceReport report;
  final String? userId;
  final bool studentMode;
  final WidgetRef ref;
  final BuildContext context;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.report,
    required this.userId,
    required this.studentMode,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      initialValue: label,
      onSelected: (newStatus) async {
        if (newStatus != label) {
          try {
            final updated = report.copyWith(status: newStatus);
            await FirestoreService.instance.updateMaintenanceReport(updated);
            if (context.mounted) {
              // Refresh después del cambio
              ref.invalidate(maintenanceReportsProvider((userId, studentMode)));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Estado actualizado correctamente.')),
              );
            }
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al actualizar el estado.')),
              );
            }
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Pendiente', child: Text('Pendiente')),
        const PopupMenuItem(value: 'En revisión', child: Text('En revisión')),
        const PopupMenuItem(value: 'Solucionado', child: Text('Solucionado')),
      ],
      child: Chip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
