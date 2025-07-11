import 'package:bloc/bloc.dart';

enum MapViewType { normal, satellite, hybrid, terrain, tilted, earth }

class MapTypeCubit extends Cubit<MapViewType> {
  MapTypeCubit() : super(MapViewType.normal);

  void setMapViewType(MapViewType type) {
    emit(type);
  }
}
