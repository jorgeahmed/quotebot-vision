import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget de marca "Powered by Mantenimiento Sinai"
/// Para usar en footers y páginas de la aplicación
class BrandingFooter extends StatelessWidget {
  final bool compact;
  final Color? textColor;

  const BrandingFooter({
    super.key,
    this.compact = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor =
        textColor ?? (isDark ? Colors.white70 : Colors.black54);

    if (compact) {
      return _buildCompactVersion(defaultColor);
    }

    return _buildFullVersion(context, defaultColor);
  }

  Widget _buildCompactVersion(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Powered by ',
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.7),
            ),
          ),
          Text(
            'Mantenimiento Sinai',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullVersion(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo pequeño (si existe)
          Image.asset(
            Theme.of(context).brightness == Brightness.dark
                ? 'assets/images/logo_dark_theme.jpg'
                : 'assets/images/logo_light_theme.jpg',
            height: 40,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),

          // Texto "Powered by"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Powered by ',
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.7),
                ),
              ),
              Text(
                'Mantenimiento Sinai',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Versión de la app
          Text(
            'v1.0.0',
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de marca de agua para usar en páginas de resultados
class BrandingWatermark extends StatelessWidget {
  final Alignment alignment;
  final double opacity;

  const BrandingWatermark({
    super.key,
    this.alignment = Alignment.bottomRight,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : Colors.black;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Opacity(
          opacity: opacity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.business,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                'Mantenimiento Sinai',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
