import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_globe/providers/product.dart';

import 'package:shop_globe/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product_details_screen';

  Product getProductItem(BuildContext cxt) {
    final routeArgsId = ModalRoute.of(cxt)?.settings?.arguments as String;

    return Provider.of<Products>(cxt, listen: false).findById(
        routeArgsId); // the listen argument of the of() prevent the rebuild and update.
  }

  @override
  Widget build(BuildContext context) {
    final targetProduct = getProductItem(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(targetProduct.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(targetProduct.title),
              background: Hero(
                tag: targetProduct.id,
                child: Image.network(
                  targetProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            const SizedBox(
              height: 10,
            ),
            Text(
              '\$${targetProduct.price}',
              textAlign: TextAlign.center,
              softWrap: true,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              width: double.infinity,
              child: Text(
                targetProduct.description,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            const SizedBox(
              height: 1000,
            )
          ])),
        ],
      ),
    );
  }
}
