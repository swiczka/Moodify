import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'drawer.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final String genresJsonString = await loadGenresAsset();
  final List<String> genres = jsonDecode(genresJsonString).cast<String>();
  runApp(MyApp(genres: genres));
}

Future<String> loadGenresAsset() async {
  return await rootBundle.loadString('assets/genres.json');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.genres});

  final List<String> genres;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moodify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: MyHomePage(title: 'Home Page', genres: genres),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title, required this.genres});

  final String title;
  final List<String> genres;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            title: Text("Moodify")
        ),
        drawer: MainDrawer(genres: genres)
    );
  }
}

