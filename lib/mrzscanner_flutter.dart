import 'dart:async';

import 'package:flutter/services.dart';

typedef MRZScannerCallback = void Function(String result);

class Mrzflutterplugin {
  static const MethodChannel _channel =
      const MethodChannel('mrzscanner_flutter');

  // Initiates the scanner view
  static Future<String> get startScanner async {
    final String scannerResult = await _channel.invokeMethod("startScanner");
    return scannerResult;
  }

  // Initiates the scanner view with continuous scanning enabled
  // After successful scan, the scanner view will not be dismissed or paused.
  // To close the scanner, call closeScanner();
  //
  // [ignoreDuplicates] is used to specify whether the scanner should ignore
  // the successful scan if the document number is identical to the previous
  // successful scan
  static void startContinuousScanner(MRZScannerCallback callback,
      [bool ignoreDuplicates = true]) {
    _channel.invokeMethod("startContinuousScanner", ignoreDuplicates);
    _channel.setMethodCallHandler((call) {
      if (call.method == "onScannerResult") callback.call(call.arguments);
      return Future(() => null);
    });
  }

  // Customize the overlay of the finder in the scanner.
  static Future<String> startScannerWithCustomOverlay(
      String base64String) async {
    final String scannerResult = await _channel.invokeMethod(
        "startScannerWithCustomOverlay", base64String);
    return scannerResult;
  }

  // Initiates the scanner view with specific frame. The values represent percentages relative to the screen size [0...100]
  static Future<String> startPartialViewScanner(
      int x, int y, int width, int height) async {
    final String scannerResult = await _channel
        .invokeMethod("startPartialViewScanner", [x, y, width, height]);
    return scannerResult;
  }

  // Initiates the scanner view
  static Future<String> get captureIdImage async {
    final String scannerResult = await _channel.invokeMethod("captureIdImage");
    return scannerResult;
  }

  // Register with the licence key provided to remove the asterisks (*) from the result.
  static void registerWithLicenceKey(String licenceKey) {
    _channel.invokeMethod("registerWithLicenceKey", licenceKey);
  }

  // Specify whether the scanner should detect and return result for passports.
  static void setPassportActive(bool active) {
    _channel.invokeMethod("setPassportActive", active);
  }

  // Specify whether the scanner should detect and return result for IDs.
  static void setIDActive(bool active) {
    _channel.invokeMethod("setIDActive", active);
  }

  // Specify whether the scanner should detect and return result for Visas.
  static void setVisaActive(bool active) {
    _channel.invokeMethod("setVisaActive", active);
  }

  // Set the date format in which the parsed dates are formatted.
  static void setDateFormat(String dateFormat) {
    _channel.invokeMethod("setDateFormat", dateFormat);
  }

  // Specify which scanner type you want to use.
  static void setScannerType(int scannerType) {
    _channel.invokeMethod("setScannerType", scannerType);
  }

  // Specify the maximum number of CPU threads that the scanner can use during the scanning process.
  static void setMaxThreads(int maxThreads) {
    _channel.invokeMethod("setMaxThreads", maxThreads);
  }

  // Specify the effort level for the scanner to use during the scanning process.
  static void setEffortLevel(int effortLevel) {
    _channel.invokeMethod("setEffortLevel", effortLevel);
  }

  // Turn flashlight on or off.
  static void toggleFlash(bool toggleFlash) {
    _channel.invokeMethod("toggleFlash", toggleFlash);
  }

  // Set zoom factor.
  static void setZoomFactor(double zoomFactor) {
    _channel.invokeMethod("setZoomFactor", zoomFactor);
  }

  // Enable automatically extracting portrait image on successful scan; Default value: false.
  static void setExtractPortraitEnabled(bool extractPortraitEnabled) {
    _channel.invokeMethod("setExtractPortraitEnabled", extractPortraitEnabled);
  }

  // Enable automatically extracting signature image on successful scan; Default value: false.
  static void setExtractSignatureEnabled(bool extractSignatureEnabled) {
    _channel.invokeMethod(
        "setExtractSignatureEnabled", extractSignatureEnabled);
  }

  // Enable automatically extracting passport image on successful scan; Default value: false.
  static void setExtractFullPassportImageEnabled(
      bool extractFullPassportImageEnabled) {
    _channel.invokeMethod(
        "setExtractFullPassportImageEnabled", extractFullPassportImageEnabled);
  }

  // Enable automatically extracting ID(back) image on successful scan; Default value: false.
  static void setExtractIdBackImageEnabled(bool extractIdBackImageEnabled) {
    _channel.invokeMethod(
        "setExtractIdBackImageEnabled", extractIdBackImageEnabled);
  }

  // Trigger an image picker.
  static Future<String> get scanFromGallery async {
    final String scannerResult = await _channel.invokeMethod("scanFromGallery");
    return scannerResult;
  }

  // Returns the current SDK Version
  static Future<String> get getSdkVersion async {
    final String sdkVersion = await _channel.invokeMethod("getSdkVersion");
    return sdkVersion;
  }

  // Resume scanning after a successful scan.
  static void resumeScanner() {
    _channel.invokeMethod("resumeScanner");
  }

  // Stop and close the scanner.
  static void closeScanner() {
    _channel.invokeMethod("closeScanner");
  }

  // Specify whether the device should vibrate when the scanner performs a successful scan. Default value: true.
  static void setVibrateOnSuccessfulScan(bool vibrate) {
    _channel.invokeMethod("setVibrateOnSuccessfulScan", vibrate);
  }

  // Specify whether the device should use the front-facing camera for scanning. Default value: false.
  static void setUseFrontCamera(bool enabled) {
    _channel.invokeMethod("setUseFrontCamera", enabled);
  }

  // Warn if the camera does not meet the minimum requirements. Default value: true.
  static void setWarnIncompatibleCamera(bool enabled) {
    _channel.invokeMethod("setWarnIncompatibleCamera", enabled);
  }
}
