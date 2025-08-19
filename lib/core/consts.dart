class ConstsValues {
  ConstsValues._();
  static const String kCategoryNameIsRequired = 'category name is required';
  static const String kCategoryDescriptionIsRequired =
      'category description is required';
  static const String kUserIDIsRequired = 'user id is required';
  static const String kInvalidOrExpiredToken = 'Invalid or expired token';
  static const String kError = 'error';
  static const String kAllFieldsAreRequired = 'All fields are required';
  static const String kFirstNameIsRequired = 'first name is required';
  static const String kLastNameIsRequired = 'last name is required';
  static const String kEmailIsRequired = 'email is required';
  static const String kPhoneIsRequired = 'phone is required';
  static const String kPasswordIsRequired = 'password is required';
  static const String kImageIsRequired = 'image is required';
  static const String kInvalidEmail = 'Invalid email';
  static const String kNotFoundThisEmail = 'Not found this email';
  static const String
      kPasswordMustBeAtLeast6CharactersAndIncludeLettersAndNumbers =
      'Password must be at least 6 characters and include letters and numbers and special characters';
  static const String kStatusCode = 'statusCode';
  static const String kEmailAlreadyExistsOrDatabaseError =
      'Email already exists or database error';
  static const String kInvalidPhone = 'Invalid phone';
  static const String kFileNotFound = 'File not found';
  static const String kImageFolderName = 'uploads';
  static const String kApiName = 'api';
  static const String kId = 'id';
  static const String kEmail = 'email';
  static const String kUser = 'user';
  static const String kMessage = 'message';
  static const String kAlert = 'alert';
  static const String kWeSendVerficationCodeToYourEmail =
      'We send verfication code to your email';
  static const String kSignupSuccessful = 'Signup successful!';
  static const String kFirstName = 'firstName';
  static const String kLastName = 'lastName';
  static const String kPhone = 'phone';
  static const String kPassword = 'password';
  static const String kImage = 'image';
  static const String kVerficationCodeIsRequired =
      'verfication code is required';
  static const String kInvalidVerficationCode = 'Invalid verfication code';
  static const String kDatabaseError = 'Database error';
  static const String kVerficationSuccessful = 'Verfication successful';
  static const String kTokenIsRequired = 'Token is required';

  static const Duration kExpiresTokenTime = Duration(days: 1);
  static const String kEmailSentSuccessfully = 'Email sent successfully';

  static const String kConfirmPassword = 'confirmPassword';

  static const String kPasswordNotMatch =
      'Password and confirm password not match';

  static const String kPasswordUpdatedSuccessfully =
      'Password updated successfully';

  static const String kPasswordRecoveryCode =
      'Animooo App Password recovery code';

  static const String kPassowrdOrEMailNotTrue = 'Password or email not true';

  static const String kLoginSuccessful = 'Login successful';

  static const String kRefreshTokenIsRequired = 'Refresh token is required';

  static const String kNotFoundThisRefreshToken =
      'Not found this refresh token';

  static const String kAuthorization = 'Authorization';

  static const String kCategories = 'Categories';
  static const String kCategory = 'Category';

  static const String kName = 'name';

  static const String kDescription = 'description';
  static const String kUserID = 'userId';

  static const String kCategoryCreatedSuccessfully =
      'Category created successfully';

  static const String kCategoryShouldBeUnique = 'Category should be unique';

  static const String kIdIsRequired = 'id is required';

  static const String kCategoryUpdatedSuccessfully =
      'Category updated successfully';

  static const String kThisCategoryNotFound = 'This category not found';

  static const String kCategoryNameIsRequiredOrImage =
      'Category name is required or image';

  static const String kCategoryDeletedSuccessfully =
      'Category deleted successfully';

  static const String kCategoryNotFoundToDeleteIt =
      'Category not found to delete it';

  static const String kAccountNotVerified = 'Account not verified';

  static const String kPrice = 'price';

  static const String kCategoryId = 'category_id';
  static const String kAnimalNameIsRequired = 'Animal name is required';
  static const String kAnimalDescriptionIsRequired =
      'Animal description is required';
  static const String kAnimalPriceIsRequired = 'Animal price is required';
  static const String kAnimalCategoryIdIsRequired =
      'Animal category id is required';

  static const String kErrorCreatingAnimal = 'Error creating animal';

  static const String kAnimalCreatedSuccessfully =
      'Animal created successfully';

  static const String kAnimalShouldBeUnique = 'Animal should be unique';

  static const String kYouAreNotTheOwnerOfThisCategory =
      'You are not the owner of this category';

  static const String kAnimals = 'Animals';

  static const String kAnimalImage = 'animal_image';
  static const String kAnimalPrice = 'animal_price';

  static const String kYouShouldEnterOneOfThisFieldToMakeUpdate =
      'You should enter one of this field [ name, description, price, image or category_id ] to make update';

  static const String kAnimalUpdatedSuccessfully =
      'Animal updated successfully';
  static const String kThisAnimalNotFound = 'This animal not found';

  static const String kYouAreNotTheOwnerOfThisAnimal =
      'You are not the owner of this animal';

  static const String kAnimalNotFoundToDeleteIt =
      'Animal not found to delete it';

  static const String kAnimalDeletedSuccessfully =
      'Animal deleted successfully';

  static const String kThisEmailNotFound = 'This email not found';
}

class ConstsTables {
  ConstsTables._();
  static const String kAnimalId = 'animal_id';
  static const String kAnimalName = 'animal_name';
  static const String kAnimalDescription = 'animal_description';
  static const String kAnimalImage = 'animal_image';
  static const String kAnimalPrice = 'animal_price';
  static const String kCategoryId = 'category_id';
  static const String kUserId = 'user_id';
  static const String kAnimalCreatedAt = 'animal_created_at';
  static const String kAnimalUpdateAt = 'animal_update_at';
  static const String kCategoryTable = 'categories';
  static const String kNameCategory = 'name_category';
  static const String kDescriptionCategory = 'description_category';
  static const String kImageCategory = 'image_category';
  static const String kCreatedAtCategory = 'created_at_category';
  static const String kUpdatedAtCategory = 'updated_at_category';
  static const String kUserIdCategory = 'user_id_category';
  static const String kFirstName = 'first_name';
  static const String kId = 'id';
  static const String kLastName = 'last_name';
  static const String kEmail = 'email';
  static const String kPhone = 'phone';
  static const String kPassword = 'password';
  static const String kImagePath = 'image_path';
  static const String kAccessToken = 'access_token';
  static const String kCode = 'code';
  static const String kRefreshToken = 'refresh_token';
  static const String kUsersTable = 'users';
  static const String kIsVerified = 'is_verified';
  static const String kVerificationCode = 'verification_code';
  static const String kExpiresAt = 'expires_at';

  static const String kAnimalsTable = 'animals';
}
