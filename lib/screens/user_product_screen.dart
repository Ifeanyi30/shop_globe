import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_globe/providers/products.dart';
import 'package:shop_globe/screens/edit_product_screen.dart';
import 'package:shop_globe/widgets/app_drawer.dart';
import 'package:shop_globe/widgets/user_product_item.dart';

class UserProductsScreen extends StatefulWidget {
  static const routeName = '/user_products';

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  Future _fetchUserProducts;
  Future<void> _refreshProducts(BuildContext cxt) async {
    await Provider.of<Products>(cxt, listen: false).fetchUserProducts();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProducts = _refreshProducts(context);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future:
            Provider.of<Products>(context, listen: false).fetchUserProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Consumer<Products>(
                  builder: (_, productsData, __) => ListView.builder(
                    itemBuilder: (_, i) {
                      return Column(children: [
                        UserProductItem(
                            id: productsData.userItems[i].id,
                            title: productsData.userItems[i].title,
                            imageUrl: productsData.userItems[i].imageUrl),
                        const Divider(
                          height: 20,
                          thickness: 1,
                          indent: 65,
                          endIndent: 20,
                        )
                      ]);
                    },
                    itemCount: productsData.userItems.length,
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
