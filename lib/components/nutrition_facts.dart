import 'package:flutter/material.dart';

class NutritionFacts extends StatelessWidget {
  final Function switchComp;
  final dynamic drinkToDisplay;

  const NutritionFacts({
    super.key,
    required this.switchComp,
    required this.drinkToDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
            //Name of drink
            Center(
              child: Text(
                drinkToDisplay['Name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
                textAlign: TextAlign.center, //Centers within container
              ),
            ),
            const SizedBox(height: 16),
            _buildNutritionItem('Company:', drinkToDisplay['Company']),
            _buildNutritionItem('Style:', drinkToDisplay['Style']),
            _buildNutritionItem('ABV:', '${drinkToDisplay['ABV']}%'),
            _buildNutritionItem('Calories:', drinkToDisplay['Calories'].toString()),
            _buildNutritionItem('Origin:', drinkToDisplay['Origin']),
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

  Widget _buildNutritionItem(String header, String value) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              header,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 4.0), // Adjust the height value as needed
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
          },
          child: Text('Favorite'),
        ),
      );
    }
  }

  Widget _buildRateButton() {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          
        },
        child: Text('Rate'),
      ),
    );
  }

  Widget _buildBackButton(context) {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFA0522D), 
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
        child: Text('Back'),
      ),
    );
  }
