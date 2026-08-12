import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_fix/models/app_user.dart';
import 'package:campus_fix/models/maintenance_report.dart';
import 'package:campus_fix/services/firestore_service.dart';
import 'package:campus_fix/widgets/app_button.dart';

class MaintenanceReportFormScreen extends ConsumerStatefulWidget {
  final MaintenanceReport? report;
  final AppUser? currentUser;
  final String? studentSessionId;

  const MaintenanceReportFormScreen({super.key, this.report, this.currentUser, this.studentSessionId});

  @override
  ConsumerState<MaintenanceReportFormScreen> createState() => _MaintenanceReportFormScreenState();
}

class _MaintenanceReportFormScreenState extends ConsumerState<MaintenanceReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _classroomController = TextEditingController();
  String _category = 'Otros';
  String _priority = 'Media';
  bool _loading = false;
  String? _errorMessage;

  final _categories = ['Electricidad', 'Agua', 'Internet', 'Mobiliario', 'Limpieza', 'Infraestructura', 'Otros'];
  final _priorities = ['Baja', 'Media', 'Alta', 'Urgente'];

  @override
  void initState() {
    super.initState();
    final report = widget.report;
    if (report != null) {
      _titleController.text = report.title;
      _descriptionController.text = report.description;
      _locationController.text = report.location;
      _classroomController.text = report.classroom;
      _category = report.category;
      _priority = report.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _classroomController.dispose();
    super.dispose();
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final userId = widget.currentUser?.id ?? widget.studentSessionId ?? '';
      final report = MaintenanceReport(
        id: widget.report?.id ?? '',
        code: widget.report?.code ?? 'REP-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        location: _locationController.text.trim(),
        classroom: _classroomController.text.trim(),
        priority: _priority,
        status: widget.report?.status ?? 'Pendiente',
        imageUrl: '',
        userId: userId,
        createdAt: widget.report?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.report == null) {
        await FirestoreService.instance.createMaintenanceReport(report);
      } else {
        await FirestoreService.instance.updateMaintenanceReport(report);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.report == null ? 'Reporte enviado correctamente.' : 'Reporte actualizado correctamente.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint('Firestore error: $error');
      setState(() {
        _errorMessage = 'No se pudo guardar el reporte. Intenta nuevamente.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.report == null ? 'Nuevo reporte' : 'Editar reporte';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa un título.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 4,
                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa una descripción.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa la ubicación.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classroomController,
                decoration: const InputDecoration(labelText: 'Aula / sector'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                items: _priorities.map((priority) => DropdownMenuItem(value: priority, child: Text(priority))).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
                decoration: const InputDecoration(labelText: 'Prioridad'),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 16),
              ],
              AppButton(label: widget.report == null ? 'Guardar' : 'Actualizar', onPressed: _saveReport, isLoading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}
