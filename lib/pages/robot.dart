import 'package:flutter/material.dart';
import 'package:se_take_home_assignment/controller/order_controller.dart';
import 'package:se_take_home_assignment/models/order/vip_order.dart';
import 'package:se_take_home_assignment/models/robot/basic_robot.dart';
import 'package:se_take_home_assignment/models/robot/mcd_robot.dart';

import '../models/order/basic_order.dart';

class RobotPage extends StatelessWidget {
  const RobotPage({Key? key, required this.orderController}) : super(key: key);
  final OrderController orderController;

  void _addRobot() {
    orderController.addMcdRobot();
  }

  String getOrderName(BasicOrder? order) {
    if (order == null) {
      return "";
    }
    final String orderName;
    orderName = order is VipOrder ? 'Vip Order ${order.id}' : 'Normal Order ${order.id}';
    return orderName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: orderController,
        builder: (BuildContext context, Widget? child) {
          final robotList = orderController.robotList;
          if (robotList.isEmpty) {
            return const Center(
              child: Text('No Robot'),
            );
          }
          return ListView.builder(
            itemCount: robotList.length,
            itemBuilder: (BuildContext context, int index) {
              final McdRobot robot = robotList[index] as McdRobot;
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${robot.name} ${robot.id}'),
                    if (robot.handleOrder != null)
                    Text('Handle ${getOrderName(robot.handleOrder)}'),
                  ],
                ),
                trailing: IconButton(
                  onPressed: () {
                    final robot = robotList[index] as McdRobot;
                    orderController.deleteMcdRobot(robot);
                  },
                  icon: const Icon(Icons.delete, size: 24,),
                )
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRobot,
        child: const Icon(Icons.add),
      ),
    );
  }
}
