import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../helper/pallet.dart';
import '../../../widgets/styled_text.dart';

class CatProduct extends StatelessWidget {
  final String image;
  final String label;
  final String desc;
  final String price;
  final double averageRating;
  final VoidCallback onPressed;

  const CatProduct({
    super.key,
    required this.image,
    required this.label,
    required this.onPressed,
    required this.desc,
    required this.price,
    required this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.018,
      ),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.height * 0.01,
          ),
          height: MediaQuery.of(context).size.height * 0.15,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Pallete.shadowColor.withOpacity(0.07),
                offset: const Offset(0, 5),
                blurRadius: 40,
                spreadRadius: 0,
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.105,
                  child: image != ""
                      ? CachedNetworkImage(
                          imageUrl: image,
                          placeholder: (context, url) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.105,
                            width: MediaQuery.of(context).size.width * .25,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          imageBuilder: (context, imageProvider) => Container(
                            width: MediaQuery.of(context).size.width * .25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          errorWidget: (context, url, error) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.105,
                            width: MediaQuery.of(context).size.width * .25,
                            child: const Center(
                              child: Icon(Icons.error),
                            ),
                          ),
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(width: 85.0, child: Icon(Icons.error)),
                ),
              ),
              const SizedBox(
                width: 18.0,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyledText(
                      text: label,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(
                      height: 1.0,
                    ),
                    StyledText(text: desc, maxLines: 2),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StyledText(
                          text: price,
                          maxLines: 1,
                          color: Pallete.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        RatingBarIndicator(
                          unratedColor: Pallete.unratedStarColor,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Pallete.textColor,
                          ),
                          rating: averageRating,
                          itemCount: 5,
                          itemSize: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
