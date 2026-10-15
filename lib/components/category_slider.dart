import '../helper/imports/common_import.dart';
import '../model/category_model.dart';
import '../util/constant_util.dart';

class CategorySlider extends StatefulWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel?) onSelection;

  const CategorySlider(
      {super.key, required this.categories, required this.onSelection})
      ;

  @override
  State<CategorySlider> createState() => _CategorySliderState();
}

class _CategorySliderState extends State<CategorySlider> {
  CategoryModel? selectCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: widget.categories.length,
          padding: EdgeInsets.only(left: DesignConstants.horizontalPadding),
          itemBuilder: (context, index) {
            return ChoiceChip(
              selectedColor: AppColorConstants.themeColor.darken(),
              backgroundColor: isDarkMode
                  ? AppColorConstants.cardColor.lighten()
                  : AppColorConstants.cardColor.darken(),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
              label: BodyMediumText(
                widget.categories[index].name,
                color: widget.categories[index] == selectCategory
                    ? Colors.white
                    : AppColorConstants.mainTextColor,
              ),
              selected: widget.categories[index] == selectCategory,
              onSelected: (status) {
                setState(() {
                  if (status == true) {
                    selectCategory = widget.categories[index];
                    widget.onSelection(selectCategory);
                  } else {
                    selectCategory = null;
                    widget.onSelection(null);
                  }
                });
              },
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(
              width: 10,
            );
          }),
    );
  }
}
