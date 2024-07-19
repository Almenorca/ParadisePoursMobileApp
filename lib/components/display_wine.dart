import 'package:flutter/material.dart';
import 'nutrition_facts.dart';
import 'ratings.dart';

class DisplayWine extends StatefulWidget {
  final dynamic wine;

  const DisplayWine({super.key, required this.wine});

  @override
  _DisplayWineState createState() => _DisplayWineState();
}

class _DisplayWineState extends State<DisplayWine> {
  bool showRatings = false;

  @override
  void initState() {
    super.initState();
    // Reset showRatings to false whenever wine prop changes
    setState(() {
      showRatings = false;
    });
  }

  void switchComp() {
    setState(() {
      showRatings = !showRatings;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine which component to display based on showRatings state
    Widget compToDisplay = showRatings
        ? Ratings(switchComp: switchComp, drinkToDisplay: widget.wine)
        : NutritionFacts(switchComp: switchComp, drinkToDisplay: widget.wine);

    return Container(
      child: compToDisplay,
    );
  }
}
