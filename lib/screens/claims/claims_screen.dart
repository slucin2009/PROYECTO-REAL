import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_fix/models/claim.dart';
import 'package:campus_fix/models/lost_item.dart';
import 'package:campus_fix/providers/auth_provider.dart';
import 'package:campus_fix/services/firestore_service.dart';
import 'package:campus_fix/widgets/animated_list_item.dart';

import 'package:intl/intl.dart';

final claimsProvider = FutureProvider.autoDispose.family<List<Claim>, (String?, bool)>((ref, params) async {
  final (userId, onlyMine) = params;
  return FirestoreService.instance.fetchClaims(userId: userId, onlyMine: onlyMine);
});

final userNameProvider = FutureProvider.autoDispose.family<String, String>((ref, userId) async {
  return FirestoreService.instance.fetchUserNameOrId(userId);
});

final lostItemProvider = FutureProvider.autoDispose.family<LostItem?, String>((ref, itemId) async {
  return FirestoreService.instance.fetchLostItemById(itemId);
});

final availableLostItemsProvider = FutureProvider.autoDispose<List<LostItem>>((ref) async {
  // Obtener objetos perdidos con estado 'Pendiente' disponibles para reclamación
  final items = await FirestoreService.instance.fetchLostItems();
  return items.where((item) => item.status == 'Pendiente').toList();
});

class ClaimsScreen extends ConsumerWidget {
  final bool studentMode;
  final String? studentSessionId;

  const ClaimsScreen({super.key, required this.studentMode, this.studentSessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).maybeWhen(data: (user) => user, orElse: () => null);
    final userId = studentMode ? (studentSessionId ?? 'estudiante_anonimo') : currentUser?.id;
    final claimsAsync = ref.watch(claimsProvider((userId, studentMode)));

    return Scaffold(
      appBar: AppBar(title: const Text('Reclamos')),
      body: claimsAsync.when(
        data: (claims) {
          if (claims.isEmpty) {
            return Center(child: Text(studentMode ? 'No tienes reclamos todavía.' : 'No hay reclamos registrados.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              final _ = ref.refresh(claimsProvider((userId, studentMode)));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final claim = claims[index];
                return AnimatedListItem(
                  index: index,
                  child: _ClaimCard(
                    claim: claim,
                    studentMode: studentMode,
                    userId: userId,
                    ref: ref,
                    context: context,
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: claims.length,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint('Firestore error: $error');
          return Center(child: Text('No se pudieron cargar los reclamos.'));
        },
      ),
      floatingActionButton: studentMode
          ? FloatingActionButton(
              onPressed: () => _showCreateClaimDialog(context, ref, userId),
              tooltip: 'Crear reclamo',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _showCreateClaimDialog(BuildContext context, WidgetRef ref, String? userId) async {
    final itemsAsync = ref.read(availableLostItemsProvider);
    
    await itemsAsync.when(
      data: (items) async {
        if (!context.mounted) return;
        if (items.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay objetos disponibles para reclamar en este momento.')),
          );
          return;
        }
        
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Crear reclamo'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecciona el objeto que deseas reclamar:'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.maxFinite,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return InkWell(
                          onTap: () async {
                            Navigator.of(context).pop();
                            await _openClaimForm(context, ref, item, userId);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
      },
      loading: () async {
        await showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            content: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stackTrace) async {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar los objetos disponibles.')),
        );
      },
    );
  }

  Future<void> _openClaimForm(
    BuildContext context,
    WidgetRef ref,
    LostItem item,
    String? userId,
  ) async {
    final formKey = GlobalKey<FormState>();
    final questionControllers = <String, TextEditingController>{};
    for (var q in item.verificationQuestions) {
      questionControllers[q.id] = TextEditingController();
    }

    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verificar propiedad del objeto'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Objeto: ${item.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (item.verificationQuestions.isNotEmpty) ...[
                    const Text(
                      'Responde las preguntas de verificación:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    for (var q in item.verificationQuestions) ...[
                      Text(q.question),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: questionControllers[q.id],
                        decoration: const InputDecoration(labelText: 'Tu respuesta'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Respuesta requerida.' : null,
                      ),
                      const SizedBox(height: 12),
                    ]
                  ] else ...[
                    const Text('Este objeto no tiene preguntas de verificación.'),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Enviar reclamo'),
            ),
          ],
        );
      },
    );

    if (accepted != true || !context.mounted) return;

    try {
      final answers = item.verificationQuestions
          .map((q) => VerificationAnswer(
                questionId: q.id,
                answer: questionControllers[q.id]?.text.trim() ?? '',
              ))
          .toList();

      final claim = Claim(
        id: '',
        lostItemId: item.id,
        userId: userId ?? 'estudiante_anonimo',
        status: 'Pendiente',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        verificationAnswers: answers,
      );

      await FirestoreService.instance.createClaim(claim);

      if (!context.mounted) return;
      ref.invalidate(claimsProvider((userId, studentMode)));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reclamo enviado correctamente.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      debugPrint('Error creating claim: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar el reclamo.')),
      );
    }
  }
}

class _ClaimCard extends ConsumerWidget {
  final Claim claim;
  final bool studentMode;
  final String? userId;
  final WidgetRef ref;
  final BuildContext context;

  const _ClaimCard({
    required this.claim,
    required this.studentMode,
    required this.userId,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userNameAsync = ref.watch(userNameProvider(claim.userId));
    final lostItemAsync = ref.watch(lostItemProvider(claim.lostItemId));

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      userNameAsync.when(
                        data: (name) => Text(
                          'Estudiante: $name',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        loading: () => const Text('Cargando...'),
                        error: (error, stackTrace) => Text('Estudiante'),
                      ),
                      const SizedBox(height: 4),
                      lostItemAsync.when(
                        data: (item) => Text(
                          'Objeto: ${item?.title ?? 'Desconocido'}',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        loading: () => const Text('Objeto: Cargando...'),
                        error: (error, stackTrace) => const Text('Objeto: Desconocido'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (!studentMode && claim.verificationAnswers.isNotEmpty) ...[
              const Text('Respuestas del reclamante', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              lostItemAsync.when(
                data: (lostItem) {
                  if (lostItem == null) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: claim.verificationAnswers.map((ans) {
                      final q = lostItem.verificationQuestions.firstWhere((q) => q.id == ans.questionId, orElse: () => VerificationQuestion(id: ans.questionId, question: 'Pregunta', answer: ''));
                      final match = ans.answer.trim().toLowerCase() == q.answer.trim().toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Text(q.question)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(ans.answer, style: const TextStyle(fontWeight: FontWeight.w500))),
                            const SizedBox(width: 8),
                            Icon(match ? Icons.check_circle : Icons.cancel, color: match ? Colors.green : Colors.red, size: 18),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Fecha: ${DateFormat.yMMMMd().add_Hm().format(claim.createdAt.toLocal())}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ),
                if (!studentMode) ...[
                  _StatusDropdown(
                    claim: claim,
                    userId: userId,
                    ref: ref,
                    context: context,
                    studentMode: studentMode,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Eliminar reclamo',
                    onPressed: () => _showDeleteConfirmation(context, ref, claim),
                  ),
                ],
                if (studentMode)
                  Chip(
                    label: Text(claim.status),
                    backgroundColor: _getStatusColor(claim.status),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref, Claim claim) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar reclamo?'),
        content: const Text('Esta acción eliminará permanentemente el reclamo.'),
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
        await FirestoreService.instance.deleteClaim(claim.id);
        if (!context.mounted) return;
        ref.invalidate(claimsProvider((userId, studentMode)));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reclamo eliminado correctamente.')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el reclamo.')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Solucionado':
        return Colors.green;
      case 'En revisión':
        return Colors.blue;
      case 'Pendiente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class _StatusDropdown extends ConsumerWidget {
  final Claim claim;
  final String? userId;
  final WidgetRef ref;
  final BuildContext context;
  final bool studentMode;

  const _StatusDropdown({
    required this.claim,
    required this.userId,
    required this.ref,
    required this.context,
    required this.studentMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButton<String>(
      value: claim.status,
      items: const [
        DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
        DropdownMenuItem(value: 'En revisión', child: Text('En revisión')),
        DropdownMenuItem(value: 'Solucionado', child: Text('Solucionado')),
      ],
      onChanged: (newStatus) async {
        if (newStatus != null && newStatus != claim.status) {
          try {
            final updated = claim.copyWith(status: newStatus);
            await FirestoreService.instance.updateClaim(updated);
            if (context.mounted) {
              ref.invalidate(claimsProvider((userId, studentMode)));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Estado actualizado correctamente.')),
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
      underline: const SizedBox(),
    );
  }
}

