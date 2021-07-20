part of 'read_manga_bloc.dart';

@immutable
abstract class ReadMangaEvent {}

class ReadMangaStarted extends ReadMangaEvent {
  ReadMangaStarted();
}

class ReadMangaFetchData extends ReadMangaEvent {
  final bool isLoading;
  final bool isRefresh;
  final bool isLoadMore;
  ReadMangaFetchData({
    this.isLoading = false,
    this.isRefresh = false,
    this.isLoadMore = false,
  });
}

class ReadMangaNextChapter extends ReadMangaEvent {
  ReadMangaNextChapter();
}

class ReadMangaPreviousChapter extends ReadMangaEvent {
  ReadMangaPreviousChapter();
}

class ReadMangaSubmitChapter extends ReadMangaEvent {
  final int chapter;

  ReadMangaSubmitChapter(this.chapter);
}
