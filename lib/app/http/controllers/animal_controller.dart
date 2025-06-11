import 'dart:io';

import 'package:animooo_api/app/models/animal_model.dart';
import 'package:animooo_api/app/models/category_model.dart';
import 'package:animooo_api/core/consts.dart';
import 'package:animooo_api/core/database/animal_crud.dart';
import 'package:animooo_api/core/database/cateogry_crud.dart';
import 'package:animooo_api/core/helper/store_images.dart';
import 'package:animooo_api/core/helper/tokens.dart';
import 'package:vania/vania.dart';

class AnimalController extends Controller {
  Future<Response> addNewAnimal(Request request) async {
    final name = request.input(ConstsValues.kName)?.toString().trim();
    final description =
        request.input(ConstsValues.kDescription)?.toString().trim();
    final imageFile = request.file(ConstsValues.kImage);
    final price = request.input(ConstsValues.kPrice)?.toString().trim();
    final categoryId =
        request.input(ConstsValues.kCategoryId)?.toString().trim();
    final token = request.header(ConstsValues.kAuthorization)?.toString();
    // check if any field is null
    List<String> requiredText = [
      if (name == null) ConstsValues.kAnimalNameIsRequired,
      if (description == null) ConstsValues.kAnimalDescriptionIsRequired,
      if (imageFile == null) ConstsValues.kImageIsRequired,
      if (price == null) ConstsValues.kAnimalPriceIsRequired,
      if (categoryId == null) ConstsValues.kAnimalCategoryIdIsRequired,
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
        //?search first category
        CategoryModel? categoryCrud = await CategoryCrud()
            .find(CategoryModel(id: int.parse(categoryId!)));
        if (categoryCrud == null) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kThisCategoryNotFound],
          }, HttpStatus.badRequest);
        } else {
          String imagePath = await StoreImages.call(imageFile!);
          AnimalCrud animalCrud = AnimalCrud();
          AnimalModel? animalModel = await animalCrud.create(AnimalModel(
            name: name!,
            description: description!,
            imagePath: imagePath,
            price: double.tryParse(price!) ?? 0.0,
            categoryId: int.parse(categoryId),
            userId: validToken.id!,
          ));
          if (animalModel == null) {
            return Response.json({
              ConstsValues.kStatusCode: HttpStatus.badRequest,
              ConstsValues.kError: [ConstsValues.kAnimalShouldBeUnique],
            }, HttpStatus.badRequest);
          } else {
            return Response.json({
              ConstsValues.kStatusCode: HttpStatus.ok,
              ConstsValues.kCategory: animalModel,
              ConstsValues.kMessage: ConstsValues.kAnimalCreatedSuccessfully,
            }, HttpStatus.ok);
          }
        }
      }
    }
  }

  Future<Response> allAnimal(Request request) async {
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
        AnimalCrud animalCrud = AnimalCrud();
        List<AnimalModel> animals = await animalCrud.all();
        return Response.json({
          ConstsValues.kStatusCode: HttpStatus.ok,
          ConstsValues.kAnimals: animals,
        }, HttpStatus.ok);
      }
    }
  }

  Future<Response> updateAnimalEndPoint(Request request) async {
    final animalID = request.input(ConstsValues.kId)?.toString().trim();
    final name = request.input(ConstsValues.kName)?.toString().trim();
    final description =
        request.input(ConstsValues.kDescription)?.toString().trim();
    var imageFile;
    try {
      imageFile = request.file(ConstsValues.kAnimalImage);
    } catch (e) {
      imageFile = null;
    }
    final price = request.input(ConstsValues.kAnimalPrice)?.toString().trim();
    final categoryId =
        request.input(ConstsValues.kCategoryId)?.toString().trim();
    final token =
        request.header(ConstsValues.kAuthorization)?.toString().trim();
    // check if any field is null
    List<String> requiredText = [
      if (animalID == null || animalID.isEmpty) ConstsValues.kIdIsRequired,
      if ((name == null || name.isEmpty) &&
          (description == null || description.isEmpty) &&
          (imageFile == null) &&
          (price == null || price.isEmpty) &&
          (categoryId == null || categoryId.isEmpty))
        ConstsValues.kYouShouldEnterOneOfThisFieldToMakeUpdate,
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
        String? imagePath;
        //?if update categoryID
        if (categoryId != null && categoryId.isNotEmpty) {
          CategoryCrud categoryCrud = CategoryCrud();
          CategoryModel? category =
              await categoryCrud.find(CategoryModel(id: int.parse(categoryId)));
          if (category == null) {
            return Response.json({
              ConstsValues.kStatusCode: HttpStatus.badRequest,
              ConstsValues.kError: [ConstsValues.kThisCategoryNotFound],
            }, HttpStatus.badRequest);
          }
        }
        print("ds");

        //?ensure that was same user to update this animal
        AnimalCrud animalCrud = AnimalCrud();
        AnimalModel? animalModel =
            await animalCrud.find(AnimalModel.fromID(id: int.parse(animalID!)));
        if (animalModel == null) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kThisAnimalNotFound],
          }, HttpStatus.badRequest);
        }
        if (animalModel.userId != validToken.id) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kYouAreNotTheOwnerOfThisAnimal],
          }, HttpStatus.badRequest);
        }
        //?upload new image
        if (imageFile != null) {
          //?remove last image from storage
          bool removed = await StoreImages.remove(animalModel.imagePath ?? '');
          print(removed);
          //?upload new image
          imagePath = await StoreImages.call(imageFile);
        }
        print(
            "userId: ${validToken.id!}, id: ${animalID}, name: $name, description: $description, imagePath: $imagePath, price: ${price}, categoryId: ${categoryId}");

        animalModel = await animalCrud.update(
          AnimalModel(
              userId: validToken.id!,
              id: int.parse(animalID),
              name: name == null || name.isEmpty ? null : name,
              description: description == null || description.isEmpty
                  ? null
                  : description,
              imagePath: imagePath,
              price: price == null || price.isEmpty
                  ? null
                  : double.tryParse(price),
              categoryId: categoryId == null || categoryId.isEmpty
                  ? null
                  : int.parse(categoryId)),
        );
        print("///d/");
        //?remove last image from storage
        if (animalModel == null) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kAnimalShouldBeUnique],
          }, HttpStatus.badRequest);
        } else {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.ok,
            ConstsValues.kAnimals: animalModel,
            ConstsValues.kMessage: ConstsValues.kAnimalUpdatedSuccessfully,
          }, HttpStatus.ok);
        }
      }
    }
  }

  Future<Response> deleteAnimalEndPoint(Request request) async {
    final id = request.input(ConstsValues.kId)?.toString().trim();
    final token = request.header(ConstsValues.kAuthorization)?.toString();
    print(request.input());
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
        AnimalCrud animalCrud = AnimalCrud();
        //first check if the animal exist
        AnimalModel? category =
            await animalCrud.find(AnimalModel.fromID(id: int.parse(id ?? '0')));
        if (category == null) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kThisAnimalNotFound],
          }, HttpStatus.badRequest);
        }
        if (category.userId != validToken.id) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.unauthorized,
            ConstsValues.kError: [ConstsValues.kYouAreNotTheOwnerOfThisAnimal],
          }, HttpStatus.unauthorized);
        }
        bool ca =
            await animalCrud.delete(AnimalModel.fromID(id: int.parse(id!)));
        if (!ca) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kAnimalNotFoundToDeleteIt],
          }, HttpStatus.badRequest);
        } else {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.ok,
            ConstsValues.kMessage: ConstsValues.kAnimalDeletedSuccessfully,
          }, HttpStatus.ok);
        }
      }
    }
  }

  
  
  Future<Response> showAnimalEndPoint(Request request) async {
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
        AnimalCrud animalCrud = AnimalCrud();
        AnimalModel? animalModel = await animalCrud.find(
          AnimalModel.fromID(id: int.parse(id ?? '0')),
        );
        if (animalModel == null) {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.badRequest,
            ConstsValues.kError: [ConstsValues.kThisAnimalNotFound],
          }, HttpStatus.badRequest);
        } else {
          return Response.json({
            ConstsValues.kStatusCode: HttpStatus.ok,
            ConstsValues.kCategories: animalModel,
          }, HttpStatus.ok);
        }
      }
    }
  }

}

final AnimalController animalController = AnimalController();
