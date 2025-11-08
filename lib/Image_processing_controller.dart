import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:opencv_dart/opencv_dart.dart' as cv;

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
  img.Image processedImage;

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

      } else if(params.edgeMethod == 'roberts'){

      // Encode ke PNG dan ubah ke image package biasa
        final (success, bytes) = cv.imencode('.png', jedge);
        if (!success){
          processedImage = img.grayscale(originalImage);
        };
        processedImage = img.decodeImage(bytes)!;
      }else{
        processedImage = img.grayscale(originalImage);
      }
      break;
    default:
      processedImage = originalImage;
  }

  return Uint8List.fromList(img.encodePng(processedImage));
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