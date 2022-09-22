import 'dart:async';

abstract class BasicRobot {
  BasicRobot({required this.id, this.name = 'Robot'});
  // unique id.
  //  odd is new bot  event is old bot
  final int id;
  // robot name.
  final String name;

  // robot is handler order or not.
  bool isBusy = false;

  Timer? timer;

}