import 'package:chewie/chewie.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget{

  final String url;
  VideoWidget(this.url);
  @override
  State<StatefulWidget> createState() {
    return _VideoWidget();
  }
}

class _VideoWidget extends State<VideoWidget>{
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.url);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 3 / 2,
      autoPlay: true,
      autoInitialize: true,
      allowFullScreen: true,
      placeholder: new Container(
        color: Colors.white,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
           Chewie(
                controller: _chewieController,
              ),
          Padding(
          padding: const EdgeInsets.only(top: 13),
            child: IconButton(
              icon: Image.asset("images/btn-close.png",fit: BoxFit.cover,width: ScreenUtil.getInstance().getWidthPx(100),),
              color: Colors.green,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
      ],
    ),);
  }
  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
