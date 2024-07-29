import 'package:flutter/material.dart';

class SpecialDrinkFacts extends StatefulWidget {
  final dynamic drinkToDisplay;
  final dynamic userId;
  final dynamic favBoolean;
  final Function favDrink;
  final Function unfavDrink;

  const SpecialDrinkFacts({
    super.key,
    required this.drinkToDisplay,
    required this.userId,
    required this.favBoolean,
    required this.favDrink,
    required this.unfavDrink,
  });

  @override
  _SpecialDrinkFactsState createState() => _SpecialDrinkFactsState();
}

class _SpecialDrinkFactsState extends State<SpecialDrinkFacts> {
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
                Flexible(
                  child: Text(
                    widget.drinkToDisplay['Name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
