import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng _currentPosition = const LatLng(30.0444, 31.2357); // Cairo default
  final Set<Marker> _markers = {};

  final String googleApiKey =
      "AIzaSyDqlxno56gw2XDbYQuQG_t19ZzHERlqScI"; // API Key

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    if (kIsWeb) {
      // Web: استخدمي موقع افتراضي
      _currentPosition = const LatLng(30.0444, 31.2357); // وسط القاهرة
      print("Web detected: Using default location $_currentPosition");
    } else {
      // Mobile: جلب موقع حقيقي
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = LatLng(position.latitude, position.longitude);
      print("Mobile GPS location: $_currentPosition");
    }

    // ماركر الموقع الحالي
    _markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: _currentPosition,
        infoWindow: const InfoWindow(title: "You are here"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );

    // جلب الكنائس حوالين الموقع
    await _getNearbyChurches();

    print("Total markers: ${_markers.length}"); // عدد الكنائس + موقعك

    setState(() {});

    // تحريك الكاميرا
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 15),
    );
  }

  Future<void> _getNearbyChurches() async {
    final url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition.latitude},${_currentPosition.longitude}&radius=5000&type=church&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      for (var place in data['results']) {
        final loc = place['geometry']['location'];
        _markers.add(
          Marker(
            markerId: MarkerId(place['place_id']),
            position: LatLng(loc['lat'], loc['lng']),
            infoWindow: InfoWindow(title: place['name']),
          ),
        );
      }
    } else {
      print("Places API Error: ${data['status']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 14,
        ),
        myLocationEnabled: true,
        markers: _markers,
        onMapCreated: (controller) => mapController = controller,
      ),
    );
  }
}
