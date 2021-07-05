import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image/image.dart';

import 'crop_editor_helper.dart';
import 'image_saver.dart';

void main() {
  runApp(Home());
}

class Home extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BRImageResizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'BRImageResizer - Image resizer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? _imageData;
  int _imageWidth = 0;
  int _imageHeight = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green[300],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageData == null
                ? Text('Select image file to resize.')
                : ImageResizer(
                    imageData: _imageData,
                    imageWidth: _imageWidth,
                    imageHeight: _imageHeight),
            SizedBox(height: 30),
            ElevatedButton(
                onPressed: () {
                  FilePicker.platform
                      .pickFiles(type: FileType.image)
                      .then((value) {
                    if (value != null && value.files.length > 0) {
                      setState(() {
                        _imageData = value.files[0].bytes;
                        var image = decodeImage(_imageData!);
                        _imageWidth = image!.width;
                        _imageHeight = image.height;
                      });
                    }
                  });
                },
                child: Text("Select image file")),
          ],
        ),
      ),
    );
  }
}

class ImageResizer extends StatefulWidget {
  ImageResizer(
      {Key? key,
      required this.imageData,
      required this.imageWidth,
      required this.imageHeight})
      : super(key: key) {
    ratio = imageWidth / imageHeight;
  }

  Uint8List? imageData;
  int imageWidth = 0;
  int imageHeight = 0;
  double ratio = 1;

  @override
  _ImageResizerState createState() => _ImageResizerState();
}

class _ImageResizerState extends State<ImageResizer> {
  bool _cropping = false;

  final GlobalKey<ExtendedImageEditorState> imageKey =
      GlobalKey<ExtendedImageEditorState>();

  Future<void> _cropImage() async {
    if (_cropping) {
      return;
    }

    String msg = '';
    try {
      _cropping = true;

      Uint8List? newImageData;

      newImageData =
          await cropImageDataWithDartLibrary(state: imageKey.currentState!);

      var image = decodeImage(newImageData!);
      var newImage = copyResize(image!,
          height: widget.imageHeight, width: widget.imageWidth);
      newImageData = Uint8List.fromList(encodeJpg(newImage));
      //

      await ImageSaver.save('extended_image_cropped_image.jpg', newImageData);
    } catch (e, stack) {
      msg = 'save failed: $e\n $stack';
      _cropping = false;
      print(msg);
    }

    _cropping = false;
  }

  @override
  Widget build(BuildContext context) {
    _cropping = false;
    return Row(
      children: [
        Container(
          margin: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height - 300,
          child: ExtendedImage.memory(
            widget.imageData!,
            extendedImageEditorKey: imageKey,
            mode: ExtendedImageMode.editor,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.height - 300,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: TextFormField(
                  key: Key(widget.imageWidth.toString()),
                    onFieldSubmitted: (text) {
                      setState(() {
                        // 폭을 변경하면 높이를 비율에 맞게 조정
                        widget.imageWidth = int.parse(text.toString());
                        double w = widget.imageWidth as double;
                        double newHeight = w / widget.ratio;
                        var nh = newHeight.floor();
                        widget.imageHeight = nh;
                      });
                    },
                    keyboardType: TextInputType.number,
                    initialValue: widget.imageWidth.toString(),
                    decoration: InputDecoration(
                        labelText: "Width(px)",
                        icon: Icon(Icons.swap_horizontal_circle_outlined))),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: TextFormField(
                  key: Key(widget.imageHeight.toString()),
                    onChanged: (text) {},
                    keyboardType: TextInputType.number,
                    initialValue: widget.imageHeight.toString(),
                    decoration: InputDecoration(
                        labelText: "Height(px)",
                        icon: Icon(Icons.swap_vertical_circle_outlined))),
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.15,
                child: ElevatedButton(
                    onPressed: () {
                      imageKey.currentState!.rotate(right: true);
                    },
                    child: Text('Rotate')),
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.15,
                child: ElevatedButton(
                    onPressed: () {
                      imageKey.currentState!.flip();
                    },
                    child: Text('Flip')),
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.15,
                child: ElevatedButton(
                    onPressed: () {
                      _cropImage();
                    },
                    child: Text('Download')),
              )
            ],
          ),
        )
      ],
    );
  }
}
