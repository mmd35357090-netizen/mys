import 'package:foap/helper/imports/common_import.dart';

import '../model/highlights.dart';

class HighlightsBar extends StatelessWidget {
  final List<HighlightsModel> highlights;
  final VoidCallback? addHighlightCallback;
  final Function(HighlightsModel) viewHighlightCallback;

  const HighlightsBar(
      {super.key,
      required this.highlights,
      this.addHighlightCallback,
      required this.viewHighlightCallback})
      ;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85,
      child: ListView.separated(
          padding: EdgeInsets.only(
              left: DesignConstants.horizontalPadding,
              right: DesignConstants.horizontalPadding),
          scrollDirection: Axis.horizontal,
          itemCount: highlights.length + (addHighlightCallback != null ? 1 : 0),
          itemBuilder: (BuildContext ctx, int index) {
            if (index == 0 && addHighlightCallback != null) {
              return SizedBox(
                width: 70,
                child: Column(
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: ThemeIconWidget(
                        ThemeIcon.plusSymbol,
                        size: 25,
                        color: AppColorConstants.iconColor,
                      ),
                    ).borderWithRadius(value: 2, radius: 50),
                    const Spacer(),
                    BodySmallText(addString.tr, weight: TextWeight.medium),
                  ],
                ).ripple(() {
                  addHighlightCallback!();
                }),
              );
            } else {
              return SizedBox(
                width: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: AvatarView(
                        url: highlights[
                                index - (addHighlightCallback != null ? 1 : 0)]
                            .coverImage,
                      ).ripple(() {
                        viewHighlightCallback(highlights[
                            index - (addHighlightCallback != null ? 1 : 0)]);
                      }),
                    ),
                    const Spacer(),
                    BodySmallText(
                      highlights[index - (addHighlightCallback != null ? 1 : 0)]
                          .name,
                      weight: TextWeight.medium,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ).hP4
                  ],
                ),
              );
            }
          },
          separatorBuilder: (BuildContext ctx, int index) {
            return const SizedBox(width: 10);
          }),
    );
  }
}
