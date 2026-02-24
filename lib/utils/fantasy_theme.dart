// ============================================================
// THÈME FANTASY MÉDIÉVAL - Chess Strategy
// ============================================================

import 'package:flutter/material.dart';

class FantasyTheme {
  // Palette de couleurs principale
  static const Color bgDark = Color(0xFF0D0A1A);
  static const Color bgMedium = Color(0xFF1A1530);
  static const Color bgLight = Color(0xFF241E42);

  static const Color purple = Color(0xFF7B2FBE);
  static const Color purpleLight = Color(0xFFAB5FEE);
  static const Color purpleDark = Color(0xFF4A1A7A);

  static const Color emerald = Color(0xFF00C97A);
  static const Color emeraldDark = Color(0xFF007A4A);
  static const Color emeraldGlow = Color(0xFF00FF9F);

  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFEC6A);
  static const Color goldDark = Color(0xFFB8860B);

  static const Color silver = Color(0xFFB0B0C8);
  static const Color white = Color(0xFFF0E8FF);
  static const Color red = Color(0xFFE84040);
  static const Color orange = Color(0xFFFF8C00);

  // Couleurs de l'échiquier
  static const Color lightSquare = Color(0xFF3D2D6A);
  static const Color darkSquare = Color(0xFF1E1438);
  static const Color lightSquareHighlight = Color(0xFF6A4DA0);
  static const Color darkSquareHighlight = Color(0xFF3D2870);

  // Couleurs des pièces
  static const Color whitePieceColor = Color(0xFFF0E8FF);
  static const Color blackPieceColor = Color(0xFF1A1A2E);
  static const Color whitePieceBorder = Color(0xFFFFD700);
  static const Color blackPieceBorder = Color(0xFF7B2FBE);

  // Gradients
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgDark, bgMedium, bgLight],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleDark, purple, purpleLight],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldDark, gold, goldLight],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emeraldDark, emerald, emeraldGlow],
  );

  // BoxDecorations communes
  static BoxDecoration cardDecoration({
    Color? borderColor,
    double borderWidth = 1.5,
    double borderRadius = 12,
    List<Color>? gradientColors,
  }) {
    return BoxDecoration(
      gradient: gradientColors != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            )
          : null,
      color: gradientColors == null ? bgMedium : null,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? purple.withValues(alpha: 0.5),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: (borderColor ?? purple).withValues(alpha: 0.3),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ],
    );
  }

  // Glow effect
  static List<BoxShadow> glowShadow(Color color, {double intensity = 0.6}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity),
        blurRadius: 15,
        spreadRadius: 3,
      ),
      BoxShadow(
        color: color.withValues(alpha: intensity * 0.5),
        blurRadius: 30,
        spreadRadius: 5,
      ),
    ];
  }

  // Textstyles
  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'serif',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: gold,
    letterSpacing: 2,
    shadows: [
      Shadow(color: Color(0xFFFFD700), blurRadius: 10),
    ],
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: silver,
    letterSpacing: 1,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    color: silver,
    letterSpacing: 0.5,
  );
}
