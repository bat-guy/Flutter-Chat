import 'package:flutter/material.dart';
import 'package:flutter_mac/screens/profile/profile.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          GestureDetector(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.account_circle_rounded)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),
        ],
      ),
    );
  }
}
