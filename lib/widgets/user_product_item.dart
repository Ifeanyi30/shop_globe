import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_globe/providers/products.dart';
import 'package:shop_globe/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem(
      {@required this.id, @required this.title, @required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    var productData = Provider.of<Products>(context, listen: false);
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, EditProductScreen.routeName,
                    arguments: id);
              },
              icon: const Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              onPressed: () async {
                try {
                  await productData.deleteProduct(id).then((_) =>
                      scaffold.showSnackBar(const SnackBar(
                          content: Text('Product deleted Successfully'))));
                } catch (error) {
                  scaffold.showSnackBar(const SnackBar(
                    content: Text('Deleting Failed'),
                    duration: Duration(seconds: 1),
                    width: 300,
                    padding: EdgeInsets.all(20),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              icon: const Icon(Icons.delete),
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
