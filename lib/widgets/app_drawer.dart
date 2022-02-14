import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_globe/helpers/custom_route.dart';
import 'package:shop_globe/providers/auth.dart';
import 'package:shop_globe/screens/orders_screen.dart';
import 'package:shop_globe/screens/user_product_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.only(
              top: 30,
              bottom: 15,
            ),
            child: Consumer<Auth>(
              builder: (_, auth, __) => Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 70,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  auth.userEmail.isNotEmpty
                      ? Text(
                          auth.matchEmail,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Hello User',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                ],
              ),
            ),
          ),
          //automaticallyImplyLeading: false, is for appbar widget.

          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Shop'),
            onTap: () {
              Navigator.of(context).pushNamed('/');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Orders'),
            onTap: () {
              // Navigator.of(context)
              //     .pushReplacementNamed(OrdersScreen.routeName);
              Navigator.of(context).pushReplacement(CustomRuote(
                builder: (ctx) => OrdersScreen(),
              ));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Manage Products'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // close the drawer before logging out to prevent error.
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
