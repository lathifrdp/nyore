import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class LiveTextRecognitionPage extends StatefulWidget {
  const LiveTextRecognitionPage({super.key});

  @override
  State<LiveTextRecognitionPage> createState() => _LiveTextRecognitionPageState();
}

class _LiveTextRecognitionPageState extends State<LiveTextRecognitionPage> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isBusy = false;
  String _recognizedText = '';
  String _debugMsg = 'Menunggu frame...';

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

      if (!mounted) return;
      setState(() {});

      _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing camera: $e");
      }
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final recognizedText = await _textRecognizer.processImage(inputImage);
      if (mounted) {
        setState(() {
          _recognizedText = recognizedText.text;
          _debugMsg = 'Memproses: ${image.width}x${image.height}, Format: ${image.format.raw}, Planes: ${image.planes.length}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _debugMsg = "Error: $e";
        });
      }
      if (kDebugMode) {
        print("Error recognizing text: $e");
      }
    } finally {
      // Small delay to prevent making the device too hot and stuttering
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) {
        _isBusy = false;
      }
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_cameraController!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) {
      if (mounted) setState(() => _debugMsg = 'Rotasi gagal dikalkulasi');
      return null;
    }

    final format = Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888;

    if (image.planes.isEmpty) {
      if (mounted) setState(() => _debugMsg = 'Image planes kosong');
      return null;
    }

    Uint8List finalBytes;

    if (Platform.isAndroid) {
      // Solusi brillian: Android sering error IllegalArgumentException karena
      // panjang byte padding tidak sesuai dengan yang diekspektasi java (width x height * 1.5).
      // OCR TextRecognizer hanya butuh Luminance (Y Plane) dan buta warna.
      // Kita cukup mengekstrak Y Plane secara pas (tanpa padding) dan mencetak UV dummy.
      final yPlane = image.planes[0];
      final yBuffer = WriteBuffer();
      int yOffset = 0;
      for (int i = 0; i < image.height; i++) {
        yBuffer.putUint8List(yPlane.bytes.sublist(yOffset, yOffset + image.width));
        yOffset += yPlane.bytesPerRow;
      }
      final yBytes = yBuffer.done().buffer.asUint8List();
      final uvSize = (image.width * image.height) ~/ 2;
      final uvBytes = Uint8List(uvSize)..fillRange(0, uvSize, 128); // 128 adalah warna netral
      
      final WriteBuffer androidBuffer = WriteBuffer();
      androidBuffer.putUint8List(yBytes);
      androidBuffer.putUint8List(uvBytes);
      finalBytes = androidBuffer.done().buffer.asUint8List();
    } else {
      // iOS
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      finalBytes = allBytes.done().buffer.asUint8List();
    }

    return InputImage.fromBytes(
      bytes: finalBytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraInitialized =
        _cameraController != null && _cameraController!.value.isInitialized;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Text Recognition'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: cameraInitialized
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(_cameraController!),
                      if (_isBusy)
                        const Positioned(
                          top: 16,
                          right: 16,
                          child: Icon(Icons.sync, color: Colors.greenAccent),
                        ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _debugMsg,
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Teks Terdeteksi:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _recognizedText.isEmpty ? 'Arahkan kamera ke teks...' : _recognizedText,
                        style: TextStyle(
                          fontSize: 16,
                          color: _recognizedText.isEmpty ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
