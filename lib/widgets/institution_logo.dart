import 'package:flutter/material.dart';

/// Widget para mostrar el logo institucional del Liceo Cristiano Peninsular
/// Intenta cargar desde assets/images/logo_institucion.png
/// Si no existe, muestra un placeholder visual con el nombre de la institución
class InstitutionLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const InstitutionLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 60,
      height: height ?? 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildLogo(),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo_institucion.png',
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback: mostrar un placeholder visual con el nombre de la institución
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.blue.shade900],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              color: Colors.white,
              size: (width ?? 60) * 0.5,
            ),
            const SizedBox(height: 4),
            const Text(
              'LCP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
