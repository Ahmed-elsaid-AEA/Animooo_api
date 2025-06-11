import 'package:animooo_api/core/consts.dart';
import 'package:mysql1/mysql1.dart';

class AnimalModel {
  @override
  String toString() {
    return 'AnimalModel(id: $id, name: $name, description: $description, imagePath: $imagePath, price: $price, categoryId: $categoryId, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  int? id;
  String? name;
  String? description;
  String? imagePath;
  double? price;
  int? categoryId;
  int? userId;
  String? createdAt;
  String? updatedAt;

  AnimalModel({
    this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.categoryId,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });
  AnimalModel.fromID({
    required this.id,
    this.name,
    this.description,
    this.imagePath,
    this.price,
    this.categoryId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json[ConstsTables.kAnimalId],
      name: json[ConstsTables.kAnimalName],
      description: json[ConstsTables.kAnimalDescription] is Blob
          ? (json[ConstsTables.kAnimalDescription] as Blob).toString()
          : json[ConstsTables.kAnimalDescription],
      imagePath: json[ConstsTables.kAnimalImage],
      price: json[ConstsTables.kAnimalPrice],
      categoryId: json[ConstsTables.kCategoryId],
      userId: json[ConstsTables.kUserId],
      createdAt: json[ConstsTables.kAnimalCreatedAt].toString(),
      updatedAt: json[ConstsTables.kAnimalUpdateAt].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ConstsTables.kAnimalId: id,
      ConstsTables.kAnimalName: name,
      ConstsTables.kAnimalDescription: description,
      ConstsTables.kAnimalImage: imagePath,
      ConstsTables.kAnimalPrice: price,
      ConstsTables.kCategoryId: categoryId,
      ConstsTables.kUserId: userId,
      ConstsTables.kAnimalCreatedAt: createdAt.toString(),
      ConstsTables.kAnimalUpdateAt: updatedAt.toString(),
    };
  }
}
