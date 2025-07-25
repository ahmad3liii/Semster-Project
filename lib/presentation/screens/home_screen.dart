import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../cubits/location_cubit.dart';
import '../../cubits/map_type_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  Marker? _searchMarker;
  Marker? _tappedMarker;
  LatLng? _tappedLocation;

  Set<Polyline> _polylines = {};
  List<LatLng> _routeCoordinates = [];
  bool _isRouteLoading = false;

  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  String? _routeDistance;
  String? _routeDuration;

  Timer? _debounce;
  Map<String, List<dynamic>> _cachedSearches = {};

  void _recenter(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16),
      ),
    );
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    if (_cachedSearches.containsKey(query)) {
      setState(() {
        _searchResults = _cachedSearches[query]!;
      });
      return;
    }

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'YourApp/1.0 (your@email.com)'},
      );
      if (response.statusCode == 200) {
        final List results = json.decode(response.body);
        _cachedSearches[query] = results;
        setState(() {
          _searchResults = results;
        });
      }
    } catch (_) {
      setState(() {
        _searchResults = [];
      });
    }
  }

  Future<void> _getRouteDirections(LatLng origin, LatLng destination) async {
    setState(() {
      _isRouteLoading = true;
      _polylines.clear();
    });

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=polyline&alternatives=false&steps=true',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final points = route['geometry'];

        _routeCoordinates = _decodePoly(points);
        final leg = route['legs'][0];
        _routeDistance = (leg['distance'] / 1000).toStringAsFixed(2) + ' كم';
        _routeDuration =
            (leg['duration'] / 60).toStringAsFixed(0) + ' دقيقة تقريباً';

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: _routeCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل الاتجاهات: $e')),
      );
    } finally {
      setState(() {
        _isRouteLoading = false;
      });
    }
  }

  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  void _selectSearchResult(dynamic result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    final selectedLatLng = LatLng(lat, lon);

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: selectedLatLng, zoom: 16),
      ),
    );

    setState(() {
      _searchMarker = Marker(
        markerId: const MarkerId('search'),
        position: selectedLatLng,
        infoWindow: InfoWindow(title: result['display_name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      _searchResults = [];
      _isSearching = false;
      _searchController.text = result['display_name'];
      _tappedLocation = null;
      _tappedMarker = null;
    });

    final current = context.read<LocationCubit>().state;
    if (current != null) {
      _getRouteDirections(current, selectedLatLng);
    }

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Transport map',
          style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
        ),
        leading: PopupMenuButton<MapViewType>(
          color: Colors.blueGrey,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(35)),
          ),
          icon: const Icon(Icons.map, color: Colors.white),
          tooltip: 'تغيير نوع الخريطة',
          onSelected: (type) {
            context.read<MapTypeCubit>().setMapViewType(type);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: MapViewType.normal,
              child: Text(
                'Normal',
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            PopupMenuItem(
              value: MapViewType.satellite,
              child: Text(
                'Satellite',
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            PopupMenuItem(
              value: MapViewType.hybrid,
              child: Text(
                'Hybrid',
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            PopupMenuItem(
              value: MapViewType.terrain,
              child: Text(
                'Terrain',
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            PopupMenuItem(
              value: MapViewType.tilted,
              child: Text(
                '3D',
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            PopupMenuItem(
              value: MapViewType.earth,
              child: Text(
                'Earth',
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<LocationCubit, LatLng?>(
        builder: (context, location) {
          if (location == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<MapTypeCubit, MapViewType>(
            builder: (context, mapViewType) {
              MapType mapType;
              switch (mapViewType) {
                case MapViewType.satellite:
                  mapType = MapType.satellite;
                  break;
                case MapViewType.hybrid:
                case MapViewType.tilted:
                case MapViewType.earth:
                  mapType = MapType.hybrid;
                  break;
                case MapViewType.terrain:
                  mapType = MapType.terrain;
                  break;
                default:
                  mapType = MapType.normal;
              }

              return Stack(
                children: [
                  GoogleMap(
                    mapType: mapType,
                    initialCameraPosition: CameraPosition(
                      target: location,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    onTap: (LatLng pos) {
                      setState(() {
                        _tappedLocation = pos;
                        _tappedMarker = Marker(
                          markerId: const MarkerId('tapped'),
                          position: pos,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen,
                          ),
                          infoWindow: const InfoWindow(title: 'الموقع المحدد'),
                        );
                        _searchMarker = null;
                        _routeDistance = null;
                        _routeDuration = null;
                        _polylines.clear();
                      });
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('me'),
                        position: location,
                        infoWindow: const InfoWindow(title: 'موقعي الحالي'),
                      ),
                      if (_searchMarker != null) _searchMarker!,
                      if (_tappedMarker != null) _tappedMarker!,
                    },
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  ),

                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fillColor: Colors.blue[400],
                              filled: true,
                              hintStyle: const TextStyle(color: Colors.white),
                              hintText: 'ابحث عن موقع...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchResults = [];
                                          _searchMarker = null;
                                          _tappedMarker = null;
                                          _polylines.clear();
                                          _routeDistance = null;
                                          _routeDuration = null;
                                        });
                                      },
                                    ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (text) {
                              if (_debounce?.isActive ?? false)
                                _debounce!.cancel();
                              _debounce = Timer(
                                const Duration(milliseconds: 600),
                                () {
                                  _searchLocation(text);
                                  setState(() {
                                    _isSearching = text.isNotEmpty;
                                  });
                                },
                              );
                            },
                            onSubmitted: (text) {
                              if (_searchResults.isNotEmpty) {
                                _selectSearchResult(_searchResults.first);
                              }
                            },
                          ),

                          if (_isSearching && _searchResults.isNotEmpty)
                            Container(
                              height: 160,
                              color: Colors.white,
                              child: ListView.builder(
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final result = _searchResults[index];
                                  return ListTile(
                                    title: Text(result['display_name']),
                                    onTap: () => _selectSearchResult(result),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  if (_isRouteLoading)
                    const Center(child: CircularProgressIndicator()),

                  if (_routeDistance != null && _routeDuration != null)
                    Positioned(
                      bottom: 150,
                      left: 70,
                      right: 70,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'المسافة: $_routeDistance\nالمدة: $_routeDuration',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    bottom: 100,
                    right: 10,
                    child: FloatingActionButton(
                      heroTag: 'btn_recenter',
                      tooltip: "تحديد موقعي",
                      onPressed: () {
                        if (location != null) {
                          _recenter(location);
                        }
                      },
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.my_location),
                    ),
                  ),

                  if (_tappedLocation != null)
                    Positioned(
                      bottom: 160,
                      right: 10,
                      child: FloatingActionButton(
                        heroTag: 'btn_route',
                        tooltip: "رسم المسار ",
                        onPressed: () {
                          final current = context.read<LocationCubit>().state;
                          if (current != null) {
                            _getRouteDirections(current, _tappedLocation!);
                          }
                        },
                        backgroundColor: const Color.fromARGB(112, 20, 219, 27),
                        child: const Icon(Icons.directions),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
