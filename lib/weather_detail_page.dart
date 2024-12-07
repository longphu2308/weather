import 'package:flutter/material.dart';

class WeatherDetailPage extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherDetailPage({Key? key, required this.weatherData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(weatherData['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature: ${weatherData['main']['temp']}°C',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              'Feels Like: ${weatherData['main']['feels_like']}°C',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Humidity: ${weatherData['main']['humidity']}%',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Weather: ${weatherData['weather'][0]['description']}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}