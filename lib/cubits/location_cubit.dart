import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transportmap/services/map_services.dart';

class LocationCubit extends Cubit<LatLng?> {
  LocationCubit() : super(null);

  /// تحديث الموقع الحالي
  Future<void> updateLocation() async {
    final location = await LocationService.getCurrentLocation();
    emit(location);
  }
}
