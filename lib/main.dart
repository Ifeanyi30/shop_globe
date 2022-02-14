import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_globe/helpers/custom_route.dart';
import 'package:shop_globe/providers/auth.dart';
import 'package:shop_globe/providers/cart.dart';
import 'package:shop_globe/providers/orders.dart';
import 'package:shop_globe/providers/products.dart';
import 'package:shop_globe/screens/auth_screen.dart';
import 'package:shop_globe/screens/cart_screen.dart';
import 'package:shop_globe/screens/edit_product_screen.dart';
import 'package:shop_globe/screens/orders_screen.dart';
import 'package:shop_globe/screens/product_detail_screen.dart';
import 'package:shop_globe/screens/products_overview_screen.dart';
import 'package:shop_globe/screens/user_product_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products('', [], ''),
          update: (context, auth, previousProducts) => Products(
            auth.token,
            previousProducts.items,
            auth.userId,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Order>(
          create: (context) => Order('', '', []),
          update: (context, auth, previousProducts) => Order(
            auth.token,
            auth.userId,
            previousProducts.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shop globe',
          theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomerPageTransitionBuilder(),
                TargetPlatform.iOS: CustomerPageTransitionBuilder(),
              })),
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (cxt, snapShot) => snapShot.connectionState ==
                          ConnectionState.waiting
                      ? const Scaffold(
                          backgroundColor: Colors.purple,
                          body: Center(
                            child: Text(
                              'Loading...',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        )
                      : AuthScreen()),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
