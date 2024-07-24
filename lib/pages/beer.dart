import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../navigation_menu.dart';
import '../components/display_beer.dart';

class BeerPage extends StatelessWidget {
  const BeerPage({super.key});

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
                      padding: EdgeInsets.all(16.0),
                      child: Card(
                        color: Colors.white.withAlpha(210),
                        elevation: 8.0,
                        child: BeerList(), // Use BeerList widget here
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
  const BeerList({super.key});

  @override
  _BeerListState createState() => _BeerListState();
}

class _BeerListState extends State<BeerList> {
  final String app_name = 'paradise-pours-4be127640468';
  String buildPath(String route) {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'https://$app_name.herokuapp.com/$route';
    } else {
      return 'http://localhost:5000/$route';
    }
  }

  // UserContext userContext;
  List<dynamic> beers = [];
  dynamic selectedBeer;
  bool showDisplayBeer = false;
  List<dynamic> searchResults = [];
  TextEditingController searchTextController = TextEditingController();
  bool validSearch = true;
  String filterSelection = '';
  List<dynamic> filteredBeers = [];

  @override
  void initState() {
    super.initState();
    fetchAllBeers();
  }

  Future<void> fetchAllBeers() async {
    try {
      var response = await http.get(Uri.parse('http://paradise-pours-4be127640468.herokuapp.com/api/getAllBeers'));
      List<dynamic> beersData = json.decode(response.body)['beers'];
      beersData.sort((a, b) => a['Name'].compareTo(b['Name']));
      setState(() {
        beers = beersData;
      });
    } catch (error) {
      print('Error fetching all beers: $error');
    }
  }

  void handleBeerClick(dynamic beer) {
    setState(() {
      selectedBeer = beer;
    });

    //Creates a pop-up that will show the nutrition facts, favorite, ratings, etc. on click
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: DisplayBeer(beer: selectedBeer),
        );
      },
    );
  }


  void handleSearch() async {
    try {
      var response = await http.post(Uri.parse('http://paradise-pours-4be127640468.herokuapp.com/api/searchBeer'),
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

  void handleFilterChange(String? selection) {
    setState(() {
      filterSelection = selection ?? ''; // handle null case if needed
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
              // Image.asset('assets/images/beer-mugs-left.png'),
              Text('Beer List', style: TextStyle(fontSize: 24)),
              // Image.asset('assets/images/beer-mugs-right.png'),
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
              'IPAs',
              'Pilsner',
              'Lager',
              'Wheat',
              'Porter',
              'Stout',
              'Lager',
              'Calories',
              'Origin',
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
                              onTap: () => handleBeerClick(beer),
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
                          onTap: () => handleBeerClick(beer),
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
