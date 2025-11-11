import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Image_processing_controller.dart'; // Pastikan file ini ada
import 'detailed_image.dart';

class ImageProcessingView extends StatelessWidget {
  ImageProcessingView({Key? key}) : super(key: key);

  //get put buat "register memori dari ImageProcessingController"
  final ImageProcessingController controller = Get.put(
    ImageProcessingController(),
  );

  @override
  Widget build(BuildContext context) {
    // Color scheme
    const primaryColor = Color(0xFFE91E63);
    const secondaryColor = Color(0xFFF8BBD0);
    const accentColor = Color(0xFFF06292);
    const backgroundColor = Colors.white;

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
      //body
      body: Column(
        children: [
          // Main scrollable content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bagian 1: Gambar Asli & Hasil
                  Row(
                    children: [
                      // bagian insert gambar asli
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              controller.pilihGambar(), // tap ke controller
                          child: Obx(
                            () => Container(
                              // styling kotak gambar asli
                              height: 150, //tinggi
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2,
                                ), //warna border
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: controller.gambarAsli.value == null
                                  ? Center(
                                      child: Text(
                                        "Tap to choose image from your device",
                                        textAlign: TextAlign.center,
                                      ),
                                    ) //text if null
                                  : Image.file(
                                      controller.gambarAsli.value!,
                                      fit: BoxFit.cover, //auto fit gambar
                                    ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),

                      // --- Gambar Hasil Proses ---
                      Expanded(
                        child: Obx(
                          () => Container(
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: accentColor, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            // mainan di controller
                            // obx dari getx
                            child: controller.isLoading.isTrue
                                ? Center(child: CircularProgressIndicator())
                                : controller.gambarHasilProses.value == null
                                ? Center(
                                    child: Text(
                                      "Edited image will appear here",
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : Image.memory(
                                    controller.gambarHasilProses.value!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Bagian 2: Histogram Section
                  Obx(() {
                    final histogramBefore = controller.histogramBefore;
                    final histogramAfter = controller.histogramAfter;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Histogram Comparison",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // --- Histogram Sebelum Edit ---
                        const Text(
                          "Before Edit",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          height: 120,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12, top: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: histogramBefore.isEmpty
                              ? const Center(
                                  child: Text(
                                    "Histogram not available. Please select an image.",
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : CustomPaint(
                                  painter: HistogramPainter(
                                    controller.histogramBefore,
                                  ),
                                ),
                        ),

                        // --- Histogram Sesudah Edit ---
                        const Text(
                          "After Edit",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          height: 120,
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.pinkAccent,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: histogramAfter.isEmpty
                              ? const Center(
                                  child: Text(
                                    "Histogram not available. Press 'Edit Image' to see the result.",
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : CustomPaint(
                                  painter: HistogramPainter(
                                    controller.histogramAfter,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.to(
                                () => DetailedImagePage(
                                  originalImage: controller.gambarAsli.value,
                                  editedImageBytes:
                                      controller.gambarHasilProses.value,
                                  originalHistogram: controller.histogramBefore.value,
                                  editedHistogram: controller.histogramAfter.value,
                                ),
                              );
                            },
                            icon: const Icon(Icons.bar_chart_rounded),
                            label: const Text("View Detailed Image"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE91E63),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 5),

                  // Bagian 3: Tombol Aksi Utama
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          controller.prosesGambar(), // dipencet => prosesGambar
                      icon: const Icon(
                        Icons.play_arrow,
                      ), //pake libnary icon arrow
                      label: const Text("Edit Image"), //text normal
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 32),

                  // Controls Section (previously on right side)
                  Obx(() {
                    final active = controller.selectedMethods;
                    final List<Widget> controls = [];
                    // if case satu satu buat slider di kanan
                    if (active.contains('brightness')) {
                      controls.add(
                        _Section(
                          title:
                              'Brightness (${controller.brightnessValue.value.toStringAsFixed(1)})',
                          child: Slider(
                            value: controller
                                .brightnessValue
                                .value, //harusnya default 1 (harus dari controller)
                            min: 0,
                            max: 2,
                            onChanged: (v) =>
                                controller.brightnessValue.value = v,
                          ),
                        ),
                      );
                    }
                    if (active.contains('contrast')) {
                      controls.add(
                        _Section(
                          title:
                              'Contrast (${controller.contrastValue.value.toStringAsFixed(2)})',
                          child: Slider(
                            value: controller.contrastValue.value,
                            min: 0,
                            max: 2,
                            onChanged: (v) =>
                                controller.contrastValue.value = v,
                          ),
                        ),
                      );
                    }
                    if (active.contains('saturation')) {
                      controls.add(
                        _Section(
                          title:
                              'Saturation (${controller.saturationValue.value.toStringAsFixed(2)})',
                          child: Slider(
                            value: controller.saturationValue.value,
                            min: 0,
                            max: 2,
                            onChanged: (v) =>
                                controller.saturationValue.value = v,
                          ),
                        ),
                      );
                    }
                    if (active.contains('hue')) {
                      controls.add(
                        _Section(
                          title:
                              'Hue (${controller.hueValue.value.toStringAsFixed(1)}°)',
                          child: Slider(
                            value: controller.hueValue.value,
                            min: -180,
                            max: 180,
                            divisions: 360,
                            label: controller.hueValue.value.toStringAsFixed(0),
                            onChanged: (v) => controller.hueValue.value = v,
                          ),
                        ),
                      );
                    }
                    if (active.contains('blur')) {
                      final radius = controller.blurRadius.value.toInt();
                      controls.add(
                        _Section(
                          title: 'Gaussian Radius ($radius)',
                          child: Slider(
                            value: controller.blurRadius.value,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: radius.toString(),
                            onChanged: (v) => controller.blurRadius.value = v,
                          ),
                        ),
                      );
                    }
                    if (active.contains('mosaic')) {
                      final mosaicBlockSize = controller.mosaicSize.value
                          .toInt();
                      controls.add(
                        _Section(
                          title: 'Mosaic Block Size ($mosaicBlockSize px)',
                          child: Slider(
                            value: controller.mosaicSize.value,
                            min: 2,
                            max: 50,
                            divisions: 48,
                            label: mosaicBlockSize.toString(),
                            onChanged: (v) => controller.mosaicSize.value = v,
                          ),
                        ),
                      );
                    }
                    if (active.contains('edge_detection')) {
                      controls.add(
                        _Section(
                          title: 'Edge Method',
                          child: DropdownButton<String>(
                            value: controller.edgeDetectionMethod.value,
                            items: const [
                              DropdownMenuItem(
                                value: 'sobel',
                                child: Text('Sobel'),
                              ),
                              DropdownMenuItem(
                                value: 'canny',
                                child: Text('Canny'),
                              ),
                              DropdownMenuItem(
                                value: 'laplacian',
                                child: Text('Laplacian'),
                              ),
                              DropdownMenuItem(
                                value: 'prewitt',
                                child: Text('Prewitt'),
                              ),
                              DropdownMenuItem(
                                value: 'roberts',
                                child: Text('Roberts'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null)
                                controller.edgeDetectionMethod.value = val;
                            },
                          ),
                        ),
                      );
                    }
                    if (active.contains('rotation')) {
                      controls.add(
                        _Section(
                          title:
                              'Rotation (${controller.rotationAngle.value.toInt()}°)',
                          child: Slider(
                            value: controller.rotationAngle.value,
                            min: 0,
                            max: 360,
                            divisions: 360,
                            label: controller.rotationAngle.value
                                .toInt()
                                .toStringAsFixed(0),
                            onChanged: (v) =>
                                controller.rotationAngle.value = v,
                          ),
                        ),
                      );
                    }
                    if (active.contains('scaling')) {
                      controls.add(
                        _Section(
                          title:
                              'Scaling (${controller.scaleFactor.value.toStringAsFixed(2)}x)',
                          child: Slider(
                            value: controller.scaleFactor.value,
                            min: 0.1,
                            max: 2.0,
                            onChanged: (v) => controller.scaleFactor.value = v,
                          ),
                        ),
                      );
                    }
                    if (active.contains('flipping')) {
                      controls.add(
                        _Section(
                          title: 'Flipping',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ChoiceChip(
                                label: Text('Horizontal'),
                                selected: controller.flipHorizontal.value,
                                onSelected: (v) =>
                                    controller.flipHorizontal.value = v,
                              ),
                              SizedBox(height: 8),
                              ChoiceChip(
                                label: Text('Vertical'),
                                selected: controller.flipVertical.value,
                                onSelected: (v) =>
                                    controller.flipVertical.value = v,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (active.contains('translation')) {
                      controls.add(
                        _Section(
                          title:
                              'Translation (X: ${controller.translateX.value.toInt()}, Y: ${controller.translateY.value.toInt()})',
                          child: Column(
                            children: [
                              Slider(
                                value: controller.translateX.value,
                                min: -100,
                                max: 100,
                                divisions: 200,
                                label: controller.translateX.value
                                    .toInt()
                                    .toString(),
                                onChanged: (v) =>
                                    controller.translateX.value = v,
                              ),
                              Slider(
                                value: controller.translateY.value,
                                min: -100,
                                max: 100,
                                divisions: 200,
                                label: controller.translateY.value
                                    .toInt()
                                    .toString(),
                                onChanged: (v) =>
                                    controller.translateY.value = v,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (controls.isEmpty) {
                      return Center(
                        child: Text(
                          'Choose an editing method to see controls here.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      );
                    }

                    return Column(children: [...controls]);
                  }),
                ],
              ),
            ),
          ),

          // Horizontal Methods Strip at Bottom (like Picsart)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Obx(() {
              final selected = controller.selectedMethods;

              Widget buildMethodChip(String id, String label, IconData icon) {
                final bool isActive = selected.contains(id);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: isActive
                            ? accentColor
                            : secondaryColor,
                        child: IconButton(
                          icon: Icon(
                            icon,
                            color: isActive ? Colors.white : primaryColor,
                            size: 24,
                          ),
                          onPressed: () => controller.toggleMetode(id),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive ? primaryColor : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                children: [
                  buildMethodChip(
                    'grayscale',
                    'Grayscale',
                    Icons.filter_b_and_w,
                  ),
                  buildMethodChip('invert', 'Invert', Icons.invert_colors),
                  buildMethodChip('sepia', 'Sepia', Icons.camera),
                  buildMethodChip('brightness', 'Brightness', Icons.wb_sunny),
                  buildMethodChip('contrast', 'Contrast', Icons.tonality),
                  buildMethodChip('saturation', 'Saturation', Icons.water_drop),
                  buildMethodChip('hue', 'Hue', Icons.color_lens),
                  buildMethodChip('blur', 'Gaussian', Icons.blur_on),
                  buildMethodChip('mosaic', 'Mosaic', Icons.grid_on),
                  buildMethodChip('sharpen', 'Sharpen', Icons.auto_fix_high),
                  buildMethodChip('edge_detection', 'Edge', Icons.grain),
                  buildMethodChip(
                    'hist_equal',
                    'Hist EQ',
                    Icons.auto_graph_rounded,
                  ),
                  buildMethodChip(
                    'rotation',
                    'Rotation',
                    Icons.rotate_90_degrees_ccw,
                  ),
                  buildMethodChip('scaling', 'Scaling', Icons.zoom_out_map),
                  buildMethodChip('flipping', 'Flipping', Icons.flip),
                  buildMethodChip(
                    'translation',
                    'Translation',
                    Icons.open_with,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    const secondaryColor = Color(0xFFF8BBD0);
    const primaryColor = Color(0xFFE91E63);

    return Card(
      color: secondaryColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class HistogramPainter extends CustomPainter {
  final Map<String, List<int>> histogramData;
  HistogramPainter(this.histogramData);

  @override
  void paint(Canvas canvas, Size size) {
    final paintR = Paint()
      ..color = Colors.red
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final paintG = Paint()
      ..color = Colors.green
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final paintB = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double stepX = size.width / 256;
    final double maxCount = histogramData.values
        .expand((list) => list)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    Path pathR = Path();
    Path pathG = Path();
    Path pathB = Path();

    for (int i = 0; i < 256; i++) {
      final x = i * stepX;
      final yR =
          size.height - (histogramData['r']![i] / maxCount) * size.height;
      final yG =
          size.height - (histogramData['g']![i] / maxCount) * size.height;
      final yB =
          size.height - (histogramData['b']![i] / maxCount) * size.height;

      if (i == 0) {
        pathR.moveTo(x, yR);
        pathG.moveTo(x, yG);
        pathB.moveTo(x, yB);
      } else {
        pathR.lineTo(x, yR);
        pathG.lineTo(x, yG);
        pathB.lineTo(x, yB);
      }
    }

    canvas.drawPath(pathR, paintR);
    canvas.drawPath(pathG, paintG);
    canvas.drawPath(pathB, paintB);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
