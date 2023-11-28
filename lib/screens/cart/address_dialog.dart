import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../helper/pallet.dart';

class PhoneNumberDialog extends StatefulWidget {
  const PhoneNumberDialog({super.key});

  @override
  State<PhoneNumberDialog> createState() => _PhoneNumberDialogState();
}

class _PhoneNumberDialogState extends State<PhoneNumberDialog> {
  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 200.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                    top: 15.0,
                    left: 25.0,
                    right: 25.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Add Phone Number!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 25.0,
                          color: Pallete.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: addressTextField(
                    controller: addressController,
                    isEnable: true,
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    String address = addressController.text;
                    if (address.isNotEmpty) {
                      if (mounted) {
                        Navigator.pop(context, address);
                      }
                    } else {
                      Fluttertoast.showToast(msg: "please Enter Phone Number!");
                    }
                  },
                  child: const Text(
                    "Save",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget addressTextField({required controller, onChanged, isEnable}) {
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
          hintText: "Add Phone Number",
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
          prefixIcon: const SizedBox(
            height: 30.0,
            width: 30.0,
            child: Center(
              child: Icon(
                Icons.phone,
                color: Pallete.searchIconColor,
                size: 25.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
