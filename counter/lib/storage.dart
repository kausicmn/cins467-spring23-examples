import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:counter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class CounterStorage {
  bool _initialized = false;

  CounterStorage();

  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
    if (kDebugMode) {
      print('Initialized default app $app');
    }
  }

  bool get isInitialized => _initialized;

  Future<bool> writeCounter(int counter) async {
    if (!isInitialized) {
      await initializeDefault();
    }
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection("example").doc("cins467").set({
      'count': counter,
    }).then((value) {
      if (kDebugMode) {
        print("Count added");
      }
      return true;
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      return false;
    });
    return false;
  }

  Future<int> readCounter() async {
    if (!isInitialized) {
      await initializeDefault();
    }
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot ds =
        await firestore.collection("example").doc("cins467").get();
    if (ds.data() != null) {
      Map<String, dynamic> data = (ds.data() as Map<String, dynamic>);
      if (data.containsKey("count")) {
        return data["count"];
      }
    }
    bool writeSuccess = await writeCounter(0);
    if (writeSuccess) {
      return 0;
    }
    return -1;
  }
}
