import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../models/order/basic_order.dart';
import '../models/order/normal_order.dart';
import '../models/order/vip_order.dart';
import '../models/robot/basic_robot.dart';
import '../models/robot/mcd_robot.dart';

class OrderController extends ChangeNotifier {
  final List<BasicOrder> _queue = [];
  int _vipOrderTotal = 0;
  final List<BasicRobot> _robotList = [];
  Timer? _timer;
  final int _handleTimes = 10;

  // add normal order
  void addNormalOrder() {
    final id = _queue.length - _vipOrderTotal + 1;
    final NormalOrder normalOrder = NormalOrder(id);
    _queue.add(normalOrder);
    notifyListeners();
  }

  // add vip order
  void addVipOrder() {
    final id = _vipOrderTotal + 1;
    final VipOrder vipOrder = VipOrder(id);
    _queue.insert(_vipOrderTotal, vipOrder);
    _vipOrderTotal++;
    notifyListeners();
  }

  // add robot
  void addMcdRobot() async {
    final robot = McdRobot(id: robotList.length + 1);
    robotList.add(robot);
    notifyListeners();
  }

  // delete robot
  void deleteMcdRobot(McdRobot robot) {
    robotList.remove(robot);
    final order = robot.handleOrder;
    if (order != null) {
      _resetOrder(order);
    }
    notifyListeners();
  }

  // handler order and create isolate to process concurrency
  Future<void> handleOrder(BasicOrder order, McdRobot robot) async {

    // setting handle time
    int count = _handleTimes;

    // setting robot handle order
    robot.updateStatus(true);
    robot.setHandleOrder(order);

    // setting order status
    order.inProcess = true;
    order.handleBy = robot;
    order.handleStatus = '$count s';

    // process
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _timer ??= timer;
      count--;
      order.handleStatus = '$count s';

      if (count == 0) {
        // completed order
        timer.cancel();
        _timer = null;
        order.handleStatus = 'complete';
        order.orderStatus = Status.complete;
        robot.updateStatus(false);
        robot.setHandleOrder(null);
      }
      notifyListeners();
    });
  }

  void _resetOrder(BasicOrder order) {
    order.orderStatus = Status.pending;
    order.handleBy = null;
    order.inProcess = false;
    order.handleStatus = 'waiting robot handle';
    _timer!.cancel();
  }

  // get first pending order which are haven't process by robot.
  BasicOrder? get firstPendingOrder =>
      queue.firstWhereOrNull((BasicOrder queueOrder) {
        return queueOrder.orderStatus == Status.pending &&
            queueOrder.inProcess == false;
      });

  // get all completed order
  bool get orderAllIsCompleted =>
      _queue.firstWhereOrNull(
          (BasicOrder order) => order.orderStatus == Status.pending) ==
      null;

  // get the all order in queue
  List<BasicOrder> get queue => _queue;

  // get the robot list
  List<BasicRobot> get robotList => _robotList;

  // get no busy robot
  BasicRobot? get notBusyRobot =>
      _robotList.firstWhereOrNull((BasicRobot robot) => robot.isBusy == false);

  // get the all order in queue status is pending
  List<BasicOrder> get pendingQueue => _queue
      .where((BasicOrder order) => order.orderStatus == Status.pending)
      .toList();

  // get the all order in queue status is pending
  List<BasicOrder> get completeQueue => _queue
      .where((BasicOrder order) => order.orderStatus == Status.complete)
      .toList();
}
