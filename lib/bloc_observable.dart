import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterBlocObservable extends BlocObserver {//для отслеживания событий
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    //выводит название bloc и его event
    log('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {//отслеживание ошибок
    super.onError(bloc, error, stackTrace);
    //выводит ошибку и ее содержание
    log('onError -- bloc: ${bloc.runtimeType}, error: $error');
  }
}