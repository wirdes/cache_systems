import 'dart:io';

import 'package:cache_systems/cache_systems.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheSystem().init(stalePeriod: const Duration(days: 7));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cache Systems Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Cache Systems Demo'),
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
  List<XFile?> files = [];

  @override
  void initState() {
    CacheSystem().getAllFile().then((value) {
      setState(() {
        files = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              'Cache Systems Demo',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Image.network(
            'https://fastly.picsum.photos/id/91/1500/1500.jpg?hmac=gFLcWG7TwMqsOm5ZizQJNJ2tYsENkSQdMMmNNp8Avvs',
            width: 200,
            height: 300,
          ),
          FutureBuilder(
            future: CacheSystem().getFile(Uri.parse(
                'https://fastly.picsum.photos/id/91/1500/1500.jpg?hmac=gFLcWG7TwMqsOm5ZizQJNJ2tYsENkSQdMMmNNp8Avvs')),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.file(
                  File(snapshot.data!.path),
                  width: 200,
                  height: 300,
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
