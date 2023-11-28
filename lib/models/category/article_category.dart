class ArticleCategory {
  String documentId;
  final String name;
  final List<String> descriptions;

  ArticleCategory({required this.documentId, required this.name, required this.descriptions});

  factory ArticleCategory.fromFireStore(Map<String, dynamic> data, String documentId) {
    return ArticleCategory(
      documentId: documentId,
      name: data.containsKey("name") ? data["name"] : '',
      descriptions: data.containsKey("description") ? data['description'] : [],
    );
  }
}
