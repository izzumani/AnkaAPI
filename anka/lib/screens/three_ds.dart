import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewx/webviewx.dart' as WVX;

class ThreeDS extends StatefulWidget {
  final String url;

  const ThreeDS({Key key, this.url}) : super(key: key);

  @override
  _ThreeDSState createState() => _ThreeDSState();
}

class _ThreeDSState extends State<ThreeDS> {
  WVX.WebViewXController webviewController;

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: 1.0,
      heightFactor: 1.0,
      child:
        SingleChildScrollView(
          child: Container(
            height: 600.0,
            width: 400.0,
            color: Colors.purple[50],
            child:
                Padding(
                  padding: EdgeInsets.all(1.0),
                  child:
                  (!kIsWeb && Platform.isIOS) ? WebView(
                    initialUrl: widget.url,
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageStarted: (String url) {
                     if (url.contains('anka')) {
                        Navigator.popAndPushNamed(context, '/completed', arguments: url);
                     }
                    },
                    gestureNavigationEnabled: true,
                  ) :
                  WVX.WebViewX(
                    initialSourceType: WVX.SourceType.URL,
                    onWebViewCreated: (controller) {
                      webviewController = controller;
                      webviewController.loadContent(widget.url, WVX.SourceType.URL);
                    },
                    javascriptMode: WVX.JavascriptMode.unrestricted,
                  ),
                ),
          ),
        ),
    );
  }
}