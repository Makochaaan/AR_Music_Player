import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../util/processFile.dart';

class AddImageDialog extends StatefulWidget {
  const AddImageDialog({super.key});

  @override
  _AddImageDialogState createState() => _AddImageDialogState();
}

class _AddImageDialogState extends State<AddImageDialog> {

  String? _image;
  final List<String> _images = [];
  final imagePicker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('画像の選択'),
      children: [
        SimpleDialogOption(
          child: const Text('カメラから追加'),
          onPressed: () async {
            final processer = ProcessFile();

            // ファイルの選択
            final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
            if (pickedFile == null) return;

            // 選択したファイルをassetsフォルダにコピー
            await processer.copyFileToAssets(pickedFile.path, 'image');
            setState(() {
              _image = pickedFile.path;
            });
            if (!mounted) return;
            // パスをmainPageに返し，その先でデータベースに挿入
            Navigator.of(context).pop(_image);
          },
        ),
        SimpleDialogOption(
          child: const Text('ギャラリーから追加'),
          onPressed: () async {
            final processer = ProcessFile();
            final List<XFile> pickedFiles = await imagePicker.pickMultiImage();
            for (var i = 0; i < pickedFiles.length; i++) {
              await processer.copyFileToAssets(pickedFiles[i].path, 'image');
            }
            setState(() {
              for (var i = 0; i < pickedFiles.length; i++) {
                _images.add(pickedFiles[i].path); 
              }
            });
            if (!mounted) return;
            Navigator.of(context).pop(_images);
          },
        ),
      ],
    );
  }
}