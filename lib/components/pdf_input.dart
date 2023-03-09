import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class PdfInput extends StatefulWidget {
  final Function onSelectPdf;

  const PdfInput(this.onSelectPdf, {Key? key}) : super(key: key);

  @override
  State<PdfInput> createState() => _PdfInputState();
}

class _PdfInputState extends State<PdfInput> {
  File? _storedPdf;

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if(result == null){
      return;
    }

    File pickedPdf = File(result.files.single.path!);
    setState(() {
      _storedPdf = pickedPdf;
    });

    final appDir = await syspaths.getApplicationDocumentsDirectory();
    String fileName = path.basename(_storedPdf!.path);
    final savedPdf = await _storedPdf!.copy(
      '${appDir.path}/$fileName',
    );
    widget.onSelectPdf(savedPdf);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: _storedPdf != null,
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
              child: _storedPdf != null
                  ? const Icon(
                      Icons.picture_as_pdf,
                      size: 50,
                    )
                  : const Text('Nenhum PDF!'),
            ),
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(
                  Icons.picture_as_pdf,
                  color: Color.fromARGB(255, 236, 182, 55),
                ),
                label: const Text('Selecionar PDF'),
                onPressed: () => _pickPdf(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 50)
      ],
    );
  }
}
