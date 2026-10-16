import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Cores baseadas no logo da Cobest
Color _primaryColor = const Color(0xFFD2691E); // Laranja do logo
Color _secondaryColor = const Color(0xFF4A4A4A); // Cinza escuro do logo

ThemeData light({Color? primaryColor, Color? secondaryColor}) => ThemeData(
  fontFamily: 'TitilliumWeb',
  primaryColor: primaryColor ?? _primaryColor,
  brightness: Brightness.light,
  highlightColor: Colors.white,
  hintColor: const Color(0xFFA7A7A7), //Border Color
  splashColor: Colors.transparent,
  cardColor: Colors.white,

  scaffoldBackgroundColor: const Color(0xFFF7F8FA),
  
  // Configuração específica para splash screen
  splashFactory: InkRipple.splashFactory,

  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Color(0xFF222324)),  // Text color primary
    bodyMedium: TextStyle(color: _primaryColor), // Text color Secondary
    bodySmall: const TextStyle(color: Color(0xFFA7A7A7)),  // Text color Light grey

    titleMedium: const TextStyle(color: Color(0xFF656566)),
  ),

  colorScheme: ColorScheme.light(
    primary: primaryColor ?? _primaryColor,  // Laranja Cobest
    secondary: secondaryColor ?? _secondaryColor,  // Cinza escuro Cobest
    tertiary: const Color(0xFFFFBB38), // Warning Color
    tertiaryContainer: const Color(0xFFFFE4CC), // Container laranja claro
    onTertiaryContainer: const Color(0xFF04BB7B), // Success Color
    onPrimary: const Color(0xFFFFE4CC), // Versão clara do laranja
    surface: const Color(0xFFF4F8FF),
    onSecondary: const Color(0xFFE85A00), // Versão mais escura do laranja
    error: const Color(0xFFFF4040), // Danger Color
    onSecondaryContainer: const Color(0xFFF3F9FF),
    outline: const Color(0xFFD2691E), // Info Color usando laranja Cobest
    onTertiary: const Color(0xFFFFF8F0), // Background muito claro
    shadow: const Color(0xFF66717C),
    
    // Cor específica para splash screen - branco para contraste com logo
    surfaceVariant: Colors.white, // Pode ser usado para splash screen

    primaryContainer: const Color(0xFFFFE4CC), // Container laranja claro
    secondaryContainer: const Color(0xFFE9EEF4),
  ),

  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
);