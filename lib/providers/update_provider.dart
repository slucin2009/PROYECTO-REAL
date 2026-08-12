import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_fix/models/app_version.dart';
import 'package:campus_fix/services/update_service.dart';
import 'package:campus_fix/core/constants/update_config.dart';

/// Provider que verifica si hay actualizaciones disponibles
/// Retorna:
/// - AppVersion si hay actualización disponible
/// - null si no hay actualización o hubo error de conexión
final updateStatusProvider = FutureProvider<AppVersion?>(
  (ref) async {
    final updateService = UpdateService();
    final remoteVersion = UpdateConfig.getUpdateConfig();

    try {
      final availableUpdate = await updateService.checkForUpdates(remoteVersion);
      return availableUpdate;
    } catch (_) {
      return null;
    }
  },
);

/// Notifier para controlar si el diálogo de actualización fue mostrado
final updateDialogShownProvider = StateProvider<bool>((ref) => false);
