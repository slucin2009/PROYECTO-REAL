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
    return AppVersion(
      version: json['version'] as String,
      downloadUrl: json['downloadUrl'] as String,
      isRequired: json['isRequired'] as bool? ?? false,
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
