
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:oktoast/oktoast.dart';
import 'dart:async';

import '../config/app.dart';
import '../config/get_box.dart';
import '../config/nav_key.dart';
import '../login/login.dart';

class ServiceRequest {
  static Future get(
    String url, {
    Map<String, dynamic>? header,
    required Map<String, dynamic>? data,
    required Function? success,
    required Function? error,
    bool showProgress = true,
  }) async {
    Map<String, dynamic> headers = header ?? {};
    // 发送get请求
    await _sendRequest(url, 'get', success!,
        data: data!,
        headers: headers,
        error: error!,
        showProgress: showProgress);
  }

  static Future post(
    String url, {
    Map<String, dynamic>? header,
    required Map<String, dynamic>? data,
    required Function? success,
    required Function? error,
    bool showProgress = true,
  }) async {
    // 发送post请求
    Map<String, dynamic> headers = header ?? {};
    return _sendRequest(url, 'post', success!,
        data: data!,
        headers: headers,
        error: error!,
        showProgress: showProgress);
  }

  static Future put(
    String url, {
    Map<String, dynamic>? header,
    required Map<String, dynamic>? data,
    required Function? success,
    required Function? error,
    bool showProgress = true,
  }) async {
    // 发送post请求
    Map<String, dynamic> headers = header ?? {};
    return _sendRequest(url, 'put', success!,
        data: data!,
        headers: headers,
        error: error!,
        showProgress: showProgress);
  }

  ///上传文件
  static Future upload(
    String url, {
    Map<String, dynamic>? header,
    required Map<String, dynamic>? data,
    required Function? success,
    required Function? error,
    bool showProgress = true,
  }) async {
    // 发送post请求
    Map<String, dynamic> headers = header ?? {};
    return _sendRequest(url, 'upload', success!,
        data: data!,
        headers: headers,
        error: error!,
        showProgress: showProgress);
  }

  // 请求处理
  static Future _sendRequest(
    String url,
    String method,
    Function success, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    Function? error,
    bool? showProgress,
  }) async {
    int _code;
    String _msg;
    var _backData;
    if (showProgress != null && showProgress) {
      EasyLoading.show(maskType: EasyLoadingMaskType.clear);
    }

    try {
      Map<String, dynamic> dataMap = data ?? {};

      Map<String, dynamic> headersMap = headers ?? {};

      ///请求参数添加token
      if (getBox.read('token') != null) {
        dataMap.addAll({
          'token': getBox.read('token'),
          //'token': 'cdf9a6d2-8cfa-4bc1-9298-31a17ed4387a'
        });
      }
      // headersMap.addAll({
      //   'platform': Platform.isIOS ? 'ios' : 'android',
      // });

      // 配置dio请求信息
      Response? response;
      Dio dio = Dio();

      dio.options.connectTimeout = 60000; // 服务器链接超时，毫秒
      dio.options.receiveTimeout = 60000; // 响应流上前后两次接受到数据的间隔，毫秒
      dio.options.headers
          .addAll(headersMap); // 添加headers,如需设置统一的headers信息也可在此添加
      dio.options.contentType = "application/x-www-form-urlencoded";
      String baseurl = AppConfig.baseUrl;

      url = baseurl + url;
      LogUtil.e('--header--');
      LogUtil.e(method + '请求url');
      LogUtil.e(url);
      LogUtil.e('请求参数');
      LogUtil.e(dataMap);
      LogUtil.e(dio.options.headers);
      if (method == 'get') {
        response = await dio.get(url, queryParameters: dataMap);
      } else if (method == 'post') {
        response = await dio.post(url, data: dataMap);
      } else if (method == 'put') {
        response = await dio.put(url, data: dataMap);
      } else if (method == 'upload') {
        FormData formData = FormData.fromMap(dataMap);
        response = await dio.post(url, data: formData);
      }
      EasyLoading.dismiss();
      LogUtil.e('请求返回值response--data--');
      LogUtil.e(response!.data);
      print(response.statusCode);
      if (response.statusCode != 200) {
        _msg = '网络请求错误,状态码:' + response.statusCode.toString();
        _handError(error!, _msg);
        return;
      }
      // 返回结果处理
      Map<String, dynamic> resCallbackMap = response.data;
      _code = resCallbackMap['code'];
      _msg = resCallbackMap['msg'];
      _backData = resCallbackMap['data'];

      //-100 重新登录
      if (_code.toInt() == -100) {
        await getBox.remove('token');

        NavKey.navKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const Login(),
            ),
            (route) => route == null);

        return;
      }
      if (_code.toInt() != 1) {
        showToast(_msg);
        return;
      }
      success(resCallbackMap);
    } catch (exception) {
      EasyLoading.dismiss();
      showToast('请求网络失败');
      LogUtil.e('-----请求出错了-----\n' + exception.toString());
    }
  }

  // 返回错误信息
  static Future? _handError(Function errorCallback, String errorMsg) {
    errorCallback(errorMsg);
  }

  ///下载
  static Future<String> downloadImage(url, localFile) async {
    Dio dio = Dio();
    String path = localFile;
    await dio.download(url, path);
    return path;
  }
}
