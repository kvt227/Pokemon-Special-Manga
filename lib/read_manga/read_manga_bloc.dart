import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:pokemon_special_app/model/image_manga.dart';

part 'read_manga_event.dart';
part 'read_manga_state.dart';

class ReadMangaBloc extends Bloc<ReadMangaEvent, ReadMangaState> {
  ReadMangaBloc() : super(ReadMangaInitial());

  List<ImgManga> listImg = <ImgManga>[];
  final templateUrl = 'https://www.pokemonspecial.com/2014/06/chapter-';
  int chapter = 4;

  @override
  Stream<ReadMangaState> mapEventToState(
    ReadMangaEvent event,
  ) async* {

    if (event is ReadMangaFetchData) {
      yield* _mapReadMangaFetchData(event);
    } else if (event is ReadMangaStarted) {
      yield* _mapStartedToState(event);
    } else if (event is ReadMangaNextChapter) {
      yield* _mapReadMangNextChapter(event);
    } else if (event is ReadMangaPreviousChapter) {
      yield* _mapReadMangaPreviousChapter(event);
    }
  }

  Stream<ReadMangaState> _mapStartedToState(
    ReadMangaStarted event,
  ) async* {
    yield ReadMangaDataLoaded();
  }

  Stream<ReadMangaState> _mapReadMangaFetchData(
    ReadMangaFetchData event,
  ) async* {

    if (event.isLoading) {
      yield ReadMangaDataLoading();
    }

    try {
      await getImage();
      yield ReadMangaDataFetched();
    } catch (ex) {
      yield ReadMangaDataFailed(ex: ex);
    }
  }

  Stream<ReadMangaState> _mapReadMangNextChapter(
      ReadMangaNextChapter event,
      ) async* {

    try {
      chapter++;
      await getImage();
      yield ReadMangaDataFetched();
    } catch (ex) {
      yield ReadMangaDataFailed(ex: ex);
    }
  }

  Stream<ReadMangaState> _mapReadMangaPreviousChapter(
      ReadMangaPreviousChapter event,
      ) async* {

    try {
      chapter--;

      if (chapter < 1) {
        chapter = 1;
      }

      await getImage();
      yield ReadMangaDataFetched();
    } catch (ex) {
      yield ReadMangaDataFailed(ex: ex);
    }
  }

  Future<void> getImage () async {
    final client = Client();

    try {
      listImg.clear();
      String url = templateUrl + chapter.toString().padLeft(3, '0') + '.html';
      if (chapter == 1) {
        url = 'https://www.pokemonspecial.com/2013/12/chapter-001.html';
      }
      final response = await client.get(Uri.parse(url));

      final utf8Body = utf8.decode(response.bodyBytes);
      final document = parse(utf8Body);
      final trs = document.querySelectorAll('img');

      for (final tr in trs) {
        try {
          String url = tr.attributes['src'];
          var urlSplit = url.split('/');
          String fileName = urlSplit[urlSplit.length - 1];
          if (int.tryParse(fileName.split('.')[0]) != null) {
            listImg.add(ImgManga(url: tr.attributes['src']));
          }
        } catch (e) {}
      }
      print('Count image: ${listImg.length}');
    }
    finally {
      client.close();
    }
  }
}
