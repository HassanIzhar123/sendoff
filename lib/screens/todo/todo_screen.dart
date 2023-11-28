import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sendoff/helper/helper_functions.dart';
import 'package:sendoff/models/Search/todo_save_model.dart';
import 'package:sendoff/screens/todo/view/ToDoItem.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/cubit/todo/todo_cubit.dart';
import '../../bloc/cubit/todo/todo_state.dart';
import '../../helper/MySharedPreferences.dart';
import '../../helper/assets.dart';
import '../../helper/pallet.dart';
import '../../models/PushOrder/OrderProduct.dart';
import '../../models/chats/admin.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/styled_text.dart';
import '../../../models/PushOrder/Order.dart' as order_number;

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> with AutomaticKeepAliveClientMixin<ToDoScreen> {
  MySharedPreferences prefs = MySharedPreferences.getInstance();
  final _globalKey = GlobalKey<ScaffoldMessengerState>();
  int orderCount = 2;
  String name = "";
  String imageUrl =
      "https://firebasestorage.googleapis.com/v0/b/sendoff-test-9da1e.appspot.com/o/Images%2F1696080631555-admin.png?alt=media&token=19ede062-1b9c-49bb-9409-dda82334bf31";
  String productsName = "";
  int messagesPerPage = 10;
  DocumentSnapshot? lastDocument;
  Admin? admin;
  List<order_number.Order> orderList = [];
  List<ToDoSaveModel> todoList = [];
  TextEditingController sendMessageController = TextEditingController();
  Stream<QuerySnapshot<Map<String, dynamic>>>? stream;
  ItemScrollController controller = ItemScrollController();
  List listMessage = [];
  bool isMessageSend = false;
  bool isLoading = true;

  @override
  Widget build(BuildContext buildContext) {
    return BlocProvider(
      create: (context) => TodoCubit()
        ..getAdminId()
        ..fetchOrderCount(),
      child: BlocConsumer<TodoCubit, TodoState>(
        listener: (context, state) {
          //log"Search state: ${state.toString()}");
          if (state is SearchOrderCountLoadingState) {
            isLoading = true;
          } else if (state is SearchOrderCountSuccessState) {
            orderList = state.orderList;
            if (orderList.isEmpty) {
              productsName = "No Orders In Progress!";
            } else {
              productsName = getProductsName();
            }
            todoList = state.todoList;
            isLoading = false;
          } else if (state is SearchOrderCountFailedState) {
            showToast(context, state.message);
            isLoading = false;
          } else if (state is SearchAdminLoadingState) {
          } else if (state is SearchAdminSuccessState) {
            if (state.admin != null) {
              name = "${state.admin!.firstName} ${state.admin!.lastName}";
              imageUrl = state.admin!.image;
            } else {
              name = "";
            }
            ////log"Name: $name");
          } else if (state is OnOrderPlace) {
            //log"InOnOrderPlace");
            context.read<TodoCubit>()
              ..getAdminId()
              ..fetchOrderCount();
          }
        },
        builder: (context, state) {
          //log"Search state build: ${state.toString()}");
          return ScaffoldMessenger(
            key: _globalKey,
            child: Scaffold(
              body: SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.height * 0.023,
                  ),
                  margin: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Image.asset(
                              CustomAssets.arrowLeft,
                              height: 30.0,
                            ),
                          ),
                          StyledText(
                            text: name,
                            maxLines: 2,
                            height: 1.2,
                            fontSize: 32.0,
                            fontWeight: FontWeight.w600,
                            align: TextAlign.center,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              imageUrl != ""
                                  ? ClipOval(
                                      child: CircleAvatar(
                                        radius: 30.0,
                                        backgroundColor: Colors.transparent,
                                        child: Image.network(
                                          imageUrl,
                                          height: 90,
                                          errorBuilder: (context, error, stackTrace) => SvgPicture.network(
                                            imageUrl, // for .svg extension
                                            height: 90,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const CircleAvatar(
                                      radius: 27.0,
                                      backgroundImage: AssetImage(CustomAssets.dummyProfile),
                                    ),
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Pallete.shadowColor.withOpacity(0.05),
                                  offset: const Offset(0, 3),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    imageUrl != ""
                                        ? ClipOval(
                                            child: CircleAvatar(
                                              radius: 30.0,
                                              backgroundColor: Colors.transparent,
                                              child: Image.network(
                                                imageUrl,
                                                height: 90,
                                                errorBuilder: (context, error, stackTrace) => SvgPicture.network(
                                                  imageUrl, // for .svg extension
                                                  height: 90,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const CircleAvatar(
                                            radius: 27.0,
                                            backgroundImage: AssetImage(CustomAssets.dummyProfile),
                                          ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.035,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (orderList.isNotEmpty)
                                                ? ("${orderList.length} Order in progess")
                                                : "No Orders!",
                                            textAlign: TextAlign.start,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Pallete.textColor,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "NunitoSans",
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5.0,
                                          ),
                                          Text(
                                            productsName,
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Pallete.textColorOnWhiteBG,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: "NunitoSans",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                isLoading
                                    ? const Expanded(
                                        child: Center(
                                          child: SizedBox(
                                            height: 40.0,
                                            width: 40.0,
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: todoList.isEmpty
                                            ? const Center(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.hourglass_empty),
                                                    SizedBox(
                                                      height: 30.0,
                                                    ),
                                                    Text("No Products Available for this Category!"),
                                                  ],
                                                ),
                                              )
                                            : ListView.builder(
                                                shrinkWrap: true,
                                                physics: const BouncingScrollPhysics(),
                                                itemCount: todoList.length,
                                                itemBuilder: (context, index) {
                                                  return ToDoItem(
                                                    index: index,
                                                    todoList: todoList,
                                                    onChecked: (bool check, int index) async {
                                                      var box = await Hive.openBox('testBox');
                                                      box.put(todoList[index].taskId, check);
                                                    },
                                                  );
                                                },
                                              ),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomButton(
                                          color: Pallete.primary,
                                          borderRadius: 30.0,
                                          height: MediaQuery.of(context).size.height * .047,
                                          width: MediaQuery.of(context).size.width * .36,
                                          onPressed: () async {
                                            await launchCallApp();
                                          },
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Image.asset(
                                                  CustomAssets.call,
                                                  height: 20.0,
                                                ),
                                                const StyledText(
                                                  text: "Call Sendoff",
                                                  fontSize: 14.0,
                                                  maxLines: 1,
                                                  align: TextAlign.center,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: CustomButton(
                                          color: Pallete.primary,
                                          borderRadius: 30.0,
                                          height: MediaQuery.of(context).size.height * .047,
                                          width: MediaQuery.of(context).size.width * .36,
                                          onPressed: () async {
                                            launchWhatsapp(buildContext);
                                          },
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Image.asset(
                                                  CustomAssets.whatsapp,
                                                  height: 20.0,
                                                ),
                                                const StyledText(
                                                  text: "Whatsapp",
                                                  fontSize: 14.0,
                                                  maxLines: 1,
                                                  align: TextAlign.center,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
              ),
            ),
          );
        },
      ),
    );
  }

  int getCurrentUtcTime() {
    return DateTime.now().toUtc().millisecondsSinceEpoch;
  }

  launchCallApp() async {
    String phone = "+27104484430";
    String callUrl = "tel://$phone";
    if (await canLaunchUrl(Uri.parse(callUrl))) {
      await launchUrl(Uri.parse(callUrl));
    } else {
      if (mounted) {
        if (_globalKey.currentState != null) {
          _globalKey.currentState!
              .showSnackBar(const SnackBar(content: Text("Call App is not installed on your device.")));
        }
      }
    }
  }

  launchWhatsapp(context) async {
    String phone = "+27663153430";
    final whatsappUrl = "whatsapp://send?phone=$phone";
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      if (mounted) {
        if (_globalKey.currentState != null) {
          _globalKey.currentState!
              .showSnackBar(const SnackBar(content: Text("WhatsApp is not installed on your device.")));
        }
      }
    }
  }

  String getProductsName() {
    String productsName = '';
    for (order_number.Order order in orderList) {
      if (productsName.isNotEmpty) {
        productsName += ', ';
      }
      String innerProductName = "";
      ////log"orderProducts: ${order.products.toString()}");
      for (int i = 0; i < order.products.length; i++) {
        OrderProduct orderProduct = order.products[i];
        if (i == order.products.length - 1) {
          innerProductName += orderProduct.productName;
        } else {
          innerProductName += "${orderProduct.productName},";
        }
      }
      productsName += innerProductName;
    }
    return productsName;
  }

  @override
  bool get wantKeepAlive => true;
}
