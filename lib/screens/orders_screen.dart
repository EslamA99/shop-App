import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopApp/providers/orders.dart';
import 'package:shopApp/widgets/appDrawer.dart';
import 'package:shopApp/widgets/orderItem.dart';

class OrderScreen extends StatelessWidget {
  static const route = '/orderScreen';

  @override
  Widget build(BuildContext context) {
    //final order = Provider.of<OrderProvider>(context);
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        body: FutureBuilder(
          future:
              Provider.of<OrderProvider>(context, listen: false).fetchOrders(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.error != null) {
                return Center(
                  child: Text('Error occured'),
                );
              } else
                return Consumer<OrderProvider>(
                  builder: (context, order, child) => ListView.builder(
                    itemBuilder: (context, i) {
                      return OrderItem(order.orders[i]);
                    },
                    itemCount: order.orders.length,
                  ),
                );
            }
          },
        ));
  }
}
