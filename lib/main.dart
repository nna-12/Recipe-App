import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:recipe/model.dart';
import 'package:recipe/wishlist.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
    theme: ThemeData.dark(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Model> list = <Model>[];
  String? text;

  List<String> wishlistItems = [];

  final url =
      'https://api.edamam.com/search?q=chicken&app_id=05fe8601&app_key=40274a9c80246a3c50b2b9b55d6db804&from=0&to=100&calories=591-722&health=alcohol-free';

  getApiData() async {
    var response = await http.get(Uri.parse(url));
    Map json = jsonDecode(response.body);

    json['hits'].forEach((e) {
      Model model = Model(
          url: e['recipe']['url'],
          image: e['recipe']['image'],
          source: e['recipe']['source'],
          label: e['recipe']['label']);
      setState(() {
        list.add(model);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getApiData();
  }

  void addToWishlist(String item) {
    setState(() {
      wishlistItems.add(item);
    });
  }

  void removeFromWishlist(int index) {
    setState(() {
      wishlistItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        title: Text('Recipe Corner',
          style: TextStyle(
            fontFamily: 'Charm',
            fontSize: 30.0,
            //color: Colors.white,
            fontWeight: FontWeight.bold,
          ),),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WishlistPage(
                    wishlistItems: wishlistItems,
                    removeFromWishlist: removeFromWishlist,
                  ),
                ),
              );
            },
            icon: Icon(Icons.favorite),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                onChanged: (v) {
                  text = v;
                },
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchPage(
                                search: text,
                                wishlistItems: wishlistItems,
                                addToWishlist: addToWishlist,
                                removeFromWishlist: removeFromWishlist,
                              )));
                    },
                    icon: Icon(Icons.search),
                  ),
                  hintText: "Search for recipe",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  fillColor: Colors.blueGrey.withOpacity(0.84),
                  filled: true,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              GridView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  primary: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final x = list[i];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WebPage(url: x.url)));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(x.image.toString()))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3),
                              height: 50,
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Text(
                                  x.label.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Charm',
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                wishlistItems.contains(x.label.toString())
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                if (wishlistItems
                                    .contains(x.label.toString())) {
                                  int index = wishlistItems
                                      .indexOf(x.label.toString());
                                  if (index != -1) {
                                    removeFromWishlist(index);
                                  }
                                } else {
                                  addToWishlist(x.label.toString());
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class WebPage extends StatelessWidget {
  final String? url;
  WebPage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl: url!,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            webViewController.clearCache();
            webViewController.evaluateJavascript('''
              document.cookie = 'key=value';
            ''');
          },
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  final String? search;
  final List<String> wishlistItems;
  final Function(String) addToWishlist;
  final Function(int) removeFromWishlist;

  SearchPage({
    required this.search,
    required this.wishlistItems,
    required this.addToWishlist,
    required this.removeFromWishlist,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Model> list = <Model>[];

  getApiData(search) async {
    final url =
        'https://api.edamam.com/search?q=$search&app_id=05fe8601&app_key=40274a9c80246a3c50b2b9b55d6db804&from=0&to=100&calories=591-722&health=alcohol-free';
    var response = await http.get(Uri.parse(url));
    Map json = jsonDecode(response.body);
    json['hits'].forEach((e) {
      Model model = Model(
          url: e['recipe']['url'],
          image: e['recipe']['image'],
          source: e['recipe']['source'],
          label: e['recipe']['label']);
      setState(() {
        list.add(model);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getApiData(widget.search);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        title: Text('Recipe Corner',
        style: TextStyle(
          fontFamily: 'Charm',
          fontSize: 30.0,
          //color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WishlistPage(
                    wishlistItems: widget.wishlistItems,
                    removeFromWishlist: widget.removeFromWishlist,
                  ),
                ),
              );
            },
            icon: Icon(Icons.favorite),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GridView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  primary: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final x = list[i];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WebPage(url: x.url)));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(x.image.toString()))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3),
                              height: 40,
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Text(
                                  x.label.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Charm',
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                widget.wishlistItems
                                    .contains(x.label.toString())
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                if (widget.wishlistItems
                                    .contains(x.label.toString())) {
                                  int index = widget.wishlistItems
                                      .indexOf(x.label.toString());
                                  if (index != -1) {
                                    widget.removeFromWishlist(index);
                                  }
                                } else {
                                  widget.addToWishlist(x.label.toString());
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
