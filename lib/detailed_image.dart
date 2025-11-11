import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'image_processing_View.dart';

class DetailedImagePage extends StatelessWidget {
  // Color scheme - same as ImageProcessingView
  static const primaryColor = Color(0xFFE91E63);
  static const backgroundColor = Colors.white;

  final File? originalImage;
  final Uint8List? editedImageBytes;

  const DetailedImagePage({
    Key? key,
    required this.originalImage,
    required this.editedImageBytes,
  }) : super(key: key);

  Map<String, List<int>> _generateHistogram(Uint8List imageBytes) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) return {'r': [], 'g': [], 'b': []};

    final rHist = List<int>.filled(256, 0);
    final gHist = List<int>.filled(256, 0);
    final bHist = List<int>.filled(256, 0);

    for (int y = 0; y < decoded.height; y++) {
      for (int x = 0; x < decoded.width; x++) {
        final pixel = decoded.getPixel(x, y);
        rHist[pixel.r.toInt()] += 1;
        gHist[pixel.g.toInt()] += 1;
        bHist[pixel.b.toInt()] += 1;
      }
    }

    return {'r': rHist, 'g': gHist, 'b': bHist};
  }

  Future<void> _downloadImage(BuildContext context) async {
    if (editedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No edited image to download')),
      );
      return;
    }

    try {
      // Get the Downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${directory.path}/edited_image_$timestamp.png';
        final file = File(filePath);
        await file.writeAsBytes(editedImageBytes!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved to: $filePath'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Image Processor",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 3,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Gambar Asli ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text(
                    "Original Image",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: originalImage != null
                        ? Image.file(
                            originalImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Container(
                            height: 200,
                            child: const Center(
                              child: Text('No original image available'),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  // Histogram for Original Image
                  if (originalImage != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Original Histogram",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomPaint(
                            painter: HistogramPainter(
                              _generateHistogram(
                                originalImage!.readAsBytesSync(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const Divider(height: 32, thickness: 2),

            // --- Gambar Setelah Diedit ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text(
                    "Edited Image",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: editedImageBytes != null
                        ? Image.memory(
                            editedImageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Container(
                            height: 200,
                            child: const Center(
                              child: Text('No edited image available'),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  // Histogram for Edited Image
                  if (editedImageBytes != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Edited Histogram",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.pinkAccent,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomPaint(
                            painter: HistogramPainter(
                              _generateHistogram(editedImageBytes!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Download Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _downloadImage(context),
                            icon: const Icon(Icons.download),
                            label: const Text("Download Edited Image"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
