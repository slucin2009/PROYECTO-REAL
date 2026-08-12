import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campus_fix/models/app_version.dart';

/// Servicio para verificar y gestionar actualizaciones de la aplicación
class UpdateService {
  static final UpdateService _instance = UpdateService._internal();

  factory UpdateService() {
    return _instance;
  }

  UpdateService._internal();

  /// Obtiene la versión instalada de la aplicación
  Future<String> getInstalledVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (_) {
      return '0.0.0';
    }
  }

  /// Compara dos versiones (ej: 1.0.1 vs 1.0.0)
  /// Retorna:
  /// -1 si version1 < version2
  ///  0 si son iguales
  ///  1 si version1 > version2
  int compareVersions(String version1, String version2) {
    final parts1 = version1.split('.').map(int.tryParse).toList();
    final parts2 = version2.split('.').map(int.tryParse).toList();

    // Completar con ceros si es necesario
    while (parts1.length < parts2.length) {
      parts1.add(0);
    }
    while (parts2.length < parts1.length) {
      parts2.add(0);
    }

    for (int i = 0; i < parts1.length; i++) {
      final p1 = parts1[i] ?? 0;
      final p2 = parts2[i] ?? 0;

      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }

    return 0;
  }

  /// Verifica si hay una nueva versión disponible
  /// Retorna null si no hay actualizacion o error de conexión
  Future<AppVersion?> checkForUpdates(AppVersion remoteVersion) async {
    // Solo verificar en Android
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      final installedVersion = await getInstalledVersion();
      final comparison = compareVersions(installedVersion, remoteVersion.version);

      // Si la versión remota es más reciente
      if (comparison < 0) {
        return remoteVersion;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Abre el enlace de descarga del APK
  Future<void> openDownloadLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Silenciar errores de apertura de URL
    }
  }
}
