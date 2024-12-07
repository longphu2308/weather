import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_service.dart';
import 'weather_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();
  String _city = 'Hanoi';
  Map<String, dynamic>? _weatherData;
  List<String> _savedCities = [];

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _loadSavedCities();
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

  void _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedCities = prefs.getStringList('savedCities') ?? [];
    });
  }

  void _saveCityToList() async {
    if (_cityController.text.isNotEmpty && !_savedCities.contains(_cityController.text)) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _savedCities.add(_cityController.text);
        prefs.setStringList('savedCities', _savedCities);
      });
      _cityController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
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
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "Search for a city or airport",
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          _city = value;
                          _fetchWeather();
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle),
                    onPressed: _saveCityToList,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _savedCities.isNotEmpty
                  ? ListView.builder(
                      itemCount: _savedCities.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_savedCities[index]),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () async {
                            final weatherData = await _weatherService.fetchWeather(_savedCities[index]);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WeatherDetailPage(weatherData: weatherData),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : Center(child: Text('No saved cities')),
            ),
          ],
        ),
      ),
    );
  }
}