
import 'package:flutter/material.dart';
import 'package:sendoff/helper/assets.dart';
import 'package:sendoff/helper/pallet.dart';
import 'package:sendoff/widgets/styled_text.dart';

class ArticleProductDetails extends StatefulWidget {
  final String name;
  final List<String> descriptions;

  const ArticleProductDetails({super.key, required this.name, required this.descriptions});

  @override
  State<ArticleProductDetails> createState() => _ArticleProductDetailsState();
}

class _ArticleProductDetailsState extends State<ArticleProductDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.primaryLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      CustomAssets.arrowLeft,
                      height: 28.0,
                    ),
                  ),
                  Expanded(
                    child: widget.name != null
                        ? StyledText(
                            text: widget.name,
                            maxLines: 2,
                            height: 1.2,
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            align: TextAlign.center,
                          )
                        : const StyledText(
                            text: "",
                            maxLines: 2,
                            height: 1.2,
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            align: TextAlign.center,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 15.0),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.descriptions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Text(widget.descriptions[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
