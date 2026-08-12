# 🧪 TEST RÁPIDO DEL SISTEMA DE ACTUALIZACIÓN

## Objetivo
Verificar que el sistema de actualización funciona correctamente sin necesidad de compilar APKs reales.

---

## 🚀 TEST EN 5 MINUTOS

### Paso 1: Abrir el archivo de configuración

📄 Archivo: `lib/core/constants/update_config.dart`

### Paso 2: Simular versión más reciente

Cambia:
```dart
static const String latestVersion = '0.1.0';  // ← Igual a pubspec.yaml
```

Por:
```dart
static const String latestVersion = '9.9.9';  // ← Simula versión más reciente
```

### Paso 3: Ejecutar la app

Chrome (más fácil para desarrollo):
```bash
flutter run -d chrome
```

O Android:
```bash
flutter run -d android
```

### Paso 4: Observar resultado

**✅ Esperado:**
- Aparece diálogo: "Nueva actualización disponible"
- Muestra: "Versión 9.9.9"
- Botón: "Actualizar ahora"
- Botón: "Actualizar después" (porque `isUpdateRequired = false`)

### Paso 5: Probar interacción

- Toca **"Actualizar después"**: Cierra el diálogo (porque es opcional)
- Cierra la app y reabre: Diálogo aparece nuevamente
- Toca **"Actualizar ahora"**: Intenta abrir URL (mostrará error en desarrollo, es normal)

### Paso 6: Revertir configuración

Cambia nuevamente:
```dart
static const String latestVersion = '9.9.9';  // ← Elimina esto
```

Por:
```dart
static const String latestVersion = '0.1.0';  // ← Vuelve al original
```

---

## 🧪 TEST AVANZADOS

### Test 1: Actualización Obligatoria

En `update_config.dart`:

```dart
static const String latestVersion = '9.9.9';  // Simula versión más reciente
static const bool isUpdateRequired = true;     // ← Cambia a true
```

**Resultado esperado:**
- No hay botón "Actualizar después"
- Solo hay botón "Actualizar ahora"
- No se puede cerrar el diálogo (click en X no cierra)
- Mensaje rojo: "Esta actualización es obligatoria..."

### Test 2: Versión Igual (Sin Actualización)

En `update_config.dart`:

```dart
static const String latestVersion = '0.1.0';  // ← Igual a pubspec.yaml
```

**Resultado esperado:**
- No aparece diálogo
- App abre normalmente
- No hay interferencia

### Test 3: Versión Antigua (Versión Instalada > Remota)

En `update_config.dart`:

```dart
static const String latestVersion = '0.0.1';  // ← Menor que pubspec.yaml
```

**Resultado esperado:**
- No aparece diálogo
- App abre normalmente

### Test 4: Changelog

En `update_config.dart`:

```dart
static const String? changelog = '''
  • Nueva característica 1
  • Nueva característica 2
  • Corrección de bug
  ''';
```

**Resultado esperado:**
- Diálogo muestra: "Cambios:"
- Lista los cambios debajo

### Test 5: Versión Instalada < Versión Remota

Cambios progresivos:
```
pubspec.yaml → version: 1.0.0+1
updateConfig → latestVersion = '1.0.1'
→ Aparece diálogo

pubspec.yaml → version: 1.0.1+2
updateConfig → latestVersion = '1.0.2'
→ Aparece diálogo

pubspec.yaml → version: 1.0.2+3
updateConfig → latestVersion = '1.1.0'
→ Aparece diálogo

pubspec.yaml → version: 1.1.0+4
updateConfig → latestVersion = '2.0.0'
→ Aparece diálogo
```

**Resultado esperado:** Todas las comparaciones correctas

---

## 📋 CHECKLIST DE TEST

- [ ] Test 1: Actualización disponible - OK
- [ ] Test 2: Actualización obligatoria - OK
- [ ] Test 3: Versión igual - OK
- [ ] Test 4: Versión más antigua - OK
- [ ] Test 5: Changelog muestra - OK
- [ ] Comparación de versiones correcta - OK
- [ ] Sin diálogo si no hay actualizacíon - OK
- [ ] Diálogo en Android - OK
- [ ] No diálogo en Chrome - OK (solo Android)

---

## 🐛 TROUBLESHOOTING

### Problema: No aparece diálogo

**Solución:**
```dart
// Verifica que:
static const String latestVersion = '9.9.9';    // Debe ser > pubspec.yaml
static const bool isUpdateRequired = false;     // No debe bloquear inicio
```

Ejecuta `flutter clean && flutter pub get && flutter run -d chrome`

### Problema: Diálogo aparece al cerrar

**Normal:** Se verifica cada vez que abre la app

### Problema: URL da error

**Normal en desarrollo:** Las URLs de ejemplo `https://example.com/...` no existen

**Para test real:**
1. Sube un APK real a Google Drive
2. Obtén URL de descarga
3. Pon en `downloadUrl`

### Problema: No funciona en web/Windows

**Normal:** El sistema solo verifica en Android. Es intencional.

---

## 🎬 VIDEO DE TEST (Pasos)

1. Abre `update_config.dart`
2. Cambia `latestVersion` de `'0.1.0'` a `'9.9.9'`
3. Abre terminal: `flutter run -d chrome`
4. Espera a que se abra Chrome
5. Debería ver diálogo de actualización
6. Toca "Actualizar después"
7. Cierra y reabre la app (F5 en Chrome)
8. Diálogo aparece nuevamente
9. Revertir `latestVersion` a `'0.1.0'`
10. ✅ Test completo

---

## ✅ RESULTADO EXITOSO

Si todos los tests pasan:

✅ El sistema de actualización está **100% funcional**

Puedes proceder a:
1. Compilar APK real
2. Cambiar versiones en producción
3. Subir APKs a servidor
4. Usuarios verán actualización automáticamente

---

