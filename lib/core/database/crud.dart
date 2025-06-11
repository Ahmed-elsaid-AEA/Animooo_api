abstract class Crud<T> {
  Future<List<T>> all();

  Future<T?> find(T model);

  Future<T?> create(T data);

  Future<T?> update(T data);

  Future<bool> delete(T model);
}
