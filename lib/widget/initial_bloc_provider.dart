import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokemon_special_app/read_manga/read_manga_bloc.dart';

class InitialBlocProvider extends StatelessWidget {
  final Widget child;

  const InitialBlocProvider({@required this.child}) : assert(child != null);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ReadMangaBloc())
      ],
      child: child,
    );
  }
}
