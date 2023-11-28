import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sendoff/bloc/cubit/chats/chats_state.dart';
import 'package:sendoff/helper/MySharedPreferences.dart';
import 'package:sendoff/screens/cart/checkout.dart';
import 'package:sendoff/screens/categories/all_categories.dart';
import 'package:sendoff/screens/home/home_page.dart';
import '../../bloc/cubit/all_categories/all_categories_cubit.dart';
import '../../bloc/cubit/chats/chats_cubit.dart';
import '../../helper/assets.dart';
import '../../helper/pallet.dart';
import '../../repositories/all_categories/all_categories_repository.dart';
import '../chat/chat_screen.dart';
import '../search/search_screen.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ChatsCubit chatsCubit = ChatsCubit();
  late TabController _tabController;
  int _selectedIndex = 2;
  final allCategoryCubit = AllCategoriesCubit(AllCategoriesRepository());
  bool isTalkToHuman = false;
  MySharedPreferences prefs = MySharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(initialIndex: _selectedIndex, length: 5, vsync: this);
    _tabController.animation!.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_selectedIndex != _tabController.index) {
          setState(() {
            FocusScope.of(context).requestFocus(FocusNode());
            _selectedIndex = _tabController.index;
          });
        }
      } else {
        final int temp = _tabController.animation!.value.round();
        if (_selectedIndex != temp) {
          _selectedIndex = temp;
          setState(() {
            FocusScope.of(context).requestFocus(FocusNode());
            _tabController.index = _selectedIndex;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void selectTab(int tabIndex) {
    _tabController.animateTo(tabIndex);
    setState(() {
      _selectedIndex = tabIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    prefs.isSignedIn();
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: TabBarView(
          controller: _tabController,
          children: [
            AllCategories(
              allCategoryCubit: allCategoryCubit,
              onTabChange: (int position, bool isTalkToHuman) {
                FocusScope.of(context).requestFocus(FocusNode());
                this.isTalkToHuman = isTalkToHuman;
                selectTab(position);
                if (isTalkToHuman && prefs.isUserSignedIn == false) {
                  chatsCubit.emit(ShowIsTalkToHumanError(
                      DateTime.now().millisecondsSinceEpoch));
                }
              },
            ),
            SearchScreen(
              allCategoryCubit: allCategoryCubit,
              onTabChange: (int position, bool isTalkToHuman) {
                FocusScope.of(context).requestFocus(FocusNode());
                this.isTalkToHuman = isTalkToHuman;
                selectTab(position);
                if (isTalkToHuman && prefs.isUserSignedIn == false) {
                  chatsCubit.emit(ShowIsTalkToHumanError(
                      DateTime.now().millisecondsSinceEpoch));
                }
              },
            ),
            HomePage(
              forNavigationClicked: (int index) {
                selectTab(index);
              },
              onTabChange: (int position, bool isTalkToHuman) {
                FocusScope.of(context).requestFocus(FocusNode());
                this.isTalkToHuman = isTalkToHuman;
                selectTab(position);
                if (isTalkToHuman && prefs.isUserSignedIn == false) {
                  chatsCubit.emit(ShowIsTalkToHumanError(
                      DateTime.now().millisecondsSinceEpoch));
                }
              },
            ),
            ChatScreen(
              chatsCubit: chatsCubit,
              isTalkToHuman: isTalkToHuman,
              onWidgetChange: () {
                FocusScope.of(context).requestFocus(FocusNode());
                selectTab(2);
              },
            ),
            Checkout(
              chatsCubit: chatsCubit,
            ),
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: kToolbarHeight,
          child: BottomNavigationBar(
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedIconTheme: const IconThemeData(color: Pallete.primary),
            currentIndex: _selectedIndex,
            // iconSize: 20,
            unselectedIconTheme:
                const IconThemeData(color: Pallete.bottomNavDisabledColor),
            onTap: (index) {
              FocusScope.of(context).requestFocus(FocusNode());
              selectTab(index);
            },
            items: [
              BottomNavigationBarItem(
                label: "",
                icon: Center(
                  child: Container(
                    height: 25,
                    child: Image.asset(
                      CustomAssets.list,
                      // height: 25,
                      color: _selectedIndex == 0
                          ? Pallete.primary
                          : Pallete.bottomNavDisabledColor,
                    ),
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: "",
                icon: Image.asset(
                  CustomAssets.search,
                  height: 25,
                  color: _selectedIndex == 1
                      ? Pallete.primary
                      : Pallete.bottomNavDisabledColor,
                ),
              ),
              BottomNavigationBarItem(
                label: "",
                icon: Image.asset(
                  _selectedIndex == 2
                      ? CustomAssets.homeFilled
                      : CustomAssets.home,
                  height: 25,
                  color: _selectedIndex == 2
                      ? Pallete.primary
                      : Pallete.bottomNavDisabledColor,
                ),
              ),
              BottomNavigationBarItem(
                label: "",
                icon: Image.asset(
                  _selectedIndex == 3
                      ? CustomAssets.profileFilled
                      : CustomAssets.profile,
                  height: 25,
                  color: _selectedIndex == 3
                      ? Pallete.primary
                      : Pallete.bottomNavDisabledColor,
                ),
              ),
              BottomNavigationBarItem(
                label: "",
                icon: Image.asset(
                  _selectedIndex == 4
                      ? CustomAssets.cartFilled
                      : CustomAssets.cart,
                  height: 25,
                  color: _selectedIndex == 4
                      ? Pallete.primary
                      : Pallete.bottomNavDisabledColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
