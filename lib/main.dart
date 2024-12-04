import 'package:flutter/material.dart';
import 'weather_service.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final WeatherService _weatherService = WeatherService();
  String _city = 'Hanoi';
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _fetchWeather() async {
    try {
      final data = await _weatherService.fetchWeather(_city);
      setState(() {
        _weatherData = data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            child: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Weather',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: TextField(
                maxLines: 1,
                decoration: InputDecoration(hintText: "Search for a city or airport"),
                onSubmitted: (value) {
                  setState(() {
                    _city = value;
                    _fetchWeather();
                  });
                },
              ),
            ),
            Expanded(
              child: _weatherData != null
                  ? ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => {},
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.location_on),
                                SizedBox(width: 16),
                                Text(_weatherData!['name']),
                                Spacer(),
                                Text('${_weatherData!['main']['temp']}°C'),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}