import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopApp/providers/auth.dart';
import 'package:shopApp/providers/cart.dart';
import 'package:shopApp/providers/product.dart';
import 'package:shopApp/screens/productDetails_screen.dart';

class productItem extends StatefulWidget {
  @override
  _productItemState createState() => _productItemState();
}

class _productItemState extends State<productItem> {
  @override
  Widget build(BuildContext context) {
    final snack = Scaffold.of(context);
    final product = Provider.of<Product>(context);
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<Auth>(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProductDetailsScreen.route, arguments: product.id);
        },
        child: GridTile(
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/tempImage.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            leading: IconButton(
                icon: product.isFavorite
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_border),
                onPressed: () async {
                  try {
                    await Provider.of<Product>(context)
                        .fav(product.id, auth.token, auth.getUserId);
                  } catch (e) {
                    snack.showSnackBar(SnackBar(
                        content: Text(
                      'Something is wrong',
                      textAlign: TextAlign.center,
                    )));
                  }
                }),
            title: FittedBox(
              child: Text(
                product.title,
                textAlign: TextAlign.center,
              ),
            ),
            trailing: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  final c = Cart(
                      id: DateTime.now().toString(),
                      price: product.price,
                      productId: product.id,
                      quantity: 1,
                      title: product.title);
                  cart.addItem(c);
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 2),
                      content: Text('Item added to cart'),
                      action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            cart.deleteProduct(product.id);
                          }),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
