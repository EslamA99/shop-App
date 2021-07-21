import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shopApp/providers/cart.dart';

class Order {
  String id;
  final double amount;
  final List<Cart> items;
  final DateTime date;
  Order({this.amount, this.date, this.id, this.items});
}

class OrderProvider with ChangeNotifier {
  List<Order> orders = [];
  String token;
  String userId;
  OrderProvider(this.token, this.orders, this.userId);
  List<Order> get getOrders {
    return [...orders];
  }

  Future<void> addOrder(Order order) async {
    try {
      String url =
          'https://shopappdb-9378d.firebaseio.com/orders/$userId.json?auth=$token';
      final res = await post(url,
          body: json.encode({
            'items': order.items
                .map((e) => {
                      'id': e.id,
                      'title': e.title,
                      'quantity': e.quantity,
                      'price': e.price,
                    })
                .toList(),
            'amount': order.amount,
            'date': order.date.toIso8601String()
          }));
      order.id = json.decode(res.body)['name'];
      orders.add(order);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> fetchOrders() async {
    try {
      String url =
          'https://shopappdb-9378d.firebaseio.com/orders/$userId.json?auth=$token';
      final res = await get(url);
      final fetchedData = json.decode(res.body) as Map<String, dynamic>;
      if (fetchedData.length == 0) return;
      List<Order> temp = [];
      fetchedData.forEach((key, value) {
        Order o = Order(
          id: key,
          amount: value['amount'],
          date: DateTime.parse(value['date']),
          items: (value['items'] as List<dynamic>)
              .map((e) => Cart(
                    id: e['id'],
                    title: e['title'],
                    quantity: e['quantity'],
                    price: e['price'],
                  ))
              .toList(),
        );
        temp.add(o);
      });
      orders = temp.reversed.toList();
      notifyListeners();
    } catch (e) {
      //print('Errorororor');
      return;
    }
  }
}
