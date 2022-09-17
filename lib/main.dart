import 'package:flutter/material.dart';
import 'package:se_take_home_assignment/controller/order_controller.dart';
import 'package:se_take_home_assignment/models/robot/mcd_robot.dart';
import 'package:se_take_home_assignment/pages/home.dart';
import 'package:se_take_home_assignment/pages/robot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _navBottomItem = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(Icons.manage_accounts),
      label: 'Robot',
    ),
  ];
  int _currentIndex = 0;

  late final OrderController _orderController = OrderController();

  @override
  void initState() {
    super.initState();

    _orderController.addListener(() {
      // when robot complete order will notify next order process until nor pending order more.
      final order = _orderController.firstPendingOrder;
      final robot = _orderController.notBusyRobot;
      if (order != null && robot != null) {
        robot as McdRobot;
        _orderController.handleOrder(order, robot);
      }
    });
  }

  @override
  void dispose() {
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(
            orderController: _orderController,
          ),
          RobotPage(
            orderController: _orderController,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navBottomItem,
      ),
    );
  }
}
