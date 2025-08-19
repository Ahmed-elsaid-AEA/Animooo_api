import 'package:animooo_api/app/models/animal_model.dart';
import 'package:animooo_api/app/models/user_model.dart';
import 'package:animooo_api/core/consts.dart';
import 'package:animooo_api/core/database/connections.dart';
import 'package:animooo_api/core/database/crud.dart';
import 'package:mysql1/mysql1.dart';

class AnimalCrud extends Crud<AnimalModel> {
  @override
  Future<List<AnimalModel>> all() async {
    late final MySqlConnection conn;
    late List<AnimalModel> data = [];
    try {
      await ensureUserTablesExist();

      conn = await DBConnections.connect();
      final Results results =
          await conn.query('select * from ${ConstsTables.kAnimalsTable}');
      data = results.map((row) => AnimalModel.fromJson(row.fields)).toList();
    } catch (e) {
      print("error");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return data;
  }

  @override
  Future<AnimalModel?> find(AnimalModel model) async {
    late final MySqlConnection conn;
    AnimalModel? data;
    try {
      await ensureUserTablesExist();
      conn = await DBConnections.connect();
      final Results results = await conn.query(
          '''SELECT * FROM ${ConstsTables.kAnimalsTable} WHERE ${ConstsTables.kAnimalId} = ? ''',
          [model.id]);
      data =
          results.isEmpty ? null : AnimalModel.fromJson(results.first.fields);
    } catch (e) {
      print("error");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return data;
  }

  @override
  Future<AnimalModel?> create(AnimalModel animal) async {
    late final MySqlConnection conn;
    AnimalModel? data;
    try {
      await ensureUserTablesExist();

      conn = await DBConnections.connect();
      final result = await conn.query('''
        INSERT INTO ${ConstsTables.kAnimalsTable} 
        (${ConstsTables.kAnimalName},
         ${ConstsTables.kAnimalDescription},
         ${ConstsTables.kAnimalImage}, 
         ${ConstsTables.kAnimalPrice},
         ${ConstsTables.kCategoryId},
         ${ConstsTables.kUserId}
          )
        VALUES (?, ?, ?, ?, ?, ?)
      ''', [
        animal.name,
        animal.description,
        animal.imagePath,
        animal.price,
        animal.categoryId,
        animal.userId
      ]);

      data = result.insertId == null
          ? null
          : AnimalModel(
              categoryId: animal.categoryId,
              id: result.insertId,
              name: animal.name,
              description: animal.description,
              imagePath: animal.imagePath,
              price: animal.price,
              userId: animal.userId,
              createdAt: DateTime.now().toString(),
              updatedAt: DateTime.now().toString(),
            );
    } catch (e) {
      print(e);
      print("error");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return data;
  }

  @override
  Future<AnimalModel?> update(AnimalModel data) async {
    late final MySqlConnection conn;
    AnimalModel? animalModel;
    print(data);
    try {
      await ensureUserTablesExist();
      conn = await DBConnections.connect();
      String querey = '''UPDATE ${ConstsTables.kAnimalsTable} SET 
       ${(data.name != null) ? ",${ConstsTables.kAnimalName} = ?" : ""}
       ${(data.description != null) ? ",${ConstsTables.kAnimalDescription} = ?" : ""}
       ${(data.imagePath != null) ? ",${ConstsTables.kAnimalImage} = ?" : ""}
       ${(data.price != null) ? ",${ConstsTables.kAnimalPrice} = ?" : ""}
       ${(data.categoryId != null) ? ",${ConstsTables.kCategoryId} = ?" : ""} 
         WHERE
      ${ConstsTables.kAnimalId} = ?
 
          ''';
      querey = querey.replaceFirst(',', " ");
      List values = [
        if (data.name != null) data.name,
        if (data.description != null) data.description,
        if (data.imagePath != null) data.imagePath,
        if (data.price != null) data.price,
        if (data.categoryId != null) data.categoryId,
        data.id
      ];
      print(querey);
      print(values);

      final Results results = await conn.query(querey, values);
      print(results.affectedRows);
      print(data.id);
      if (results.affectedRows != null) {
        animalModel = await find(AnimalModel.fromID(id: data.id));
      } else {
        animalModel = null;
      }
    } catch (e) {
      print("error in update $e");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }

    return animalModel;
  }

  @override
  Future<bool> delete(AnimalModel model) async {
    late final MySqlConnection conn;
    bool deleted = false;
    try {
      await ensureUserTablesExist();

      conn = await DBConnections.connect();

      final results = await conn.query(
          'DELETE FROM ${ConstsTables.kAnimalsTable} where ${ConstsTables.kAnimalId} = ?',
          [model.id]);

      deleted = results.insertId == null ? false : true;
    } catch (e) {
      print("error in delete $e");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }

    return deleted;
  }

  static Future<void> ensureUserTablesExist() async {
    final conn = await DBConnections.connect();
    try {
      // Example table creation
      await conn.query('''
            CREATE TABLE IF NOT EXISTS ${ConstsTables.kAnimalsTable}(
                ${ConstsTables.kAnimalId} BIGINT AUTO_INCREMENT PRIMARY KEY NOT NULL,
                ${ConstsTables.kAnimalName} VARCHAR(100) NOT NULL UNIQUE,
                ${ConstsTables.kAnimalDescription} TEXT,
                ${ConstsTables.kAnimalImage} VARCHAR(512),
                ${ConstsTables.kAnimalPrice} FLOAT,
                ${ConstsTables.kCategoryId} BIGINT NOT NULL,
                ${ConstsTables.kUserId} BIGINT NOT NULL,
                ${ConstsTables.kAnimalCreatedAt} TIMESTAMP  DEFAULT CURRENT_TIMESTAMP, 
                ${ConstsTables.kAnimalUpdateAt} TIMESTAMP  DEFAULT CURRENT_TIMESTAMP, 
                CONSTRAINT fk_category_animal
                FOREIGN KEY (${ConstsTables.kCategoryId}) REFERENCES ${ConstsTables.kCategoryTable}(${ConstsTables.kCategoryId})
                ON DELETE CASCADE
                ON UPDATE CASCADE,
                    
                CONSTRAINT fk_user_animal
                FOREIGN KEY (${ConstsTables.kUserId}) REFERENCES ${ConstsTables.kUsersTable}(${ConstsTables.kId})
                ON DELETE CASCADE
                ON UPDATE CASCADE
                );
    ''');

      // Add more table creation queries if needed
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
  }
}
/**
 CREATE TABLE IF NOT EXISTS animals(
id BIGINT AUTO_INCREMENT PRIMARY KEY NOT NULL,
animal_name VARCHAR(100),
animal_description TEXT,
animal_image VARCHAR(512),
animal_price FLOAT,
category_id BIGINT NOT NULL,
user_id BIGINT NOT NULL,
animal_created_at TIMESTAMP  DEFAULT CURRENT_TIMESTAMP, 
animal_update_at TIMESTAMP  DEFAULT CURRENT_TIMESTAMP, 
CONSTRAINT fk_category_animal
FOREIGN KEY (category_id) REFERENCES categories(id_category)
ON DELETE CASCADE
ON UPDATE CASCADE,
    
CONSTRAINT fk_user_animal
FOREIGN KEY (user_id) REFERENCES users(id)
ON DELETE CASCADE
ON UPDATE CASCADE
);
 */
