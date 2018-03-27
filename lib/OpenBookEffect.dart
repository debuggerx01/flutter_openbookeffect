import 'dart:math' show min;

import 'package:flutter/material.dart';

class OpenBookEffect {

  ///给定context和控件的rect,返回控件中心到屏幕中心的偏移
  static Offset getOffsetFromCentrePoint(BuildContext context, Rect rect) {
    var size = MediaQuery
        .of(context)
        .size;
    return new Offset(size.width / 2 - rect.left - rect.width / 2,
        size.height / 2 - rect.top - rect.height / 2);
  }

  static Rect getRectOfRectWithMoveToCenterAndScaled(BuildContext context,
      Rect rect, double scaleKey) {
    var size = MediaQuery
        .of(context)
        .size;
    return new Rect.fromLTWH(
        size.width / 2 - rect.width * (1 + scaleKey) / 2,
        size.height / 2 - rect.height * (1 + scaleKey) / 2,
        rect.width * (1 + scaleKey),
        rect.height * (1 + scaleKey));
  }

  static RectScaleRadio getMaxScaleRadio(BuildContext context, Rect rect) {
    var size = MediaQuery
        .of(context)
        .size;
    return new RectScaleRadio(
        size.width / rect.width - 1, size.height / rect.height - 1);
  }
}

class RectScaleRadio {
  double minRadio;
  double w;
  double h;

  RectScaleRadio(this.w, this.h) :
        minRadio = min(w, h);
}
