import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:howdy/ui/screens/preview_screen.dart';
import 'package:howdy/ui/themes/colors.dart';
import 'package:howdy/ui/themes/font_style.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController cameraController;
  AnimationController sizeController;
  Animation<double> sizeAnimation;
  bool isClicked = false;
  String path;
  @override
  void initState() {
    super.initState();

    initializeCamera();
    sizeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 50),
    );
    sizeAnimation = Tween(
      begin: 1.0,
      end: 1.2,
    ).animate(sizeController);
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  initializeCamera() async {
    var cameras = await availableCameras();
    var firstCam = cameras[0];
    cameraController = CameraController(firstCam, ResolutionPreset.high);
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });
    await cameraController.initialize();
  }

  takePhoto() async {
    sizeController.forward();
    setState(() {
      isClicked = !isClicked;
    });
    await Future.delayed(Duration(milliseconds: 100));
    sizeController.reverse();
    setState(() {
      isClicked = !isClicked;
    });

    Directory directory = await getTemporaryDirectory();

    path = directory.path + "/${DateTime.now().microsecondsSinceEpoch}.png";

    await cameraController.takePicture(path);
    print('real path is $path');

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => PreviewScreen(path)));
  }

  takeVideo() async {
    sizeController.forward();
    setState(() {
      isClicked = !isClicked;
    });

    Directory directory = await getTemporaryDirectory();

    path = directory.path + "/${DateTime.now().microsecondsSinceEpoch}.mp4";
    await cameraController.startVideoRecording(path);
  }

  stopVideo() async {
    await cameraController.stopVideoRecording();
    sizeController.reverse();
    setState(() {
      isClicked = !isClicked;
    });
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => PreviewScreen(
                  path,
                  isVideo: true,
                )));
    print('stopped  $path');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),

      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          cameraController != null && cameraController.value.isInitialized
              ? CameraPreview(cameraController)
              : Center(
                  child: Text('Loading'),
                ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.flash_off,
                      color: ConstantColor.white,
                      size: 30,
                    ),
                    ScaleTransition(
                      scale: sizeAnimation,
                      child: GestureDetector(
                        child: FlatButton(
                            shape: CircleBorder(
                                side: BorderSide(
                              color: ConstantColor.white,
                              width: 1,
                            )),
                            color: isClicked ? Colors.red : null,
                            child: SizedBox(
                              height: 80,
                            ),
                            onPressed: () {
                              takePhoto();
                            }),
                        onLongPress: () {
                          print('longpressed');
                          takeVideo();
                        },
                        onLongPressUp: () {
                          print('press up');
                          stopVideo();
                        },
                      ),
                    ),
                    Icon(
                      Icons.flip_camera_ios,
                      color: ConstantColor.white,
                      size: 30,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                StyledText(
                  'Hold for video, tap for photo',
                  size: 16,
                  weight: FontWeight.w400,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
