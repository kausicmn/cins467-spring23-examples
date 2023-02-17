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
    try {
      if (!isInitialized) {
        await initializeDefault();
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
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
    }
    bool writeSuccess = await writeCounter(0);
    if (writeSuccess) {
      return 0;
    }
    return -1;
  }
}
