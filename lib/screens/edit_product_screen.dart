import 'package:flutter/material.dart';
import 'package:fourth/provider/product.dart';
import 'package:provider/provider.dart';
import '../provider/products.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _initialValue = {
    'title': '',
    'description': '',
    'price': '',
  };
  Product _editProduct = Product(
    id: null,
    price: 0,
    title: "",
    description: "",
    imageUrl: "",
  );
  var isloading = false;

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpeg') &&
              !_imageUrlController.text.endsWith('.jpg'))) {
        return;
      }
      setState(() {});
    }
  }

  var isFirst = true;

  @override
  void didChangeDependencies() {
    if (isFirst) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editProduct = Provider.of<Products>(context).findbyId(productId);
        print("product is " + _editProduct.id);
        _initialValue = {
          'title': _editProduct.title,
          'description': _editProduct.description,
          'price': _editProduct.price.toString(),
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
    }
    isFirst = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    bool isValid = _form.currentState.validate();
    setState(() {
      isloading = true;
    });
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    if (_editProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id, _editProduct);
      
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (error) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    isloading = false;
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      } 
    }
    setState(() {
          isloading = false;
        });
        Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          )
        ],
      ),
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initialValue['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            isFavourite: _editProduct.isFavourite,
                            price: _editProduct.price,
                            title: value,
                            description: _editProduct.description,
                            imageUrl: _editProduct.imageUrl);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the title';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initialValue['price'],
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            isFavourite: _editProduct.isFavourite,
                            price: double.parse(value),
                            title: _editProduct.title,
                            description: _editProduct.description,
                            imageUrl: _editProduct.imageUrl);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide the price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please provide valid input';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please provide value greater that zero';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initialValue['description'],
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editProduct = Product(
                            id: _editProduct.id,
                            isFavourite: _editProduct.isFavourite,
                            price: _editProduct.price,
                            title: _editProduct.title,
                            description: value,
                            imageUrl: _editProduct.imageUrl);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide description';
                        }
                        if (value.length < 10) {
                          return 'Please provide min 10 char';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter Url')
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            initialValue: _initialValue['imageUrl'],
                            decoration: InputDecoration(labelText: 'ImageUrl'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _editProduct = Product(
                                  id: _editProduct.id,
                                  isFavourite: _editProduct.isFavourite,
                                  price: _editProduct.price,
                                  title: _editProduct.title,
                                  description: _editProduct.description,
                                  imageUrl: value);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please provide imageurl';
                              }
                              if ((!value.startsWith('http') &&
                                      !value.startsWith('https')) ||
                                  (!value.endsWith('.png') &&
                                      !value.endsWith('.jpeg') &&
                                      !value.endsWith('.jpg'))) {
                                return 'Please provide valid imageUrl';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
