class Provider {

  int? id ;
  String ?name;
  String ?companyName;

  Provider({
    required this.id,
    required this.name,
    required this.companyName

});


  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'],
      name: json['name'],
      companyName: json['company_name']
    );

  }

}