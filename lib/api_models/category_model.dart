class CategoryModel {
  final int? id;
  final String? name;
  final String? icon;

  CategoryModel({this.id,this.name, this.icon});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id:json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}
