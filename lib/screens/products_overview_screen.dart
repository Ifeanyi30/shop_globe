import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_globe/providers/cart.dart';
import 'package:shop_globe/providers/products.dart';
import 'package:shop_globe/screens/cart_screen.dart';
import 'package:shop_globe/widgets/app_drawer.dart';
import 'package:shop_globe/widgets/badge.dart';
import '../widgets/products_item.dart';

enum filterOption { Favorite, All }

class ProductOverviewScreen extends StatefulWidget {
  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool showFavoriteOnly = false;
  var _isLoading = true;

  // @override
  // void initState() {
  //   // Future.delayed(Duration.zero)
  //   //     .then((_) => Provider.of<Products>(context).fetchProducts());
  //   // this is not really effective
  //   // Use the Provider below instead, with the listen property set to false.
  //   Provider.of<Products>(context, listen: false).fetchProducts().then((_) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  //   super.initState();
  // }

  //or Use

  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchProducts().then((_) {
        setState(() {
          _isInit = false;
          _isLoading = false;
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (filterOption selectedValue) {
              setState(() {
                if (selectedValue == filterOption.Favorite) {
                  showFavoriteOnly = true;
                } else {
                  showFavoriteOnly = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                  child: Text('Only Favorites'), value: filterOption.Favorite),
              const PopupMenuItem(
                  child: Text('Sholl All'), value: filterOption.All),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, child) =>
                Badge(icon: child as Widget, count: cart.itemCount),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(showFavs: showFavoriteOnly),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final bool showFavs;
  const ProductGrid({Key key, @required this.showFavs}) : super(key: key);

  // const ProductGrid({
  //   Key? key,
  //   required this.products,
  // }) : super(key: key);

  // final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);

    final products = showFavs ? productsData.favorites : productsData.items;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        // the ChangeNotifierProvider.value is good when a list is used
        // and when the context argument is not used in the builder/create.
        value: products[index],
        child: ProductItem(
            // id: products[index].id,
            // title: products[index].title,
            // imageUrl: products[index].imageUrl
            ),
      ),
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
    );
  }
}
