import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopApp/providers/product.dart';
import 'package:shopApp/providers/productProvider.dart';
import 'package:shopApp/screens/editProduct_screen.dart';

class UserProductsItem extends StatefulWidget {
  final Product product;
  UserProductsItem(this.product);

  @override
  _UserProductsItemState createState() => _UserProductsItemState();
}

class _UserProductsItemState extends State<UserProductsItem> {
  bool isError = false;
  @override
  Widget build(BuildContext context) {
    final snack = Scaffold.of(context);
    return ListTile(
      title: Text(widget.product.title),
      leading:
          CircleAvatar(backgroundImage: NetworkImage(widget.product.imageUrl)),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).pushNamed(EditProductScreen.route,
                      arguments: widget.product.id);
                }),
            IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () async {
                  try {
                    await Provider.of<productProvider>(context)
                        .deleteProduct(widget.product.id);
                  } catch (e) {
                    snack.showSnackBar(
                        SnackBar(content: Text('Deleting failed')));
                  }
                }),
          ],
        ),
      ),
    );
  }
}
