# ⚡ GUÍA RÁPIDA - Sistema de Actualización

## 🎯 CUANDO PUBLIQUES UNA NUEVA VERSIÓN

### 1️⃣ Cambiar versión instalada

📄 Archivo: `pubspec.yaml`

```yaml
version: 1.0.0+1    # Cambiar la versión aquí
```

### 2️⃣ Compilar APK

```bash
flutter build apk --release
```

APK en: `build/app/outputs/apk/release/app-release.apk`

### 3️⃣ Subir APK a servidor

Ejemplo:
- Google Drive (obtén link público)
- Tu servidor web
- Dropbox, Firebase Storage, etc.

### 4️⃣ Configurar actualización

📄 Archivo: **`lib/core/constants/update_config.dart`**

```dart
// Versión disponible (igual a pubspec.yaml)
static const String latestVersion = '1.0.1';

// URL donde está el APK
static const String downloadUrl = 'https://tu-servidor.com/campus_fix_1.0.1.apk';

// Obligatoria? true = sí, false = opcional
static const bool isUpdateRequired = false;

// Cambios (opcional)
static const String? changelog = '''
  • Cambio 1
  • Cambio 2
''';
```

### 4.1️⃣ Usar GitHub para la configuración remota (recomendado)

En lugar de editar manualmente los valores locales, puedes subir un archivo `version.json`
al repositorio de GitHub y apuntar `UpdateConfig.versionJsonUrl` a la URL "raw" del archivo.

Ejemplo de `version.json` (usa el archivo `version.json.example` en la raíz del proyecto):

```json
{
  "version": "1.0.1",
  "downloadUrl": "https://example.com/campus_fix_1.0.1.apk",
  "forceUpdate": false,
  "changelog": "• Mejoras de rendimiento\n• Corrección de errores menores"
}
```

Dónde subirlo en GitHub:

- Coloca `version.json` en la rama `main` (o la rama que uses para producción), por ejemplo en la raíz del repositorio.
- Obtén la URL "raw" para el archivo: `https://raw.githubusercontent.com/<usuario>/<repo>/main/version.json`
- Pega esa URL en `lib/core/constants/update_config.dart` → `versionJsonUrl`.

Cada vez que publiques una nueva APK, sube la nueva `version.json` con la versión actualizada y la URL del APK.


### 5️⃣ ¡Listo!

Todos los usuarios con versión anterior verán el diálogo al abrir la app.

---

## 📋 ARCHIVOS CLAVE

| Archivo | Editar? | Propósito |
|---------|---------|-----------|
| `pubspec.yaml` | ✏️ Versión | Versión instalada |
| `lib/core/constants/update_config.dart` | ✏️ Siempre | Versión remota, URL, obligatoria |
| Otros | ✗ No | Solo lectura |

---

## 🧪 PRUEBAS RÁPIDAS

1. Abre `update_config.dart`
2. Cambia `latestVersion` a algo mayor (ej: '9.9.9')
3. Ejecuta `flutter run -d chrome`
4. Debe mostrar diálogo de actualización
5. Revertir a `'0.1.0'`

---

## 🔗 ENLACES ÚTILES

- **Subir a Google Drive:** Drive → Subir archivo → Compartir → Link público → Obtener ID
- **URL Google Drive:** `https://drive.google.com/uc?export=download&id=FILE_ID`
- **Firebase Storage:** Firebase Console → Storage → Subir archivo → Obtener URL
- **Servidor propio:** Sube a `tudominio.com/apks/` → Usa URL directa

---

## ✅ CHECKLIST ANTES DE PUBLICAR

- [ ] Cambié versión en `pubspec.yaml`
- [ ] Ejecuté `flutter build apk --release`
- [ ] Subí APK a servidor accesible
- [ ] Actualicé `latestVersion` en `update_config.dart`
- [ ] Actualicé `downloadUrl` en `update_config.dart`
- [ ] Definí si es `isUpdateRequired`
- [ ] Actualicé `changelog` (opcional)
- [ ] No modifiqué nada más del código

**¡Todo listo!**

