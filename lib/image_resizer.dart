import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';

import 'crop_editor_helper.dart';
import 'image_saver.dart';

// ignore: must_be_immutable
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
                        title: Text(_getPresetListTileSizeText(position)),
                        subtitle: Text(_getPresetListTileInfoText(position)),

                        // leading: Icon(Icons.photo_size_select_large_outlined),
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

  String _getPresetListTileSizeText(int position) {
    String str;
    Size size =
        widget.presets[widget.selectedPresetName]!.elementAt(position).size;
    str = "${size.width} x ${size.height}";

    return str;
  }

  String _getPresetListTileInfoText(int position) {
    return widget.presets[widget.selectedPresetName]!.elementAt(position).title;
  }
}
