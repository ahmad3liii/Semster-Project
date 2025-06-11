// // import 'package:flutter/material.dart';

// // void main() {
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   // This widget is the root of your application.
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Flutter Demo',
// //       theme: ThemeData(
// //         // This is the theme of your application.
// //         //
// //         // TRY THIS: Try running your application with "flutter run". You'll see
// //         // the application has a purple toolbar. Then, without quitting the app,
// //         // try changing the seedColor in the colorScheme below to Colors.green
// //         // and then invoke "hot reload" (save your changes or press the "hot
// //         // reload" button in a Flutter-supported IDE, or press "r" if you used
// //         // the command line to start the app).
// //         //
// //         // Notice that the counter didn't reset back to zero; the application
// //         // state is not lost during the reload. To reset the state, use hot
// //         // restart instead.
// //         //
// //         // This works for code too, not just values: Most code changes can be
// //         // tested with just a hot reload.
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// //       ),
// //       home: const MyHomePage(title: 'Flutter Demo Home Page'),
// //     );
// //   }
// // }

// // class MyHomePage extends StatefulWidget {
// //   const MyHomePage({super.key, required this.title});

// //   // This widget is the home page of your application. It is stateful, meaning
// //   // that it has a State object (defined below) that contains fields that affect
// //   // how it looks.

// //   // This class is the configuration for the state. It holds the values (in this
// //   // case the title) provided by the parent (in this case the App widget) and
// //   // used by the build method of the State. Fields in a Widget subclass are
// //   // always marked "final".

// //   final String title;

// //   @override
// //   State<MyHomePage> createState() => _MyHomePageState();
// // }

// // class _MyHomePageState extends State<MyHomePage> {
// //   int _counter = 0;

// //   void _incrementCounter() {
// //     setState(() {
// //       // This call to setState tells the Flutter framework that something has
// //       // changed in this State, which causes it to rerun the build method below
// //       // so that the display can reflect the updated values. If we changed
// //       // _counter without calling setState(), then the build method would not be
// //       // called again, and so nothing would appear to happen.
// //       _counter++;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // This method is rerun every time setState is called, for instance as done
// //     // by the _incrementCounter method above.
// //     //
// //     // The Flutter framework has been optimized to make rerunning build methods
// //     // fast, so that you can just rebuild anything that needs updating rather
// //     // than having to individually change instances of widgets.
// //     return Scaffold(
// //       appBar: AppBar(
// //         // TRY THIS: Try changing the color here to a specific color (to
// //         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
// //         // change color while the other colors stay the same.
// //         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
// //         // Here we take the value from the MyHomePage object that was created by
// //         // the App.build method, and use it to set our appbar title.
// //         title: Text(widget.title),
// //       ),
// //       body: Center(
// //         // Center is a layout widget. It takes a single child and positions it
// //         // in the middle of the parent.
// //         child: Column(
// //           // Column is also a layout widget. It takes a list of children and
// //           // arranges them vertically. By default, it sizes itself to fit its
// //           // children horizontally, and tries to be as tall as its parent.
// //           //
// //           // Column has various properties to control how it sizes itself and
// //           // how it positions its children. Here we use mainAxisAlignment to
// //           // center the children vertically; the main axis here is the vertical
// //           // axis because Columns are vertical (the cross axis would be
// //           // horizontal).
// //           //
// //           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
// //           // action in the IDE, or press "p" in the console), to see the
// //           // wireframe for each widget.
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             Text('Hello', style: TextStyle(color: Colors.blue, fontSize: 50)),
// //             Text(
// //               '$_counter',
// //               style: Theme.of(context).textTheme.headlineMedium,
// //             ),
// //           ],
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: _incrementCounter,
// //         tooltip: 'Increment',
// //         child: const Icon(Icons.add),
// //       ), // This trailing comma makes auto-formatting nicer for build methods.
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:dio/dio.dart';
// import 'package:transportmap/map_event.dart';
// import 'map_bloc.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: BlocProvider(
//         create: (context) => MapBloc(dio: Dio()),
//         child: MapScreen(),
//       ),
//     );
//   }
// }

// class MapScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Google Maps with Bloc')),
//       body: BlocBuilder<MapBloc, MapState>(
//         builder: (context, state) {
//           if (state is MapInitial) {
//             context.read<MapBloc>().add(FetchMapData());
//             return Center(child: Text('Initializing...'));
//           } else if (state is MapLoading) {
//             return Center(child: CircularProgressIndicator());
//           } else if (state is MapLoaded) {
//             return Column(
//               children: [
//                 Expanded(
//                   child: GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: state.location,
//                       zoom: 14,
//                     ),
//                     markers: {
//                       Marker(markerId: MarkerId('1'), position: state.location),
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Text('Fetched Data: ${state.data['title']}'),
//                 ),
//               ],
//             );
//           } else if (state is MapError) {
//             return Center(child: Text('Error: ${state.error}'));
//           }
//           return Center(child: Text('Unknown state'));
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'map_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => MapBloc(
          dio: Dio(),
          googleApiKey:
              'AIzaSyA33lbD_9fb8isa-eI9a4nMEFPES9KSVBA', // استبدل بمفتاح API الفعلي
        ),

        child: MapScreen(),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = LatLng(37.42796133580664, -122.085749655962);
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    // تحميل البيانات الأولية عند بدء التشغيل
    context.read<MapBloc>().add(FetchMapData());
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _fetchDirections(LatLng origin, LatLng destination) async {
    // مسح العلامات والمسارات القديمة
    setState(() {
      _markers.clear();
      _polylines.clear();
    });

    // إضافة علامة المنشأ (لون أخضر)
    _markers.add(
      Marker(
        markerId: MarkerId('origin'),
        position: origin,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Origin', snippet: 'Start point'),
      ),
    );

    // إضافة علامة الوجهة (لون أحمر)
    _markers.add(
      Marker(
        markerId: MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'Destination', snippet: 'End point'),
      ),
    );

    // إرسال طلب الحصول على الاتجاهات
    context.read<MapBloc>().add(
      FetchDirections(origin: origin, destination: destination),
    );

    // تحديث الخريطة لعرض العلامات الجديدة
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transport Map with Directions'),
        leading: IconButton(
          icon: Icon(Icons.center_focus_strong),
          onPressed: () {
            mapController.animateCamera(
              CameraUpdate.newLatLng(_initialPosition),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.directions, color: Colors.blue),
            tooltip: 'Get Directions',
            onPressed: () {
              // يمكنك استبدال هذه الإحداثيات بقيم مناسبة لتطبيقك
              // أو الحصول عليها من مستخدم
              _fetchDirections(
                // LatLng(35.449185, 36.072590), // سان فرانسيسكو
                // LatLng(35.546323, 35.770380),
                LatLng(37.7749, -122.4194), // سان فرانسيسكو
                LatLng(34.0522, -118.2437), // لوس أنجلوس
              );

              // إظهار مؤشر تحميل
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fetching directions...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is DirectionsLoaded) {
            // تحويل polyline إلى قائمة نقاط
            final points = _decodePolyline(state.polyline);

            setState(() {
              // إضافة المسار الجديد
              _polylines.add(
                Polyline(
                  polylineId: PolylineId('route'),
                  points: points,
                  color: Colors.blue,
                  width: 5,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                  jointType: JointType.round,
                ),
              );

              // توجيه الكاميرا لتظهر المسار كاملاً
              mapController.animateCamera(
                CameraUpdate.newLatLngBounds(
                  _boundsFromLatLngList(points),
                  100, // padding
                ),
              );
            });
          }
        },
        // listener: (context, state) {
        //   if (state is DirectionsLoaded) {
        //     // إضافة المسار إلى الخريطة عند استلام البيانات
        //     setState(() {
        //       _polylines.add(
        //         Polyline(
        //           polylineId: PolylineId('route'),
        //           points: _decodePolyline(state.polyline),
        //           color: Colors.blue,
        //           width: 5,
        //         ),
        //       );
        //     });

        //     // توجيه الكاميرا لتظهر المسار كاملاً
        //     mapController.animateCamera(
        //       CameraUpdate.newLatLngBounds(
        //         _boundsFromLatLngList(_decodePolyline(state.polyline)),
        //         100,
        //       ),
        //     );
        //   }
        // },
        builder: (context, state) {
          if (state is MapInitial || state is MapLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is MapError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.error}'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // print("Error: ${state.error}");
                        context.read<MapBloc>().add(FetchMapData());
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 12,
                ),
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
              if (state is DirectionsLoaded)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Route Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Distance: ${(state.distance / 1000).toStringAsFixed(1)} km',
                          ),
                          Text('Duration: ${state.duration}'),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.center_focus_strong),
      //   onPressed: () {
      //     mapController.animateCamera(CameraUpdate.newLatLng(_initialPosition));
      //   },
      // ),
    );
  }

  // دالة لفك تشفير polyline
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
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

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  // دالة لحساب الحدود الجغرافية لقائمة نقاط
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }
}
