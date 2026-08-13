import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:campus_fix/models/app_version.dart';
import 'package:campus_fix/core/constants/update_config.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();

  factory UpdateService() {
    return _instance;
  }

  UpdateService._internal();

  // ============================================================
  // VERSIÓN INSTALADA
  // ============================================================

  Future<String> getInstalledVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      debugPrint(
        '[UpdateService] Versión instalada: ${packageInfo.version}',
      );

      return packageInfo.version;
    } catch (e) {
      debugPrint(
        '[UpdateService] Error obteniendo versión: $e',
      );

      return '0.0.0';
    }
  }

  // ============================================================
  // OBTENER VERSION.JSON
  // ============================================================

  Future<AppVersion?> fetchRemoteVersion() async {
    try {
      if (!Platform.isAndroid) {
        debugPrint(
          '[UpdateService] No es Android. Se omite actualización.',
        );

        return null;
      }

      final url = UpdateConfig.versionJsonUrl;

      debugPrint(
        '[UpdateService] Consultando: $url',
      );

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Cache-Control': 'no-cache',
              'Pragma': 'no-cache',
            },
          )
          .timeout(
            Duration(
              seconds: UpdateConfig.fetchTimeoutSeconds,
            ),
          );

      debugPrint(
        '[UpdateService] HTTP: ${response.statusCode}',
      );

      if (response.statusCode != 200) {
        debugPrint(
          '[UpdateService] Error HTTP: ${response.statusCode}',
        );

        return null;
      }

      final jsonData =
          jsonDecode(response.body) as Map<String, dynamic>;

      final remoteVersion = AppVersion.fromJson(jsonData);

      debugPrint(
        '[UpdateService] Versión remota: ${remoteVersion.version}',
      );

      debugPrint(
        '[UpdateService] APK: ${remoteVersion.downloadUrl}',
      );

      debugPrint(
        '[UpdateService] Obligatoria: ${remoteVersion.isRequired}',
      );

      return remoteVersion;
    } catch (e) {
      debugPrint(
        '[UpdateService] Error obteniendo actualización: $e',
      );

      return null;
    }
  }

  // ============================================================
  // COMPARAR VERSIONES
  // ============================================================

  int compareVersions(
    String version1,
    String version2,
  ) {
    final parts1 = version1
        .split('.')
        .map(
          (part) => int.tryParse(part) ?? 0,
        )
        .toList();

    final parts2 = version2
        .split('.')
        .map(
          (part) => int.tryParse(part) ?? 0,
        )
        .toList();

    while (parts1.length < parts2.length) {
      parts1.add(0);
    }

    while (parts2.length < parts1.length) {
      parts2.add(0);
    }

    for (int i = 0; i < parts1.length; i++) {
      if (parts1[i] < parts2[i]) {
        return -1;
      }

      if (parts1[i] > parts2[i]) {
        return 1;
      }
    }

    return 0;
  }

  // ============================================================
  // COMPROBAR ACTUALIZACIÓN
  // ============================================================

  Future<AppVersion?> checkForUpdates() async {
    try {
      final installedVersion = await getInstalledVersion();

      final remoteVersion = await fetchRemoteVersion();

      if (remoteVersion == null) {
        debugPrint(
          '[UpdateService] No se pudo obtener version.json.',
        );

        // Fallback local
        if (UpdateConfig.isUpdateRequired) {
          final comparison = compareVersions(
            installedVersion,
            UpdateConfig.latestVersion,
          );

          if (comparison < 0) {
            debugPrint(
              '[UpdateService] Actualización encontrada mediante fallback.',
            );

            return AppVersion(
              version: UpdateConfig.latestVersion,
              downloadUrl: UpdateConfig.downloadUrl,
              isRequired: true,
              changelog: UpdateConfig.changelog,
            );
          }
        }

        return null;
      }

      final comparison = compareVersions(
        installedVersion,
        remoteVersion.version,
      );

      debugPrint(
        '[UpdateService] Instalada: $installedVersion',
      );

      debugPrint(
        '[UpdateService] Disponible: ${remoteVersion.version}',
      );

      debugPrint(
        '[UpdateService] Comparación: $comparison',
      );

      if (comparison < 0) {
        debugPrint(
          '[UpdateService] ¡ACTUALIZACIÓN DISPONIBLE!',
        );

        return remoteVersion;
      }

      debugPrint(
        '[UpdateService] La aplicación está actualizada.',
      );

      return null;
    } catch (e) {
      debugPrint(
        '[UpdateService] Error comprobando actualización: $e',
      );

      return null;
    }
  }

  // ============================================================
  // ABRIR APK
  // ============================================================

  Future<bool> openDownloadLink(String url) async {
    try {
      debugPrint(
        '[UpdateService] Intentando abrir APK:',
      );

      debugPrint(url);

      if (url.trim().isEmpty) {
        debugPrint(
          '[UpdateService] URL vacía.',
        );

        return false;
      }

      final uri = Uri.tryParse(url);

      if (uri == null) {
        debugPrint(
          '[UpdateService] URL inválida.',
        );

        return false;
      }

      debugPrint(
        '[UpdateService] URI: $uri',
      );

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      debugPrint(
        '[UpdateService] launchUrl resultado: $launched',
      );

      return launched;
    } catch (e) {
      debugPrint(
        '[UpdateService] Error abriendo APK: $e',
      );

      return false;
    }
  }
}

// ============================================================
// TIMEOUT
// ============================================================

class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => message;
}