import 'package:chewie/chewie.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final String bucket;
  final String url;

  VideoPreview({Key key, this.bucket, this.url}) : super(key: key);

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
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
      autoPlay: false,
      looping: false,
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),
      backgroundColor: Colors.white,
      body: videoPlayerController!=null && videoPlayerController.value.isInitialized
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
    );
  }
}
