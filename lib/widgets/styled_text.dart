import 'package:flutter/material.dart';

import '../helper/pallet.dart';

class StyledText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? align;
  final double? height;
  final int? maxLines;
  final bool? isUnderLine;

  const StyledText({
    Key? key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.align,
    this.height,
    this.maxLines,
    this.isUnderLine = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align ?? TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.clip,
      style:  TextStyle(
              height: height ?? 1.0,
              fontSize: fontSize ?? 16.0,
              color: color ?? Pallete.textColor,
              fontWeight: fontWeight ?? FontWeight.w500,
              fontFamily: "NunitoSans",
              decoration: isUnderLine != null
                  ? isUnderLine!
                      ? TextDecoration.underline
                      : null
                  : null,
            ),
    );
  }
}
