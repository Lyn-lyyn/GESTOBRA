import 'package:flutter/material.dart';

class AppColors {
  // Colores principales extraídos de tu diseño
  static const Color naranja = Color(0xFFF57C00); // Naranja GestObra principal
  static const Color noseleccionado = Color(0xFFE0E0E0); // para botones sin seleccionar en caso de que sean multiples opciones, en caso de que se seleccione debe cambiar a naranja
  static const Color grisfondo = Color.fromARGB(232, 245, 245, 245); // el fondo de la app debe ser blanco, pero existen cuadros(contenedores) dentro de ella que deben ser de este gris, lo de dentro de esos contenedores ya puede ser blanco nuevamente
  static const Color blanco = Colors.white; // color blanko
  static const Color gris = Color.fromRGBO(52, 51, 51, 1); //para bordes
  // Colores de texto
  static const Color textoNegro = Color(0xFF212121); //textos principales
  static const Color textoGris = Color(0xFF757575); //textos secundarios 
  
  // Colores de estado (basados en tu Word)
  static const Color estadoVerde = Color(0xFF4CAF50); // Para "En ejecución" o avances o concluidas
  static const Color estadoAmarillo = Color(0xFFFFC107); // Para "Pendiente"
  static const Color estadoRojo = Color(0xFFF44336); // Para incidencias altas


//si necesitan algun color añadanlo aqui y me ponen una explicacion de para que es

}