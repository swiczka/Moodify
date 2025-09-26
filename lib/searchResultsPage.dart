import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pierwszy/record.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchResultsPage extends StatefulWidget {
  
  final List<Record> records;
  
  const SearchResultsPage({super.key, required this.records});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage>{

  List<Widget> getWidgetsFromRecords(List<Record> records){
    List<Widget> finalWidgets = [];
    for(final record in records){
      finalWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Image.network(
                      record.thumb,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image, size: 100);
                      },
                    ),

                    Text(record.type, style: TextStyle(fontSize: 18),),

                    InkWell(
                      child: Icon(Icons.open_in_new, size: 35),
                      onTap: () => launchUrl(Uri.parse(Record.domain+record.uri))
                    )
                  ],
                ),
            ),
          ),
        ),


      );
    }
    return finalWidgets;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wyniki wyszukiwania")
      ),
      // body: ListView.separated(
      //   padding: EdgeInsets.all(8),
      //   itemCount: widget.records.length,
      //   separatorBuilder: (context, index) => const Divider(),
      //   children: getWidgetsFromRecords(widget.records)
      // )
      body: ListView(
          padding: EdgeInsets.all(8),
          children: getWidgetsFromRecords(widget.records)
      )
    );
  }
}
