import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavourite = false});

  Future<void> toogleTheFavourite(String token,String user_id) async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url = 'https://shopapp1-b7199.firebaseio.com/userFavourite/$user_id/$id.json?auth=$token';
    try {
      final response=await http.put(
        url,
        body: json.encode(
            isFavourite,
        ),
      );
      if(response.statusCode>=400){
        isFavourite=oldStatus;
        notifyListeners();
      }
    } catch (error) {
      isFavourite=oldStatus;
      notifyListeners();
    }
  }
}
