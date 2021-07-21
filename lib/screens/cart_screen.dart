import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopApp/providers/cart.dart';
import 'package:shopApp/providers/orders.dart';
import 'package:shopApp/widgets/cartItem.dart';

class CartScreen extends StatelessWidget {
  static const route = '/cartScreen';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final order = Provider.of<OrderProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.all(5),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                      //Spacer(),
                      Chip(
                          label: Text(
                            "\$${cart.getTotal.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: Theme.of(context).primaryColor),
                      //Spacer(),
                      OrderButton(cart: cart, order: order)
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                  child: ListView.builder(
                itemBuilder: (context, index) {
                  return CartItem(cart.items[index]);
                },
                itemCount: cart.itemsCount(),
              ))
            ],
          )),
    );
  }
}

class OrderButton extends StatefulWidget {
  OrderButton({
    Key key,
    @required this.cart,
    @required this.order,
  }) : super(key: key);

  final CartProvider cart;
  final OrderProvider order;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : FlatButton(
            onPressed: (widget.cart.getTotal <= 0)
                ? null
                : () async {
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      Order o = new Order(
                          amount: widget.cart.getTotal,
                          date: DateTime.now(),
                          id: DateTime.now().toString(),
                          items: widget.cart.getItems);
                      await widget.order.addOrder(o);
                      widget.cart.clear();
                    } catch (e) {
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Somthing is wrong'),
                          content: Text('an error occured'),
                          actions: [
                            FlatButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text('Ok'))
                          ],
                        ),
                      );
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
            child: Text(
              "Order now",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ));
  }
}
