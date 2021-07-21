import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shopApp/models/httpException.dart';

class Product with ChangeNotifier {
  String id;
  String title;
  String description;
  String imageUrl;
  double price;
  bool isFavorite = false;
  Product({this.id, this.title, this.description, this.price, this.imageUrl});

  fav(String pid, String token, String userId) async {
    bool temp = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    String url =
        'https://shopappdb-9378d.firebaseio.com/userFavorites/$userId/$pid.json?auth=$token';
    try {
      final response = await put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        isFavorite = temp;
        notifyListeners();
        throw HttpException('Something is wrong');
      }
    } catch (e) {
      isFavorite = temp;
      notifyListeners();
      throw e;
    }
  }
}
