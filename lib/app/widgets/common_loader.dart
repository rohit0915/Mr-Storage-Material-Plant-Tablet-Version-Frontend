import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const CommonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 120,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
