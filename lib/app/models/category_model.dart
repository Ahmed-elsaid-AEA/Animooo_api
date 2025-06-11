import 'package:animooo_api/core/consts.dart';
import 'package:mysql1/mysql1.dart';

class CategoryModel {
  int? id;
  String? nameCategory;
  String? descriptionCategory;
  String? imageCategory;
  String? createdAt;
  String? updatedAt;
  int? userId;

  CategoryModel({
    this.id,
    this.nameCategory,
    this.descriptionCategory,
    this.imageCategory,
    this.createdAt,
    this.updatedAt,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nameCategory,
      'description': descriptionCategory,
      'imagePath': imageCategory,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) { 
    return CategoryModel(
      //{category_id: 3, name_category: dfdf, description_category: dffdd, image_category: http://127.0.0.1:8000/api/uploads/1749550549436.png, created_at_category: 2025-06-10 16:50:57.000Z, updated_at_category: 2025-06-10 16:50:57.000Z, user_id_category: 1
      id: json[ConstsTables.kCategoryId],
      nameCategory: json[ConstsTables.kNameCategory],
      descriptionCategory: json[ConstsTables.kDescriptionCategory] is Blob
          ? (json[ConstsTables.kDescriptionCategory] as Blob).toString()
          : json[ConstsTables.kDescriptionCategory],
      imageCategory: json[ConstsTables.kImageCategory].toString(),
      createdAt: json[ConstsTables.kCreatedAtCategory]?.toString(),
      updatedAt: json[ConstsTables.kUpdatedAtCategory]?.toString(),
      userId: json[ConstsTables.kUserIdCategory],
    );
  }
}
