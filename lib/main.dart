import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<WeatherItem> currentWeather;
  TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    currentWeather = fetchWeather("London");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<WeatherItem>(
            future: currentWeather,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(children: [
                  Text('Temperatura:${snapshot.data!.tempC}'),
                  Text('Odczuwalna temperatura:${snapshot.data!.feelslikeC}'),
                  Text('Warunki pogodowe:${snapshot.data!.condition}'),
                  Image.network('https:${snapshot.data!.conditionImage}'),
                ]);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}