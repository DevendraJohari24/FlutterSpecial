import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() {
  runApp(MyBarCodeScanner());
}

class MyBarCodeScanner extends StatefulWidget {
  @override
  MyBarCodeScannerState createState() => MyBarCodeScannerState();
}

class MyBarCodeScannerState extends State<MyBarCodeScanner> {
  String ssid = "";
  String password = "";
  String title = "";
  String url = "";
  BarcodeWiFiEncryptionType type;

  File pickedImage;
  var picker = ImagePicker();
  bool imageLoaded = false;

  Future getImage() async {
    var pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = File(pickedFile.path);
      imageLoaded = true;
    });

    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(pickedImage);

    final BarcodeDetector barcodeDetector =
        FirebaseVision.instance.barcodeDetector();

    final List<Barcode> barcodes =
        await barcodeDetector.detectInImage(visionImage);

    for (Barcode barcode in barcodes) {
      final Rect boundingBox = barcode.boundingBox;
      final List<Offset> cornerPoints = barcode.cornerPoints;

      final String rawValue = barcode.rawValue;

      final BarcodeValueType valueType = barcode.valueType;

      // See API reference for complete list of supported types
      switch (valueType) {
        case BarcodeValueType.wifi:
          ssid = barcode.wifi.ssid;
          password = barcode.wifi.password;
          type = barcode.wifi.encryptionType;
          break;
        case BarcodeValueType.url:
          title = barcode.url.title;
          url = barcode.url.url;
          break;
      }
    }
    barcodeDetector.close();
    return barcodes;
  }

  printInfo() {
    print("SSID:" + "$ssid");
    print("Password:" + "$password");
    print("Title:" + "$title");
    print("URL:" + "$url");
    print("Type:" + "$type");
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Barcode Recognition"),
        ),
        body: Column(
          children: [
            RaisedButton(
              onPressed: () {
                getImage();
                printInfo();
              },
              child: Icon(Icons.image),
            ),
          ],
        ),
      ),
    );
  }
}
