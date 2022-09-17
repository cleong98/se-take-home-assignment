import 'package:flutter/material.dart';
import 'package:se_take_home_assignment/controller/order_controller.dart';
import 'package:se_take_home_assignment/models/order/basic_order.dart';
import 'package:se_take_home_assignment/models/order/vip_order.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.orderController}) : super(key: key);
  final OrderController orderController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Area',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(
                  height: 10,
                ),
                _AreaCard(
                  orderController: orderController,
                  showStatus: Status.pending,
                ),
                const SizedBox(height: 20,),
                const Text(
                  'Complete Area',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(
                  height: 10,
                ),
                _AreaCard(
                  orderController: orderController,
                  showStatus: Status.complete,
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      orderController.addNormalOrder();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.blue.shade50,
                    ),
                    child: Text(
                      'Add New Normal Order',
                      style: TextStyle(
                        color: Colors.blue.shade300,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      orderController.addVipOrder();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.blue.shade50,
                    ),
                    child: Text(
                      'Add New Vip Order',
                      style: TextStyle(
                        color: Colors.blue.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({
    Key? key,
    required this.orderController,
    required this.showStatus,
  }) : super(key: key);

  final OrderController orderController;
  final Status showStatus;

  Widget _orderCard(BasicOrder order, int index) {
    final text = order is VipOrder ? 'VIP Order' : 'Normal Order';
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text('$text (${order.id})'),
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade300),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              '${ index + 1 }',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ),
        trailing: Text(order.handleStatus),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emptyText = showStatus == Status.pending
        ? 'Pending Area is empty'
        : 'Complete Area is empty';
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: AnimatedBuilder(
          animation: orderController,
          builder: (BuildContext context, Widget? child) {
            final List<BasicOrder> queue = showStatus == Status.pending
                ? orderController.pendingQueue
                : orderController.completeQueue;
            if (queue.isEmpty) {
              return Center(child: Text(emptyText));
            }
            return ListView.builder(
              itemCount: queue.length,
              itemBuilder: (BuildContext context, int index) {
                final order = queue[index];
                return _orderCard(order, index);
              },
            );
          }),
    );
  }
}
