import 'dart:io'; //akses file
import 'dart:typed_data'; //akses data biner
import 'package:flutter/foundation.dart'; //akses compute yang tidak mebekukan ui
import 'package:get/get.dart'; //getx
import 'package:image_picker/image_picker.dart'; //"image picker"
import 'package:image/image.dart' as img; 
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'dart:math';



// UBAH KELAS ProcessParams Anda
class ProcessParams {
  final File imageFile;
  final List<String> methods; // daftar metode yang dipilih (berurutan)
  final double brightness;
  final double contrast;
  final int blurRadius;

  // TAMBAHKAN INI
  final String edgeMethod; // Untuk menyimpan 'sobel' / 'canny' / 'laplacian' / 'prewitt' / 'roberts'

  ProcessParams({
    required this.imageFile,
    required this.methods,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.blurRadius = 3,
    // TAMBAHKAN INI
    this.edgeMethod = 'sobel', // Nilai default
  });
}

// UBAH FUNGSI _processImageInBackground
Uint8List _processImageInBackground(ProcessParams params) {
  final bytes = params.imageFile.readAsBytesSync();
  final img.Image originalImage = img.decodeImage(bytes)!;

  // Mulai dari gambar asli, lalu terapkan metode terpilih secara berurutan.
  img.Image current = originalImage;

  // Urutan canonical agar hasil konsisten saat banyak metode dipilih.
  const List<String> canonicalOrder = [
    'grayscale',
    'invert',
    'sepia',
    'brightness',
    'contrast',
    'blur',
    'sharpen',
    'edge_detection',
    'hist_equal'
  ];

  // Filter methods sesuai urutan canonical namun hanya yang dipilih.
  final List<String> toApply = [
    for (final m in canonicalOrder)
      if (params.methods.contains(m)) m,
  ];

  for (final method in toApply) {
    switch (method) {
      case 'grayscale':
        current = img.grayscale(current);
        break;
      case 'invert':
        current = img.invert(current);
        break;
      case 'sepia':
        current = img.sepia(current);
        break;
      case 'brightness':
        current = img.adjustColor(current, brightness: params.brightness);
        break;
      case 'contrast':
        current = img.adjustColor(current, contrast: params.contrast);
        break;
      case 'blur':
        current = img.gaussianBlur(current, radius: params.blurRadius);
        break;
      case 'sharpen':
        current = img.convolution(
          current,
          filter: [0, -1, 0, -1, 5, -1, 0, -1, 0],
        );
        break;
      case 'edge_detection':
        // Pastikan input grayscale untuk deteksi tepi, tanpa memaksa
        // pengguna jika sudah grayscale sebelumnya.
        final img.Image grayImage = img.grayscale(current);

        if (params.edgeMethod == 'sobel') {
          current = img.sobel(grayImage);
        } else if (params.edgeMethod == 'canny') {
          // Konversi 'current' ke Mat, lalu Canny
          final currentBytes = img.encodePng(grayImage);
          final mat = cv.imdecode(currentBytes, cv.IMREAD_GRAYSCALE);
          final edges = cv.canny(mat, 100, 200);
          final (_success, outBytes) = cv.imencode('.png', edges);
          current = img.decodeImage(outBytes)!;
        } else if (params.edgeMethod == 'laplacian') {
          final currentBytes = img.encodePng(grayImage);
          final mat = cv.imdecode(currentBytes, cv.IMREAD_GRAYSCALE);
          final lap = cv.laplacian(mat, cv.MatType.CV_8U);
          final (_success, outBytes) = cv.imencode('.png', lap);
          current = img.decodeImage(outBytes)!;
        } else if (params.edgeMethod == 'prewitt') {
          current = applyManualPrewitt(grayImage);
        } else if (params.edgeMethod == 'roberts') {
          current = applyManualRoberts(grayImage)!;
        } else {
          // default ke Sobel
          current = img.sobel(grayImage);
        }
        break;
      case 'hist_equal':
        print("histogram equalizer");
        final inputBytes = img.encodePng(current);
        final (success, outputBytes) = processEqualizeColor(inputBytes);
        if (success) {
          current = img.decodeImage(outputBytes)!;
        }
        break;
    }
  }

  return Uint8List.fromList(img.encodePng(current));
}

// ----- CONTROLLER UTAMA -----
class ImageProcessingController extends GetxController {
  // ... (State lama tetap sama)
  final Rx<File?> gambarAsli = Rx<File?>(null);
  final Rx<Uint8List?> gambarHasilProses = Rx<Uint8List?>(null);
  final RxBool isLoading = false.obs;
  // Multi-pilih metode
  final RxList<String> selectedMethods =
      <String>[].obs; // tidak default grayscale agar tidak auto convert

  // State untuk slider (sesuai UI Anda)
  final RxDouble brightnessValue = 1.0.obs; // UI Anda min: 0, biar default 1
  final RxDouble contrastValue = 1.0.obs; // UI Anda min: 0, default 1
  final RxDouble blurRadius = 3.0.obs; // UI Anda min: 1

  // --- TAMBAHKAN STATE BARU UNTUK DROPDOWN ---
  final RxString edgeDetectionMethod = 'sobel'.obs; // Default 'sobel'
  final histogramData = <String, List<int>>{}.obs;

  Future<void> pilihGambar() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      gambarAsli.value = File(pickedFile.path);
      gambarHasilProses.value = null; // Reset hasil proses
    }
  }
  
  void generateHistogram(Uint8List imageBytes) {
    final img.Image? decoded = img.decodeImage(imageBytes);
    if (decoded == null) return;

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

    histogramData.value = {
      'r': rHist,
      'g': gHist,
      'b': bHist,
    };
  }

  // --- UBAH FUNGSI prosesGambar ---
  Future<void> prosesGambar() async {
    if (gambarAsli.value == null || isLoading.isTrue) return;
    if (selectedMethods.isEmpty) {
      // Jika tidak ada metode dipilih, tampilkan gambar asli
      gambarHasilProses.value = await gambarAsli.value!.readAsBytes();
      return;
    }

    try {
      isLoading.value = true;

      final params = ProcessParams(
        imageFile: gambarAsli.value!,
        methods: List<String>.from(selectedMethods),
        brightness: brightnessValue.value,
        contrast: contrastValue.value,
        blurRadius: blurRadius.value.toInt(),
        edgeMethod: edgeDetectionMethod.value, // Kirim metode yang dipilih
      );

      final Uint8List result = await compute(_processImageInBackground, params);
      gambarHasilProses.value = result;
      generateHistogram(result);

    } catch (e) {
      print('test');
      print(e);
      Get.snackbar("Error", "Gagal memproses gambar: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleMetode(String metode) {
    if (selectedMethods.contains(metode)) {
      selectedMethods.remove(metode);
    } else {
      selectedMethods.add(metode);
    }
  }
}

// Ini adalah implementasi manual dari:
// Gx = [1 0; 0 -1]
// Gy = [0 1; -1 0]
img.Image? applyManualRoberts(img.Image src) {
  // Convert to OpenCV Mat
  final srcBytes = img.encodePng(src);
  final mat = cv.imdecode(srcBytes, cv.IMREAD_GRAYSCALE);

  // Roberts Cross kernels
  final rx = cv.Mat.fromList(2, 2, cv.MatType(cv.MatType.CV_32F), [
    1.0,
    0.0,
    0.0,
    -1.0,
  ]);
  final ry = cv.Mat.fromList(2, 2, cv.MatType(cv.MatType.CV_32F), [
    0.0,
    1.0,
    -1.0,
    0.0,
  ]);

  // Apply filters
  final jx = cv.filter2D(mat, cv.MatType.CV_32F, rx);
  final jy = cv.filter2D(mat, cv.MatType.CV_32F, ry);

  // Calculate magnitude: sqrt(jx^2 + jy^2)
  final jx2 = cv.multiply(jx, jx);
  final jy2 = cv.multiply(jy, jy);
  final sum = cv.add(jx2, jy2);
  final magnitude = cv.sqrt(sum);

  // Convert back to 8-bit
  final result = cv.Mat.empty();
  cv.normalize(
    magnitude,
    result,
    alpha: 0,
    beta: 255,
    normType: cv.NORM_MINMAX,
    dtype: cv.MatType.CV_8U,
  );

  final (success, bytes) = cv.imencode('.png', result);
  return img.decodeImage(bytes);
}

img.Image applyManualPrewitt(img.Image src) {
  final int width = src.width;
  final int height = src.height;

  // Buat gambar baru untuk menampung hasil
  final img.Image dest = img.Image(width: width, height: height);

  // Kernel Prewitt (Px dan Py)
  final List<int> Px = [-1, 0, 1, -1, 0, 1, -1, 0, 1];
  final List<int> Py = [-1, -1, -1, 0, 0, 0, 1, 1, 1];

  // Loop setiap piksel (lewati pinggirnya)
  for (int y = 1; y < height - 1; ++y) {
    for (int x = 1; x < width - 1; ++x) {
      double Jx = 0; // Gradien X
      double Jy = 0; // Gradien Y

      int i = 0; // Index kernel

      // Terapkan kernel 3x3
      for (int ky = -1; ky <= 1; ++ky) {
        for (int kx = -1; kx <= 1; ++kx) {
          // Ambil nilai piksel (gambar sudah grayscale)
          final pixel = src.getPixel(x + kx, y + ky);
          final val = pixel.r.toDouble(); // Ambil channel merah saja dan konversi ke double

          Jx += val * Px[i];
          Jy += val * Py[i];
          i++;
        }
      }

      // Hitung besaran gradien (Magnitude)
      // Jedge = sqrt(Jx.^2 + Jy.^2)
      final double magnitude = sqrt(Jx * Jx + Jy * Jy);

      // Konversi nilai magnitude ke 0-255 dan pangkas (clamp)
      final int finalVal = magnitude.clamp(0, 255).toInt();

      // Set piksel di gambar tujuan
      dest.setPixelRgba(x, y, finalVal, finalVal, finalVal, 255);
    }
  }
  return dest;
}

(bool, Uint8List) processEqualizeCV(Uint8List inputBytes) {

  // 1. Decode sebagai GRAYSCALE (Wajib untuk equalizeHist)
  final grayMat = cv.imdecode(inputBytes, cv.IMREAD_GRAYSCALE);
  if (grayMat.isEmpty) {
    throw Exception("Gagal decode gambar");
  }

  // 2. Buat Mat kosong untuk hasil
  final equalizedMat = cv.Mat.empty();

  // 3. Jalankan fungsinya
  cv.equalizeHist(grayMat, dst: equalizedMat);

  // 4. Encode kembali ke bytes
  final outputBytes = cv.imencode(".png", equalizedMat);

  // 5. Bersihkan memori
  grayMat.dispose();
  equalizedMat.dispose();

  return outputBytes;
}

(bool, Uint8List) processEqualizeColor(Uint8List inputBytes) {
  // 1. Decode as color image (BGR)
  final mat = cv.imdecode(inputBytes, cv.IMREAD_COLOR);
  if (mat.isEmpty) {
    throw Exception("Gagal decode gambar warna");
  }

  // 2. Convert to YCrCb color space
  final ycrcb = cv.cvtColor(mat, cv.COLOR_BGR2YCrCb);

  // 3. Split into channels
  final channels = cv.split(ycrcb);

  // 4. Equalize only the Y (luminance) channel
  final yEq = cv.equalizeHist(channels[0]);
  channels[0].dispose();
  channels[0] = yEq;

  // 5. Merge channels back
  final merged = cv.merge(channels);

  // 6. Convert back to BGR
  final result = cv.cvtColor(merged, cv.COLOR_YCrCb2BGR);

  // 7. Encode result
  final outputBytes = cv.imencode('.png', result);

  // 8. Dispose all mats
  for (final c in channels) {
    c.dispose();
  }
  mat.dispose();
  ycrcb.dispose();
  merged.dispose();
  result.dispose();

  return outputBytes;
}





