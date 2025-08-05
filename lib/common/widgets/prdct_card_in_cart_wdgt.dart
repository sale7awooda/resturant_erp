// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// class ProductInCartCard extends ConsumerWidget {
//   final CartItemModel item;
//   // final String? categoryID;
//   const ProductInCartCard({super.key, required this.item
//       // , this.categoryID
//       });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return
//         // InkWell(
//         //     onTap: () {
//         //       context.push('/productDetails', extra: item.id);
//         //     },
//         //     child:
//         Container(
//             color: clrWhite,
//             width: 130.w, // 130.w,
//             height: 180.h,
//             // margin: EdgeInsets.symmetric(horizontal: 2.w),
//             // padding: EdgeInsets.all(2.w),
//             child: Stack(alignment: Alignment.topCenter, children: [
//               Column(children: [
//                 SizedBox(
//                     height: 130.h, //150.h,
//                     width: 130.w,
//                     child: Stack(
//                       children: [
//                         CachedNetworkImage(
//                             imageUrl: item.imgUrl,
//                             imageBuilder: (context, imageProvider) => Container(
//                                 decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(20),
//                                     image: DecorationImage(
//                                         image: imageProvider,
//                                         fit: BoxFit.cover))),
//                             placeholder: (context, url) =>
//                                 MyShimmer(width: 129.w, hight: 154.h),
//                             errorWidget: (context, url, error) => Center(
//                                 child: Icon(Icons.error,
//                                     size: 40, color: clrRed))),
//                         // //? the options to delete the cart
//                         // Positioned(
//                         //   left: 5,
//                         //   top: 5,
//                         //   child: Container(
//                         //       width: 25.w,
//                         //       height: 25.w,
//                         //       decoration: BoxDecoration(
//                         //         color: clrWhite, // AppConstants().appMainClr,
//                         //         borderRadius: BorderRadius.circular(15),
//                         //       ),
//                         //       child: Center(
//                         //           child: IconButton(icon:  Icon(Icons.more_horiz_outlined,
//                         //               color: clrBlack, size: 20),onPressed: () {

//                         //               },))),
//                         // ),
//                         // //? the add to cart button
//                         // Positioned(
//                         //   right: 5,
//                         //   top: 5,
//                         //   child: TriangularCartButton(
//                         //     cartItem: CartItemModel(
//                         //         productId: item.productId,
//                         //         name: item.name,
//                         //         quantity: 1,
//                         //         categoryId: item.categoryId,
//                         //         // int.tryParse(categoryID ?? '') ?? 1,
//                         //         //1, // int.parse(category!.id),
//                         //         isOffer: item.isOffer,
//                         //         offerPercent: item.offerPercent,
//                         //         // int.tryParse(product.offerPercent ?? '') ?? 0,
//                         //         totalCost: item.totalCost,
//                         //         // double.tryParse(product.cost!) ?? 0.0,
//                         //         // (product.cost is num)
//                         //         //     ? (product.cost as num).toDouble()
//                         //         //     : 0.0,
//                         //         //double.tryParse(product.cost) ??0,// int.tryParse(product.cost) ?? 0,
//                         //         imgUrl: item
//                         //             .imgUrl, // product.firstImageOrPlaceholder,
//                         //         perCost: item.perCost
//                         //         // (product.cost is num)
//                         //         //     ? (product.cost as num).toDouble()
//                         //         //     : 0.0,
//                         //         // double.tryParse(product.cost) ??
//                         //         //     0 // int.tryParse(product.cost) ?? 0,
//                         //         ),
//                         //   ),
//                         // ),
//                       ],
//                     )),
//                 SizedBox(height: 5.h),
//                 Container(
//                   height: 35.h,
//                   width: 120.w,
//                   padding: EdgeInsets.symmetric(horizontal: 5),
//                   child: Center(
//                     child: Text(
//                       item.name,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                           fontSize: 12.sp, fontWeight: FontWeight.w700),
//                     ),
//                   ),
//                 ),
//               ]), //? price tag
//               Positioned(
//                 left: 15.w,
//                 bottom: 30.h,
//                 child: SizedBox(
//                   // color: clrLightBlue,
//                   height: 35.h,
//                   width: 75.w,
//                   child: Stack(
//                     alignment: Alignment.topCenter,
//                     // mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Positioned(
//                         top: 10.h,
//                         child: Container(
//                           height: 25.h,
//                           width: 75.w,
//                           decoration: BoxDecoration(
//                               color: clrYellow,
//                               borderRadius: BorderRadius.circular(7)),
//                           child: Center(
//                             child: Column(
//                               children: [
//                                 SizedBox(height: 6.h),
//                                 LocalRedYellowCartButton(cartItem: item)
//                                 // RedYellowCartButton(cartItem: item)
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: 17.h,
//                         width: 65.w,
//                         decoration: BoxDecoration(
//                             color: clrRed,
//                             borderRadius: BorderRadius.circular(7)),
//                         child: Center(
//                           child: TxtWidget(
//                               txt: "${item.perCost} ${'KWD'.tr()}",
//                               color: clrWhite,
//                               fontsize: 12.sp,
//                               fontWeight: FontWeight.w600),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               //?offer widget
//               item.isOffer == 'Y'
//                   ? Positioned(
//                       left: 5.w,
//                       top: 5.h,
//                       child: SizedBox(
//                         height: 25.h,
//                         width: 55.w,
//                         child: Stack(
//                           alignment: Alignment.centerLeft,
//                           children: [
//                             Positioned(
//                               left: 15.w,
//                               child: Container(
//                                 height: 19.h,
//                                 padding: EdgeInsets.only(
//                                     right: 3.w,
//                                     bottom: context.locale.toString() == "ar"
//                                         ? 2.h
//                                         : 0.h),
//                                 width: 35.w,
//                                 alignment: Alignment.centerRight,
//                                 decoration: BoxDecoration(
//                                   color: clrDarkGreen,
//                                   borderRadius: BorderRadius.only(
//                                     topRight: Radius.circular(15),
//                                     bottomRight: Radius.circular(15),
//                                   ),
//                                 ),
//                                 child: TxtWidget(
//                                     txt: "Offer".tr(),
//                                     color: clrWhite,
//                                     fontsize: 11.sp,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             Positioned(
//                               left: 0,
//                               child: Container(
//                                 height: 19.h,
//                                 width: 19.h,
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                     color: clrRed,
//                                     borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(10),
//                                         topRight: Radius.circular(10),
//                                         bottomRight: Radius.circular(10)),
//                                     border: Border(
//                                         right: BorderSide(
//                                             color: clrWhite, width: 1))),
//                                 child: TxtWidget(
//                                     txt: "%${item.offerPercent}",
//                                     color: clrWhite,
//                                     fontsize: 9.sp,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             )
//                           ],
//                         ),
//                       ))
//                   : SizedBox.shrink()
//             ])
//             // )
//             );
//   }
// }
