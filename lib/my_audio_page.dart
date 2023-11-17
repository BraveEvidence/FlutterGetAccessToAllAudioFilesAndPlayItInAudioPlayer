import 'package:flutapp/my_audio_view.dart';
import 'package:flutter/material.dart';

class MyAudioPage extends StatelessWidget {
  const MyAudioPage({required this.url, super.key});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: MyAudioView(audioUrl: url)),
    );
  }
}
