import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrinkOtdFacts extends StatefulWidget {
  final dynamic drinkToDisplay;
  final dynamic userId;
  final dynamic favBoolean;
  final Function favDrink;
  final Function unfavDrink;

  const DrinkOtdFacts({
    super.key,
    required this.drinkToDisplay,
    required this.userId,
    required this.favBoolean,
    required this.favDrink,
    required this.unfavDrink,
  });

  @override
  _DrinkFactsState createState() => _DrinkFactsState();
}

class _DrinkFactsState extends State<DrinkOtdFacts> {
  late bool favBoolean;

  @override
  void initState() {
    super.initState();
    favBoolean = widget.favBoolean;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.beerMugEmpty, color: Colors.brown),
                const SizedBox(width: 8), 
                Text(
                  widget.drinkToDisplay['Name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 8), 
                const FaIcon(FontAwesomeIcons.beerMugEmpty, color: Colors.brown),
              ],
            ),
            const SizedBox(height: 16),
            _buildDrinkItem('Company:', widget.drinkToDisplay['Company']),
            _buildDrinkItem('Style:', widget.drinkToDisplay['Style']),
            _buildDrinkItem('ABV:', '${widget.drinkToDisplay['ABV']}%'),
            _buildDrinkItem('Calories:', widget.drinkToDisplay['Calories'].toString()),
            _buildDrinkItem('Origin:', widget.drinkToDisplay['Origin']),
            const SizedBox(height: 16),
            _buildFavoriteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkItem(String header, String value) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              header,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4.0),
            Text(value),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      alignment: Alignment.center,
      child: IconButton(
        onPressed: () {
          if (favBoolean) {
            widget.unfavDrink();
            setState(() {
              favBoolean = false;
            });
          } else {
            widget.favDrink();
            setState(() {
              favBoolean = true;
            });
          }
        },
        icon: favBoolean ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
        iconSize: 72.0, 
        color: Colors.red, 
        padding: const EdgeInsets.all(0),
        constraints: const BoxConstraints(), 
        splashColor: Colors.transparent, 
        highlightColor: Colors.transparent, 
      ),
    );
  }
}
