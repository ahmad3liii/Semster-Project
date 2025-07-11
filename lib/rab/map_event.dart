// import 'package:equatable/equatable.dart';
// import 'map_event.dart';

// abstract class MapEvent extends Equatable {
//   const MapEvent();

//   @override
//   List<Object> get props => [];
// }

// class FetchMapData extends MapEvent {}
part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class FetchMapData extends MapEvent {}

class FetchDirections extends MapEvent {
  final LatLng origin;
  final LatLng destination;

  const FetchDirections({required this.origin, required this.destination});

  @override
  List<Object> get props => [origin, destination];
}
