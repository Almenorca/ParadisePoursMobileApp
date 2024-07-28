import 'package:flutter/material.dart';
import 'drink_otd_facts.dart';

class DrinkOtdDrink extends StatefulWidget {
  final dynamic drink;
  final dynamic userId;
  //Favorite Features
  final dynamic favBoolean;
  final Function favDrink;
  final Function unfavDrink;  

  const DrinkOtdDrink(
    {super.key, 
    required this.drink,
    required this.userId,
    required this.favBoolean,
    required this.favDrink,
    required this.unfavDrink,
    });

  @override
  _DisplayDrinkState createState() => _DisplayDrinkState();
}

class _DisplayDrinkState extends State<DrinkOtdDrink> {
  bool showRatings = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget compToDisplay =  DrinkOtdFacts(
                        drinkToDisplay: widget.drink, 
                        userId: widget.userId, 
                        favBoolean: widget.favBoolean,
                        favDrink: widget.favDrink,
                        unfavDrink: widget.unfavDrink);
    return Container(
      child: compToDisplay,
    );
  }
}
