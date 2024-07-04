# cache_system

This package for flutter is used to cache files in the device. It can be used to cache images, videos, audios, text and other files. It can also be used to cache files from the internet.
<br>
[![Pub Version](https://img.shields.io/pub/v/cache_systems)](https://pub.dev/packages/cache_systems)

## Platform Support

| macOS | Windows | Linux | Web | Android | iOS |
| :---: | :-----: | :---: | :-: | :-----: | :-: |
|  ✅   |   ✅    |  ✅   | ❌  |   ✅    | ✅  |

# Install

- Add `cache_systems` to your dependencies list in `pubspec.yaml` file

```yaml
dependencies:
  flutter:
    sdk: flutter
  cache_systems: ^0.0.3
```

- Run `flutter packages get` from your root project

- import the package by `import 'package:cache_systems/cache_systems.dart';`

## Usage

### Cache files from the internet

Firstly initialize the cache system by calling `CacheSystem().init()` in the `main()` function. This will initialize the cache system with default values. You can also pass the `stalePeriod` parameter to the `init()` function to set the stale period for the cache system. The stale period is the time after which the cache will be considered stale and will be deleted. The default value for stale period is 7 days.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheSystem().init(stalePeriod: const Duration(days: 7));
  runApp(const MyApp());
}
```

To cache files from the internet, use the `CacheSystem().getFile()` function. This function takes the url of the file to be cached as the parameter. Url type must Uri. It returns a `Future` which will return the path of the cached file. The cached file will be deleted after the stale period.

```dart
Future<File?> cacheFile() async {
  final String url = 'https://www.example.com/image.png';
  final File? file = CacheSystem().getFile(Uri.parse(
                'https://fastly.picsum.photos/id/91/1500/1500.jpg?hmac=gFLcWG7TwMqsOm5ZizQJNJ2tYsENkSQdMMmNNp8Avvs'));
    return file;
}
```

or if your file is an image and you want to render it in the UI, you can use the FutureBuilder widget to render the image.

```dart
FutureBuilder(
      future: CacheSystem().getFile(Uri.parse(
          'https://fastly.picsum.photos/id/91/1500/1500.jpg?hmac=gFLcWG7TwMqsOm5ZizQJNJ2tYsENkSQdMMmNNp8Avvs')),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.file(snapshot.data!);
        }
        return const SizedBox();
      },
    );
```

If you want get all the cached files, you can use the `CacheSystem().getAllFiles()` function. This function returns a `Future` which will return a list of all the cached files.

```dart
Future<List<File?>> getAllFiles() async {
  final List<File> files = await CacheSystem().getAllFiles();
  return files;
}
```

or if you want to render all the cached file in the UI, you can use like this.

```dart
GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(
              file!,
              height: 100,
              width: 100,
            ),
          );
      },
    );
```
