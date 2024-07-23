import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../navigation_menu.dart';
import '../components/display_liquor.dart';

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
                  image:
                      AssetImage('assets/images/LiquorBackground2Enhanced.jpg'),
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
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'https://$app_name.herokuapp.com/$route';
    } else {
      return 'http://localhost:5000/$route';
    }
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

  @override
  void initState() {
    super.initState();
    fetchAllLiquors();
  }

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

  void handleLiquorClick(dynamic liquor) {
    setState(() {
      selectedLiquor = liquor;
      showDisplayLiquor = true;
    });
  }

  void handleSearch() async {
    searchTextController.text = 'Search';

    try {
      var response = await http.post(Uri.parse(buildPath('api/searchLiquor')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'Name': searchTextController.text}));

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
        if (validSearch && showDisplayLiquor && selectedLiquor != null)
          DisplayLiquor(liquor: selectedLiquor), // Display the selected Liquor
        // ElevatedButton(
        //   onPressed: widget.switchComponents,
        //   child: Row(
        //     children: <Widget>[
        //       Icon(Icons.arrow_left),
        //       Text('Back'),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
