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
  bool _cropping = false;
  final GlobalKey<ExtendedImageEditorState> imageKey =
      GlobalKey<ExtendedImageEditorState>();

  @override
  Widget build(BuildContext context) {
    _cropping = false;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

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
                ? Text('')
                : Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(20),
                        width: width * 0.7,
                        height: height - 300,
                        child: ExtendedImage.memory(
                          _imageData!,
                          extendedImageEditorKey: imageKey,
                          mode: ExtendedImageMode.editor,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: width * 0.2,
                        height: height - 300,
                        child: Column(
                          children: [
                            Container(
                              width: width * 0.2,
                              child: TextField(
                                  onChanged: (text) {},
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: "Width(px)",
                                      icon: Icon(Icons
                                          .swap_horizontal_circle_outlined))),
                            ),
                            Container(
                              width: width * 0.2,
                              child: TextField(
                                  onChanged: (text) {},
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: "Height(px)",
                                      icon: Icon(Icons
                                          .swap_vertical_circle_outlined))),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: width * 0.15,
                              child: ElevatedButton(
                                  onPressed: () {
                                    imageKey.currentState!.rotate(right: true);
                                  },
                                  child: Text('Rotate')),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: width * 0.15,
                              child: ElevatedButton(
                                  onPressed: () {
                                    imageKey.currentState!.flip();
                                  },
                                  child: Text('Flip')),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: width * 0.15,
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
                  ),
            SizedBox(height: 30),
            _imageData == null
                ? Text('')
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(),
                      Spacer(),
                      ElevatedButton(
                          onPressed: () {
                            imageKey.currentState!.rotate(right: true);
                          },
                          child: Text('Rotate')),
                      Spacer(),
                      ElevatedButton(
                          onPressed: () {
                            imageKey.currentState!.flip();
                          },
                          child: Text('Flip')),
                      Spacer(),
                      ElevatedButton(
                          onPressed: () {
                            _cropImage();
                          },
                          child: Text('Save')),
                      Spacer(),
                      Spacer(),
                    ],
                  ),
            SizedBox(height: 30),
            ElevatedButton(
                onPressed: () {
                  FilePicker.platform.pickFiles().then((value) {
                    if (value != null && value.files.length > 0) {
                      setState(() {
                        _imageData = value.files[0].bytes;
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

  Future<void> _cropImage() async {
    if (_cropping) {
      return;
    }

    String msg = '';
    try {
      _cropping = true;

      Uint8List? imageData;

      imageData =
          await cropImageDataWithDartLibrary(state: imageKey.currentState!);

      // 테스트 : 이미지 크기를 100 x 100으로 변경하는 코드
      var image = decodeImage(imageData!);
      var newImage = copyResize(image!, height: 100, width: 100);
      imageData = Uint8List.fromList(encodeJpg(newImage));
      //

      await ImageSaver.save('extended_image_cropped_image.jpg', imageData);
    } catch (e, stack) {
      msg = 'save failed: $e\n $stack';
      _cropping = false;
      print(msg);
    }

    _cropping = false;
  }
}
