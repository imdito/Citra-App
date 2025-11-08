import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Image_processing_controller.dart'; // Pastikan file ini ada

class ImageProcessingView extends StatelessWidget {
  ImageProcessingView({Key? key}) : super(key: key);

  final ImageProcessingController controller = Get.put(ImageProcessingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Processor (GetX)")),
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
                    child: Obx(() => Container(
                      height: 150,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)),
                      child: controller.gambarAsli.value == null
                          ? Center(child: Text("Ketuk untuk Pilih Gambar"))
                          : Image.file(controller.gambarAsli.value!,
                          fit: BoxFit.cover),
                    )),
                  ),
                ),
                SizedBox(width: 16),

                // --- Gambar Hasil Proses ---
                Expanded(
                  child: Obx(() => Container(
                    height: 150,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey)),
                    child: controller.isLoading.isTrue
                        ? Center(child: CircularProgressIndicator())
                        : controller.gambarHasilProses.value == null
                        ? Center(child: Text("Hasil Proses"))
                        : Image.memory(
                        controller.gambarHasilProses.value!,
                        fit: BoxFit.cover),
                  )),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Bagian 2: Histogram (Placeholder)
            SizedBox(height: 16),

            // Bagian 3: Tombol Aksi Utama
            ElevatedButton(
              onPressed: () => controller.prosesGambar(),
              child: Text("Proses Gambar"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48), // Tombol lebar penuh
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
                    // Kita harus membungkus ListView dengan Obx
                    // agar tombol bisa berganti style (solid/outline)
                    child: Obx(() {
                      // Ambil nilai yang sedang dipilih
                      final String selectedId = controller.selectedMethod.value;

                      return ListView(
                        children: [
                          // --- Tombol Grayscale ---
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: selectedId == 'grayscale'
                                ? ElevatedButton(
                              onPressed: () =>
                                  controller.ubahMetode('grayscale'),
                              child: Text('GrayScale'),
                            )
                                : OutlinedButton(
                              onPressed: () =>
                                  controller.ubahMetode('grayscale'),
                              child: Text('GrayScale'),
                            ),
                          ),
                          // --- Tombol Invert Colors ---
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: selectedId == 'invert'
                                ? ElevatedButton(
                              onPressed: () =>
                                  controller.ubahMetode('invert'),
                              child: Text('Invert Colors'),
                            )
                                : OutlinedButton(
                              onPressed: () =>
                                  controller.ubahMetode('invert'),
                              child: Text('Invert Colors'),
                            ),
                          ),
                          // --- Tombol Sepia Tone ---
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: selectedId == 'sepia'
                                ? ElevatedButton(
                              onPressed: () =>
                                  controller.ubahMetode('sepia'),
                              child: Text('Sepia Tone'),
                            )
                                : OutlinedButton(
                              onPressed: () =>
                                  controller.ubahMetode('sepia'),
                              child: Text('Sepia Tone'),
                            ),
                          ),
                          // --- Tombol Edge Detection ---
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: selectedId == 'edge_detection'
                                ? ElevatedButton(
                              onPressed: () => controller
                                  .ubahMetode('edge_detection'),
                              child: Text('Edge Detection'),
                            )
                                : OutlinedButton(
                              onPressed: () => controller
                                  .ubahMetode('edge_detection'),
                              child: Text('Edge Detection'),
                            ),
                          ),
                          // --- Tombol Brightness ---
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: selectedId == 'brightness'
                                ? ElevatedButton(
                              onPressed: () =>
                                  controller.ubahMetode('brightness'),
                              child: Text('Brightness'),
                            )
                                : OutlinedButton(
                              onPressed: () =>
                                  controller.ubahMetode('brightness'),
                              child: Text('Brightness'),
                            ),
                          ),
                          // --- Tombol Contrast ---
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: selectedId == 'contrast'
                                ? ElevatedButton(
                              onPressed: () =>
                                  controller.ubahMetode('contrast'),
                              child: Text('Contrast'),
                            )
                                : OutlinedButton(
                              onPressed: () =>
                                  controller.ubahMetode('contrast'),
                              child: Text('Contrast'),
                            ),
                          ),
                          // --- Tombol Blur ---
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: selectedId == 'blur'
                                ? ElevatedButton(
                              onPressed: () =>
                                  controller.ubahMetode('blur'),
                              child: Text('Gaussian Blur'),
                            )
                                : OutlinedButton(
                              onPressed: () =>
                                  controller.ubahMetode('blur'),
                              child: Text('Gaussian Blur'),
                            ),
                          ),
                          // --- Tombol Sharpen ---
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: selectedId == 'sharpen'
                                ? ElevatedButton(
                              onPressed: () =>
                                  controller.ubahMetode('sharpen'),
                              child: Text('Sharpen Image'),
                            )
                                : OutlinedButton(
                              onPressed: () =>
                                  controller.ubahMetode('sharpen'),
                              child: Text('Sharpen Image'),
                            ),
                          ),
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
                      // Semua logika 'switch' sekarang ada di sini
                      final selected = controller.selectedMethod.value;

                      switch (selected) {
                        case 'brightness':
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Intensitas Brightness: ${controller.brightnessValue.value.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Slider(
                                value: controller.brightnessValue.value,
                                min: 0,
                                max: 10,
                                onChanged: (val) {
                                  controller.brightnessValue.value = val;
                                },
                              ),
                            ],
                          );
                        case 'contrast':
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Intensitas Kontras: ${controller.contrastValue.value.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Slider(
                                value: controller.contrastValue.value,
                                min: 0,
                                max: 2,
                                onChanged: (val) {
                                  controller.contrastValue.value = val;
                                },
                              ),
                            ],
                          );
                        case 'blur':
                        // Ambil nilai integer
                          final int radius = controller.blurRadius.value.toInt();
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Radius Blur: $radius',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Slider(
                                value: radius.toDouble(), // Kirim balik
                                min: 1,
                                max: 10,
                                divisions: 9, // (10-1)
                                label: radius.toString(),
                                onChanged: (val) {
                                  controller.blurRadius.value = val;
                                },
                              ),
                            ],
                          );
                        case 'edge_detection':
                          return Column(
                            children: [
                              Expanded(
                                child: Text(
                                  "Metode Deteksi Tepi",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 16),
                              Expanded(
                                child: DropdownButton<String>(
                                  value: controller.edgeDetectionMethod.value,
                                  items: [
                                    DropdownMenuItem(
                                      value: 'sobel',
                                      child: Text('Sobel'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'canny',
                                      child: Text('Canny'),
                                    ),
                                    DropdownMenuItem(
                                        value: 'roberts',
                                        child: Text('Roberts'))
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.edgeDetectionMethod.value = val;
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        default:
                          return Center(
                            child: Text(
                              "Tidak ada opsi tambahan untuk metode ini.",
                              textAlign: TextAlign.center,
                            ),
                          );
                      }
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