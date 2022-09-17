import 'dart:async';
import 'dart:isolate';

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
    notifyListeners();
  }

  // handler order and create isolate to process concurrency
  Future<void> handleOrder(BasicOrder order, McdRobot robot) async {
    robot.updateStatus(true);
    robot.setHandleOrder(order);
    order.inProcess = true;
    order.handleBy = robot;
    //_queue.remove(order);
    _createIsolate(order, robot);
  }

  // create isolate
  // isolate will auto release so no need manual to dispose isolate
  void _createIsolate(BasicOrder order, McdRobot robot) async {
    // create a receipt port to communicate with isolate.
    // because in dart isolate is seal. there are not shared data with main isolate.
    final ReceivePort receivePort = ReceivePort();
    // create a send port to receive send port from isolate
    SendPort? sendPort;

    // listen data from isoalte
    receivePort.listen((value) {
      BasicOrder handleOrder = order;

      // create communication with isolate.
      // get the send port from isolate that can receipt isolate data.
      if (value is SendPort) {
        sendPort = value;
      }

      // handler count down, update order status and some business logic
      if (value is Map<String, dynamic>) {
        final String? handleStatus = value["handleMessage"];
        final robotisAvailable = robotList.firstWhereOrNull(
                (BasicRobot queueRobot) => robot.id == queueRobot.id) !=
            null;
        // if robot not available will back to waiting robot handler.
        if (!robotisAvailable) {
          sendPort!.send(true);
          order.orderStatus = Status.pending;
          order.handleBy = null;
          order.inProcess = false;
        }
        if (handleStatus != null) {
          handleOrder.handleStatus = handleStatus;
          notifyListeners();
        }
      }

      // if all countdown is completed will update to complete status.
      if (value is bool) {
        final complete = value;
        if (complete) {
          handleOrder.orderStatus = Status.complete;
          robot.updateStatus(false);
          robot.setHandleOrder(null);
          notifyListeners();
        }
      }
    });

    // run isolate
    await Isolate.spawn(processOrder, receivePort.sendPort);
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

// isolate cannot be class member
void processOrder(SendPort sendPort) {
  final ReceivePort receivePort = ReceivePort();
  bool forceExit = false;
  int timeout = 10;
  final Map<String, dynamic> receiveData = {};
  receivePort.listen((value) {
    if (value is BasicOrder) {
      final order = value;
    }
    if (value is bool) {
      forceExit = value;
    }
    print("Background Isolate Receive Data -> 【$value]");
  });
  sendPort.send(receivePort.sendPort);

  Timer.periodic(const Duration(seconds: 1), (timer) {
    if (timeout == 0) {
      timer.cancel();
    }
    receiveData["handleMessage"] = '$timeout s';
    sendPort.send(receiveData);
    timeout--;
    if (timeout == -1 || forceExit) {
      timer.cancel();
      if (!forceExit) {
        receiveData["handleMessage"] = 'complete';
        sendPort.send(receiveData);
        sendPort.send(true);
      } else {
        receiveData["handleMessage"] = 'waiting robot handle';
        sendPort.send(receiveData);
        sendPort.send(false);
      }
    }
  });
}
