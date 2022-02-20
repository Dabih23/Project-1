import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rick_morty_freezed/bloc/character_bloc.dart';
import 'package:rick_morty_freezed/data/models/character.dart';
import 'package:rick_morty_freezed/ui/widgets/custom_list_tile.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Character _currentCharacter;//хранит общую информацию о количестве страниц и персонажей
  List<Results> _currentResults = [];//хранится массив персонажей
  int _currentPage = 1;//с ее помощью будем отслеживать текущую страницу
  String _currentSearchStr = '';//текущая строка которую ввел пользователь в поиске

  final RefreshController refreshController = RefreshController();
  bool _isPagination = false;

  Timer? searchDebounce;//переменная для задежрки запроса
  //чтобы когда пользователь вводит символ, то искало не сразу а после паузы

  final _storage = HydratedBlocOverrides.current?.storage;//передаем текущий storage

  @override
  void initState() {
    //если хранилище пустое, то отправляем запрос
    if (_storage.runtimeType.toString().isEmpty) {
      if (_currentResults.isEmpty) {//если нет никаких результатов
        context//делаем запрос на сайт Рик и Морти
            .read<CharacterBloc>()//берем наш bloc
            //и к нему добавляем наше событие
            .add(const CharacterEvent.fetch(name: '', page: 1));
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //в этой переменной с помощью метода watch отслеживаем изменения в bloc
    final state = context.watch<CharacterBloc>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding:// отступы:       верх       низ         лево     право
              const EdgeInsets.only(top: 15, bottom: 15, left: 16, right: 16),
          child: TextField(//наша строка поиска
            style: const TextStyle(color: Colors.white),//цвет текста
            cursorColor: Colors.white,//цвет курсора
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromRGBO(86, 86, 86, 0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white),//иконка
              hintText: 'Search Name',//текст подсказки
              hintStyle: const TextStyle(color: Colors.white),
            ),
            onChanged: (value) {
              _currentPage = 1;//когда начинаем поиск то значение 1(всегда 1: ввели букву и ищем с первой страницы)
              _currentResults = [];//очищаем перед каждым поиском
              _currentSearchStr = value;//передаем то что ввел пользователь

              searchDebounce?.cancel();//перед задежркой отменяем таймеры
              searchDebounce = Timer(const Duration(milliseconds: 500), () {
                context//при нажатии на строку поиска
                  .read<CharacterBloc>()//обращаемся к bloc
                  //затем обращаемся к нашему событию
                  //в name передаем значение, которое пользователь введет в строку
                  .add(CharacterEvent.fetch(name: value, page: _currentPage));
              });
              
            },
          ),
        ),
        Expanded(
          child: state.when(
            loading: () {//состояние загрузки
              if (!_isPagination) {//если не наша переменная то загрузка
                return Center(//когда загрузка то индикатор с надписью
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(width: 10),
                      Text('Loading...'),
                    ],
                  ),
                );
              } else {//иначе добавляем персонажей к уже имеющимся
                return _customListView(_currentResults);
              }
            },//принимает переменную, которую реализовали в State
            loaded: (characterLoaded) {
              _currentCharacter = characterLoaded;//передаем то что хранится в characterLoaded
              if (_isPagination) {//если _isPagination
              //тогда в нашу переменную добавляем новых персонажей
                _currentResults.addAll(_currentCharacter.results);
                refreshController.loadComplete();//персонажи загрузились
                _isPagination = false;
              } else {//иначе отображаем список имеющихся персонажей
                _currentResults = _currentCharacter.results;//содержит массив информации о персонажах
              }
              return _currentResults.isNotEmpty//если есть какой-то результат
                  ? _customListView(_currentResults)//тогда отображаем наших персонажей
                  : const SizedBox();//иначе ничего не отображаем
            },
            //при состоянии ошибки просто выводим Text
            error: () => const Text('Nothing found...'),
          ),
        ),
      ],
    );
  }

//                        принимает массив персонажей
  Widget _customListView(List<Results> currentResults) {
    return SmartRefresher(
      controller: refreshController,
      enablePullUp: true,//появление загрузки когда мы внизу
      enablePullDown: false,//чтобы не появялась загрузка сверху
      onLoading: () {//момент загрузки
        _isPagination = true;//переменную в тру
        _currentPage++;//значение страницы увеличиваем на 1
        //если наша страницы меньше или равна количеству страниц
        if (_currentPage <= _currentCharacter.info.pages) {
          //тогда получаем новых персонажей
          context.read<CharacterBloc>().add(CharacterEvent.fetch(
             //                        текущая страница
              name: _currentSearchStr, page: _currentPage));
        } else {
          refreshController.loadNoData();//метод,, который говорит что данных больше нет
        }
      },
      child: ListView.separated(
        itemCount: currentResults.length,//длинна списка
        //(_, index) - первый параметр не принимаем, а второй это индекс
        separatorBuilder: (_, index) => const SizedBox(height: 5),//возвращаем отступ между карточками
        shrinkWrap: true,//занимает только нужное пространство (в зависимости от кол-ва элементов)
        itemBuilder: (context, index) {
          final result = currentResults[index];//обращаемся к списку по индексу и передаем в переменную
          return Padding(
            padding:
                const EdgeInsets.only(right: 16, left: 16, top: 3, bottom: 3),
            child: CustomListTile(result: result),
          );
        },
      ),
    );
  }
}