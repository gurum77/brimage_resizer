import 'dart:typed_data';

import 'package:brimage_resizer/preset_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart';
import 'image_resizer.dart';

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

  @override
  void initState() {
    super.initState();
    _presets = PresetHelper.makePresets();
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
