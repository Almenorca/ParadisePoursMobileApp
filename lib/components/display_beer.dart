import 'package:flutter/material.dart';
import 'nutrition_facts.dart';
import 'ratings.dart';

class DisplayBeer extends StatefulWidget {
  final dynamic beer;

  const DisplayBeer({super.key, required this.beer});

  @override
  _DisplayBeerState createState() => _DisplayBeerState();
}

class _DisplayBeerState extends State<DisplayBeer> {
  bool showRatings = false;

  @override
  void initState() {
    super.initState();
    // Reset showRatings to false whenever beer prop changes
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
        ? Ratings(switchComp: switchComp, drinkToDisplay: widget.beer)
        : NutritionFacts(switchComp: switchComp, drinkToDisplay: widget.beer);

    return Container(
      child: compToDisplay,
    );
  }
}
