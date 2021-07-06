import 'dart:html';
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
        child: SingleChildScrollView(
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
    originSize = Size(imageWidth as double, imageHeight as double);

    presets['Google play store'] = googlePlayStorePresets;
    presets['Itch.io'] = itchIoPresets;
  }

  Uint8List? imageData;
  int imageWidth = 0;
  int imageHeight = 0;
  double ratio = 1;
  bool lockedAspectRatio = true;
  Size originSize = Size(0, 0);
  Size presetSize = Size(0, 0);
  var googlePlayStorePresets = [
    Size(512, 512),
    Size(1024, 500),
    Size(568, 320),
    Size(3840, 2160),
    Size(320, 568),
    Size(2160, 3840)
  ];
  var itchIoPresets = [Size(315, 250), Size(630, 500)];
  var presets = new Map<String, List>();
  String selectedPresetName = 'Google play store';

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
            initEditorConfigHandler: (state) {
              return EditorConfig(
                  cropRectPadding: EdgeInsets.all(20),
                  cornerColor: Colors.red,
                  cropAspectRatio: widget.imageWidth / widget.imageHeight);
            },
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.2,
          // height: MediaQuery.of(context).size.height - 300,
          child: Column(
            children: [
              DropdownButton<String>(
                value: widget.selectedPresetName,
                isExpanded: true,
                items: _getPresetNameItems(),
                elevation: 16,
                onChanged: (presetName) {
                  setState(() {
                    widget.selectedPresetName = presetName.toString();
                    // widget.imageWidth = size!.width as int;
                    // widget.imageHeight = size.height as int;
                    // if (widget.imageWidth == 0 || widget.imageHeight == 0) {
                    //   widget.imageWidth = widget.originSize.width as int;
                    //   widget.imageHeight = widget.originSize.height as int;
                    // }
                    // widget.ratio = widget.imageWidth / widget.imageHeight;
                    // widget.presetSize = size;
                  });
                },
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: 200,
                child: ListView.builder(
                    key: Key(widget.selectedPresetName),
                    itemCount:
                        widget.presets[widget.selectedPresetName]!.length,
                    itemBuilder: (context, position) {
                      print(widget.presets[widget.selectedPresetName]!.length
                          .toString());
                      return Text(widget.presets[widget.selectedPresetName]!
                          .elementAt(position)
                          .toString());
                    }),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: TextFormField(
                    key: Key(widget.imageWidth.toString()),
                    onFieldSubmitted: (text) {
                      setState(() {
                        if (text != "") {
                          // 폭을 변경하면 높이를 비율에 맞게 조정
                          int newWidth = int.parse(text.toString());
                          if (newWidth > 0) {
                            widget.imageWidth = newWidth;
                            if (widget.lockedAspectRatio) {
                              _setImageHeightByRatio();
                            }
                          }
                        }
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
                    onFieldSubmitted: (text) {
                      setState(() {
                        if (text != "") {
                          // 높이를 변경하면 폭을 비율에 맞게 조정
                          int newHeight = int.parse(text.toString());
                          if (newHeight > 0) {
                            widget.imageHeight = newHeight;

                            if (widget.lockedAspectRatio) {
                              _setImageWidthByRatio();
                            }
                          }
                        }
                      });
                    },
                    keyboardType: TextInputType.number,
                    initialValue: widget.imageHeight.toString(),
                    decoration: InputDecoration(
                        labelText: "Height(px)",
                        icon: Icon(Icons.swap_vertical_circle_outlined))),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                      key: Key(widget.lockedAspectRatio.toString()),
                      value: widget.lockedAspectRatio,
                      onChanged: (checked) {
                        setState(() {
                          widget.lockedAspectRatio = checked!;
                          if (widget.lockedAspectRatio)
                            _setImageHeightByRatio();
                        });
                      }),
                  Text('Lock Aspect Ratio', style: TextStyle(fontSize: 12))
                ],
              ),
              // SizedBox(height: 20),
              // Container(
              //   width: MediaQuery.of(context).size.width * 0.15,
              //   child: ElevatedButton(
              //       onPressed: () {
              //         imageKey.currentState!.rotate(right: true);
              //       },
              //       child: Text('Rotate')),
              // ),
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
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue[900],
                    ),
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

  void _setImageHeightByRatio() {
    double w = widget.imageWidth as double;
    double newHeight = w / widget.ratio;
    var nh = newHeight.floor();
    widget.imageHeight = nh;
  }

  void _setImageWidthByRatio() {
    double h = widget.imageHeight as double;
    double newWidth = h * widget.ratio;
    var nw = newWidth.floor();
    widget.imageWidth = nw;
  }

  List<DropdownMenuItem<String>> _getPresetNameItems() {
    List<DropdownMenuItem<String>> items = [];
    for (var presetName in widget.presets.keys) {
      items.add(
          DropdownMenuItem<String>(value: presetName, child: Text(presetName)));
    }

    return items;
  }
}
