import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherDetailPage extends StatefulWidget {
  final Map<String, dynamic> weatherData;
  final Function(String) onCityRemoved;

  const WeatherDetailPage({Key? key, required this.weatherData, required this.onCityRemoved}) : super(key: key);

  @override
  _WeatherDetailPageState createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  Color _backgroundColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _setBackgroundColor();
  }

  void _setBackgroundColor() {
    String mainWeather = widget.weatherData['weather'][0]['main'].toLowerCase();
    setState(() {
      switch (mainWeather) {
        case 'clear':
          _backgroundColor = Color.fromARGB(255, 134, 196, 247);
          break;
        case 'clouds':
          _backgroundColor = Color.fromARGB(255, 52, 112, 241);
          break;
        case 'rain':
          _backgroundColor = Colors.blueGrey;
          break;
        case 'snow':
          _backgroundColor = Colors.lightBlueAccent;
          break;
        case 'thunderstorm':
          _backgroundColor = Colors.deepPurple;
          break;
        case 'mist':
        case 'fog':
          _backgroundColor = const Color.fromARGB(255, 61, 34, 34);
          break;
        default:
          _backgroundColor = Colors.blueGrey;
          break;
      }
    });
  }

  void _removeCity() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCities = prefs.getStringList('savedCities') ?? [];
    savedCities.remove(widget.weatherData['name']);
    await prefs.setStringList('savedCities', savedCities);
    widget.onCityRemoved(widget.weatherData['name']);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.weatherData['name']} removed from saved cities')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao màn hình
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.weatherData['name']),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Remove City'),
                    content: Text('Do you want to remove ${widget.weatherData['name']} from saved cities?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: Text('Remove'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _removeCity();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        color: _backgroundColor,
        height: screenHeight, // Chiều cao full màn hình
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWeatherInfoCard(),
                SizedBox(height: 20),
                _buildTemperatureDetails(),
                SizedBox(height: 20),
                _buildAdditionalInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.weatherData['weather'][0]['main'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.weatherData['weather'][0]['description'],
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            Icon(
              _getWeatherIcon(widget.weatherData['weather'][0]['main']),
              size: 64,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureDetails() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Temperature', style: TextStyle(fontSize: 18)),
                Text(
                  '${widget.weatherData['main']['temp']}°C',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Feels Like', style: TextStyle(fontSize: 16)),
                Text(
                  '${widget.weatherData['main']['feels_like']}°C',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Humidity', '${widget.weatherData['main']['humidity']}%'),
            Divider(),
            _buildInfoRow('Pressure', '${widget.weatherData['main']['pressure']} hPa'),
            Divider(),
            _buildInfoRow('Wind Speed', '${widget.weatherData['wind']['speed']} m/s'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String mainWeather) {
    switch (mainWeather.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.beach_access;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'mist':
      case 'fog':
        return Icons.foggy;
      default:
        return Icons.wb_cloudy;
    }
  }
}