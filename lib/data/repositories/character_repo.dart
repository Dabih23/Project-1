import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rick_morty_freezed/data/models/character.dart';

class CharacterRepo {
  final url = 'https://rickandmortyapi.com/api/character';

//                     принимает страницу и имя персонажа
  Future<Character> getCharacter(int page, String name) async {
    try {///                                 к Url добавляем наши параметры
      var response = await http.get(Uri.parse(url + '?page=$page&name=$name'));//запрос к Url

      var jsonResult = json.decode(response.body);//в переменной декодируем наш запрос
      return Character.fromJson(jsonResult);
    } catch (e) {
      //   исключение (название ошибки)
      throw Exception(e.toString());
    }
  }
}