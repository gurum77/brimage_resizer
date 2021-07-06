import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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
  var _presets = new Map<String, List>();

// https://blog.hootsuite.com/social-media-image-sizes-guide/#Instagram_image_sizes
  void _initPresets() {
    var _instagram = [
      SizeInfo.make('Profile photo', Size(320, 320)),
      SizeInfo.make('Feed photo(Landscape)', Size(1000, 566)),
      SizeInfo.make('Feed photo(Portrait)', Size(1000, 1350)),
      SizeInfo.make('Feed photo(square)', Size(1080, 1080)),
      SizeInfo.make('Stories', Size(1080, 1920)),
      SizeInfo.make('Thumbnails', Size(161, 161)),
      SizeInfo.make('Portrait', Size(1080, 1350))
    ];

     var _twitter = [
      SizeInfo.make('Profile photo', Size(400, 400)),
      SizeInfo.make('Header Photo', Size(1500, 500)),
      SizeInfo.make('In-Stram photo', Size(1600, 1900)),
      SizeInfo.make('Card image', Size(1200, 1200)),
      SizeInfo.make('Fleets', Size(1080, 1920))
    ];

    var _facebook = [
      SizeInfo.make('Profile photo', Size(170, 170)),
      SizeInfo.make('Cover photo1', Size(851, 315)),
      SizeInfo.make('Cover photo2', Size(1200, 628)),
      SizeInfo.make('Post/Timeline photo', Size(1200, 630)),
      SizeInfo.make('Stories', Size(1080, 1920)),
      SizeInfo.make('Ads', Size(1080, 1080))
    ];

    var _linkedin = [
      SizeInfo.make('Profile photo', Size(400, 400)),
      SizeInfo.make('Profile cover photo', Size(1584, 396)),
      SizeInfo.make('Blog post link image', Size(1200, 627)),
      SizeInfo.make('Sharing a link in an update', Size(1200, 627)),
      SizeInfo.make('Stories', Size(1080, 1920)),
      SizeInfo.make('Company logo', Size(300, 300)),
      SizeInfo.make('Page cover', Size(1128, 191)),
      SizeInfo.make('Life tab main image', Size(1128, 376)),
      SizeInfo.make('Life tab custom modules', Size(502, 282)),
      SizeInfo.make('Life tab company photo', Size(900, 600)),
      SizeInfo.make('Square logo', Size(60, 60)),
      SizeInfo.make('Company logo size for ads', Size(100, 100)),
      SizeInfo.make('Spotlight ads logo', Size(100, 100)),
      SizeInfo.make('Spotlight ads custom background', Size(300, 250)),
      SizeInfo.make('Sponsored content images', Size(1200, 627)),
      SizeInfo.make('Sponsored content carousel', Size(1080, 1080))
    ];

    var _pinterest = [
      SizeInfo.make('Profile photo', Size(365, 165)),
      SizeInfo.make('Profile cover photo', Size(800, 450)),
      SizeInfo.make('Pins', Size(1000, 1500)),
      SizeInfo.make('Story pins', Size(1080, 1920)),
      SizeInfo.make('Fleets', Size(1080, 1920)),
      SizeInfo.make('Collections pins1', Size(1000, 1000)),
      SizeInfo.make('Collections pins2', Size(1000, 1500)),
      SizeInfo.make('App install ads', Size(1000, 1500)),
      SizeInfo.make('Carousel pins and ads1', Size(1000, 1000)),
      SizeInfo.make('Carousel pins and ads2', Size(1000, 1500)),
      SizeInfo.make('Shopping ads', Size(1000, 1500)),
      
    ];

    var _googlePlayStore = [
      SizeInfo.make('App icon', Size(512, 512)),
      SizeInfo.make('Graphics image', Size(1024, 500)),
      SizeInfo.make('Screen shot(Min,L)', Size(568, 320)),
      SizeInfo.make('Screen shot(Min,P)', Size(320, 568)),
      SizeInfo.make('Screen shot(Max,L)', Size(3840, 2160)),
      SizeInfo.make('Screen shot(Max,P)', Size(2160, 3840))
    ];

    _presets['Instagram best fit'] = _instagram;
    _presets['Twitter best fit'] = _twitter;
    _presets['Face best fit'] = _facebook;
    _presets['Linkedin best fit'] = _linkedin;
    _presets['Google play store'] = _googlePlayStore;
    _presets['Pinterest'] = _pinterest;
  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initPresets();
  }
  // preset을 json에서 로딩하는건 공부하고 나서 하자.
  void _loadPresets() {
    rootBundle.loadString('assets/presets.json').then((value) {
      Map jsonResult = jsonDecode(value);
      jsonResult.forEach((key, value) {
        List<SizeInfo> newPreset = [];
        List list = value;
        list.forEach((element) {
          SizeInfo si = SizeInfo(
              title: element['name'],
              size:
                  Size(double.parse(element['w']), double.parse(element['h'])));
          newPreset.add(si);
        });
        _presets[key] = newPreset;
      });
    });
  }

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
                      imageHeight: _imageHeight,
                      presets: _presets,
                    ),
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

class SizeInfo {
  String title = '';
  Size size = Size(0, 0);
  SizeInfo({required this.title, required this.size});
  SizeInfo.make(String title, Size size) {
    this.title = title;
    this.size = size;
  }
}

class ImageResizer extends StatefulWidget {
  ImageResizer(
      {Key? key,
      required this.imageData,
      required this.imageWidth,
      required this.imageHeight,
      required this.presets})
      : super(key: key) {
    ratio = imageWidth / imageHeight;
    originSize = Size(imageWidth as double, imageHeight as double);
    selectedPresetName = this.presets.keys.elementAt(0);
  }

  Uint8List? imageData;
  int imageWidth = 0;
  int imageHeight = 0;
  double ratio = 1;
  bool lockedAspectRatio = true;
  Size originSize = Size(0, 0);
  Size presetSize = Size(0, 0);
  var presets = new Map<String, List>();
  // var googlePlayStorePresets = [
  //   Size(512, 512),
  //   Size(1024, 500),
  //   Size(568, 320),
  //   Size(3840, 2160),
  //   Size(320, 568),
  //   Size(2160, 3840)
  // ];

  String selectedPresetName = '';

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
                width: MediaQuery.of(context).size.width * 0.18,
                height: 300,
                child: ListView.builder(
                    key: Key(widget.selectedPresetName),
                    itemCount:
                        widget.presets[widget.selectedPresetName]!.length,
                    itemBuilder: (context, position) {
                      return ListTile(
                        title: Text(_getPresetListTileText(position)),
                        leading: Icon(Icons.photo_size_select_large_outlined),
                        onTap: () {
                          setState(() {
                            Size size = widget
                                .presets[widget.selectedPresetName]!
                                .elementAt(position)
                                .size;
                            widget.imageWidth = size.width.toInt();
                            widget.imageHeight = size.height.toInt();
                            widget.ratio =
                                widget.imageWidth / widget.imageHeight;
                          });
                        },
                      );
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

  String _getPresetListTileText(int position) {
    String str;
    Size size =
        widget.presets[widget.selectedPresetName]!.elementAt(position).size;
        String title = widget.presets[widget.selectedPresetName]!.elementAt(position).title;
    str = "$title - ${size.width} x ${size.height}";

    return str;
  }
}
