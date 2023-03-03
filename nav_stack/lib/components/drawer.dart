import 'package:flutter/material.dart';
import 'package:nav_stack/first.dart';
import 'package:nav_stack/second.dart';

Widget getDrawer(context) {
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
          ),
          child: Text('Drawer Header'),
        ),
        ListTile(
          title: const Text('Page 1'),
          onTap: () {
            // Update the state of the app.
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const FirstRoute()),
                (route) => false);
          },
        ),
        ListTile(
          title: const Text('Page 2'),
          onTap: () {
            // Update the state of the app.
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SecondRoute()),
                (route) => false);
          },
        ),
        ListTile(
          title: const Text('Apply Filter'),
          onTap: () {
            // Update the state of the app.
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
