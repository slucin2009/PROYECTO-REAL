import 'package:flutter/material.dart';
import 'package:campus_fix/models/app_version.dart';
import 'package:campus_fix/services/update_service.dart';

/// Diálogo para mostrar notificación de nueva actualización disponible
class UpdateDialog extends StatelessWidget {
  final AppVersion updateInfo;
  final VoidCallback? onLater;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !updateInfo.isRequired,
      child: AlertDialog(
        title: const Text('Nueva actualización disponible'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Versión ${updateInfo.version}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (updateInfo.isRequired)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Esta actualización es obligatoria. Debes actualizar para continuar.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (updateInfo.isRequired) const SizedBox(height: 12),
              if (updateInfo.changelog != null) ...[
                const Text(
                  'Cambios:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  updateInfo.changelog!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!updateInfo.isRequired)
            TextButton(
              onPressed: onLater ?? () => Navigator.of(context).pop(),
              child: const Text('Actualizar después'),
            ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Actualizar ahora'),
            onPressed: () async {
              await UpdateService().openDownloadLink(updateInfo.downloadUrl);
              // No cerramos el diálogo si es obligatoria
              if (!updateInfo.isRequired && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
