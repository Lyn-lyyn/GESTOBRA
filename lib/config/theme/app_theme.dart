import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.naranja,
      scaffoldBackgroundColor: AppColors.grisfondo,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.naranja,
        brightness: Brightness.light,
        surface: AppColors.blanco,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.blanco,
        foregroundColor: AppColors.textoNegro,
        elevation: 0,
        surfaceTintColor: AppColors.blanco,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textoNegro,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      dividerColor: AppColors.bordeSuave,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.blanco,
        selectedItemColor: AppColors.naranja,
        unselectedItemColor: AppColors.textoGris,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Estilo global para Botones Elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.naranja,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      
      // Estilo global para Inputs (TextFields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.bordeSuave),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.bordeSuave),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.naranja, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }
}
