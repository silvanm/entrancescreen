import 'dart:async';
import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:scoped_model/scoped_model.dart';

import 'models/appstate.dart';

class Facedetector extends StatefulWidget {
  final CameraDescription camera;
  final FirebaseStorage storage;

  const Facedetector({Key key, this.camera, this.storage}) : super(key: key);

  @override
  _FacedetectorState createState() => _FacedetectorState();
}

class _FacedetectorState extends State<Facedetector> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];
  Timer _timer;
  DateTime _lastUpload;

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        widget.camera,
        // Define the resolution to use.
        ResolutionPreset.high,
      );
      _initializeControllerFuture = _controller.initialize();
      _timer = Timer(
        Duration(seconds: 5),
        takePicture,
      );
    }
  }

  void takePicture() async {
    try {
      _timer?.cancel();
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Construct the path where the image should be saved using the
      // pattern package.
      final path = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      // Attempt to take a picture and log where it's been saved.
      await _controller.takePicture(path);

      final File imageFile = File(path);
      final FirebaseVisionImage visionImage =
      FirebaseVisionImage.fromFile(imageFile);
      final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
      print("Start Detection");
      final DateTime dStart = new DateTime.now();
      final List<Face> faces = await faceDetector.processImage(visionImage);
      final DateTime dEnd = new DateTime.now();

      Duration difference = dEnd.difference(dStart);
      print('${faces.length} faces detected');
      print('Duration ${difference.inSeconds} seconds');
      faceDetector.close();

      DateFormat fmt = new DateFormat('y/MM/dd');
      String filename = '${fmt.format(DateTime.now())}/${DateTime.now()}.jpg';

      if (faces.length > 0) {
        final StorageReference ref =
        widget.storage.ref().child(filename);
        final StorageUploadTask uploadTask = ref.putFile(
          imageFile,
          StorageMetadata(
            contentLanguage: 'en',
            customMetadata: <String, String>{'facecount': '${faces.length}'},
          ),
        );
        _lastUpload = DateTime.now();
        //StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
        Future<StorageTaskSnapshot> f = uploadTask.onComplete;

        f.then((snapshot) {
          print('Uploaded picture $filename)');

          if (ScopedModel
              .of<Appstate>(context)
              .debug) {
            final snackBar = SnackBar(
                content: Text('Uploaded picture $filename)'));
            Scaffold.of(context).showSnackBar(snackBar);
          }
          setState(() {
            _tasks.add(uploadTask);
          });
          imageFile.delete();
        }).catchError((_) {
          print(_);
          imageFile.delete();
        });
      } else {
        imageFile.delete();
      }
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }


    _timer = Timer(
      Duration(seconds: 1),
      takePicture
      ,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool debug = ScopedModel
        .of<Appstate>(context)
        .debug;
    if (debug) {
      return Row(children: <Widget>[
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return Container(
                width: 90,
                height: 160,
                child: CameraPreview(_controller),
              );
            } else {
              // Otherwise, display a loading indicator.
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        FlatButton(
          child: Icon(Icons.camera),
          onPressed: () => takePicture(),
        ),
      ]);
    } else {
      return Row();
    }
  }
}
