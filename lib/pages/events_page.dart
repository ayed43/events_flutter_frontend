import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late GoogleMapController mapController;
  BitmapDescriptor? customIcon;

  final List<Map<String, dynamic>> _dummyEvents = [
    {
      "title": "Tech Meetup",
      "description": "Innovations in AI & IoT",
      "seats_available": 25,
      "lat": 21.5433,
      "long": 39.1740,
    },
    {
      "title": "Startup Expo",
      "description": "Young minds pitch ideas",
      "seats_available": 10,
      "lat": 21.5438,
      "long": 39.1743,
    },
    {
      "title": "Hackathon Night",
      "description": "24hr coding challenge",
      "seats_available": 45,
      "lat": 21.5441,
      "long": 39.1745,
    },
    {
      "title": "Design Workshop",
      "description": "UI/UX fundamentals",
      "seats_available": 15,
      "lat": 21.5435,
      "long": 39.1738,
    },
    {
      "title": "Blockchain Seminar",
      "description": "Future of decentralized tech",
      "seats_available": 30,
      "lat": 21.5439,
      "long": 39.1741,
    },
    {
      "title": "Networking Mixer",
      "description": "Connect with tech professionals",
      "seats_available": 50,
      "lat": 21.5440,
      "long": 39.1739,
    },
    {
      "title": "VR Demo Day",
      "description": "Experience virtual reality",
      "seats_available": 20,
      "lat": 21.5436,
      "long": 39.1742,
    },
    {
      "title": "Data Science Talk",
      "description": "Machine learning trends",
      "seats_available": 35,
      "lat": 21.5437,
      "long": 39.1744,
    },
    {
      "title": "Coding Bootcamp",
      "description": "Learn Python basics",
      "seats_available": 40,
      "lat": 21.5434,
      "long": 39.1737,
    },
    {
      "title": "Tech Career Fair",
      "description": "Meet top employers",
      "seats_available": 100,
      "lat": 21.5442,
      "long": 39.1746,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
  }

  Future<void> _loadCustomIcon() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(32, 32), devicePixelRatio: 1.0),
      'assets/images/event_marker.png',
    );
    setState(() {}); // Trigger rebuild with the loaded icon
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _zoomToFitAllMarkers();
  }

  Set<Marker> _buildMarkers() {
    return _dummyEvents.map((event) {
      return Marker(
        markerId: MarkerId(event['title']),
        position: LatLng(event['lat'], event['long']),
        infoWindow: InfoWindow(
          title: event['title'],
          snippet:
          "${event['description']} — Seats: ${event['seats_available']}",
        ),
        icon: customIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }).toSet();
  }

  void _zoomToFitAllMarkers() {
    if (_dummyEvents.isEmpty) return;

    final latitudes = _dummyEvents.map((e) => e['lat']);
    final longitudes = _dummyEvents.map((e) => e['long']);

    final bounds = LatLngBounds(
      southwest: LatLng(latitudes.reduce((a, b) => a < b ? a : b),
          longitudes.reduce((a, b) => a < b ? a : b)),
      northeast: LatLng(latitudes.reduce((a, b) => a > b ? a : b),
          longitudes.reduce((a, b) => a > b ? a : b)),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: LatLng(21.5433, 39.1740),
        zoom: 15,
      ),
      markers: _buildMarkers(),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
