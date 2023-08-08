import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

typedef PageChanged = void Function(int index);

class PhotoPreview extends StatefulWidget {
  final List galleryItems; //图片列表
  final int defaultImage; //默认第几张
  final PageChanged? pageChanged; //切换图片回调
  final Axis direction; //图片查看方向
  final BoxDecoration? decoration; //背景设计
  final bool isLocal;

  const PhotoPreview({
    Key? key,
    required this.galleryItems,
    required this.defaultImage,
    this.pageChanged,
    this.direction = Axis.horizontal,
    this.decoration,
    this.isLocal = false,
  }) : super(key: key);
  @override
  _PhotoPreviewState createState() => _PhotoPreviewState();
}

class _PhotoPreviewState extends State<PhotoPreview> {
  int? tempSelect;
  @override
  void initState() {
    super.initState();
    tempSelect = widget.defaultImage + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Stack(
          children: [
            PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return widget.isLocal
                      ? PhotoViewGalleryPageOptions(
                          imageProvider:
                              FileImage(File(widget.galleryItems[index])),
                        )
                      : PhotoViewGalleryPageOptions(
                          imageProvider:
                              NetworkImage(widget.galleryItems[index]),
                        );
                },
                scrollDirection: widget.direction,
                itemCount: widget.galleryItems.length,
                backgroundDecoration: widget.decoration ??
                    const BoxDecoration(color: Colors.white),
                pageController:
                    PageController(initialPage: widget.defaultImage),
                onPageChanged: (index) => setState(() {
                      tempSelect = index + 1;
                      if (widget.pageChanged != null) {
                        widget.pageChanged!(index);
                      }
                    })),
            Positioned(
              ///布局自己换
              right: 20,
              top: 20,
              child: SafeArea(
                child: Text(
                  '$tempSelect/${widget.galleryItems.length}',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
