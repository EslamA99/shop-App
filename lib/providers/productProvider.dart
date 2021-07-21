import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shopApp/models/httpException.dart';

import 'product.dart';

class productProvider with ChangeNotifier {
  List<Product> productList = [
    /*Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/
  ];
  final String token;
  final String userId;
  productProvider(this.token, this.productList, this.userId);
  List<Product> get items {
    return productList;
  }

  List<Product> get favItems {
    return productList.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return productList.firstWhere((element) => element.id == id);
  }

  Future<void> fetchData([bool userOrAll = false]) async {
    String temp = userOrAll ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    String url =
        'https://shopappdb-9378d.firebaseio.com/products.json?auth=$token&$temp';
    String favUrl =
        'https://shopappdb-9378d.firebaseio.com/userFavorites/$userId.json?auth=$token';
    try {
      final favResponse = await http.get(favUrl);
      final favData = json.decode(favResponse.body);
      final response = await http.get(url);
      final fetchedData = json.decode(response.body) as Map<String, dynamic>;
      if (fetchedData.length == 0) return;
      final List<Product> temp = [];
      fetchedData.forEach((key, value) {
        Product p = Product(
            description: value["description"],
            id: key,
            imageUrl: value["imageUrl"],
            price: value['price'],
            title: value['title']);
        p.isFavorite = favData == null ? false : favData[key] ?? false;
        temp.add(p);
      });
      productList = temp;
      notifyListeners();
    } catch (e) {
      print('object');
    }
  }

  Future<void> addProduct(Product p) async {
    String url =
        'https://shopappdb-9378d.firebaseio.com/products.json?auth=$token';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'description': p.description,
          'title': p.title,
          'imageUrl': p.imageUrl,
          'price': p.price,
          'creatorId': userId,
        }),
      );
      p = Product(
        id: json.decode(response.body)['name'],
        description: p.description,
        title: p.title,
        imageUrl: p.imageUrl,
        price: p.price,
      );
      productList.add(p);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  updateProduct(String id, Product p) {
    try {
      String url =
          'https://shopappdb-9378d.firebaseio.com/products/$id.json?auth=$token';
      final index = productList.indexWhere((element) => element.id == id);
      if (index >= 0) {
        http.patch(url,
            body: json.encode({
              'description': p.description,
              'title': p.title,
              'imageUrl': p.imageUrl,
              'price': p.price,
            }));
        productList[index] = p;
        notifyListeners();
      } else
        print('Error');
    } catch (e) {
      throw e;
    }
  }

  deleteProduct(String id) async {
    int index = productList.indexWhere((element) => element.id == id);
    Product p = productList[index];
    String url =
        'https://shopappdb-9378d.firebaseio.com/products/$id.json?auth=$token';
    String favUrl =
        'https://shopappdb-9378d.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    productList.removeWhere((element) => element.id == id);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      productList.insert(index, p);
      notifyListeners();
      throw HttpException('could not delete the product');
    }
    final favResponse = await http.delete(favUrl);
    if (favResponse.statusCode >= 400) {
      productList.insert(index, p);
      notifyListeners();
      throw HttpException('could not delete the product');
    }
    p = null;
  }
}
