import 'package:flutter/material.dart';

///需要实时获得某个Widget的Rect信息时使用该控件
///可选传GlobalKey和无参两种构造方式，之后利用对象本身或者构造传入的key以获取信息

class RectGetter extends StatefulWidget {
  final GlobalKey<_RectGetterState> key;
  final Widget child;

  ///持有某RectGetter对象的key时利用该方法获得其child的rect
  static Rect getRectFromKey(GlobalKey<_RectGetterState> globalKey) {
    var object = globalKey?.currentContext?.findRenderObject();
    var translation = object?.getTransformTo(null)?.getTranslation();
    var size = object?.semanticBounds?.size;

    if (translation != null && size != null) {
      return new Rect.fromLTWH(
          translation.x, translation.y, size.width, size.height);
    } else {
      return null;
    }
  }

  ///传GlobalKey构造，之后可以RectGetter.getRectFromKey(key)的方式获得Rect
  RectGetter({this.key, this.child}) : super(key: key);

  ///生成默认GlobalKey的命名无参构造，调用对象的getRect方法获得Rect
  factory RectGetter.defaultKey({Widget child}) {
    return new RectGetter(
      key: new GlobalKey(),
      child: child,
    );
  }

  ///持有RectGetter对象时使用该方法获得其child的Rect
  Rect getRect() {
    return getRectFromKey(this.key);
  }

  @override
  _RectGetterState createState() => new _RectGetterState();
}

class _RectGetterState extends State<RectGetter> {
  @override
  Widget build(BuildContext context) => widget.child;
}
