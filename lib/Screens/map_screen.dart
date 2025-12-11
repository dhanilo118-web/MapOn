import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Coordenada inicial genérica (Centro de Tucuruí)
  final LatLng _initialLocation = const LatLng(-3.766, -49.676);

  // ============================================================
  // FUNÇÃO DE BUSCA (Corrigida com { chaves })
  // ============================================================
  Future<void> _searchLocation() async {
    String query = _searchController.text.trim();

    // Correção: Adicionei chaves {}
    if (query.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');

    try {
      final response = await http.get(url, headers: {'User-Agent': 'com.example.mapon'});

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final nome = data[0]['display_name'].toString().split(',')[0];

          _mapController.move(LatLng(lat, lon), 16.0);

          // Correção: Adicionei chaves {}
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Encontrado: $nome'), backgroundColor: Colors.green));
          }
        } else {
          // Correção: Adicionei chaves {}
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Local não encontrado!'), backgroundColor: Colors.orange));
          }
        }
      }
    } catch (e) {
      // Correção: Adicionei chaves {}
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro de conexão.'), backgroundColor: Colors.red));
      }
    }
  }

  // ============================================================
  // FUNÇÃO GPS (Corrigida com { chaves })
  // ============================================================
  Future<void> _goToUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // Correção: Adicionei chaves {}
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, ative o GPS do celular.')));
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      // Correção: Adicionei chaves {}
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    // Correção: Adicionei chaves {}
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    _mapController.move(LatLng(position.latitude, position.longitude), 17.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. O MAPA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _initialLocation, initialZoom: 15.0, minZoom: 3.0, maxZoom: 18.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mapon',
              ),
              CurrentLocationLayer(
                alignPositionOnUpdate: AlignOnUpdate.never,
                style: LocationMarkerStyle(
                  marker: const DefaultLocationMarker(
                    color: Color(0xFFEA2A33),
                    child: Icon(Icons.navigation, color: Colors.white, size: 14),
                  ),
                  markerSize: const Size(40, 40),
                  accuracyCircleColor: const Color(0xFFEA2A33).withValues(alpha: .1),
                ),
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                  ),
                ],
              ),
            ],
          ),

          // 2. A INTERFACE (Barra de Busca + Botões)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- BARRA DE BUSCA ---
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.grey),
                            onPressed: _searchLocation,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _searchLocation(),
                            decoration: const InputDecoration(
                              hintText: "Procurar local...",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Icon(Icons.mic, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- BOTÕES FLUTUANTES (Alinhados à Direita) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          // Botão de GPS (Menor)
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: FloatingActionButton(
                              heroTag: "loc",
                              mini: true,
                              onPressed: _goToUserLocation,
                              backgroundColor: const Color(0xFFEA2A33),
                              elevation: 4,
                              child: const Icon(Icons.my_location, color: Colors.white, size: 20),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Botões de Zoom (+ e -)
                          Container(
                            width: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                            ),
                            child: Column(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  iconSize: 20,
                                  onPressed: () {
                                    final currentZoom = _mapController.camera.zoom;
                                    _mapController.move(_mapController.camera.center, currentZoom + 1);
                                  },
                                  icon: const Icon(Icons.add, color: Colors.white),
                                ),
                                Container(height: 1, width: 25, color: Colors.grey.withValues(alpha: .3)),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  iconSize: 20,
                                  onPressed: () {
                                    final currentZoom = _mapController.camera.zoom;
                                    _mapController.move(_mapController.camera.center, currentZoom - 1);
                                  },
                                  icon: const Icon(Icons.remove, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Painel Inferior (Bottom Sheet)
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.1,
            maxChildSize: 0.4,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF121212),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5))],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 6,
                        decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Mapa Livre",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Text("Explore a cidade", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
