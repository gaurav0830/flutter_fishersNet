class ApiConstant {
  // Update with your server IP
  static const String baseServerUrl = 'http://192.168.89.28/fishing1/fishing_app1';

  static const String apiBase = '$baseServerUrl/api';
  static const String imageBase = '$baseServerUrl';

  // API Endpoints
  static const String register = '$apiBase/register.php';
  static const String login = '$apiBase/login.php';
  static const String viewMagazine = '$apiBase/view_magazine.php';
  static const String viewRescue = '$apiBase/view_rescue.php';
  static const String addFeedback = '$apiBase/add_feedback.php';
  static const String bookFish = '$apiBase/book_fish.php';
  static const String viewFish = '$apiBase/view_fish.php';
  static const String uploadFishImage = '$apiBase/upload_fish_image.php';
  static const String uploadMagazineImage = '$apiBase/upload_magazine_image.php';
  static const String getFish = '$apiBase/get_fish.php';
  static const String addFish = '$apiBase/add_fish.php';
  static const String viewOrders = '$apiBase/view_orders.php';
  static const String viewFeedback = '$apiBase/get_feedback.php';
}
