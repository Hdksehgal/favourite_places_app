import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});
  final void Function(File image) onPickImage;


  State<ImageInput> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File? selectedimage;

  void _takepicture() async {
    final imagepicker = ImagePicker();
    final pickedimage =
        await imagepicker.pickImage(source: ImageSource.camera, maxWidth: 600);
    // here the ImageSource allows us to decide from where do we have to pick
    // the image from (i.e. gallery or camera)

    if (pickedimage == null) return;

    setState(() {
      selectedimage = File(pickedimage.path);
    });

    widget.onPickImage(selectedimage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
        onPressed: _takepicture,
        icon: const Icon(Icons.camera_outlined),
        label: const Text("Take picture"));

    if (selectedimage != null) {
      content = Stack(
        children: [
          Image.file(
            selectedimage!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TextButton(
                onPressed: _takepicture,
                child: Text(
                  "Retake the picture",
                  style: TextStyle(color: Colors.white.withOpacity(.7)),
                )),
          )
        ],
      );
    }

    return Container(
        decoration: BoxDecoration(
            border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.primary.withOpacity(.3))),
        alignment: Alignment.center,
        height: 250,
        width: double.infinity,
        child: content);
  }
}
