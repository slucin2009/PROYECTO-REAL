import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_fix/providers/update_provider.dart';
import 'package:campus_fix/widgets/update_dialog.dart';

/// Widget que verifica actualizaciones y muestra el diálogo si es necesario
/// Envuelve el contenido principal de la aplicación
class UpdateCheckWrapper extends ConsumerWidget {
  final Widget child;

  const UpdateCheckWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialogShown = ref.watch(updateDialogShownProvider);

    // Mostrar el diálogo cuando haya actualización disponible y no se haya mostrado aún
    ref.listen(updateStatusProvider, (previous, next) {
      next.whenData((update) {
        if (update != null && !dialogShown && context.mounted) {
          ref.read(updateDialogShownProvider.notifier).state = true;

          showDialog(
            context: context,
            barrierDismissible: !update.isRequired, // No cerrar si es obligatoria
            builder: (context) => UpdateDialog(
              updateInfo: update,
              onLater: () {
                Navigator.of(context).pop();
              },
            ),
          );
        }
      });
    });

    return child;
  }
}
