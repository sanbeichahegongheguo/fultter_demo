import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flustars/flustars.dart';
import 'dart:io';

class CoursewareVideo extends StatefulWidget {
  final FlickManager flickManager;
  final String pic;
  final Function soundAction;
  final bool isHiddenControls;
  CoursewareVideo(this.flickManager, {Key key, this.pic, this.soundAction, this.isHiddenControls = false}) : super(key: key);

  @override
  _CoursewareVideoState createState() => _CoursewareVideoState();
}

class _CoursewareVideoState extends State<CoursewareVideo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlickVideoPlayer(
      flickManager: widget.flickManager,
      preferredDeviceOrientation: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
      flickVideoWithControls: FlickVideoWithControls(
        videoFit: BoxFit.contain,
        playerLoadingFallback: Positioned.fill(
          child: Stack(
            children: <Widget>[
              widget.pic != null
                  ? Positioned.fill(
                      child: Image.file(
                        File(widget.pic),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    strokeWidth: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
        controls: Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: widget.isHiddenControls
              ? Container()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FlickAutoHideChild(
                      autoHide: false,
                      showIfVideoNotInitialized: false,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FlickLeftDuration(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: FlickToggleSoundAction(
                        toggleMute: () {
                          widget.flickManager.flickDisplayManager.handleShowPlayerControls();
                          if (widget.soundAction != null) {
                            widget.soundAction();
                          }
                        },
                      ),
                    ),
//                    FlickAutoHideChild(
//                      autoHide: false,
//                      showIfVideoNotInitialized: false,
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.end,
//                        children: <Widget>[
//                          Container(
//                            padding: EdgeInsets.all(2),
//                            decoration: BoxDecoration(
//                              color: Colors.black38,
//                              borderRadius: BorderRadius.circular(20),
//                            ),
//                            child: FlickSoundToggle(
//                              color: Colors.white,
//                            ),
//                          ),
//                          // FlickFullScreenToggle(),
//                        ],
//                      ),
//                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
