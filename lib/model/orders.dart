library orders;

class Order {
  final String id;
  final String name;

  Order(String this.id, String this.name);

  Order.fromMap(Map<String, Object> map) : this(map["name"], map["id"]);

  @override String toString() => "$name";

}


