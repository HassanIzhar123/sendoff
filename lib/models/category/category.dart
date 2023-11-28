
class Category {
  final String documentId;
  final String name;
  final String image;
  final dynamic description;
  final double rating, reviews;
  final int products;

  @override
  String toString() {
    return 'Category{documentId: $documentId, name: $name, image: $image, description: $description, rating: $rating, reviews: $reviews, products: $products, status: $status, popular: $popular, talktoHuman: $talktoHuman, order: $order}';
  }

  final String status, popular;
  bool talktoHuman = false;
  final int order;

  Category({
    required this.documentId,
    required this.name,
    required this.image,
    required this.description,
    required this.products,
    required this.status,
    required this.popular,
    required this.rating,
    required this.reviews,
    required this.talktoHuman,
    required this.order,
  });

  factory Category.fromFireStore(Map<String, dynamic> data, String documentId, bool isArticle) {
    return Category(
      documentId: documentId,
      name: data.containsKey("name") ? data["name"] : '',
      image: data.containsKey("image") ? data["image"] : '',
      description: !isArticle
          ? (data.containsKey("description") ? data['description'] : '')
          : (data.containsKey("description") ? data['description'] : []),
      products: data.containsKey("products") ? (data['products'] ?? 0) : 0,
      status: data.containsKey("status") ? data["status"] : "false",
      popular: data.containsKey("popular") ? data["popular"] : "false",
      talktoHuman: data.containsKey("talktoHuman") ? data["talktoHuman"] : false,
      rating: data.containsKey("rating") ? (data['rating'] ?? 0.0).toDouble() : 0.0,
      reviews: data.containsKey("reviews") ? (data['reviews'] ?? 0.0).toDouble() : 0.0,
      order: data.containsKey("order") ? (data['order'] ?? 0).toInt() : 0,
    );
  }
}
