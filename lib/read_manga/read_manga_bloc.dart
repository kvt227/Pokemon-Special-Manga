import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:pokemon_special_app/database/cache_table.dart';
import 'package:pokemon_special_app/model/cache_manga.dart';
import 'package:pokemon_special_app/model/image_manga.dart';

part 'read_manga_event.dart';
part 'read_manga_state.dart';

class ReadMangaBloc extends Bloc<ReadMangaEvent, ReadMangaState> {
  ReadMangaBloc() : super(ReadMangaInitial());

  CacheMangaTable _cacheTable = CacheMangaTable();
  List<ImgManga> listImg = <ImgManga>[];
  int chapter = 234;
  int _currentId = 1;

  final _templateUrl = 'https://www.pokemonspecial.com/2014/06/chapter-';
  final _mangaName = 'Pokemon Special';
  final _listIgnore = [
    'home.png',
    'top.png',
    'center.png',
    'bottom.png',
    'next.png',
    'prev.png',
  ];

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
    } else if (event is ReadMangaSubmitChapter) {
      yield* _mapReadMangSubmitChapter(event);
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
      await _cacheTable.update(CacheManga(mangaName: _mangaName, chapter: chapter, id: _currentId));
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

      await _cacheTable.update(CacheManga(mangaName: _mangaName, chapter: chapter, id: _currentId));
      await getImage();
      yield ReadMangaDataFetched();
    } catch (ex) {
      yield ReadMangaDataFailed(ex: ex);
    }
  }

  Stream<ReadMangaState> _mapReadMangSubmitChapter(
      ReadMangaSubmitChapter event,
      ) async* {

    try {
      chapter = event.chapter;
      await _cacheTable.update(CacheManga(mangaName: _mangaName, chapter: chapter, id: _currentId));
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

      var currentManga =  await _cacheTable.selectById(_currentId);
      // Trường hợp tại bảng cache chưa tồn tại truyện đang đọc
      if (currentManga == null) {
        currentManga = CacheManga(mangaName: _mangaName, chapter: chapter);
        _cacheTable.insert(currentManga);
      }

      chapter = currentManga.chapter;

      String url = _templateUrl + chapter.toString().padLeft(3, '0') + '.html';
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

          if (urlSplit[0] != 'https:' || _listIgnore.contains(fileName)) {
            continue;
          }

          // Từ chap 234 đến chap 364 là truyện scan và được đặt tên file bao gồm chữ bên trong
          if ((chapter > 233 && chapter < 365) || int.tryParse(fileName.split('.')[0]) != null) {
            listImg.add(ImgManga(url: tr.attributes['src']));
          }
        } catch (e) {}
      }
      // print('Count image: ${listImg.length}');
    }
    finally {
      client.close();
    }
  }
}
