import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../helper/pallet.dart';

class CustomLinkText extends StatelessWidget {
  final String text;
  final Function(String url)? onTap;

  const CustomLinkText(this.text, this.onTap, {super.key});

  List<TextSpan> _getSpans() {
    List<TextSpan> spans = [];

    // Regular expression to find URLs in the text
    RegExp regex = RegExp(r'https?://\S+');

    Iterable<Match> matches = regex.allMatches(text);

    if (matches.isEmpty) {
      spans.add(TextSpan(text: text));
      return spans;
    }

    int currentIndex = 0;

    for (Match match in matches) {
      // Add the text before the link
      spans.add(TextSpan(text: text.substring(currentIndex, match.start)));

      // Add the link
      final link = text.substring(match.start, match.end);
      spans.add(
        TextSpan(
          text: link,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _launchURL(link);
            },
        ),
      );

      currentIndex = match.end;
    }
    spans.add(TextSpan(text: text.substring(currentIndex)));
    return spans;
  }

  void _launchURL(String url) {
    if (onTap != null) {
      onTap!(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14.0,
          height: 1.18,
          color: Pallete.textColorOnWhiteBG,
        ),
        children: _getSpans(),
      ),
    );
  }
}
