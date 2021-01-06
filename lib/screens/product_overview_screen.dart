import 'package:flutter/material.dart';
import 'package:fourth/badge.dart';
import 'package:fourth/widget/app_drawer.dart';
import '../widget/product_grid.dart';
import '../provider/cart.dart';
import 'package:provider/provider.dart';
import '../provider/products.dart';
import 'cart_screen.dart';

enum FavourCat {
  All,
  Favourite,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}



class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var isInitial=true;
  var isLoading=false;

  @override
  void didChangeDependencies() {
    if(isInitial){
      setState(() {
        isLoading=true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_){
        setState(() {
            isLoading=false;
        });
      });
    }
    isInitial=false;
    super.didChangeDependencies();
  }
  var _showOnlyFavourite = false;
  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(
        title: Text('Shopping Items'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FavourCat selected) {
              setState(() {
                if (selected == FavourCat.All) {
                  _showOnlyFavourite = false;
                } else {
                  _showOnlyFavourite = true;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FavourCat.Favourite,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FavourCat.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routename);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: isLoading ? Center(child: CircularProgressIndicator(),) : ProductGrid(_showOnlyFavourite),
    );
    return scaffold;
  }
}
