import 'package:flutter/material.dart';
import 'package:se_take_home_assignment/controller/order_controller.dart';
import 'package:se_take_home_assignment/models/robot/mcd_robot.dart';

class RobotPage extends StatelessWidget {
  const RobotPage({Key? key, required this.orderController}) : super(key: key);
  final OrderController orderController;

  void _addRobot() {
    orderController.addMcdRobot();
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
              return ListTile(
                title: Text('${robotList[index].name} ${robotList[index].id}'),
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
