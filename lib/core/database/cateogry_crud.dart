import 'package:animooo_api/app/models/category_model.dart';
import 'package:animooo_api/core/consts.dart';
import 'package:animooo_api/core/database/connections.dart';
import 'package:animooo_api/core/database/crud.dart';
import 'package:mysql1/mysql1.dart';

class CategoryCrud extends Crud<CategoryModel> {
  @override
  Future<List<CategoryModel>> all() async {
    late final MySqlConnection conn;
    late List<CategoryModel> data = [];
    try {
      await ensureCategoryTablesExist();

      conn = await DBConnections.connect();
      final Results results =
          await conn.query('SELECT * FROM ${ConstsTables.kCategoryTable}');
      // print(results.map((row) => row.fields).toList());
      data = results.map((row) {
        var a = CategoryModel.fromJson(row.fields);
        print(a);
        return a;
      }).toList();
    } catch (e) {
      print(e);
      print("error");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return data;
  }

  @override
  Future<CategoryModel?> create(CategoryModel data) async {
    late final MySqlConnection conn;
    CategoryModel? user;
    try {
      await ensureCategoryTablesExist();

      conn = await DBConnections.connect();
      print(data);
      String querey = '''
        INSERT INTO ${ConstsTables.kCategoryTable} (
         ${ConstsTables.kNameCategory},
         ${ConstsTables.kDescriptionCategory},
         ${ConstsTables.kImageCategory}, 
         ${ConstsTables.kUserIdCategory}
         )
        VALUES (?, ?, ?, ?)
      ''';
      List args = [
        data.nameCategory,
        data.descriptionCategory,
        data.imageCategory,
        data.userId
      ];
      print(args);
      print(querey);
      final result = await conn.query(querey, args);
      print(result.insertId);
      user = result.insertId == null
          ? null
          : CategoryModel(
              id: result.insertId,
              nameCategory: data.nameCategory,
              descriptionCategory: data.descriptionCategory,
              imageCategory: data.imageCategory,
              userId: data.userId,
              createdAt: DateTime.now().toString(),
              updatedAt: DateTime.now().toString(),
            );
    } catch (e) {
      print("error");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return user;
  }

  @override
  Future<CategoryModel?> update(CategoryModel data) async {
    late final MySqlConnection conn;
    CategoryModel? category;
    try {
      await ensureCategoryTablesExist();
      conn = await DBConnections.connect();
      String querey = '''UPDATE ${ConstsTables.kCategoryTable} SET
        ${(data.nameCategory != null) ? ",${ConstsTables.kNameCategory} = ?" : ""}
       ${(data.descriptionCategory != null) ? ",${ConstsTables.kDescriptionCategory} = ?" : ""}
       ${(data.imageCategory != null) ? ",${ConstsTables.kImageCategory} = ?" : ""}
       ${(data.updatedAt != null) ? ",${ConstsTables.kUpdatedAtCategory} = ?" : ""}
       
         WHERE
         ${ConstsTables.kCategoryId} = ?

          ''';
      querey = querey.replaceFirst(',', " ");
      List values = [
        if (data.nameCategory != null) data.nameCategory,
        if (data.descriptionCategory != null) data.descriptionCategory,
        if (data.imageCategory != null) data.imageCategory,
        if (data.updatedAt != null) data.updatedAt,
        data.id
      ];
      print(querey);
      print(values);

      final Results results = await conn.query(querey, values);
      print(results.affectedRows);
      print(data.id);
      if (results.affectedRows != null) {
        category = await find(CategoryModel(id: data.id));
      } else {
        category = null;
      }
    } catch (e) {
      print("error in update");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }

    return category;
  }

  @override
  Future<bool> delete(CategoryModel model) async {
    late final MySqlConnection conn;
    bool deleted = false;
    try {
      await ensureCategoryTablesExist();

      conn = await DBConnections.connect();

      final results = await conn.query(
          'delete from ${ConstsTables.kCategoryTable} where ${ConstsTables.kCategoryId} = ?',
          [model.id]);

      deleted = results.insertId == null ? false : true;
    } catch (e) {
      print(e);
      print("error in delete");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }

    return deleted;
  }

  @override
  Future<CategoryModel?> find(CategoryModel model) async {
    late final MySqlConnection conn;
    CategoryModel? data;
    try {
      await ensureCategoryTablesExist();
      String query =
          '''SELECT * FROM ${ConstsTables.kCategoryTable} WHERE ${ConstsTables.kCategoryId} = ? ''';

      conn = await DBConnections.connect();
      final Results results = await conn.query(query, [model.id]);
      print(results.first.fields);
      data = results.first.fields.isEmpty
          ? null
          : CategoryModel.fromJson(results.first.fields);
    } catch (e) {
      print("error in find");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return data;
  }

  static Future<void> ensureCategoryTablesExist() async {
    final conn = await DBConnections.connect();
    try {
      String query = '''
          CREATE TABLE IF NOT EXISTS ${ConstsTables.kCategoryTable} (
          ${ConstsTables.kCategoryId} BIGINT PRIMARY KEY AUTO_INCREMENT NOT NULL,
          ${ConstsTables.kNameCategory} VARCHAR(255) NOT NULL  UNIQUE,
          ${ConstsTables.kDescriptionCategory} TEXT,
          ${ConstsTables.kImageCategory} VARCHAR(512),
          ${ConstsTables.kCreatedAtCategory} TIMESTAMP  DEFAULT CURRENT_TIMESTAMP, 
          ${ConstsTables.kUpdatedAtCategory} TIMESTAMP  DEFAULT CURRENT_TIMESTAMP, 
          ${ConstsTables.kUserIdCategory} BIGINT NOT NULL,
          CONSTRAINT fk_user
            FOREIGN KEY (${ConstsTables.kUserIdCategory}) REFERENCES ${ConstsTables.kUsersTable}(${ConstsTables.kId})
              ON DELETE CASCADE
              ON UPDATE CASCADE
      );
      
      ''';

      // Example table creation
      await conn.query(query);

      // Add more table creation queries if needed
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
  }
}
/** 
 CREATE TABLE category (
    id BIGINT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    name VARCHAR(255) NOT NULL  UNIQUE,
    description TEXT,
    image_path VARCHAR(512),
    created_at TIMESTAMP  DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP  DEFAULT CURRENT_TIMESTAMP, 
    user_id BIGINT NOT NULL,
    CONSTRAINT fk_user
 	    FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Optional: Create indexes for better performance
CREATE INDEX idx_category_user_id ON category(user_id);
CREATE INDEX idx_category_name ON category(name);

 */
