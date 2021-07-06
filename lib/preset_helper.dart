import 'dart:ui';
import 'package:brimage_resizer/SizeInfo.dart';

class PresetHelper {
// https://blog.hootsuite.com/social-media-image-sizes-guide/#Instagram_image_sizes
  static Map<String, List> makePresets() {
    var _presets = new Map<String, List>();

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

    var _youtube = [
      SizeInfo.make('Profile photo', Size(800, 800)),
      SizeInfo.make('Banner', Size(2048, 1152)),
      SizeInfo.make('Video', Size(1280, 720))
    ];

    var _tumblr = [
      SizeInfo.make('Profile photo', Size(128, 128)),
      SizeInfo.make('Aidio post', Size(169, 169)),
      SizeInfo.make('Banner', Size(3000, 1055)),
      SizeInfo.make('Dashboard view', Size(1280, 1920)),
      SizeInfo.make('Ads', Size(1280, 1920))
    ];

    var _snapchat = [
      SizeInfo.make('Ads', Size(1080, 1920)),
      SizeInfo.make('Geofilter', Size(120, 120))
    ];
    var _tiktok = [
      SizeInfo.make('Profile photo', Size(20, 20)),
      SizeInfo.make('Video', Size(1080, 1920))
    ];

    var _googlePlayStore = [
      SizeInfo.make('App icon', Size(512, 512)),
      SizeInfo.make('Graphics image', Size(1024, 500)),
      SizeInfo.make('Screen shot(Min,L)', Size(568, 320)),
      SizeInfo.make('Screen shot(Min,P)', Size(320, 568)),
      SizeInfo.make('Screen shot(Max,L)', Size(3840, 2160)),
      SizeInfo.make('Screen shot(Max,P)', Size(2160, 3840))
    ];

    _presets['Instagram'] = _instagram;
    _presets['Twitter'] = _twitter;
    _presets['Facebook'] = _facebook;
    _presets['Linkedin'] = _linkedin;
    _presets['Youtube'] = _youtube;
    _presets['Pinterest'] = _pinterest;
    _presets['Tumblr'] = _tumblr;
    _presets['Snapchat'] = _snapchat;
    _presets['Tiktok'] = _tiktok;
    _presets['Google play store'] = _googlePlayStore;
    return _presets;
  }
}
