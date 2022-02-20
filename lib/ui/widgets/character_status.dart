import 'package:flutter/material.dart';

enum LiveState { alive, dead, unknown }//статусы персонажа

class CharacterStatus extends StatelessWidget {
  final LiveState liveState;
  const CharacterStatus({ Key? key, required this.liveState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(//закругленная иконка, которая в зависимости от статуса принимает разный цвет
          Icons.circle,
          size: 11,
          color: liveState == LiveState.alive
              ? Colors.lightGreenAccent[400]//если жив то цвет зеленый
              : liveState == LiveState.dead//иначе статус "умер"
                  ? Colors.red//тогда цвет красный
                  : Colors.white,//если ничего из этого то белый
        ),
        const SizedBox(
          width: 6,
        ),
        Text(//текст к иконке
          liveState == LiveState.dead
              ? 'Dead'
              : liveState == LiveState.alive
                  ? 'Alive'
                  : 'Unknown',
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }
}