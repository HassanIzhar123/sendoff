import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helper/assets.dart';
import '../../../helper/pallet.dart';
import '../../../models/product/product.dart';
import '../../../widgets/styled_text.dart';

class CartProduct extends StatelessWidget {
  final Product currentProduct;
  final int position;
  final Function() onPressed;
  final Function(int position, Product product) onDeleteClicked;
  final Function(int position, Product product) onIncrement, onDecrement;

  const CartProduct({
    super.key,
    required this.currentProduct,
    required this.position,
    required this.onPressed,
    required this.onDeleteClicked,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.018,
        ),
        child: InkWell(
          onTap: () {
            onPressed();
          },
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
                // const SizedBox(
                //   width: 18.0,
                // ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StyledText(
                              text: currentProduct.name,
                              maxLines: 2,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 9.0),
                                  child: StyledText(
                                    // text: "Size: ${size}",
                                    text: "Size: M",
                                    maxLines: 1,
                                    fontSize: 15.0,
                                    color: Pallete.textColorOnWhiteBG,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 9.0),
                                  child: Container(
                                    height: 10.0,
                                    width: 1.0,
                                    decoration: BoxDecoration(
                                      color: Pallete.dividerColor.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                const StyledText(
                                  // text: "Color: ${color}",
                                  text: "Color: Green",
                                  fontSize: 15.0,
                                  maxLines: 1,
                                  color: Pallete.textColorOnWhiteBG,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const StyledText(
                                  text: "QTY",
                                  maxLines: 1,
                                  fontWeight: FontWeight.w600,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .03,
                                ),
                                Container(
                                  height: 35.0,
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  width: MediaQuery.of(context).size.width * .20,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1.0, color: Pallete.cartPageBorderColor),
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        constraints: const BoxConstraints(
                                          minWidth: 20,
                                          maxWidth: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          int quantity = currentProduct.finalQuantity;
                                          if (quantity != 0) {
                                            quantity--;
                                          }
                                          await saveQuantity(quantity);
                                          await onDecrement(position, currentProduct);
                                        },
                                        icon: const Icon(
                                          Icons.remove,
                                          size: 20,
                                        ),
                                      ),
                                      StyledText(
                                        text: currentProduct.finalQuantity.toString(),
                                        maxLines: 1,
                                        color: Pallete.textColorOnWhiteBG,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      IconButton(
                                        constraints: const BoxConstraints(
                                          minWidth: 20,
                                          maxWidth: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          int quantity = currentProduct.finalQuantity;
                                          if (quantity >= 0) {
                                            quantity++;
                                          }
                                          await saveQuantity(quantity);
                                          await onIncrement(position, currentProduct);
                                        },
                                        icon: const Icon(
                                          Icons.add,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .03,
                                ),
                                InkWell(
                                  onTap: () {
                                    onDeleteClicked(position, currentProduct);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6.0),
                                    height: 35.0,
                                    width: 35.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 1.0, color: Pallete.cartPageBorderColor),
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                    child: Image.asset(
                                      CustomAssets.delete,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .03,
                                ),
                                StyledText(
                                  text: "R${currentProduct.finalPrice.toStringAsFixed(2)}",
                                  fontSize: 15.0,
                                  maxLines: 1,
                                  fontWeight: FontWeight.w600,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: const EdgeInsets.only(
                            top: 7.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: SizedBox(
                            // height: MediaQuery.of(context).size.height * 0.105,
                            height: MediaQuery.of(context).size.height * 0.07,
                            child: currentProduct.images[0] != ""
                                ? CachedNetworkImage(
                                    imageUrl: currentProduct.images[0],
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    imageBuilder: (context, imageProvider) => Container(
                                      width: MediaQuery.of(context).size.width * .17,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20.0),
                                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox(width: 85.0, child: Icon(Icons.error)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future saveQuantity(int quantity) async {
    if (quantity != 0) {
      List<Product> list = await getListFromPrefs();
      bool isSaved = false;
      int position = -1;
      for (int i = 0; i < list.length; i++) {
        if (list[i].documentId == currentProduct.documentId) {
          position = i;
          isSaved = true;
          break;
        }
      }
      if (isSaved) {
        Product savedProduct = list[position];
        double realPrice = savedProduct.finalPrice;
        realPrice = savedProduct.price * quantity;
        savedProduct.finalQuantity = quantity;
        savedProduct.finalPrice = realPrice;
        list[position] = savedProduct;
        await saveListToPrefs(list);
      }
    }
    List<Product> list = await getListFromPrefs();
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
    final List<Product> list = serializedList.map((jsonString) => Product.fromJson(json.decode(jsonString))).toList();
    return list;
  }
}

// class CartProduct extends StatefulWidget {
//   final Product currentProduct;
//   final int position;
//   final String image;
//   final String label;
//   final String desc;
//   final String price;
//   final String size;
//   final String color;
//   final int quantity;
//   final VoidCallback onPressed;
//   final Function(int position) onDeleteClicked;
//   final Function(int position) onIncrement, onDecrement;
//
//   const CartProduct({
//     super.key,
//     required this.currentProduct,
//     required this.position,
//     required this.image,
//     required this.label,
//     required this.onPressed,
//     required this.onDeleteClicked,
//     required this.onIncrement,
//     required this.onDecrement,
//     required this.desc,
//     required this.price,
//     required this.quantity,
//     required this.size,
//     required this.color,
//   });
//
//   @override
//   State<CartProduct> createState() => _CartProductState();
// }
//
// class _CartProductState extends State<CartProduct> {
//   int quantity = 0;
//
//   @override
//   void initState() {
//     quantity = widget.quantity;
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: EdgeInsets.only(
//           top: MediaQuery.of(context).size.height * 0.018,
//         ),
//         child: InkWell(
//           onTap: widget.onPressed,
//           child: Container(
//             padding: EdgeInsets.all(
//               MediaQuery.of(context).size.height * 0.01,
//             ),
//             height: MediaQuery.of(context).size.height * 0.15,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: Pallete.shadowColor.withOpacity(0.07),
//                   offset: const Offset(0, 5),
//                   blurRadius: 40,
//                   spreadRadius: 0,
//                 )
//               ],
//             ),
//             child: Row(
//               children: [
//                 // const SizedBox(
//                 //   width: 18.0,
//                 // ),
//                 Expanded(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           StyledText(
//                             text: widget.label,
//                             fontSize: 18.0,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(right: 9.0),
//                                 child: StyledText(
//                                   text: "Size: ${widget.size}",
//                                   fontSize: 15.0,
//                                   color: Pallete.textColorOnWhiteBG,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(right: 9.0),
//                                 child: Container(
//                                   height: 10.0,
//                                   width: 1.0,
//                                   decoration: BoxDecoration(
//                                     color: Pallete.dividerColor.withOpacity(0.1),
//                                   ),
//                                 ),
//                               ),
//                               StyledText(
//                                 text: "Color: ${widget.color}",
//                                 fontSize: 15.0,
//                                 color: Pallete.textColorOnWhiteBG,
//                               ),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               const StyledText(
//                                 text: "QTY",
//                                 fontWeight: FontWeight.w600,
//                               ),
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width * .03,
//                               ),
//                               Container(
//                                 height: 35.0,
//                                 padding: const EdgeInsets.symmetric(horizontal: 5.0),
//                                 width: MediaQuery.of(context).size.width * .20,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(width: 1.0, color: Pallete.cartPageBorderColor),
//                                   borderRadius: BorderRadius.circular(50.0),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     IconButton(
//                                       constraints: const BoxConstraints(
//                                         minWidth: 20,
//                                         maxWidth: 20,
//                                       ),
//                                       padding: EdgeInsets.zero,
//                                       onPressed: () {
//                                         if (quantity != 0) {
//                                           setState(() {
//                                             quantity--;
//                                           });
//                                         }
//                                         saveQuantity();
//                                         widget.onDecrement(widget.position);
//                                       },
//                                       icon: const Icon(
//                                         Icons.remove,
//                                         size: 20,
//                                       ),
//                                     ),
//                                     StyledText(
//                                       text: quantity.toString(),
//                                       color: Pallete.textColorOnWhiteBG,
//                                       fontSize: 16.0,
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                     IconButton(
//                                       constraints: const BoxConstraints(
//                                         minWidth: 20,
//                                         maxWidth: 20,
//                                       ),
//                                       padding: EdgeInsets.zero,
//                                       onPressed: () {
//                                         if (quantity >= 0) {
//                                           setState(() {
//                                             quantity++;
//                                           });
//                                         }
//                                         saveQuantity();
//                                         widget.onIncrement(widget.position);
//                                       },
//                                       icon: const Icon(
//                                         Icons.add,
//                                         size: 20,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width * .03,
//                               ),
//                               InkWell(
//                                 onTap: () {
//                                   widget.onDeleteClicked(widget.position);
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.all(6.0),
//                                   height: 35.0,
//                                   width: 35.0,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(width: 1.0, color: Pallete.cartPageBorderColor),
//                                     borderRadius: BorderRadius.circular(50.0),
//                                   ),
//                                   child: Image.asset(
//                                     CustomAssets.delete,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width * .03,
//                               ),
//                               StyledText(
//                                 text: widget.price,
//                                 fontSize: 15.0,
//                                 fontWeight: FontWeight.w600,
//                               )
//                             ],
//                           ),
//                         ],
//                       ),
//                       Align(
//                         alignment: Alignment.topRight,
//                         child: Container(
//                           margin: const EdgeInsets.only(
//                             top: 7.0,
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20.0),
//                           ),
//                           child: SizedBox(
//                             // height: MediaQuery.of(context).size.height * 0.105,
//                             height: MediaQuery.of(context).size.height * 0.07,
//                             child: widget.image != ""
//                                 ? CachedNetworkImage(
//                                     imageUrl: widget.image,
//                                     placeholder: (context, url) => const Center(
//                                       child: CircularProgressIndicator(),
//                                     ),
//                                     imageBuilder: (context, imageProvider) => Container(
//                                       width: MediaQuery.of(context).size.width * .17,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(20.0),
//                                         image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//                                       ),
//                                     ),
//                                     errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
//                                     fit: BoxFit.cover,
//                                   )
//                                 : const SizedBox(width: 85.0, child: Icon(Icons.error)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void saveQuantity() async {
//     if (quantity != 0) {
//       List<Product> list = await getListFromPrefs();
//       bool isSaved = false;
//       int position = -1;
//       for (int i = 0; i < list.length; i++) {
//         if (list[i].documentId == widget.currentProduct.documentId) {
//           position = i;
//           isSaved = true;
//           break;
//         }
//       }
//       if (isSaved) {
//         Product savedProduct = list[position];
//         double realPrice = savedProduct.finalPrice;
//         realPrice = savedProduct.price * quantity;
//         savedProduct.finalQuantity = quantity;
//         savedProduct.finalPrice = realPrice;
//         list[position] = savedProduct;
//         await saveListToPrefs(list);
//       }
//     }
//     List<Product> list = await getListFromPrefs();
//     //loglist.toString());
//   }
//
//   Future<void> saveListToPrefs(List<Product> list) async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<String> serializedList = list.map((product) {
//       return json.encode(product.toJson());
//     }).toList();
//     prefs.setStringList('cartList', serializedList);
//   }
//
//   Future<List<Product>> getListFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<String>? serializedList = prefs.getStringList('cartList');
//
//     if (serializedList == null) {
//       return [];
//     }
//     final List<Product> list = serializedList.map((jsonString) => Product.fromJson(json.decode(jsonString))).toList();
//     return list;
//   }
// }
