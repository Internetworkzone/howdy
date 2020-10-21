import 'dart:io';
import 'package:flutter/material.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/status_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PreviewScreen extends StatefulWidget {
  PreviewScreen(this.path, {this.isVideo = false});
  final String path;
  final bool isVideo;

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  VideoPlayerController videoPlayerController;
  String caption;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(File(widget.path));
    videoPlayerController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    ColorService color = Provider.of<ColorService>(context);
    User user = Provider.of<UserService>(context).user;
    videoPlayerController.play();
    print(videoPlayerController.value.initialized);
    return Scaffold(
      body: Stack(
        children: [
          widget.isVideo
              ? Column(
                  children: [
                    AspectRatio(
                        aspectRatio: videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(videoPlayerController)),
                    Flexible(
                        child: VideoProgressIndicator(
                      videoPlayerController,
                      allowScrubbing: false,
                    )),
                  ],
                )
              : Image.file(
                  File(widget.path),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                color: Color(0x55000000),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.image),
                        // VerticalDivider(),
                        Flexible(
                          child: TextField(),
                        ),
                        MaterialButton(
                          shape: CircleBorder(),
                          child: Icon(Icons.send),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ],
                )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color.primaryColor,
        child: Icon(Icons.send),
        onPressed: () async {
          Navigator.pop(context);

          await StatusService().uploadStatus(
            uid: user.uid,
            path: widget.path,
            isMultimedia: true,
            caption: caption,
            userName: user.name,
            type: widget.isVideo ? 'mp4' : 'png',
          );
        },
      ),
    );
  }
}
