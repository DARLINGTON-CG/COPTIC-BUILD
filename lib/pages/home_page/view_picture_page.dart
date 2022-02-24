import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/services/location/location.dart';
import 'package:copticmeet/utils/color_utils.dart';
import 'package:copticmeet/widgets/liking_animation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ViewPicturePage extends StatefulWidget {
  final Location location;
  final Database database;
  final String preferences;
  final PageController controller;
  final List images;
  final userID;
  final userInfo;

  const ViewPicturePage(
      {Key key,
      @required this.location,
      @required this.database,
      @required this.preferences,
      @required this.controller,
      @required this.images,
      @required this.userInfo,
      @required this.userID})
      : super(key: key);

  @override
  _ViewPicturePageState createState() => _ViewPicturePageState();
}

class _ViewPicturePageState extends State<ViewPicturePage> {
  int likedPhotoIndex = 0;
  bool indexLiked = false;
  bool isLikeAnimating = false;
  List<dynamic> localLikedMyPhotos;

  @override
  void initState() {
    super.initState();

    indexLiked = widget.userInfo['likedMyPhotos'].toString().contains(
        "{\"userID\":\"${widget.database.userId}\",\"likedPhotoLink\":\"${widget.images[likedPhotoIndex]?.url}\"}");

    if (jsonDecode(widget.userInfo['likedMyPhotos'].toString()) != null) {
      final jsonList = jsonDecode(widget.userInfo['likedMyPhotos'].toString())
          .map((item) => jsonEncode(item))
          .toList();
      final uniqueJsonList = jsonList.toSet().toList();
      final result = uniqueJsonList.map((item) => jsonDecode(item)).toList();

      localLikedMyPhotos = result;
    } else
      localLikedMyPhotos = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: widget.controller,
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (context, idx) => PhotoViewGalleryPageOptions(
              imageProvider: widget.images[idx],
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained * (0.5 + idx / 10),
              maxScale: PhotoViewComputedScale.covered * 1.1,
            ),
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                likedPhotoIndex = index;
                indexLiked = localLikedMyPhotos.toString().contains(
                    "{userID: ${widget.database.userId}, likedPhotoLink: ${widget.images[index]?.url}}");
              });
            },
          ),
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isLikeAnimating ? 1 : 0,
              child: LikeAnimation(
                isAnimating: isLikeAnimating, //isLikeAnimating,
                child: Icon(
                  Icons.favorite,
                  color: ColorUtils.defaultColor,
                  size: 100,
                ),
                duration: const Duration(
                  milliseconds: 400,
                ),
                onEnd: () {
                  setState(() {
                    isLikeAnimating = false;
                  });
                },
              ),
            ),
          ),

          // LikeAnimation(
          //                 isAnimating: true,
          //                 smallLike: true,
          //                 child: IconButton(
          //                   icon:  const Icon(
          //         Icons.favorite_border,
          //         color:Colors.white,
          //         size: 80
          //       ),
          //                   onPressed: () {},
          //                 ),
          //               ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.width * 0.15,
              width: MediaQuery.of(context).size.width * 0.15,
              margin: EdgeInsets.only(bottom: 30.0),
              child: FloatingActionButton(
                  heroTag: UniqueKey(),
                  backgroundColor: Colors.white.withOpacity(0.5),
                  child: Icon(
                    indexLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      indexLiked = !indexLiked;
                      isLikeAnimating = true;
                    });
                    CachedNetworkImageProvider img =
                        widget.images[likedPhotoIndex];
                    var currentUser = widget.database.userId;
                    var swipedUser = widget.userID;

                    // String temp =
                    //     "{\"userID\":\"${widget.database.userId}\",\"likedPhotoLink\":\"${images[likedPhotoIndex]?.url}\"}";
                   
                   
                    // showGeneralDialog(
                    //     barrierColor: Colors.black.withOpacity(0.8),
                    //     transitionBuilder: (context, a1, a2, widget) {
                    //       return Transform.scale(
                    //         scale: a1.value,
                    //         child: Opacity(
                    //           opacity: a1.value,
                    //           child: AlertDialog(
                    //             titlePadding: EdgeInsets.all(0),
                    //             actionsPadding: EdgeInsets.all(0),
                    //             contentPadding: EdgeInsets.all(0),
                    //             content: Container(
                    //                 height: 200,
                    //                 width: 200,
                    //                 decoration: BoxDecoration(
                    //                   image: DecorationImage(
                    //                       image: img,
                    //                       fit: BoxFit.cover),
                    //                 ),
                    //                 child: Center(
                    //                   child: Container(
                    //                     width: 60,
                    //                     height: 60,
                    //                     child: Image(
                    //                       image: AssetImage(
                    //                           'assets/images/icons/like.png'),
                    //                     ),
                    //                   ),
                    //                 )),
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //     transitionDuration:
                    //         Duration(milliseconds: 200),
                    //     barrierDismissible: true,
                    //     barrierLabel: '',
                    //     context: context,
                    //     pageBuilder:
                    //         (context, animation1, animation2) {});

                    //
                    var photoLiked = {
                      "userID": currentUser,
                      "likedPhotoLink": img?.url
                    };
                    bool removeLike = !indexLiked;
                    if (removeLike) {
                      localLikedMyPhotos.removeWhere((element) =>
                          element.toString().contains(photoLiked.toString()));
                    } else {
                      if (!localLikedMyPhotos
                          .toString()
                          .contains(photoLiked.toString()))
                        localLikedMyPhotos.add(photoLiked);
                    }
                    widget.database
                        .updatePhotosLike(swipedUser, photoLiked, removeLike);
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
