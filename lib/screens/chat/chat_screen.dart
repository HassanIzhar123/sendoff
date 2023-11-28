import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sendoff/helper/MySharedPreferences.dart';
import 'package:sendoff/models/PushOrder/OrderProduct.dart';
import 'package:sendoff/screens/todo/todo_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/cubit/chats/chats_cubit.dart';
import '../../bloc/cubit/chats/chats_state.dart';
import '../../helper/assets.dart';
import '../../helper/helper_functions.dart';
import '../../helper/pallet.dart';
import '../../models/chats/admin.dart';
import '../../models/chats/chat.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/styled_text.dart';
import '../authentication/widgets/custom_text_field.dart';
import '../../../models/PushOrder/Order.dart' as order_number;

class ChatScreen extends StatefulWidget {
  final ChatsCubit chatsCubit;
  final Function() onWidgetChange;
  final bool isTalkToHuman;

  const ChatScreen(
      {super.key,
      required this.chatsCubit,
      required this.isTalkToHuman,
      required this.onWidgetChange});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin<ChatScreen> {
  Admin? admin;
  List<order_number.Order> orderList = [];
  TextEditingController sendMessageController = TextEditingController();
  Stream<QuerySnapshot<Map<String, dynamic>>>? stream;
  MySharedPreferences prefs = MySharedPreferences.getInstance();
  int messagesPerPage = 10;
  DocumentSnapshot? lastDocument;
  List<Chat> chatMessages = [];
  ItemScrollController controller = ItemScrollController();
  List listMessage = [];
  bool isMessageSend = false;
  String name = "", imageUrl = "", productsName = "";
  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    prefs.getCustomerId();
    return BlocProvider(
      create: (context) => widget.chatsCubit
        ..fetchOrderCount()
        ..getAdminId()
        ..getChatMessages(
          messagesPerPage,
          lastDocument,
        ),
      child: BlocConsumer<ChatsCubit, ChatsState>(
        listener: (context, state) {
          if (state is ChatsLoadingState) {
          } else if (state is ChatsSuccessState) {
            stream = state.stream;
            stream!.listen((snapshot) {
              for (int i = 0; i < snapshot.docChanges.length; i++) {
                var change = snapshot.docChanges[i];
                switch (change.type) {
                  case DocumentChangeType.added:
                    if (!isMessageSend) {
                      if (i == snapshot.docChanges.length - 1) {
                        lastDocument = change.doc;
                      }
                      String messageId = change.doc.id;
                      if (!chatMessages
                          .any((chat) => chat.messageId == messageId)) {
                        chatMessages.add(
                          Chat(
                            displayName: change.doc.get("displayName"),
                            text: change.doc.get('text'),
                            timestamp: change.doc.get('timestamp'),
                            uid: change.doc.get("uid"),
                            messageId: messageId,
                            read: change.doc.data()!.containsKey('read')
                                ? change.doc.get("read")
                                : false,
                          ),
                        );
                      }
                      // chatMessages.add(
                      //   Chat(
                      //     displayName: change.doc.get("displayName"),
                      //     text: change.doc.get('text'),
                      //     timestamp: change.doc.get('timestamp'),
                      //     uid: change.doc.get("uid"),
                      //     messageId: change.doc.id,
                      //     read: change.doc.data()!.containsKey('read') ? change.doc.get("read") : false,
                      //   ),
                      // );
                    } else {
                      String messageId = change.doc.id;
                      if (!chatMessages
                          .any((chat) => chat.messageId == messageId)) {
                        chatMessages.insert(
                          0,
                          Chat(
                            displayName: change.doc.get("displayName"),
                            text: change.doc.get('text'),
                            timestamp: change.doc.get('timestamp'),
                            uid: change.doc.get("uid"),
                            messageId: messageId,
                            read: change.doc.data()!.containsKey('read')
                                ? change.doc.get("read")
                                : false,
                          ),
                        );
                      }
                      // chatMessages.insert(
                      //   0,
                      //   Chat(
                      //     displayName: change.doc.get("displayName"),
                      //     text: change.doc.get('text'),
                      //     timestamp: change.doc.get('timestamp'),
                      //     uid: change.doc.get("uid"),
                      //     messageId: change.doc.id,
                      //   ),
                      // );
                      isMessageSend = false;
                    }
                    break;
                  case DocumentChangeType.modified:
                    int index = chatMessages
                        .indexWhere((obj) => obj.messageId == change.doc.id);
                    Chat chat = Chat.fromMap(change.doc.data()!, change.doc.id);
                    if (index != -1) {
                      setState(() {
                        chatMessages[index] = chat;
                      });
                    }
                    // int index = chatMessages.indexWhere((obj) => obj.messageId == change.doc.id);
                    // Chat chat = Chat.fromMap(change.doc.data()!, change.doc.id);
                    // setState(() {
                    //   chatMessages[index] = chat;
                    // });
                    break;
                  case DocumentChangeType.removed:
                    // TODO: Handle this case.
                    break;
                }
              }
              // var distinctIds = chatMessages.toSet().toList();
              // chatMessages.addAll(distinctIds);
              chatMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
              log("chatMessagtes: ${chatMessages.toString()}");
              setState(() {});
            });
          } else if (state is ChatsFailedState) {
            if (state.message == "customer is not signed In") {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      "Please note: You are not logged in; Only the Call Sendoff and WhatsApp functionality will be available"),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
              ));
            }
          } else if (state is ChatsOrderCountLoadingState) {
          } else if (state is ChatsOrderCountSuccessState) {
            orderList = state.orderList;
            if (orderList.isEmpty) {
              productsName = "No Orders In Progress!";
            } else {
              productsName = getProductsName();
            }
          } else if (state is ChatsAdminLoadingState) {
          } else if (state is ChatsAdminSuccessState) {
            if (state.admin != null) {
              name = "${state.admin!.firstName} ${state.admin!.lastName}";
              imageUrl = state.admin!.image;
            } else {
              name = "";
            }
          } else if (state is ChatsSendMessageLoadingState) {
            sendMessageController.text = "";
          } else if (state is ChatsSendMessageSuccessState) {
          } else if (state is ChatsSendMessageFailedState) {
            if (state.message == "customer is not signed In") {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Please note: You are not logged in; Only the Call Sendoff and WhatsApp functionality will be available",
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
              ));
            }
          } else if (state is OnOrderPlace) {
            widget.chatsCubit
              ..fetchOrderCount()
              ..getAdminId()
              ..getChatMessages(
                messagesPerPage,
                lastDocument,
              );
          } else if (state is ShowIsTalkToHumanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Please note: You are not logged in; Only the Call Sendoff and WhatsApp functionality will be available",
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return ScaffoldMessenger(
            key: _globalKey,
            child: Scaffold(
              extendBodyBehindAppBar: true,
              body: SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.height * 0.023,
                  ),
                  // margin: const EdgeInsets.only(
                  //   top: 10.0,
                  // ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              widget.onWidgetChange();
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
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Pallete.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            onPressed: () async {
                              await screenPush(
                                context,
                                const ToDoScreen(),
                              );
                            },
                            child: const Text("ToDo's"),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
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
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Image.network(
                                                imageUrl,
                                                height: 90,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    SvgPicture.network(
                                                  imageUrl, // for .svg extension
                                                  height: 90,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const CircleAvatar(
                                            radius: 27.0,
                                            backgroundImage: AssetImage(
                                                CustomAssets.dummyProfile),
                                          ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.035,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                    // SizedBox(
                                    //   width: MediaQuery.of(context).size.width * 0.035,
                                    // ),
                                    // Image.asset(
                                    //   CustomAssets.arrowRight,
                                    //   height: 14.0,
                                    // ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      state is ChatsLoadingState
                                          ? const CircularProgressIndicator()
                                          : const SizedBox(),
                                      Expanded(
                                        child: NotificationListener<
                                            ScrollEndNotification>(
                                          onNotification: (scrollEnd) {
                                            final metrics = scrollEnd.metrics;
                                            if (metrics.atEdge) {
                                              bool isTop = metrics.pixels == 0;
                                              if (!isTop) {
                                                ////log"scroll is on top ${lastDocument.toString()}");
                                                context
                                                    .read<ChatsCubit>()
                                                    .getChatMessages(
                                                        messagesPerPage,
                                                        lastDocument);
                                                //log"lastDocument1: ${lastDocument.toString()}");
                                                // controller.scrollTo(index: 0, duration: Duration.zero);
                                              }
                                            }
                                            return true;
                                          },
                                          child:
                                              ScrollablePositionedList.builder(
                                            reverse: true,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemScrollController: controller,
                                            itemCount: chatMessages.length,
                                            itemBuilder: (context, index) {
                                              return TextMessage(
                                                received:
                                                    chatMessages[index].uid ==
                                                            prefs.customerId
                                                        ? false
                                                        : true,
                                                text: chatMessages[index].text,
                                                time: chatMessages[index]
                                                    .timestamp,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: CustomTextField(
                                    controller: sendMessageController,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    suffix: IconButton(
                                      onPressed: () {
                                        if (sendMessageController.text == "") {
                                          if (_globalKey.currentState != null) {
                                            var snackBar = const SnackBar(
                                                content: Text(
                                                    'please type something!'));
                                            _globalKey.currentState!
                                                .showSnackBar(snackBar);
                                          }
                                        } else {
                                          isMessageSend = true;
                                          context
                                              .read<ChatsCubit>()
                                              .sendMessage(
                                                  sendMessageController.text,
                                                  getCurrentUtcTime());
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.send,
                                        size: 35.0,
                                        color: Pallete.primary,
                                      ),
                                    ),
                                    hintText: "Type your message...",
                                    fillColor: Colors.white,
                                    borderColor:
                                        Pallete.textColor.withOpacity(.1),
                                    hintStyle: const TextStyle(
                                      fontFamily: "NunitoSans",
                                      fontSize: 17.0,
                                      color: Pallete.msgHintTextColor,
                                    ),
                                    validator: (val) {
                                      return null;
                                    },
                                    onChanged: (val) {},
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomButton(
                                          color: Pallete.primary,
                                          borderRadius: 30.0,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .047,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .36,
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .047,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .36,
                                          onPressed: () async {
                                            await launchWhatsapp();
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

  @override
  bool get wantKeepAlive => true;

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

  String getName() {
    if (admin != null) {
      return "${admin!.firstName} ${admin!.lastName}";
    } else {
      return "";
    }
  }

  String getProductsName() {
    String productsName = '';
    for (order_number.Order order in orderList) {
      if (productsName.isNotEmpty) {
        productsName += ', ';
      }
      String innerProductName = "";
      //log"orderProducts: ${order.products.toString()}");
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
}

class VoiceMessage extends StatelessWidget {
  final bool received;
  final String time;

  const VoiceMessage({
    Key? key,
    required this.received,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Align(
        alignment: received ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width * .7,
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: received ? Pallete.grey2 : Pallete.chatBGColor,
            borderRadius: received
                ? const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0),
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.play_arrow,
                color: Pallete.primary,
                size: 30,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Container(
                  height: 2.0,
                  color: Pallete.chatVoiceLineColor,
                ),
              ),
              const SizedBox(width: 8.0),
              StyledText(
                text: time,
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TextMessage extends StatelessWidget {
  final bool received;
  final String text;
  final int time;

  const TextMessage(
      {super.key,
      required this.received,
      required this.text,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Align(
        alignment: received ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: received ? Pallete.grey2 : Pallete.chatBGColor,
            borderRadius: received
                ? const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0),
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8.0),
              Flexible(
                child: StyledText(
                  text: text,
                  fontSize: 15.0,
                ),
              ),
              const SizedBox(width: 8.0),
              StyledText(
                text: convertTime(time),
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
              )
            ],
          ),
        ),
      ),
    );
  }

  String convertTime(int timeStamp) {
    return DateFormat('HH:mm')
        .format(DateTime.fromMillisecondsSinceEpoch(timeStamp));
  }
}
