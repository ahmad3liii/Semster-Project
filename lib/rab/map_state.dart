// part of 'map_bloc.dart';

// abstract class MapState extends Equatable {
//   const MapState();

//   @override
//   List<Object> get props => [];
// }

// class MapInitial extends MapState {}

// class MapLoading extends MapState {}

// class MapLoaded extends MapState {
//   final LatLng location;
//   final dynamic data;

//   const MapLoaded({required this.location, required this.data});

//   @override
//   List<Object> get props => [location, data];
// }

// class MapError extends MapState {
//   final String error;

//   const MapError({required this.error});

//   @override
//   List<Object> get props => [error];
// }
part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class DirectionsLoading extends MapState {}

class MapLoaded extends MapState {
  final LatLng location;
  final dynamic data;

  const MapLoaded({required this.location, required this.data});

  @override
  List<Object> get props => [location, data];
}

class DirectionsLoaded extends MapState {
  final String polyline;
  final String duration;
  final int distance;

  const DirectionsLoaded({
    required this.polyline,
    required this.duration,
    required this.distance,
  });

  @override
  List<Object> get props => [polyline, duration, distance];
}

class MapError extends MapState {
  final String error;

  const MapError({required this.error});

  @override
  List<Object> get props => [error];
}
