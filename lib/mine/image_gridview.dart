import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/mine/photo_preview.dart';

class ImageGridView extends StatefulWidget {
  ///是否编辑模式
  final bool isEdit;

  ///图片列表
  final List imageList;

  ///一行数量
  final int crossAxisCount;

  /// 最多显示的图片数量
  final int? maxImageLength;

  ///删除图片回调
  final Function(int)? delectCallBack;

  ///添加图片回调
  final Function? addCallBack;

  final String? addImage;

  ///是否是视频
  final bool? isVideo;

  final double? ratio;

  final void Function()? onTap;

  const ImageGridView({
    required this.isEdit,
    required this.imageList,
    required this.crossAxisCount,
    this.maxImageLength,
    this.delectCallBack,
    this.addCallBack,
    this.addImage,
    this.isVideo = false,
    this.onTap,
    this.ratio,
    Key? key,
  }) : super(key: key);

  @override
  _ImageGridViewState createState() => _ImageGridViewState();
}

class _ImageGridViewState extends State<ImageGridView> {
  @override
  Widget build(BuildContext context) {
    return widget.imageList.isEmpty && !widget.isEdit
        ? Container()
        : GridView.count(
            padding: const EdgeInsets.symmetric(vertical: 10),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            //一行的Widget数量
            crossAxisCount: widget.crossAxisCount,
            //子Widget宽高比例
            childAspectRatio: widget.ratio ?? 1,
            //子Widget列表
            children: listItems(),
          );
  }

  List<Widget> listItems() {
    List<Widget> list = [];
    for (var i = 0; i < widget.imageList.length; i++) {
      list.add(
        Stack(
          children: [
            InkWell(
              onTap: widget.onTap ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoPreview(
                          galleryItems: widget.imageList,
                          defaultImage: i,
                        ),
                      ),
                    );
                  },
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.w),
                      image: DecorationImage(
                        image: NetworkImage(widget.imageList[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.isEdit,
                    child: Positioned(
                      right: 0.w,
                      top: 0.w,
                      child: GestureDetector(
                        onTap: () {
                          widget.delectCallBack!(i);
                        },
                        child: Image.asset(
                          'images/del_image.png',
                          width: 34.w,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.isVideo != null && widget.isVideo!,
                    child: Center(
                      child: Image.asset('images/video_play.png'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (widget.isEdit &&
        (widget.maxImageLength == null ||
            widget.imageList.length < widget.maxImageLength!)) {
      list.add(
        GestureDetector(
          onTap: () {
            if (widget.addCallBack != null) {
              widget.addCallBack!();
            }
          },
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Image.asset(
              widget.addImage == null
                  ? 'images/add_image.png'
                  : widget.addImage!,
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
    }
    return list;
  }
}
