import 'package:flutter/material.dart';
import 'drink_facts.dart';
import 'ratings.dart';

class DisplayDrink extends StatefulWidget {
  final dynamic drink;
  final dynamic userId;
  //Favorite Features
  final dynamic avgRating;
  final dynamic favBoolean;
  final Function favDrink;
  final Function unfavDrink;  
  //Comment Features
  final int userRating;
  final int index;
  final Function(int, String) rateDrink; 
  final List<Map<String, dynamic>> comments;

  const DisplayDrink(
    {super.key, 
    required this.drink,
    required this.userId,
    required this.favBoolean,
    required this.avgRating,
    required this.favDrink,
    required this.unfavDrink,
    required this.userRating,
    required this.index,
    required this.rateDrink,
    required this.comments,
    });

  @override
  _DisplayDrinkState createState() => _DisplayDrinkState();
}

class _DisplayDrinkState extends State<DisplayDrink> {
  bool showRatings = false;

  @override
  void initState() {
    super.initState();
    // Reset showRatings to false whenever Drink prop changes
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
        ? Ratings(switchComp: switchComp, 
                  drinkToDisplay: widget.drink,
                  userRating: widget.userRating,
                  index: widget.index,
                  rateDrink: widget.rateDrink, 
                  comments: widget.comments) 
        : DrinkFacts(switchComp: switchComp, 
                        drinkToDisplay: widget.drink, 
                        userId: widget.userId, 
                        favBoolean: widget.favBoolean,
                        avgRating: widget.avgRating,
                        favDrink: widget.favDrink,
                        unfavDrink: widget.unfavDrink);
    return Container(
      child: compToDisplay,
    );
  }
}
