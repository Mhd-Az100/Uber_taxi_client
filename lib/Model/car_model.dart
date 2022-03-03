class Car {
  Car({
    this.id,
    this.name,
    this.image,
    this.kmprice,
    this.minprice,
    this.fixedprice,
    this.profitvalue,
    this.profitunit,
    this.type,
    this.updatedAt,
    this.createdAt,
  });

  String? id;
  String? name;
  String? image;
  String? kmprice;
  String? minprice;
  String? fixedprice;
  String? profitvalue;
  String? profitunit;
  String? type;
  DateTime? updatedAt;
  DateTime? createdAt;

  factory Car.fromJson(Map<String, dynamic> json) => Car(
        id: json["_id"],
        name: json["name"],
        image: json['image'],
        kmprice: json["kmprice"],
        minprice: json["minprice"],
        fixedprice: json["fixedprice"],
        profitvalue: json["profitvalue"],
        profitunit: json["profitunit"],
        type: json["type"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "image": image,
        "kmprice": kmprice,
        "minprice": minprice,
        "fixedprice": fixedprice,
        "profitvalue": profitvalue,
        "profitunit": profitunit,
        "type": type,
        "updated_at": updatedAt!.toIso8601String(),
        "created_at": createdAt!.toIso8601String(),
      };
}
