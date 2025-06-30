class Message {
  int ?id;
  String ?title;
  String ?body;
  String ?status;
Message({
    required this.id,
  required this.title,
  required this.body,
  required this.status,
});
factory Message.fromJson(Map<String, dynamic> json) => Message(
  id: json['id'],
  title: json['title'],
  body: json['body'],
  status: json['status'],
);


}