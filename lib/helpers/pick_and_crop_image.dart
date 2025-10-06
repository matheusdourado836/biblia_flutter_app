import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<dynamic> showOpcoesBottomSheet(BuildContext context, {required String label}) async {
  return await showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).primaryColor,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(50)
                ),
                child: Icon(
                  Icons.image,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: const Text('Galeria'),
              onTap: () async {
                final file = await pick(context, ImageSource.gallery);
                Navigator.pop(context, file);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(50)
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: const Text('Tirar foto'),
              onTap: () async {
                final file = await pick(context, ImageSource.camera);
                Navigator.pop(context, file);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(50)
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              title: const Text('Remover'),
              onTap: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );
    },
  );
}

Future<File?> pick(BuildContext context, ImageSource source, {String mode = 'round'}) async {
  File? croppedImage;
  var storageStatus = await Permission.storage.status;
  var cameraStatus = await Permission.camera.status;
  if (source == ImageSource.camera && cameraStatus.isDenied) {
    Permission.camera.request();
  }
  if(source == ImageSource.gallery && storageStatus.isDenied) {
    Permission.storage.request();
  }
  final imagePicker = ImagePicker();
  final pickedFile = await imagePicker.pickImage(source: source);
  if (!context.mounted) return null;
  if (pickedFile != null) {
    croppedImage = mode == 'round'
      ? await cropImage(context, File(pickedFile.path))
      : await cropImageSquare(context, File(pickedFile.path));
  }

  return croppedImage;
}

Future<File?> cropImage(BuildContext context, File file) async {
  final cropController = CropController();

  try {
    final imageBytes = await file.readAsBytes();
    Uint8List? croppedBytes;

    if(!context.mounted) return null;

    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: CropPreview(
              controller: cropController,
              mode: CropMode.oval,
              maskOptions: const MaskOptions(
                backgroundColor: Colors.black38,
                borderColor: Colors.grey,
                strokeWidth: 2,
                aspectRatio: 4 / 4,
                minSize: 25,
              ),
              bytes: imageBytes
            ),
          ),
          TextButton(
            onPressed: () async {
              croppedBytes = await cropController.crop();
              Navigator.pop(context, true);
            },
            child: const Text('Cortar')
          )
        ],
      )
    );

    if (croppedBytes == null) {
      return null;
    }

    final directory = await getTemporaryDirectory();
    final croppedFilePath = '${directory.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png';
    final croppedFile = File(croppedFilePath);
    await croppedFile.writeAsBytes(croppedBytes!);

    return croppedFile;
  } catch (e) {
    print('Erro ao cortar a imagem: $e');
    return null;
  }
}

Future<File?> cropImageSquare(BuildContext context, File file) async {
  final cropController = CropController();

  try {
    final imageBytes = await file.readAsBytes();
    Uint8List? croppedBytes;

    if(!context.mounted) return null;

    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: CropPreview(
              controller: cropController,
              maskOptions: const MaskOptions(
                backgroundColor: Colors.black38,
                borderColor: Colors.grey,
                strokeWidth: 2,
                aspectRatio: 5 / 4,
                minSize: 25,
              ),
              bytes: imageBytes
            ),
          ),
          TextButton(
            onPressed: () async {
              croppedBytes = await cropController.crop();
              Navigator.pop(context, true);
            },
            child: const Text('Cortar')
          )
        ],
      )
    );

    if (croppedBytes == null) {
      return null;
    }

    final directory = await getTemporaryDirectory();
    final croppedFilePath = '${directory.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png';
    final croppedFile = File(croppedFilePath);
    await croppedFile.writeAsBytes(croppedBytes!);

    return croppedFile;
  } catch (e) {
    print('Erro ao cortar a imagem: $e');
    return null;
  }
}