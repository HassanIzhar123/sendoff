import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sendoff/helper/assets.dart';
import 'package:sendoff/helper/helper_functions.dart';
import 'package:sendoff/helper/pallet.dart';
import 'package:sendoff/screens/full_image_screen/full_image_screen.dart';
import 'package:sendoff/widgets/styled_text.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/product/product.dart';
import '../../models/product/rating_reviews.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_link_text.dart';
import '../cart/cart_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductDetails extends StatefulWidget {
  Product currentProduct;
  List<Product> products;

  bool isArticle = false;

  ProductDetails({
    super.key,
    // required this.recommendedProducts,
    required this.products,
    required this.currentProduct,
    required this.isArticle,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  bool _productImagesVisible = false;
  bool _productDetailsVisible = false;
  bool _productRecommendationVisible = true;
  bool _customerReviewsVisible = true;
  bool _productMaterialsVisible = true;
  bool _contactUsVisible = true;
  bool _additionalInfoVisible = true;
  int quantity = 1;
  CarouselController carouselController = CarouselController();
  double averageRating = 0.0;
  List<Product> recommendedProducts = [];

  @override
  void initState() {
    super.initState();
    // List<Product> recommendedProducts = [];
    List<Product> removedProducts = [];
    removedProducts.addAll(widget.products);
    removedProducts.remove(widget.currentProduct);
    if (removedProducts.length >= 3) {
      recommendedProducts.add(removedProducts[0]);
      recommendedProducts.add(removedProducts[1]);
      recommendedProducts.add(removedProducts[2]);
    } else {
      recommendedProducts = removedProducts;
    }
    _productImagesVisible = widget.currentProduct.images != null
        ? widget.currentProduct.images.isNotEmpty
        : false;
    _productDetailsVisible =
        widget.currentProduct.description.isEmpty ? false : true;
    _productRecommendationVisible = recommendedProducts.isEmpty ? false : true;
    _productMaterialsVisible =
        widget.currentProduct.productMaterial.isEmpty ? false : true;
    _additionalInfoVisible =
        widget.currentProduct.additionalInfo.isEmpty ? false : true;
    _customerReviewsVisible =
        widget.currentProduct.ratingReviews.isEmpty ? false : true;
    averageRating = widget.currentProduct.averageRating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Pallete.primaryLight,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  widget.currentProduct.images.isNotEmpty
                      ? CarouselSlider(
                          options: CarouselOptions(
                            height: 300.0,
                            autoPlay: true,
                            viewportFraction: 1.0,
                          ),
                          carouselController: carouselController,
                          items: widget.currentProduct.images.map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return GestureDetector(
                                  onTap: () {
                                    screenPush(
                                      context,
                                      FullImageScreen(
                                        imageUrl: i,
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    // height: 300,
                                    child: CachedNetworkImage(
                                      imageUrl: i,
                                      placeholder: (context, url) => SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Center(
                                              child: Icon(Icons.error)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        )
                      : Image.asset(
                          CustomAssets.whiteFlowerForgroundRect,
                          fit: BoxFit.cover,
                        ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.height * 0.023,
                    ).copyWith(top: MediaQuery.of(context).size.height * .045),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(9.0),
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Image.asset(
                              CustomAssets.arrowLeft,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(9.0),
                          height: 50.0,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: Image.asset(
                            CustomAssets.exit,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height * 0.023,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: StyledText(
                            text: widget.currentProduct.name,
                            fontSize: 18.0,
                            maxLines: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!widget.currentProduct.isArticleProduct) ...{
                          StyledText(
                            text:
                                "R${widget.currentProduct.price.toStringAsFixed(2)}",
                            color: Pallete.primary,
                            maxLines: 1,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        },
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: RatingBarIndicator(
                        unratedColor: Pallete.unratedStarColor,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Pallete.textColor,
                        ),
                        rating: averageRating,
                        itemCount: 5,
                        itemSize: 18,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .025),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _productImagesVisible = !_productImagesVisible;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const StyledText(
                                  text: "Images",
                                  fontSize: 17.0,
                                  maxLines: 1,
                                  fontWeight: FontWeight.w600,
                                ),
                                Icon(
                                  _productImagesVisible
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_right,
                                  size: 25.0,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _productImagesVisible,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                height:
                                    MediaQuery.of(context).size.height * .23,
                                child: widget.currentProduct.images.isNotEmpty
                                    ? ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            widget.currentProduct.images.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              // log(carouselController.);
                                              carouselController.animateToPage(
                                                index,
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: CachedNetworkImage(
                                                imageUrl: widget.currentProduct
                                                    .images[index],
                                                placeholder: (context, url) =>
                                                    const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .35,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    const Center(
                                                        child:
                                                            Icon(Icons.error)),
                                                fit: BoxFit
                                                    .cover, // You can adjust the BoxFit as needed
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : const Center(
                                        child:
                                            Text("Images are not Available!"),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .03),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _productDetailsVisible =
                                    !_productDetailsVisible;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const StyledText(
                                  text: "Product Details",
                                  fontSize: 17.0,
                                  maxLines: 1,
                                  fontWeight: FontWeight.w600,
                                ),
                                Icon(
                                  _productDetailsVisible
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_right,
                                  size: 25.0,
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Visibility(
                              visible: _productDetailsVisible,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  // child: StyledText(
                                  //   text: widget.currentProduct.description,
                                  // ),
                                  child: CustomLinkText(
                                    widget.currentProduct.description,
                                    (String url) async {
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(Uri.parse(url));
                                      } else {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'No browser installed to open link'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .03),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _productRecommendationVisible =
                                    !_productRecommendationVisible;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const StyledText(
                                  text: "We also Recommend",
                                  fontSize: 17.0,
                                  maxLines: 1,
                                  fontWeight: FontWeight.w600,
                                ),
                                Icon(
                                  _productRecommendationVisible
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_right,
                                  size: 25.0,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _productRecommendationVisible,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                height: recommendedProducts.isNotEmpty
                                    ? MediaQuery.of(context).size.height * .25
                                    : null,
                                child: recommendedProducts.isNotEmpty
                                    ? ListView(
                                        scrollDirection: Axis.horizontal,
                                        children:
                                            recommendedProducts.map((product) {
                                          return alsoRecommendItem(
                                            product,
                                            onTapped: () {
                                              //remove the current product from the list into a different list and pass it to the product details screen
                                              // List<Product> temp = recommendedProducts;
                                              // temp.insert(0, widget.currentProduct);
                                              // temp.removeWhere((element) {
                                              //   return element.documentId == product.documentId;
                                              // });
                                              screenPush(
                                                context,
                                                ProductDetails(
                                                  currentProduct: product,
                                                  products: widget.products,
                                                  // recommendedProducts: temp,
                                                  isArticle: widget.isArticle,
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                      )
                                    : const Center(
                                        child: StyledText(
                                          text:
                                              "recommended Products are not Available!",
                                          fontSize: 14.0,
                                          height: 1.18,
                                          color: Pallete.textColorOnWhiteBG,
                                          maxLines: 2,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .03),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _customerReviewsVisible =
                                    !_customerReviewsVisible;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const StyledText(
                                  text: "Customer Reviews",
                                  maxLines: 1,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                Icon(
                                  _customerReviewsVisible
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_right,
                                  size: 25.0,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _customerReviewsVisible,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: widget.currentProduct.ratingReviews
                                            .isNotEmpty
                                        ? ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, position) {
                                              return Card(
                                                color: Pallete.primaryLight,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          StyledText(
                                                            text:
                                                                "${widget.currentProduct.ratingReviews[position].userName} - ",
                                                            fontSize: 14.0,
                                                            height: 1.18,
                                                            color: Pallete
                                                                .textColorOnWhiteBG,
                                                          ),
                                                          StyledText(
                                                            text: widget
                                                                .currentProduct
                                                                .ratingReviews[
                                                                    position]
                                                                .productName,
                                                            fontSize: 14.0,
                                                            height: 1.18,
                                                            color: Pallete
                                                                .textColorOnWhiteBG,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 5.0),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 10.0),
                                                        child:
                                                            RatingBarIndicator(
                                                          unratedColor: Pallete
                                                              .unratedStarColor,
                                                          itemBuilder: (context,
                                                                  index) =>
                                                              const Icon(
                                                            Icons.star,
                                                            color: Pallete
                                                                .textColor,
                                                          ),
                                                          rating: widget
                                                              .currentProduct
                                                              .ratingReviews[
                                                                  position]
                                                              .rating,
                                                          itemCount: 5,
                                                          itemSize: 18,
                                                        ),
                                                      ),
                                                      StyledText(
                                                        text: widget
                                                            .currentProduct
                                                            .ratingReviews[
                                                                position]
                                                            .review,
                                                        fontSize: 14.0,
                                                        height: 1.18,
                                                        color: Pallete
                                                            .textColorOnWhiteBG,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            itemCount: widget.currentProduct
                                                .ratingReviews.length,
                                            shrinkWrap: true,
                                          )
                                        : const Center(
                                            child: StyledText(
                                              text: "No Reviews",
                                              fontSize: 14.0,
                                              height: 1.18,
                                              color: Pallete.textColorOnWhiteBG,
                                              maxLines: 2,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.currentProduct.isArticleProduct) ...{
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * .03),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _productMaterialsVisible =
                                      !_productMaterialsVisible;
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const StyledText(
                                    text: "Materials",
                                    fontSize: 17.0,
                                    maxLines: 1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  Icon(
                                    _productMaterialsVisible
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_right,
                                    size: 25.0,
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: _productMaterialsVisible,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: widget.currentProduct.productMaterial
                                            .isNotEmpty
                                        ? StyledText(
                                            text: widget
                                                .currentProduct.productMaterial,
                                            fontSize: 14.0,
                                            height: 1.18,
                                            color: Pallete.textColorOnWhiteBG,
                                          )
                                        // ? CustomLinkText(
                                        //     widget.currentProduct.productMaterial,
                                        //     (String url) {},
                                        //   )
                                        : const Center(
                                            child: StyledText(
                                              text: "No Materials",
                                              fontSize: 14.0,
                                              height: 1.18,
                                              color: Pallete.textColorOnWhiteBG,
                                              maxLines: 2,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    },
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .03),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _contactUsVisible = !_contactUsVisible;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const StyledText(
                                  maxLines: 1,
                                  text: "Contact Us",
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                Icon(
                                  _contactUsVisible
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_right,
                                  size: 25.0,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _contactUsVisible,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: CustomButton(
                                          color: Pallete.primary,
                                          borderRadius: 30.0,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .047,
                                          onPressed: () async {
                                            await launchCallApp();
                                          },
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Image.asset(
                                                  CustomAssets.call,
                                                  height: 20.0,
                                                ),
                                                const StyledText(
                                                  text: "Call Sendoff",
                                                  fontSize: 15.0,
                                                  maxLines: 2,
                                                  align: TextAlign.center,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: CustomButton(
                                          color: Pallete.primary,
                                          borderRadius: 30.0,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .047,
                                          onPressed: () {
                                            launchWhatsapp();
                                          },
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Image.asset(
                                                  CustomAssets.whatsapp,
                                                  height: 20.0,
                                                ),
                                                const StyledText(
                                                  text: "Whatsapp",
                                                  fontSize: 15.0,
                                                  maxLines: 2,
                                                  align: TextAlign.center,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.currentProduct.isArticleProduct) ...{
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * .03),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _additionalInfoVisible =
                                      !_additionalInfoVisible;
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const StyledText(
                                    text: "Additional Information",
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w600,
                                    maxLines: 1,
                                  ),
                                  Icon(
                                    _additionalInfoVisible
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_right,
                                    size: 25.0,
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: _additionalInfoVisible,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: widget.currentProduct
                                              .additionalInfo.isNotEmpty
                                          ? StyledText(
                                              text: widget.currentProduct
                                                  .additionalInfo,
                                              fontSize: 14.0,
                                              height: 1.18,
                                              color: Pallete.textColorOnWhiteBG,
                                            )
                                          : const Center(
                                              child: StyledText(
                                                text:
                                                    "No additional information",
                                                fontSize: 14.0,
                                                height: 1.18,
                                                color:
                                                    Pallete.textColorOnWhiteBG,
                                                maxLines: 2,
                                              ),
                                            )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    },
                    if (!widget.currentProduct.isArticleProduct) ...{
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * .03),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const StyledText(
                              text: "Subtotal",
                              maxLines: 1,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w700,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * .06,
                                width: MediaQuery.of(context).size.width * .29,
                                decoration: BoxDecoration(
                                  color: Pallete.primary.withOpacity(.2),
                                  borderRadius: BorderRadius.circular(60.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .042,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .085,
                                        decoration: BoxDecoration(
                                          color: Pallete.primary,
                                          borderRadius:
                                              BorderRadius.circular(60.0),
                                        ),
                                        child: customIcon(Icons.remove,
                                            onPressed: () {
                                          if (quantity != 1) {
                                            setState(() {
                                              quantity--;
                                            });
                                          }
                                        }),
                                      ),
                                      StyledText(
                                        text: quantity.toString(),
                                        fontSize: 17.0,
                                        maxLines: 1,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .042,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .085,
                                        decoration: BoxDecoration(
                                          color: Pallete.primary,
                                          borderRadius:
                                              BorderRadius.circular(60.0),
                                        ),
                                        child: customIcon(Icons.add,
                                            onPressed: () {
                                          if (quantity >= 1) {
                                            setState(() {
                                              quantity++;
                                            });
                                          }
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    },
                    if (!widget.isArticle) ...{
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * .03),
                        child: CustomButton(
                          color: Pallete.primary,
                          borderRadius: 30.0,
                          height: MediaQuery.of(context).size.height * .055,
                          onPressed: () async {
                            List<Product> list = await getListFromPrefs();
                            bool isSaved = false;
                            int position = -1;
                            for (int i = 0; i < list.length; i++) {
                              if (list[i].documentId ==
                                  widget.currentProduct.documentId) {
                                position = i;
                                isSaved = true;
                                break;
                              }
                            }
                            if (isSaved) {
                              Product savedProduct = list[position];
                              double realPrice = savedProduct.finalPrice;
                              double realQuantity =
                                  savedProduct.finalQuantity.toDouble();
                              realQuantity += quantity;
                              realPrice = savedProduct.price * realQuantity;
                              savedProduct.finalQuantity = realQuantity.toInt();
                              savedProduct.finalPrice = realPrice;
                              list[position] = savedProduct;
                              if (list[position].finalPrice > 0) {
                                await saveListToPrefs(list);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'This product cannot be added in cart because it has zero price!'),
                                  ),
                                );
                                return;
                              }
                            } else {
                              widget.currentProduct.finalQuantity = quantity;
                              double price = widget.currentProduct.price;
                              widget.currentProduct.finalPrice =
                                  price * quantity;
                              if (widget.currentProduct.finalPrice > 0) {
                                list.add(widget.currentProduct);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'This product cannot be added in cart because it has zero price!'),
                                  ),
                                );
                                return;
                              }
                              await saveListToPrefs(list);
                            }
                            await screenPush(context, const CartPage());
                          },
                          child: const Center(
                            child: StyledText(
                              text: "Add to Cart",
                              fontSize: 17.0,
                              maxLines: 1,
                              align: TextAlign.center,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    },
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  launchCallApp() async {
    String phone = "+27104484430";
    String callUrl = "tel://$phone";
    if (await canLaunchUrl(Uri.parse(callUrl))) {
      await launchUrl(Uri.parse(callUrl));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call App is not installed on your device.'),
          ),
        );
      }
    }
  }

  launchWhatsapp() async {
    String phone = "+27663153430";
    final whatsappUrl = "whatsapp://send?phone=$phone";
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp is not installed on your device.'),
          ),
        );
      }
    }
  }

  Future<void> saveListToPrefs(List<Product> list) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> serializedList = list.map((product) {
      return json.encode(product.toJson());
    }).toList();
    prefs.setStringList('cartList', serializedList);
  }

  Future<List<Product>> getListFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? serializedList = prefs.getStringList('cartList');

    if (serializedList == null) {
      return [];
    }
    final List<Product> list = serializedList
        .map((jsonString) => Product.fromJson(json.decode(jsonString)))
        .toList();
    return list;
  }

  Widget customIcon(IconData icon, {required Function() onPressed}) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onPressed();
          },
          child: Padding(
            padding: const EdgeInsets.all(
              2.0,
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  double calculateAverageRating(List<RatingReviews> reviews) {
    if (reviews.isEmpty) {
      return 0.0;
    }
    double averageRating =
        reviews.map((review) => review.rating).reduce((a, b) => a + b) /
            reviews.length;
    return averageRating;
  }

  Widget alsoRecommendItem(Product product, {required Function() onTapped}) {
    return GestureDetector(
      onTap: () {
        onTapped();
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                width: MediaQuery.of(context).size.width * .35,
                child: product.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.images[0],
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        imageBuilder: (context, imageProvider) => Container(
                          width: MediaQuery.of(context).size.width * .25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Center(child: Icon(Icons.error)),
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(width: 85.0, child: Icon(Icons.error)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.012),
              child: StyledText(
                maxLines: 1,
                text: "R${product.price.toStringAsFixed(2)}",
                color: Pallete.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .35,
              child: StyledText(
                text: product.description,
                maxLines: 2,
                fontSize: 13.0,
                color: Pallete.textColorOnWhiteBG,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
