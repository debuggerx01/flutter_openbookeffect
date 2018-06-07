import 'package:flutter/material.dart';
import 'package:flutter_openbookeffect/newPage.dart';

class SV {
  static Image parchmentImage = new Image.asset(
    'images/parchment.png',
    fit: BoxFit.cover,
  );

  ///该缩放比例将应用于原始尺寸到fit尺寸之间的百分比
  static final double openBookScaleRadioKey = 0.6;

  static GlobalKey<NewPageState> newPageKey = new GlobalKey();

  static NewPage secPage = new NewPage(newPageKey);

  static int index;
}
