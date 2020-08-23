import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper/models/photos_model.dart';
import 'package:wallpaper/view/image_view.dart';

Widget wallPaper(List<PhotosModel> listPhotos, BuildContext context) {
  final Orientation orientation = MediaQuery.of(context).orientation;
  final IconData icon = Icons.favorite_border;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 1),
    child: GridView.count(
        crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
        childAspectRatio: 0.6,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(4.0),
        mainAxisSpacing: 6.0,
        crossAxisSpacing: 6.0,
        children: listPhotos.map((PhotosModel photoModel) {
          return GridTile(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImageView(
                                imgPath: photoModel.src.portrait,
                              )));
                },
                child: Hero(
                  tag: photoModel.src.portrait,
                  child: Container(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(1),
                        child: kIsWeb
                            ? Image.network(
                                photoModel.src.portrait,
                                height: 50,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: photoModel.src.portrait,
                                placeholder: (context, url) => Container(
                                      color: Color(0xfff5f8fd),
                                    ),
                                fit: BoxFit.cover)),
                  ),
                ),
              ),
              footer: Padding(
                  padding: EdgeInsets.all(5),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          debugPrint('yes, I am favorite');
                        },
                        child: Icon(
                          icon,
                          color: Colors.white,
                        ),
                      ))));
        }).toList()),
  );
}

Widget brandName() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        "Wallpaper",
        style: TextStyle(color: Colors.white, fontFamily: 'Overpass'),
      ),
    ],
  );
}
