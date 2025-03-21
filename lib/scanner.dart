import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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
    return FutureBuilder<String?>(
      future: getTextFromPhoto(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Pokazuje ładowanie
        } else if (snapshot.hasError) {
          return Text("Błąd: ${snapshot.error}");
        } else if (snapshot.data!.isEmpty){
          return Text("Pusto!");
        }
          else{
          return Text(snapshot.data ?? "Brak tekstu");}
        }
    );
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
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        wasPhotoTaken = false;
                        snapshot = null;
                      });
                    },

                    child: Icon(Icons.cancel_rounded, color: Colors.white70, size: 40,),
                    style: ButtonStyle(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child:
                      Container(
                        width: 200,
                        height: 100,
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

