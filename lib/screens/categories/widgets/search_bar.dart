import 'package:flutter/material.dart';
import 'package:sendoff/helper/assets.dart';

import '../../../helper/pallet.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final bool isEnable;
  const SearchTextField(
      {Key? key, this.controller, this.onChanged, this.isEnable = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3.0,
      shadowColor: Pallete.shadowColor.withOpacity(0.07),
      borderRadius: BorderRadius.circular(50.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: Pallete.textColor,
        style: const TextStyle(
          fontSize: 16.0,
          fontFamily: "NunitoSans",
          fontWeight: FontWeight.w500,
          color: Pallete.textColor,
        ),
        decoration: InputDecoration(
          fillColor: Pallete.searchBarFillColor,
          enabled: isEnable,
          hintText: "Search for a product",
          hintStyle: const TextStyle(
            fontSize: 15.0,
            fontFamily: "NunitoSans",
            fontWeight: FontWeight.w500,
            color: Pallete.hintTextColor,
          ),
          isDense: true,
          isCollapsed: true,
          contentPadding: const EdgeInsets.only(top: 15.0, left: 10.0),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          // border: OutlineInputBorder(
          //   borderSide: const BorderSide(
          //     width: 1,
          //     strokeAlign: BorderSide.strokeAlignCenter,
          //     color: Pallete.borderColor,
          //   ),
          //   borderRadius: BorderRadius.circular(50.0),
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: const BorderSide(
          //     width: 1,
          //     strokeAlign: BorderSide.strokeAlignCenter,
          //     color: Pallete.primary,
          //   ),
          //   borderRadius: BorderRadius.circular(50.0),
          // ),
          prefixIcon: SizedBox(
            height: 30.0,
            width: 30.0,
            child: Center(
                child: Image.asset(
              CustomAssets.search,
              color: Pallete.searchIconColor,
              height: 25,
            )),
          ),
        ),
      ),
    );
  }
}
