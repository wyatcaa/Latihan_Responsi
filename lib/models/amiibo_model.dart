class AmiiboRelease {
  final String? au;
  final String? eu;
  final String? jp;
  final String? na;

  AmiiboRelease({
    this.au,
    this.eu,
    this.jp,
    this.na,
  });

  factory AmiiboRelease.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AmiiboRelease(au: "-", eu: "-", jp: "-", na: "-");
    }

    return AmiiboRelease(
      au: json['au']?.toString(),
      eu: json['eu']?.toString(),
      jp: json['jp']?.toString(),
      na: json['na']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "au": au,
      "eu": eu,
      "jp": jp,
      "na": na,
    };
  }
}

class AmiiboModel {
  final String head;
  final String tail;
  final String name;
  final String image;
  final String gameSeries;
  final String type;
  final String character;
  final String amiiboSeries;
  final AmiiboRelease release;

  AmiiboModel({
    required this.head,
    required this.tail,
    required this.name,
    required this.image,
    required this.gameSeries,
    required this.type,
    required this.character,
    required this.amiiboSeries,
    required this.release,
  });

  factory AmiiboModel.fromJson(Map<String, dynamic> json) {
    return AmiiboModel(
      head: json['head']?.toString() ?? "",
      tail: json['tail']?.toString() ?? "",
      name: json['name']?.toString() ?? "",
      image: json['image']?.toString() ?? "",
      gameSeries: json['gameSeries']?.toString() ?? "",
      type: json['type']?.toString() ?? "",
      character: json['character']?.toString() ?? "",
      amiiboSeries: json['amiiboSeries']?.toString() ?? "",
      release: AmiiboRelease.fromJson(json['release']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "head": head,
      "tail": tail,
      "name": name,
      "image": image,
      "gameSeries": gameSeries,
      "type": type,
      "character": character,
      "amiiboSeries": amiiboSeries,
      "release": release.toJson(),
    };
  }
}
