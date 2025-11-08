import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Image_processing_controller.dart'; // Pastikan file ini ada

class ImageProcessingView extends StatelessWidget {
  ImageProcessingView({Key? key}) : super(key: key);

  final ImageProcessingController controller = Get.put(
    ImageProcessingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Processor"),
        backgroundColor: const Color(0xFFB8C3FF),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bagian 1: Gambar Asli & Hasil
            Row(
              children: [
                // --- Gambar Asli ---
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.pilihGambar(),
                    child: Obx(
                      () => Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: controller.gambarAsli.value == null
                            ? Center(child: Text("Ketuk untuk Pilih Gambar"))
                            : Image.file(
                                controller.gambarAsli.value!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // --- Gambar Hasil Proses ---
                Expanded(
                  child: Obx(
                    () => Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
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

            // Bagian 2: Histogram (Placeholder)
            SizedBox(height: 16),

            // Bagian 3: Tombol Aksi Utama
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.prosesGambar(),
                icon: const Icon(Icons.play_arrow),
                label: const Text("Proses Gambar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD6A5),
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            Divider(height: 32),

            // Bagian 4: Kontrol (Struktur Master-Detail)
            Expanded(
              child: Row(
                children: [
                  // --- SISI KIRI (Daftar Metode) ---
                  Expanded(
                    flex: 1,
                    child: Obx(() {
                      final selected = controller.selectedMethods;
                      Widget buildChip(String id, String label, IconData icon) {
                        final bool isActive = selected.contains(id);
                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 16),
                              SizedBox(width: 4),
                              Text(label),
                            ],
                          ),
                          selected: isActive,
                          onSelected: (_) => controller.toggleMetode(id),
                          selectedColor: const Color(0xFFA0E7E5),
                          backgroundColor: const Color(0xFFF3F4F8),
                          checkmarkColor: Colors.black87,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: isActive
                                  ? Colors.teal.shade400
                                  : Colors.grey.shade300,
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

                  // --- SISI KANAN (Opsi/Parameter) ---
                  Expanded(
                    flex: 1,
                    child: Obx(() {
                      final active = controller.selectedMethods;
                      final List<Widget> controls = [];

                      if (active.contains('brightness')) {
                        controls.add(
                          _Section(
                            title:
                                'Brightness (${controller.brightnessValue.value.toStringAsFixed(1)})',
                            child: Slider(
                              value: controller.brightnessValue.value,
                              min: 0,
                              max: 10,
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
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF1E6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
