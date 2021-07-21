import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopApp/providers/productProvider.dart';
import 'package:shopApp/screens/editProduct_screen.dart';
import 'package:shopApp/widgets/appDrawer.dart';
import 'package:shopApp/widgets/userProductsItem.dart';

class UserProductsScreen extends StatelessWidget {
  static const route = 'userProductsScreen/';

  Future<void> refresh(BuildContext context) async {
    await Provider.of<productProvider>(context, listen: false).fetchData(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your products'),
        actions: [
          IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.route);
              }),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: refresh(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => refresh(context),
                    child: Consumer<productProvider>(
                      builder: (context, value, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (_, index) {
                            return UserProductsItem(value.items[index]);
                          },
                          itemCount: value.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
