import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_globe/providers/product.dart';
import 'package:shop_globe/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit_product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imgController = TextEditingController();
  final _imgUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');

  var _isLoading = false;

  @override
  void didChangeDependencies() {
    _imgUrlFocusNode.addListener(_updateUrl);
    super.didChangeDependencies();
  }

  void _updateUrl() {
    if (!_imgUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _imgUrlFocusNode.removeListener(_updateUrl);
    _imgUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prodId = ModalRoute.of(context).settings.arguments;
    if (prodId != null) {
      _editedProduct =
          Provider.of<Products>(context).findById(prodId as String);
      _imgController.text = _editedProduct.imageUrl;
    }

    Future<void> _saveForm() async {
      final survey = Provider.of<Products>(context, listen: false);
      final validForm = _formKey.currentState.validate();
      if (!validForm) {
        return;
      }
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });

      try {
        if (prodId != null) {
          await survey.updateProduct(_editedProduct.id, _editedProduct);
        } else {
          await survey.addProduct(_editedProduct.id, _editedProduct);
        }
      } catch (error) {
        return await showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('An error occurred'),
              content: Text(error.toString()),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Okay'))
              ],
            );
          },
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: () {
              _saveForm();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                autovalidateMode: AutovalidateMode.always,
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Title',
                        ),
                        initialValue: _editedProduct.title,
                        validator: (value) {
                          if ((value as String).isEmpty) {
                            return 'Please provide a value';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onSaved: (newValue) {
                          setState(() {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                title: newValue as String,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: _editedProduct.imageUrl,
                                isFavorite: _editedProduct.isFavorite);
                          });
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Price',
                        ),
                        initialValue: _editedProduct.price <= 0
                            ? ''
                            : _editedProduct.price.toString(),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          var price = value as String;
                          if (price.isEmpty) {
                            return 'Please enter a price.';
                          }
                          if (double.tryParse(price) == null) {
                            return 'Please enter a valid number.';
                          }
                          if (double.tryParse(price) <= 0) {
                            return 'Please a number greater than zero.';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          setState(() {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: double.parse(newValue.toString()),
                                imageUrl: _editedProduct.imageUrl);
                          });
                        },
                      ),
                      TextFormField(
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        initialValue: _editedProduct.description,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.next,
                        onSaved: (newValue) {
                          setState(() {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: _editedProduct.title,
                                description: newValue as String,
                                price: _editedProduct.price,
                                imageUrl: _editedProduct.imageUrl);
                          });
                        },
                        validator: (value) {
                          if ((value as String).isEmpty) {
                            return 'Please enter a description.';
                          }
                          if (value.length < 10) {
                            return 'Should be at least 10 characters long.';
                          }
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            )),
                            child: Container(
                              child: _imgController.text.isEmpty
                                  ? Text('Enter a URL')
                                  : FittedBox(
                                      child: Image.network(
                                      _imgController.text,
                                      fit: BoxFit.cover,
                                    )),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Image Url',
                              ),
                              // initialValue: '',
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              focusNode: _imgUrlFocusNode,
                              onSaved: (newValue) {
                                setState(() {
                                  _editedProduct = Product(
                                      id: _editedProduct.id,
                                      isFavorite: _editedProduct.isFavorite,
                                      title: _editedProduct.title,
                                      description: _editedProduct.description,
                                      price: _editedProduct.price,
                                      imageUrl: newValue as String);
                                });
                              },
                              controller: _imgController,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
