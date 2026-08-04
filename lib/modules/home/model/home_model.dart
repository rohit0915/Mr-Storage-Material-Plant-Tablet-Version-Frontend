class HomeModel {
  final String title;
  final String description;

  HomeModel({required this.title, required this.description});

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
