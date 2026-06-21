import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/church_provider.dart';
import '../providers/location_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _defaultPosition = LatLng(30.0444, 31.2357);

  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeMap());
  }

  Future<void> _initializeMap() async {
    final churchProvider = context.read<ChurchProvider>();
    final locationProvider = context.read<LocationProvider>();

    await churchProvider.loadChurches();
    final locationAvailable = await locationProvider.getCurrentLocation();

    if (!mounted) return;

    final position = locationProvider.currentPosition;
    if (locationAvailable && position != null) {
      churchProvider.calculateNearestChurch(
        position.latitude,
        position.longitude,
      );
      await mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    } else if (locationProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(locationProvider.errorMessage!)));
    }
  }

  Set<Marker> _buildMarkers(
    ChurchProvider churchProvider,
    LocationProvider locationProvider,
  ) {
    final markers = <Marker>{};
    final nearestChurch = churchProvider.nearestChurch;

    for (final church in churchProvider.churches) {
      final isNearest = church.id == nearestChurch?.id;
      markers.add(
        Marker(
          markerId: MarkerId(church.id),
          position: LatLng(church.latitude, church.longitude),
          infoWindow: InfoWindow(
            title: church.name,
            snippet: isNearest ? 'Nearest church' : church.address,
          ),
          icon: isNearest
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarker,
          zIndexInt: isNearest ? 2 : 1,
        ),
      );
    }

    final position = locationProvider.currentPosition;
    if (position != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          zIndexInt: 3,
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<ChurchProvider, LocationProvider>(
        builder: (context, churchProvider, locationProvider, child) {
          final position = locationProvider.currentPosition;
          final currentPosition = position == null
              ? _defaultPosition
              : LatLng(position.latitude, position.longitude);

          return GoogleMap(
            myLocationEnabled: position != null,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            markers: _buildMarkers(churchProvider, locationProvider),
            initialCameraPosition: CameraPosition(
              target: currentPosition,
              zoom: 9,
            ),
            onMapCreated: (controller) {
              mapController = controller;
              if (position != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(currentPosition, 15),
                );
              }
            },
          );
        },
      ),
    );
  }
}
