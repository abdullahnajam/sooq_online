import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
// ...
class ImagePreview extends StatefulWidget {
  List<dynamic> galleryItems;
  int index;

  ImagePreview(this.galleryItems, this.index);

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
   PageController pageController;
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.index);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return  Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.galleryItems[index]),
                  initialScale: PhotoViewComputedScale.contained * 0.8,
                  heroAttributes: PhotoViewHeroAttributes(tag: index),
                );
              },
              itemCount: widget.galleryItems.length,
              loadingBuilder: (context, event) => Center(
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                  ),
                ),
              ),
              pageController: pageController,


            ),
             Align(
               alignment: Alignment.center,
               child: Container(
                 alignment: Alignment.center,
                    height: 60,
                    width: 100,
                    child:Image.asset("assets/images/watermarkBR.png")),
             ),

          ],
        );}
}
