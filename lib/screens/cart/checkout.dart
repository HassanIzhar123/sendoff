import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:sendoff/bloc/cubit/chats/chats_cubit.dart';
import 'package:sendoff/bloc/cubit/checkout/checkout_cubit.dart';
import 'package:sendoff/helper/helper_functions.dart';
import 'package:sendoff/screens/authentication/register_screen.dart';
import 'package:sendoff/screens/cart/address_dialog.dart';
import 'package:sendoff/screens/cart/success_order_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/PushOrder/Order.dart' as order_number;
import '../../bloc/cubit/chats/chats_state.dart';
import '../../bloc/cubit/checkout/checkout_state.dart';
import '../../helper/assets.dart';
import '../../helper/pallet.dart';
import '../../models/PushOrder/OrderProduct.dart';
import '../../models/product/product.dart';
import '../../repositories/checkout/checkout_repository.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/styled_text.dart';

class Checkout extends StatefulWidget {
  final ChatsCubit chatsCubit;

  const Checkout({super.key, required this.chatsCubit});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState
    extends State<Checkout> /*with AutomaticKeepAliveClientMixin<Checkout>*/ {
  bool isLoading = false;
  List<Product> list = [];

  // double deliveryPrice = 10.26;
  Map<String, dynamic>? paymentIntent;
  double subTotal = 0.0, total = 0.0;
  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> saveListToPrefs(List<Product> list) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> serializedList =
        list.map((product) => json.encode(product.toJson())).toList();
    prefs.setStringList('cartList', serializedList);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CheckoutCubit(CheckoutRepository())..fetchCheckoutData(),
      child: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          //log"checkout state: $state");
          if (state is CheckoutLoadingState) {
            isLoading = true;
          } else if (state is CheckoutSuccessState) {
            list = state.list;
            //log"adding allList: ${list.toString()}");
            isLoading = false;
          } else if (state is CheckOutPushOrderLoadingState) {
            showLoaderDialog(context);
          } else if (state is CheckOutPushOrderSuccessState) {
            Navigator.pop(context);
            setState(() {});
            log("message: ${state.pushOrderModel.isUploaded}");
            showDialog(
                context: context,
                useSafeArea: true,
                builder: (_) {
                  return SuccessOrderDialog(
                    isSignedIn: state.pushOrderModel.isSignedIn ?? false,
                    onSignedUpClicked: (bool isLogin) async {
                      Object? object = await getValueAfterScreenPush(
                        context,
                        RegisterScreen(
                          isLogin: isLogin,
                        ),
                      );
                      if (object != null) {
                        String customerId = object as String;
                        if (isLogin) {
                          Fluttertoast.showToast(msg: "Thanks for Logging In!");
                        } else {
                          Fluttertoast.showToast(msg: "Thanks for Signing In!");
                        }
                        widget.chatsCubit.emit(const OnOrderPlace());
                      }
                    },
                  );
                }).then((value) {
              if (state.pushOrderModel.isSignedIn ?? false) {
                widget.chatsCubit.emit(const OnOrderPlace());
              }
            });
          } else if (state is CheckOutPushOrderFailedState) {
            log("message: ${state.message}");
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Center(child: Text("Payment Failed")),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ).then((value) {
              widget.chatsCubit.emit(const OnOrderPlace());
            });
          }
        },
        builder: (context, state) {
          getProductValue();
          return SafeArea(
            child: ScaffoldMessenger(
              key: _globalKey,
              child: Scaffold(
                backgroundColor: Pallete.primaryLight,
                body: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.height * 0.023,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20.0,
                        ),
                        const StyledText(
                          text: "Checkout",
                          maxLines: 2,
                          height: 1.2,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w700,
                          align: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 25.0, horizontal: 20.0),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Pallete.shadowColor.withOpacity(0.05),
                                offset: const Offset(0, 3),
                                blurRadius: 20,
                                spreadRadius: 0,
                              )
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Column(
                            children: [
                              list.isNotEmpty
                                  ? ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, position) {
                                        Product currentProduct = list[position];
                                        return Container(
                                          padding: EdgeInsets.only(
                                            top: 10.0,
                                            bottom:
                                                position != (list.length - 1)
                                                    ? 0.0
                                                    : 10.0,
                                            right: 15.0,
                                            left: 15.0,
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: StyledText(
                                                      text: list[position].name,
                                                      maxLines: 2,
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  StyledText(
                                                      text:
                                                          "R${list[position].price.toStringAsFixed(2)}",
                                                      maxLines: 2,
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 20.0,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const StyledText(
                                                    text: "Quantity",
                                                    maxLines: 1,
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    height: 35.0,
                                                    width: 100.0,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Pallete.primaryLight,
                                                      border: Border.all(
                                                          width: 1.0,
                                                          color: Pallete
                                                              .cartPageBorderColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        IconButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(),
                                                          onPressed: () {
                                                            int quantity =
                                                                currentProduct
                                                                    .finalQuantity;
                                                            if (quantity != 1) {
                                                              setState(() {
                                                                quantity--;
                                                                currentProduct
                                                                        .finalQuantity =
                                                                    quantity;
                                                                currentProduct
                                                                    .finalPrice = currentProduct
                                                                        .price *
                                                                    currentProduct
                                                                        .finalQuantity;
                                                                saveListToPrefs(
                                                                    list);
                                                              });
                                                            }
                                                          },
                                                          icon: const Icon(
                                                              Icons.remove,
                                                              size: 15.0),
                                                        ),
                                                        StyledText(
                                                            text: currentProduct
                                                                .finalQuantity
                                                                .toString()),
                                                        IconButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(),
                                                          onPressed: () {
                                                            int quantity =
                                                                currentProduct
                                                                    .finalQuantity;
                                                            if (quantity >= 1) {
                                                              setState(() {
                                                                quantity++;
                                                                currentProduct
                                                                        .finalQuantity =
                                                                    quantity;
                                                                currentProduct
                                                                    .finalPrice = currentProduct
                                                                        .price *
                                                                    currentProduct
                                                                        .finalQuantity;
                                                                saveListToPrefs(
                                                                    list);
                                                              });
                                                            }
                                                          },
                                                          icon: const Icon(
                                                              Icons.add,
                                                              size: 15.0),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10.0,
                                              ),
                                              Divider(
                                                color: Pallete.dividerColor
                                                    .withOpacity(.1),
                                                thickness: 1,
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      itemCount: list.length,
                                      shrinkWrap: true,
                                    )
                                  : const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.hourglass_empty),
                                          SizedBox(
                                            height: 30.0,
                                          ),
                                          Text("No Products Added"),
                                        ],
                                      ),
                                    ),
                              const SizedBox(
                                height: 18.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const StyledText(
                                    text: "Sub Total",
                                    maxLines: 1,
                                    fontSize: 15.0,
                                  ),
                                  StyledText(
                                    text: "R${subTotal.toStringAsFixed(2)}",
                                    maxLines: 1,
                                    fontSize: 15.0,
                                  ),
                                ],
                              ),
                              // const SizedBox(
                              //   height: 15.0,
                              // ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     const StyledText(
                              //       maxLines: 1,
                              //       text: "Delivery",
                              //       fontSize: 15.0,
                              //     ),
                              //     StyledText(
                              //       text: "R$deliveryPrice",
                              //       maxLines: 1,
                              //       fontSize: 15.0,
                              //     ),
                              //   ],
                              // ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const StyledText(
                                    text: "Total",
                                    maxLines: 1,
                                    fontSize: 15.0,
                                  ),
                                  StyledText(
                                    text: "R${total.toStringAsFixed(2)}",
                                    maxLines: 1,
                                    fontSize: 15.0,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 25.0,
                              ),
                              CustomButton(
                                color: Pallete.primary,
                                borderRadius: 30.0,
                                height:
                                    MediaQuery.of(context).size.height * .054,
                                onPressed: () async {
                                  // Stripe.instance.applySettings();
                                  if (list.isNotEmpty) {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    if (prefs.containsKey("guest_address")) {
                                      String? address =
                                          prefs.getString("guest_address");
                                      makeTransactionAccordingToSignUp(
                                          context, prefs, address);
                                    } else {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const PhoneNumberDialog();
                                        },
                                      ).then(
                                        (value) async {
                                          if (value != null) {
                                            String address = value as String;
                                            prefs.setString(
                                                "guest_address", address);
                                            makeTransactionAccordingToSignUp(
                                                context, prefs, address);
                                          }
                                        },
                                      );
                                    }
                                  } else {
                                    if (_globalKey.currentState != null) {
                                      var snackBar = const SnackBar(
                                          content: Text(
                                              'Please add Something in cart!'));
                                      _globalKey.currentState!
                                          .showSnackBar(snackBar);
                                    }
                                  }
                                },
                                child: const Center(
                                  child: StyledText(
                                    text: "Checkout",
                                    fontSize: 17.0,
                                    maxLines: 1,
                                    align: TextAlign.center,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 25.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(CustomAssets.stripe,
                                      height: 35.0),
                                  Image.asset(CustomAssets.masterCard,
                                      height: 35.0),
                                  Image.asset(CustomAssets.visa, height: 35.0),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void makeTransaction(
      BuildContext context, String? customerId, String address) async {
    showLoaderDialog(context);
    List<OrderProduct> orderProducts = [];
    double totalPrice = 0;
    int totalQuantity = 0;
    for (int i = 0; i < list.length; i++) {
      OrderProduct orderProduct = OrderProduct(
          productId: list[i].documentId,
          productName: list[i].name,
          quantity: list[i].finalQuantity,
          price: list[i].finalPrice);
      orderProducts.add(orderProduct);
      totalPrice += list[i].finalPrice;
      totalQuantity += list[i].finalQuantity;
    }
    order_number.Order order = order_number.Order(
      customerId: customerId,
      orderDate: getCurrentUtcTime(),
      products: orderProducts,
      totalPrice: totalPrice,
      totalQuantity: totalQuantity,
      status: "pending",
      phoneNumber: address,
    );
    log("OrderDetailsJson: ${order.toString()}");
    if (mounted) {
      await makePayment(context, totalPrice, () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.remove("cartList");
        setState(() {
          list = [];
          total = 0;
          subTotal = 0;
        });
        Navigator.pop(context);
        context.read<CheckoutCubit>().pushOrder(customerId, order);
      }, (String message) {
        log("message: $message");
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Center(child: Text("Payment Failed")),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      });
    }
  }

  Future<void> makePayment(BuildContext context, double amount,
      Function() onSuccess, Function(String message) onFailed) async {
    try {
      paymentIntent =
          await createPaymentIntent(amount.toInt().toString(), 'ZAR', onFailed);

      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent![
                      'client_secret'], //Gotten from payment intent
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Ikay'))
          .then(
        (value) {
          log('here');
        },
      );

      await displayPaymentSheet(onSuccess, onFailed);
    } catch (err) {
      log(err.toString());
      onFailed(err.toString());
      throw Exception(err);
    }
  }

  Future displayPaymentSheet(
      Function() onSuccess, Function(String message) onFailed) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        onSuccess();
        paymentIntent = null;
      }).onError((error, stackTrace) {
        log('Error is:---> ${error.toString()}');
        onFailed(error.toString());
      });
    } on StripeException catch (e) {
      log('Error is:---> ${e.toString()}');
      onFailed(e.toString());
    } catch (e) {
      log(e.toString());
      onFailed(e.toString());
    }
  }

  createPaymentIntent(
      String amount, String currency, Function(String message) onFailed) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': dotenv.env['PUBLISHABLE-KEY']!,
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      log("err: ${err.toString()}");
      throw Exception(err.toString());
      onFailed(err.toString());
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }

  int getCurrentUtcTime() {
    return DateTime.now().toUtc().millisecondsSinceEpoch;
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Loading...")),
          const SizedBox(),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  getProductValue() {
    subTotal = 0;
    for (int i = 0; i < list.length; i++) {
      subTotal += list[i].finalPrice;
    }
    total = subTotal;
    total = double.parse(total.toStringAsFixed(3));
  }

  void makeTransactionAccordingToSignUp(
      BuildContext context, SharedPreferences prefs, String? address) async {
    bool isSignedIn = prefs.getBool("isSignedIn") ?? false;
    if (isSignedIn) {
      if (mounted) {
        String? customerId = prefs.getString("customerId");
        if (customerId != null) {
          makeTransaction(context, customerId, address!);
        }
      }
    } else {
      if (mounted) {
        makeTransaction(context, null, address!);
      }
    }
  }

// @override
// bool get wantKeepAlive => true;
}
