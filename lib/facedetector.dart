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
  bool _isDetecting = false;

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() async {
    super.initState();
    if (!kIsWeb) {
      _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        widget.camera,
        // Define the resolution to use.
        ResolutionPreset.veryHigh,
      );
      await _controller.initialize();
      _controller.startImageStream((CameraImage image) {
        if (_isDetecting) return;
        _isDetecting = true;
        try {
          // await doSomethingWith(image)
          print("detecting");
        } catch (e) {
          //await handleExepction(e)
          print("exception");
        } finally {
          _isDetecting = false;
        }
      });
    }
  }

  /// Prevent too many uploads
  bool throttlingNecessary() {
    if (_lastUpload == null) {
      return false;
    }
    if (_lastUpload.difference(DateTime.now()).inSeconds < -5) {
      return false;
    }
    print('Throttling enabled since $_lastUpload');
    return true;
  }

  /*
  void takePicture() async {
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;


      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFile(imageFile);
      final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
      final List<Face> faces = await faceDetector.processImage(visionImage);

      print('${faces.length} faces detected');

      faceDetector.close();

      DateFormat fmt = new DateFormat('y-MM-dd');
      String filename='${fmt.format(DateTime.now())}/${DateTime.now()}.jpg';

      if (faces.length > 0 && !throttlingNecessary()) {
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
        StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

        print('Uploaded picture $filename)');

        if (ScopedModel.of<Appstate>(context).debug) {
          final snackBar = SnackBar(content: Text('Uploaded picture $filename)'));
          Scaffold.of(context).showSnackBar(snackBar);
        }
        setState(() {
          _tasks.add(uploadTask);
        });
      }// delete the file to free storage
      imageFile.delete();

    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }

  }
   */

  @override
  Widget build(BuildContext context) {
    bool debug = ScopedModel.of<Appstate>(context).debug;
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
      ]);
    } else {
      return Row();
    }
  }
}
