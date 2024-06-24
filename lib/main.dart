import 'package:flutter/material.dart';
import 'package:pmob/pages/mainpage.dart';
// Replace with the location of your splash screen widget

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Define your app's theme here
      ),
      home: SplashScreen(), // Show SplashScreen initially
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simulate a delay to show the splash screen for 2 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Mainpage()), // Replace with your main app screen widget
      );
    });

    return Scaffold(
      body: Center(
        child: Image(
          image: NetworkImage('https://i.ibb.co.com/S5R8Dc0/splash.png"'),
          fit: BoxFit.fill, // Adjust fit as needed
        ), // Replace with your splash screen image asset
      ),
    );
  }
}
