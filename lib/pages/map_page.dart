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

  void _hideEventInfo() {
    setState(() {
      selectedEventName = null;
      selectedEventDescription = null;
      selectedEventPosition = null;
    });
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
      child: BlocBuilder<HomeCubit, HomeStates>(
        builder: (context, state) {
          return GestureDetector(
            onTap: _hideEventInfo,
            child: Stack(
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
                    // Try to load markers when map is ready
                    if (state is SuccessState) {
                      debugPrint('Map created and events ready, loading markers');
                      _loadMarkers();
                    }
                  },
                  onTap: (LatLng position) {
                    _hideEventInfo();
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                // Loading indicator when events are still loading
                if (state is LoadingState)
                  const Center(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Loading events...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (selectedEventName != null && selectedEventPosition != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {}, // Prevent hiding when tapping on the card
                      child: _buildEventInfoCard(),
                    ),
                  ),
              ],
            ),
          );
        },
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
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedEventName!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _hideEventInfo,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                selectedEventDescription!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
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
      const size = 160;
      const borderWidth = 6.0;
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final radius = size / 2;

      // Draw outer white border
      final outerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(radius, radius), radius, outerPaint);

      // Draw inner shadow border
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(radius, radius), radius - 2, shadowPaint);

      // Draw main background
      final backgroundPaint = Paint()
        ..color = Colors.blue.shade400
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(radius, radius), radius - borderWidth, backgroundPaint);

      try {
        final imageUrl = '$serverUrl/storage/${event.image}';
        final bytes = await _loadNetworkImageBytes(imageUrl);
        if (bytes != null) {
          final image = await decodeImageFromList(bytes);

          // Create clipping path for the image (smaller circle inside the border)
          final imageRadius = radius - borderWidth;
          final RRect oval = RRect.fromRectAndRadius(
            Rect.fromLTWH(borderWidth, borderWidth,
                (size - borderWidth * 2).toDouble(),
                (size - borderWidth * 2).toDouble()),
            Radius.circular(imageRadius),
          );
          canvas.clipRRect(oval);

          // Draw the image
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
            Rect.fromLTWH(borderWidth, borderWidth,
                size - borderWidth * 2, size - borderWidth * 2),
            Paint()..filterQuality = FilterQuality.high,
          );
        } else {
          _drawEnhancedIcon(canvas, radius, borderWidth);
        }
      } catch (e) {
        _drawEnhancedIcon(canvas, radius, borderWidth);
      }

      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(size, size);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
    } catch (e) {
      return BitmapDescriptor.defaultMarker;
    }
  }

  void _drawEnhancedIcon(Canvas canvas, double radius, double borderWidth) {
    // Create gradient background for icon
    final rect = Rect.fromLTWH(borderWidth, borderWidth,
        (radius * 2) - (borderWidth * 2),
        (radius * 2) - (borderWidth * 2));
    final gradient = ui.Gradient.linear(
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.bottom),
      [Colors.blue.shade300, Colors.blue.shade600],
    );

    final gradientPaint = Paint()..shader = gradient;
    canvas.drawCircle(Offset(radius, radius), radius - borderWidth, gradientPaint);

    // Draw icon with shadow effect
    final shadowTextPainter = TextPainter(textDirection: TextDirection.ltr);
    shadowTextPainter.text = TextSpan(
      text: String.fromCharCode(Icons.event.codePoint),
      style: TextStyle(
        fontSize: radius * 0.8,
        fontFamily: Icons.event.fontFamily,
        color: Colors.black.withOpacity(0.2),
      ),
    );
    shadowTextPainter.layout();
    shadowTextPainter.paint(
      canvas,
      Offset(radius - shadowTextPainter.width / 2 + 2,
          radius - shadowTextPainter.height / 2 + 2),
    );

    // Draw main icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.event.codePoint),
      style: TextStyle(
        fontSize: radius * 0.8,
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