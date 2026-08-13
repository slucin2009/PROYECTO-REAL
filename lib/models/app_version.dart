/// Modelo para la información de actualización disponible
class AppVersion {
  /// Versión disponible (ej: 1.0.1)
  final String version;

  /// Enlace de descarga del APK
  final String downloadUrl;

  /// Si la actualización es obligatoria
  final bool isRequired;

  /// Descripción de cambios (opcional)
  final String? changelog;

  const AppVersion({
    required this.version,
    required this.downloadUrl,
    required this.isRequired,
    this.changelog,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    // El JSON remoto puede usar la clave 'forceUpdate' (según la especificación)
    // o 'isRequired' (compatibilidad). Aceptamos ambos.
    final bool isReq = json['forceUpdate'] as bool? ?? json['isRequired'] as bool? ?? false;
    return AppVersion(
      version: json['version'] as String,
      downloadUrl: json['downloadUrl'] as String,
      isRequired: isReq,
      changelog: json['changelog'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'downloadUrl': downloadUrl,
      'isRequired': isRequired,
      'changelog': changelog,
    };
  }
}
