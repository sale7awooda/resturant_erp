// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Page Controller Provider
// final pageControllerProvider = Provider<PageController>((ref) {
//   return PageController();
// });

// // Current Index State Provider
// class PageIndexNotifier extends StateNotifier<int> {
//   PageIndexNotifier() : super(0);

//   void updateIndex(int newIndex) => state = newIndex;
// }

// final pageIndexProvider = StateNotifierProvider<PageIndexNotifier, int>((ref) {
//   return PageIndexNotifier();
// });

// class ImageSlider extends ConsumerWidget {
//   // final List<String> images ;
//   final Product? product;

//   const ImageSlider({super.key, required this.product});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final pageController = ref.watch(pageControllerProvider);
//     // final currentIndex = ref.watch(pageIndexProvider);

//     return SizedBox(
//       height: 450,
//       child: Stack(alignment: Alignment.bottomCenter, children: [
//         PageView.builder(
//           controller: pageController,
//           itemCount: product!.images!.length,
//           onPageChanged: (index) {
//             ref.read(pageIndexProvider.notifier).updateIndex(index);
//           },
//           itemBuilder: (context, index) {
//             final image = product!.images![index];
//             return CachedNetworkImage(
//                 imageUrl: image.toString(),
//                 imageBuilder: (context, imageProvider) => Container(
//                     decoration: BoxDecoration(
//                         // borderRadius: BorderRadius.circular(15),
//                         image: DecorationImage(
//                             image: imageProvider, fit: BoxFit.fill))),
//                 placeholder: (context, url) => MyShimmer(hight: 450),
//                 errorWidget: (context, url, error) => Icon(Icons.error,size: 35,));
//           },
//         ),
//         Positioned(
//           bottom: 20,
//           child: SmoothPageIndicator(
//             controller: pageController,
//             count: product!.images!.length,
//             effect: WormEffect(
//               dotWidth: 10,
//               dotHeight: 10,
//               activeDotColor: Colors.white,
//               dotColor: Colors.grey,
//             ),
//           ),
//         ),
//         Positioned(
//             left: 20, top: 20, child: FavoriteButton(productId: product!.id!))
//       ]),
//     );
//   }
// }
