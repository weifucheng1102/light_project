import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:scan/scan.dart';

import '../widget/custom_appbar.dart';

/// 扫码页面
class QRScannerPage extends StatefulWidget {
  // final QRScannerPageConfig? config;

  //const QRScannerPage({this.config});
  const QRScannerPage({Key? key}) : super(key: key);
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  var stateSetter;

  IconData lightIcon = Icons.flash_on;

  ScanController controller = ScanController();

  List<String> result = [];

  @override
  Widget build(
     context) {
    return Scaffold(
        appBar: const MyAppBar(
          title: '扫码',
        ),
        body: _buildBody());
  }

  Widget _buildBody() {
    return Stack(children: [
      ScanView(
        controller: controller,
        scanAreaScale: 1,
        // scanLineColor: widget.config.scanLineColor,
        onCapture: (String data) async {
          print('扫到了');
          Navigator.pop(context, data);
        },
      ),

      Positioned(
        left: 0,
        bottom: 100,
        right: 0,
        child: Center(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              stateSetter = setState;
              return MaterialButton(
                  child: Icon(lightIcon, size: 30, color: Colors.greenAccent),
                  onPressed: () {
                    controller.toggleTorchMode();
                    if (lightIcon == Icons.flash_on) {
                      lightIcon = Icons.flash_off;
                    } else {
                      lightIcon = Icons.flash_on;
                    }
                    stateSetter(() {});
                  });
            },
          ),
        ),
      ),
      // Positioned(
      //   right: 50,
      //   bottom: 100,
      //   child: MaterialButton(
      //       child: const Icon(Icons.image,
      //           size: 30, color: Color.fromRGBO(4, 184, 67, 1)),
      //       onPressed: () async {
      //         await pickImage();
      //         // DialogUtil.showCommonDialog(context, '$result');
      //       }),
      // ),
    ]);
  }

  // Future<Future<Object?>> showResult({String? content}) async {
  //   return showGeneralDialog(
  //       context: context,
  //       pageBuilder: (context, anim1, anim2) {},
  //       barrierColor: Colors.black.withOpacity(.6),
  //       barrierDismissible: true,
  //       barrierLabel: "",
  //       transitionDuration: Duration(milliseconds: 150),
  //       transitionBuilder: (context, anim1, anim2, child) {
  //         return Transform.scale(
  //             scale: anim1.value,
  //             child: Opacity(
  //                 opacity: anim1.value,
  //                 child: Center(
  //                   child: Padding(
  //                       padding: const EdgeInsets.all(12.0),
  //                       child: Material(
  //                         type: MaterialType.transparency,
  //                         child: Container(
  //                             height: 450,
  //                             width: 300,
  //                             decoration: const ShapeDecoration(
  //                                 color: Colors.white,
  //                                 shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.all(
  //                                   Radius.circular(8.0),
  //                                 ))),
  //                             child: Column(
  //                               children: [
  //                                 Expanded(
  //                                   flex: 2,
  //                                   child: Align(
  //                                     alignment: Alignment.center,
  //                                     child: Text(
  //                                       content!,
  //                                       style: const TextStyle(
  //                                           height: 1, fontSize: 18),
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 DividerHorizontal(),
  //                                 Expanded(
  //                                   flex: 1,
  //                                   child: Row(
  //                                     children: [
  //                                       Expanded(
  //                                           child: GestureDetector(
  //                                         behavior: HitTestBehavior.opaque,
  //                                         onTap: () {
  //                                           Navigator.pop(context);
  //                                         },
  //                                         child: const Align(
  //                                           alignment: Alignment.center,
  //                                           child: Text(
  //                                             '确认',
  //                                             style: TextStyle(
  //                                                 color: Color(0xFFFF7B85),
  //                                                 fontSize: 18),
  //                                           ),
  //                                         ),
  //                                       ))
  //                                     ],
  //                                   ),
  //                                 )
  //                               ],
  //                             )),
  //                       )),
  //                 )));
  //       });
  // }

  // Future qr_flutter() async {
  //   final XFile? image =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     print('扫到了-------');
  //     String? value = await Scan.parse(image.path);
  //     print(value);
  //     if (value != null) {
  //       Navigator.pop(context, value);
  //     }
  //   }
  // }
}

class QRScannerPageConfig {
  double scanAreaSize;
  Color scanLineColor;

  QRScannerPageConfig({
    this.scanAreaSize = 1.0,
    this.scanLineColor = const Color.fromRGBO(4, 184, 67, 1),
  });
}

class DividerHorizontal extends StatelessWidget {
  final double height;
  final Color color;

  const DividerHorizontal(
      {this.height = 1, this.color = const Color(0xFFF8F9F8)});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: color,
    );
  }
}
