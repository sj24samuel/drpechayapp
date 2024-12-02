import 'package:drpechayapp/pages/camerascanner.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class Scanner1 extends StatefulWidget {
  const Scanner1({super.key});

  @override
  State<Scanner1> createState() => _Scanner1State();
}

class _Scanner1State extends State<Scanner1> {
  late ImagePicker _imagePicker;
  XFile? _pickedImage;
  List<dynamic>? _recognitions1;
  bool _isLoading = false;
  late String res;
    
 

  @override
  void initState() {
    super.initState();
    _initializeTflite();
    _imagePicker = ImagePicker();
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
          _recognitions1 = null; // Clear previous recognitions
          _isLoading = true;
        });
        await _processImage();
      }     
  }

  Future<void> _pickImageFromCamera() async{
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
          _recognitions1 = null; // Clear previous recognitions
          _isLoading = true;
        });
        await _processImage();
      }     
  }

  Future<void> _initializeTflite() async {
    // Load the model and labels
    res = (await Tflite.loadModel(
      model: "assets/bokchoymodel.tflite",
      labels: "assets/petchay_labels.txt",
      isAsset: true, // defaults to true, set to false to load resources outside assets
      useGpuDelegate: false // defaults to false, set to true to use GPU delegate
    ))!;
    print(res);

  }

  Future<void> _processImage() async {
    if (_pickedImage != null) {
      final List<dynamic>? recognitions1 = await Tflite.runModelOnImage(
        path: _pickedImage!.path,
        numResults: 1,
        threshold: 0.5,
        asynch: true
      );
      // Update the recognitions
      setState(() {
        _recognitions1 = recognitions1;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
          const Text(
            "Scan My Pechay",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),       
          if (!_isLoading) ...[
            Image.asset(
              'assets/images/uploading.gif', // Path to your GIF image
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
          ],
          if (!_isLoading && _pickedImage != null)
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Image.file(
                File(_pickedImage!.path),
                fit: BoxFit.cover,
              ),
            )
          else if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Container(),            
            const SizedBox(height: 20), 

             ElevatedButton.icon(
               onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => Camerascanner()));
               },
               label: const Text("Scan my Pechay",
                 style: TextStyle(color: Colors.black)),
                 style: ButtonStyle(
                   backgroundColor: WidgetStateProperty.all(Colors.white),
                   padding: WidgetStateProperty.all(
                     const  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
              )
             ),

            const SizedBox(height: 20), 

            ElevatedButton.icon(
              onPressed: _pickImageFromCamera,
              label: const Text("Take a Picture",
                style: TextStyle(color: Colors.black)),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  padding: WidgetStateProperty.all(
                    const  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
              )
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _pickImageFromGallery,
               label: const Text("Pick From Gallery",
               style: TextStyle(color: Colors.black)),
               style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
               ),
              ),
              const SizedBox(height: 16),
              //Display combined recognized if available
              if (_recognitions1 != null)
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      "Details:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 86, 54, 244),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _recognitions1!
                          .map(
                            (recognition) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Label: ${recognition['label']}",style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),),
                                Text(
                                  "Confidence Level: ${(recognition['confidence'] * 100).toStringAsFixed(2)}%",
                                                              style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  // Display recommendations card if the label is "Alternaria_Leaf_Spot"
                  if (_recognitions1 != null &&
                      _recognitions1![0]['label'] == 'Alternaria_Leaf_Spot')
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      color: Colors.grey[200],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recommendations for Alternaria Leaf Spot:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "1. Remove infected leaves immediately to prevent spreading.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "2. Apply fungicide as per manufacturer's instructions.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "3. Ensure proper ventilation and reduce humidity around plants.",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  // Display recommendations card if the label is "Bacterial_Spot"
                  if (_recognitions1 != null &&
                      _recognitions1![0]['label'] == 'Bacterial_Soft_Rot')
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      color: Colors.grey[200],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recommendations for Bacterial Soft Rot:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "1. Avoid overhead watering to minimize moisture on leaves.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "2. Apply copper-based fungicide to affected plants.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "3. Ensure proper plant spacing for adequate airflow.",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                                      if (_recognitions1 != null &&
                      _recognitions1![0]['label'] == 'Healthy_Pechay')
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      color: Colors.grey[200],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recommendations for Healthy Pechay:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "1. Avoid overhead watering to minimize moisture on leaves.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "2. Apply copper-based fungicide to affected plants.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "3. Ensure proper plant spacing for adequate airflow.",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                     if (_recognitions1 != null &&
                      _recognitions1![0]['label'] == 'Black_Rot')
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      color: Colors.grey[200],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recommendations for Healthy Pechay:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "1. Avoid overhead watering to minimize moisture on leaves.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "2. Apply copper-based fungicide to affected plants.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "3. Ensure proper plant spacing for adequate airflow.",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                     if (_recognitions1 != null &&
                      _recognitions1![0]['label'] == 'Downy_Mildew')
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      color: Colors.grey[200],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recommendations for Healthy Pechay:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "1. Avoid overhead watering to minimize moisture on leaves.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "2. Apply copper-based fungicide to affected plants.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "3. Ensure proper plant spacing for adequate airflow.",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    if (_recognitions1 != null &&
                      _recognitions1![0]['label'] == 'Leaf_Miner_Damage')
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      color: Colors.grey[200],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recommendations for Healthy Pechay:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "1. Avoid overhead watering to minimize moisture on leaves.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "2. Apply copper-based fungicide to affected plants.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "3. Ensure proper plant spacing for adequate airflow.",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    if (_recognitions1 != null &&
                      _recognitions1![0]['label'] == 'Pest')
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      color: Colors.grey[200],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recommendations for Healthy Pechay:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "1. Avoid overhead watering to minimize moisture on leaves.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "2. Apply copper-based fungicide to affected plants.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "3. Ensure proper plant spacing for adequate airflow.",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    if (_recognitions1 != null &&
                      _recognitions1![0]['label'] == 'Unknown disease')
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      color: Colors.grey[200],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recommendations for Healthy Pechay:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "1. Avoid overhead watering to minimize moisture on leaves.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "2. Apply copper-based fungicide to affected plants.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "3. Ensure proper plant spacing for adequate airflow.",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                                      if (_recognitions1 != null &&
                      _recognitions1![0]['label'] == 'Undefined')
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      color: Colors.grey[200],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recommendations for Undefined:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "1. Image is not a leaf/leaves.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "2. Its probably unrecognizable/blurred or unclear.",
                            style: TextStyle(fontSize: 15),
                          ),
                          Text(
                            "3. Ensure proper view of the image",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          else
            Container(
            ),
         ],
      ),

    );
  }
  @override
  void dispose() {
    // Dispose TFLite resources
    Tflite.close();
    super.dispose();
  }
   //@override
  void init() {
    _initializeTflite();
  }
  

}


class Scannermain extends StatelessWidget {
  const Scannermain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pechay Scanner",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 98, 218, 18),
      ),
      body: Scanner1(),
    ) ;
  }
}