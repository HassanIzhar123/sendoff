
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendoff/helper/helper_functions.dart';
import 'package:sendoff/models/Search/category_product.dart';
import 'package:sendoff/models/helper/NavigatingTabChangeModel.dart';
import 'package:sendoff/models/product/product.dart';
import 'package:sendoff/screens/categories/article_product_details.dart';
import 'package:sendoff/screens/categories/category_products.dart';
import 'package:sendoff/screens/categories/product_details.dart';
import '../../bloc/cubit/all_categories/all_categories_cubit.dart';
import '../../bloc/cubit/all_categories/all_categories_state.dart';
import '../../helper/all_text.dart';
import '../../helper/pallet.dart';
import '../../repositories/all_categories/all_categories_repository.dart';
import '../../widgets/styled_text.dart';
import '../categories/all_categories.dart';
import '../categories/widgets/search_bar.dart';

class SearchScreen extends StatefulWidget {
  final Function(int position, bool isTalkToHuman) onTabChange;
  final AllCategoriesCubit allCategoryCubit;

  const SearchScreen({super.key, required this.allCategoryCubit, required this.onTabChange});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin<SearchScreen> {
  final searchController = TextEditingController();
  List<CategoryProduct> filteredItems = [];
  List<CategoryProduct> items = [];
  String _query = '';
  final _globalKey = GlobalKey<ScaffoldMessengerState>();
  Stream<List<CategoryProduct>> stream = const Stream.empty();

  void search(String query) {
    setState(
      () {
        _query = query;
        filteredItems = items.where((item) {
          if (item.categoryOrProduct == CategoryOrProduct.category) {
            return item.category!.name.toLowerCase().contains(
                  query.toLowerCase(),
                );
          } else {
            return item.product!.name.toLowerCase().contains(
                  query.toLowerCase(),
                );
          }
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => AllCategoriesCubit(AllCategoriesRepository())..fetchCategoryProductData(),
      child: BlocConsumer<AllCategoriesCubit, AllCategoriesState>(
        listener: (context, state) {
          if (state is AllCategoryProductSuccessState) {
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
                      Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.025),
                        child: SearchTextField(
                          controller: searchController,
                          isEnable: true,
                          onChanged: (value) {
                            search(value);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Expanded(
                        child: StreamBuilder<List<CategoryProduct>>(
                          stream: stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final data = snapshot.data;
                              items = data != null
                                  ? data.isNotEmpty
                                      ? data
                                      : []
                                  : [];
                              return filteredItems.isNotEmpty || _query.isNotEmpty
                                  ? filteredItems.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No Results Found',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: filteredItems.length,
                                          itemBuilder: (context, index) {
                                            return CategoryOption(
                                              index: index,
                                              label:
                                                  filteredItems[index].categoryOrProduct == CategoryOrProduct.category
                                                      ? filteredItems[index].category!.name
                                                      : filteredItems[index].product!.name,
                                              image:
                                                  filteredItems[index].categoryOrProduct == CategoryOrProduct.category
                                                      ? filteredItems[index].category!.image
                                                      : filteredItems[index].product != null
                                                          ? (filteredItems[index].product!.images.isNotEmpty
                                                              ? filteredItems[index].product!.images[0]
                                                              : "")
                                                          : "",
                                              bgColor: Pallete.cremationBG,
                                              onPressed: () async {
                                                FocusScope.of(context).requestFocus(FocusNode());
                                                CategoryProduct item = filteredItems[index];
                                                if (item.categoryOrProduct == CategoryOrProduct.category) {
                                                  if (items[index].category!.description.runtimeType == List<dynamic>) {
                                                    screenPush(
                                                      context,
                                                      ArticleProductDetails(
                                                        name: item.category!.name,
                                                        descriptions: item.category!.description.cast<String>(),
                                                      ),
                                                    );
                                                  } else {
                                                    if (item.category!.talktoHuman == true) {
                                                      widget.onTabChange(3, true);
                                                    } else {
                                                      Object? value = await getValueAfterScreenPush(
                                                          context,
                                                          CategoryProducts(
                                                              item.category!.documentId, item.category!.name));
                                                      if (value != null) {
                                                        NavigatingTabChangeModel navigatingTabChangeModel =
                                                            value as NavigatingTabChangeModel;
                                                        widget.onTabChange(navigatingTabChangeModel.position, false);
                                                      }
                                                    }
                                                  }
                                                } else {
                                                  List<Product> data = [];
                                                  for (int i = 0; i < items.length; i++) {
                                                    if (items[i].categoryOrProduct == CategoryOrProduct.product) {
                                                      if (items[i].product!.categoryId == item.product!.categoryId) {
                                                        data.add(items[i].product!);
                                                      }
                                                    }
                                                  }
                                                  // List<Product> recommendedProducts = [];
                                                  // List<Product> removedProducts = [];
                                                  // removedProducts.addAll(data);
                                                  // removedProducts.remove(item.product!);
                                                  // if (removedProducts.length >= 3) {
                                                  //   recommendedProducts.add(removedProducts[0]);
                                                  //   recommendedProducts.add(removedProducts[1]);
                                                  //   recommendedProducts.add(removedProducts[2]);
                                                  // } else {
                                                  //   recommendedProducts = removedProducts;
                                                  // }
                                                  screenPush(
                                                    context,
                                                    ProductDetails(
                                                        // recommendedProducts: recommendedProducts,
                                                        products: data,
                                                        currentProduct: item.product!,
                                                        isArticle: (item.categoryOrProduct == CategoryOrProduct.product)
                                                            ? (item.product != null)
                                                                ? item.product!.isArticleProduct
                                                                : false
                                                            : false),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        )
                                  : items.isEmpty
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
                                      : ListView(
                                          physics: const BouncingScrollPhysics(),
                                          shrinkWrap: true,
                                          children: items
                                              .asMap()
                                              .map((index, i) {
                                                final item = items[index];
                                                return MapEntry(
                                                  index,
                                                  CategoryOption(
                                                      index: index,
                                                      label: item.categoryOrProduct == CategoryOrProduct.category
                                                          ? item.category!.name
                                                          : item.product!.name,
                                                      image: item.categoryOrProduct == CategoryOrProduct.category
                                                          ? item.category!.image
                                                          : item.product != null
                                                              ? (item.product!.images.isNotEmpty
                                                                  ? item.product!.images[0]
                                                                  : "")
                                                              : "",
                                                      bgColor: Pallete.cremationBG,
                                                      onPressed: () async {
                                                        FocusScope.of(context).requestFocus(FocusNode());
                                                        if (item.categoryOrProduct == CategoryOrProduct.category) {
                                                          if (items[index].category!.description.runtimeType ==
                                                              List<dynamic>) {
                                                            screenPush(
                                                              context,
                                                              ArticleProductDetails(
                                                                name: item.category!.name,
                                                                descriptions: item.category!.description.cast<String>(),
                                                              ),
                                                            );
                                                          } else {
                                                            if (item.category!.talktoHuman == true) {
                                                              widget.onTabChange(3, true);
                                                            } else {
                                                              Object? value = await getValueAfterScreenPush(
                                                                  context,
                                                                  CategoryProducts(
                                                                      item.category!.documentId, item.category!.name));
                                                              if (value != null) {
                                                                NavigatingTabChangeModel navigatingTabChangeModel =
                                                                    value as NavigatingTabChangeModel;
                                                                widget.onTabChange(
                                                                    navigatingTabChangeModel.position, false);
                                                              }
                                                            }
                                                          }
                                                        } else {
                                                          List<Product> data = [];
                                                          for (int i = 0; i < items.length; i++) {
                                                            if (items[i].categoryOrProduct ==
                                                                CategoryOrProduct.product) {
                                                              if (items[i].product!.categoryId ==
                                                                  item.product!.categoryId) {
                                                                data.add(items[i].product!);
                                                              }
                                                            }
                                                          }
                                                          // List<Product> recommendedProducts = [];
                                                          // List<Product> removedProducts = [];
                                                          // removedProducts.addAll(data);
                                                          // removedProducts.remove(item.product!);
                                                          // if (removedProducts.length >= 3) {
                                                          //   recommendedProducts.add(removedProducts[0]);
                                                          //   recommendedProducts.add(removedProducts[1]);
                                                          //   recommendedProducts.add(removedProducts[2]);
                                                          // } else {
                                                          //   recommendedProducts = removedProducts;
                                                          // }
                                                          screenPush(
                                                            context,
                                                            ProductDetails(
                                                              // recommendedProducts: recommendedProducts,
                                                              products: data,
                                                              currentProduct: item.product!,
                                                              isArticle:
                                                                  (item.categoryOrProduct == CategoryOrProduct.product)
                                                                      ? (item.product != null)
                                                                          ? item.product!.isArticleProduct
                                                                          : false
                                                                      : false,
                                                            ),
                                                          );
                                                        }
                                                      }),
                                                );
                                              })
                                              .values
                                              .toList(),
                                        );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            return const Center(
                              child: SizedBox(
                                height: 50.0,
                                width: 50.0,
                                child: CircularProgressIndicator(),
                              ),
                            ); // Loading indicator
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
