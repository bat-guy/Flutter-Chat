import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mac/preference/app_preference.dart';
import 'package:flutter_mac/preference/shared_preference.dart';
import 'package:flutter_mac/viewmodel/image_preview_view_model.dart';

class ImagePreview extends StatefulWidget {
  final String imageUrl;

  const ImagePreview({
    super.key,
    required this.imageUrl,
  });

  @override
  State<ImagePreview> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ImagePreview> {
  AppColorPref _colorsPref = AppColorPref();
  final _viewModel = ImagePreviewViewModel();
  var _messageLoaderVisible = false;

  @override
  initState() {
    super.initState();
    _viewModel.messageLoaderStream.listen((isVisible) {
      if (mounted) setState(() => _messageLoaderVisible = isVisible);
    });
    _getColorsPref();
  }

  _getColorsPref() async {
    var a = await AppPreference().getAppColorPref();
    setState(() {
      _colorsPref = a;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: _colorsPref.appBarColor,
          actions: [
            IconButton(onPressed: () => {}, icon: const Icon(Icons.download))
          ],
        ),
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.decal,
              colors: [
                _colorsPref.appBackgroundColor.first,
                _colorsPref.appBackgroundColor.second
              ],
            )),
            child: Center(
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20.0),
                minScale: 0.1,
                maxScale: 3.6,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.colorBurn,
                        ),
                      ),
                    ),
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            )));
  }
}
