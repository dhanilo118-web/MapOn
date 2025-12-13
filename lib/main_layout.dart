import 'package:MapOn/Screens/contact_screen.dart';
import 'package:MapOn/Screens/home_page.dart';
import 'package:MapOn/Screens/map_screen.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 1; // Começa na Home (índice 1)

  // Método para trocar de aba (usado pelo botão da Home)
  void _goToMapTab() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lista de telas
    final List<Widget> screens = [
      const MapScreen(),
      HomeScreen(onGoToMap: _goToMapTab), // Passamos a função aqui
      const ContactScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212).withValues(alpha: 0.9),
          border: const Border(top: BorderSide(color: Colors.white10)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          destinations: [
            _buildNavItem(Icons.map, "Mapa", 0),
            _buildNavItem(Icons.home_filled, "Home", 1),
            _buildNavItem(Icons.person, "Contato", 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFFEA2A33) : Colors.white60;

    return NavigationDestination(
      icon: Icon(icon, color: color),
      label: label,
    );
  }
}
