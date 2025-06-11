import 'dart:io';

import 'package:animooo_api/app/models/category_model.dart';
import 'package:animooo_api/core/consts.dart';
import 'package:animooo_api/core/database/cateogry_crud.dart';
import 'package:animooo_api/core/helper/store_images.dart';
import 'package:animooo_api/core/helper/tokens.dart';
import 'package:vania/vania.dart';

class CategoryController extends Controller {
  Future<Response> getAllCategory(Request request) async {
    String? token = request.header(ConstsValues.kAuthorization)?.toString();

    if (token == null) {
      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.badRequest,
        ConstsValues.kError: [ConstsValues.kTokenIsRequired],
      }, HttpStatus.badRequest);
    } else {
      ({String? email, int? id, bool isValid})? isValid = await tokenIsValid(
        token.replaceFirst("Bearer ", ''),
      );
      if (!isValid.isValid) {
        return Response.json({
          ConstsValues.kStatusCode: HttpStatus.unauthorized,
          ConstsValues.kError: [ConstsValues.kInvalidOrExpiredToken],
        }, HttpStatus.unauthorized);
      } else {
        CategoryCrud categoryCrud = CategoryCrud();
        List<CategoryModel> categories = await categoryCrud.all();
        return Response.json({
          ConstsValues.kStatusCode: HttpStatus.ok,
          ConstsValues.kCategories: categories,
        }, HttpStatus.ok);
      }
    }
  }

  Future<Response> createNewCategory(Request request) async {
    final name = request.input(ConstsValues.kName)?.toString().trim();
    final description =
        request.input(ConstsValues.kDescription)?.toString().trim();
    final imageFile = request.file(ConstsValues.kImage);
    final token = request.header(ConstsValues.kAuthorization)?.toString();
    // check if any field is null
    List<String> requiredText = [
      if (imageFile == null) ConstsValues.kImageIsRequired,
      if (name == null) ConstsValues.kCategoryNameIsRequired,
      if (description == null) ConstsValues.kCategoryDescriptionIsRequired,
      if (token == null) ConstsValues.kTokenIsRequired
    ];
    if (requiredText.isNotEmpty) {
      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.badRequest,
        ConstsValues.kError: requiredText,
      }, HttpStatus.badRequest);
    } else {
      ({String? email, int? id, bool isValid})? validToken =
          await tokenIsValid(token!.replaceFirst("Bearer ", ''));
      if (!validToken.isValid) {
        return Response.json({
          ConstsValues.kStatusCode: HttpStatus.unauthorized,
          ConstsValues.kError: [ConstsValues.kInvalidOrExpiredToken],
        }, HttpStatus.unauthorized);
      } else {
        print(validToken.id);
        String imagePath = await StoreImages.call(imageFile!);
        CategoryCrud categoryCrud = CategoryCrud();
        var ca = await categoryCrud.create(CategoryModel(
            nameCategory: name,
            descriptionCategory: description,
            userId: validToken.id ?? 0,
            imageCategory: imagePath));
        if (ca == null) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kCategoryShouldBeUnique],
          }, HttpStatus.badRequest);
        } else {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.ok,
            ConstsValues.kCategory: ca,
            ConstsValues.kMessage: ConstsValues.kCategoryCreatedSuccessfully,
          }, HttpStatus.ok);
        }
      }
    }
  }

  Future<Response> deleteCategory(Request request) async {
    final id = request.input(ConstsValues.kId)?.toString().trim();
    final token = request.header(ConstsValues.kAuthorization)?.toString();

    List<String> requiredText = [
      if (id == null || id.isEmpty) ConstsValues.kIdIsRequired,
      if (token == null) ConstsValues.kTokenIsRequired,
    ];
    if (requiredText.isNotEmpty) {
      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.badRequest,
        ConstsValues.kError: requiredText,
      }, HttpStatus.badRequest);
    } else {
      ({String? email, int? id, bool isValid})? validToken =
          await tokenIsValid(token!.replaceFirst("Bearer ", ''));
      if (!validToken.isValid) {
        return Response.json({
          ConstsValues.kStatusCode: HttpStatus.unauthorized,
          ConstsValues.kError: [ConstsValues.kInvalidOrExpiredToken],
        }, HttpStatus.unauthorized);
      } else {
        CategoryCrud categoryCrud = CategoryCrud();
        //first check if the category exist
        CategoryModel? category =
            await categoryCrud.find(CategoryModel(id: int.parse(id ?? '0')));
        if (category == null) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kThisCategoryNotFound],
          }, HttpStatus.badRequest);
        }
        if (category.userId != validToken.id) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.unauthorized,
            ConstsValues.kError: [
              ConstsValues.kYouAreNotTheOwnerOfThisCategory
            ],
          }, HttpStatus.unauthorized);
        }
        bool ca = await categoryCrud.delete(CategoryModel(id: int.parse(id!)));
        if (!ca) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kCategoryNotFoundToDeleteIt],
          }, HttpStatus.badRequest);
        } else {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.ok,
            ConstsValues.kMessage: ConstsValues.kCategoryDeletedSuccessfully,
          }, HttpStatus.ok);
        }
      }
    }
  }

  Future<Response> updateCategoryEndPoint(Request request) async {
    final name = request.input(ConstsValues.kName)?.toString().trim();
    final description =
        request.input(ConstsValues.kDescription)?.toString().trim();
    final imageFile = request.file(ConstsValues.kImage);
    final token =
        request.header(ConstsValues.kAuthorization)?.toString().trim();
    final id = request.input(ConstsValues.kId)?.toString().trim();
    // check if any field is null
    List<String> requiredText = [
      if (name == null && imageFile == null)
        ConstsValues.kCategoryNameIsRequiredOrImage,
      if (description == null) ConstsValues.kCategoryDescriptionIsRequired,
      if (token == null) ConstsValues.kTokenIsRequired,
      if (id == null || id.isEmpty) ConstsValues.kIdIsRequired,
    ];
    if (requiredText.isNotEmpty) {
      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.badRequest,
        ConstsValues.kError: requiredText,
      }, HttpStatus.badRequest);
    } else {
      ({String? email, int? id, bool isValid})? validToken =
          await tokenIsValid(token!.replaceFirst("Bearer ", ''));
      if (!validToken.isValid) {
        return Response.json({
          ConstsValues.kStatusCode: HttpStatus.unauthorized,
          ConstsValues.kError: [ConstsValues.kInvalidOrExpiredToken],
        }, HttpStatus.unauthorized);
      } else {
        String? imagePath;
        CategoryCrud categoryCrud = CategoryCrud();
        CategoryModel? category =
            await categoryCrud.find(CategoryModel(id: int.parse(id ?? '0')));
        if (category == null) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kThisCategoryNotFound],
          }, HttpStatus.badRequest);
        }
        if (category.userId != validToken.id) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.unauthorized,
            ConstsValues.kError: [
              ConstsValues.kYouAreNotTheOwnerOfThisCategory
            ],
          }, HttpStatus.unauthorized);
        }
        if (imageFile != null) {
          //?remove last image from storage
          bool removed = await StoreImages.remove(category.imageCategory ?? '');
          print(removed);
          //?upload new image
          imagePath = await StoreImages.call(imageFile);
        }

        category = await categoryCrud.update(CategoryModel(
            nameCategory: name,
            descriptionCategory: description,
            userId: validToken.id ?? 0,
            id: int.parse(id ?? '0'),
            imageCategory: imagePath));
        //?remove last image from storage
        if (category == null) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kCategoryShouldBeUnique],
          }, HttpStatus.badRequest);
        } else {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.ok,
            ConstsValues.kCategory: category,
            ConstsValues.kMessage: ConstsValues.kCategoryUpdatedSuccessfully,
          }, HttpStatus.ok);
        }
      }
    }
  }

  Future<Response> showCategory(Request request) async {
    String? token = request.header(ConstsValues.kAuthorization)?.toString();
    String? id = request.input(ConstsValues.kId)?.toString().trim();
    List<String> requiredText = [
      if (id == null || id.isEmpty) ConstsValues.kIdIsRequired,
      if (token == null) ConstsValues.kTokenIsRequired
    ];
    if (requiredText.isNotEmpty) {
      return Response.json({
        ConstsValues.kStatusCode: HttpStatus.badRequest,
        ConstsValues.kError: requiredText,
      }, HttpStatus.badRequest);
    } else {
      ({String? email, int? id, bool isValid})? isValid = await tokenIsValid(
        token!.replaceFirst("Bearer ", ''),
      );
      if (!isValid.isValid) {
        return Response.json({
          ConstsValues.kStatusCode: HttpStatus.unauthorized,
          ConstsValues.kError: [ConstsValues.kInvalidOrExpiredToken],
        }, HttpStatus.unauthorized);
      } else {
        CategoryCrud categoryCrud = CategoryCrud();
        CategoryModel? categories = await categoryCrud.find(
          CategoryModel(id: int.parse(id ?? '0')),
        );
        if (categories == null) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kThisCategoryNotFound],
          }, HttpStatus.badRequest);
        } else {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.ok,
            ConstsValues.kCategories: categories,
          }, HttpStatus.ok);
        }
      }
    }
  }
}

final CategoryController categoryController = CategoryController();
