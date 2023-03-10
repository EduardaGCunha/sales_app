import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class ImageInput extends StatefulWidget {
  final Function onSelectImage;

  const ImageInput(this.onSelectImage, {Key? key}) : super(key: key);

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _storedImage;

  _takePicture(bool value) async {
    final ImagePicker picker = ImagePicker();
    XFile? imageFile = await picker.pickImage(
      source: value == true? ImageSource.camera : ImageSource.gallery,
      maxWidth: 600,
    );

    if(imageFile == null){
      return;
    }

    setState(() {
      _storedImage = File(imageFile.path);
    });

    final appDir = await syspaths.getApplicationDocumentsDirectory();
    String fileName = path.basename(_storedImage!.path);
    final savedImage = await _storedImage!.copy(
      '${appDir.path}/$fileName',
    );
    widget.onSelectImage(savedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: _storedImage != null,
          child: Container(
            width: 180,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _storedImage != null
                  ? Image.file(
                      _storedImage!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : const Text('Nenhuma imagem!'),
            ),
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.camera, color: Color.fromARGB(255, 236, 182, 55),),
                label: const Text('Tirar Foto'),
                onPressed: () => _takePicture(true),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.photo_library, color: Color.fromARGB(255, 236, 182, 55),),
                label: const Text('Carregar da Galeria'),
                onPressed: () => _takePicture(false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 50,)
      ],
    );
  }
}
