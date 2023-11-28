import 'package:flutter/material.dart';
import 'package:sendoff/helper/assets.dart';

import '../../../helper/pallet.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/styled_text.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      height: 50,
      color: Pallete.googleBtnColor,
      borderRadius: 30.0,
      border: Border.all(color: Pallete.primary),
      onPressed: onPressed!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Image.asset(CustomAssets.google)),
          SizedBox(
            width: MediaQuery.of(context).size.width*.012,
          ),
          const StyledText(
            text: "Sign up with Google",
            fontSize: 17.0,
            maxLines: 2,
            align: TextAlign.center,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
