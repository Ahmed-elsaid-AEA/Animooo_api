import 'package:animooo_api/app/models/user_model.dart';
import 'package:animooo_api/core/consts.dart';
import 'package:animooo_api/core/database/connections.dart';
import 'package:animooo_api/core/database/crud.dart';
import 'package:mysql1/mysql1.dart';

class UserCrud extends Crud<UserModel> {
  @override
  Future<List<UserModel>> all() async {
    late final MySqlConnection conn;
    late List<UserModel> data = [];
    try {
      await ensureUserTablesExist();

      conn = await DBConnections.connect();
      final Results results =
          await conn.query('select * from ${ConstsTables.kUsersTable}');
      data = results.map((row) => UserModel.fromJson(row.fields)).toList();
    } catch (e) {
      print("error");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return data;
  }

  @override
  Future<UserModel?> find(UserModel model) async {
    late final MySqlConnection conn;
    UserModel? data;
    try {
      await ensureUserTablesExist();
      conn = await DBConnections.connect();
      final Results results = await conn.query(
          '''SELECT * FROM ${ConstsTables.kUsersTable} WHERE ${ConstsTables.kId} = ? ''',
          [model.id]);
      data = results.isEmpty ? null : UserModel.fromJson(results.first.fields);
    } catch (e) {
      print("error");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return data;
  }

  Future<UserModel?> findUsingMailAndPassword(UserModel usermodel) async {
    late final MySqlConnection conn;
    UserModel? data;
    try {
      await ensureUserTablesExist();
      conn = await DBConnections.connect();
      final Results results = await conn.query(
          '''SELECT * FROM ${ConstsTables.kUsersTable} WHERE ${ConstsTables.kEmail} = ?  
          AND ${ConstsTables.kPassword} = ? ''',
          [usermodel.email, usermodel.hashPassword]);
      data = results.isEmpty ? null : UserModel.fromJson(results.first.fields);
    } catch (e) {
      print("error");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return data;
  }

  Future<UserModel?> findUsingRefreshToken(UserModel usermodel) async {
    late final MySqlConnection conn;
    UserModel? data;
    print(usermodel.refreshToken);
    try {
      await ensureUserTablesExist();
      conn = await DBConnections.connect();
      final Results results = await conn.query(
          '''SELECT * FROM ${ConstsTables.kUsersTable} WHERE ${ConstsTables.kRefreshToken} = ?  
          ''',
          [
            usermodel.refreshToken,
          ]);
      data = results.isEmpty ? null : UserModel.fromJson(results.first.fields);
    } catch (e) {
      print("error");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return data;
  }

  Future<UserModel?> findUsingEmail(UserModel usermodel) async {
    late final MySqlConnection conn;
    UserModel? data;
    try {
      await ensureUserTablesExist();
      conn = await DBConnections.connect();
      final Results results = await conn.query(
          '''SELECT * FROM ${ConstsTables.kUsersTable} WHERE ${ConstsTables.kEmail} = ?
          ${(usermodel.accessToken != null) ? ' AND ${ConstsTables.kAccessToken} = ?' : ""}
           ''',
          [
            usermodel.email,
            if (usermodel.accessToken != null) usermodel.accessToken
          ]);
      data = results.isEmpty ? null : UserModel.fromJson(results.first.fields);
    } catch (e) {
      print("error");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return data;
  }

  Future<UserModel?> findVerfiyCode(UserModel usermodel) async {
    late final MySqlConnection conn;
    UserModel? data;
    try {
      await ensureUserTablesExist();
      print(usermodel.email);
      print(usermodel.verificationCode);
      conn = await DBConnections.connect();
      final Results results = await conn.query(
          '''SELECT * FROM ${ConstsTables.kUsersTable} WHERE 
          ${ConstsTables.kEmail} = ? AND
          ${ConstsTables.kVerificationCode} = ? ''',
          [usermodel.email, usermodel.verificationCode]);
      print(results);
      print(results.first.fields);
      data = results.isEmpty ? null : UserModel.fromJson(results.first.fields);
    } catch (e) {
      print("error");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return data;
  }

  @override
  Future<UserModel?> create(UserModel data) async {
    late final MySqlConnection conn;
    UserModel? user;
    try {
      await ensureUserTablesExist();

      conn = await DBConnections.connect();
      final result = await conn.query('''
        INSERT INTO users (${ConstsTables.kFirstName}, ${ConstsTables.kLastName},
         ${ConstsTables.kEmail}, 
         ${ConstsTables.kPhone},
         ${ConstsTables.kPassword},
         ${ConstsTables.kImagePath},
         ${ConstsTables.kVerificationCode}
         )
        VALUES (?, ?, ?, ?, ?, ?,?)
      ''', [
        data.firstName,
        data.lastName,
        data.email,
        data.phone,
        data.hashPassword,
        data.imagePath,
        data.verificationCode
      ]);
      user = result.insertId == null
          ? null
          : data.copyWith(
              id: result.insertId,
            );
    } catch (e) {
      print(e);
      print("error");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
    return user;
  }

  @override
  Future<UserModel?> update(UserModel data) async {
    late final MySqlConnection conn;
    UserModel? user;
    try {
      await ensureUserTablesExist();
      conn = await DBConnections.connect();
      String querey = '''UPDATE ${ConstsTables.kUsersTable} SET 
       ${(data.firstName != null) ? ",${ConstsTables.kFirstName} = ?" : ""}
       ${(data.lastName != null) ? ",${ConstsTables.kLastName} = ?" : ""}
       ${(data.email != null) ? ",${ConstsTables.kEmail} = ?" : ""}
       ${(data.phone != null) ? ",${ConstsTables.kPhone} = ?" : ""}
       ${(data.hashPassword != null) ? ",${ConstsTables.kPassword} = ?" : ""}
       ${(data.imagePath != null) ? ",${ConstsTables.kImagePath} = ?" : ""}
       ${(data.isVerified != null) ? ",${ConstsTables.kIsVerified} = ?" : ""}
       ${(data.refreshToken != null) ? ",${ConstsTables.kRefreshToken} = ?" : ""}
       ${(data.verificationCode != null) ? ",${ConstsTables.kVerificationCode} = ?" : ""}
       ${(data.accessToken != null) ? ",${ConstsTables.kAccessToken} = ?" : ""}
         WHERE
       ${(data.id != null) ? "${ConstsTables.kId} = ?" : "${ConstsTables.kEmail} = ?"}
 
          ''';
      querey = querey.replaceFirst(',', " ");
      List values = [
        if (data.firstName != null) data.firstName,
        if (data.lastName != null) data.lastName,
        if (data.email != null) data.email,
        if (data.phone != null) data.phone,
        if (data.hashPassword != null) data.hashPassword,
        if (data.imagePath != null) data.imagePath,
        if (data.isVerified != null) data.isVerified,
        if (data.refreshToken != null) data.refreshToken,
        if (data.verificationCode != null) data.verificationCode,
        if (data.accessToken != null) data.accessToken,
        (data.id != null) ? data.id : data.email
      ];
      print(querey);
      print(values);

      final Results results = await conn.query(querey, values);
      print(results.affectedRows);
      print(data.id);
      if (results.affectedRows != null) {
        return data.id == null
            ? await findUsingEmail(UserModel.fromEmail(email: data.email))
            : await find(UserModel.fromID(id: data.id));
      } else {
        user = null;
      }
    } catch (e) {
      print("error in update");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }

    return user;
  }
  //?New

  Future<UserModel?> updateVerification(UserModel data) async {
    late final MySqlConnection conn;
    UserModel? user;
    print(data.verificationCode);
    print(data.email);
    try {
      await ensureUserTablesExist();
      conn = await DBConnections.connect();
      String querey = '''UPDATE ${ConstsTables.kUsersTable} SET 
        ${ConstsTables.kVerificationCode} = ? 
       
         WHERE
       ${ConstsTables.kEmail} = ?
 
          ''';
      print(querey);

      List values = [data.verificationCode, data.email];

      final Results results = await conn.query(querey, values);

      if (results.affectedRows != null) {
        return data.id == null
            ? await findUsingEmail(UserModel.fromEmail(email: data.email))
            : await find(UserModel.fromID(id: data.id));
      } else {
        user = null;
      }
    } catch (e) {
      print("error in update $e");
    } finally {
      await DBConnections.closeDbConnection(conn);
    }

    return user;
  }

  @override
  Future<bool> delete(UserModel model) async {
    late final MySqlConnection conn;
    bool deleted = false;
    try {
      await ensureUserTablesExist();

      conn = await DBConnections.connect();

      final results =
          await conn.query('delete from users where id = @id', [model.id]);

      deleted = results.insertId == null ? false : true;
    } catch (e) {
      print("error in update");
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
      CREATE TABLE IF NOT EXISTS ${ConstsTables.kUsersTable} (
        ${ConstsTables.kId} BIGINT AUTO_INCREMENT PRIMARY KEY NOT NULL,
        ${ConstsTables.kFirstName} VARCHAR(100),
        ${ConstsTables.kLastName} VARCHAR(100),
        ${ConstsTables.kEmail} VARCHAR(100) UNIQUE,
        ${ConstsTables.kPhone} VARCHAR(20),
        ${ConstsTables.kPassword} VARCHAR(255),
        ${ConstsTables.kImagePath} VARCHAR(255),
        ${ConstsTables.kIsVerified} SMALLINT DEFAULT 0,
        ${ConstsTables.kVerificationCode} varchar(5),
        ${ConstsTables.kRefreshToken} varchar(255),
        ${ConstsTables.kAccessToken} varchar(255)
      )
    ''');

      // Add more table creation queries if needed
    } finally {
      await DBConnections.closeDbConnection(conn);
    }
  }
}
