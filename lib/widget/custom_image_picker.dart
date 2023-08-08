import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

import '../util/common.dart';
import 'custom_bottom_sheet.dart';
import 'package:device_info_plus/device_info_plus.dart';

typedef PickerCallback = void Function(List<XFile> imageList);

class CustomImagePicker {
  static void pickImage(
    BuildContext context, {
    // required count,
    required bool isMulty,
    required PickerCallback pickerCallback,
  }) {
    final ImagePicker picker = ImagePicker();

    CustomButtomSheet.showText(context, dataArr: ['相册', '相机'],
        clickCallback: (index, string) async {
      bool permissionSuccess = false;

      if (Platform.isIOS) {
        if (index == 0) {
          permissionSuccess = await requestPermission(Permission.photos);
        } else {
          permissionSuccess = true;
        }
      } else {
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          bool photoSuccess = await requestPermission(Permission.photos);
          bool videosSuccess = await requestPermission(Permission.videos);
          bool audioSuccess = await requestPermission(Permission.audio);
          permissionSuccess = photoSuccess && videosSuccess && audioSuccess;
        } else {
          bool storageSuccess = await requestPermission(Permission.storage);
          permissionSuccess = storageSuccess;
        }
      }

      if (index == 1) {
        bool isSuccess = await requestPermission(Permission.camera);
        if (isSuccess && permissionSuccess) {
          final XFile? res = await picker.pickImage(source: ImageSource.camera);
          if (res != null) {
            pickerCallback([res]);
          }
        } else {
          showToast('相机权限被拒绝');
        }
      } else {
        if (permissionSuccess) {
          if (isMulty) {
            final List<XFile> images = await picker.pickMultiImage();
            if (images.isNotEmpty) {
              pickerCallback(images);
            }
          } else {
            final XFile? res =
                await picker.pickImage(source: ImageSource.gallery);
            if (res != null) {
              pickerCallback([res]);
            }
          }
        } else {
          showToast('相册权限被拒绝');
        }
      }
    });
  }
}
