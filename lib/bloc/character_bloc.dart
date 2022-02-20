import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:rick_morty_freezed/data/models/character.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_morty_freezed/data/repositories/character_repo.dart';

part 'character_bloc.freezed.dart';
part 'character_bloc.g.dart';
part 'character_event.dart';
part 'character_state.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> with HydratedMixin {
  final CharacterRepo characterRepo;
  CharacterBloc({required this.characterRepo})
      : super(const CharacterState.loading()) {
    on<CharacterEventFetch>((event, emit) async {//регистрируем bloc
      emit(const CharacterState.loading());//когда приложение загружается то выываем состояние загрузки
      try {
        Character _characterLoaded = await characterRepo//characterRepo - репозиторий
            .getCharacter(event.page, event.name)//берем age и name
            .timeout(const Duration(seconds: 5));//чтобы bloc не подвис
        //когда персонажи загрузятся, то передаем соответствующее состояние и данные   
        emit(CharacterState.loaded(characterLoaded: _characterLoaded));
      } catch (_) {
        //если что-то не так то вызываем состояние Error (CharacterState.error())
        emit(const CharacterState.error());
        rethrow;//пускаем ошибку дальше
      }
    });
  }

  @override//восстановление состояния       
  CharacterState? fromJson(Map<String, dynamic> json) => CharacterState.fromJson(json);

  @override//сохранение состояния на устройство        берем состояние и передаем в toJson
  Map<String, dynamic>? toJson(CharacterState state) => state.toJson();
}