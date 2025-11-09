import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Image_processing_controller.dart'; // Pastikan file ini ada

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
      body: Padding(
        padding: const EdgeInsets.all(16.0), //padding keseluruhan
        
        child: SingleChildScrollView( 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bagian 1: Gambar Asli & Hasil
              Row(
                children: [
                  // bagian insert gambar asli
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.pilihGambar(), // tap ke controller
                      child: Obx(
                        () => Container(
                          // styling kotak gambar asli
                          height: 150, //tinggi 
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor, width: 2), //warna border
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: controller.gambarAsli.value == null
                              ? Center(child: Text("Ketuk untuk Pilih Gambar")) //text if null
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
                            ? Center(child: Text("Hasil Proses"))
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
                final histogramData = controller.histogramData;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Histogram (RGB Overlay)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    // Histogram Chart Area
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: accentColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: histogramData.isEmpty
                          ? const Center(
                              child: Text(
                                "Histogram belum tersedia. Tekan 'Proses Gambar' untuk melihat hasil.",
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : CustomPaint(
                              painter: HistogramPainter(histogramData),
                            ),
                    ),
                  ],
                );
              }),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed('/detailed-histogram'); // atau Get.to(DetailHistogramView());
                  },
                  icon: const Icon(Icons.bar_chart_rounded),
                  label: const Text("View Detailed Histogram"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Bagian 3: Tombol Aksi Utama
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.prosesGambar(), // dipencet => prosesGambar
                  icon: const Icon(Icons.play_arrow), //pake libnary icon arrow
                  label: const Text("Proses Gambar"), //text normal
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
              Divider(height: 32), // stand for it's name

              // Edit time
              // Changed from Expanded to SizedBox to allow scrolling in SingleChildScrollView
              SizedBox(
                height: 500, // Increased height to comfortably show all controls including edge detection
                child: Row(
                  children: [
                    // bagian pertama children di kiri dulu
                    Expanded(
                      flex: 1,
                      child: Obx(() {
                        final selected = controller.selectedMethods; //mainan di controller
                        Widget buildChip(String id, String label, IconData icon) {
                          final bool isActive = selected.contains(id);
                          return FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 26),
                                SizedBox(width: 6),
                                Text(label),
                              ],
                            ),
                            selected: isActive,
                            onSelected: (_) => controller.toggleMetode(id),
                            selectedColor: accentColor,
                            backgroundColor: secondaryColor,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isActive ? Colors.white : primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: isActive ? primaryColor : accentColor,
                                width: 2,
                              ),
                            ),
                          );
                        }

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            buildChip(
                              'grayscale',
                              'Grayscale',
                              Icons.filter_b_and_w,
                            ),
                            buildChip('invert', 'Invert', Icons.invert_colors),
                            buildChip('sepia', 'Sepia', Icons.camera),
                            buildChip('brightness', 'Brightness', Icons.wb_sunny),
                            buildChip('contrast', 'Contrast', Icons.tonality),
                            buildChip('blur', 'Gaussian', Icons.blur_on),
                            buildChip('sharpen', 'Sharpen', Icons.auto_fix_high),
                            buildChip('edge_detection', 'Edge', Icons.grain),
                          ],
                        );
                      }),
                    ),

                    // --- PEMISAH ---
                    VerticalDivider(width: 20),

                    // kanan 
                    Expanded(
                      flex: 1,
                      child: Obx(() {
                        final active = controller.selectedMethods;
                        final List<Widget> controls = [];
                      // if case satu satu buat slider di kanan
                        if (active.contains('brightness')) {
                          controls.add(
                            _Section(
                              title:
                                  'Brightness (${controller.brightnessValue.value.toStringAsFixed(1)})',
                              child: Slider(
                                value: controller.brightnessValue.value, //harusnya default 1 (harus dari controller)
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

                        if (controls.isEmpty) {
                          return Center(
                            child: Text(
                              'Pilih metode di kiri untuk mengatur parameter',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          );
                        }

                        return ListView(children: [...controls]);
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      final yR = size.height - (histogramData['r']![i] / maxCount) * size.height;
      final yG = size.height - (histogramData['g']![i] / maxCount) * size.height;
      final yB = size.height - (histogramData['b']![i] / maxCount) * size.height;

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
