import 'package:foap/controllers/post_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import '../../components/post_card.dart';
import '../../model/post_model.dart';

class ViewPostInsights extends StatefulWidget {
  final PostModel post;

  const ViewPostInsights({Key? key, required this.post}) : super(key: key);

  @override
  State<ViewPostInsights> createState() => _ViewPostInsightsState();
}

class _ViewPostInsightsState extends State<ViewPostInsights> {
  final PostController _postController = Get.find();

  @override
  void initState() {
    // _postController.viewInsight(widget.post.id);
    _postController.viewInsight(1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 55,
          ),
          backNavigationBar(
              context: context, title: LocalizationString.insights),
          divider(context: context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: PostMediaTile(
                      model: widget.post,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        ThemeIconWidget(ThemeIcon.message),
                        const SizedBox(
                          height: 5,
                        ),
                        BodySmallText(
                          widget.post.totalComment.toString(),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        ThemeIconWidget(ThemeIcon.favFilled),
                        const SizedBox(
                          height: 5,
                        ),
                        BodySmallText(
                          widget.post.totalLike.toString(),
                        )
                      ],
                    ),
                    // Column(
                    //   children: [
                    //     ThemeIconWidget(ThemeIcon.send),
                    //     const SizedBox(
                    //       height: 5,
                    //     ),
                    //     BodySmallText(
                    //       '10',
                    //     )
                    //   ],
                    // ),
                    // Column(
                    //   children: [
                    //     ThemeIconWidget(ThemeIcon.bookMark),
                    //     const SizedBox(
                    //       height: 5,
                    //     ),
                    //     BodySmallText(
                    //       '10',
                    //     )
                    //   ],
                    // )
                  ],
                ).hp(50),
                divider(context: context).vP25,
                overView(),
                divider(context: context).vP25,
                viewByNetwork(),
                divider(context: context).vP25,
                postInteraction(),
                divider(context: context).vP25,
                profileActivity(),
                divider(context: context).vP25,
                viewByGender()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget overView() {
    return Obx(() => _postController.insight.value == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyLargeText(
                LocalizationString.overview,
                weight: TextWeight.semiBold,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    LocalizationString.accountsReached,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(
                      _postController.insight.value!.totalView.toString()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     BodyMediumText(
              //       LocalizationString.accountsEngaged,
              //       weight: TextWeight.medium,
              //     ),
              //     BodyMediumText(_postController.insight.value!.totalView.toString()),
              //   ],
              // ),
              // const SizedBox(
              //   height: 20,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(LocalizationString.views,
                      weight: TextWeight.medium),
                  BodyMediumText(
                      _postController.insight.value!.totalView.toString()),
                ],
              ),
            ],
          ).hP16);
  }

  Widget postInteraction() {
    return Obx(() => _postController.insight.value == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyLargeText(
                LocalizationString.postInteractions,
                weight: TextWeight.bold,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    LocalizationString.profileVisits,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(_postController
                      .insight.value!.profileViewFromPost
                      .toString()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    LocalizationString.follows,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(
                      _postController.insight.value!.followFromPost.toString()),
                ],
              ),
            ],
          ).hP16);
  }

  Widget viewByGender() {
    return Obx(() => _postController.insight.value == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyLargeText(
                LocalizationString.gender,
                weight: TextWeight.bold,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    LocalizationString.male,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(
                      _postController.insight.value!.viewFromMale.toString()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    LocalizationString.female,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(
                      _postController.insight.value!.viewFromFemale.toString()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    LocalizationString.other,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(
                      _postController.insight.value!.viewFromOther.toString()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    LocalizationString.noSpecified,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(_postController
                      .insight.value!.viewFromGenderNotDisclosed
                      .toString()),
                ],
              ),
            ],
          ).hP16);
  }

  Widget viewByNetwork() {
    return Obx(() => _postController.insight.value == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyLargeText(
                LocalizationString.network,
                weight: TextWeight.bold,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    LocalizationString.followers,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(_postController
                      .insight.value!.viewFromFollowers
                      .toString()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BodyMediumText(
                    LocalizationString.nonFollowers,
                    weight: TextWeight.medium,
                  ),
                  BodyMediumText(_postController
                      .insight.value!.viewFromNonFollowers
                      .toString()),
                ],
              ),
            ],
          ).hP16);
  }

  Widget profileActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyLargeText(
          LocalizationString.profileActivity,
          weight: TextWeight.bold,
        ),
        const SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BodyMediumText(
              LocalizationString.comments,
              weight: TextWeight.medium,
            ),
            BodyMediumText(widget.post.totalComment.toString()),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BodyMediumText(
              LocalizationString.likes,
              weight: TextWeight.medium,
            ),
            BodyMediumText(widget.post.totalLike.toString()),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     BodyMediumText(
        //       LocalizationString.saved,
        //       weight: TextWeight.medium,
        //     ),
        //     BodyMediumText('20'),
        //   ],
        // ),
      ],
    ).hP16;
  }
}
