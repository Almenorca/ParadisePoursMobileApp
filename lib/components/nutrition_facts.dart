import 'package:flutter/material.dart';

class NutritionFacts extends StatelessWidget {
  final Function switchComp;
  final dynamic drinkToDisplay;

  const NutritionFacts(
      {super.key, required this.switchComp, required this.drinkToDisplay});

  @override
  Widget build(BuildContext context) {
    // Implement your UI for NutritionFacts widget
    return Container(
      child: const Text('Nutrition Facts Widget'),
    );
  }
}
