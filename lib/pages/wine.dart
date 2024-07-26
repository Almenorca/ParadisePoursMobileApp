import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paradise_pours_app/auth_service.dart';
import 'dart:convert';

import '../navigation_menu.dart';
import '../components/display_drink.dart';

class WinePage extends StatelessWidget {
  const WinePage({super.key});

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
            'Wine',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.redAccent.withAlpha(150),
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
                  image: AssetImage('assets/images/wine1.jpg'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
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
                        child: WineList(), // Use WineList widget here
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

class WineList extends StatefulWidget {
  const WineList({super.key});

  @override
  _WinePageState createState() => _WinePageState();
}

class _WinePageState extends State<WineList> {
  final String app_name = 'paradise-pours-4be127640468';
  String buildPath(String route) {
      return 'https://$app_name.herokuapp.com/$route';
  }

  // UserContext userContext;
  List<dynamic> wines = [];
  dynamic selectedWine;
  bool showDisplayWine = false;
  List<dynamic> searchResults = [];
  TextEditingController searchTextController = TextEditingController();
  bool validSearch = true;
  String filterSelection = '';
  List<dynamic> filteredWines = [];

  int? _userId; //User Id. Used for favorite and rating
  bool favBoolean = false; //Used as a checker if user liked a beer. Will be used to passed down for favorite.
  int userRating = 0; //User rating
  double avgRating = 0; //Avg Ratings of drink
  List<Map<String, dynamic>> comments = []; //Comments of drink

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchAllWines();
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

  //Fetches all wine upon entering page.
  Future<void> fetchAllWines() async {
    try {
      var response = await http.get(Uri.parse(buildPath('api/getAllWines')));
      List<dynamic> winesData = json.decode(response.body)['wines'];
      winesData.sort((a, b) => a['Name'].compareTo(b['Name']));
      setState(() {
        wines = winesData;
      });
    } catch (error) {
      print('Error fetching all wines: $error');
    }
  }

  void handleWineClick(dynamic wine) async{
    setState(() {
      selectedWine = wine;
    });

    await Future.wait([
      checkFav(selectedWine),
      getRating(selectedWine),
      getAvgRatings(selectedWine),
      getComments(selectedWine)
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
            drink: selectedWine,
            userId: _userId,
            favBoolean: favBoolean,
            avgRating: avgRating,
            favDrink: favWine,
            unfavDrink: unfavWine,
            userRating: userRating,
            rateDrink: rateWine,
            comments: comments,
          ),
        );
      },
    );
  }

  Future<void> checkFav(dynamic selectedBeer) async {
    print("original boolean = $favBoolean");
    List<dynamic> favorites = selectedWine['Favorites'];
    print("$selectedWine['Favorites']");
    setState(() {
      favBoolean = (favorites.contains(_userId.toString()));
    });
    print("new boolean = $favBoolean");
  }

  //Get User's rating
  Future<void> getRating(dynamic selectedWine) async {
    try {
      var uri = Uri.parse(buildPath('api/userRating')).
      replace(queryParameters: {'UserId': _userId, 
                                '_id': selectedWine['_id']});
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
  Future<void> getAvgRatings(dynamic selectedWine) async {
    try {
      var uri = Uri.parse(buildPath('api/wineRatings')).replace(queryParameters: {'_id': selectedWine['_id']});
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
  Future<void> getComments(dynamic selectedWine) async {
    try {
      var uri = Uri.parse(buildPath('api/getWineComments')).replace(queryParameters: {'_id': selectedWine['_id']});
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

  //Unfavorites Wine
  void unfavWine() async {
    try {
      var response = await http.post(Uri.parse(buildPath('api/unfavoriteWine')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'UserId': _userId.toString(), //Needs to be converted to string because the userIds were stored as string in Favorites.
                              '_id': selectedWine['_id']}));
      if (response.statusCode == 200) {
        setState(() {
          favBoolean = false;
        });
        fetchAllWines(); //Call function to refresh wine list to show that Favorites has been edited.
      print('Successfully unfavorited. favBoolean: $favBoolean');
      }
    } 
    catch (error) {
      print('Error unfavoriting: $error');
    }
  }

  //Favorites Wine
  void favWine() async {
      try {
      var response = await http.post(Uri.parse(buildPath('api/favoriteWine')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'UserId': _userId.toString(),
                            '_id': selectedWine['_id']}));
      if (response.statusCode == 200) {
        setState(() {
          favBoolean = true;
        });
        fetchAllWines(); //Call function to refresh wine list to show that Favorites has been edited.
        print('Successfully favorited. favBoolean: $favBoolean');
      }
    } 
    catch (error) {
      print('Error favoriting: $error');
    } 
  }

  //Rates Wine
    void rateWine(rating, comment) async {
      try {
      var response = await http.post(Uri.parse(buildPath('api/rateWine')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'UserId': _userId.toString(),
                            '_id': selectedWine['_id'],
                            'Stars': rating,
                            'Comment': comment,}));
      if (response.statusCode == 200) {
        fetchAllWines(); //Call function to refresh wine list to show that Favorites has been edited.
        print('Successfully rated and commented');
      }
    } 
    catch (error) {
      print('Error commenting: $error');
    } 
  }

  //Searches wine via searchbar.
  void handleSearch() async {
    try {
      var response = await http.post(Uri.parse(buildPath('api/searchWine')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'Name': searchTextController.text.trim()}));
      setState(() {
        validSearch = true;
        searchResults = json.decode(response.body)['wine'];
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
      showDisplayWine = !showDisplayWine;
    });
  }

  void applyFilter() {
    List<dynamic> filteredWines = [];
    if (filterSelection == 'Favorites' && _userId != null) {
      filteredWines = wines.where((wine) => wine['Favorites']?.contains(_userId.toString()) ?? false).toList();
    } else if (filterSelection == 'Red') {
      filteredWines = wines.where((wine) => wine['Style'] == 'Red').toList();
    } else if (filterSelection == 'White') {
      filteredWines = wines.where((wine) => wine['Style'] == 'White').toList();
    } else if (filterSelection == 'Sparkling') {
      filteredWines = wines.where((wine) => wine['Style'] == 'Sparkling').toList();
    } else if (filterSelection == 'Calories < 125') {
      filteredWines = wines.where((wine) => wine['Calories'] < 125).toList();
    } else if (filterSelection == 'USA Origin') {
      filteredWines = wines.where((wine) => wine['Origin'] == 'USA').toList();
    } else {
      filteredWines = wines;
    }
    setState(() {
      validSearch = true;
      searchResults = filteredWines;
      showDisplayWine = false;
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
      showDisplayWine = false;
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
              Text('Wine List', style: TextStyle(fontSize: 24)),
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
        Container(
          padding: const EdgeInsets.all(10),
          child: DropdownButton<String>(
            value: filterSelection,
            onChanged: handleFilterChange,
            items: <String>[
              '',
              'Favorites',
              'Red',
              'White',
              'Sparkling',
              'Calories < 125',
              'USA Origin',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.isEmpty ? 'Filter' : value),
              );
            }).toList(),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: validSearch
              ? (searchResults.isEmpty
                  ? (wines.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: wines.length,
                          itemBuilder: (context, index) {
                            var wine = wines[index];
                            return ListTile(
                              title: Text(wine['Name']),
                              onTap: () => handleWineClick(wine),
                            );
                          },
                        ))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        var wine = searchResults[index];
                        return ListTile(
                          title: Text(wine['Name']),
                          onTap: () => handleWineClick(wine),
                        );
                      },
                    ))
              : Column(
                  children: <Widget>[
                    const Text('No Wines matched with the criteria'),
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
