import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:counter/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  if (kIsWeb) {
    runApp(const MyApp(title: "Web"));
  } else if (Platform.isAndroid) {
    runApp(const MyApp(title: "Android"));
  } else if (Platform.isIOS) {
    runApp(const MyApp(title: "iOS"));
  }

  // runApp(const MyApp(title: "default"));
}

class MyApp extends StatelessWidget {
  final String title;
  const MyApp({super.key, required this.title});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(
        title: 'Flutter Demo $title',
        storage: CounterStorage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.storage});

  final String title;
  final CounterStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<int> _counter;
  late Future<Position> _position;
  File? _image;

  Future<void> _incrementCounter() async {
    int count = await widget.storage.readCounter();
    if (count <= 10) {
      count += 1;
    }
    await widget.storage.writeCounter(count);
    setState(() {
      _counter = widget.storage.readCounter();
    });
  }

  Future<void> _decrementCounter() async {
    int count = await widget.storage.readCounter();
    if (count > 0) {
      count -= 1;
    }
    await widget.storage.writeCounter(count);
    setState(() {
      _counter = widget.storage.readCounter();
    });
  }

  void getCounter() async {
    if (!widget.storage.isInitialized) {
      await widget.storage.initializeDefault();
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _counter = widget.storage.readCounter();
    _position = _determinePosition();
    getCounter();
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (kDebugMode) {
        print(position == null
            ? 'Unknown'
            : '${position.latitude.toString()}, ${position.longitude.toString()}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: getBody(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'Take Photo',
        child: const Icon(Icons.add_a_photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _getImage() async {
    final ImagePicker _picker = ImagePicker();
    // Capture a photo
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      } else {
        if (kDebugMode) {
          print("No image picked");
        }
      }
    });
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  List<Widget> getBody() {
    return <Widget>[
      Container(
          margin: const EdgeInsets.all(10.0),
          width: 200,
          height: 200,
          color: Colors.white,
          child: _image == null
              ? Placeholder(
                  child: Image.network(
                      "https://t3.ftcdn.net/jpg/02/48/42/64/360_F_248426448_NVKLywWqArG2ADUxDq6QprtIzsF82dMF.jpg"))
              : Image.file(_image!)),
      FutureBuilder(
          future: _position,
          builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
              default:
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                return Text(
                    '${snapshot.data!.latitude}, ${snapshot.data!.longitude}, ${snapshot.data!.accuracy}');
            }
          }),
      const Text(
        'You pushed my button this many times:',
      ),
      widget.storage.isInitialized
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("example")
                  .doc("cins467")
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error.toString()}");
                } else {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  if (kDebugMode) {
                    print(snapshot.data);
                  }
                  return Text(
                    snapshot.data!["count"].toString(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                }
              })
          : const CircularProgressIndicator(),
      FutureBuilder<int>(
          future: _counter, // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              return Text(
                '${snapshot.data}',
                style: Theme.of(context).textTheme.headlineMedium,
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          }),
      Row(
        children: [
          ElevatedButton(
              onPressed: _incrementCounter, child: const Icon(Icons.add)),
          IconButton(
              icon: const Icon(Icons.remove),
              tooltip: 'Decrement counter by one',
              onPressed: _decrementCounter),
        ],
      )
    ];
  }
}
