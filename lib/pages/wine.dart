import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../navigation_menu.dart';
// import '../components/display_wine.dart';

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

  @override
  void initState() {
    super.initState();
    fetchAllWines();
  }

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

  void handleWineClick(dynamic wine) {
    setState(() {
      selectedWine = wine;
      showDisplayWine = true;
    });
  }

  void handleSearch() async {
    // searchTextController.text = 'Search';

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
        // if (validSearch && showDisplayWine && selectedWine != null)
        //   DisplayWine(wine: selectedWine), // Display the selected wine
        // // ElevatedButton(
        // //   onPressed: widget.switchComponents,
        // //   child: Row(
        // //     children: <Widget>[
        // //       Icon(Icons.arrow_left),
        // //       Text('Back'),
        // //     ],
        // //   ),
        // // ),
      ],
    );
  }
}
