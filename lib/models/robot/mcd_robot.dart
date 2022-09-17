import 'package:se_take_home_assignment/models/order/basic_order.dart';
import 'package:se_take_home_assignment/models/robot/basic_robot.dart';

class McdRobot extends BasicRobot {
  McdRobot({this.handleOrder, required super.id, super.name = 'Mcd Robot'});

  BasicOrder? handleOrder;

  void setHandleOrder(BasicOrder? order) => handleOrder = order;

  void updateStatus(bool status) {
    super.isBusy = status;
  }
}
