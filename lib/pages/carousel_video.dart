import 'package:chewie/chewie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CarouselVideo extends StatefulWidget {
  final String bucket;
  final String url;

  CarouselVideo({Key key, this.bucket, this.url}) : super(key: key);

  @override
  _CarouselVideoState createState() => _CarouselVideoState();
}

class _CarouselVideoState extends State<CarouselVideo> {
  VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    final finalUrl = await _buildVideoURL(widget.bucket, widget.url);
    videoPlayerController = VideoPlayerController.network(finalUrl);
    videoPlayerController.initialize().then((_) {
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
    );

    return videoPlayerController != null &&
        videoPlayerController.value.isInitialized
        ? Center(
      child: Chewie(
        controller: chewieController,
      ),
    )
        : Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
