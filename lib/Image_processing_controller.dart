import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'dart:math';

// UBAH KELAS ProcessParams Anda
class ProcessParams {
  final File imageFile;
  final String methodName;
  final double brightness;
  final double contrast;
  final int blurRadius;

  // TAMBAHKAN INI
  final String edgeMethod; // Untuk menyimpan 'sobel' atau 'canny'

  ProcessParams({
    required this.imageFile,
    required this.methodName,
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
  img.Image? processedImage;

  // Beberapa algoritma (seperti edge detection) bekerja
  // paling baik pada gambar grayscale.
  final img.Image grayImage = img.grayscale(originalImage);


  switch (params.methodName) {
    case 'grayscale':
      processedImage = grayImage; // Kita sudah buat di atas
      break;
    case 'invert':
      processedImage = img.invert(originalImage);
      break;
    case 'sepia':
      processedImage = img.sepia(originalImage);
      break;
    case 'brightness':
      processedImage = img.adjustColor(
          originalImage,
          brightness: params.brightness
      );
      break;
    case 'contrast':
      processedImage = img.adjustColor(
          originalImage,
          contrast: params.contrast
      );
      break;
    case 'blur':
      processedImage = img.gaussianBlur(
          originalImage,
          radius: params.blurRadius
      );
      break;
    case 'sharpen':
      processedImage = img.convolution(originalImage, filter: [
        0, -1,  0,
        -1,  5, -1,
        0, -1,  0
      ]);
      break;

    case 'edge_detection':
      final mat = cv.imread(params.imageFile.path);
      final grayMat = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
      if (params.edgeMethod == 'sobel') {
        processedImage = img.sobel(grayImage);
      } else if (params.edgeMethod == 'canny') {

        final edges = cv.canny(grayMat, 100, 200);
        final (succes, bytes) = cv.imencode('.png', edges);
        processedImage = img.decodeImage(bytes)!;

      } else if (params.edgeMethod == 'laplacian') {
        final laplacian = cv.laplacian(grayMat, cv.MatType.CV_8U);
        final (succes, bytes) = cv.imencode('.png', laplacian);
        processedImage = originalImage;
      }else if(params.edgeMethod == 'prewitt'){
        processedImage = applyManualPrewitt(grayImage);
      }else if(params.edgeMethod == 'roberts'){
        processedImage = applyManualRoberts(grayImage);
      }
      else{
        // Default ke Sobel jika metode tidak dikenali
        processedImage = img.sobel(grayImage);
      }
    default:
      processedImage = originalImage;
  }

  return Uint8List.fromList(img.encodePng(processedImage!));
}

// ----- CONTROLLER UTAMA -----
class ImageProcessingController extends GetxController {
  // ... (State lama tetap sama)
  final Rx<File?> gambarAsli = Rx<File?>(null);
  final Rx<Uint8List?> gambarHasilProses = Rx<Uint8List?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedMethod = 'grayscale'.obs;

  // State untuk slider (sesuai UI Anda)
  final RxDouble brightnessValue = 0.0.obs; // UI Anda min: 0
  final RxDouble contrastValue = 1.0.obs;   // UI Anda min: 0, default 1
  final RxDouble blurRadius = 3.0.obs;      // UI Anda min: 1

  // --- TAMBAHKAN STATE BARU UNTUK DROPDOWN ---
  final RxString edgeDetectionMethod = 'sobel'.obs; // Default 'sobel'


  Future<void> pilihGambar() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      gambarAsli.value = File(pickedFile.path);
      gambarHasilProses.value = null; // Reset hasil proses
    }
  }

  // --- UBAH FUNGSI prosesGambar ---
  Future<void> prosesGambar() async {
    if (gambarAsli.value == null || isLoading.isTrue) return;

    try {
      isLoading.value = true;

      final params = ProcessParams(
        imageFile: gambarAsli.value!,
        methodName: selectedMethod.value,
        brightness: brightnessValue.value,
        contrast: contrastValue.value,
        blurRadius: blurRadius.value.toInt(),

        // TAMBAHKAN INI
        edgeMethod: edgeDetectionMethod.value, // Kirim metode yang dipilih
      );

      final Uint8List result = await compute(_processImageInBackground, params);
      gambarHasilProses.value = result;

    } catch (e) {
      print('test');
      print(e);
      Get.snackbar("Error", "Gagal memproses gambar: $e");

    } finally {
      isLoading.value = false;
    }
  }

  void ubahMetode(String? metodeBaru) {
    if (metodeBaru != null) {
      selectedMethod.value = metodeBaru;
    }
  }

}

// Ini adalah implementasi manual dari:
// Gx = [1 0; 0 -1]
// Gy = [0 1; -1 0]
img.Image? applyManualRoberts(img.Image src) {
  final rx = [
    1, 0, 0,
    0, -1, 0,
    0, 0, 0
  ];
  final ry = [
    0, 1, 0,
    -1, 0, 0,
    0, 0, 0
  ];

  final Jx = img.convolution(src, filter: rx);
  final Jy = img.convolution(src, filter: ry);
  Uint8List Jxx = img.encodePng(Jx);
  Uint8List Jyy = img.encodePng(Jy);
  final jy = cv.imdecode(Jyy, cv.IMREAD_GRAYSCALE);
  final jx = cv.imdecode(Jxx, cv.IMREAD_GRAYSCALE);

  final Jedge = cv.sqrt(cv.add(cv.pow(jy, 2), cv.pow(jx, 2)));
  final img.Image? hasil = img.decodeImage(Jedge.data);
  return hasil;
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
          final val = pixel.r; // Ambil channel merah saja

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