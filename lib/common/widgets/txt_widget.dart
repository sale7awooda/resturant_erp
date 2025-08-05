import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class TxtWidget extends StatelessWidget {
  const TxtWidget({
    super.key,
    required this.txt,
    this.fontsize,
    this.maxLines,
    this.textAlign,
    this.fontWeight,
    this.color,
    this.overflow = TextOverflow.ellipsis,
  });

  final String txt;
  final double? fontsize;
  final int? maxLines;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final Color? color;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      maxLines: maxLines,
      textAlign: textAlign,
      // overflow: overflow,
      softWrap: true,
      style: TextStyle(
        fontSize: fontsize ?? 12.sp,
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
