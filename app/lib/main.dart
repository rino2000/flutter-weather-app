// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, non_constant_identifier_names
import 'dart:convert';
import 'package:app/model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

// Website to convert json to Dart class
// https://javiercbk.github.io/json_to_dart/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String KEY =
      ''; // PASS YOUR API KEY FROM https://www.weatherapi.com/
  late Future<WeatherData> future;
  late Future<List<Suggestion>> future_suggestion;
  String _city = "Lissabon"; // Default city
  TextEditingController city_controller = TextEditingController();

  Future<WeatherData> fetchWeather(String? city) async {
    final response = await http.get(Uri.parse(
        'http://api.weatherapi.com/v1/forecast.json?key=$KEY&q=$city&days=1&aqi=no&alerts=no'));
    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather');
    }
  }

  Future<List<Suggestion>> fetchSuggestions(String? city) async {
    final response = await http.get(
        Uri.parse('http://api.weatherapi.com/v1/search.json?key=$KEY&q=$city'));
    if (response.statusCode == 200) {
      List<Suggestion> suggestions = (json.decode(response.body) as List)
          .map((data) => Suggestion.fromJson(data))
          .toList();
      return suggestions;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  void initState() {
    super.initState();
    future = fetchWeather(_city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40,
          color: Colors.white,
          child: Center(
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(suffixIcon: Icon(Icons.search)),
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: 20),
              ),
              suggestionsCallback: (pattern) async {
                return await fetchSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion.toString()),
                );
              },
              onSuggestionSelected: (suggestion) => setState(
                () {
                  _city = suggestion.toString();
                  future = fetchWeather(_city);
                },
              ),
            ),
          ),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.red, Colors.red],
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red, Colors.blue],
          ),
        ),
        child: Weather(
          future: future,
        ),
      ),
    );
  }
}

class Weather extends StatefulWidget {
  final Future<WeatherData> future;
  const Weather({Key? key, required this.future}) : super(key: key);

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherData>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator.adaptive());
        }
        return Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Text(
              snapshot.data!.location!.name.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            Text(
              "Last updated " +
                  snapshot.data!.current!.lastUpdated
                      .toString()
                      .replaceRange(0, 10, ""),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              snapshot.data!.current!.tempC!.toStringAsFixed(0) + "°",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 150,
              ),
            ),
            WeatherInfo(
              uv: snapshot.data!.current!.uv.toString(),
              feelslike: snapshot.data!.current!.feelslikeC.toString() + "°C",
              wd: snapshot.data!.current!.windDir.toString(),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      snapshot.data!.forecast!.forecastday![0].hour!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                snapshot.data!.forecast!.forecastday![0]
                                    .hour![index].time
                                    .toString()
                                    .replaceRange(0, 10, ""),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: const [
                                        Colors.pinkAccent,
                                        Colors.deepPurpleAccent,
                                        Colors.red
                                        //add more color here.
                                      ],
                                    ).createShader(
                                      Rect.fromLTWH(0.0, 0.0, 200.0, 100.0),
                                    ),
                                ),
                              ),
                              const Icon(Icons.cloud, size: 30),
                              Text(
                                snapshot.data!.forecast!.forecastday![0]
                                        .hour![index].tempC!
                                        .toStringAsFixed(0) +
                                    "°",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: const [
                                        Colors.pinkAccent,
                                        Colors.deepPurpleAccent,
                                        Colors.red
                                        //add more color here.
                                      ],
                                    ).createShader(
                                      Rect.fromLTWH(0.0, 0.0, 200.0, 100.0),
                                    ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class WeatherInfo extends StatefulWidget {
  final String? uv, feelslike, wd;
  const WeatherInfo({Key? key, this.uv, this.feelslike, this.wd})
      : super(key: key);

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "UV = ${widget.uv}",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Feelslike = ${widget.feelslike}",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Wind direction = ${widget.wd}",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
