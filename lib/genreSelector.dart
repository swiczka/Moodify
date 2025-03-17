import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'drawer.dart';

class GenreSelector extends StatefulWidget {
  const GenreSelector({super.key, required this.genres});

  final List<String> genres;

  @override
  State<StatefulWidget> createState() => _GenreSelectorState();
}

class _GenreSelectorState extends State<GenreSelector> {

  Map<String, bool> selectedGenres = {};

  TextEditingController searchController = TextEditingController();
  List<String> filteredGenres = [];

  @override
  void initState() {
    super.initState();

    for (var genre in widget.genres) {
      selectedGenres[genre] = false;
    }
    // Initialize filteredGenres with all genres
    filteredGenres = widget.genres;
    searchController.addListener(_filterGenres);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterGenres() {
    setState(() {
      filteredGenres = widget.genres
          .where((genre) =>
          genre.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  List<Widget> buildGenreList() {
    return filteredGenres.map((String genre) {
      return CheckboxListTile(
        title: Text(genre),
        value: selectedGenres[genre],
        onChanged: (bool? value) {
          setState(() {
            selectedGenres[genre] = value!;
          });
        },
      );
    }).toList();
  }

  void saveSelectedGenres() {
    List<String> selected = [];
    selectedGenres.forEach((genre, isSelected) {
      if (isSelected) {
        selected.add(genre);
      }
    });
    print("Selected Genres: $selected");
    // You can now save the selected genres or pass them to another screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose genres you like"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search genres',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // List of genres
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: buildGenreList(),
            ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: saveSelectedGenres,
        child: Text("Save"),
      ),
      drawer: MainDrawer(genres: widget.genres),
    );
  }
}