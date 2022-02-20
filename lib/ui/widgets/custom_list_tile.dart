import 'package:flutter/material.dart';
import 'package:rick_morty_freezed/data/models/character.dart';
import 'package:rick_morty_freezed/ui/widgets/character_status.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomListTile extends StatelessWidget {
  final Results result;
  const CustomListTile({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(//для закругления
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: MediaQuery.of(context).size.height / 7,//высота
        color: const Color.fromRGBO(86, 86, 86, 0.8),//цвет
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CachedNetworkImage(//для картинки
              imageUrl: result.image,//обращаемся к картинке
              //когда нет картинки отображаем загрузку
              placeholder: (context, url) => const CircularProgressIndicator(
                color: Colors.grey,
              ),
              //если картинка не загрузится, то выводим иконку ошибки
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(//бокс где находится имя
                      width: MediaQuery.of(context).size.width / 1.9,
                      child: Text(
                        result.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText2,
                      )),
                  const SizedBox(//отступ
                    height: 10,
                  ),
                  CharacterStatus(
                      liveState: result.status == 'Alive'//если статус "Alive"
                          ? LiveState.alive//то значение живой
                          : result.status == 'Dead'//иначе статус мертв
                              ? LiveState.dead//тогда статус мертв
                              : LiveState.unknown//если ничего из этого то неопределен
                              ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Row(
                      // Rows for Species and Gender
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          // Species column
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Species:',
                              style: Theme.of(context).textTheme.caption,
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              result.species,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyText1,
                            )
                          ],
                        ),
                        Column(
                          // Gender  column
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gender:',
                              style: Theme.of(context).textTheme.caption,
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              result.gender,
                              style: Theme.of(context).textTheme.bodyText1,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}