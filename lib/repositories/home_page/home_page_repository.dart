import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/category/category.dart';
import 'base_repository.dart';

class HomePageRepository extends BaseRepository {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  Future<BehaviorSubject<List<Category>>> getCategories() async {
    BehaviorSubject<List<Category>>? combinedStream = BehaviorSubject<List<Category>>();
    Stream<List<Category>> categoriesStream = _fireStore
        .collection('categories')
        .where('popular', isEqualTo: "true")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
              (doc) => Category.fromFireStore(doc.data(), doc.id, false),
            )
            .toList());
    Stream<List<Category>> articlesStream = _fireStore
        .collection('Advice&article')
        .where('popular', isEqualTo: "true")
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
              (doc) => Category.fromFireStore(doc.data(), doc.id, true),
            )
            .toList());
    CombineLatestStream.combine2<List<Category>, List<Category>, List<Category>>(
      categoriesStream,
      articlesStream,
      (categories, articles) => [...categories, ...articles],
    ).listen((combinedData) {
      combinedStream.add(combinedData);
    });
    return combinedStream;
  }
}
