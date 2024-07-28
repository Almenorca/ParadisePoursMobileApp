// ignore_for_file: non_constant_identifier_names, avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paradise_pours_app/auth_service.dart';
import 'package:paradise_pours_app/components/display_dotd.dart';
import 'dart:convert';

import '../navigation_menu.dart';
import '../components/display_drink.dart';

class BeerPage extends StatefulWidget {
  const BeerPage({super.key});

  @override
  _BeerPageState createState() => _BeerPageState();
}

class _BeerPageState extends State<BeerPage> {
  bool showBeerList = false;

  void toggleBeerList() {
    setState(() {
      showBeerList = !showBeerList;
    });
  }

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
            'Beer',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.orange.withAlpha(150),
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
                  image: AssetImage('assets/images/Beer.jpeg'),
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
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        color: Colors.white.withAlpha(210),
                        elevation: 8.0,
                        child: showBeerList
                            ? BeerList(onBack: toggleBeerList) // Use BeerList widget here
                            : BeerOfTheDay(onExploreFullList: toggleBeerList),
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

class BeerList extends StatefulWidget {
  final VoidCallback onBack;
  const BeerList({required this.onBack, super.key});

  @override
  _BeerListState createState() => _BeerListState();
}

class _BeerListState extends State<BeerList> {
  final String app_name = 'paradise-pours-4be127640468';
  String buildPath(String route) {
    return 'https://$app_name.herokuapp.com/$route';
  }

  List<dynamic> beers = [];
  dynamic selectedBeer;
  bool showDisplayBeer = false;
  List<dynamic> searchResults = [];
  TextEditingController searchTextController = TextEditingController();
  bool validSearch = true;
  String filterSelection = '';
  List<dynamic> filteredBeers = [];

  int? _userId; //User Id. Used for favorite and rating
  bool favBoolean = false; //Used as a checker if user liked a beer. Will be used to passed down for favorite.
  int userRating = 0; //User rating
  int index = 0;
  double avgRating = 0; //Avg Ratings of drink
  List<Map<String, dynamic>> comments = []; //Comments of drink

  @override //Similar to useEffect()
  void initState() {
    super.initState();
    _loadUserData();
    fetchAllBeers();
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

  //Fetches all beer upon entering page.
  Future<void> fetchAllBeers() async {
    try {
      var response = await http.get(Uri.parse(buildPath('api/getAllBeers')));
      List<dynamic> beersData = json.decode(response.body)['beers'];
      beersData.sort((a, b) => a['Name'].compareTo(b['Name']));
      setState(() {
        beers = beersData;
      });
    } catch (error) {
      print('Error fetching all beers: $error');
    }
  }

  Future<void> loadBOTD(dynamic beer) async {
    setState(() {
      selectedBeer = beer;
    });

    await Future.wait([
      checkFav(selectedBeer),
      getRating(selectedBeer),
      getAvgRatings(selectedBeer),
      getComments(selectedBeer)
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
            drink: selectedBeer,
            userId: _userId,
            favBoolean: favBoolean,
            avgRating: avgRating,
            favDrink: favBeer,
            unfavDrink: unfavBeer,
            userRating: userRating,
            rateDrink: rateBeer,
            comments: comments,
            index: index,
          ),
        );
      },
    );
  }

  Future<void> checkFav(dynamic selectedBeer) async {
    print("original boolean = $favBoolean");
    List<dynamic> favorites = selectedBeer['Favorites'];
    print("$selectedBeer['Favorites']");
    setState(() {
      favBoolean = (favorites.contains(_userId.toString()));
    });
    print("new boolean = $favBoolean");
  }

  //Get User's rating
  Future<void> getRating(dynamic selectedBeer) async {
    try {
      var uri = Uri.parse(buildPath('api/userBeerRating')).replace(
          queryParameters: {
            'UserId': _userId.toString(),
            '_id': selectedBeer['_id']
          });
      var response = await http.get(uri, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          userRating = data['userRating'] as int;
          index = data['index'] as int;
        });
        print('Successfully retrieved user rating. userRating: $userRating');
      } else {
        setState(() {
          userRating = 0;
          index = 0;
        });
        print('User rating does not exist: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        userRating = 0;
        index = 0;
      });
      print('User rating does not exist: $error');
    }
  }

  //Get Avg ratings
  Future<void> getAvgRatings(dynamic selectedBeer) async {
    try {
      var uri = Uri.parse(buildPath('api/beerRatings')).replace(queryParameters: {'_id': selectedBeer['_id']});
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
  Future<void> getComments(dynamic selectedBeer) async {
    try {
      var uri = Uri.parse(buildPath('api/getBeerComments')).replace(queryParameters: {'_id': selectedBeer['_id']});
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

  //Unfavorites Beer
  void unfavBeer() async {
    try {
      var response = await http.post(Uri.parse(buildPath('api/unfavoriteBeer')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'UserId': _userId.toString(), //Needs to be converted to string because the userIds were stored as string in Favorites.
            '_id': selectedBeer['_id']
          }));
      if (response.statusCode == 200) {
        setState(() {
          favBoolean = false;
        });
        fetchAllBeers(); 
        print('Successfully unfavorited. favBoolean: $favBoolean');
      }
    } catch (error) {
      print('Error unfavoriting: $error');
    }
  }

  //Favorites Beer
  void favBeer() async {
    try {
      var response = await http.post(Uri.parse(buildPath('api/favoriteBeer')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'UserId': _userId.toString(),
            '_id': selectedBeer['_id']
          }));
      if (response.statusCode == 200) {
        setState(() {
          favBoolean = true;
        });
        fetchAllBeers(); 
        print('Successfully favorited. favBoolean: $favBoolean');
      }
    } catch (error) {
      print('Error favoriting: $error');
    }
  }

  //Rates Beer
  void rateBeer(rating, comment) async {
    try {
      var response = await http.post(Uri.parse(buildPath('api/rateBeer')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'UserId': _userId.toString(),
            '_id': selectedBeer['_id'],
            'Stars': rating,
            'Comment': comment,
          }));
      if (response.statusCode == 200) {
        fetchAllBeers(); 
        print('Successfully rated and commented');
      }
    } catch (error) {
      print('Error commenting: $error');
    }
  }

  //Searches beer via searchbar.
  void handleSearch() async {
    try {
      var response = await http.post(Uri.parse(buildPath('api/searchBeer')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'Name': searchTextController.text.trim()}));
      setState(() {
        validSearch = true;
        searchResults = json.decode(response.body)['beer'];
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
      showDisplayBeer = !showDisplayBeer;
    });
  }

  void applyFilter() {
    List<dynamic> filteredBeers = [];
    if (filterSelection == 'Favorites' && _userId != null) {
      filteredBeers = beers.where((beer) => beer['Favorites']?.contains(_userId.toString()) ?? false).toList();
    } else if (filterSelection == 'IPAs') {
      filteredBeers = beers.where((beer) => beer['Style'] == 'IPA' && beer['ABV'] >= 5.0).toList();
    } else if (filterSelection == 'Pilsner') {
      filteredBeers = beers.where((beer) => beer['Style'] == 'Pilsner').toList();
    } else if (filterSelection == 'Lager') {
      filteredBeers = beers.where((beer) => RegExp(r'Lager', caseSensitive: false).hasMatch(beer['Style'])).toList();
    } else if (filterSelection == 'Wheat') {
      filteredBeers = beers.where((beer) => RegExp(r'Wheat', caseSensitive: false).hasMatch(beer['Style'])).toList();
    } else if (filterSelection == 'Porter') {
      filteredBeers = beers.where((beer) => beer['Style'] == 'Porter').toList();
    } else if (filterSelection == 'Stout') {
      filteredBeers = beers.where((beer) => beer['Style'] == 'Stout').toList();
    } else if (filterSelection == 'Calories < 125') {
      filteredBeers = beers.where((beer) => beer['Calories'] < 125).toList();
    } else if (filterSelection == 'USA Origin') {
      filteredBeers = beers.where((beer) => beer['Origin'] == 'USA').toList();
    } else {
      filteredBeers = beers;
    }
    setState(() {
      validSearch = true;
      searchResults = filteredBeers;
      showDisplayBeer = false;
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
      showDisplayBeer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack, 
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Text('Beer List', style: TextStyle(fontSize: 24)),
            ),
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
        //Filter Menu
        Container(
          padding: const EdgeInsets.all(10),
          child: DropdownButton<String>(
            value: filterSelection,
            onChanged: handleFilterChange,
            items: <String>[
              '',
              'Favorites',
              'IPAs',
              'Pilsner',
              'Lager',
              'Wheat',
              'Porter',
              'Stout',
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
        //Beer List
        Container(
          padding: const EdgeInsets.all(10),
          child: validSearch
              ? (searchResults.isEmpty
                  ? (beers.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: beers.length,
                          itemBuilder: (context, index) {
                            var beer = beers[index];
                            return ListTile(
                              title: Text(beer['Name']),
                              onTap: () => loadBOTD(beer),
                            );
                          },
                        ))
                  //Search Bar
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        var beer = searchResults[index];
                        return ListTile(
                          title: Text(beer['Name']),
                          onTap: () => loadBOTD(beer),
                        );
                      },
                    ))
              : Column(
                  children: <Widget>[
                    const Text('No beers matched with the criteria'),
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

class BeerOfTheDay extends StatefulWidget {
  final VoidCallback onExploreFullList;

  const BeerOfTheDay({required this.onExploreFullList, super.key});

  @override
  _BeerOfTheDayState createState() => _BeerOfTheDayState();
}

class _BeerOfTheDayState extends State<BeerOfTheDay> {
  final String app_name = 'paradise-pours-4be127640468';
  String buildPath(String route) {
    return 'https://$app_name.herokuapp.com/$route';
  }

  dynamic beerOfTheDay;
  bool isLoading = true;
  dynamic selectedBeer;
  int? _userId; 
  bool favBoolean = false; 

  @override
  void initState() {
    super.initState();
    fetchBeerOfTheDay();
  }

  Future<void> fetchBeerOfTheDay() async {
    final authService = AuthService();
    dynamic storedBeer = await authService.getBeerOfTheDay();

    if (storedBeer != null) {
      setState(() {
        beerOfTheDay = storedBeer;
        isLoading = false;
      });
      await loadBOTD(storedBeer);
    } else {
      try {
        var response = await http.post(Uri.parse(buildPath('api/searchBeer')),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'Name': ''}));
        List<dynamic> beers = json.decode(response.body)['beer'];
        beers.shuffle();
        if (beers.isNotEmpty) {
          selectedBeer = beers.first;
          await loadBOTD(selectedBeer);
          await authService.saveBeerOfTheDay(selectedBeer);
        }
        setState(() {
          beerOfTheDay = beers.isNotEmpty ? beers.first : null;
          isLoading = false;
        });
      } catch (error) {
        print('Error fetching beer of the day: $error');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  //Unfavorites Beer
  void unfavBOTDBeer() async {
    try {
      var response = await http.post(Uri.parse(buildPath('api/unfavoriteBeer')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'UserId': _userId.toString(), //Needs to be converted to string because the userIds were stored as string in Favorites.
            '_id': selectedBeer['_id']
          }));
      if (response.statusCode == 200) {
        setState(() {
          favBoolean = false;
        });
        fetchBeerOfTheDay(); 
        print('Successfully unfavorited. favBOTDBoolean: $favBoolean');
      }
    } catch (error) {
      print('Error unfavoriting: $error');
    }
  }

  //Favorites Beer
  void favBOTDBeer() async {
    try {
      var response = await http.post(Uri.parse(buildPath('api/favoriteBeer')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'UserId': _userId.toString(),
            '_id': selectedBeer['_id']
          }));
      if (response.statusCode == 200) {
        setState(() {
          favBoolean = true;
        });
        fetchBeerOfTheDay(); 
        print('Successfully favorited. favBOTDBoolean: $favBoolean');
      }
    } catch (error) {
      print('Error favoriting: $error');
    }
  }

  Future<void> loadBOTD(dynamic beer) async {
    setState(() {
      selectedBeer = beer;
    });

    await Future.wait([
      checkBOTDFav(selectedBeer),
    ]);
  }

  Future<void> checkBOTDFav(dynamic selectedBeer) async {
    List<dynamic> favorites = selectedBeer['Favorites'];
    setState(() {
      favBoolean = (favorites.contains(_userId.toString()));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (beerOfTheDay != null)
          DrinkOtdDrink(
            drink: beerOfTheDay,
            userId: _userId,
            favBoolean: favBoolean,
            favDrink: favBOTDBeer,
            unfavDrink: unfavBOTDBeer,
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0), // Add bottom padding
          child: ElevatedButton(
            onPressed: widget.onExploreFullList,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA0522D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Explore our full beer selection'),
          ),
        ),
      ],
    );
  } 
}
