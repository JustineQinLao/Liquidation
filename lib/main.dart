import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquidapp/Databases/db_connection.dart';
import 'package:liquidapp/Pages/home_page.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
Future<void> main() async {
   // before the runApp() call
  WidgetsFlutterBinding.ensureInitialized();
  
  
  // Than we setup preferred orientations,
  // and only after it finished we run our app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));

  

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tagalogers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
