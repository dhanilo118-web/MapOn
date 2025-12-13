import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_on/ifpa_locais.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // --- VARIÁVEIS DE VOZ ---
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;

  // Coordenada inicial genérica (Centro de Tucuruí)
  final LatLng _initialLocation = const LatLng(-3.766, -49.676);

  // LISTA QUE CONTROLA QUAIS PINOS APARECEM
  List<IfpaPlace> _visiblePlaces = [];

  // VARÍAVEL PARA CONTROLAR O QUE APARECE NA BARRA DESLIZANTE
  IfpaPlace? _selectedPlace; // Se for null, a barra não aparece

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeechState();
  }

  // Inicializa o serviço de voz
  void _initSpeechState() async {
    try {
      _speechEnabled = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) {
          setState(() => _isListening = false);
          debugPrint("Erro de voz: $errorNotification");
        },
      );
    } catch (e) {
      debugPrint("Erro ao inicializar voz: $e");
    }
    if (mounted) setState(() {});
  }

  // Função para ligar/desligar microfone
  void _listen() async {
    if (!_isListening && _speechEnabled) {
      setState(() => _isListening = true);
      _searchController.clear();

      _speech.listen(
        onResult: (val) {
          setState(() {
            _searchController.text = val.recognizedWords;
          });
        },
        localeId: 'pt_BR',
        listenOptions: stt.SpeechListenOptions(cancelOnError: true),
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // ============================================================
  // FUNÇÃO DE BUSCA
  // ============================================================
  Future<void> _searchLocation() async {
    String query = _searchController.text.trim();
    if (query.endsWith('.')) {
      query = query.substring(0, query.length - 1);
    }

    _searchController.text = query;
    query = query.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _visiblePlaces = [];
        _selectedPlace = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    // 1. Busca Local
    final localMatch = ifpaLocais.where((place) {
      return place.title.toLowerCase().contains(query) || place.description.toLowerCase().contains(query);
    }).toList();

    if (localMatch.isNotEmpty) {
      setState(() {
        _visiblePlaces = localMatch;
        _selectedPlace = localMatch.first;
      });
      _mapController.move(localMatch.first.location, 18.0);
      return;
    }

    // 2. Busca Online
    setState(() {
      _visiblePlaces = [];
      _selectedPlace = null;
    });

    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1&addressdetails=1');

    try {
      final response = await http.get(url, headers: {'User-Agent': 'com.example.mapon'});

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);

          String displayName = data[0]['display_name'];
          final nomeCurto = displayName.split(',')[0];

          final location = LatLng(lat, lon);

          _mapController.move(location, 16.0);

          setState(() {
            _selectedPlace = IfpaPlace(
              title: nomeCurto,
              description: displayName,
              location: location,
              icon: Icons.public,
              color: Colors.blueAccent,
            );
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Local não encontrado!'), backgroundColor: Colors.orange));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erro de conexão.'), backgroundColor: Colors.red));
      }
    }
  }

  // ============================================================
  // FUNÇÃO GPS
  // ============================================================
  Future<void> _goToUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ative o GPS.')));
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    _mapController.move(LatLng(position.latitude, position.longitude), 17.0);
  }

  void _onMarkerTap(IfpaPlace place) {
    setState(() {
      _selectedPlace = place;
    });
    _mapController.move(place.location, 18.0);
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
            options: MapOptions(
              initialCenter: _initialLocation,
              initialZoom: 15.0,
              minZoom: 3.0,
              // CORREÇÃO: Permitimos zoom alto na câmera (até 19)
              maxZoom: 19.0,
              onMapReady: () {
                _goToUserLocation();
              },
              onTap: (tapPosition, point) {
                if (_selectedPlace != null) {
                  setState(() {
                    _selectedPlace = null;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                // Satélite da Esri
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.mapon',
                // --- O PULO DO GATO (OVERZOOM) ---
                // maxNativeZoom: 17 -> Diz: "Só baixe imagens até o nível 17"
                // maxZoom: 19 -> Diz: "Se passar do 17, estique a imagem até o 19"
                maxNativeZoom: 17,
                maxZoom: 19.0,
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
              MarkerLayer(
                markers: _visiblePlaces.map((place) {
                  return Marker(
                    point: place.location,
                    width: 60,
                    height: 80,
                    child: GestureDetector(
                      onTap: () => _onMarkerTap(place),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on, color: place.color, size: 40),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [BoxShadow(blurRadius: 2, color: Colors.black26)],
                            ),
                            child: Text(
                              place.title,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'Esri World Imagery',
                    onTap: () => launchUrl(Uri.parse('https://www.esri.com/en-us/legal/copyright-trademarks')),
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
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  _visiblePlaces = [];
                                  _selectedPlace = null;
                                });
                              }
                            },
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

                        // --- ÍCONE DO MICROFONE ---
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening ? const Color(0xFFEA2A33) : Colors.grey,
                            ),
                            onPressed: _listen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- BOTÕES FLUTUANTES ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
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
                                Container(height: 1, width: 25, color: Colors.grey.withValues(alpha: 0.3)),
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

          // 3. BARRA DESLIZANTE
          if (_selectedPlace != null)
            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.15,
              maxChildSize: 0.5,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -5))],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(3)),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _selectedPlace!.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_selectedPlace!.icon, size: 32, color: _selectedPlace!.color),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _selectedPlace!.title,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Divider(color: Colors.grey[800], thickness: 1, height: 1),
                      const SizedBox(height: 20),
                      const Text(
                        "INFORMAÇÕES",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedPlace!.description,
                        style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedPlace = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C2C2C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            side: BorderSide(color: Colors.grey[800]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Fechar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
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
