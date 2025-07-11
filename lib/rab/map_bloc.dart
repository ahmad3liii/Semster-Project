// import 'dart:async';
// import 'package:bloc/bloc.dart';
// import 'package:dio/dio.dart';
// import 'package:equatable/equatable.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import 'map_event.dart';
// part 'map_state.dart';

// class MapBloc extends Bloc<MapEvent, MapState> {
//   final Dio dio;

//   MapBloc({required this.dio}) : super(MapInitial()) {
//     on<FetchMapData>(_onFetchMapData);
//   }

//   Future<void> _onFetchMapData(
//     FetchMapData event,
//     Emitter<MapState> emit,
//   ) async {
//     emit(MapLoading());
//     try {
//       final response = await dio.get(
//         'https://jsonplaceholder.typicode.com/posts/1',
//       );
//       final LatLng location = LatLng(37.42796133580664, -122.085749655962);
//       emit(MapLoaded(location: location, data: response.data));
//     } catch (e) {
//       emit(MapError(error: e.toString()));
//     }
//   }
// }
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final Dio dio;
  final String googleApiKey;

  MapBloc({required this.dio, required this.googleApiKey})
    : super(MapInitial()) {
    on<FetchMapData>(_onFetchMapData);
    on<FetchDirections>(_onFetchDirections);
  }

  Future<void> _onFetchMapData(
    FetchMapData event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());
    try {
      // يمكنك استبدال هذا بمكالمة API فعلية إذا كنت بحاجة إلى بيانات إضافية
      final response = await dio.get(
        'https://jsonplaceholder.typicode.com/posts/1',
      );
      final LatLng location = LatLng(37.42796133580664, -122.085749655962);
      emit(MapLoaded(location: location, data: response.data));
    } catch (e) {
      emit(MapError(error: e.toString()));
    }
  }

  Future<void> _onFetchDirections(
    FetchDirections event,
    Emitter<MapState> emit,
  ) async {
    emit(DirectionsLoading());
    try {
      final response = await dio.post(
        'https://routes.googleapis.com/directions/v2:computeRoutes',
        options: Options(
          headers: {
            'X-Goog-Api-Key': googleApiKey,
            'Content-Type': 'application/json',
            'X-Goog-FieldMask':
                'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
          },
        ),
        data: {
          "origin": {
            "location": {
              "latLng": {
                "latitude": event.origin.latitude,
                "longitude": event.origin.longitude,
              },
            },
          },
          "destination": {
            "location": {
              "latLng": {
                "latitude": event.destination.latitude,
                "longitude": event.destination.longitude,
              },
            },
          },
          "travelMode": "DRIVE", // أو "WALK", "BICYCLE", "TWO_WHEELER"
          "routingPreference": "TRAFFIC_AWARE", // أو "TRAFFIC_UNAWARE"
        },
      );

      final polyline =
          response.data['routes'][0]['polyline']['encodedPolyline'];
      final duration = response.data['routes'][0]['duration'];
      final distance = response.data['routes'][0]['distanceMeters'];

      emit(
        DirectionsLoaded(
          polyline: polyline,
          duration: duration,
          distance: distance,
        ),
      );
    } on DioException catch (e) {
      emit(
        MapError(
          error:
              "Directions API Error: ${e.response?.data['error_message'] ?? e.message}",
        ),
      );
    } catch (e) {
      emit(MapError(error: "Unexpected error: $e"));
    }
  }
}
