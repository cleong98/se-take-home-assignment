abstract class BasicRobot {
  BasicRobot({required this.id, this.name = 'Robot'});
  // unique id.
  final int id;
  // robot name.
  final String name;

  // robot is handler order or not.
  bool isBusy = false;
}