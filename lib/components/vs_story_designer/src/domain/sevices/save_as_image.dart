import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

/// Function to capture a widget as an image and save it to the application's documents directory.
///
/// [contentKey]: A GlobalKey<State<StatefulWidget>> associated with the widget
///               to be captured. This key is used to get the RenderRepaintBoundary.
/// [context]: The BuildContext, often used for showing snackbars or other UI feedback.
/// [fileName]: The base name for the image file. A timestamp will be appended
///             to ensure uniqueness.
///
/// Returns the path to the saved image file if successful, otherwise returns false.
Future<dynamic> takePicture({
  required GlobalKey contentKey, // Use GlobalKey<State<StatefulWidget>> or GlobalKey for type safety
  required BuildContext context,
  required String fileName, // Ensure fileName is a String
}) async {
  try {
    /// Get the RenderRepaintBoundary from the contentKey.
    RenderRepaintBoundary boundary =
    contentKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    /// Convert the boundary to an image with a pixel ratio of 3 for higher quality.
    /// The format is explicitly set to PNG here, so the content type is PNG.
    ui.Image image = await boundary.toImage(pixelRatio: 3);

    /// Convert the image to ByteData in PNG format.
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    /// Get the application's document directory path.
    final String dir = (await getApplicationDocumentsDirectory()).path;

    /// Construct the image path dynamically.
    /// The file name includes the provided fileName, a timestamp, and the .png extension.
    /// This ensures the path is not static and matches the PNG content type.
    String imagePath = '$dir/${fileName}_${DateTime.now().millisecondsSinceEpoch}.png';

    /// Create a file object at the determined path.
    File capturedFile = File(imagePath);

    /// Write the PNG bytes to the file.
    await capturedFile.writeAsBytes(pngBytes);

    /// Return the path of the saved image.
    return imagePath;
  } catch (e) {
    debugPrint('Exception during image capture: $e');
    return false;
  }
}
