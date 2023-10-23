import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final Color backgroundColor;
  const Loading({super.key, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: const Center(
        child: SpinKitChasingDots(
          color: Colors.amber,
          size: 50,
        ),
      ),
    );
  }
}
