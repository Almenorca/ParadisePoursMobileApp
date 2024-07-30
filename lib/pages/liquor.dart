// ignore_for_file: avoid_print, library_private_types_in_public_api, non_constant_identifier_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paradise_pours_app/auth_service.dart';
import 'package:paradise_pours_app/components/special_drink.dart';
import 'dart:convert';

import '../navigation_menu.dart';
import '../components/display_drink.dart';

class LiquorPage extends StatefulWidget {
  const LiquorPage({super.key});

  @override
  _LiquorPageState createState() => _LiquorPageState();
}

class _LiquorPageState extends State<LiquorPage> {
  bool showLiquorList = false;

  void toggleLiquorList() {
    setState(() {
      showLiquorList = !showLiquorList;
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
            'Liquor',
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
                  image: AssetImage('assets/images/LiquorBackground2Enhanced.jpg'),
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
                        child: showLiquorList
                            ? LiquorList(onBack: toggleLiquorList) // Use LiquorList widget here
                            : LiquoroftheMonth(onExploreFullList: toggleLiquorList),
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
  final VoidCallback onBack;
  const LiquorList({required this.onBack, super.key});

  @override
  _LiquorListState createState() => _LiquorListState();
}

class _LiquorListState extends State<LiquorList> {
  final String app_name = 'paradise-pours-4be127640468';
  String buildPath(String route) {
      return 'https://$app_name.herokuapp.com/$route';
  }

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
  int index = 0;
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
      print('Error fetching all liquors: $error');
    }
  }

  Future<void> handleLiquorClick(dynamic liquor) async{
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
            index: index,
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
      var uri = Uri.parse(buildPath('api/userLiquorRating')).replace(
          queryParameters: {
            'UserId': _userId, 
            '_id': selectedLiquor['_id']
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
          body: json.encode({
            'UserId': _userId.toString(), //Needs to be converted to string because the userIds were stored as string in Favorites.
            '_id': selectedLiquor['_id']
          }));
      if (response.statusCode == 200) {
        setState(() {
          favBoolean = false;
        });
        fetchAllLiquors(); 
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
          body: json.encode({
            'UserId': _userId.toString(),
            '_id': selectedLiquor['_id']
          }));
      if (response.statusCode == 200) {
        setState(() {
          favBoolean = true;
        });
        fetchAllLiquors(); 
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
          body: json.encode({
            'UserId': _userId.toString(),
            '_id': selectedLiquor['_id'],
            'Stars': rating,
            'Comment': comment,
          }));
      if (response.statusCode == 200) {
        fetchAllLiquors(); 
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
    } else if (filterSelection == 'Red') {
      filteredLiquors = liquors.where((liquor) => liquor['Style'] == 'Red').toList();
    } else if (filterSelection == 'White') {
      filteredLiquors = liquors.where((liquor) => liquor['Style'] == 'White').toList();
    } else if (filterSelection == 'Sparkling') {
      filteredLiquors = liquors.where((liquor) => liquor['Style'] == 'Sparkling').toList();
    } else if (filterSelection == 'Calories < 125') {
      filteredLiquors = liquors.where((liquor) => liquor['Calories'] < 125).toList();
    } else if (filterSelection == 'USA Origin') {
      filteredLiquors = liquors.where((liquor) => liquor['Origin'] == 'USA').toList();
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
              child: Text('Liquor List', style: TextStyle(fontSize: 24)),
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
        //Liquor List
        Container(
          padding: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height * 0.8,
          child: validSearch
              ? (searchResults.isEmpty
                  ? (liquors.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
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

class LiquoroftheMonth extends StatefulWidget {
  final VoidCallback onExploreFullList;

  const LiquoroftheMonth({required this.onExploreFullList, super.key});

  @override
  _LiquoroftheMonthState createState() => _LiquoroftheMonthState();
}

class _LiquoroftheMonthState extends State<LiquoroftheMonth> {
  final String app_name = 'paradise-pours-4be127640468';
  String buildPath(String route) {
    return 'https://$app_name.herokuapp.com/$route';
  }

  dynamic LiquoroftheMonth;
  bool isLoading = true;
  dynamic selectedLiquor;
  int? _userId; 
  bool favBoolean = false; 
  late AuthService authService;

@override
  void initState() {
    super.initState();
    authService = AuthService();
    _loadUserData();
    fetchLiquoroftheMonth();
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

  Future<void> fetchLiquoroftheMonth() async {
    dynamic storedLiquor = await authService.getLiquorOfTheMonth();

    if (storedLiquor != null) {
      setState(() {
        LiquoroftheMonth = storedLiquor;
        isLoading = false;
      });
      await loadWOTM(storedLiquor);
    } else {
      try {
        var response = await http.post(Uri.parse(buildPath('api/searchLiquor')),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'Name': ''}));
        List<dynamic> liquors = json.decode(response.body)['liquor'];
        liquors.shuffle();
        if (liquors.isNotEmpty) {
          selectedLiquor = liquors.first;
          await loadWOTM(selectedLiquor);
          await authService.saveLiquorOfTheMonth(selectedLiquor);
        }
        setState(() {
          LiquoroftheMonth = liquors.isNotEmpty ? liquors.first : null;
          isLoading = false;
        });
      } catch (error) {
        print('Error fetching liquor of the month: $error');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  //Unfavorites Liquor
  void unfavWOTMLiquor() async {
    try {
      var response = await http.post(Uri.parse(buildPath('api/unfavoriteLiquor')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'UserId': _userId.toString(), //Needs to be converted to string because the userIds were stored as string in Favorites.
            '_id': selectedLiquor['_id']
          }));
      if (response.statusCode == 200) {
        setState(() {
          favBoolean = false;
        });
        fetchLiquoroftheMonth(); 
        print('Successfully unfavorited. favWOTMBoolean: $favBoolean');
      }
    } catch (error) {
      print('Error unfavoriting: $error');
    }
  }

  //Favorites Liquor
  void favWOTMLiquor() async {
    try {
      var response = await http.post(Uri.parse(buildPath('api/favoriteLiquor')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'UserId': _userId.toString(),
            '_id': selectedLiquor['_id']
          }));
      if (response.statusCode == 200) {
        setState(() {
          favBoolean = true;
        });
        fetchLiquoroftheMonth(); 
        print('Successfully favorited. favWOTMBoolean: $favBoolean');
      }
    } catch (error) {
      print('Error favoriting: $error');
    }
  }

  Future<void> loadWOTM(dynamic liquor) async {
    setState(() {
      selectedLiquor = liquor;
    });

    await Future.wait([
      checkWOTMFav(selectedLiquor),
    ]);
  }

  Future<void> checkWOTMFav(dynamic selectedLiquor) async {
    List<dynamic> favorites = selectedLiquor['Favorites'];
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
        if (LiquoroftheMonth != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/cocktail-list-header1.png',
                  height: 24,
                ),
                const SizedBox(width: 8), 
                Text(
                  'Liquor Of The Month',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent.withAlpha(150),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'assets/images/cocktail-list-header1.png',
                  height: 24,
                ),
              ],
            ),
          ),
          SpecialDrink(
            drink: LiquoroftheMonth,
            userId: _userId,
            favBoolean: favBoolean,
            favDrink: favWOTMLiquor,
            unfavDrink: unfavWOTMLiquor,
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ElevatedButton(
            onPressed: widget.onExploreFullList,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withAlpha(150),
              foregroundColor: Colors.white,
            ),
            child: const Text('Explore our full liquor selection'),
          ),
        ),
      ],
    );
  } 
}
