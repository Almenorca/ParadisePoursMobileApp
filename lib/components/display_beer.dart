import 'package:flutter/material.dart';
import 'beer_facts.dart';
import 'ratings.dart';

class DisplayBeer extends StatefulWidget {
  final dynamic beer; //Selected beer
  final dynamic userId;
  final dynamic favBoolean;
  final Function favBeer;
  final Function unfavBeer;

  const DisplayBeer(
    {super.key, 
    required this.beer,
    required this.userId,
    required this.favBoolean,
    required this.favBeer,
    required this.unfavBeer,
    });

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
        ? Ratings(switchComp: switchComp, drinkToDisplay: widget.beer) //switchComp function, beer, userId, favBoolean passed
        : BeerFacts(switchComp: switchComp, 
                        drinkToDisplay: widget.beer, 
                        userId: widget.userId, 
                        favBoolean: widget.favBoolean,
                        favBeer: widget.favBeer,
                        unfavBeer: widget.unfavBeer);
    return Container(
      child: compToDisplay,
    );
  }
}
