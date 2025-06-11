import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class LocationCubit extends Cubit<LatLng?> {
  LocationCubit() : super(null);

  Future<void> getCurrentLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      final position = await Geolocator.getCurrentPosition();
      emit(LatLng(position.latitude, position.longitude));
    } else {
      emit(null);
    }
  }
}

enum MapViewType { normal, satellite, hybrid, terrain, tilted, earth }

class MapTypeCubit extends Cubit<MapViewType> {
  MapTypeCubit() : super(MapViewType.normal);

  void setMapViewType(MapViewType type) => emit(type);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocationCubit()..getCurrentLocation()),
        BlocProvider(create: (_) => MapTypeCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'تجربة الخرائط والموقع',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  Marker? _searchMarker;

  void _recenter(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16),
      ),
    );
  }

  Future<void> _searchAndNavigate(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newLatLng = LatLng(location.latitude, location.longitude);
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newLatLng, zoom: 16),
          ),
        );

        setState(() {
          _searchMarker = Marker(
            markerId: const MarkerId('search'),
            position: newLatLng,
            infoWindow: InfoWindow(title: query),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لم يتم العثور على الموقع')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطتي'),
        leading: PopupMenuButton<MapViewType>(
          icon: const Icon(Icons.map),
          tooltip: 'تغيير نوع الخريطة',
          onSelected: (type) {
            context.read<MapTypeCubit>().setMapViewType(type);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: MapViewType.normal,
              child: Text('عادي - Normal'),
            ),
            PopupMenuItem(
              value: MapViewType.satellite,
              child: Text('فضائي - Satellite'),
            ),
            PopupMenuItem(
              value: MapViewType.hybrid,
              child: Text('مختلط - Hybrid'),
            ),
            PopupMenuItem(
              value: MapViewType.terrain,
              child: Text('تضاريس - Terrain'),
            ),
            PopupMenuItem(
              value: MapViewType.tilted,
              child: Text('عرض مائل - 3D'),
            ),
            PopupMenuItem(
              value: MapViewType.earth,
              child: Text('جوجل إيرث - Earth'),
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
              CameraPosition initialCamera;

              switch (mapViewType) {
                case MapViewType.satellite:
                  mapType = MapType.satellite;
                  initialCamera = CameraPosition(target: location, zoom: 15);
                  break;
                case MapViewType.hybrid:
                  mapType = MapType.hybrid;
                  initialCamera = CameraPosition(target: location, zoom: 15);
                  break;
                case MapViewType.terrain:
                  mapType = MapType.terrain;
                  initialCamera = CameraPosition(target: location, zoom: 15);
                  break;
                case MapViewType.tilted:
                  mapType = MapType.hybrid;
                  initialCamera = CameraPosition(
                    target: location,
                    zoom: 17,
                    tilt: 160,
                    bearing: 45,
                  );
                  break;
                case MapViewType.earth:
                  mapType = MapType.hybrid;
                  initialCamera = CameraPosition(
                    target: location,
                    zoom: 18,
                    tilt: 70,
                    bearing: 60,
                  );
                  break;
                case MapViewType.normal:
                default:
                  mapType = MapType.normal;
                  initialCamera = CameraPosition(target: location, zoom: 15);
              }

              return Stack(
                children: [
                  GoogleMap(
                    mapType: mapType,
                    initialCameraPosition: initialCamera,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('me'),
                        position: location,
                        infoWindow: const InfoWindow(title: 'موقعي الحالي'),
                      ),
                      if (_searchMarker != null) _searchMarker!,
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
                  // مربع البحث
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _searchAndNavigate,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن موقع...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // زر إعادة التمركز
                  Positioned(
                    bottom: 100,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: () => _recenter(location),
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                  // أزرار تغيير العرض
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _mapTypeButton(context, MapViewType.normal, 'عادي'),
                          _mapTypeButton(
                            context,
                            MapViewType.satellite,
                            'فضائي',
                          ),
                          _mapTypeButton(context, MapViewType.hybrid, 'مختلط'),
                          _mapTypeButton(
                            context,
                            MapViewType.terrain,
                            'تضاريس',
                          ),
                          _mapTypeButton(context, MapViewType.tilted, 'مائل'),
                          _mapTypeButton(context, MapViewType.earth, 'إيرث'),
                        ],
                      ),
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

  Widget _mapTypeButton(BuildContext context, MapViewType type, String label) {
    final current = context.watch<MapTypeCubit>().state;
    final isSelected = current == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        onPressed: () {
          context.read<MapTypeCubit>().setMapViewType(type);
        },
        child: Text(label),
      ),
    );
  }
}
