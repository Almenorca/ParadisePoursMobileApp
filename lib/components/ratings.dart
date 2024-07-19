import 'package:flutter/material.dart';

class Ratings extends StatelessWidget {
  final Function switchComp;
  final dynamic drinkToDisplay;

  const Ratings(
      {super.key, required this.switchComp, required this.drinkToDisplay});

  @override
  Widget build(BuildContext context) {
    // Implement your UI for Ratings widget
    return Container(
      child: const Text('Ratings Widget'),
    );
  }
}
