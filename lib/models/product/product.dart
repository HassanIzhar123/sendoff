
import 'rating_reviews.dart';

class Product {
  final String documentId, categoryId;
  final String name, description, category;

  // @override
  // String toString() {
  //   return 'Product{documentId: $documentId, categoryId: $categoryId, name: $name, description: $description, category: $category, price: $price, quantity: $quantity, rating: $rating, reviews: $reviews, finalPrice: $finalPrice, finalQuantity: $finalQuantity, images: $images, additionalInfo: $additionalInfo, productMaterial: $productMaterial, averageRating: $averageRating, ratingReviews: $ratingReviews, isArticleProduct: $isArticleProduct}';
  // }

  final double price, quantity, rating;

  @override
  String toString() {
    return 'Product{name: $name}';
  }

  final String reviews;
  double finalPrice;
  int finalQuantity;
  final List<dynamic> images;
  final String additionalInfo;
  final String productMaterial;
  final double averageRating;
  List<RatingReviews> ratingReviews;
  final bool isArticleProduct;

  Product({
    required this.documentId,
    required this.categoryId,
    required this.category,
    required this.name,
    required this.description,
    required this.images,
    required this.price,
    required this.quantity,
    required this.rating,
    required this.reviews,
    required this.finalPrice,
    required this.finalQuantity,
    required this.additionalInfo,
    required this.productMaterial,
    required this.ratingReviews,
    required this.averageRating,
    required this.isArticleProduct,
  });

  factory Product.fromFireStore(Map<String, dynamic> data, String documentId, bool isArticleProduct) {
    dynamic priceValue = data.containsKey("price") ? data['price'] : 0.0;
    dynamic quantityValue = data.containsKey("quantity") ? data['quantity'] : 0.0;
    dynamic reviewsValue = data.containsKey("reviews") ? data['reviews'] : 0.0;
    dynamic ratingValue = data.containsKey("rating") ? data['rating'] : 0.0;
    dynamic averageRatingValue = data.containsKey("averageRating") ? data['averageRating'] : 0.0;
    return Product(
      documentId: documentId,
      categoryId: data.containsKey("categoryId") ? data['categoryId'] : '',
      category: data.containsKey("category") ? data['category'] : '',
      name: data.containsKey("name") ? data['name'] : '',
      description: data.containsKey("description") ? data['description'] : '',
      images: data.containsKey("images") ? data['images'] : [],
      price: priceValue is int ? priceValue.toDouble() : (priceValue is double ? priceValue : 0.0),
      quantity: quantityValue is int ? quantityValue.toDouble() : (quantityValue is double ? quantityValue : 0.0),
      rating: ratingValue is int ? ratingValue.toDouble() : (ratingValue is double ? ratingValue : 0.0),
      reviews: reviewsValue is String
          ? reviewsValue
          : reviewsValue is int
              ? reviewsValue.toDouble().toString()
              : (reviewsValue is double ? reviewsValue : 0.0).toString(),
      finalPrice: 0.0,
      finalQuantity: 0,
      additionalInfo: data.containsKey("additionalInfo") ? data["additionalInfo"] : "",
      productMaterial: data.containsKey("productMaterial") ? data["productMaterial"] : "",
      ratingReviews: data.containsKey("ratingReviews") ? data["ratingReviews"] : [],
      averageRating: averageRatingValue is int
          ? averageRatingValue.toDouble()
          : (averageRatingValue is double ? averageRatingValue : 0.0),
      isArticleProduct: isArticleProduct,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'categoryId': categoryId,
      'category': category,
      'name': name,
      'description': description,
      'images': images,
      'price': price,
      'quantity': quantity,
      'rating': rating,
      'reviews': reviews,
      'finalPrice': finalPrice,
      'finalQuantity': finalQuantity,
      'additionalInfo': additionalInfo,
      'productMaterial': productMaterial,
      'ratingReviews': ratingReviews.map((review) => review.toJson()).toList(),
      'averageRating': averageRating,
      'isArticleProduct': isArticleProduct,
    };
  }

  factory Product.fromJson(Map<String, dynamic> data) {
    dynamic priceValue = data.containsKey("price") ? data['price'] : 0.0;
    dynamic quantityValue = data.containsKey("quantity") ? data['quantity'] : 0.0;
    dynamic reviewsValue = data.containsKey("reviews") ? data['reviews'] : 0.0;
    dynamic ratingValue = data.containsKey("rating") ? data['rating'] : 0.0;
    dynamic averageRatingValue = data.containsKey("averageRating") ? data['averageRating'] : 0.0;
    return Product(
      documentId: data.containsKey("documentId") ? data["documentId"] : "",
      categoryId: data.containsKey("categoryId") ? data['categoryId'] : '',
      category: data.containsKey("category") ? data['category'] : '',
      name: data.containsKey("name") ? data['name'] : '',
      description: data.containsKey("description") ? data['description'] : '',
      images: data.containsKey("images") ? data['images'] : [],
      price: priceValue is int ? priceValue.toDouble() : (priceValue is double ? priceValue : 0.0),
      quantity: quantityValue is int ? quantityValue.toDouble() : (quantityValue is double ? quantityValue : 0.0),
      rating: ratingValue is int ? ratingValue.toDouble() : (ratingValue is double ? ratingValue : 0.0),
      reviews: reviewsValue is String
          ? reviewsValue
          : reviewsValue is int
              ? reviewsValue.toDouble().toString()
              : (reviewsValue is double ? reviewsValue : 0.0).toString(),
      finalPrice: data['finalPrice'],
      finalQuantity: data['finalQuantity'],
      additionalInfo: data.containsKey("additionalInfo") ? data["additionalInfo"] : "",
      productMaterial: data.containsKey("productMaterial") ? data["productMaterial"] : "",
      ratingReviews: data.containsKey("RatingReviews") ? data["RatingReviews"] : [],
      averageRating: averageRatingValue is int
          ? averageRatingValue.toDouble()
          : (averageRatingValue is double ? averageRatingValue : 0.0),
      isArticleProduct: data.containsKey("isArticleProduct") ? data["isArticleProduct"] : false,
    );
  }
}
