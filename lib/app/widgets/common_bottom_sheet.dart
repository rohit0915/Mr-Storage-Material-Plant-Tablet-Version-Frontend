import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonBottomSheet {
  CommonBottomSheet._();

  static void show({required Widget child}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: child,
      ),
      isScrollControlled: true,
    );
  }
}
