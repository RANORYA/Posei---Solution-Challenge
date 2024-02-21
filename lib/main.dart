import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(WaterTankApp());
}

class WaterTankApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoYouThink',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double waterTankPercentage = 75; // Example water tank percentage
  bool isRaining = false; // Rain status, initially set to false
  String location = ''; // Location information

  @override
  void initState() {
    super.initState();
    _getLocationAndWeatherData();
  }

  Future<void> _getLocationAndWeatherData() async {
    try {
      final permissionStatus = await Geolocator.requestPermission();
      if (permissionStatus == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      } else {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        double latitude = position.latitude;
        double longitude = position.longitude;
        final response = await http.get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=2e9db428708e5b72e78b7dc29cac4c6b'));
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          setState(() {
            isRaining = data['rain'] != null;
            location = data['name'];
          });
        } else {
          throw Exception('Weather data could not be fetched.');
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        location = 'Location information could not be obtained';
      });
    }
  }

  void dispenseWater() {
    setState(() {
      waterTankPercentage -= 10;
      if (waterTankPercentage < 0) {
        waterTankPercentage = 0;
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Water dispensed!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop),
            SizedBox(width: 5),
            Text(
              '$waterTankPercentage%',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Location',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      location,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Rain Status',
                      style: TextStyle(fontSize: 18),
                    ),
                    Row(
                      children: [
                        Icon(
                          isRaining ? Icons.beach_access : Icons.cloud,
                          color: isRaining ? Colors.blue : Colors.grey,
                        ),
                        SizedBox(width: 5),
                        Text(
                          isRaining ? 'Rainy' : 'Not raining',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: waterTankPercentage > 0 ? dispenseWater : null, // Enable the button to be pressed if the water percentage is greater than 0, otherwise disable the button
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Dispense Water',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
