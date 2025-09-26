import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:pierwszy/main.dart';
import 'package:pierwszy/searchResultsPage.dart';
import 'package:pierwszy/record.dart';
import 'package:image_cropper/image_cropper.dart';

class Scanner extends StatefulWidget{
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner>{

  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  XFile? snapshot;
  late TextRecognizer textRecognizer;

  @override
  void initState() {
    super.initState();
    _setupCameraController();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  Future<void> _setupCameraController() async{
    List<CameraDescription> _cameras = await availableCameras();
    if(_cameras.isNotEmpty){
      setState(() {
        cameras = _cameras;
        cameraController = CameraController(_cameras.first, ResolutionPreset.high);
      });
      cameraController?.initialize().then((_){
        setState(() {

        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCameraUI()
    );
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<XFile?> takePicture() async {
    if (cameraController == null || cameraController?.value.isInitialized == false) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController?.value.isTakingPicture == true) {
      return null;
    }

    try {
      final XFile? file = await cameraController?.takePicture();
      return file;
    } on CameraException catch (e) {
      showInSnackBar(e.description ?? "Camera error");
      return null;
    }
  }

  bool wasPhotoTaken = false;

  Widget buildPreview(){
    if(!wasPhotoTaken){
      return CameraPreview(cameraController!);
    }
    else{
      if(snapshot == null){
        return CameraPreview(cameraController!);
      }
      else{
        return Image(image: XFileImage(snapshot!));
      }
    }
  }

  List<Record> parseRecords(Map<String, dynamic> json){
    final results = json['results'] as List<dynamic>;
    List<Record> parsedRecords = [];
    for(final element in results){
      parsedRecords.add(Record.fromJson(element as Map<String, dynamic>));
    }
    return parsedRecords;
  }

  Future<List<Record>> fetchQuery(String query) async {
    final response = await http.get(Uri.parse(
        'https://api.discogs.com/database/search?q=${query}&key=mlcelCkAOHAYliDeFqEQ&secret=xKkdpCmTAGBYnJQgPDcgXDNZTwFSjuto'
    ));

    if(response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return parseRecords(decoded);
    }
    else{
      throw Exception('Failed to load album');
    }
  }

  Future<String?> getTextFromPhoto() async {
    if(snapshot == null){
      return "No photo available";
    }
    InputImage input = InputImage.fromFile(File(snapshot!.path));
    RecognizedText text = await textRecognizer.processImage(input);
    textRecognizer.close();
    return text.text;
  }

  Widget buildReadyText() {

    String message = "";
    bool success = false;

    return FutureBuilder<String?>(
      future: getTextFromPhoto(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
          } else if (snapshot.hasError) {
            message = "Błąd: ${snapshot.error}";
          } else if (snapshot.data!.isEmpty) {
            message = "Pusto";
          }
          else {
            message = snapshot.data ?? "Brak tekstu";
            if(snapshot.data != null) success = true;
          }

          if(!success){
            return Container(
              alignment: Alignment.center,
              child: Text(message, style: TextStyle(color: Colors.blueAccent, fontSize: 20),),
            );
          }
          else{
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(message),
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                    final results = await fetchQuery(snapshot.data!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultsPage(records: results,),
                      ),
                      );
                    },
                    child: Icon(Icons.search),
                  )
                ],
              ),
            );
          }

      }
    );
  }

  Future<void> _cropImage() async {
    if (snapshot != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: snapshot!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Przytnij zdjęcie',
            toolbarColor: Colors.blueAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Photo',
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          snapshot = XFile(croppedFile.path);
        });
      }
    }
  }

  Widget _buildCameraUI() {
    if(cameraController == null || cameraController?.value.isInitialized == false){
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              SizedBox(
                  height: MediaQuery.sizeOf(context).height*0.9,
                  width: MediaQuery.sizeOf(context).width,
                  child: buildPreview()
              ),
              if(!wasPhotoTaken) Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: TextButton(

                    onPressed: () async {
                      XFile? newSnapshot = await takePicture();
                      setState(() {
                        snapshot = newSnapshot;
                        wasPhotoTaken = true;
                      });
                    },
                    child: Icon(Icons.photo_camera, size: 60, color: Colors.white70),
                  ),
                ),
              )
              else Stack(
                children: [Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        wasPhotoTaken = false;
                        snapshot = null;
                      });
                    },

                    child: Icon(Icons.cancel_rounded, size: 40,),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: FloatingActionButton(
                    onPressed: () async {
                      await _cropImage();
                    },
                    child: Icon(Icons.crop, size: 40,),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child:
                      Container(
                        width: 300,
                        height: 150,
                        decoration: BoxDecoration(
                            boxShadow: [BoxShadow(blurRadius: 15, spreadRadius: 1, blurStyle: BlurStyle.normal, color: Colors.black45, offset: Offset(10, 10))],
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Colors.white
                        ),
                        child: buildReadyText(),
                      ),
                    ),
                  ),
                ],
              )],
          )
        )
    );
  }


}

