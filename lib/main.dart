import 'dart:io';

import 'package:flutapp/my_audio_page.dart';
import 'package:flutapp/my_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}

final _router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const MyHomePage(),
  ),
  GoRoute(
    path: '/audio',
    builder: (context, state) {
      // final url = state.pathParameters['url'];
      Map<String, dynamic> myMap = state.extra as Map<String, dynamic>;
      return MyAudioPage(
        url: myMap['url'],
      );
    },
  ),
]);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const audioPickerChannel = MethodChannel("audioPickerPlatform");
  var myList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                try {
                  myList.clear();
                  final String result =
                      await audioPickerChannel.invokeMethod('pickAudio');
                  debugPrint("Flutter Result " + result);
                  String cleanString =
                      result.replaceAll('[', '').replaceAll(']', '').trim();
                  List<String> stringList = cleanString.split(',');

                  setState(() {
                    myList = Platform.isAndroid
                        ? stringList.toList()
                        : stringList.map((e) => e.replaceAll('"', '')).toList();
                  });
                } on PlatformException catch (e) {
                  debugPrint("Fail: '${e.message}'.");
                }
              },
              child: const Text("Get all audios"),
            ),
            myList.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var firstData = myList[index].split("@@");

                      return InkWell(
                        onTap: () async {
                          if (Platform.isAndroid) {
                            context
                                .push("/audio", extra: {'url': firstData[1]});
                          } else {
                            debugPrint(
                                "Value is" + firstData[1].toString().trim());
                            await audioPickerChannel.invokeMethod('playAudio',
                                {"identifier": firstData[0].toString().trim()});
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: MyImageView(
                                  imageUrl: firstData[0].toString().trim(),
                                ),
                              ),
                              Text(
                                firstData[2],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: myList.length,
                  ))
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}

//image@@audiouri@@title