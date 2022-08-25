library civil_id_detector;

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';



enum IDTYPE {
  CIVIL_ID_FRONT,
  CIVIL_ID_BACK
}

class CivilIdDetector{
  static final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  static var count = 0;
  static var isCaptured = false;

  static void detect(CameraController cameraController,Function callback) async{
    try {
      count = 0;
      isCaptured = false;
      cameraController.startImageStream((image) => {
        getImage(cameraController,image,callback)
      });
    } catch (e) {
      print("Exception : "+e.toString());
      // throw ImageNotSelectedException('Image not found');
    }
  }

  static getImage(CameraController cameraController,CameraImage cameraImage, Function callback) async{
    if(count%50 == 0) {
      final inputImage = _getStreamInputImage(cameraController,cameraImage);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String text = recognizedText.text;
      LineSplitter ls = new LineSplitter();
      List<String> _masForUsing = ls.convert(text);
      List<String> idString = [];
      int index = 0;
      for(String s in _masForUsing){
        if(s.contains("IDKWT") || index > 0){
          if(index < 3){
            index++;
            var barText = s.replaceAll(" ", "");
            if(barText.length == 30) {
              idString.add(barText);
            }
          }else{
            index = 0;
          }
        }
      }

      if(text.contains("STATE OF") ||
          text.contains("OF KUWAIT") ||
          text.contains("KUWAIT CIVIL") ||
          text.contains("CIVIL ID") ||
          text.contains("ID CARD")
      ){
        // print(text);
        if(!isCaptured) {
          isCaptured = true;
          cameraController.stopImageStream();
          callback(IDTYPE.CIVIL_ID_FRONT, null);
        }
      }else if (text.contains("IDKWT")){
        var isAllowed = true;
        if(idString.length > 0 && idString[0] != null && idString[0].length != 30){
          isAllowed = false;
          print("F");
        }
        if(idString.length > 1 && idString[1] != null && idString[1].length != 30){
          isAllowed = false;
          print("S");
        }
        if(idString.length > 2 && idString[2] != null && idString[2].length != 30){
          isAllowed = false;
          print("T");
        }
        if(isAllowed){
          String? idType;
          String? country;
          String? civilId;
          String? gender;
          String? nationality;
          String? name;
          if(idString.length > 0) {
            idType = idString[0].substring(0, 2);
            country = idString[0].substring(2, 5);
            civilId = idString[0].substring(15, 27);
          }
          if(idString.length >= 1) {
            gender = idString[1].substring(07, 08);
            nationality = idString[1].substring(15, 18);
          }
          if(idString.length >= 2) {
            name = idString[2].replaceAll("<<", " ").replaceAll("<", " ")
                .replaceAll("«", "").replaceAll(" K ", "")
                .replaceAll(" K", "");
          }

          var mrzModel = CivilIdMrzModel(idType, country, civilId, gender, nationality, name);
          if(!isCaptured) {
            isCaptured = true;
            cameraController.stopImageStream();
            callback(IDTYPE.CIVIL_ID_BACK, mrzModel);
          }
        }


      }
    }
    count++;
  }

  static InputImage _getStreamInputImage(CameraController cameraController,CameraImage image) {
    final Uint8List bytes = Uint8List.fromList(
      image.planes.fold(
        <int>[],
            (List<int> previousValue, Plane element) => previousValue..addAll(element.bytes),
      ),
    );

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final InputImageRotation imageRotation =
        InputImageRotationValue.fromRawValue(cameraController.description.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    final List<InputImagePlaneMetadata> planeData = image.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final InputImageData inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  }
}

class CivilIdMrzModel{
  String? idType;
  String? country;
  String? civilId;
  String? gender;
  String? nationality;
  String? name;

  CivilIdMrzModel(String? idType,String? country,String? civilID,String? gender,String? nationality,String? name){
    this.idType = idType;
    this.country = country;
    this.civilId = civilID;
    this.gender = gender;
    this.nationality = nationality;
    this.name = name;
  }

}
