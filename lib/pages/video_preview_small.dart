import 'package:chewie/chewie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewSmall extends StatefulWidget {
  final String bucket;
  final String videoPath;

  VideoPreviewSmall({Key key, this.videoPath,this.bucket}) : super(key: key);

  @override
  _VideoPreviewSmallState createState() => _VideoPreviewSmallState();
}

class _VideoPreviewSmallState extends State<VideoPreviewSmall> {
  VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    final finalUrl = await _buildVideoURL(widget.bucket, widget.videoPath);
    videoPlayerController = VideoPlayerController.network(finalUrl);
    videoPlayerController.initialize().then((_) {
      if(mounted)
      setState(() {});
    });
  }

  _buildVideoURL(String bucket, String path) async {
    var _url = await FirebaseStorage(storageBucket: '$bucket')
        .ref()
        .child('profileVideos/$path')
        .getDownloadURL();
    return _url;
  }

  @override
  Widget build(BuildContext context) {
    final chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
      showControls: false,
      showOptions: false,
      showControlsOnInitialize: false,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width:MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
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
