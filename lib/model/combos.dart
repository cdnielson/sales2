library combos;

class Combo {
  final String sku;
  final String finish;
  final String combo;

  Combo(String this.sku, String this.finish, String this.combo);

  Combo.fromMap(Map<String, Object> map) : this(map["sku"], map["finish"], map["combo"]);

}
