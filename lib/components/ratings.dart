import 'package:flutter/material.dart';

class Ratings extends StatefulWidget {
  final Function switchComp;
  final dynamic drinkToDisplay;
  final Function(int, String) rateDrink; 
  final List<Map<String, dynamic>> comments;

  const Ratings({
    super.key,
    required this.switchComp,
    required this.drinkToDisplay,
    required this.rateDrink,
    required this.comments,
  });

  @override
  _RatingsState createState() => _RatingsState();
}

class _RatingsState extends State<Ratings> {
  int _rating = 0; // Initial rating if user never rated the drink.
  final TextEditingController commentController = TextEditingController();
  String feedbackMessage = '';

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
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36.0,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            // Comment textbox
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Add a comment',
                hintText: 'Type your comment here...',
              ),
              maxLines: 4, 
            ),
            const SizedBox(height: 16),
            // Submit button
            _buildSubmitButton(),
            const SizedBox(height: 16),
            // Back button
            _buildBackButton(context),
          ],
        ),
      ),
    );
  }

    void _handleSubmit() {
    widget.rateDrink(_rating, commentController.text);
    setState(() {
      feedbackMessage = 'Rating and comment submitted successfully!';
    });
  }
    Widget _buildSubmitButton() {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        child: const Text('Submit Rating'),
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
          widget.switchComp();
        },
        child: const Text('Back'),
      ),
    );
  }
}
