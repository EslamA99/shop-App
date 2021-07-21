import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopApp/providers/cart.dart';

class CartItem extends StatelessWidget {
  Cart cart;
  CartItem(this.cart);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you want to remove this item?'),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                    child: Text('No')),
                FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                    child: Text('Yes')),
              ],
            );
          },
        );
      },
      key: ValueKey(cart.id),
      background: Container(
        padding: EdgeInsets.all(10),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 35,
        ),
        alignment: Alignment.centerRight,
        color: Colors.red,
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        final c = Provider.of<CartProvider>(context, listen: false);
        c.deleteItem(cart);
      },
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
                padding: EdgeInsets.all(5),
                child: FittedBox(child: Text("\$${cart.price}"))),
          ),
          title: Text("${cart.title}"),
          subtitle: Text("${cart.price * cart.quantity}"),
          trailing: Text("${cart.quantity}x"),
        ),
      ),
    );
  }
}
