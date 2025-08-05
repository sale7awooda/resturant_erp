// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sinwaan/core/constants.dart';

// class ProductHomeCard extends ConsumerWidget {
//   final Product product;
//   final String? categoryID;
//   const ProductHomeCard({super.key, required this.product, this.categoryID});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // final languageSaved = ref.read(prefStringProvider);
//     return InkWell(
//         onTap: () {
//           context.push('/productDetails', extra: product.id);
//         },
//         child: Container(
//             color: clrWhite,
//             // color: clrRed,
//             width: 170.w, // 130.w,
//             height: 250.h,
//             // padding: EdgeInsets.symmetric(horizontal: 5.h),
//             margin: EdgeInsets.symmetric(horizontal: 5.w),
//             child: Stack(children: [
//               Column(children: [
//                 SizedBox(
//                     height: 170.h, //150.h,
//                     width: 170.h,
//                     child: Stack(
//                       children: [
//                         CachedNetworkImage(
//                             imageUrl: product.productImage,
//                             imageBuilder: (context, imageProvider) => Container(
//                                 decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(20),
//                                     image: DecorationImage(
//                                         image: imageProvider,
//                                         fit: BoxFit.cover))),
//                             placeholder: (context, url) =>
//                                 MyShimmer(width: 169.w, hight: 169.h),
//                             errorWidget: (context, url, error) => Center(
//                                 child: Icon(Icons.error,
//                                     size: 40, color: clrRed))),
//                         //? the add to cart button
//                         Positioned(
//                             left: 7,
//                             bottom: 7,
//                             child: LocalCartButton(
//                               cartItem: CartItemModel(
//                                 productId: product.id,
//                                 name: product.name,
//                                 quantity: 1,
//                                 categoryId: int.tryParse(categoryID ?? '') ?? 1,

//                                 isOffer: product.isOffer,
//                                 offerPercent:
//                                     int.tryParse(product.offerPercent ?? '') ??
//                                         0,

//                                 perCost: _parseDouble(product.cost),
//                                 totalCost: _parseDouble(
//                                     product.cost), // Same as perCost initially

//                                 imgUrl: product.productImage,
//                               ),
//                             )

//                             // LocalCartButton(
//                             //   cartItem: CartItemModel(
//                             //     productId: product.id,
//                             //     name: product.name,
//                             //     quantity: 1,
//                             //     categoryId: int.tryParse(categoryID ?? '') ??
//                             //         1, //1, // int.parse(category!.id),
//                             //     isOffer: product.isOffer,
//                             //     offerPercent:
//                             //         int.tryParse(product.offerPercent ?? '') ?? 0,
//                             //     totalCost: (product.cost.isNotEmpty)
//                             //         ? double.tryParse(product.cost) ?? 0.0
//                             //         : 0.0,
//                             //     // (product.cost is num)
//                             //     //     ? (product.cost as num).toDouble()
//                             //     //     : 0.0,
//                             //     //double.tryParse(product.cost) ??0,// int.tryParse(product.cost) ?? 0,
//                             //     imgUrl: product.productImage,
//                             //     perCost: (product.cost is num)
//                             //         ? (product.cost as num).toDouble()
//                             //         : 0.0,
//                             //     // double.tryParse(product.cost) ??
//                             //     //     0 // int.tryParse(product.cost) ?? 0,
//                             //   ),
//                             // ),
//                             ), //?offer widget
//                         product.isOffer == 'Y'
//                             ? Positioned(
//                                 left: 5.w,
//                                 top: 5.h,
//                                 child: SizedBox(
//                                   height: 25.h,
//                                   width: 55.w,
//                                   child: Stack(
//                                     alignment: Alignment.centerLeft,
//                                     children: [
//                                       Positioned(
//                                         left: 15.w,
//                                         child: Container(
//                                           height: 19.h,
//                                           padding: EdgeInsets.only(
//                                               right: 3.w,
//                                               bottom:
//                                                   context.locale.toString() ==
//                                                           "ar"
//                                                       ? 2.h
//                                                       : 0.h),
//                                           width: 40.w,
//                                           alignment: Alignment.center,
//                                           decoration: BoxDecoration(
//                                             color: clrDarkGreen,
//                                             borderRadius: BorderRadius.only(
//                                               topRight: Radius.circular(15),
//                                               bottomRight: Radius.circular(15),
//                                             ),
//                                           ),
//                                           child: TxtWidget(
//                                               txt: "Offer".tr(),
//                                               color: clrWhite,
//                                               fontsize: 11.sp,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         left: 0,
//                                         child: Container(
//                                           height: 19.h,
//                                           width: 19.h,
//                                           alignment: Alignment.center,
//                                           decoration: BoxDecoration(
//                                               color: clrRed,
//                                               borderRadius: BorderRadius.only(
//                                                   topLeft: Radius.circular(10),
//                                                   topRight: Radius.circular(10),
//                                                   bottomRight:
//                                                       Radius.circular(10)),
//                                               border: Border(
//                                                   right: BorderSide(
//                                                       color: clrWhite,
//                                                       width: 1))),
//                                           child: TxtWidget(
//                                               txt: "%${product.offerPercent}",
//                                               color: clrWhite,
//                                               fontsize: 9.sp,
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ))
//                             : SizedBox.shrink()
//                       ],
//                     )),
//                 SizedBox(height: 5.h),
//                 SizedBox(
//                   height: 75.h,
//                   width: 170.w,
//                   child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         //? the price
//                         SizedBox(
//                           // padding: EdgeInsets.symmetric(horizontal: 5),
//                           height: 20.h,
//                           width: 160.w,
//                           child: Row(
//                             // mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                       color: clrYellow,
//                                       borderRadius: context
//                                                   .locale.languageCode ==
//                                               "ar"
//                                           ? BorderRadius.only(
//                                               topRight: Radius.circular(10),
//                                               bottomRight: Radius.circular(10))
//                                           : BorderRadius.only(
//                                               topLeft: Radius.circular(10),
//                                               bottomLeft: Radius.circular(10))),
//                                   child: Center(
//                                     child: TxtWidget(
//                                       txt: 'theprice'.tr(),
//                                       color: clrRed,
//                                       fontsize: 16.sp,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                       color: clrRed,
//                                       borderRadius: context
//                                                   .locale.languageCode !=
//                                               "ar"
//                                           ? BorderRadius.only(
//                                               topRight: Radius.circular(10),
//                                               bottomRight: Radius.circular(10))
//                                           : BorderRadius.only(
//                                               topLeft: Radius.circular(10),
//                                               bottomLeft: Radius.circular(10))),
//                                   child: Center(
//                                     child: TxtWidget(
//                                         maxLines: 1,
//                                         txt: product.isOffer == "Y"
//                                             ? "${product.offerCost!} ${'KWD'.tr()}"
//                                             : "${product.cost} ${'KWD'.tr()}",
//                                         color: clrWhite,
//                                         fontsize: 12.sp,
//                                         fontWeight: FontWeight.w500),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 60.w)
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 5.h),
//                         //? the product name
//                         Container(
//                           height: 50.h,
//                           width: 140.w,
//                           padding: EdgeInsets.symmetric(horizontal: 5),
//                           child: Text(
//                             product.name,
//                             maxLines: 3,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                                 fontSize: 14.sp, fontWeight: FontWeight.bold),
//                           ),
//                         )
//                       ]),
//                 )
//               ]),

//               // Positioned(
//               //     right: 7,
//               //     top: 7,
//               //     child: FavoriteButton(
//               //       productId: product.id,
//               //       // change to product.isfavorite
//               //       // isFavorite: product.isOffer
//               //     )),
//               product.isInStock == "N"
//                   ? Container(
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                           border: Border.all(color: clrRed),
//                           borderRadius: BorderRadius.circular(15),
//                           color: product.isInStock == "N"
//                               ? clrWhite.withValues(alpha: 0.7)
//                               : clrWhite.withValues(alpha: 0.0)),
//                       child: TxtWidget(
//                           fontsize: 22.sp,
//                           fontWeight: FontWeight.bold,
//                           txt: 'out of stock',
//                           color: clrRed))
//                   : SizedBox.shrink()
//             ])));
//   }

//   double _parseDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String && value.trim().isNotEmpty) {
//       return double.tryParse(value) ?? 0.0;
//     }
//     return 0.0;
//   }
// }
