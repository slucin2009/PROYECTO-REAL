import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_fix/models/app_user.dart';
import 'package:campus_fix/models/lost_item.dart';
import 'package:campus_fix/screens/lost_found/lost_item_detail_screen.dart';
import 'package:campus_fix/screens/lost_found/lost_item_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:campus_fix/services/firestore_service.dart';
import 'package:campus_fix/widgets/animated_list_item.dart';

final lostItemsProvider = FutureProvider.autoDispose<List<LostItem>>((ref) {
  return FirestoreService.instance.fetchLostItems();
});

class LostItemsScreen extends ConsumerWidget {
  final bool studentMode;
  final String? studentSessionId;
  final AppUser? currentUser;

  const LostItemsScreen({
    super.key,
    required this.studentMode,
    this.studentSessionId,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only allow authenticated users (students or authority)
    if (!studentMode && currentUser == null) {
      return const Center(child: Text('Debes iniciar sesión para ver los objetos.'));
    }

    final itemsAsync = ref.watch(lostItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Objetos Perdidos'),
        actions: [
          if (!studentMode && currentUser != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: FloatingActionButton.small(
                  tooltip: 'Crear objeto',
                  onPressed: () async {
                    final result = await Navigator.of(context).push<bool?>(
                      MaterialPageRoute(
                        builder: (_) => LostItemFormScreen(item: null, currentUser: currentUser),
                      ),
                    );
                    if (result == true) {
                      ref.invalidate(lostItemsProvider);
                    }
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          // Filter: students see only Pendiente items, authorities see all
          final filteredItems = studentMode ? items.where((i) => i.status == 'Pendiente').toList() : items;

          if (filteredItems.isEmpty) {
            return Center(child: Text(studentMode ? 'No hay objetos disponibles.' : 'No hay objetos registrados.'));
          }

          return RefreshIndicator(
            onRefresh: () async => await ref.refresh(lostItemsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return AnimatedListItem(
                  index: index,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final res = await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => LostItemDetailScreen(
                          itemId: item.id,
                          studentMode: studentMode,
                          studentSessionId: studentSessionId,
                        ),
                      ));
                      if (res == true) {
                        ref.invalidate(lostItemsProvider);
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(item.title, style: Theme.of(context).textTheme.titleLarge)),
                                Chip(
                                  label: Text(item.status),
                                  backgroundColor: item.status == 'Entregado' ? Colors.grey : Colors.orange,
                                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (item.withdrawnBy != null)
                              Text('Retirado por: ${item.withdrawnBy}', style: const TextStyle(fontSize: 12, color: Colors.grey))
                            else
                              Text('Creado: ${DateFormat.yMMMMd().add_Hm().format(item.createdAt.toLocal())}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            if (item.verificationQuestions.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Chip(
                                label: Text('${item.verificationQuestions.length} preguntas'),
                                avatar: const Icon(Icons.question_mark, size: 16),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: filteredItems.length,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint('Firestore error: $error');
          return const Center(child: Text('No se pudieron cargar los objetos.'));
        },
      ),
    );
  }
}

