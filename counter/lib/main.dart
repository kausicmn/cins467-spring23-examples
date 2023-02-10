import 'package:counter/storage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        title: 'Flutter Demo Home Page',
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _counter = widget.storage.readCounter();
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
          children: <Widget>[
            const Text(
              'You pushed my button this many times:',
            ),
            FutureBuilder<int>(
                future:
                    _counter, // a previously-obtained Future<String> or null
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
