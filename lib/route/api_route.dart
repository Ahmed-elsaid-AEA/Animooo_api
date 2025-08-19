import 'package:animooo_api/app/http/controllers/animal_controller.dart';
import 'package:animooo_api/app/http/controllers/category_controller.dart';
import 'package:animooo_api/app/http/controllers/user_controller.dart';
import 'package:vania/vania.dart';

/// Api route class
class ApiRoute implements Route {
  /// Register all routes
  @override
  void register() {
    /// Base RoutePrefix
    Router.basePrefix('api');

    /// User routes
    Router.post("/signup", userController.signup);
    Router.post("/verfication_code", userController.otpVerficationCode);
    //?new verfication code
    Router.post("/create_new_verfication_code", userController.createNewVerficationCode);
    Router.get("/check_token_work", userController.checkTokenWork);
    Router.post("/forget_password", userController.forgetPassword);
    Router.post("/create_new_possword", userController.createNewPassword);
    Router.get("/login", userController.login);
    Router.post(
        "/generateAccessToken", userController.generateAccessTokenEndPoint);

    /// Show image
    Router.get('/uploads/{filename}', userController.showImage);

    /// Category routes
    Router.get('/allCategories', categoryController.getAllCategory);
    Router.post('/createNewCategory', categoryController.createNewCategory);
    Router.post('/updateCategory', categoryController.updateCategoryEndPoint);
    Router.delete('/deleteCategory', categoryController.deleteCategory);
    Router.get('/showCategory', categoryController.showCategory);

    /// Animal routes
    Router.post('/addNewAnimal', animalController.addNewAnimal);
    Router.get('/allAnimal', animalController.allAnimal);
    Router.post('/updateAnimal', animalController.updateAnimalEndPoint);
    Router.delete('/deleteAnimal', animalController.deleteAnimalEndPoint);
    Router.get('/showAnimal', animalController.showAnimalEndPoint);
  }
}
