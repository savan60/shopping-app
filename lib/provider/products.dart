import 'package:flutter/material.dart';
import 'package:fourth/model/httpException.dart';
import './product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  final String token;
  final String userid;
  List<Product> item = []; //[
  //   Product(
  //     id: 'p1',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p2',
  //     title: 'Trousers',
  //     description: 'A nice pair of trousers.',
  //     price: 59.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  //   ),
  //   Product(
  //     id: 'p3',
  //     title: 'Yellow Scarf',
  //     description: 'Warm and cozy - exactly what you need for the winter.',
  //     price: 19.99,
  //     imageUrl:
  //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  //   ),
  //   Product(
  //     id: 'p4',
  //     title: 'A Pan',
  //     description: 'Prepare any meal you want.',
  //     price: 49.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  //   ),
  // ];

     Products({this.token,this.userid,this.item});


  List<Product> get items {
    return [...item];
  }

  List<Product> get favItems {
    return item.where((prod) => prod.isFavourite).toList();
  }

  Product findbyId(String id) {
    return item.firstWhere((pro) => pro.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = 'https://shopapp1-b7199.firebaseio.com/products.json?auth=$token';
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'userId':userid,
          }));

      item.add(Product(
          id: json.decode(response.body)['name'],
          price: product.price,
          description: product.description,
          title: product.title,
          imageUrl: product.imageUrl));
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
  

  Future<void> updateProduct(String id, Product newproduct) async {
    final index = item.indexWhere((prod) => prod.id == id);
    final url = 'https://shopapp1-b7199.firebaseio.com/products/$id.json?auth=$token';
    print("index is " + index.toString());
    if (index >= 0) {
      await http.patch(url,
          body: json.encode({
            'title': newproduct.title,
            'imageUrl': newproduct.imageUrl,
            'description': newproduct.description,
            'price': newproduct.price,
          }));
      item[index] = newproduct;
      notifyListeners();
    }
  }

  Future<void> fetchAndSetProducts([bool filteruser=false]) async {
    final filterString=filteruser?'orderBy="userId"&equalTo="$userid"':'';
    final url = 'https://shopapp1-b7199.firebaseio.com/products.json?auth=$token&$filterString';
    final urlf= 'https://shopapp1-b7199.firebaseio.com/userFavourite/$userid.json?auth=$token';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData==null){
        return;
      }
      final favouriteStatus=await http.get(urlf);
      final favourite=json.decode(favouriteStatus.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, product) {
        loadedProducts.add(
          Product(
            title: product['title'],
            imageUrl: product['imageUrl'],
            description: product['description'],
            price: product['price'],
            id: key,
            isFavourite: favourite==null? false : favourite[key] ?? false,   
          ),
        );
      });
      item = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://shopapp1-b7199.firebaseio.com/products/$id.json?auth=$token';
    final exisitingProductIndex = item.indexWhere((prod) => prod.id == id);
    var exisitingProduct = item[exisitingProductIndex];
    item.removeAt(exisitingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      item.insert(exisitingProductIndex, exisitingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    } else {
      exisitingProduct = null;
    }
  }
}
