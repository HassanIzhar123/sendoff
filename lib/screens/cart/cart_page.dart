import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendoff/screens/cart/widgets/cart_product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/cubit/cart/cart_cubit.dart';
import '../../bloc/cubit/cart/cart_state.dart';
import '../../helper/assets.dart';
import '../../helper/pallet.dart';
import '../../models/helper/NavigatingTabChangeModel.dart';
import '../../models/product/product.dart';
import '../../repositories/cart/cart_repository.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/styled_text.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with AutomaticKeepAliveClientMixin<CartPage> {
  List<Product> list = [];
  String totalPrice = "0";
  bool isLoading = false;

  Future<void> saveListToPrefs(List<Product> list) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> serializedList =
        list.map((product) => json.encode(product.toJson())).toList();
    prefs.setStringList('cartList', serializedList);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => CartCubit(CartRepository())..fetchCartData(),
      child: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          ////log"state: $state");
          if (state is CartLoadingState) {
            isLoading = true;
          } else if (state is CartSuccessState) {
            setState(() {
              list = state.list;
              isLoading = false;
            });
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Pallete.primaryLight,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height * 0.023,
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 25.0,
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset(
                            CustomAssets.arrowLeft,
                            height: 30.0,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                        ),
                        const StyledText(
                          text: "Cart",
                          maxLines: 2,
                          height: 1.2,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w700,
                          align: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: SizedBox(
                                height: 50.0,
                                width: 50.0,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : list.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.hourglass_empty),
                                      SizedBox(
                                        height: 30.0,
                                      ),
                                      Text("No Categories Available!"),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    return CartProduct(
                                      currentProduct: list[index],
                                      position: index,
                                      onPressed: () {},
                                      onDeleteClicked:
                                          (int position, Product product) {
                                        setState(() {
                                          list.removeAt(position);
                                          saveListToPrefs(list);
                                        });
                                      },
                                      onIncrement:
                                          (int position, Product product) {
                                        context
                                            .read<CartCubit>()
                                            .fetchCartData();
                                      },
                                      onDecrement:
                                          (int position, Product product) {
                                        context
                                            .read<CartCubit>()
                                            .fetchCartData();
                                      },
                                    );
                                    // return CartProduct(
                                    //   currentProduct: list[index],
                                    //   position: index,
                                    //   image: list[index].images.isNotEmpty ? list[index].images[0] : "",
                                    //   label: list[index].name,
                                    //   desc: list[index].description,
                                    //   price: "R${list[index].finalPrice}",
                                    //   quantity: list[index].finalQuantity,
                                    //   color: "Green",
                                    //   size: "M",
                                    //   onPressed: () {},
                                    //   onDeleteClicked: (int position) {
                                    //     setState(() {
                                    //       list.removeAt(position);
                                    //       saveListToPrefs(list);
                                    //     });
                                    //   },
                                    //   onDecrement: (int position) async {
                                    //     // list = await getListFromPrefs();
                                    //     // if (mounted) {
                                    //     //   setState(() {});
                                    //     // }
                                    //   },
                                    //   onIncrement: (int position) async {
                                    //     list = await getListFromPrefs();
                                    //     //log"listtoStinrg: ${list.toString()}");
                                    //     if (mounted) {
                                    //       setState(() {});
                                    //     }
                                    //   },
                                    // );
                                  },
                                ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .22,
                    ),
                  ],
                ),
              ),
            ),
            bottomSheet: Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.height * 0.023,
              ),
              height: MediaQuery.of(context).size.height * .22,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Pallete.shadowColor.withOpacity(0.07),
                    offset: const Offset(0, -10),
                    blurRadius: 20,
                    spreadRadius: 0,
                  )
                ],
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Center(
                      child: Container(
                        height: 5.0,
                        width: 50.0,
                        color: Pallete.grey1,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const StyledText(
                        text: "Sub Total",
                        maxLines: 1,
                        color: Pallete.textColorOnWhiteBG,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                      StyledText(
                        text: "R${addingAllPrices().toStringAsFixed(2)}",
                        color: Pallete.textColorOnWhiteBG,
                        maxLines: 1,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),
                  Divider(
                    color: Pallete.dividerColor.withOpacity(.1),
                    thickness: 1,
                  ),
                  CustomButton(
                    color: Pallete.primary,
                    borderRadius: 30.0,
                    height: MediaQuery.of(context).size.height * .054,
                    onPressed: () async {
                      ////log"clicked");
                      //exit this screen
                      Navigator.pop(context);
                      //go to detail screen
                      Navigator.pop(context);
                      //go to all categories screen
                      Navigator.pop(
                          context, NavigatingTabChangeModel("", 4, list));

                      ////log"clicked1");
                    },
                    child: const Center(
                      child: StyledText(
                        text: "Proceed to checkout",
                        fontSize: 17.0,
                        maxLines: 1,
                        align: TextAlign.center,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double addingAllPrices() {
    double prices = 0;
    for (int i = 0; i < list.length; i++) {
      prices += list[i].finalPrice;
    }
    return prices;
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

  @override
  bool get wantKeepAlive => true;
}
