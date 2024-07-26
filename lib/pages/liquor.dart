import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paradise_pours_app/auth_service.dart';
import 'dart:convert';

import '../navigation_menu.dart';
import '../components/display_drink.dart';

class LiquorPage extends StatelessWidget {
  const LiquorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Liquor',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepOrange.withAlpha(150),
          foregroundColor: Colors.white,
          leading: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/Paradise_Pours_Logo.png')),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/LiquorBackground2Enhanced.jpg'),
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
            // Scrollable content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                      height: MediaQuery.of(context).padding.top +
                          kToolbarHeight), // Match app bar height
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Card(
                        color: Colors.white.withAlpha(210),
                        elevation: 8.0,
                        child: LiquorList(), // Use LiquorList widget here
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        endDrawer: const NavigationMenu(),
      ),
    );
  }
}

class LiquorList extends StatefulWidget {
  const LiquorList({super.key});

  @override
  _LiquorPageState createState() => _LiquorPageState();
}

class _LiquorPageState extends State<LiquorList> {
  final String app_name = 'paradise-pours-4be127640468';
  String buildPath(String route) {
      return 'https://$app_name.herokuapp.com/$route';
  }

  // UserContext userContext;
  List<dynamic> liquors = [];
  dynamic selectedLiquor;
  bool showDisplayLiquor = false;
  List<dynamic> searchResults = [];
  TextEditingController searchTextController = TextEditingController();
  bool validSearch = true;
  String filterSelection = '';
  List<dynamic> filteredLiquors = [];

  int? _userId; //User Id. Used for favorite and rating
  bool favBoolean = false; //Used as a checker if user liked a liquor. Will be used to passed down for favorite.
  int userRating = 0; //User rating
  double avgRating = 0; //Avg Ratings of drink
  List<Map<String, dynamic>> comments = []; //Comments of drink

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchAllLiquors();
  }

  //Initializes user id.
  Future<void> _loadUserData() async {
    final authService = AuthService();
    final user = await authService.getUser();
    if (user != null) {
      setState(() {
        _userId = user.userId;
      });
    }
  }

  //Fetches all liquor upon entering page.
  Future<void> fetchAllLiquors() async {
    try {
      var response = await http.get(Uri.parse(buildPath('api/getAllLiquors')));
      List<dynamic> liquorsData = json.decode(response.body)['liquors'];
      liquorsData.sort((a, b) => a['Name'].compareTo(b['Name']));
      setState(() {
        liquors = liquorsData;
      });
    } catch (error) {
      print('Error fetching all Liquors: $error');
    }
  }

  void handleLiquorClick(dynamic liquor) async{
    setState(() {
      selectedLiquor = liquor;
    });

    await Future.wait([
      checkFav(selectedLiquor),
      getRating(selectedLiquor),
      getAvgRatings(selectedLiquor),
      getComments(selectedLiquor)
    ]);

    // Show dialog after all async operations are complete
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: DisplayDrink(
            drink: selectedLiquor,
            userId: _userId,
            favBoolean: favBoolean,
            avgRating: avgRating,
            favDrink: favLiquor,
            unfavDrink: unfavLiquor,
            userRating: userRating,
            rateDrink: rateLiquor,
            comments: comments,
          ),
        );
      },
    );
  }

Future<void> checkFav(dynamic selectedLiquor) async {
  print("original boolean = $favBoolean");
  List<dynamic> favorites = selectedLiquor['Favorites'];
  print("$selectedLiquor['Favorites']");
  setState(() {
    favBoolean = (favorites.contains(_userId.toString()));
  });
  print("new boolean = $favBoolean");
}

//Get User's rating
Future<void> getRating(dynamic selectedLiquor) async {
  try {
    var uri = Uri.parse(buildPath('api/userRating')).
    replace(queryParameters: {'UserId': _userId, 
                              '_id': selectedLiquor['_id']});
    var response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        userRating = data['userRating'];
      });
      print('Successfully retrieved user rating. userRating: $userRating');
    }
  } catch (error) {
    print('Error getting ratings: $error');
  }
}

//Get Avg ratings
Future<void> getAvgRatings(dynamic selectedLiquor) async {
  try {
    var uri = Uri.parse(buildPath('api/liquorRatings')).replace(queryParameters: {'_id': selectedLiquor['_id']});
    var response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        avgRating = data['avgRating'];
      });
      print('Successfully retrieved average ratings. avgRating: $avgRating');
    }
  } catch (error) {
    print('Error getting ratings: $error');
  }
}

//Get users comments
Future<void> getComments(dynamic selectedLiquor) async {
  try {
    var uri = Uri.parse(buildPath('api/getLiquorComments')).replace(queryParameters: {'_id': selectedLiquor['_id']});
    var response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        comments = List<Map<String, dynamic>>.from(data['comments']);
      });
      print('Successfully retrieved comments. comments: $comments');
    }
  } catch (error) {
    print('Error getting comments: $error');
  }
}
  //Unfavorites Liquor
  void unfavLiquor() async {
    try {
      var response = await http.post(Uri.parse(buildPath('api/unfavoriteLiquor')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'UserId': _userId.toString(), //Needs to be converted to string because the userIds were stored as string in Favorites.
                              '_id': selectedLiquor['_id']}));
      if (response.statusCode == 200) {
        setState(() {
          favBoolean = false;
        });
        fetchAllLiquors(); //Call function to refresh liquor list to show that Favorites has been edited.
      print('Successfully unfavorited. favBoolean: $favBoolean');
      }
    } 
    catch (error) {
      print('Error unfavoriting: $error');
    }
  }

  //Favorites Liquor
  void favLiquor() async {
      try {
      var response = await http.post(Uri.parse(buildPath('api/favoriteLiquor')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'UserId': _userId.toString(),
                            '_id': selectedLiquor['_id']}));
      if (response.statusCode == 200) {
        setState(() {
          favBoolean = true;
        });
        fetchAllLiquors(); //Call function to refresh liquor list to show that Favorites has been edited.
        print('Successfully favorited. favBoolean: $favBoolean');
      }
    } 
    catch (error) {
      print('Error favoriting: $error');
    } 
  }

  //Rates Liquor
    void rateLiquor(rating, comment) async {
      try {
      var response = await http.post(Uri.parse(buildPath('api/rateLiquor')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'UserId': _userId.toString(),
                            '_id': selectedLiquor['_id'],
                            'Stars': rating,
                            'Comment': comment,}));
      if (response.statusCode == 200) {
        fetchAllLiquors(); //Call function to refresh liquor list to show that Favorites has been edited.
        print('Successfully rated and commented');
      }
    } 
    catch (error) {
      print('Error commenting: $error');
    } 
  }

  //Searches liquor via searchbar.
  void handleSearch() async {
    try {
      var response = await http.post(Uri.parse(buildPath('api/searchLiquor')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'Name': searchTextController.text.trim()}));
      setState(() {
        validSearch = true;
        searchResults = json.decode(response.body)['liquor'];
        searchTextController.clear();
      });
    } catch (error) {
      setState(() {
        validSearch = false;
        searchTextController.clear();
      });
      print('Error handling search: $error');
    }
  }

  void handleSearchBackButton() {
    setState(() {
      searchResults.clear();
      validSearch = true;
      showDisplayLiquor = !showDisplayLiquor;
    });
  }

  void applyFilter() {
    List<dynamic> filteredLiquors = [];
    if (filterSelection == 'Favorites' && _userId != null) {
      filteredLiquors = liquors.where((liquor) => liquor['Favorites']?.contains(_userId.toString()) ?? false).toList();
    } else if (filterSelection == 'Whiskey and Scotch') {
      filteredLiquors = liquors.where((liquor) => liquor['Style'] == 'Whiskey' || liquor['Style'] == 'Scotch').toList();
    } else if (filterSelection == 'Vodka') {
      filteredLiquors = liquors.where((liquor) => liquor['Style'] == 'Vodka').toList();
    }  else if (filterSelection == 'Rum') {
      filteredLiquors = liquors.where((liquor) => liquor['Style'] == 'Rum').toList();
    } else if (filterSelection == 'Gin') {
      filteredLiquors = liquors.where((liquor) => liquor['Style'] == 'Gin').toList();
    } else if (filterSelection == 'Tequila') {
      filteredLiquors = liquors.where((liquor) => liquor['Style'] == 'Tequila').toList();
    } else if (filterSelection == 'Brandy and Cognac') {
      filteredLiquors = liquors.where((liquor) => liquor['Style'] == 'Brandy' || liquor['Style'] == 'Cognac').toList();
    } else {
      filteredLiquors = liquors;
    }
    setState(() {
      validSearch = true;
      searchResults = filteredLiquors;
      showDisplayLiquor = false;
    });
  }

  void handleFilterChange(String? selection) {
    setState(() {
      filterSelection = selection ?? ''; // handle null case if needed
    });
    applyFilter();
  }

  void handleClearFilter() {
    setState(() {
      filterSelection = '';
      searchResults = [];
      validSearch = true;
      showDisplayLiquor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Image.asset('assets/images/Liquor-glass-left.png'),
              Text('Liquor List', style: TextStyle(fontSize: 24)),
              // Image.asset('assets/images/Liquor-glass-right.png'),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: searchTextController,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: handleSearch,
              ),
            ],
          ),
        ),
        //Dropdown Menu
        Container(
          padding: const EdgeInsets.all(10),
          child: DropdownButton<String>(
            value: filterSelection,
            onChanged: handleFilterChange,
            items: <String>[
              '',
              'Favorites',
              'Whiskey and Scotch',
              'Vodka',
              'Rum',
              'Gin',
              'Tequila',
              'Brandy and Cognac',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.isEmpty ? 'Filter' : value),
              );
            }).toList(),
          ),
        ),
        //Liquor List
        Container(
          padding: const EdgeInsets.all(10),
          child: validSearch
              ? (searchResults.isEmpty
                  ? (liquors.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: liquors.length,
                          itemBuilder: (context, index) {
                            var liquor = liquors[index];
                            return ListTile(
                              title: Text(liquor['Name']),
                              onTap: () => handleLiquorClick(liquor),
                            );
                          },
                        ))
                  //Search Bar
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        var liquor = searchResults[index];
                        return ListTile(
                          title: Text(liquor['Name']),
                          onTap: () => handleLiquorClick(liquor),
                        );
                      },
                    ))
              : Column(
                  children: <Widget>[
                    const Text('No Liquors matched with the criteria'),
                    TextButton.icon(
                      label: const Text('Clear'),
                      icon: const Icon(Icons.arrow_left),
                      onPressed: handleSearchBackButton,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
