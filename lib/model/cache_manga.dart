import 'package:flutter/material.dart';

class CacheManga {

  int id;
  int chapter;
  String mangaName;

  CacheManga({@required mangaName, @required this.chapter});

  CacheManga.fromData(id, mangaName, chapter) {
    this.id = id;
    this.chapter = chapter;
    this.mangaName = mangaName;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mangaName': mangaName,
      'chapter': chapter,
    };
  }
}