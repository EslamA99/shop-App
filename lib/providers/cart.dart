import 'package:flutter/cupertino.dart';

class Cart {
  final String id;
  final String title;
  int quantity;
  final double price;
  final String productId;
  Cart({this.id, this.title, this.price, this.quantity, this.productId});
}

class CartProvider with ChangeNotifier {
  List<Cart> items = [];

  List<Cart> get getItems {
    return [...items];
  }

  void addItem(Cart cart) {
    var tempItem =
        items.where((element) => element.productId == cart.productId).toList();
    if (tempItem.length != 0) {
      items
          .firstWhere((element) => element.productId == cart.productId)
          .quantity++;
    } else
      items.add(cart);
    notifyListeners();
  }

  int itemsCount() {
    return items.length == 0 ? 0 : items.length;
  }

  double get getTotal {
    double total = 0;
    items.forEach((element) {
      total += element.price * element.quantity;
    });
    return total;
  }

  void deleteItem(Cart cart) {
    items.remove(cart);
    notifyListeners();
  }

  void deleteProduct(String id) {
    if (items.firstWhere((element) => element.productId == id) != null) {
      items.firstWhere((element) => element.productId == id).quantity > 1
          ? items.firstWhere((element) => element.productId == id).quantity--
          : items.removeWhere((element) => element.productId == id);
    } else {
      print('Errrooorrrrrooorrr');
      return;
    }
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }
}

/**import 'package:flutter/cupertino.dart';

class Cart {
  final String id;
  final String title;
  final int quantity;
  final double price;
  Cart({this.id, this.title, this.price, this.quantity});
}

class CartProvider with ChangeNotifier {
  Map<String, Cart> items;

  Map<String, Cart> get getItems {
    return {...items};
  }

  void addItem(String id, double price, String title) {
    if (items.containsKey(id))
      items.update(id, (value) {
        return Cart(
            id: value.id,
            price: value.price,
            title: value.title,
            quantity: (value.quantity + 1));
      });
    else
      items.putIfAbsent(id, () {
        return Cart(
            id: DateTime.now().toString(),
            price: price,
            title: title,
            quantity: 1);
      });
    notifyListeners();
  }
}
 */
