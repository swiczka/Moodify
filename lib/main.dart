import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'scanner.dart';


void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moodify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage>{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.document_scanner_outlined), text: "Skanuj",),
                    Tab(icon: Icon(Icons.home_outlined), text: "Główna"),
                    Tab(icon: Icon(Icons.favorite_border_outlined), text: "Ulubione"),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
              children: [
                Scanner(),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: searchBar(),
                  ),
                ),
                Text("Something big will be here..."),
              ]
          ),
        ),
      ),
    );
  }
}


SearchAnchor searchBar(){
  return SearchAnchor(
    builder: (BuildContext context, SearchController controller) {
      return SearchBar(
        controller: controller,
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        onTap: () {
          controller.openView();
        },

        onChanged: (_) {
          controller.openView();
        },
        leading: const Icon(Icons.search),
      );
    },
    suggestionsBuilder: (BuildContext context, SearchController controller) {
      return List<ListTile>.generate(5, (int index) {
        final String item = 'item $index';
        return ListTile(
          title: Text(item),
          onTap: () {

          },
        );
      });
    },
  );
}



