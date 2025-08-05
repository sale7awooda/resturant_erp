import 'package:flutter/material.dart';

late String? hex;
// final Color clrMainSeed = Colors.white;
const Color clrGreen = Colors.green;
Color clrMainAppClr = Colors.green; //parseColor('#58c3ed');
const Color clrLightGreen = Color.fromRGBO(197, 240, 143, 1);
const Color clrDarkGreen = Color.fromRGBO(74, 124, 14, 1);
const Color clrRed = Colors.red; // Color.fromRGBO(174, 28, 18, 1);
const Color clrLightRed = Color.fromARGB(255, 248, 124, 115);
const Color clrWhite = Colors.white;
const Color clrGrey = Colors.grey;
const Color clrLightGrey = Color.fromARGB(255, 239, 239, 239);
const Color clrBlack = Colors.black;
const Color clrLightBlack = Color.fromARGB(255, 70, 67, 67);
const Color clrpurble = Colors.purple;
const Color clrBlue = Colors.blue;
const Color clrLightBlue = Color.fromARGB(255, 123, 193, 251);
const Color clrYellow = Colors.yellow;
const Color clrLightYellow = Color.fromARGB(255, 255, 241, 120);
const Color clrOrange = Colors.orange;
const Color clrLightOrange = Color.fromARGB(255, 253, 201, 123);
const Color clrAmber = Colors.amberAccent;
// const Color clrHEX = Color();

class AppConstants {
  final String appName = 'Resturant Manager';
  final Color appMainClr = Colors.green;
  // parseColor('#58c3ed'); // Colors.lightGreen;
  // final String baseURL =
  //     // 'http://192.168.131.1:8080/sinwan/interface/interface.php?action=';
  //     'https://sinwaan.com/interface/interface.php?action=';
  // final String endPointCategory = 'category';
  // final String endPointFavoriteAction = 'do_favorite_action';
  // final String endPointFavoriteList = 'get_favorite_list';
  // final String endPointHomeCategory = 'home_category';
  // final String endpointProductsList = 'products_list';
  // final String endPointSignup = 'signup';
  // final String endPointVerify = 'verify';
  // final String endpointLogin = 'login';
  // final String endpointResetPwd = 'resetpwd';
  // final String endpointChangePwd = 'changepwd';
  // final String endPointAddToCart = 'add_to_cart';
  // final String endpointGetCartList = 'get_cart';
  // final String endPointAddAddress = 'add_address';
  // final String endPointdeleteAddress = 'delete_address';
  // final String endPointUpdateAddress = 'edit_address';
  // final String endPointGetAddressList = 'get_address';
  // final String endPointCheckout = 'place_order';
  // final String endPointGetOrders = 'get_orders';
  // final String endPointOrderPayment = 'payment_order';
  // final String endPointGetOrdersDetails = 'get_order_details';
  // final String endPointPurchaseReport = 'get_rpt_purchase';
  // final String endPointNotifications = 'get_notifications_list';
  // final String endPointProductDetails = 'get_product_details';
  // final String endPointAddRating = 'do_rate';
  // final String endPointClearCart = 'clear_cart';
}

/// Constant sizes to be used in the app (paddings, gaps, rounded corners etc.)
class Sizes {
  static const p4 = 4.0;
  static const p8 = 8.0;
  static const p12 = 12.0;
  static const p16 = 16.0;
  static const p20 = 20.0;
  static const p24 = 24.0;
  static const p32 = 32.0;
  static const p48 = 48.0;
  static const p64 = 64.0;
  static const p80 = 80.0;
  static const p100 = 100.0;
  static const p150 = 150.0;
  static const p200 = 200.0;
}

/// Constant gap widths
const gapW4 = SizedBox(width: Sizes.p4);
const gapW8 = SizedBox(width: Sizes.p8);
const gapW12 = SizedBox(width: Sizes.p12);
const gapW16 = SizedBox(width: Sizes.p16);
const gapW20 = SizedBox(width: Sizes.p20);
const gapW24 = SizedBox(width: Sizes.p24);
const gapW32 = SizedBox(width: Sizes.p32);
const gapW48 = SizedBox(width: Sizes.p48);
const gapW64 = SizedBox(width: Sizes.p64);

/// Constant gap heights
const gapH4 = SizedBox(height: Sizes.p4);
const gapH8 = SizedBox(height: Sizes.p8);
const gapH12 = SizedBox(height: Sizes.p12);
const gapH16 = SizedBox(height: Sizes.p16);
const gapH20 = SizedBox(height: Sizes.p20);
const gapH24 = SizedBox(height: Sizes.p24);
const gapH32 = SizedBox(height: Sizes.p32);
const gapH48 = SizedBox(height: Sizes.p48);
const gapH64 = SizedBox(height: Sizes.p64);
const gapH80 = SizedBox(height: Sizes.p80);
const gapH10 = SizedBox(height: Sizes.p100);
const gapH150 = SizedBox(height: Sizes.p150);
const gapH200 = SizedBox(height: Sizes.p200);
Color parseColor(String hexColor) {
  // Remove '#' if it exists
  final cleanedHex = hexColor.replaceAll("#", "");
  return Color(int.parse("0xFF$cleanedHex"));
}
