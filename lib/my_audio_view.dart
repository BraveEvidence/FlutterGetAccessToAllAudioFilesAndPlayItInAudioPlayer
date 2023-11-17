import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const myAudioView = 'myAudioView';

class MyAudioView extends StatefulWidget {
  const MyAudioView({required this.audioUrl, super.key});

  final String audioUrl;

  @override
  State<MyAudioView> createState() => _MyAudioViewState();
}

class _MyAudioViewState extends State<MyAudioView> {
  final Map<String, dynamic> creationParams = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    creationParams["audioUrl"] = widget.audioUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? AndroidView(
            viewType: myAudioView,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          )
        : UiKitView(
            viewType: myAudioView,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          );
  }
}
