class CategoryModel {
  final int? id;
  final String? name;
  final String? icon;
  final bool? isFav;

  CategoryModel({this.id,this.name,this.icon,this.isFav});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id:json['id'],
      name: json['name'],
      icon: json['icon'],
      isFav:json['isFav']
    );
  }
}
