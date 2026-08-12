import 'package:campus_fix/models/app_version.dart';

/// Configuración centralizada de actualizaciones
/// Modificar estos valores cuando publiques una nueva versión
class UpdateConfig {
  /// Versión más reciente disponible
  /// Cambiar este valor a la nueva versión (ej: 1.0.1, 1.0.2, 1.1.0)
  static const String latestVersion = '1.0.1';

  /// URL de descarga del APK
  /// Cambiar a tu servidor o servicio de descarga
  /// Ejemplo: 'https://tuservidor.com/campus_fix_1.0.1.apk'
  static const String downloadUrl = 'https://example.com/campus_fix_1.0.1.apk';

  /// Si la actualización es obligatoria
  /// - true: El usuario DEBE actualizar para continuar
  /// - false: El usuario puede optar por actualizar después
  static const bool isUpdateRequired = false;

  /// Descripción de cambios (opcional)
  static const String changelog = '''
  • Nuevo sistema de actualización automática
  • Mejoras de rendimiento
  • Correcciones de errores
  ''';

  /// Obtiene la configuración como objeto AppVersion
  static AppVersion getUpdateConfig() {
    return AppVersion(
      version: latestVersion,
      downloadUrl: downloadUrl,
      isRequired: isUpdateRequired,
      changelog: changelog,
    );
  }
}
