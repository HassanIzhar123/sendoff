class RatingReviews {
  RatingReviews({
    required this.productId,
    required this.productName,
    required this.rating,
    required this.review,
    required this.userName,
  });

  String productId;
  String productName;
  double rating;
  String review;
  String userName;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'rating': rating,
      'review': review,
      'userName': userName,
    };
  }

  @override
  String toString() {
    return 'RatingReviews{productName: $productName, rating: $rating, review: $review}';
  }
}
