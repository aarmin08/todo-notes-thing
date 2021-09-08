class Note {
  final String id;
  String content;
  final String createdAt;
  String title;
  int gradientColorIndex;

  Note({
    required this.content,
    required this.createdAt,
    required this.id,
    required this.title,
    required this.gradientColorIndex,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json["id"],
        title: json["title"],
        createdAt: json["createdAt"],
        content: json["content"],
        gradientColorIndex: json["gradientColorIndex"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "createdAt": createdAt,
        "content": content,
        "gradientColorIndex": gradientColorIndex,
      };
}
