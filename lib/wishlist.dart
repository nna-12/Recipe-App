import 'package:flutter/material.dart';

class WishlistPage extends StatelessWidget {
  final List<String> wishlistItems;
  final Function(int) removeFromWishlist;

  WishlistPage({
    required this.wishlistItems,
    required this.removeFromWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        title: Text('Wishlist',
          style: TextStyle(
            fontFamily: 'Charm',
            fontSize: 30.0,
            //color: Colors.white,
            fontWeight: FontWeight.bold,
          ),),
      ),

      body: wishlistItems.isEmpty
          ? Center(
        child: Text(
          'Wishlist is empty',

          style: TextStyle(
              fontFamily: 'Charm',
              fontSize: 24.0,
              fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: wishlistItems.length,
        itemBuilder: (context, index) {
          final item = wishlistItems[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '• $item',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      removeFromWishlist(index);
                    },
                  ),
                ),
              ),
              Divider(
                height: 0,
                thickness: 1,
                color: Colors.grey[300],
                indent: 16.0,
                endIndent: 16.0,
              ),
            ],
          );
        },
      ),
    );
  }
}
