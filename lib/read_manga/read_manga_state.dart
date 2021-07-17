part of 'read_manga_bloc.dart';

@immutable
abstract class ReadMangaState {}

class ReadMangaInitial extends ReadMangaState {}

class ReadMangaDataLoading extends ReadMangaState {}

class ReadMangaDataLoaded extends ReadMangaState {}

class ReadMangaDataFetched extends ReadMangaState {}

class ReadMangaDataFiltered extends ReadMangaState {}

class ReadMangaDataFailed extends ReadMangaState {
  final dynamic ex;

  ReadMangaDataFailed({this.ex});
}
