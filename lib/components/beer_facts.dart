import 'package:flutter/material.dart';

class BeerFacts extends StatefulWidget {
  final Function switchComp;
  final dynamic drinkToDisplay;
  final dynamic userId;
  final dynamic favBoolean;
  final Function favBeer;
  final Function unfavBeer;

  const BeerFacts({
    super.key,
    required this.switchComp,
    required this.drinkToDisplay,
    required this.userId,
    required this.favBoolean,
    required this.favBeer,
    required this.unfavBeer,
  });

  @override
  _BeerFactsState createState() => _BeerFactsState();
}

class _BeerFactsState extends State<BeerFacts> {
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
            Center(
              child: Text(
                widget.drinkToDisplay['Name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            _buildBeerItem('Company:', widget.drinkToDisplay['Company']),
            _buildBeerItem('Style:', widget.drinkToDisplay['Style']),
            _buildBeerItem('ABV:', '${widget.drinkToDisplay['ABV']}%'),
            _buildBeerItem('Calories:', widget.drinkToDisplay['Calories'].toString()),
            _buildBeerItem('Origin:', widget.drinkToDisplay['Origin']),
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

  Widget _buildBeerItem(String header, String value) {
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
      child: ElevatedButton(
        onPressed: () {
          if (favBoolean) {
            widget.unfavBeer();
            setState(() {
              favBoolean = false;
            });
          } else {
            widget.favBeer();
            setState(() {
              favBoolean = true;
            });
          }
        },
        child: favBoolean ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
      ),
    );
  }

  Widget _buildRateButton() {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Rate'),
      ),
    );
  }

  Widget _buildBackButton(context) {
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
