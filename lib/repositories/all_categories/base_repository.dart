import '../../models/category/category.dart';

abstract class BaseRepository {
  Future<Stream<List<Category>>> getCategories();
}
