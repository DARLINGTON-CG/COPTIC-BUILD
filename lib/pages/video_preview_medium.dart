import 'package:chewie/chewie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewMedium extends StatefulWidget {
  final String url;

  VideoPreviewMedium(this.url);

  @override
  _VideoPreviewMediumState createState() => _VideoPreviewMediumState();
}

class _VideoPreviewMediumState extends State<VideoPreviewMedium> {
  VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    videoPlayerController = VideoPlayerController.network(widget.url);
    videoPlayerController.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,
      showControls: true,
      showOptions: false,
      showControlsOnInitialize: false,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration:BoxDecoration(
          gradient: new LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ],
                begin: const FractionalOffset(1.0, 0.0),
                end: const FractionalOffset(0.0, 0.7),
                stops: [0.3, 1.0],
                tileMode: TileMode.clamp)
        ),
        child: videoPlayerController!=null && videoPlayerController.value.isInitialized
            ? Center(
          child: Chewie(
            controller: chewieController,
          ),
        )
            : Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
