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
    return const MaterialApp(
      title: 'Cache Systems Demo',
      home: MyHomePage(title: 'Cache Systems Demo'),
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
  List<CacheFile?> files = [];

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
    final imgUri = Uri.parse(
      'https://fastly.picsum.photos/id/91/1500/1500.jpg?hmac=gFLcWG7TwMqsOm5ZizQJNJ2tYsENkSQdMMmNNp8Avvs',
    );
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // For Image
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<CacheFile?>(
                      future: CacheSystem().get(
                        imgUri,
                        fileType: CacheFileType.image,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              snapshot.data!.file,
                              height: 100,
                              width: 100,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    // or use the CachedImage widget
                    CachedImage(url: imgUri, height: 100, width: 100),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final cachefile = files[index];
                      if (cachefile!.fileType != 'image/*') {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(
                          cachefile.file,
                          height: 100,
                          width: 100,
                        ),
                      );
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
