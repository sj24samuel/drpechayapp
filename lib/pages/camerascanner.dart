import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';

class Camerascanner extends StatefulWidget {
  const Camerascanner({super.key});

  @override
  State<Camerascanner> createState() => _CamerascannerState();
}

class _CamerascannerState extends State<Camerascanner> {

  CameraController? _cameraController;
  late List<CameraDescription> cameras;
  bool isDetecting = false;
  String? detectionResult;
  double? detectionConfidence;
  late String res;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0], // Use the back camera
      ResolutionPreset.low,
    );

    await _cameraController?.initialize();
    if (!mounted) return;

    setState(() {});
    _startCameraStream();
  }

  void _startCameraStream() {
    _cameraController?.startImageStream((CameraImage image) async {
      if (!isDetecting) {
        isDetecting = true;

        // Run the machine learning model on the frame
        var result = await _detectDisease(image);

        if (mounted) {
          setState(() {
            detectionResult = result['label'];
            detectionConfidence = result['confidence'];
          });
        }

        isDetecting = false;
      }
    });
  }

  Future<void> _loadModel() async {
    res = (await Tflite.loadModel(
      model: "assets/bokchoymodel.tflite",
      labels: "assets/petchay_labels.txt",
    ))!;
    print("Model loaded: $res");
  }

  Future<Map<String, dynamic>> _detectDisease(CameraImage image) async {
    print("Running model on frame...");
    var results = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,  // For normalization if needed
      imageStd: 127.5,   // For normalization if needed
      rotation: 90,
      numResults: 1,  // Limit number of results
      threshold: 0.3, // Detection confidence threshold
      asynch: true
    );
    print('Inference results: $results');
    if (results != null && results.isNotEmpty) {
      var result = results.first;
      return {
        'label': result['label'],
        'confidence': result['confidence']
      };
    }
    return {
      'label': 'No disease detected',
      'confidence': 0.0
    };
  }

  @override
  void dispose() {
    // Stop the camera stream
    _cameraController?.stopImageStream();
    // Dispose of the camera controller
    _cameraController?.dispose();
    // Release TensorFlow Lite resources
    Tflite.close();  
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Pechay Disease Detection",
          style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 98, 218, 18),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                detectionResult != null
                  ? "$detectionResult\nConfidence: ${(detectionConfidence! * 100).toStringAsFixed(2)}%"
                  : "Detecting...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
