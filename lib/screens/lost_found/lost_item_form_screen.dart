import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_fix/models/app_user.dart';
import 'package:campus_fix/models/lost_item.dart';
import 'package:campus_fix/services/firestore_service.dart';
import 'package:uuid/uuid.dart';
import 'package:campus_fix/widgets/app_button.dart';

class LostItemFormScreen extends ConsumerStatefulWidget {
  final LostItem? item;
  final AppUser? currentUser;

  const LostItemFormScreen({super.key, this.item, this.currentUser});

  @override
  ConsumerState<LostItemFormScreen> createState() => _LostItemFormScreenState();
}

class _LostItemFormScreenState extends ConsumerState<LostItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;
  List<VerificationQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _titleController.text = item.title;
      _questions = List.from(item.verificationQuestions);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final item = LostItem(
        id: widget.item?.id ?? '',
        title: _titleController.text.trim(),
        userId: widget.currentUser?.id ?? '',
        status: widget.item?.status ?? 'Pendiente',
        withdrawnBy: widget.item?.withdrawnBy,
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        verificationQuestions: _questions,
      );

      if (widget.item == null) {
        await FirestoreService.instance.createLostItem(item);
      } else {
        await FirestoreService.instance.updateLostItem(item);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.item == null ? 'Objeto creado correctamente.' : 'Objeto actualizado correctamente.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint('Firestore error: $error');
      setState(() {
        _errorMessage = 'No se pudo guardar el objeto. Intenta nuevamente.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item == null ? 'Crear objeto' : 'Editar objeto';

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
                decoration: const InputDecoration(labelText: 'Nombre del objeto *'),
                validator: (value) => value == null || value.isEmpty ? 'Ingresa el nombre del objeto.' : null,
              ),
              const SizedBox(height: 24),
              const Text('Preguntas de verificación (opcionales)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('${_questions.length}/4 preguntas agregadas', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              for (var i = 0; i < _questions.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: _questions[i].question,
                              decoration: const InputDecoration(labelText: 'Pregunta'),
                              validator: (v) => v == null || v.isEmpty ? 'La pregunta no puede estar vacía.' : null,
                              onChanged: (v) => setState(() => _questions[i] = VerificationQuestion(id: _questions[i].id, question: v, answer: _questions[i].answer)),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _questions[i].answer,
                              decoration: const InputDecoration(labelText: 'Respuesta correcta'),
                              validator: (v) => v == null || v.isEmpty ? 'La respuesta no puede estar vacía.' : null,
                              onChanged: (v) => setState(() => _questions[i] = VerificationQuestion(id: _questions[i].id, question: _questions[i].question, answer: v)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => setState(() => _questions.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              if (_questions.length < 4)
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar pregunta'),
                      onPressed: () => setState(() => _questions = List.from(_questions)..add(VerificationQuestion(id: const Uuid().v4(), question: '', answer: ''))),
                    ),
                  ],
                ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              AppButton(label: widget.item == null ? 'Crear' : 'Actualizar', onPressed: _saveItem, isLoading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}
