import 'package:flutter/material.dart';

// ── Paleta de colores PASTEL ROSA ────────────────────────────────────────────
class AppColors {
  // Rosa pastel principal
  static const pastelPink     = Color(0xFFFFB6C1); // Rosa pastel claro
  static const pastelRose     = Color(0xFFFFC0CB); // Rosa tradicional pastel
  static const softPeach      = Color(0xFFFFDAB9); // Durazno suave
  static const powderPink     = Color(0xFFEFD1D8); // Rosa pólvora
  static const blush          = Color(0xFFFADadd); // Rosa ruborizado
  
  // Rosas más intensos para acentos
  static const roseGold       = Color(0xFFE8B4B8); // Oro rosa
  static const dustyRose      = Color(0xFFDCAE96); // Rosa polvoriento
  static const warmPink       = Color(0xFFF4A4A4); // Rosa cálido
  
  // Para degrade hacia lavanda suave
  static const softLilac      = Color(0xFFE6D7E8); // Lila suave
  static const paleLavender   = Color(0xFFDDC9E2); // Lavanda pálido

  // Aliases de compatibilidad
  static const pink           = pastelPink;
  static const salmon         = softPeach;
  static const coral          = warmPink;
  static const teal           = warmPink; // Alias para coral/warmPink
  static const slateBlue      = paleLavender; // Alias para lilac suave
  static const lavender       = softLilac;
  static const mauve          = paleLavender;
  static const purple         = Color(0xFFBFA4C4); // Morado suave rosado
  static const deepPurple     = Color(0xFF9A7B9A); // Morado oscuro suave

  // Neutros con tono rosado
  static const background     = Color(0xFFFFF0F3); // fondo rosa muy claro
  static const surface        = Colors.white;
  static const textPrimary    = Color(0xFF5C4A52); // gris-marrón cálido oscuro
  static const textSecondary  = Color(0xFF8B6B73); // gris-marrón medio

  // Gradientes
  static const gradientStart  = powderPink;
  static const gradientMid   = pastelPink;
  static const gradientEnd   = warmPink;

  // Gradiente principal - rosa pastel a cálido
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [powderPink, pastelPink, warmPink, roseGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.4, 0.7, 1.0],
  );

  // Gradiente suave (fondos)
  static const LinearGradient softGradient = LinearGradient(
    colors: [blush, Color(0xFFFFF5F5), Color(0xFFFFF0F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Gradiente de botón
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [pastelPink, warmPink],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Gradiente completo (5 colores)
  static const LinearGradient fullGradient = LinearGradient(
    colors: [blush, powderPink, pastelPink, warmPink, roseGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
}

// ── Tema global ──────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get theme {
    const primary = AppColors.pastelPink;
    const accent  = AppColors.warmPink;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: AppColors.surface,
        // ignore: deprecated_member_use
        background: AppColors.background,
        tertiary: AppColors.softLilac,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD0D0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD0D0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.8),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.warmPink,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFFFE4E8),
        selectedColor: AppColors.powderPink,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),

      // BottomNav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.pastelPink,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      // Cards
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shadowColor: AppColors.pastelPink.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFFFE0E6),
        thickness: 1,
      ),
    );
  }
}

// ── Widgets reutilizables ────────────────────────────────────────────────────

/// Fondo con degradado de la paleta Rosa Pastel
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.fullGradient,
      ),
      child: child,
    );
  }
}

/// Botón primario con degradado hermoso
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [AppColors.pastelPink, AppColors.warmPink, AppColors.roseGold],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFCCCCCC), Color(0xFFAAAAAA)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.warmPink.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: AppColors.pastelPink.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Campo de texto estilizado
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final String? hint;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.hint,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, size: 20),
        suffixIcon: suffix,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}