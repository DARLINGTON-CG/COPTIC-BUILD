import 'package:camera/camera.dart';
import 'package:copticmeet/pages/profile/utils.dart';
import 'package:copticmeet/providers/profile_info_caches.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:copticmeet/utils/color_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class CameraScan extends StatefulWidget {
  final String path;
  final Database database;

  CameraScan(this.path, this.database);

  @override
  _CameraScanState createState() => _CameraScanState();
}

class _CameraScanState extends State<CameraScan> {
  CameraController _camera;

  CameraLensDirection _direction = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  void _initializeCamera() async {
    CameraDescription description = await getCamera(_direction);
    _camera = CameraController(
      description,
      defaultTargetPlatform == TargetPlatform.iOS
          ? ResolutionPreset.low
          : ResolutionPreset.medium,
    );
    await _camera.initialize();
    setState(() {});
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(
              child: Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
                ),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return Theme.of(context).primaryColor;
                        },
                      ),
                    ),
                    onPressed: () async {
                      final pr = ProgressDialog(context, isDismissible: false);
                      pr.style(
                        message: 'Detecting face on image...',
                        borderRadius: 10.0,
                        backgroundColor: Colors.white,
                        progressWidget: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        elevation: 10.0,
                        insetAnimCurve: Curves.easeInOut,
                        progress: 0.0,
                        maxProgress: 100.0,
                        progressTextStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400),
                        messageTextStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 19.0,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                      await _camera.setFlashMode(FlashMode.off);
                      await _camera.takePicture().then((value) async {
                        final prd =
                            ProgressDialog(context, isDismissible: false);
                        prd.style(
                          message: 'Comparison in progress...',
                          borderRadius: 10.0,
                          backgroundColor: Colors.white,
                          progressWidget: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          elevation: 10.0,
                          insetAnimCurve: Curves.easeInOut,
                          progress: 0.0,
                          maxProgress: 100.0,
                          progressTextStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                          ),
                          messageTextStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 19.0,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                        await prd.show();
                        final result =
                            await compareFaces(widget.path, value.path);
                        await prd.hide();
                        final code = result["code"];
                        final message = result["message"];
                        if (code == 0) {
                          Provider.of<ProfileImageCaches>(context,
                                  listen: false)
                              .addUserInfo(
                                  {"isVerified": true}, widget.database);

                          Navigator.pop(context);
                        } else {
                          final snack = SnackBar(
                            content: Text(
                              "Profile unverified. Face not found",
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snack);
                        }
                      });
                    },
                    child: Text(
                      "Capture",
                    ),
                  ),
                )
              ],
            ),
    );
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }

    //await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "Face Detection",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      backgroundColor: ColorUtils.defaultColor,
      body: _buildImage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCameraDirection,
        child: _direction == CameraLensDirection.back
            ? const Icon(Icons.camera_front)
            : const Icon(Icons.camera_rear),
      ),
    );
  }
}
