# 📋 PUNTOS CLAVE - SISTEMA DE ACTUALIZACIÓN

## ⭐ LO MÁS IMPORTANTE

**Archivo a editar cuando publiques versión nueva:**
```
lib/core/constants/update_config.dart
```

**Valores a cambiar cada vez:**
1. `latestVersion` - nueva versión (ej: '1.0.1')
2. `downloadUrl` - enlace del APK (ej: 'https://...')
3. `isUpdateRequired` - true/false
4. `changelog` - descripción de cambios

**Versión instalada:**
```
pubspec.yaml → version: X.X.X+N
```

---

## 🔄 CICLO DE PUBLICACIÓN

```
1. Cambiar código
   ↓
2. Actualizar versión en pubspec.yaml (1.0.0 → 1.0.1)
   ↓
3. flutter build apk --release
   ↓
4. Subir APK a servidor (Google Drive, tu server, etc.)
   ↓
5. Obtener URL pública del APK
   ↓
6. Editar update_config.dart:
   - latestVersion = '1.0.1'
   - downloadUrl = 'https://...'
   ↓
7. ¡LISTO! Usuarios verán actualización automáticamente
```

---

## ✅ VERIFICACIÓN ANTES DE PUBLICAR

- [ ] Cambié `pubspec.yaml` con nueva versión
- [ ] Compilé con `flutter build apk --release`
- [ ] Subí APK a servidor accesible
- [ ] El enlace funciona (prueba en navegador)
- [ ] Actualicé `update_config.dart` con:
  - [ ] Nueva versión en `latestVersion`
  - [ ] URL correcta en `downloadUrl`
  - [ ] `isUpdateRequired` configurado (true/false)
  - [ ] `changelog` actualizado (opcional)
- [ ] No modifiqué nada más
- [ ] Ejecuté `flutter analyze` - sin errores

**Si todo ✅ → Listo para publicar**

---

## 🧪 ANTES DE PUBLICAR EN PRODUCCIÓN

1. **Test local:**
   - Cambia `latestVersion` a '9.9.9'
   - Ejecuta `flutter run -d chrome`
   - Verifica que diálogo aparece
   - Revertir `latestVersion` a versión actual

2. **Verifica compilación:**
   ```bash
   flutter clean
   flutter pub get
   flutter analyze --no-pub
   flutter build apk --release
   ```

3. **Verifica funcionamiento:**
   - Abre app en teléfono/emulador
   - Debería mostrar diálogo si hay versión más reciente
   - Botón "Actualizar ahora" abre navegador

---

## 💡 TIPS

- **Google Drive:** Comparte archivo → Obtén ID → URL: `https://drive.google.com/uc?export=download&id=ID`
- **Servidor propio:** Sube a tu web → Copia URL directa
- **Firebase Storage:** Upload → Obtén URL de descarga
- **Dropbox:** Comparte → Cambia `dl=0` por `dl=1` en URL

---

## 🚨 ERRORES COMUNES

| Error | Solución |
|-------|----------|
| No aparece diálogo | Verifica que `latestVersion` > `pubspec.yaml` |
| URL da error | URL puede no existir, normal en desarrollo |
| Diálogo desaparece | Revertiste `latestVersion` al valor anterior |
| No funciona en web | Normal, solo funciona en Android |
| APK no se descarga | Verifica que URL sea accesible |

---

## 📞 REFERENCIAS RÁPIDAS

- **Cambiar versión:** `pubspec.yaml` línea `version: X.X.X+N`
- **Configurar actualización:** `lib/core/constants/update_config.dart`
- **Ver versión instalada:** `package_info_plus` lee de `pubspec.yaml`
- **Descargar APK:** `url_launcher` abre navegador con URL
- **Verificar:** Solo Android (intencional)

---

## ✨ RESUMEN

**Sistema completo implementado:**
✅ Detecta versiones automáticamente
✅ Muestra diálogo si hay actualización
✅ Permite descargar e instalar nueva versión
✅ Configurable (obligatoria u opcional)
✅ No afecta resto de la aplicación
✅ Funciona sin Google Play Store
✅ Fácil de actualizar (solo cambiar config)

**LISTO PARA PRODUCCIÓN ✅**

