import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        children: [
          Text('Hello World',style: TextStyle(fontSize: 24),),
          Text('Hello World2 ',style: TextStyle(fontSize: 24),),
          Text('Hello World2 ',style: TextStyle(fontSize: 24),),
        ],
      ),)
    );
  }
}
