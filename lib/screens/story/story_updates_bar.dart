import 'package:foap/components/thumbnail_view.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';
import 'package:foap/helper/string_extension.dart';

double storyCircleSize = 50;

class StoryUpdatesBar extends StatelessWidget {
  final List<StoryModel> stories;

  final VoidCallback addStoryCallback;
  final Function(StoryModel) viewStoryCallback;

  const StoryUpdatesBar({
    super.key,
    required this.stories,
    required this.addStoryCallback,
    required this.viewStoryCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(right: DesignConstants.horizontalPadding),
      scrollDirection: Axis.horizontal,
      itemCount: stories.length + 1,
      itemBuilder: (BuildContext ctx, int index) {
        if (index == 0) {
          return SizedBox(
            width: storyCircleSize + 20,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: storyCircleSize,
                      width: storyCircleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColorConstants.themeColor
                            .withValues(alpha: 0.12),
                        border: Border.all(
                            color: AppColorConstants.themeColor
                                .withValues(alpha: 0.35),
                            width: 1.5),
                      ),
                      child: Icon(Icons.person_rounded,
                          size: storyCircleSize * 0.5,
                          color: AppColorConstants.themeColor
                              .withValues(alpha: 0.6)),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        height: 22,
                        width: 22,
                        decoration: BoxDecoration(
                          color: AppColorConstants.themeColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColorConstants.backgroundColor,
                              width: 2),
                        ),
                        child: const Icon(Icons.add_rounded,
                            size: 15, color: Colors.white),
                      ),
                    ),
                  ],
                ).ripple(() {
                  addStoryCallback();
                }),
                const SizedBox(
                  height: 6,
                ),
                BodySmallText(yourStoryString.tr, weight: TextWeight.medium)
              ],
            ),
          );
        } else {
          final story = stories[index - 1];
          final viewed = story.isViewed == true;
          return SizedBox(
              width: storyCircleSize + 20,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: viewed
                          ? null
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColorConstants.themeColor,
                                AppColorConstants.themeColor
                                    .withValues(alpha: 0.55),
                              ],
                            ),
                      color: viewed ? AppColorConstants.disabledColor : null,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColorConstants.backgroundColor),
                      child: ClipOval(
                        child: story.userImage != null
                            ? CachedNetworkImage(
                                imageUrl: story.userImage!,
                                fit: BoxFit.cover,
                                height: storyCircleSize - 9,
                                width: storyCircleSize - 9,
                                placeholder: (context, url) => SizedBox(
                                    height: 20,
                                    width: 20,
                                    child:
                                        const CircularProgressIndicator().p16),
                                errorWidget: (context, url, error) =>
                                    const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Icon(Icons.error)),
                              )
                            : SizedBox(
                                height: storyCircleSize - 9,
                                width: storyCircleSize - 9,
                                child: Center(
                                    child: BodyMediumText(
                                        story.userName.getInitials)),
                              ),
                      ),
                    ),
                  ).ripple(() {
                    viewStoryCallback(story);
                  }),
                  const SizedBox(
                    height: 6,
                  ),
                  Expanded(
                    child: BodySmallText(story.userName,
                            maxLines: 1,
                            weight: viewed
                                ? TextWeight.regular
                                : TextWeight.semiBold)
                        .hP4,
                  ),
                ],
              ));
        }
      },
    );
  }
}
