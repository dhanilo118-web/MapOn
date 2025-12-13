import 'dart:convert';
import 'package:MapOn/ifpa_locais.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  // Controlador de animação
  late final AnimatedMapController _animatedMapController;
  final TextEditingController _searchController = TextEditingController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;

  bool _isSatellite = true;

  // --- NOVA VARIÁVEL PARA CONTROLAR VISIBILIDADE ---
  bool _showMarkers = true;

  final LatLng _initialLocation = const LatLng(-3.766, -49.676);

  List<IfpaPlace> _visiblePlaces = [];
  IfpaPlace? _selectedPlace;

  @override
  void initState() {
    super.initState();

    // Inicialização otimizada para suavidade
    _animatedMapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );

    _speech = stt.SpeechToText();
    _initSpeechState();
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  void _initSpeechState() async {
    try {
      _speechEnabled = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening') setState(() => _isListening = false);
        },
        onError: (errorNotification) => setState(() => _isListening = false),
      );
    } catch (e) {
      debugPrint("Erro voz: $e");
    }
    if (mounted) setState(() {});
  }

  void _listen() async {
    if (!_isListening && _speechEnabled) {
      setState(() => _isListening = true);
      _searchController.clear();
      _speech.listen(
        onResult: (val) => setState(() => _searchController.text = val.recognizedWords),
        localeId: 'pt_BR',
        listenOptions: stt.SpeechListenOptions(cancelOnError: true),
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _searchLocation() async {
    String query = _searchController.text.trim();
    if (query.endsWith('.')) query = query.substring(0, query.length - 1);

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

    // Busca Local
    final localMatch = ifpaLocais.where((place) {
      return place.title.toLowerCase().contains(query) || place.description.toLowerCase().contains(query);
    }).toList();

    if (localMatch.isNotEmpty) {
      setState(() {
        _visiblePlaces = localMatch;
        _selectedPlace = localMatch.first;
        // Se buscar algo, forçamos mostrar os marcadores caso estejam ocultos
        _showMarkers = true;
      });
      // Animação suave
      _animatedMapController.animateTo(dest: localMatch.first.location, zoom: 18.0);
      return;
    }

    // Busca Online
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
          final location = LatLng(lat, lon);
          String displayName = data[0]['display_name'];
          final nomeCurto = displayName.split(',')[0];

          _animatedMapController.animateTo(dest: location, zoom: 16.0);

          setState(() {
            _showMarkers = true; // Força mostrar ao encontrar
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
    _animatedMapController.animateTo(dest: LatLng(position.latitude, position.longitude), zoom: 17.0);
  }

  void _onMarkerTap(IfpaPlace place) {
    setState(() => _selectedPlace = place);
    _animatedMapController.animateTo(dest: place.location, zoom: 18.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF1E1E1E),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _animatedMapController.mapController,
            options: MapOptions(
              initialCenter: _initialLocation,
              initialZoom: 15.0,
              minZoom: 3.0,
              maxZoom: 22.0,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              onMapReady: () {
                _goToUserLocation();
              },
              onTap: (tapPosition, point) {
                if (_selectedPlace != null) setState(() => _selectedPlace = null);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatellite
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mapon',
                maxNativeZoom: _isSatellite ? 17 : 19,
                maxZoom: 22.0,
                keepBuffer: 2,
                panBuffer: 1,
                tileDisplay: const TileDisplay.fadeIn(duration: Duration(milliseconds: 300)),
              ),

              CurrentLocationLayer(
                alignPositionOnUpdate: AlignOnUpdate.never,
                style: LocationMarkerStyle(
                  markerSize: const Size(20, 20),
                  marker: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA2A33),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 3)],
                    ),
                  ),
                  accuracyCircleColor: const Color(0xFFEA2A33).withValues(alpha: .15),
                ),
              ),

              // --- CAMADA DE MARCADORES CONDICIONAL ---
              MarkerLayer(
                markers: _showMarkers
                    ? _visiblePlaces.map((place) {
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
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList()
                    : [], // Lista vazia se _showMarkers for false
              ),
            ],
          ),

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- LADO ESQUERDO: BÚSSOLA + TOGGLE MARCADORES ---
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          children: [
                            // BÚSSOLA
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: FloatingActionButton(
                                heroTag: "compass",
                                mini: true,
                                backgroundColor: Colors.white,
                                elevation: 4,
                                onPressed: () {
                                  _animatedMapController.animatedRotateReset();
                                },
                                child: StreamBuilder<MapEvent>(
                                  stream: _animatedMapController.mapController.mapEventStream,
                                  builder: (context, snapshot) {
                                    final rotation = _animatedMapController.mapController.camera.rotation;
                                    return Transform.rotate(
                                      angle: rotation * (3.1415926535 / 180) * -1,
                                      child: const Icon(Icons.explore, color: Color(0xFFEA2A33), size: 22),
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 12), // Espaço
                            // NOVO BOTÃO: MOSTRAR/ESCONDER
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: FloatingActionButton(
                                heroTag: "toggle_markers",
                                mini: true,
                                backgroundColor: Colors.white,
                                elevation: 4,
                                onPressed: () {
                                  setState(() {
                                    _showMarkers = !_showMarkers;
                                    // Fecha o card se esconder os marcadores
                                    if (!_showMarkers) _selectedPlace = null;
                                  });
                                },
                                child: Icon(
                                  _showMarkers ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey[800],
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- LADO DIREITO (Camadas, Localização, Zoom) ---
                      Column(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: FloatingActionButton(
                              heroTag: "layers",
                              mini: true,
                              onPressed: () => setState(() => _isSatellite = !_isSatellite),
                              backgroundColor: Colors.white,
                              elevation: 4,
                              child: Icon(Icons.layers, color: Colors.grey[800], size: 20),
                            ),
                          ),
                          const SizedBox(height: 12),
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

                          // ZOOM
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
                                    _animatedMapController.animatedZoomIn();
                                  },
                                  icon: const Icon(Icons.add, color: Colors.white),
                                ),
                                Container(height: 1, width: 25, color: Colors.grey.withValues(alpha: 0.3)),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  iconSize: 20,
                                  onPressed: () {
                                    _animatedMapController.animatedZoomOut();
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
                          onPressed: () => setState(() => _selectedPlace = null),
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
