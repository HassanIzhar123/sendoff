import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendoff/models/product/rating_reviews.dart';
import '../../models/product/product.dart';
import 'base_repository.dart';

class ProductsRepository extends BaseRepository {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  Future<List<Product>> getProductsForCategory(String categoryID) async {
    try {
      final QuerySnapshot productQuerySnapshot =
          await _fireStore.collection('products').where('categoryId', isEqualTo: categoryID).get();
      List<Product> products = [];
      for (QueryDocumentSnapshot productDoc in productQuerySnapshot.docs) {
        Product product = Product.fromFireStore(productDoc.data() as Map<String, dynamic>, productDoc.id, false);
        QuerySnapshot reviewsQuerySnapshot = await _fireStore
            .collection('reviews')
            .where('productId', isEqualTo: productDoc.id)
            .where('rating', isGreaterThanOrEqualTo: 4.0)
            .limit(5)
            .get();
        List<RatingReviews> reviews = reviewsQuerySnapshot.docs.map((reviewDoc) {
          return RatingReviews(
            productId: reviewDoc['productId'],
            productName: reviewDoc['productName'],
            rating: double.parse(reviewDoc['rating'].toString()),
            review: reviewDoc['review'],
            userName: reviewDoc['userName'],
          );
        }).toList();
        product.ratingReviews = reviews;
        products.add(product);
      }
      final QuerySnapshot articleQuerySnapshot =
          await _fireStore.collection('Advice&article').where('categoryId', isEqualTo: categoryID).get();
      for (QueryDocumentSnapshot productDoc in articleQuerySnapshot.docs) {
        Product product = Product.fromFireStore(productDoc.data() as Map<String, dynamic>, productDoc.id, true);
        QuerySnapshot reviewsQuerySnapshot = await _fireStore
            .collection('reviews')
            .where('productId', isEqualTo: productDoc.id)
            .where('rating', isGreaterThanOrEqualTo: 4.0)
            .limit(5)
            .get();
        List<RatingReviews> reviews = reviewsQuerySnapshot.docs.map((reviewDoc) {
          return RatingReviews(
            productId: reviewDoc['productId'],
            productName: reviewDoc['productName'],
            rating: double.parse(reviewDoc['rating'].toString()),
            review: reviewDoc['review'],
            userName: reviewDoc['userName'],
          );
        }).toList();
        product.ratingReviews = reviews;
        products.add(product);
      }
      // products.sort((a, b) => b.averageRating.compareTo(a.averageRating));
      products.sort((a, b) {
        int ratingComparison = b.averageRating.compareTo(a.averageRating);
        if (ratingComparison != 0) {
          return ratingComparison;
        } else {
          return a.price.compareTo(b.price);
        }
      });
      return products;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
}
