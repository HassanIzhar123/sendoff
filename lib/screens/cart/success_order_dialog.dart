import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../generated/assets.dart';

class SuccessOrderDialog extends StatefulWidget {
  final Function(bool isLogin) onSignedUpClicked;
  final bool isSignedIn;

  const SuccessOrderDialog({super.key, required this.isSignedIn, required this.onSignedUpClicked});

  @override
  State<SuccessOrderDialog> createState() => _SuccessOrderDialogState();
}

class _SuccessOrderDialogState extends State<SuccessOrderDialog> {
  bool isSigned = false;

  @override
  void initState() {
    isSigned = widget.isSignedIn;
    // isSigned = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0.0),
      content: SizedBox(
        height: 400.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 6,
              child: SvgPicture.asset(
                Assets.imagesUntitled,
                fit: BoxFit.contain,
              ),
            ),
            !isSigned
                ? Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Text(
                          "Select any option!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onSignedUpClicked(true);
                              },
                              child: const Text(
                                "LogIn",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10.0,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20.0,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onSignedUpClicked(false);
                              },
                              child: const Text(
                                "SignUp",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
