import 'package:flutter/material.dart';
import 'nutrition_facts.dart';
import 'ratings.dart';

class DisplayLiquor extends StatefulWidget {
  final dynamic liquor;

  const DisplayLiquor({super.key, required this.liquor});

  @override
  _DisplayLiquorState createState() => _DisplayLiquorState();
}

class _DisplayLiquorState extends State<DisplayLiquor> {
  bool showRatings = false;

  @override
  void initState() {
    super.initState();
    // Reset showRatings to false whenever liquor prop changes
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
        ? Ratings(switchComp: switchComp, drinkToDisplay: widget.liquor)
        : NutritionFacts(switchComp: switchComp, drinkToDisplay: widget.liquor);

    return Container(
      child: compToDisplay,
    );
  }
}
