import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopApp/helpers/customRouteTransition.dart';
import 'package:shopApp/providers/auth.dart';
import 'package:shopApp/providers/cart.dart';
import 'package:shopApp/providers/orders.dart';
import 'package:shopApp/providers/productProvider.dart';
import 'package:shopApp/screens/auth_screen.dart';
import 'package:shopApp/screens/cart_screen.dart';
import 'package:shopApp/screens/editProduct_screen.dart';
import 'package:shopApp/screens/orders_screen.dart';
import 'package:shopApp/screens/productDetails_screen.dart';
import 'package:shopApp/screens/products_screen.dart';
import 'package:shopApp/screens/splash_screen.dart';
import 'package:shopApp/screens/userProducts_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            //عشان ان بكريت الصفحة من جديد يعني مش بستخدم اوبجكت موجود لا بكريته
            builder: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, productProvider>(
            builder: (context, value, previous) => productProvider(value.token,
                previous == null ? [] : previous.productList, value.getUserId),
          ),
          ChangeNotifierProvider(
            builder: (context) => CartProvider(),
          ),
          ChangeNotifierProxyProvider<Auth, OrderProvider>(
            builder: (context, value, previous) => OrderProvider(value.token,
                previous == null ? [] : previous.orders, value.userId),
          ),
        ],
        child: Consumer<Auth>(
          builder: (context, authData, child) => MaterialApp(
            title: 'ShopApp',
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomRouteTransition(),
                  TargetPlatform.iOS: CustomRouteTransition(),
                })),
            home: authData.isAuthenticated
                ? ProductsScreen()
                : FutureBuilder(
                    future: authData.tryLogIn(),
                    builder: (ctx, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailsScreen.route: (context) => ProductDetailsScreen(),
              CartScreen.route: (context) => CartScreen(),
              OrderScreen.route: (context) => OrderScreen(),
              UserProductsScreen.route: (context) => UserProductsScreen(),
              EditProductScreen.route: (context) => EditProductScreen(),
            },
          ),
        ));
  }
}
