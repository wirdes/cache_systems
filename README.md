# Cache Systems
[![Pub Version](https://img.shields.io/pub/v/cache_systems)](https://pub.dev/packages/cache_systems)

This package for flutter is used to cache files in the device. It can be used to cache images, videos, audios, text and other files. It can also be used to cache files from the internet.
<br>
# 🛠 Getting Started


## Initial Configurations

Add the `cache_systems` plugin to your project's `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cache_systems: ^[version] # <~ always ensure to use the latest version
```

After adding the dependency, run the following command to get the package:

```bash
flutter pub get
```

# 📝 Usage

### Cache files from the internet

Firstly initialize the cache system by calling `CacheSystem().init()` in the `main()` function. This will initialize the cache system with default values. You can also pass the `stalePeriod` parameter to the `init()` function to set the stale period for the cache system. The stale period is the time after which the cache will be considered stale and will be deleted. The default value for stale period is 7 days.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheSystem().init(stalePeriod: const Duration(days: 7));
  runApp(const MyApp());
}
```

To cache files from the internet, use the `CacheSystem().get()` function. This function takes the url of the file to be cached as the parameter. Url type must Uri. It returns a `Future` which will return a `CacheFile` object.

```dart
class CacheFile {
  @HiveField(0)
  String path;
  @HiveField(1)
  DateTime? expiration;
  @HiveField(2)
  String fileType;
  CacheFile(
    this.path,
    this.fileType, {
    this.expiration,
  });

  File get file => File(path);
}
```

`CacheFile` object contains the path of the cached file, the expiration date of the file and the type of the file. The `file` property of the `CacheFile` object returns the `File` object of the cached file.

```dart
  final String url = Uri.parse('https://fastly.picsum.photos/id/91/1500/1500.jpg?hmac=gFLcWG7TwMqsOm5ZizQJNJ2tYsENkSQdMMmNNp8Avvs');
  final CacheFile? cachedfile = await CacheSystem().get(url);
  if (cachedfile != null) {
    print(cachedfile.file.path);
  }
```

or if your file is an image and you want to render it in the UI, you can use the FutureBuilder widget to render the image.

```dart
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
    );
```

or you can use the `CachedImage` widget to render the image. The `CachedImage` widget takes the url of the image as the parameter and returns an `Image` widget.

```dart
    CachedImage(url: imgUri)
```

If you want get all the cached files, you can use the `CacheSystem().getAllFiles()` function. This function returns a `Future` which will return a list of `CacheFile` objects.

```dart
  final List<CacheFile?> files = await CacheSystem().getAllFiles();
  for (final file in files) {
    print(file!.file.path);
  }
```

# ⚡️ Web Support (Service Worker)

To use the cache system in the web, you need to add a service worker to your web project. You can add a service worker by creating a `web` folder in your project and adding a `service_worker.js` file to the `web` folder. The `service_worker.js` file should contain the following code.

```javascript
const BASE_URL = "https://fastly.picsum.photos"; //the url of the files you want to cache

const cacheName = "file-cache-v3.1"; // Change the cache name to update the cache

self.addEventListener("install", (event) => {
  self.skipWaiting();
  event.waitUntil(caches.open(cacheName));
});

self.addEventListener("activate", (event) => {
  console.log("Activating Cache service worker");
});

self.addEventListener("fetch", (event) => {
  if (event.request.url.includes(BASE_URL)) {
    event.respondWith(
      caches
        .match(event.request)
        .then((response) => {
          if (response) {
            return response;
          }

          return fetch(event.request).then((response) => {
            return caches.open(cacheName).then((cache) => {
              cache.put(event.request.url, response.clone());
              return response;
            });
          });
        })
        .catch(async (error) => {
          console.log("Error fetching from cache", error);
        })
    );
  }
});
```

After adding the `service_worker.js` file, you need to add the service worker to the `index.html` file of your web project. Add the following code to the `index.html` file.

```html
<!DOCTYPE html>
<html>
  <head>
    <base href="$FLUTTER_BASE_HREF" />
    <meta charset="UTF-8" />
    <meta content="IE=Edge" http-equiv="X-UA-Compatible" />
    <meta name="description" content="A new Flutter project." />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black" />
    <meta name="apple-mobile-web-app-title" content="example" />
    <link rel="apple-touch-icon" href="icons/Icon-192.png" />
    <link rel="icon" type="image/png" href="favicon.png" />
    <title>example</title>
    <link rel="manifest" href="manifest.json" />
    <--- Add the following code to add the service worker --->
    <script>
      if ("serviceWorker" in navigator) {
        window.addEventListener("load", () => {
          navigator.serviceWorker
            .register("/service-worker.js")
            .then((registration) => {
              console.log("Service Worker :", registration);
            })
            .catch((error) => {
              console.log("Service Worker has Error:", error);
            });
        });
      }
    </script>
    <--- End of service worker code --->
  </head>
  <body>
    <script src="flutter_bootstrap.js" async=""></script>
    <script src="main.dart.js" type="application/javascript"></script>
  </body>
</html>
```
