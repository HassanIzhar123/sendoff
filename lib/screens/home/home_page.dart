import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/cubit/home_page/home_page_cubit.dart';
import '../../bloc/cubit/home_page/home_page_state.dart';
import '../../helper/all_text.dart';
import '../../helper/assets.dart';
import '../../helper/helper_functions.dart';
import '../../helper/pallet.dart';
import '../../models/category/category.dart';
import '../../models/helper/NavigatingTabChangeModel.dart';
import '../../repositories/home_page/home_page_repository.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/styled_text.dart';
import '../categories/article_product_details.dart';
import '../categories/category_products.dart';

class HomePage extends StatefulWidget {
  final Function(int position, bool isTalkToHuman) onTabChange;
  Function(int index) forNavigationClicked;

  HomePage({Key? key, required this.forNavigationClicked, required this.onTabChange}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage> {
  Stream<List<Category>> allCategoriesStream = const Stream<List<Category>>.empty();
  List<Category> items = [];
  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomePageCubit(HomePageRepository())..fetchCategoriesData(),
      child: BlocConsumer<HomePageCubit, HomePageState>(
        listener: (context, state) {
          //log"state: $state");
          if (state is HomePageSuccessState) {
            allCategoriesStream = state.homePageStream;
          }
        },
        builder: (context, state) {
          return ScaffoldMessenger(
            key: _globalKey,
            child: Scaffold(
              backgroundColor: Pallete.primaryLight,
              body: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height * 0.023,
                ).copyWith(top: MediaQuery.of(context).size.height * .045),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    const StyledText(
                      text: AllText.homePageTitle,
                      maxLines: 2,
                      height: 1.2,
                      fontSize: 32.0,
                      fontWeight: FontWeight.w700,
                      align: TextAlign.center,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.025),
                      child: const StyledText(
                        text: AllText.homePageSubTitle,
                        color: Pallete.textColorLighter,
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<Category>>(
                        stream: allCategoriesStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final data = snapshot.data;
                            items = data != null
                                ? data.isNotEmpty
                                    ? data
                                    : []
                                : [];
                            return items.isEmpty
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
                                            HomePageOption(
                                              label: item.name,
                                              image: item.image,
                                              bgColor: Pallete.cremationBG,
                                              onPressed: () async {
                                                if (items[index].description.runtimeType == List<dynamic>) {
                                                  screenPush(
                                                    context,
                                                    ArticleProductDetails(
                                                      name: item.name,
                                                      descriptions: item.description.cast<String>(),
                                                    ),
                                                  );
                                                } else {
                                                  if (items[index].talktoHuman == true) {
                                                    widget.onTabChange(3, true);
                                                  } else {
                                                    Object? value = await getValueAfterScreenPush(
                                                        context, CategoryProducts(item.documentId, item.name));
                                                    if (value != null) {
                                                      NavigatingTabChangeModel navigatingTabChangeModel =
                                                          value as NavigatingTabChangeModel;
                                                      widget.onTabChange(navigatingTabChangeModel.position, false);
                                                    }
                                                  }
                                                }
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
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: CustomButton(
                        key: widget.key,
                        color: Pallete.primary,
                        borderRadius: 30.0,
                        height: MediaQuery.of(context).size.height * .058,
                        width: MediaQuery.of(context).size.width * .44,
                        onPressed: () {
                          widget.forNavigationClicked(0);
                        },
                        child: const Center(
                          child: StyledText(
                            text: "See All Options",
                            maxLines: 2,
                            align: TextAlign.center,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
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

class HomePageOption extends StatelessWidget {
  final String label;
  final String image;
  final Color bgColor;
  final VoidCallback onPressed;

  const HomePageOption(
      {super.key, required this.label, required this.image, required this.onPressed, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.018,
      ),
      child: InkWell(
        onTap: onPressed,
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.105,
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
                          width: MediaQuery.of(context).size.width * .25,
                          child: const Icon(Icons.error),
                        ),
                ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.4,
                    fontSize: 17.0,
                    color: Pallete.textColorOnWhiteBG,
                    fontWeight: FontWeight.w500,
                    fontFamily: "NunitoSans",
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.035,
              ),
              Image.asset(
                CustomAssets.arrowRight,
                height: 14.0,
              ),
              const SizedBox(
                width: 10.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
