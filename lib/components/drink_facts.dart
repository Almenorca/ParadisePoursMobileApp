import 'package:flutter/material.dart';

class DrinkFacts extends StatefulWidget {
  final Function switchComp;
  final dynamic drinkToDisplay;
  final dynamic userId;
  final dynamic favBoolean;
  final Function favDrink;
  final Function unfavDrink;
  final double? avgRating; // Updated to double? to handle null values

  const DrinkFacts({
    super.key,
    required this.switchComp,
    required this.drinkToDisplay,
    required this.userId,
    required this.favBoolean,
    required this.favDrink,
    required this.unfavDrink,
    required this.avgRating,
  });

  @override
  _DrinkFactsState createState() => _DrinkFactsState();
}

class _DrinkFactsState extends State<DrinkFacts> {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name of drink
            Flexible(
              child: Text(
                widget.drinkToDisplay['Name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            // Display the average rating as stars
            _buildStarRating(widget.avgRating),
            const SizedBox(height: 16),
            _buildDrinkItem('Company:', widget.drinkToDisplay['Company']),
            _buildDrinkItem('Style:', widget.drinkToDisplay['Style']),
            _buildDrinkItem('ABV:', '${widget.drinkToDisplay['ABV']}%'),
            _buildDrinkItem('Calories:', widget.drinkToDisplay['Calories'].toString()),
            _buildDrinkItem('Origin:', widget.drinkToDisplay['Origin']),
            const SizedBox(height: 16),
            _buildFavoriteButton(),
            const SizedBox(height: 16),
            _buildRateButton(),
            const SizedBox(height: 16),
            _buildBackButton(context),
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

  Widget _buildStarRating(double? rating) {
    // Provide a default value of 0 if rating is null
    double safeRating = rating ?? 0.0;

    int fullStars = safeRating.floor();
    double fractionalStar = safeRating - fullStars;

    List<Widget> stars = List.generate(5, (index) {
      if (index < fullStars) {
        return const Icon(Icons.star, color: Colors.yellow, size: 32.0);
      } else if (index == fullStars && fractionalStar > 0) {
        return const Icon(Icons.star_half, color: Colors.yellow, size: 32.0);
      } else {
        return const Icon(Icons.star_border, color: Colors.yellow, size: 32.0);
      }
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: stars,
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

  Widget _buildRateButton() {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          widget.switchComp();
        },
        child: const Text('Rate'),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA0522D),
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Back'),
      ),
    );
  }
}
