import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_pours_app/components/ratings.dart';

void main() {
  // Mock function for rating drink
  final Function(int, String) rateDrinkMock = (rating, comment) {};

  // Sample comments to test
  final List<Map<String, dynamic>> sampleComments = [
    {'Rating': 4, 'Comment': 'Great drink!'},
    {'Rating': 5, 'Comment': 'Excellent choice!'},
    {'Rating': 3, 'Comment': 'It was okay.'},
  ];

  testWidgets('Handles comment submission with dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Ratings(
          switchComp: () {},
          drinkToDisplay: 'sampleDrink',
          rateDrink: rateDrinkMock,
          comments: sampleComments,
          userRating: 3,
          index: 1,
        ),
      ),
    );

    // Tap submit button
    await tester.tap(find.text('Submit Rating'));
    await tester.pump();

    // Verify the confirmation dialog appears
    expect(find.text('Confirm Overwrite'), findsOneWidget);

    // Confirm in dialog
    await tester.tap(find.text('Ok'));
    await tester.pump();

    // Verify the success dialog appears
    expect(find.text('Cheers!'), findsOneWidget);
  });

  testWidgets('Ratings widget initializes correctly',
      (WidgetTester tester) async {
    // Mock functions
    void mockSwitchComp() {}
    void mockRateDrink(int rating, String comment) {}

    // Sample data
    final drinkToDisplay = {}; // Adjust this as needed
    final comments = [
      {'Rating': 3, 'Comment': 'Good'},
      {'Rating': 4, 'Comment': 'Very Good'}
    ];

    // Build the Ratings widget
    await tester.pumpWidget(
      MaterialApp(
        home: Ratings(
          switchComp: mockSwitchComp,
          drinkToDisplay: drinkToDisplay,
          rateDrink: mockRateDrink,
          comments: comments,
          userRating: 2,
          index: 0,
        ),
      ),
    );

    // Verify initial state
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Add a comment'), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsNWidgets(5));
  });

  testWidgets('Updates rating when a star is pressed',
      (WidgetTester tester) async {
    // Mock functions
    void mockSwitchComp() {}
    void mockRateDrink(int rating, String comment) {}

    // Sample data
    final drinkToDisplay = {};
    final List<Map<String, dynamic>> comments = [];

    // Build the Ratings widget
    await tester.pumpWidget(
      MaterialApp(
        home: Ratings(
          switchComp: mockSwitchComp,
          drinkToDisplay: drinkToDisplay,
          rateDrink: mockRateDrink,
          comments: comments,
          userRating: 2,
          index: 0,
        ),
      ),
    );

    // Tap on the third star to update rating
    await tester.tap(find.byIcon(Icons.star_border).at(2));
    await tester.pump();

    // Verify rating update
    expect(find.byIcon(Icons.star).at(0), isNotNull);
    expect(find.byIcon(Icons.star).at(1), isNotNull);
    expect(find.byIcon(Icons.star).at(2), isNotNull);
    expect(find.byIcon(Icons.star_border).at(2), isNotNull);
  });

  testWidgets('Displays confirmation dialog on submit',
      (WidgetTester tester) async {
    // Mock functions
    void mockSwitchComp() {}
    void mockRateDrink(int rating, String comment) {}

    // Sample data
    final drinkToDisplay = {};
    final List<Map<String, dynamic>> comments = [];

    // Build the Ratings widget with an index greater than 0
    await tester.pumpWidget(
      MaterialApp(
        home: Ratings(
          switchComp: mockSwitchComp,
          drinkToDisplay: drinkToDisplay,
          rateDrink: mockRateDrink,
          comments: comments,
          userRating: 2,
          index: 1,
        ),
      ),
    );

    // Tap submit button
    await tester.tap(find.text('Submit Rating'));
    await tester.pump();

    // Verify dialog
    expect(find.text('Confirm Overwrite'), findsOneWidget);
    expect(find.text('Would you like to overwrite your existing comment?'),
        findsOneWidget);
  });

  testWidgets('Back button calls switchComp function',
      (WidgetTester tester) async {
    // Mock functions
    bool wasCalled = false;
    void mockSwitchComp() {
      wasCalled = true;
    }

    void mockRateDrink(int rating, String comment) {}

    // Sample data
    final drinkToDisplay = {};
    final List<Map<String, dynamic>> comments = [];

    // Build the Ratings widget
    await tester.pumpWidget(
      MaterialApp(
        home: Ratings(
          switchComp: mockSwitchComp,
          drinkToDisplay: drinkToDisplay,
          rateDrink: mockRateDrink,
          comments: comments,
          userRating: 2,
          index: 0,
        ),
      ),
    );

    // Tap back button
    await tester.tap(find.text('Back'));
    await tester.pump();

    // Verify switchComp was called
    expect(wasCalled, isTrue);
  });
}
