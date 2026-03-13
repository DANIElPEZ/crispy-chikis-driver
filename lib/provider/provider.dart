import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class crispyDriverProvider extends ChangeNotifier {
  bool isLive = false;
  final supabase = Supabase.instance.client;
  StreamSubscription<Position>? _positionStreamSubscription;
  Map? destinationPos;
  LatLng? lastPosition;
  double heading = 0.0;
  List<LatLng> routePoints = [];
  LatLng? _lastRouteRequestPos;

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> startStreamUpdateLoc(String orderIdStr, String phone) async {
    try {
      final orderId = int.tryParse(orderIdStr);
      final hasPermission = await _requestPermissions();
      if(orderId ==null || !hasPermission) throw Exception('invalid state');
      destinationPos=await supabase.from('ordenes').update({'phone_order': phone}).eq('orden_id', orderId).select('latitud_destino, longitud_destino').maybeSingle();
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
              (Position? position) {
            if (position != null) {
              lastPosition = LatLng(position.latitude, position.longitude);
              heading = position.heading;
              updateDriverPos(orderId, position.latitude, position.longitude);
              if(destinationPos!=null){
                final dest = LatLng(destinationPos!['latitud_destino'], destinationPos!['longitud_destino']);
                if(_lastRouteRequestPos == null || Geolocator.distanceBetween(
                    _lastRouteRequestPos!.latitude, _lastRouteRequestPos!.longitude,
                    position.latitude, position.longitude) > 20){
                  _lastRouteRequestPos = lastPosition;
                  fetchRoute(dest);
                }
              }
              notifyListeners();
            }
          },
          onError: (error) {
            print('Error en el stream de Geolocator: $error');
          }
      );

      isLive=true;
      notifyListeners();
    } catch (e) {
      print('Error iniciando stream: $e');
    }
  }

  void handlePositionUpdate(Position position, LatLng destination) {
    lastPosition = LatLng(position.latitude, position.longitude);
    heading = position.heading;

    if (routePoints.isEmpty) {
      fetchRoute(destination);
    }
    notifyListeners();
  }

  Future<void> updateDriverPos(int orderId, double lat, double lng)async{
    await supabase.from('ordenes').update({'latitud_envio': lat,'longitud_envio': lng}).eq('orden_id', orderId);
  }

  Future<bool> _requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return (permission != LocationPermission.deniedForever);
  }

  Future<void> fetchRoute(LatLng destination) async {
    if (lastPosition == null) return;

    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${lastPosition!.longitude},${lastPosition!.latitude};'
          '${destination.longitude},${destination.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        routePoints = coords.map((c) => LatLng(c[1], c[0])).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Error obteniendo ruta: $e");
    }
  }

  Future<void> stopStreamLoc() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    isLive = false;
    notifyListeners();
  }
}