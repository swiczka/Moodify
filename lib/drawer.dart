import 'package:flutter/material.dart';
import 'genreSelector.dart';
import 'main.dart';

class MainDrawer extends StatelessWidget{
  const MainDrawer({super.key, required this.genres});

  final List<String> genres;

  @override
  Widget build(BuildContext context){
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                      begin: Alignment(0, -1),
                      end: Alignment(0, 1)
                  )
              ),
              child: Text("Actions", style: TextStyle(fontSize: 20, color: Colors.white),),
            ),
            ListTile(
              title: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.home_outlined),
                  Text(' Home page'),
                ],
              ),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: "Home Page", genres: genres,))
                );
              },
            ),
            ListTile(
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.library_music_outlined),
                    Text(' Customize your genres'),
                  ],
                ),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => GenreSelector(genres: genres))
                  );
                }
            ),
            ListTile(
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.history),
                    Text(' History'),
                  ],
                ),
                onTap: () {
                  //TODO implement history
                }
            )
          ],
        )
    );
  }
}