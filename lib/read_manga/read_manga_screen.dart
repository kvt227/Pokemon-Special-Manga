import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pokemon_special_app/model/image_manga.dart';
import 'package:pokemon_special_app/read_manga/read_manga_bloc.dart';

class ReadMangaScreen extends StatefulWidget {
  @override
  _ReadMangaScreenState createState() => _ReadMangaScreenState();
}

class _ReadMangaScreenState extends State<ReadMangaScreen> {
  ReadMangaBloc _readMangaBloc;

  @override
  void initState() {
    _readMangaBloc = BlocProvider.of<ReadMangaBloc>(context);
    _readMangaBloc.add(ReadMangaStarted());
    _fetchData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchData() {
    _readMangaBloc.add(ReadMangaFetchData(isLoading: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Center(child: Text('Pokemon Special Manga'))),
      body: Container(
        color: Colors.white,
        child: BlocConsumer<ReadMangaBloc, ReadMangaState>(
            listener: (ctx, state) {},
            builder: (ctx, state) {
              if (state is ReadMangaInitial ||
                  state is ReadMangaDataLoading) {
                return const SpinKitWave(
                  color: Colors.red,
                );
              }
              if (state is ReadMangaDataFailed) {
                return Center(
                  child: Text('Error'),
                );
              }

              final listImg = _readMangaBloc?.listImg;

              return Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_left),
                            tooltip: 'Previous chapter',
                            onPressed: () {
                              setState(() {
                                _readMangaBloc.add(ReadMangaPreviousChapter());
                              });
                            },
                          ),
                          Text(
                            _readMangaBloc?.chapter.toString().padLeft(3, '0'),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_right),
                            tooltip: 'Next chapter',
                            onPressed: () {
                              setState(() {
                                _readMangaBloc.add(ReadMangaNextChapter());
                              });
                            },
                          ),
                        ],
                      ),
                      Expanded(child: buildManga(listImg)),
                    ],
                  )
              );
            }),
      ),
    );
  }

  Widget buildManga(List<ImgManga> listImg) {

    return ListView.separated(
        itemBuilder: (context, index) {
          return buildImgManga(listImg[index], index);
        },
        separatorBuilder: (context, index) {
          return Container(
            height: 2,
            color: const Color(0xffffffff),
          );
        },
        itemCount: listImg.length
    );
  }

  Widget buildImgManga(ImgManga img, int index) {
    print('Link image: ${img.url}');
    return Container(
        child: Row(
          children: [
            Expanded(
                child: Image.network(img.url)
            )
          ],
        )
    );
  }
}
