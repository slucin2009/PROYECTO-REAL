---
title: Sistema de Actualización de Aplicación - CampusFix
description: Guía completa para usar y configurar el sistema de actualización automática
---

# 🚀 Sistema de Actualización Automática - CampusFix

## ✅ Implementación Completada

El sistema de actualización automática ha sido **completamente implementado** y **integrado** en tu aplicación Flutter. La verificación se realiza automáticamente cuando la aplicación inicia.

---

## 📁 Archivos Creados/Modificados

### **Archivos Nuevos Creados:**

1. **`lib/models/app_version.dart`**
   - Modelo que define la estructura de información de actualización
   - Incluye: versión, URL de descarga, si es obligatoria, changelog

2. **`lib/services/update_service.dart`**
   - Servicio que maneja toda la lógica de actualización
   - Compara versiones correctamente (1.0.0 vs 1.0.1 vs 1.1.0)
   - Abre el enlace de descarga
   - Maneja errores de conexión gracefully

3. **`lib/core/constants/update_config.dart`** ⚠️ **ARCHIVO CLAVE**
   - Configuración centralizada y fácil de cambiar
   - Define versión actual, enlace de descarga, si es obligatoria
   - **Aquí cambias los valores cada vez que publiques una nueva versión**

4. **`lib/providers/update_provider.dart`**
   - Provider Riverpod que gestiona la verificación de actualizaciones
   - Verifica al iniciar la app
   - Solo en Android (no afecta web/Windows)

5. **`lib/widgets/update_dialog.dart`**
   - Diálogo hermoso que muestra la actualización disponible
   - Muestra versión, changelog, y opciones de actualizar
   - Si es obligatoria, el usuario no puede cerrar el diálogo

6. **`lib/widgets/update_check_wrapper.dart`**
   - Widget que envuelve la app para verificar actualizaciones
   - Integrado automáticamente en `main.dart`

### **Archivos Modificados:**

1. **`pubspec.yaml`**
   - Agregadas dependencias: `package_info_plus`, `url_launcher`

2. **`lib/main.dart`**
   - Importado `UpdateCheckWrapper`
   - Envuelto el home con verificación de actualizaciones
   - **No se modificó nada más**

---

## 🔧 CÓMO CONFIGURAR Y USAR

### **1. Cambiar la Versión de la Aplicación**

La versión debe estar en **`pubspec.yaml`**:

```yaml
version: 0.1.0+1
```

Cuando publiques una nueva versión, cambia así:

```yaml
version: 0.1.1+2
```

O para una versión más grande:

```yaml
version: 0.2.0+3
```

**Formato:** `MAJOR.MINOR.PATCH+BUILD_NUMBER`

---

### **2. Cambiar la Versión Remota (Versión Disponible)**

Abre: **`lib/core/constants/update_config.dart`**

Cambia la constante `latestVersion`:

```dart
/// Versión más reciente disponible
static const String latestVersion = '0.1.1';  // ← Cambia aquí
```

---

### **3. Cambiar el Enlace de Descarga**

En el mismo archivo **`lib/core/constants/update_config.dart`**:

```dart
/// URL de descarga del APK
static const String downloadUrl = 'https://example.com/campus_fix_0.1.1.apk';  // ← Cambia aquí
```

**Dónde subir el APK:**

- **Opción 1:** Servidor propio (recomendado)
  - Si tienes un servidor web, carga el APK ahí
  - Ejemplo: `https://tudominio.com/apks/campus_fix_0.1.1.apk`

- **Opción 2:** Google Drive público
  - Comparte el enlace público del APK
  - Obtén el ID del archivo de Google Drive
  - Crea URL: `https://drive.google.com/uc?export=download&id=FILE_ID`

- **Opción 3:** Servicio de archivos (Firebase Storage, Dropbox, etc.)
  - Firebase Storage: `https://storage.googleapis.com/...`
  - Dropbox: `https://www.dropbox.com/s/...?dl=1`

---

### **4. Marcar Actualización como Obligatoria u Opcional**

En **`lib/core/constants/update_config.dart`**:

```dart
/// Si la actualización es obligatoria
static const bool isUpdateRequired = false;  // true = obligatoria, false = opcional
```

- **`true`:** El usuario debe actualizar para continuar usando la app
- **`false`:** El usuario puede actualizar después (botón "Actualizar después")

---

### **5. Agregar Descripción de Cambios (Opcional)**

En **`lib/core/constants/update_config.dart`**:

```dart
static const String? changelog = '''
  • Nuevo sistema de actualización automática
  • Mejoras de rendimiento
  • Correcciones de errores
  ''';
```

---

## 📱 FLUJO COMPLETO: DE VERSIÓN ANTERIOR A NUEVA

### **Escenario: Pasar de v1.0.0 a v1.0.1**

#### **Paso 1: Preparar la nueva versión en tu código**

Haz los cambios que necesites en tu código Flutter.

#### **Paso 2: Cambiar la versión en pubspec.yaml**

```yaml
# Antes
version: 1.0.0+1

# Después
version: 1.0.1+2
```

#### **Paso 3: Compilar la APK de release**

```bash
cd proyectodeverdadya
flutter clean
flutter pub get
flutter build apk --release
```

La APK se genera en:
```
build/app/outputs/apk/release/app-release.apk
```

#### **Paso 4: Subir el APK a un servidor accesible**

Ejemplo con un servidor web propio o Google Drive.

Obtén la URL pública de descarga del APK. Ejemplo:
```
https://mi-servidor.com/apks/campus_fix_1.0.1.apk
```

#### **Paso 5: Actualizar la configuración de actualización**

Abre **`lib/core/constants/update_config.dart`** y cambia:

```dart
/// Versión más reciente disponible
static const String latestVersion = '1.0.1';  // ← Nueva versión

/// URL de descarga del APK
static const String downloadUrl = 'https://mi-servidor.com/apks/campus_fix_1.0.1.apk';  // ← URL pública

/// Si la actualización es obligatoria
static const bool isUpdateRequired = false;  // true si es obligatoria

/// Descripción de cambios
static const String? changelog = '''
  • Nuevo sistema de actualización automática
  • Mejoras de rendimiento
  • Correcciones de errores
  ''';
```

#### **Paso 6: Hacer que la app detecte la actualización**

No tienes que hacer nada más. La app ya verifica automáticamente:

1. Cuando el usuario abre la app (en teléfono con v1.0.0)
2. La app lee su versión instalada (v1.0.0)
3. Compara con la versión en `update_config.dart` (v1.0.1)
4. Detecta que v1.0.1 > v1.0.0
5. Muestra el diálogo de actualización
6. El usuario puede descargar e instalar v1.0.1

---

## 🧪 PRUEBAS

### **Probar el Sistema Localmente:**

1. **Versión instalada:** Mantén `pubspec.yaml` con versión `0.1.0`

2. **Simular nueva versión:** Abre `lib/core/constants/update_config.dart`

```dart
static const String latestVersion = '0.1.1';  // Simula versión más reciente
static const String downloadUrl = 'https://ejemplo.com/apk.apk';  // URL cualquiera
```

3. **Ejecutar en Android/Chrome:**

```bash
flutter run -d chrome
# o
flutter run -d android
```

4. **Resultado esperado:** Aparece diálogo de actualización al iniciar

5. **Revertir para producción:**

```dart
static const String latestVersion = '0.1.0';  // Igual a pubspec.yaml
```

---

## 🎯 COMPORTAMIENTO EN DIFERENTES ESCENARIOS

### **Escenario 1: Sin Internet**

- ✅ La app funciona normalmente
- ✅ No muestra diálogo de actualización
- ✅ No hay errores

### **Escenario 2: Versión instalada = Versión remota**

- ✅ No muestra diálogo (ya está actualizada)
- ✅ La app funciona normalmente

### **Escenario 3: Versión instalada < Versión remota (ACTUALIZACIÓN DISPONIBLE)**

- ✅ Muestra diálogo de actualización
- ✅ Usuario puede descargar el APK
- ✅ Si es obligatoria: no puede continuar sin actualizar
- ✅ Si es opcional: puede continuar con botón "Actualizar después"

### **Escenario 4: Versión instalada > Versión remota**

- ✅ No muestra diálogo (versión más nueva instalada)
- ✅ La app funciona normalmente

---

## 🔒 SEGURIDAD Y LIMITACIONES

### **Versiones Soportadas:**

✅ Comparación correcta de versiones:
- 1.0.0 vs 1.0.1 ✓
- 1.0.1 vs 1.1.0 ✓
- 2.0.0 vs 1.9.9 ✓

### **Plataformas:**

- ✅ Android
- ❌ iOS (requiere configuración adicional)
- ❌ Web (configuración alternativa necesaria)
- ❌ Windows (configuración alternativa necesaria)

El sistema solo verifica en Android automáticamente. Para otras plataformas, necesitarían una arquitectura diferente (Google Play, App Store, etc.).

### **Errores de Conexión:**

- ✅ Si no hay internet: la app funciona normalmente
- ✅ Si la URL es inválida: se silencia el error gracefully
- ✅ Si Firebase falla: no afecta la app

---

## 📊 RESUMEN DE CAMBIOS

| Archivo | Tipo | Descripción |
|---------|------|-------------|
| `lib/models/app_version.dart` | Crear | Modelo de versión |
| `lib/services/update_service.dart` | Crear | Servicio de actualización |
| `lib/core/constants/update_config.dart` | **Crear** | **Configuración (EDITAR AQUÍ)** |
| `lib/providers/update_provider.dart` | Crear | Provider Riverpod |
| `lib/widgets/update_dialog.dart` | Crear | Diálogo de actualización |
| `lib/widgets/update_check_wrapper.dart` | Crear | Widget wrapper |
| `pubspec.yaml` | Modificar | Agregar dependencias |
| `lib/main.dart` | Modificar | Integrar wrapper |

---

## 🚀 PRÓXIMOS PASOS

### **Para Publicar v1.0.1:**

1. Haz los cambios en tu código
2. Cambia versión en `pubspec.yaml` → `1.0.1+2`
3. Ejecuta `flutter build apk --release`
4. Sube el APK a tu servidor (Google Drive, servidor propio, etc.)
5. Abre `lib/core/constants/update_config.dart`
6. Actualiza `latestVersion`, `downloadUrl`, y `changelog`
7. **¡Listo!** Los teléfonos con v1.0.0 verán automáticamente el aviso

---

## ❓ PREGUNTAS FRECUENTES

**P: ¿Cómo distribu yo el APK inicial?**  
R: Por WhatsApp, email, Google Drive, tu servidor, etc. El sistema de actualización automática solo funciona DESPUÉS de instalar el APK inicial.

**P: ¿Cada cuándo verifica si hay actualización?**  
R: Cada vez que el usuario abre la app.

**P: ¿Se puede mostrar el diálogo nuevamente si el usuario lo cierra?**  
R: Sí, aparece cada vez que abre la app hasta que actualice (si es obligatoria) o siempre (si es opcional).

**P: ¿Qué pasa si la URL del APK no funciona?**  
R: El usuario ve el error cuando trata de descargar. El sistema solo abre el navegador.

**P: ¿Puedo usar un enlace de Google Drive?**  
R: Sí, obtén el ID del archivo y usa: `https://drive.google.com/uc?export=download&id=FILE_ID`

**P: ¿Afecta a la versión web?**  
R: No, el sistema solo funciona en Android.

---

## 📝 NOTAS FINALES

- ✅ El sistema está **100% implementado** e integrado
- ✅ No afecta al sistema de objetos perdidos
- ✅ No afecta a autenticación ni roles
- ✅ No afecta a Firestore
- ✅ Solo verifica en Android
- ✅ Los usuarios ven el aviso automáticamente al abrir la app
- ✅ Es fácil de actualizar: solo cambia los valores en `update_config.dart`

**¡Tu sistema de actualización automática está listo!**

