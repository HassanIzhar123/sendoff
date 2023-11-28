import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendoff/bloc/cubit/all_categories/all_categories_cubit.dart';
import 'package:sendoff/models/helper/NavigatingTabChangeModel.dart';
import 'package:sendoff/repositories/all_categories/all_categories_repository.dart';
import 'package:sendoff/screens/categories/article_product_details.dart';
import '../../bloc/cubit/all_categories/all_categories_state.dart';
import '../../helper/all_text.dart';
import '../../helper/assets.dart';
import '../../helper/helper_functions.dart';
import '../../helper/pallet.dart';
import '../../models/category/category.dart';
import '../../widgets/styled_text.dart';
import 'category_products.dart';

class AllCategories extends StatefulWidget {
  final Function(int position, bool isTalkToHuman) onTabChange;
  final AllCategoriesCubit allCategoryCubit;

  const AllCategories({super.key, required this.allCategoryCubit, required this.onTabChange});

  @override
  State<AllCategories> createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategories> with AutomaticKeepAliveClientMixin<AllCategories> {
  final searchController = TextEditingController();
  final _globalKey = GlobalKey<ScaffoldMessengerState>();
  Stream<List<Category>> stream = const Stream.empty();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => AllCategoriesCubit(AllCategoriesRepository())..fetchCategoriesData(),
      child: BlocConsumer<AllCategoriesCubit, AllCategoriesState>(
        listener: (context, state) {
          if (state is AllCategoriesSuccessState) {
            stream = state.allCategoriesStream;
          }
        },
        builder: (context, state) {
          return ScaffoldMessenger(
            key: _globalKey,
            child: Scaffold(
              backgroundColor: Pallete.primaryLight,
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.height * 0.03,
                  ).copyWith(top: MediaQuery.of(context).size.height * .045),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(
                        height: 20.0,
                      ),
                      const StyledText(
                        text: AllText.categoriesPageTitle,
                        maxLines: 2,
                        height: 1.2,
                        fontSize: 32.0,
                        fontWeight: FontWeight.w700,
                        align: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Expanded(
                        child: StreamBuilder<List<Category>>(
                          stream: stream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: SizedBox(
                                  height: 40,
                                  width: 49,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.data != null) {
                              if (snapshot.data!.isEmpty) {
                                return const Center(
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
                                );
                              }
                              return ListView(
                                padding: EdgeInsets.zero,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  for (int i = 0; i < snapshot.data!.length; i++) ...{
                                    CategoryOption(
                                      label: snapshot.data![i].name,
                                      index: i,
                                      bgColor: Pallete.cremationBG,
                                      image: snapshot.data![i].image,
                                      onPressed: () async {
                                        if (snapshot.data![i].description.runtimeType == List<dynamic>) {
                                          screenPush(
                                            context,
                                            ArticleProductDetails(
                                              name: snapshot.data![i].name,
                                              descriptions: snapshot.data![i].description.cast<String>(),
                                            ),
                                          );
                                        } else {
                                          if (snapshot.data![i].talktoHuman == true) {
                                            widget.onTabChange(3, true);
                                          } else {
                                            Object? value = await getValueAfterScreenPush(
                                              context,
                                              CategoryProducts(
                                                snapshot.data![i].documentId,
                                                snapshot.data![i].name,
                                              ),
                                            );
                                            if (value != null) {
                                              NavigatingTabChangeModel navigatingTabChangeModel =
                                                  value as NavigatingTabChangeModel;
                                              widget.onTabChange(navigatingTabChangeModel.position, false);
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  }
                                ],
                              );
                            } else {
                              return const Center(
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
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
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
}

class CategoryOption extends StatelessWidget {
  final int index;
  final String label;
  final String image;
  final Color bgColor;
  final VoidCallback onPressed;

  const CategoryOption(
      {super.key,
      required this.index,
      required this.label,
      required this.image,
      required this.onPressed,
      required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        margin: EdgeInsets.only(top: index != 0 ? 10 : 0),
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        height: MediaQuery.of(context).size.height * 0.15,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.105,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
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
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.105,
                      width: MediaQuery.of(context).size.width * .25,
                      child: const Center(
                        child: Icon(Icons.error),
                      ),
                    ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.start,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 17.0,
                  color: Pallete.textColorOnWhiteBG,
                  fontWeight: FontWeight.w500,
                  fontFamily: "NunitoSans",
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Image.asset(
              CustomAssets.arrowRight,
              height: 14.0,
            ),
          ],
        ),
      ),
    );
  }
}
