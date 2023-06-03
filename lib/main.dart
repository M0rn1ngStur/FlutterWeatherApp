import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'nav.dart';
import 'package:path_provider/path_provider.dart';

Future<WeatherItem> fetchWeather(String city) async {
  final response = await http.get(Uri.parse(
      'http://api.weatherapi.com/v1/current.json?key=6cc52574e25342c9bf1142032230104&q=${city}'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return WeatherItem.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class WeatherItem {
  final double tempC;
  final double feelslikeC;
  final String condition;
  final String conditionImage;

  const WeatherItem({
    required this.tempC,
    required this.feelslikeC,
    required this.condition,
    required this.conditionImage,
  });

  factory WeatherItem.fromJson(Map<String, dynamic> json) {
    return WeatherItem(
      tempC: json['current']['temp_c'],
      feelslikeC: json['current']['feelslike_c'],
      condition: json['current']['condition']["text"],
      conditionImage: json['current']['condition']["icon"],
    );
  }
}

class CityStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/citysearches.txt');
  }

  Future<List<String>> readCitySearches() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return jsonDecode(contents);
    } catch (e) {
      // If encountering an error, return 0
      return [];
    }
  }

  Future<File> writeCitySearches(List<String> citySearches) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString(jsonEncode(citySearches));
  }
}

void main() => runApp(MyApp(
      storage: CityStorage(),
    ));

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.storage});

  final CityStorage storage;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<WeatherItem> currentWeather;
  String citySearch = "London";
  TextEditingController locationController = TextEditingController();
  List<String> recentSearches = [];

  Future handleClick() async {
    setState(() {
      citySearch = locationController.text;
      currentWeather = fetchWeather(locationController.text);
      addSearch(locationController.text);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.storage.readCitySearches().then((value) {
      setState(() {
        recentSearches = value;
        if (value.isNotEmpty) {
          currentWeather = fetchWeather(value.first);
        }
      });
    });
    currentWeather = fetchWeather("London");
  }

  Future<File> addSearch(String cityName) {
    setState(() {
      if (!recentSearches.contains(cityName)) {
        recentSearches.add(cityName);
      }
    });

    // Write the variable as a string to the file.
    return widget.storage.writeCitySearches(recentSearches);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WeatherApp'),
        ),
        drawer: NavDrawer(
            recentSearches: recentSearches,
            setCity: (String cityName) {
              setState(() {
                citySearch = cityName;
                currentWeather = fetchWeather(cityName);
                locationController.text = cityName;
              });
            }),
        body: Center(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                  // Tell your textfield which controller it owns
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Enter location',
                  )),
            ),
            Center(
              child: ElevatedButton(
                child: Text("Search"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  elevation: 0,
                ),
                onPressed: handleClick,
              ),
            ),
            Center(
              child: Text(citySearch),
            ),
            FutureBuilder<WeatherItem>(
              future: currentWeather,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(children: [
                    Text('Temperature:${snapshot.data!.tempC}'),
                    Text('Feels like:${snapshot.data!.feelslikeC}'),
                    Text('Conditions:${snapshot.data!.condition}'),
                    Image.network('https:${snapshot.data!.conditionImage}'),
                  ]);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            )
          ],
        )),
      ),
    );
  }
}
