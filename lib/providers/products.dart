import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_globe/models/exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  List<Product> _userItems = [];

  final _authToken;
  final userId;

  Products(this._authToken, this._items, this.userId);

  Future<void> fetchUserProducts() async {
    try {
      var url = Uri.parse(
          'https://shop-globe-default-rtdb.firebaseio.com/products.json?auth=$_authToken&orderBy="creatorId"&equalTo="$userId"');

      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      List<Product> _loadedProducts = [];
      if (extractedData.isEmpty) {
        return;
      }
      extractedData.forEach((prodId, prodValue) {
        _loadedProducts.add(Product(
          id: prodId,
          title: prodValue['title'],
          description: prodValue['description'],
          price: prodValue['price'],
          imageUrl: prodValue['imageUrl'],
        ));
      });
      _userItems = _loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchProducts() async {
    try {
      var url = Uri.parse(
          'https://shop-globe-default-rtdb.firebaseio.com/products.json?auth=$_authToken');

      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> _loadedProducts = [];
      if (extractedData.isEmpty) {
        return;
      }
      url = Uri.parse(
          'https://shop-globe-default-rtdb.firebaseio.com/userfavorites/$userId.json?auth=$_authToken');

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      extractedData.forEach((prodId, prodValue) {
        _loadedProducts.add(Product(
          id: prodId,
          title: prodValue['title'],
          description: prodValue['description'],
          price: prodValue['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodValue['imageUrl'],
        ));
      });
      _items = _loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // var _showFavoritesOnly = false;

  Product findById(String id) {
    return [..._items].firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  List<Product> get favorites {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite == true).toList();
    // }
    return [..._items];
  }

  List<Product> get userItems {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite == true).toList();
    // }
    return [..._userItems];
  }

  Future<void> addProduct(String id, Product newProduct) async {
    final url = Uri.parse(
        'https://shop-globe-default-rtdb.firebaseio.com/products.json?auth=$_authToken');

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            'creatorId': userId,
          }));
      final product = Product(
          id: json.decode(response.body)['name'],
          title: newProduct.title,
          description: newProduct.description,
          price: newProduct.price,
          imageUrl: newProduct.imageUrl);

      final prodIndex = _items.indexWhere((element) => element.id == id);
      if (prodIndex < 0) {
        _items.add(product);
        notifyListeners();
        return;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url = Uri.parse(
        'https://shop-globe-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken');

    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex < 0) {
      notifyListeners();
      return;
    } else {
      try {
        await http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'price': newProduct.price,
              'imageUrl': newProduct.imageUrl,
              'isFavorite': newProduct.isFavorite
            }));
        _items[prodIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shop-globe-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken');

    var existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not Delete product');
    }
    existingProduct = null;
  }
}
