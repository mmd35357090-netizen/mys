import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foap/components/custom_texts.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/model/shop_model/category.dart';

//ignore: must_be_immutable
class CategoryCard extends StatelessWidget {
  ShopCategoryModel category;
  VoidCallback? callback;

  CategoryCard({super.key, required this.category, required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => callback!(),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: category.picture!,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: BodyLargeText(
                category.name,
                weight: TextWeight.semiBold,
                textAlign: TextAlign.center,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ).round(5).p4,
    );
  }
}

class CategoryCardForPost extends StatelessWidget {
  final ShopCategoryModel category;
  final VoidCallback? callback;

  const CategoryCardForPost(
      {super.key, required this.category, required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => callback!(),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: category.picture!,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Heading6Text(
                category.name,
                weight: TextWeight.semiBold,
                textAlign: TextAlign.center,
                maxLines: 2,
                color: Colors.white,
              ).hP4,
            ),
          )
        ],
      ),
    );
  }
}
