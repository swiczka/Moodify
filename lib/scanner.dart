import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Scanner extends StatefulWidget{
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner>{

  List<CameraDescription> cameras = [];
  CameraController? cameraController;

  @override
  void initState() {
    super.initState();
    _setupCameraController();
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

  Widget _buildCameraUI(){
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
                  child: CameraPreview(cameraController!)
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: FloatingActionButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                      elevation: 10,

                      onPressed: () {
                        //TODO what happens when you click a snap button
                      },
                    child: Icon(Icons.camera_outlined),
                  ),
                ),
              )
            ],
          )
        )
    );
  }
}

