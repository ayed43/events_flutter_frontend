import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:demo/cubits/home_cobit/home_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;
  String? selectedEventName;
  String? selectedEventDescription;
  LatLng? selectedEventPosition;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing map...');
    _loadMarkersIfReady();
  }

  void _loadMarkersIfReady() {
    final cubit = HomeCubit.get(context);
    if (cubit.state is SuccessState) {
      debugPrint('Loading markers immediately');
      _loadMarkers();
    } else {
      debugPrint('Waiting for events to load...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeStates>(
      listener: (context, state) {
        if (state is SuccessState) {
          debugPrint('Cubit updated with events, reloading markers');
          _loadMarkers();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Events Map'),
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(24.7136, 46.6753), // Default to Riyadh
                zoom: 10,
              ),
              markers: markers,
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
            if (selectedEventName != null && selectedEventPosition != null)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: _buildEventInfoCard(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadMarkers() async {
    final cubit = HomeCubit.get(context);
    if (cubit.state is! SuccessState) return;

    final events = HomeCubit.get(context).events;
    debugPrint('Loading ${events.length} events');

    final newMarkers = await _createMarkers(events);
    setState(() {
      markers = newMarkers;
    });
  }

  Widget _buildEventInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedEventName!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedEventDescription!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Future<Set<Marker>> _createMarkers(List<dynamic> events) async {
    Set<Marker> markers = {};

    for (var event in events) {
      try {
        debugPrint('Creating marker for: ${event.name}');
        final icon = await _getMarkerIcon(event);
        markers.add(
          Marker(
            markerId: MarkerId(event.id.toString()),
            position: LatLng(event.latitude, event.longitude),
            infoWindow: InfoWindow(
              title: event.name,
              snippet: event.description,
            ),
            onTap: () {
              setState(() {
                selectedEventName = event.name;
                selectedEventDescription = event.description;
                selectedEventPosition = LatLng(event.latitude, event.longitude);
              });
            },
            icon: icon,
          ),
        );
      } catch (e) {
        debugPrint('Error creating marker: $e');
        markers.add(
          Marker(
            markerId: MarkerId(event.id.toString()),
            position: LatLng(event.latitude, event.longitude),
            infoWindow: InfoWindow(
              title: event.name,
              snippet: event.description,
            ),
          ),
        );
      }
    }
    debugPrint('Created ${markers.length} markers');
    return markers;
  }

  Future<BitmapDescriptor> _getMarkerIcon(dynamic event) async {
    try {
      const size = 150;
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final radius = size / 2;
      final paint = Paint()..color = Colors.blue;

      canvas.drawCircle(Offset(radius, radius), radius, paint);

      try {
        final imageUrl = '$serverUrl/storage/${event.image}';
        final bytes = await _loadNetworkImageBytes(imageUrl);
        if (bytes != null) {
          final image = await decodeImageFromList(bytes);
          final RRect oval = RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
            Radius.circular(radius),
          );
          canvas.clipRRect(oval);
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
            Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
            Paint(),
          );
        } else {
          _drawIcon(canvas, radius);
        }
      } catch (e) {
        _drawIcon(canvas, radius);
      }

      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(size, size);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
    } catch (e) {
      return BitmapDescriptor.defaultMarker;
    }
  }

  void _drawIcon(Canvas canvas, double radius) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.event.codePoint),
      style: TextStyle(
        fontSize: radius,
        fontFamily: Icons.event.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );
  }

  Future<Uint8List?> _loadNetworkImageBytes(String imageUrl) async {
    try {
      final response = await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
      return response.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}