import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrzscanner_flutter/mrzscanner_flutter.dart';
import 'package:mrzscanner_flutter/mrzscanner_constants.dart';

void main() {
  runApp(new MaterialApp(home: new MyPage()));
}

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => new _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String? _result = 'No result yet';
  String? fullImage;
  String? idBackImage;

  int scannerType = ScannerType.MRZ;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      Mrzflutterplugin.registerWithLicenceKey("android_licence_key");
    } else if (Platform.isIOS) {
      Mrzflutterplugin.registerWithLicenceKey("ios_licence_key");
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> startScanning() async {
    String? scannerResult;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      Mrzflutterplugin.setIDActive(true);
      Mrzflutterplugin.setPassportActive(true);
      Mrzflutterplugin.setVisaActive(true);
      Mrzflutterplugin.setVibrateOnSuccessfulScan(true);

      scannerType = ScannerType.MRZ;
      Mrzflutterplugin.setScannerType(scannerType);
      Mrzflutterplugin.setMaxThreads(MaxThreads.TWO);
      Mrzflutterplugin.setExtractIdBackImageEnabled(true);

      String jsonResultString = await Mrzflutterplugin.startScanner;

      if (scannerType == ScannerType.MRZ ||
          scannerType == ScannerType.ID_SESSION) {
        Map<String, dynamic> jsonResult = jsonDecode(jsonResultString);

        fullImage = jsonResult['full_image'];
        idBackImage = jsonResult['id_back'];

        scannerResult = jsonResult['document_number'] +
            ' ' +
            jsonResult['given_names_readable'] +
            ' ' +
            jsonResult['surname'];

        debugPrint("Successful scan: $jsonResult");
      } else {
        fullImage = jsonResultString;

        debugPrint("Successful scan: $jsonResultString");
      }
    } on PlatformException catch (ex) {
      String? message = ex.message;
      scannerResult = 'Scanning failed: $message';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _result = scannerResult;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future startContinuousScanning(BuildContext context) async {
    Mrzflutterplugin.setIDActive(true);
    Mrzflutterplugin.setPassportActive(true);
    Mrzflutterplugin.setVisaActive(true);
    Mrzflutterplugin.setVibrateOnSuccessfulScan(true);

    scannerType = ScannerType.MRZ;
    Mrzflutterplugin.setScannerType(scannerType);

    MRZScannerCallback callback = (result) {
      if (!result.startsWith("Error")) {
        Map<String, dynamic> jsonResult = jsonDecode(result);
        fullImage = jsonResult['full_image'];

        // If the widget was removed from the tree while the asynchronous platform
        // message was in flight, we want to discard the reply rather than calling
        // setState to update our non-existent appearance.
        if (!mounted) return;

        debugPrint("Successful scan: $result");
      }
    };

    Mrzflutterplugin.startContinuousScanner(callback, true);
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (fullImage != null) Image.memory(base64Decode(fullImage!)),
            if (idBackImage != null) Image.memory(base64Decode(idBackImage!)),
            new TextButton(
              child: Text("Start Scanner"),
              onPressed: startScanning,
            ),
            new TextButton(
              child: Text("Start Continuous Scanner"),
              onPressed: () => startContinuousScanning(context),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Result: $_result'),
            ),
          ],
        ),
      ),
    );
  }
}
