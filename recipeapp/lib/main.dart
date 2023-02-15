import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App Demo',
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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Recipe App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<dynamic>> recipes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recipes = getRecipes();
    //fetch our recipes
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder<List>(
        future: recipes,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            default:
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          Uri url = Uri.parse(snapshot.data![index]["url"]);
                          _launchUrl(url);
                        },
                        child: Card(
                            child: Column(children: [
                          ListTile(title: Text(snapshot.data![index]["title"])),
                          Image.network(snapshot.data![index]["photo_url"]),
                        ])));
                  },
                );
              }
              return const Text("Shouldn't get here");
          }
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      if (kDebugMode) {
        print("Could not launch $url");
      }
    }
  }

  Future<List> getRecipes() async {
    var url = Uri.https('rest.bryancdixon.com');

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = convert.jsonDecode(response.body);
      if (kDebugMode) {
        print(jsonResponse["recipes"][0]);
      }
      return jsonResponse["recipes"];
    } else {
      if (kDebugMode) {
        print('Request failed with status: ${response.statusCode}.');
      }
    }
    return List.empty();
  }
}
