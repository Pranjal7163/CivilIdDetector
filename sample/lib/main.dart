import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:sample/image_constants.dart';
import 'package:civil_id_detector/civil_id_detector.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();


}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late List<CameraDescription> _cameras;
  CameraController? _camController;
  String _topBg = ImageConstants.rectangleTriLight;
  String _topLeftIcon = ImageConstants.closeCircle;
  bool _isImageSelected = false;
  var count = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    availableCameras().then((value) {
      _cameras = value;
      _camController = CameraController(_cameras[0], ResolutionPreset.medium);
      _camController?.addListener(() {
        if (mounted) {
          setState(() {});
          if (_camController?.value.hasError == true) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Camera error ${_camController?.value.errorDescription}')));
          }
        }
      });
      _camController?.initialize().then((value) {
        if (!mounted) {
          return;
        }

        setState(() {});
        setFlashMode(FlashMode.auto);
        _camController?.setFocusMode(FocusMode.auto);
        CivilIdDetector.detect(_camController!, (IDTYPE idType, CivilIdMrzModel? mrzModel) => {
          handleResponse(idType, mrzModel)
        });
      }).catchError((Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              print('User denied camera access');
              break;

            default:
              print('Some error occurred in camera');
              break;
          }
        }
      });
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _topBg = ImageConstants.rectangleTriDark;
        _topLeftIcon = ImageConstants.tick;
        _isImageSelected = true;
      });
    });
  }

  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await _camController?.setFlashMode(mode);
      // await _torchController?.toggle();
    } on CameraException catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_camController != null &&
        !(_camController?.value.isInitialized == true)) {
      return const Center(
        child: Text(
          'Initializing camera...',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontSize: 19),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ColoredBox(
          color: const Color.fromARGB(255, 64, 64, 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                // color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                // height: 500,
                width: MediaQuery.of(context).size.width,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: svgProvider.Svg(_topBg),
                //     fit: BoxFit.cover,
                //   ),
                // ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SvgPicture.asset(
                    //   _topLeftIcon,
                    //   width: 32,
                    //   height: 32,
                    // ),
                    const SizedBox(
                      width: 10,
                    ),
                    Visibility(
                      visible: !_isImageSelected,
                      child: Flexible(
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'Please capture the ',
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.secondary,
                                // fontFamily: fontFamily,
                              ),
                            ),
                            TextSpan(
                              text: 'FRONT SIDE ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                                // fontFamily: fontFamily,
                              ),
                            ),
                            TextSpan(
                              text:
                              'image of your CIVIL ID within the dotted frame',
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.secondary,
                                // fontFamily: fontFamily,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _isImageSelected,
                      child: Flexible(
                        child: RichText(
                          text: const TextSpan(children: [
                            TextSpan(
                              text: 'The ',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                // fontFamily: fontFamily,
                              ),
                            ),
                            TextSpan(
                              text: 'FRONT SIDE ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                // fontFamily: fontFamily,
                              ),
                            ),
                            TextSpan(
                              text: 'image is captured',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                // fontFamily: fontFamily,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DottedBorder(
                color: Colors.red,
                radius: const Radius.circular(11),
                strokeWidth: 4,
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: 327,
                  height: 232,
                  child: (_camController == null)
                      ? Container()
                      : CameraPreview(
                    _camController!,
                  ),
                ),
              ),
              const SizedBox(
                height: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleResponse(IDTYPE idType,CivilIdMrzModel? mrzModel){
    if(idType == IDTYPE.CIVIL_ID_FRONT){
      print("Front Captured");
    }else if(idType == IDTYPE.CIVIL_ID_BACK && mrzModel != null){
      print("Back Captured");
      if(mrzModel.idType != null){
        print("ID TYPE : "+mrzModel.idType!);
      }
      if(mrzModel.country != null){
        print("COUNTRY : "+mrzModel.country!);
      }
      if(mrzModel.gender != null){
        print("GENDER : "+mrzModel.gender!);
      }
      if(mrzModel.nationality != null){
        print("NATIONALITY : "+mrzModel.nationality!);
      }
      if(mrzModel.name != null){
        print("NAME : "+mrzModel.name!);
      }
    }
  }
}


