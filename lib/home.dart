import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:wallpaper/data/data.dart';
import 'dart:convert';
import 'package:wallpaper/models/categorie_model.dart';
import 'package:wallpaper/models/photos_model.dart';
import 'package:wallpaper/view/categorie_screen.dart';
import 'package:wallpaper/view/search_view.dart';
import 'package:wallpaper/view/latest.dart';
import 'package:wallpaper/view/favourites.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategorieModel> categories = new List();

  int noOfImageToLoad = 30;
  List<PhotosModel> photos = new List();

  getTrendingWallpaper() async {
    await http.get(
        "https://api.pexels.com/v1/curated?per_page=$noOfImageToLoad&page=1",
        headers: {"Authorization": apiKEY}).then((value) {
      //print(value.body);

      Map<String, dynamic> jsonData = jsonDecode(value.body);
      jsonData["photos"].forEach((element) {
        //print(element);
        PhotosModel photosModel = new PhotosModel();
        photosModel = PhotosModel.fromMap(element);
        photos.add(photosModel);
        //print(photosModel.toString()+ "  "+ photosModel.src.portrait);
      });

      setState(() {});
    });
  }

  TextEditingController searchController = new TextEditingController();

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    //getWallpaper();
    getTrendingWallpaper();
    categories = getCategories();
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        noOfImageToLoad = noOfImageToLoad + 30;
        getTrendingWallpaper();
      }
    });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              labelPadding: EdgeInsets.all(10),
              indicatorColor: Colors.white,
              labelStyle: TextStyle(fontSize: 20.0),
              unselectedLabelStyle: TextStyle(fontSize: 18.0),
              tabs: [
                Text('Latest'),
                Text('Categories'),
                Text('Favourites'),
              ],
            ),
            title: Container(
              decoration: BoxDecoration(
                color: Color(0xff09314b),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        controller: searchController,
                        decoration: InputDecoration(
                            hintText: "search wallpapers",
                            hintStyle: TextStyle(fontSize: 16.0, color: Colors.white70),
                            border: InputBorder.none),
                  )),
                  InkWell(
                      onTap: () {
                        if (searchController.text != "") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchView(
                                        search: searchController.text,
                                      )));
                        }
                      },
                      child: Container(child: Icon(Icons.search)))
                ],
              ),
            ),
            elevation: 0.0,
          ),
          backgroundColor: Colors.black,
          body: TabBarView(
            children: [
              Latest(),
              GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(5.0),
                  shrinkWrap: true,
                  mainAxisSpacing: 5.0,
                  crossAxisSpacing: 5.0,
                  children: List.generate(categories.length, (index) {
                    return GridTile(
                      child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CategorieScreen(
                                      categorie: categories[index].categorieName,
                                    )));
                          },
                          child: Hero(
                            tag: categories[index].imgUrl,
                            child: Container(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(1),
                                  child: kIsWeb
                                      ? Image.network(
                                    categories[index].imgUrl,
                                    height: 50,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  )
                                      : CachedNetworkImage(
                                      imageUrl: categories[index].imgUrl,
                                      placeholder: (context, url) => Container(
                                        color: Color(0xfff5f8fd),
                                      ),
                                      fit: BoxFit.cover)),
                            ),
                          ),
                      ));
                  })),
              Favourites()
            ],
          ),
        ));
  }
}

class CategoriesTile extends StatelessWidget {
  final String imgUrls, categorie;

  CategoriesTile({@required this.imgUrls, @required this.categorie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategorieScreen(
                      categorie: categorie,
                    )));
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        child: kIsWeb
            ? Column(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(
                              imgUrls,
                              height: 50,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: imgUrls,
                              height: 50,
                              width: 100,
                              fit: BoxFit.cover,
                            )),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        categorie,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Overpass'),
                      )),
                ],
              )
            : Stack(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(
                              imgUrls,
                              height: 50,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: imgUrls,
                              height: 50,
                              width: 100,
                              fit: BoxFit.cover,
                            )),
                  Container(
                    height: 50,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Container(
                      height: 50,
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        categorie ?? "Yo Yo",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Overpass'),
                      ))
                ],
              ),
      ),
    );
  }
}
