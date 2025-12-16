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
    final List<Widget> screens = [const MapScreen(), HomeScreen(onGoToMap: _goToMapTab), const ContactScreen()];

    return Scaffold(
      body: screens[_currentIndex],
      // Container para a barra de navegação
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          border: const Border(top: BorderSide(color: Colors.white10)),
        ),
        // Usando NavigationBar com altura reduzida e indicador circular
        child: NavigationBar(
          height: 65, // <-- Altura reduzida
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF121212),
          indicatorColor: const Color(0xFFEA2A33), // Cor vermelha do MapOn
          indicatorShape: const CircleBorder(), // <-- Transforma em círculo

          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

          destinations: [
            _buildNavItem(Icons.map_outlined, Icons.map, "Mapa", 0),
            _buildNavItem(Icons.home_outlined, Icons.home_filled, "Home", 1),
            _buildNavItem(Icons.person_outline, Icons.person, "Contato", 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData iconOutline, IconData iconFilled, String label, int index) {
    return NavigationDestination(
      // Ícone normal (cinza)
      icon: Icon(iconOutline, color: Colors.white60),
      // Ícone selecionado (branco dentro da bolinha vermelha)
      selectedIcon: Icon(iconFilled, color: Colors.white),
      label: label,
    );
  }
}
