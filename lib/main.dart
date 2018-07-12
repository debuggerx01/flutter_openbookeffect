import 'dart:math';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/material.dart';
import 'package:flutter_openbookeffect/OpenBookEffect.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:flutter_openbookeffect/SV.dart';
import 'package:flutter_openbookeffect/newPage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool canTouch = true;

  bool slowAnimation = false;

  @override
  Widget build(BuildContext context) {
    final parchmentCard = new Card(
      child: new SizedBox.expand(
        child: SV.parchmentImage,
      ),
    );

    AnimationController openAniController = new AnimationController(
        duration: new Duration(milliseconds: 300), lowerBound: 0.0, upperBound: 1.0, vsync: this);

    AnimationController fillAniController = new AnimationController(
        duration: new Duration(milliseconds: 100), lowerBound: 0.0, upperBound: 1.0, vsync: this);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new CustomScrollView(
        primary: false,
        slivers: <Widget>[
          new SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: new SliverGrid.count(
              crossAxisSpacing: 10.0,
              crossAxisCount: 3,
              children:
                  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24].map((i) {
                RectGetter bookCard = new RectGetter.defaultKey(
                  child: new Card(
                    child: new SizedBox.expand(
                      child: new Container(
                        color: Colors.primaries[i % 18],
                        child: new Center(
                          child: new Text('$i'),
                        ),
                      ),
                    ),
                  ),
                );

                return new GestureDetector(
                  onTap: () {
                    if (!canTouch) {
                      return;
                    }

                    //进入打开页面逻辑后设置不能再响应其他点击,避免快速点击造成的冲突
                    canTouch = false;

                    var rect = bookCard.getRect();

                    var openAnime = new OverlayEntry(
                      builder: (BuildContext context) => new Positioned.fromRect(
                            rect: rect,
                            child: new AnimatedBuilder(
                              animation: openAniController,
                              builder: (BuildContext context, Widget child) {
                                var offset = OpenBookEffect.getOffsetFromCentrePoint(context, rect);
                                offset *= openAniController.value;

                                double scaleRatio = openAniController.value *
                                    SV.openBookScaleRadioKey *
                                    OpenBookEffect.getMaxScaleRadio(context, rect).minRadio;

                                var translateMatrix4 = new Matrix4.identity()..translate(offset.dx, offset.dy);

                                var scaleMatrix4 = new Matrix4.identity()..scale(1 + scaleRatio);

                                var flipMatrix4 = MatrixUtils.createCylindricalProjectionTransform(
                                    radius: 0.0,

                                    ///翻转90°
                                    angle: -openAniController.value * pi / 2,
                                    orientation: Axis.horizontal)
                                  ..translate(offset.dx, offset.dy);

                                return new Stack(
                                  children: <Widget>[
                                    new Transform(
                                      transform: translateMatrix4,
                                      child: new Transform(
                                        origin: new Offset(rect.width / 2, rect.height / 2),
                                        transform: scaleMatrix4,
                                        child: parchmentCard,
                                      ),
                                    ),
                                    new Transform(
                                      origin: new Offset(
                                          offset.dx - (rect.width * scaleRatio / 2), offset.dy + rect.height / 2),
                                      transform: flipMatrix4,
                                      child: new Transform(
                                        origin: new Offset(rect.width / 2, rect.height / 2),
                                        transform: scaleMatrix4,
                                        child: bookCard.clone(),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                    );

                    Rect fillRect = OpenBookEffect.getRectOfRectWithMoveToCenterAndScaled(context, rect,
                        SV.openBookScaleRadioKey * OpenBookEffect.getMaxScaleRadio(context, rect).minRadio);

                    var scaleRadio = OpenBookEffect.getMaxScaleRadio(context, fillRect);

                    var fillAnime = new OverlayEntry(
                      builder: (BuildContext context) => new Positioned.fromRect(
                            rect: fillRect,
                            child: new AnimatedBuilder(
                              animation: fillAniController,
                              builder: (BuildContext context, Widget child) {
                                var fillMatrix4 = new Matrix4.identity()
                                  ..scale(1 + scaleRadio.w * fillAniController.value,
                                      1 + scaleRadio.h * fillAniController.value);

                                return new Transform(
                                  origin: new Offset(fillRect.width / 2, fillRect.height / 2),
                                  transform: fillMatrix4,
                                  child: parchmentCard,
                                );
                              },
                            ),
                          ),
                    );

                    //先将开页动画添加至覆盖层
                    Overlay.of(context).insert(openAnime);
                    openAniController.forward().whenComplete(() {
                      //开页动画播放完成时,将填充动画添加到覆盖层,并移除开页动画
                      openAnime.remove();
                      Overlay.of(context).insert(fillAnime);
                      fillAniController.forward().whenComplete(() {
                        SV.index = i;

                        //播放填充动画,完成时导航至阅读器页面
                        Navigator.of(context).push(new PageRouteBuilder(pageBuilder:
                            (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                          //直接返回页面即可避免播放默认路由动画
                          return SV.secPage;
                        }))
                          ..whenComplete(() {
                            //本次路由导航完成时,也就是从阅读页面退出时,先将填充动画添加到覆盖层
                            Overlay.of(context).insert(fillAnime);
                            //然后通知阅读页面将自身隐藏
                            SV.newPageKey.currentState.hide(true);
                            //反向播放填充动画成为缩放效果
                            fillAniController.reverse().whenComplete(() {
                              //反向填充动画播放完成时,将开页动画添加到覆盖层,并移除填充动画
                              fillAnime.remove();
                              Overlay.of(context).insert(openAnime);
                              openAniController.reverse().whenComplete(() {
                                //反向播放开页动画成为合页效果,完成时移除开页动画,并设置可以响应点击flag
                                openAnime.remove();
                                canTouch = true;
                              });
                            });
                          }).timeout(new Duration(milliseconds: 100), onTimeout: fillAnime.remove);
                      });
                    });
                  },
                  child: bookCard,
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          slowAnimation = !slowAnimation;
          timeDilation = slowAnimation ? 5.0 : 1.0;
        },
        child: new Icon(Icons.add),
      ),
    );
  }
}
