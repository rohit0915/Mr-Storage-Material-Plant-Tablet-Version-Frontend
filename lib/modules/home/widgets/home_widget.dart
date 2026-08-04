import 'package:flutter/material.dart';
import '../model/home_model.dart';

class HomeWidget extends StatelessWidget {
  final HomeModel model;

  const HomeWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(model.title),
        subtitle: Text(model.description),
        leading: const CircleAvatar(
          child: Icon(Icons.home),
        ),
      ),
    );
  }
}
