import 'package:rxdart/rxdart.dart';

import '../../models/category/category.dart';

abstract class BaseRepository {
  Future<BehaviorSubject<List<Category>>> getCategories();
}
