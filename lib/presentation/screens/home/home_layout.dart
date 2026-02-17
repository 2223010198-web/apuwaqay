import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// IMPORTS DE LAS PANTALLAS
import 'dashboard_screen.dart';
import '../map/map_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart'; // Opcional si quieres settings abajo

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int _currentIndex = 0; // 0: Inicio, 1: Mapa, 2: Historial

  // Variable para pasar coordenadas específicas al mapa (desde el historial)
  LatLng? _initialMapCoords;

  // Función para cambiar de pestaña manualmente
  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Función especial: Ir al mapa y centrar en una coordenada
  void _goToMapWithCoords(LatLng coords) {
    setState(() {
      _initialMapCoords = coords; // Guardamos la coordenada
      _currentIndex = 1;          // Cambiamos a la pestaña del Mapa
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definimos las pantallas aquí para poder pasarles las funciones
    final List<Widget> pages = [
      // 0. DASHBOARD (Le pasamos la función para ir al mapa)
      DashboardScreen(
        onMapTap: () => _goToTab(1),
      ),

      // 1. MAPA
      MapScreen(
        initialCoords: _initialMapCoords, // Si hay coordenada guardada, la usa
      ),

      // 2. HISTORIAL (Le pasamos la función para ver eventos en el mapa)
      HistoryScreen(
        onMapRequest: (coords) => _goToMapWithCoords(coords),
      ),
    ];

    return Scaffold(
      // El cuerpo cambia según el índice seleccionado
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      // BARRA DE NAVEGACIÓN INFERIOR
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            _initialMapCoords = null; // Limpiamos coordenadas al cambiar manualmente
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}