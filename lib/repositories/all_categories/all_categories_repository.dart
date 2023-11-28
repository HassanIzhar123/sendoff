import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendoff/models/Search/category_product.dart';
import 'package:sendoff/models/product/product.dart';
import 'package:sendoff/models/product/rating_reviews.dart';
import '../../models/category/category.dart';
import 'base_repository.dart';

class AllCategoriesRepository extends BaseRepository {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  Future<Stream<List<Category>>> getCategories() async {
    Stream<List<Category>> categoriesStream =
        FirebaseFirestore.instance.collection('categories').snapshots().map((snapshot) => snapshot.docs
            .map(
              (doc) => Category.fromFireStore(doc.data(), doc.id, false),
            )
            .toList());
    return categoriesStream;
  }

  Future<List<CategoryProduct>> getCategoryProducts() async {
    List<CategoryProduct> categoryProductList = [];
    final QuerySnapshot categoryQuerySnapshot = await _fireStore.collection('categories').get();

    List<Category> categoryList = categoryQuerySnapshot.docs.map((doc) {
      return Category.fromFireStore(doc.data() as Map<String, dynamic>, doc.id, false);
    }).toList();

    await Future.wait(
      categoryList.map(
        (category) async {
          categoryProductList.add(CategoryProduct(CategoryOrProduct.category, category, null));

          final QuerySnapshot productQuerySnapshot =
              await _fireStore.collection('products').where('categoryId', isEqualTo: category.documentId).get();

          List<Product> products = [];

          for (QueryDocumentSnapshot productDoc in productQuerySnapshot.docs) {
            Product product = Product.fromFireStore(productDoc.data() as Map<String, dynamic>, productDoc.id, false);

            QuerySnapshot reviewsQuerySnapshot = await _fireStore
                .collection('reviews')
                .where('productId', isEqualTo: productDoc.id)
                .where('rating', isGreaterThanOrEqualTo: 4.0)
                .limit(5)
                .get();

            List<RatingReviews> reviews = reviewsQuerySnapshot.docs.map(
              (reviewDoc) {
                return RatingReviews(
                  productId: reviewDoc['productId'],
                  productName: reviewDoc['productName'],
                  rating: double.parse(reviewDoc['rating'].toString()),
                  review: reviewDoc['review'],
                  userName: reviewDoc['userName'],
                );
              },
            ).toList();

            product.ratingReviews = reviews;
            products.add(product);
          }

          final QuerySnapshot articleQuerySnapshot =
              await _fireStore.collection('Advice&article').where('categoryId', isEqualTo: category.documentId).get();

          for (QueryDocumentSnapshot productDoc in articleQuerySnapshot.docs) {
            Product product = Product.fromFireStore(productDoc.data() as Map<String, dynamic>, productDoc.id, true);

            QuerySnapshot reviewsQuerySnapshot = await _fireStore
                .collection('reviews')
                .where('productId', isEqualTo: productDoc.id)
                .where('rating', isGreaterThanOrEqualTo: 4.0)
                .limit(5)
                .get();

            List<RatingReviews> reviews = reviewsQuerySnapshot.docs.map(
              (reviewDoc) {
                return RatingReviews(
                  productId: reviewDoc['productId'],
                  productName: reviewDoc['productName'],
                  rating: double.parse(reviewDoc['rating'].toString()),
                  review: reviewDoc['review'],
                  userName: reviewDoc['userName'],
                );
              },
            ).toList();

            product.ratingReviews = reviews;
            products.add(product);
          }

          categoryProductList.addAll(
            products.map(
              (product) => CategoryProduct(CategoryOrProduct.product, null, product),
            ),
          );
        },
      ),
    );
    return categoryProductList;
  }
}
