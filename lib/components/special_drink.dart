// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'special_drink_facts.dart';

class SpecialDrink extends StatefulWidget {
  final dynamic drink;
  final dynamic userId;
  //Favorite Features
  final dynamic favBoolean;
  final Function favDrink;
  final Function unfavDrink;  

  const SpecialDrink(
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

class _DisplayDrinkState extends State<SpecialDrink> {
  bool showRatings = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget compToDisplay =  SpecialDrinkFacts(
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
