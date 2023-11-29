import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sendoff/bloc/cubit/products/products_cubit.dart';
import 'package:sendoff/bloc/cubit/products/products_state.dart';
import 'package:sendoff/repositories/products/products_repository.dart';
import 'package:sendoff/screens/categories/product_details.dart';
import 'package:sendoff/screens/categories/widgets/cat_product.dart';
import '../../helper/assets.dart';
import '../../helper/helper_functions.dart';
import '../../helper/pallet.dart';
import '../../models/product/product.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/styled_text.dart';

class CategoryProducts extends StatefulWidget {
  String categoryId;
  String name;

  CategoryProducts(this.categoryId, this.name, {super.key});

  @override
  State<CategoryProducts> createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  bool filter = false;
  Stream<List<Product>> productsStream = const Stream<List<Product>>.empty();
  List<Product> list = [], filteredList = [];
  final _globalKey = GlobalKey<ScaffoldMessengerState>();
  Product? product;
  double filteredAverageRating = 0.0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductsCubit(ProductsRepository())..fetchCategoriesData(widget.categoryId),
      child: BlocConsumer<ProductsCubit, ProductsState>(
        listener: (context, state) {
          if (state is ProductsSuccessState) {
            productsStream = state.allCategoriesStream;
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
                    horizontal: MediaQuery.of(context).size.height * 0.023,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Image.asset(
                              CustomAssets.arrowLeft,
                              height: 28.0,
                            ),
                          ),
                          Expanded(
                            child: widget.name != null
                                ? StyledText(
                                    text: widget.name,
                                    maxLines: 2,
                                    height: 1.2,
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.w600,
                                    align: TextAlign.center,
                                  )
                                : const StyledText(
                                    text: "",
                                    maxLines: 2,
                                    height: 1.2,
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.w600,
                                    align: TextAlign.center,
                                  ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                filter = !filter;
                                if (product != null) {
                                  showPriceRangeBottomSheet(context, 0.0, product!.price.toDouble());
                                }
                              });
                            },
                            child: Image.asset(
                              filter ? CustomAssets.filterFilled : CustomAssets.filter,
                              height: 24.0,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: StreamBuilder<List<Product>>(
                          stream: productsStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final List<Product> data = snapshot.data!;
                              list = data != null
                                  ? data.isNotEmpty
                                      ? data
                                      : []
                                  : [];
                              if (list.isNotEmpty) {
                                product =
                                    list.reduce((currentMax, obj) => obj.price > currentMax.price ? obj : currentMax);
                              }
                              return filteredList.isNotEmpty
                                  ? filteredList.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No Results Found',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: filteredList.length,
                                          itemBuilder: (context, index) {
                                            var item = filteredList[index];
                                            return CatProduct(
                                              image: item.images.isNotEmpty ? item.images[0] : "",
                                              label: item.name,
                                              desc: item.description,
                                              averageRating: item.averageRating,
                                              price: "R${item.price.toStringAsFixed(2)}",
                                              onPressed: () async {
                                                screenPush(
                                                  context,
                                                  ProductDetails(
                                                    products: data,
                                                    currentProduct: item,
                                                    isArticle: item.isArticleProduct,
                                                  ),
                                                );
                                              },
                                            );
                                          },
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
                                              Text("No Products Available for this Category!"),
                                            ],
                                          ),
                                        )
                                      : ListView(
                                          physics: const BouncingScrollPhysics(),
                                          shrinkWrap: true,
                                          children: data
                                              .asMap()
                                              .map((index, i) {
                                                final Product item = data[index];
                                                return MapEntry(
                                                  index,
                                                  CatProduct(
                                                    image: item.images.isNotEmpty ? item.images[0] : "",
                                                    label: item.name,
                                                    desc: item.description,
                                                    averageRating: item.averageRating,
                                                    price: "R${item.price.toStringAsFixed(2).toString()}",
                                                    onPressed: () {
                                                      screenPush(
                                                        context,
                                                        ProductDetails(
                                                          products: data,
                                                          currentProduct: item,
                                                          isArticle: item.isArticleProduct,
                                                        ),
                                                      );
                                                    },
                                                  ),
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

  void showPriceRangeBottomSheet(BuildContext context, double startingPrice, double lastPrice) {
    RangeValues priceRange = RangeValues(startingPrice, lastPrice);
    showModalBottomSheet(
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: PriceRangeBottomSheet(
            list: list,
            lastPrice: lastPrice,
            priceRange: priceRange,
            onPriceRangeChanged: (RangeValues newRange) {
              setState(() {
                priceRange = newRange;
              });
            },
            onFilteredApply: (List<Product> list) {
              setState(() {
                // filteredAverageRating = calculateReviews(list[]);
                filteredList = list;
              });
            },
            onClearApply: () {
              setState(() {
                filteredAverageRating = 0.0;
                filteredList = [];
              });
            },
          ),
        );
      },
    );
  }
}

class PriceRangeBottomSheet extends StatefulWidget {
  final List<Product> list;
  final double lastPrice;
  final RangeValues priceRange;
  final Function(RangeValues) onPriceRangeChanged;
  final Function(List<Product>) onFilteredApply;
  final Function() onClearApply;

  const PriceRangeBottomSheet({
    super.key,
    required this.list,
    required this.lastPrice,
    required this.priceRange,
    required this.onPriceRangeChanged,
    required this.onFilteredApply,
    required this.onClearApply,
  });

  @override
  _PriceRangeBottomSheetState createState() => _PriceRangeBottomSheetState();
}

class _PriceRangeBottomSheetState extends State<PriceRangeBottomSheet> {
  late RangeValues _currentRange;

  @override
  void initState() {
    super.initState();
    _currentRange = widget.priceRange;
  }

  List<Product> filterProductsByPriceRange(List<Product> products, double minPrice, double maxPrice) {
    return products.where((product) => product.price >= minPrice && product.price <= maxPrice).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .33,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              height: 5.0,
              width: 50.0,
              color: Pallete.grey1,
            ),
          ),
          const Center(
            child: StyledText(
              text: "Filter by price",
              maxLines: 1,
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Center(
            child: StyledText(
              text: "Spend a maximum of",
              maxLines: 1,
              color: Pallete.textColorOnWhiteBG,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const StyledText(
                      text: "R0",
                      maxLines: 1,
                      color: Pallete.textColorOnWhiteBG,
                    ),
                    StyledText(
                      text: "R${widget.lastPrice.toStringAsFixed(2) ?? "0"}",
                      maxLines: 1,
                      color: Pallete.textColorOnWhiteBG,
                    )
                  ],
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                    trackHeight: 6.0,
                    rangeThumbShape: CustomRangeThumbShape(),
                    showValueIndicator: ShowValueIndicator.always,
                    valueIndicatorTextStyle: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontFamily: "NunitoSans",
                    ),
                    rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape()),
                child: RangeSlider(
                  values: _currentRange,
                  activeColor: Pallete.primary,
                  inactiveColor: Pallete.priceRangeOffColor,
                  min: widget.priceRange.start,
                  max: widget.priceRange.end,
                  onChanged: (RangeValues newRange) {
                    setState(() {
                      _currentRange = newRange;
                    });
                    widget.onPriceRangeChanged(_currentRange);
                  },
                  labels: RangeLabels(
                    _currentRange.start.toStringAsFixed(0),
                    _currentRange.end.toStringAsFixed(0),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CustomButton(
                    color: Colors.white,
                    border: Border.all(width: 1.5, color: Pallete.textColor),
                    borderRadius: 30.0,
                    height: MediaQuery.of(context).size.height * .058,
                    onPressed: () {
                      widget.onClearApply();
                      Navigator.pop(context);
                    },
                    child: const Center(
                      child: StyledText(
                        text: "Clear",
                        fontSize: 17.0,
                        maxLines: 1,
                        align: TextAlign.center,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CustomButton(
                    color: Pallete.primary,
                    borderRadius: 30.0,
                    height: MediaQuery.of(context).size.height * .058,
                    onPressed: () {
                      List<Product> productsList =
                          filterProductsByPriceRange(widget.list, _currentRange.start, _currentRange.end);
                      widget.onFilteredApply(productsList);
                      Navigator.pop(context);
                    },
                    child: const Center(
                      child: StyledText(
                        text: "Apply",
                        fontSize: 17.0,
                        maxLines: 1,
                        align: TextAlign.center,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .015,
          ),
        ],
      ),
    );
  }
}

Future<List<Product>> streamToList(Stream<List<Product>> stream) async {
  final resultList = <Product>[];
  await for (final list in stream) {
    resultList.addAll(list);
  }
  return resultList;
}

class CustomRangeThumbShape extends RangeSliderThumbShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.fromRadius(15.0);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    bool isPressed = false,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
  }) {
    final Canvas canvas = context.canvas;
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );
    final Color color = colorTween.evaluate(enableAnimation)!;

    final Path thumbPath = Path();
    thumbPath.addOval(Rect.fromCircle(center: center, radius: 13.0));

    canvas.drawShadow(thumbPath, Pallete.shadowColor.withOpacity(0.2), 5.0, true);

    canvas.drawCircle(
      center,
      13.0,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    canvas.drawCircle(
      center,
      12.0,
      Paint()..color = color,
    );
  }
}
