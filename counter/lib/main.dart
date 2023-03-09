import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:counter/add_photo.dart';
import 'package:counter/storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
  ],
);

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
  late Future<Position> _position;
  late Future<Stream<DocumentSnapshot>> _fbstream;
  GoogleSignInAccount? googleUser;

  File? _image;

  Future<UserCredential> signInWithGoogle() async {
    if (!widget.storage.isInitialized) {
      await widget.storage.initializeDefault();
    }
    // Trigger the authentication flow
    googleUser = await _googleSignIn.signIn();

    if (kDebugMode) {
      if (googleUser != null) {
        print(googleUser!.displayName);
      }
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> _handleSignOut() {
    FirebaseAuth.instance.signOut();
    return _googleSignIn.disconnect();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _position = _determinePosition();
    // _fbstream = widget.storage.getInstanceStream();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        googleUser = account;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (googleUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: getUnsignedBody(),
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _getImage,
        //   tooltip: 'Take Photo',
        //   child: const Icon(Icons.add_a_photo),
        // ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    } else {
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
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                onPressed: _handleSignOut,
                child: Icon(Icons.logout),
              ),
              const SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddPhoto(
                                title: "Add a Photo",
                              )));
                },
                tooltip: 'Add a Photo',
                child: const Icon(Icons.add_a_photo),
              ), // This trailing comma makes auto-formatting nicer for build methods.
            ],
          ));
    }
  }

  List<Widget> getBody() {
    List<Widget> widgets = [];
    widgets.add(StreamBuilder(
        stream: FirebaseFirestore.instance.collection("photos").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Text("Loading Photos");
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              return photoWidget(snapshot, index);
            },
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
          );
        }));
    return widgets;
  }

  Widget photoWidget(AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    try {
      return Column(
        children: [ListTile(title: Text(snapshot.data!.docs[index]["title"]))],
      );
    } catch (e) {
      return ListTile(title: Text(e.toString()));
    }
  }

  List<Widget> getUnsignedBody() {
    List<Widget> widgets = [];
    widgets.add(const Text("You are not currently signed in"));
    widgets.add(ElevatedButton(
        onPressed: signInWithGoogle, child: const Text("Sign In")));
    return widgets;
  }
}
