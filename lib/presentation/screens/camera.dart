import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'add_transaction.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final String apiKey = 'AIzaSyDHmh4P92aN9GGSug0cwwZrp2WnfWJ3RzM'; // Replace with your actual API key

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture; // Wait for initialization to complete
      setState(() {}); // Trigger a rebuild once initialization is complete
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcessImage(BuildContext context) async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final savedImage = File(imagePath);
      await savedImage.writeAsBytes(await image.readAsBytes());

      Uint8List imageBytes = await savedImage.readAsBytes();

      String extractedText = await sendToGeminiAPI(imageBytes);
      print('Extracted Text: $extractedText');

      // Navigate to AddScreen and pass the extracted text
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddScreen(
            extractedText: extractedText,
          ),
        ),
      );
    } catch (e) {
      print('Error capturing or processing image: $e');
    }
  }

  Future<String> sendToGeminiAPI(Uint8List imageBytes) async {
    final model = GenerativeModel(model: 'gemini-pro-vision', apiKey: apiKey);

    final prompt = TextPart(
      "Extract the category of expense from these food,Transportation,Education,Bills,Travels,Pets,Others Expense,Tax and  a one-word that describtion for the expense, and the total amount of expense. For example output should be coma separated like  food, dinner, 100."
    );

    final imagePart = DataPart('image/jpeg', imageBytes);

    final response = model.generateContentStream([
      Content.multi([prompt, imagePart])
    ]);

    // Collect the extracted text from the stream response
    StringBuffer extractedTextBuffer = StringBuffer();
    await for (final chunk in response) {
      extractedTextBuffer.write(chunk.text);
    }

    return extractedTextBuffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Screen'),
      ),
      body: CameraPreview(_controller),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: () => _captureAndProcessImage(context),
      ),
    );
  }
}
