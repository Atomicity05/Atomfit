
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'dart:convert';

class SimpleScreen1 extends StatefulWidget {
  const SimpleScreen1({Key? key}) : super(key: key);

  @override
  State<SimpleScreen1> createState() => _SimpleScreen1State();
}

class _SimpleScreen1State extends State<SimpleScreen1> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  UnityWidgetController? _unityWidgetController;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unityWidgetController?.dispose();
    super.dispose();
  }

  void onUnityCreated(UnityWidgetController controller) {
    _unityWidgetController = controller;
  }

  void sendMessageToUnity() {
    /*final message = {
      'name': 'rotateObject',
      'data': '1',
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    final messageJson = jsonEncode(message);
    */
    int valueToSend = 1;
/*
    _unityWidgetController?.postMessage(
      'UnityMessageManager',
      'onFlutterMessage',
      messageJson,
    );*/
    
    _unityWidgetController?.postMessage(
    'UnityMessageManager',
    'onMessage',
    valueToSend.toString(),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Simple Screen'),
      ),
      body: Card(
        margin: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: UnityWidget(
                onUnityCreated: onUnityCreated,
              ),
            ),
            ElevatedButton(
              onPressed: sendMessageToUnity,
              child: const Text('Send Message to Unity'),
            ),
          ],
        ),
      ),
    );
  }
}
