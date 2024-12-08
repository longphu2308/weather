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
  Map<String, Map<String, dynamic>> _savedCitiesWeatherData = {};
  List<String> _savedCities = [];
  String? _errorMessage;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _loadSavedCities();
    _loadThemeMode();
  }

  void _fetchWeather() async {
    try {
      final data = await _weatherService.fetchWeather(_city);
      setState(() {
        _weatherData = data;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to fetch weather for this city';
        _weatherData = null;
      });
      print(e);
    }
  }

  void _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCities = prefs.getStringList('savedCities') ?? [];
    setState(() {
      _savedCities = savedCities;
    });
    for (var city in savedCities) {
      _fetchWeatherForCity(city);
    }
  }

  void _fetchWeatherForCity(String city) async {
    try {
      final data = await _weatherService.fetchWeather(city);
      setState(() {
        _savedCitiesWeatherData[city] = data;
      });
    } catch (e) {
      print('Unable to fetch weather for $city: $e');
    }
  }

  void _saveCityToList() async {
    if (_cityController.text.isNotEmpty) {
      try {
        // Attempt to fetch weather for the city to validate its existence
        final cityWeatherData = await _weatherService.fetchWeather(_cityController.text);
        
        final prefs = await SharedPreferences.getInstance();
        
        // Check if city is already in the list
        if (!_savedCities.contains(cityWeatherData['name'])) {
          setState(() {
            _savedCities.add(cityWeatherData['name']);
            _savedCitiesWeatherData[cityWeatherData['name']] = cityWeatherData;
            prefs.setStringList('savedCities', _savedCities);
          });
          
          // Show a success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${cityWeatherData['name']} added to saved cities'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Show a message if city is already in the list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${cityWeatherData['name']} is already in your saved cities'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        
        _cityController.clear();
      } catch (e) {
        // Show error if city can't be found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not find weather data for this city'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedCities.remove(city);
      _savedCitiesWeatherData.remove(city);
      prefs.setStringList('savedCities', _savedCities);
    });
  }

  void _removeAllCities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedCities.clear();
      _savedCitiesWeatherData.clear();
      prefs.setStringList('savedCities', _savedCities);
    });
  }

  // Function to get weather icon based on condition
  IconData _getWeatherIcon(String condition) {
    // You might want to expand this with more specific conditions
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.water_drop;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }

  void _toggleThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    });
  }

  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      home: ScaffoldMessenger(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weather',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
                          color: Colors.blue,
                        ),
                        onPressed: _toggleThemeMode,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever, color: Colors.blue),
                        onPressed: _removeAllCities,
                      ),
                    ],
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
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: _cityController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    _cityController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.blue.shade200, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.blue, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                        onSubmitted: (value) {
                          setState(() {
                            _city = value;
                            _fetchWeather();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.blue, size: 40),
                      onPressed: _saveCityToList,
                    ),
                  ],
                ),
              ),
              // Error message display
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              // Saved cities list
              Expanded(
                child: _savedCities.isNotEmpty
                    ? ListView.builder(
                        itemCount: _savedCities.length,
                        itemBuilder: (context, index) {
                          final city = _savedCities[index];
                          final weatherData = _savedCitiesWeatherData[city];
                          return Dismissible(
                            key: Key(city),
                            background: Container(
                              color: Colors.red,
                              child: Icon(Icons.delete, color: Colors.white),
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _removeCity(city);
                            },
                            child: Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: weatherData != null
                                    ? Icon(
                                        _getWeatherIcon(weatherData['weather'][0]['main']),
                                        color: Colors.blue,
                                        size: 30,
                                      )
                                    : Icon(
                                        Icons.wb_cloudy,
                                        color: Colors.blue,
                                        size: 30,
                                      ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      city,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (weatherData != null)
                                      Text(
                                        '${weatherData['main']['temp']}°C',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Icon(Icons.chevron_right, color: Colors.blue),
                                onTap: () async {
                                  try {
                                    final weatherData = await _weatherService.fetchWeather(city);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WeatherDetailPage(
                                          weatherData: weatherData,
                                          onCityRemoved: _removeCity,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to load weather data'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'No saved cities',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}