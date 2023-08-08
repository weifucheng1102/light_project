import 'package:flutter/material.dart';

typedef ClickCallback = void Function(int selectIndex, String selectString);

const double cellHeight = 50.0;
const double spaceHeight = 5.0;
const Color spaceColor = Color(0xFFE6E6E6); //230

const Color textColor = Color(0xFF323232); //50
const double textFontSize = 18.0;

const Color redTextColor = Color(0xFFE64242); //rgba(230,66,66,1)

const Color titleColor = Color(0xFF787878); //120
const double titleFontSize = 13.0;

class CustomButtomSheet {
  //弹出底部文字
  static void showText(BuildContext context,
      {required List<String> dataArr,
      String? title,
      bool showRedText = false,
      ClickCallback? clickCallback}) {
    var titleHeight = cellHeight;
    var titltLineHeight = 1.0;
    if (title == null) {
      titleHeight = 0.0;
      titltLineHeight = 0.0;
    }
    var _textColor = textColor;
    if (showRedText) {
      _textColor = redTextColor;
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
              child: Container(
            color: Colors.white,
            height: cellHeight * (dataArr.length + 1) +
                (dataArr.length - 1) * 1 +
                spaceHeight +
                titleHeight +
                titltLineHeight,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: titleHeight,
                  child: Center(
                    child: Text(title ?? "",
                        style: const TextStyle(
                            fontSize: titleFontSize, color: titleColor),
                        textAlign: TextAlign.center),
                  ),
                ),
                SizedBox(
                    height: titltLineHeight,
                    child: Container(color: spaceColor)),
                Expanded(
                  child: ListView.separated(
                    itemCount: dataArr.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        child: Container(
                          height: cellHeight,
                          color: Colors.white,
                          child: Center(
                            child: Text(dataArr[index],
                                style: TextStyle(
                                    fontSize: textFontSize, color: _textColor),
                                textAlign: TextAlign.center),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop(index);
                          clickCallback!(index, dataArr[index]);
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 1,
                        color: spaceColor,
                      );
                    },
                  ),
                ),
                SizedBox(
                    height: spaceHeight, child: Container(color: spaceColor)),
                GestureDetector(
                  child: Container(
                    height: cellHeight,
                    color: Colors.white,
                    child: const Center(
                      child: Text("取消",
                          style: TextStyle(
                              fontSize: textFontSize, color: textColor),
                          textAlign: TextAlign.center),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ));
        });
  }
}
