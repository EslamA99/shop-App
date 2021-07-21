import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopApp/providers/productProvider.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const route = '/peoductDetails';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final product = Provider.of<productProvider>(context).findById(productId);

    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
                height: 250,
                width: double.infinity,
                child: Hero(
                  tag: product.id,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                )),
            title: Text(product.title),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          SizedBox(
            height: 25,
          ),
          Text(
            product.title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(
            height: 10,
          ),
          Text('\$${product.price}',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          SizedBox(
            height: 10,
          ),
          Text(
            product.description,
            textAlign: TextAlign.center,
          )
        ]))
      ],
    ));
  }
}
