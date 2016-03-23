library rings;
import 'package:polymer/polymer.dart';

class Ring extends JsProxy{
  @reflectable List category;
  @reflectable final String SKU;
  @reflectable final String finish;
  @reflectable num price;
  @reflectable final String image;
  @reflectable int tier;
  @reflectable int id;
  @reflectable final String combo;
  @reflectable final String combo2;


  Ring(List this.category, String this.SKU, String this.finish, String _price, String this.image, String _tier, String _id, String this.combo, String this.combo2)
  {
    this.price = num.parse(_price);
    this.tier = int.parse(_tier);
    this.id = int.parse(_id);
  }

  Ring.fromMap(Map<String, Object> map) : this(map["category"], map["SKU"], map["finish"], map["price"], map["image"], map["tier"], map["id"], map["combo"], map["combo2"]);

  @override String toString() => "$SKU";

  @reflectable bool cleared = false;
  @reflectable String added = "Remove";
  @reflectable String icon = "clear";
  @reflectable String notes = "";
}


