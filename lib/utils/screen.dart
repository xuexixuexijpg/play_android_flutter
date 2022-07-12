import 'dart:collection';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../main.dart';

//https://juejin.cn/post/7078816723666731021

//假定375px
const double screenWidthDesign = 375;

void runMyApp(Widget app) {
  MyWidgetsFlutterBinding.ensureInitialized()
    ..scheduleAttachRootWidget(app)
    ..scheduleWarmUpFrame();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      builder: useScreenAuto ? (context, widget) {
        return MediaQuery(
            data: MediaQuery.of(context).copyWith(
                size: Size(
                    screenWidthDesign,
                    window.physicalSize.height /
                        (window.physicalSize.width / screenWidthDesign)),
                devicePixelRatio: window.physicalSize.width / screenWidthDesign),
            child: widget!);
      } : null,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    color: Colors.yellow,
                    child: const Text('1/3屏宽'),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    color: Colors.green,
                    child: const Text('1/3屏宽'),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    color: Colors.blue,
                    child: const Text('1/3屏宽'),
                  ),
                )
              ],
            ),
            Container(
              height: 50,
              width: 125,
              alignment: Alignment.center,
              color: Colors.pink,
              child: const Text('125宽度'),
            ),
            Container(
              height: 50,
              width: 375,
              alignment: Alignment.center,
              color: Colors.orange,
              child: const Text('375宽度'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

/// 一个自定义的 WidgetsFlutterBinding 子类
class MyWidgetsFlutterBinding extends WidgetsFlutterBinding {
  final Queue<PointerEvent> _pendingPointerEvents = Queue<PointerEvent>();

  static MyWidgetsFlutterBinding ensureInitialized() {
    MyWidgetsFlutterBinding();
    return WidgetsBinding.instance as MyWidgetsFlutterBinding;
  }

  @override
  void scheduleAttachRootWidget(Widget rootWidget) {
    super.scheduleAttachRootWidget(rootWidget);
  }

  @override
  void initInstances() {
    super.initInstances();
    window.onPointerDataPacket = _handlePointerDataPacket;
  }


  // @override
  // ViewConfiguration createViewConfiguration() {
  //   return ViewConfiguration(
  //     size: Size(
  //         screenWidthDesign, window.physicalSize.height / (window.physicalSize.width / screenWidthDesign)),
  //     devicePixelRatio: window.physicalSize.width / screenWidthDesign,
  //   );
  // }

  void _handlePointerDataPacket(PointerDataPacket packet) {
    // We convert pointer data to logical pixels so that e.g. the touch slop can be
    // defined in a device-independent manner.
    _pendingPointerEvents.addAll(PointerEventConverter.expand(
        packet.data, window.physicalSize.width / screenWidthDesign));
    if (!locked) _flushPointerEventQueue();
  }

  void _flushPointerEventQueue() {
    assert(!locked);

    while (_pendingPointerEvents.isNotEmpty) {
      handlePointerEvent(_pendingPointerEvents.removeFirst());
    }
  }
}