import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_fix/models/claim.dart';
import 'package:campus_fix/screens/claims/claims_screen.dart';
import 'package:intl/intl.dart';
import 'package:campus_fix/models/lost_item.dart';
import 'package:campus_fix/services/firestore_service.dart';
import 'package:campus_fix/widgets/app_button.dart';
import 'package:campus_fix/screens/lost_found/lost_item_form_screen.dart';
import 'package:campus_fix/providers/auth_provider.dart';

class LostItemDetailScreen extends ConsumerWidget {
  final String itemId;
  final bool studentMode;
  final String? studentSessionId;

  const LostItemDetailScreen({
    super.key,
    required this.itemId,
    required this.studentMode,
    this.studentSessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(_lostItemProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        toolbarHeight: 56,
      ),
      body: itemAsync.when(
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Objeto no encontrado.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(item.status),
                      backgroundColor: item.status == 'Entregado' ? Colors.grey : Colors.orange,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (item.withdrawnBy != null) ...[Text('Retirado por: ${item.withdrawnBy}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 12)],
                Text('Creado: ${DateFormat.yMMMMd().add_Hm().format(item.createdAt.toLocal())}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                if (item.verificationQuestions.isNotEmpty) ...[const Divider(), const SizedBox(height: 12), const Text('Preguntas de verificación', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), for (var q in item.verificationQuestions) ...[
                      Align(alignment: Alignment.centerLeft, child: Text('• ${q.question}', style: const TextStyle(fontSize: 14))),
                      const SizedBox(height: 8),
                    ], const SizedBox(height: 12)],
                const SizedBox(height: 16),
                if (studentMode && item.status == 'Pendiente')
                  AppButton(
                    label: 'Solicitar objeto',
                    onPressed: () async {
                      final userId = studentSessionId ?? 'estudiante_anonimo';
                      final formKey = GlobalKey<FormState>();
                      final questionControllers = <String, TextEditingController>{};
                      for (var q in item.verificationQuestions) {
                        questionControllers[q.id] = TextEditingController();
                      }

                      final accepted = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Solicitar objeto'),
                            content: SingleChildScrollView(
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Solicitar: ${item.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 16),
                                    if (item.verificationQuestions.isNotEmpty) ...[const Text('Responde las preguntas', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), for (var q in item.verificationQuestions) ...[
                                          Text(q.question),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: questionControllers[q.id],
                                            decoration: const InputDecoration(labelText: 'Tu respuesta'),
                                            validator: (v) => v == null || v.trim().isEmpty ? 'Respuesta requerida.' : null,
                                          ),
                                          const SizedBox(height: 12),
                                        ]
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')), ElevatedButton(onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                Navigator.of(context).pop(true);
                              }
                            }, child: const Text('Enviar solicitud'))],
                          );
                        },
                      );

                      if (accepted != true) return;

                      try {
                        final answers = item.verificationQuestions.map((q) => VerificationAnswer(questionId: q.id, answer: questionControllers[q.id]?.text.trim() ?? '')).toList();
                        final claim = Claim(
                          id: '',
                          lostItemId: item.id,
                          userId: userId,
                          status: 'Pendiente',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          verificationAnswers: answers,
                        );
                        await FirestoreService.instance.createClaim(claim);
                        ref.invalidate(claimsProvider((userId, true)));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada correctamente.')));
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar la solicitud.')));
                      }
                    },
                  )
                else
                  Row(
                    children: [
                      if (item.status == 'Pendiente')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final withdrawnByController = TextEditingController();
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Marcar como entregado'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [Text('¿A quién se entrega ${item.title}?'), const SizedBox(height: 12), TextFormField(controller: withdrawnByController, decoration: const InputDecoration(labelText: 'Nombre del estudiante'))],
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(withdrawnByController.text.isNotEmpty),
                                      child: const Text('Confirmar'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                try {
                                  await FirestoreService.instance.updateLostItem(item.copyWith(status: 'Entregado', withdrawnBy: withdrawnByController.text.trim()));
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Objeto marcado como entregado.')));
                                  Navigator.of(context).pop(true);
                                } catch (_) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar.')));
                                }
                              }
                            },
                            child: const Text('Marcar como entregado'),
                          ),
                        ),
                      if (item.status == 'Pendiente') const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final currentUser = ref.watch(currentUserProvider).maybeWhen(data: (u) => u, orElse: () => null);
                            final result = await Navigator.of(context).push<bool?>(
                              MaterialPageRoute(builder: (_) => LostItemFormScreen(item: item, currentUser: currentUser)),
                            );
                            if (result == true) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Objeto actualizado.')));
                              Navigator.of(context).pop(true);
                            }
                          },
                          child: const Text('Editar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('¿Eliminar objeto?'),
                                content: const Text('Esta acción no se puede deshacer.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              try {
                                await FirestoreService.instance.deleteLostItem(item.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Objeto eliminado.')));
                                Navigator.of(context).pop(true);
                              } catch (_) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar.')));
                              }
                            }
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
        error: (error, stack) {
          debugPrint('Firestore error: $error');
          return const Center(child: Text('No se pudo cargar el objeto. Intenta nuevamente.'));
        },
      ),
    );
  }
}

final _lostItemProvider = FutureProvider.family<LostItem?, String>((ref, id) {
  return FirestoreService.instance.fetchLostItemById(id);
});

