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
            Center(
              child: ElevatedButton(
                onPressed: () => switchComp(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Rate Beer'),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String header, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$header ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: () {
        },
        child: Text('Favorite'),
      ),
    );
  }
}
