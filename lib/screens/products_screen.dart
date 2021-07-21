import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopApp/providers/cart.dart';
import 'package:shopApp/providers/productProvider.dart';
import 'package:shopApp/screens/cart_screen.dart';
import 'package:shopApp/widgets/appDrawer.dart';
import 'package:shopApp/widgets/badge.dart';
import 'package:shopApp/widgets/productItem.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool isFav = false;
  bool isInit = true;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    if (isInit) {
      setState(() {
        isLoading = true;
      });
      Provider.of<productProvider>(context)
          .fetchData()
          .then((value) => setState(() {
                isLoading = false;
              }));
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productList = isFav
        ? Provider.of<productProvider>(context).favItems
        : Provider.of<productProvider>(context).items;
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Shop App'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                if (value == 'all')
                  isFav = false;
                else
                  isFav = true;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('All'),
                value: 'all',
              ),
              PopupMenuItem(
                child: Text('Favorites'),
                value: 'fav',
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<CartProvider>(
              builder: (context, value, child) =>
                  Badge(child: child, value: value.itemsCount().toString()),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.route);
                },
              ))
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemBuilder: (context, index) {
                return ChangeNotifierProvider.value(
                  //بستخدم اوبجكت موجود عكس الي فالمين
                  value: productList[index],
                  child: productItem(),
                );
              },
              itemCount: productList.length,
            ),
    );
  }
}
