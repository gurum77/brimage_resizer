import 'dart:ui';

class SizeInfo {
  String title = '';
  Size size = Size(0, 0);
  SizeInfo({required this.title, required this.size});
  SizeInfo.make(String title, Size size) {
    this.title = title;
    this.size = size;
  }
}
