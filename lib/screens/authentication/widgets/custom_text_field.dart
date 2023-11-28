import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sendoff/helper/pallet.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final double? width, height, radius;
  final int? maxLength;
  final String? hintText;
  final TextStyle hintStyle, errorStyle, inputStyle;
  final TextStyle? floatingStyle;
  final EdgeInsets? contentPadding;
  final void Function(String? value)? onSaved, onChanged;
  final VoidCallback? onTap;
  final bool showCursor;
  final bool autofocus;
  final bool showErrorBorder;
  final TextAlign textAlign;
  final Alignment errorAlign, floatingAlign;
  final Color fillColor;
  final Color borderColor;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int? maxLines;
  final Widget? suffix;
  final String? Function(String? value) validator;

  const CustomTextField({
    Key? key,
    this.controller,
    this.width,
    this.height = 50,
    this.radius = 10,
    this.maxLines = 1,
    this.maxLength,
    this.floatingStyle,
    this.onSaved,
    this.onChanged,
    this.onTap,
    this.showCursor = true,
    this.showErrorBorder = false,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.errorAlign = Alignment.centerRight,
    this.floatingAlign = Alignment.centerLeft,
    this.fillColor = Pallete.searchBarFillColor,
    this.borderColor = Pallete.borderColor,
    this.hintText,
    this.hintStyle = const TextStyle(
      fontFamily: "NunitoSans",
      fontSize: 17.0,
      color: Pallete.hintTextColor,
    ),
    this.errorStyle = const TextStyle(
      height: 0,
      color: Colors.transparent,
    ),
    this.inputStyle = const TextStyle(
      fontFamily: "NunitoSans",
      fontSize: 17.0,
      color: Pallete.textColor,
    ),
    this.contentPadding = const EdgeInsets.fromLTRB(17, 18, 1, 18),
    required this.keyboardType,
    required this.textInputAction,
    required this.validator,
    this.suffix,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? errorText;
  bool hidePassword = true;

  bool get hasError => errorText != null;

  bool get showErrorBorder => widget.showErrorBorder && hasError;

  bool get isPasswordField => widget.keyboardType == TextInputType.visiblePassword;

  void _onSaved(String? value) {
    value = value!.trim();
    widget.controller?.text = value;
    widget.onSaved?.call(value);
  }

  void _onChanged(String value) {
    if (widget.onChanged != null) {
      _runValidator(value);
      widget.onChanged!(value);
    }
  }

  String? _runValidator(String? value) {
    final error = widget.validator(value!.trim());
    setState(() {
      errorText = error;
    });
    return error;
  }

  void _togglePasswordVisibility() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(widget.radius!)),
      borderSide: const BorderSide(
        color: Pallete.primary,
      ),
    );
  }

  OutlineInputBorder _normalBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(widget.radius!)),
      borderSide: BorderSide(color: widget.borderColor),
    );
  }

  OutlineInputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(widget.radius!)),
      borderSide: const BorderSide(
        color: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //TextField
        TextFormField(
          onTap: widget.onTap,
          controller: widget.controller,
          textAlign: widget.textAlign,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          style: isPasswordField && hidePassword
              ? widget.inputStyle.copyWith(color: Pallete.primary, letterSpacing: 2, fontSize: 25)
              : widget.inputStyle,
          showCursor: widget.showCursor,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          textAlignVertical: TextAlignVertical.center,
          autovalidateMode: AutovalidateMode.disabled,
          cursorColor: Pallete.primary,
          obscureText: isPasswordField && hidePassword,
          validator: _runValidator,
          onFieldSubmitted: _runValidator,
          onSaved: _onSaved,
          onChanged: _onChanged,
          autofillHints: const [
            AutofillHints.email,
            AutofillHints.username,
            AutofillHints.familyName,
            AutofillHints.password,
          ],
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: widget.hintStyle,
            errorStyle: widget.errorStyle,
            fillColor: widget.fillColor,
            contentPadding: isPasswordField && hidePassword
                ? widget.contentPadding!.copyWith(left: 12, right: 1, top: 13, bottom: 12)
                : widget.contentPadding,
            isDense: true,
            filled: true,
            counterText: '',
            suffixIcon: widget.suffix,
            enabledBorder: _normalBorder(),
            border: InputBorder.none,
            focusedBorder: _focusedBorder(),
            focusedErrorBorder: _focusedBorder(),
            errorBorder: showErrorBorder ? _errorBorder() : null,
          ),
        ),

        //Error text
        if (hasError) ...[
          SizedBox(
            width: widget.width,
            child: Align(
              alignment: widget.errorAlign,
              child: Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 13.0,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }
}
