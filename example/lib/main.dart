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
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    'Cache Systems Demo',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        'https://fastly.picsum.photos/id/91/1500/1500.jpg?hmac=gFLcWG7TwMqsOm5ZizQJNJ2tYsENkSQdMMmNNp8Avvs',
                        height: 100,
                        width: 100,
                      ),
                    ),
                    FutureBuilder(
                      future: CacheSystem().getFile(
                        Uri.parse(
                          'https://fastly.picsum.photos/id/91/1500/1500.jpg?hmac=gFLcWG7TwMqsOm5ZizQJNJ2tYsENkSQdMMmNNp8Avvs',
                        ),
                        fileType: CacheFileType.image,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              File(snapshot.data!.path),
                              height: 100,
                              width: 100,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text('Cached Images'),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      if (file?.mimeType != null &&
                          file?.mimeType?.contains('image') == true) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            File(file!.path),
                            height: 100,
                            width: 100,
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey,
                            child: Text(
                              file?.mimeType ?? 'Unknown',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
