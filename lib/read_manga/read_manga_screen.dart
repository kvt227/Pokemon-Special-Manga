import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pokemon_special_app/model/image_manga.dart';
import 'package:pokemon_special_app/read_manga/read_manga_bloc.dart';

class ReadMangaScreen extends StatefulWidget {
  @override
  _ReadMangaScreenState createState() => _ReadMangaScreenState();
}

class _ReadMangaScreenState extends State<ReadMangaScreen> {

  ReadMangaBloc _readMangaBloc;
  double _height = 0;

  var _scrollController = ScrollController();
  var _isVisible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _readMangaBloc = BlocProvider.of<ReadMangaBloc>(context);
    _readMangaBloc.add(ReadMangaStarted());
    _fetchData();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {

      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        // print('true: ' + _scrollController.position.pixels.toString());
        if (_isVisible) {
          setState(() {
            _isVisible = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
          // print('false: ' + _scrollController.position.pixels.toString());
          if (!_isVisible) {
            setState(() {
              _isVisible = true;
            });
          }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _readMangaBloc.close();
  }

  void _fetchData() {
    _readMangaBloc.add(ReadMangaFetchData(isLoading: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 45,
          backgroundColor: Colors.white,
          title: const Center(child: Text('Pokemon Special Manga'))
      ),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Error'),
                      Container(
                        height: 5,
                      ),
                      OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _fetchData();
                            });
                          },
                          child: Text('Reload')
                      )
                    ],
                  ),
                );
              }

              final listImg = _readMangaBloc?.listImg;

              return Container(
                  child: Column(
                    children: [
                      Visibility(
                          visible: _isVisible,
                          child: buildHeader()
                      ),
                      Expanded(child: buildManga(listImg)),
                    ],
                  )
              );
            }),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
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
        SizedBox(
          width: 40,
          // height: 45,
          child: TextField(
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
            ),
            //keyboardType: TextInputType.number,
            controller: TextEditingController(
                text: (_readMangaBloc?.chapter.toString().padLeft(3, '0') ?? 0)),
            onSubmitted: (String value) async {
              setState(() {
                _readMangaBloc.add(ReadMangaSubmitChapter(int.parse(value)));
              });
            },
          ),
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
    );
  }

  Widget buildManga(List<ImgManga> listImg) {
    // Get height of image by device
    _height = _getHeightByDevice();

    return ListView.separated(
        controller: _scrollController,
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
    // print('Link image: ${img.url}');
    return SizedBox(
      // 2.72: The ratio between _height and real height to have a full size image.
      height: _height / 2.72,
      child: PhotoView(
        imageProvider: NetworkImage(img.url),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        // enableRotation: false,
        backgroundDecoration: BoxDecoration(
          color: Colors.white,
          // For test
          // color: Colors.red
        ),
        loadingBuilder: (context, event) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  double _getHeightByDevice() {
    double height = 1000;
    int chapter = _readMangaBloc?.chapter;

    if (chapter > 233 && chapter < 365) {
      height = 1056 * window.physicalSize.width / 1559;
    } else {
      height = 1290 * window.physicalSize.width / 908;
    }

    return height;
  }
}
