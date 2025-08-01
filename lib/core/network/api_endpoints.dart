class ApiEndPoints {
  static const baseUrl = "https://gymapp.runasp.net/";
  static const imagesBaseUrl = "https://gymapp.runasp.net/Images/FoodImages/";
  static const usersImagesBaseUrl = "https://gymapp.runasp.net/Images/UserImages/";
  static const login = "api/Account/Login";
  static const plans = "api/Package";
  static const trainerDataById = "/api/TrainerData/GetById";
  static const trainerData = "/api/TrainerData";
  static const getTrainees = "api/Account/GetAllTrainees";
  static const getAllUsers = "api/Account/GetAllUsers";
  static const getNewUsers = "api/Account/GetNewUsers";
  static const getUserAboutToExpire = "/api/Account/GetUsersNearExpirePackage";
  static const dietMeals = "api/Food";
  static const addDietMealForUser = "/api/UserFood/AddFoodsToUser";
  static const updateDietMealForUser = "/api/UserFood";
  static const getUserById = "api/Account/GetUserById";
  static const getUserDiet = "api/UserFood/GetFoodsForUser";
  static const exercise = "api/Exercise";
  static const addExerciseForUser = "api/Account/AddExerciseToUser";
  static var updateUserImage = "api/Account/UpdateImage";
  static const allChats = "api/Chat/GetContactUsers";
  static const chat = "api/Chat/GetChat";
  static const deleteChat = "api/Chat";
  static const sendMessage = "api/Chat/send";
  static const updateUserPackage = "api/Account/UpdateUserPackage";
  static const fcmToken = "/api/UserDevice";

  static const deleteUser = "api/Account/DeleteUser";
}
