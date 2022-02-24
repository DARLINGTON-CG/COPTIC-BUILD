import 'dart:async';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

Future<CameraDescription> getCamera(CameraLensDirection dir) async {
  return await availableCameras().then(
    (List<CameraDescription> cameras) => cameras.firstWhere(
      (CameraDescription camera) => camera.lensDirection == dir,
    ),
  );
}

Future<Map<String, dynamic>> compareFaces(String path1, String path2) async {
  final dio = new Dio();
  var formData = FormData.fromMap({
    'photo1': await MultipartFile.fromFile(path1),
    'photo2': await MultipartFile.fromFile(path2)
  });
  var response = await dio.post(
    "https://face-verification2.p.rapidapi.com/FaceVerification",
    options: Options(
      headers: {
        "x-rapidapi-key": "2411817f9dmsh23c6cf36156bb92p1f8792jsn3fd1327e495a",
        "x-rapidapi-host": "face-verification2.p.rapidapi.com",
      },
    ),
    data: formData,
  );

  Map<String, dynamic> map = response.data as Map<String, dynamic>;
  int code = map["statusCode"];
  String statusMessage = map["statusMessage"];
  bool hasError = map["hasError"];
  String message = map["data"]["resultMessage"];
  int resultIndex = map["data"]["resultIndex"];
  if (code == 200 && statusMessage == "OK" && !hasError) {
    return {
      "message": message,
      "code": resultIndex,
    };
  } else {
    return null;
  }
}

Future<List<Face>> getFacesFromPath(String path) async {
  final inputImage = InputImage.fromFilePath(path);
  final faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions());
  return faceDetector.processImage(inputImage);
}

Future<List<Face>> getFacesFromCamera(
    CameraImage cameraImage, CameraDescription camera) async {
  final WriteBuffer allBytes = WriteBuffer();
  for (Plane plane in cameraImage.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  final Size imageSize =
      Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

  final InputImageRotation imageRotation =
      InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
          InputImageRotation.Rotation_0deg;

  final InputImageFormat inputImageFormat =
      InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
          InputImageFormat.NV21;

  final planeData = cameraImage.planes.map(
    (Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    },
  ).toList();

  final inputImageData = InputImageData(
    size: imageSize,
    imageRotation: imageRotation,
    inputImageFormat: inputImageFormat,
    planeData: planeData,
  );

  final inputImage =
      InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  final faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions());
  return faceDetector.processImage(inputImage);
}
