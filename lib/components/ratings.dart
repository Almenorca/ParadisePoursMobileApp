// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, avoid_print, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';

class Ratings extends StatefulWidget {
  final Function switchComp;
  final dynamic drinkToDisplay;
  final Function(int, String) rateDrink; 
  final List<Map<String, dynamic>> comments;
  final int userRating;
  final int index;

  const Ratings({
    super.key,
    required this.switchComp,
    required this.drinkToDisplay,
    required this.rateDrink,
    required this.comments,
    required this.userRating,
    required this.index,
  });

  @override
  _RatingsState createState() => _RatingsState();
}

class _RatingsState extends State<Ratings> {
  late int _rating; // Initial rating if user never rated the drink.
  late int _index;
  late int flag;
  late TextEditingController commentController = TextEditingController();
  PageController _pageController = PageController();
  
  @override
  void initState() {
    super.initState();
    _rating = widget.userRating;
    _index = widget.index;
    _pageController = PageController(initialPage: _index);
  
    if(widget.index > 0){ //Used to flag if user already commented.
      flag = 1;
      print(flag);
    }
    else{
      flag = 0;
      print(flag);
    }
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of the PageController when not needed
    super.dispose();
  }


  void _handleSubmit() {
  if (flag == 1) { //Confirmation popup if user has an existing comment for the drink.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Overwrite'),
          content: Text('Would you like to overwrite your existing comment?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitRating();
              },
              child: Text('Ok'),
              style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFA0522D),
              foregroundColor: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
              style: ElevatedButton.styleFrom(
              ),
            ),
          ],
        );
      },
    );
  }
    else{
      _submitRating();
    }

  }

  void _submitRating(){
    widget.rateDrink(_rating, commentController.text);
    //Tells user they successfully submitted and takes them back to beer list.
    //Tbh the reason this exists because I was struggling to refresh avgRating and comments after submission. 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cheers!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('assets/images/beer-mugs-right.png'),
              SizedBox(height: 16),
              Text('Rating and comment submitted successfully!'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); //Closes alert
                Navigator.of(context).pop(); //Exists back to drink list
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Comment navigation
                Container(
                  height: 250, 
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Comment navigation
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.comments.length,
                        itemBuilder: (context, index) {
                          final rating = widget.comments[index]['Rating'];
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Display rating as stars
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 32.0,
                                    );
                                  }),
                                ),
                                SizedBox(height: 12),
                                // Display comment
                                Text(
                                  widget.comments[index]['Comment'] ?? 'No comment',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                        onPageChanged: (index) {
                        },
                      ),
                    ],
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
                _buildSubmitButton(context),
                const SizedBox(height: 16),
                // Back button
                _buildBackButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          _handleSubmit();
        },
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
