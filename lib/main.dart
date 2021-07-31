import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pokemon_special_app/database/pokemon_manga_db.dart';
import 'package:pokemon_special_app/read_manga/read_manga_screen.dart';
import 'package:pokemon_special_app/widget/initial_bloc_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PokemonMangaDatabase.instance.init();
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Pokemon Special Manga',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: InitialBlocProvider(child: ReadMangaScreen())
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
