import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImageDialog extends StatefulWidget {
  @override
  _AddImageDialogState createState() => _AddImageDialogState();
}

class _AddImageDialogState extends State<AddImageDialog> {

  XFile? _image;
  final imagePicker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('画像の選択'),
      children: [
        SimpleDialogOption(
          child: Text('カメラから追加'),
          onPressed: () async {
             final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
                  setState(() {
                    if (pickedFile != null){
                      _image = XFile(pickedFile.path);
                    }
                  });
                  if (!mounted) return;
                  Navigator.of(context).pop(_image);
          },
        ),
        SimpleDialogOption(
          child: Text('ギャラリーから追加'),
          onPressed: () async {
             final List<XFile>? pickedFiles = await imagePicker.pickMultiImage();
            setState(() {
              if (pickedFiles != null){
                for (var i = 0; i < pickedFiles.length; i++) {
                  pickedFiles[i] = XFile(pickedFiles[i].path);
                }
              }
            });
            if (!mounted) return;
            Navigator.of(context).pop(pickedFiles);
          },
        ),
      ],
    );
  }
}