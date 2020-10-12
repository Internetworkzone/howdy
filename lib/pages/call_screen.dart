import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RemoteView;
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as LocalView;
import 'package:howdy/modals/call.dart';
import 'package:howdy/modals/constants.dart';
import 'package:howdy/modals/user.dart';
import 'package:howdy/services/app_id.dart';
import 'package:howdy/services/call_service.dart';
import 'package:howdy/services/color_service.dart';
import 'package:howdy/services/user_service.dart';
import 'package:provider/provider.dart';

class CallScreen extends StatefulWidget {
  CallScreen({
    this.isCaller = false,
    this.call,
    this.audioPlayer,
  });

  final Call call;
  final bool isCaller;
  final AudioPlayer audioPlayer;
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  Animation<Offset> localViewPositon;
  AnimationController localViewPositonController;
  int remoteUserId;
  RtcEngine engine;
  double viewPosition = 0.0;
  double x = 0;
  double y = 0;
  CallService callService = CallService();
  bool isPicked = false;
  Timer timer;
  bool isVisible = false;

  @override
  void dispose() {
    super.dispose();
    localViewPositonController.dispose();
    remoteUserId = null;

    if (timer != null && timer.isActive) timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isCaller) {
      initiateCall();
    }
    localViewPositonController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1),
    );
    updateLocalViewPosition();
  }

  updateLocalViewPosition() {
    localViewPositon = localViewPositonController.drive(Tween(
      begin: Offset.zero,
      end: Offset(0.0, 3.0),
    ));
  }

  handleHorizontalPosition(DragUpdateDetails details) {
    viewPosition += details.primaryDelta;
    updateLocalViewPosition();

    localViewPositonController.value = viewPosition / context.size.width;
  }

  handleVerticalPosition(DragUpdateDetails details) {
    viewPosition += details.primaryDelta;
    updateLocalViewPosition();
    localViewPositonController.value = viewPosition / context.size.height;
  }

  Future<void> initiateCall() async {
    engine = await RtcEngine.create(AppId);

    engine.setEventHandler(
      RtcEngineEventHandler(
        error: (error) {},
        joinChannelSuccess: (channel, uid, elapsed) async {
          await callService.makeCall(
            widget.call,
          );
          if (widget.audioPlayer != null &&
              widget.audioPlayer.state == AudioPlayerState.PLAYING)
            widget.audioPlayer.stop();
        },
        userJoined: (uid, elapsed) {
          if (timer != null && timer.isActive) {
            timer.cancel();
          }
          setState(() {
            remoteUserId = uid;
            isPicked = true;
          });
          showIcons();
        },
        leaveChannel: (stats) {
          remoteUserId = null;
          if (widget.isCaller)
            callService.disConnectCall(widget.call, isPicked);
          if (widget.audioPlayer.state == AudioPlayerState.PLAYING)
            widget.audioPlayer.stop();
        },
        userOffline: (uid, reason) async {
          remoteUserId = null;
          await endCall();

          if (widget.isCaller) Navigator.pop(context);
        },
        firstRemoteVideoFrame: (uid, width, height, elapsed) {},
      ),
    );
    if (widget.call.calltype == CallType.video) {
      await engine.enableVideo();
    } else {
      await engine.enableAudio();
    }
    await engine.joinChannel(null, '123', null, 0);

    if (widget.isCaller) {
      timer = Timer(Duration(seconds: 15), () async {
        await endCall();

        Navigator.pop(context);
      });
    }
  }

  Future<void> endCall() async {
    engine.leaveChannel();
    engine.destroy();
  }

  showIcons() {
    if (timer != null && timer.isActive) {
      setState(() {
        isVisible = !isVisible;
      });
      timer.cancel();
    } else {
      setState(() {
        isVisible = !isVisible;
      });
      if (widget.call.calltype == CallType.video) {
        timer = Timer(Duration(seconds: 5), () {
          setState(() {
            isVisible = !isVisible;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorService color = Provider.of<ColorService>(context, listen: false);
    return Scaffold(
      backgroundColor: color.primaryColor,
      body: Stack(
        children: remoteUserId != null ? inCallView() : initialView(),
      ),
    );
  }

  List<Widget> initialView() {
    return [
      widget.call.calltype == CallType.video && widget.isCaller
          ? LocalView.SurfaceView()
          : SizedBox(),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Material(
                    shape: CircleBorder(),
                    child: Icon(Icons.person, size: 100),
                  ),
                  SizedBox(height: 30),
                  Text(
                    widget.isCaller
                        ? widget.call.receiverName
                        : widget.call.callerName,
                    style: TextStyle(
                      fontSize: 30,
                      color: white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.isCaller ? 'Ringing' : 'Calling',
                    style: TextStyle(
                      fontSize: 20,
                      color: white,
                    ),
                  ),
                ],
              ),
              SizedBox(),
              Row(
                mainAxisAlignment: widget.isCaller
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceAround,
                children: [
                  MaterialButton(
                    color: Colors.red,
                    padding: EdgeInsets.all(15),
                    shape: CircleBorder(),
                    child: Icon(
                      Icons.call_end_sharp,
                      color: white,
                      size: 40,
                    ),
                    onPressed: () async {
                      await endCall();
                      if (widget.isCaller) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  widget.isCaller
                      ? SizedBox()
                      : MaterialButton(
                          color: Colors.green,
                          padding: EdgeInsets.all(15),
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.call,
                            color: white,
                            size: 40,
                          ),
                          onPressed: () async {
                            await initiateCall();
                          },
                        ),
                ],
              ),
            ],
          ),
        ),
      )
    ];
  }

  List<Widget> inCallView() {
    return [
      widget.call.calltype == CallType.video
          ? GestureDetector(
              child: RemoteView.SurfaceView(uid: remoteUserId),
              onTap: showIcons,
            )
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    shape: CircleBorder(),
                    child: Icon(Icons.person, size: 100),
                  ),
                  SizedBox(height: 30),
                  Text(
                    widget.isCaller
                        ? widget.call.receiverName
                        : widget.call.callerName,
                    style: TextStyle(
                      fontSize: 30,
                      color: white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'On call  03:36',
                    style: TextStyle(
                      fontSize: 20,
                      color: white,
                    ),
                  ),
                ],
              ),
            ),
      isVisible
          ? Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                      color: Colors.red,
                      padding: EdgeInsets.all(15),
                      shape: CircleBorder(),
                      child: Icon(
                        Icons.call_end_sharp,
                        color: white,
                        size: 40,
                      ),
                      onPressed: () async {
                        await endCall();
                        if (widget.isCaller) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          child: Icon(
                            Icons.switch_camera,
                            color: white,
                            size: 30,
                          ),
                          onTap: () {
                            engine.switchCamera();
                          },
                        ),
                        Icon(
                          Icons.videocam_off,
                          color: white,
                          size: 30,
                        ),
                        Icon(
                          Icons.mic_off,
                          color: white,
                          size: 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(),
      widget.call.calltype == CallType.video
          ? Padding(
              padding: const EdgeInsets.only(right: 5.0, bottom: 50),
              child: Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Container(
                      color: Colors.blueGrey,
                      height: 160,
                      width: 120,
                      child: LocalView.SurfaceView(),
                    ),
                  ),
                  // onHorizontalDragUpdate: handleHorizontalPosition,
                  // onVerticalDragUpdate: handleVerticalPosition,
                  onPanUpdate: (details) {
                    setState(() {
                      x = details.delta.dx;
                      y = details.delta.dy;
                    });
                  },
                ),
              ),
            )
          : SizedBox(),
    ];
  }
}
