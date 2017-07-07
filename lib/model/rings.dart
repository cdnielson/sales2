library rings;

class Ring {
  List category;
  final String SKU;
  final String finish;
  num price;
  final String image;
  int tier;
  int id;
  final String combo;
  final String combo2;
  final String combo3;
  final String combo4;
  final String combo5;
  final String combo6;

  Ring(
      List this.category,
      String this.SKU,
      String this.finish,
      String _price,
      String this.image,
      String _tier,
      String _id,
      String this.combo,
      String this.combo2,
      String this.combo3,
      String this.combo4,
      String this.combo5,
      String this.combo6)
  {
    this.price = num.parse(_price);
    this.tier = int.parse(_tier);
    this.id = int.parse(_id);
  }

  Ring.fromMap(Map<String, Object> map) : this(
      map["category"],
      map["SKU"],
      map["finish"],
      map["price"],
      map["image"],
      map["tier"],
      map["id"],
      map["combo"],
      map["combo2"],
      map["combo3"],
      map["combo4"],
      map["combo5"],
      map["combo6"]);

  @override String toString() => "$SKU";

  String added = "none";
  String notes = "";
}


