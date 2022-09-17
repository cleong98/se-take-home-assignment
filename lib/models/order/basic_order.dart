import 'package:se_take_home_assignment/models/robot/basic_robot.dart';

abstract class BasicOrder {
  BasicOrder(this.id);
  // unique id.
  final int id;
  // order status.
  Status orderStatus = Status.pending;
  // order handler message.
  String handleStatus = 'waiting robot handle';
  // is in process.
  bool inProcess = false;
  // handler by which robot.
  BasicRobot? handleBy;
}

enum Status {
  pending,
  complete,
}
