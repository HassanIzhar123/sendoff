class Admin {
  final String email;
  final String firstName;
  final String lastName;
  final String userId;
  final String image;

  Admin({required this.email, required this.firstName, required this.lastName, required this.userId, required this.image});

  factory Admin.fromFireStore(Map<String, dynamic> data, String documentId) {
    return Admin(
      email: data.containsKey("email") ? data["email"] : '',
      firstName: data.containsKey("firstName") ? data['firstName'] : '',
      lastName: data.containsKey("lastName") ? data['lastName'] : "",
      userId: documentId,
      image:  data.containsKey("image") ? data['image'] : "",
    );
  }

  @override
  String toString() {
    return 'Admin{email: $email, firstName: $firstName, lastName: $lastName, userId: $userId, image: $image}';
  }
}
