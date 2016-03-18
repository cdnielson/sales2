library swatches;

class Swatch {
  final String name;
  final String url;
  final String type;

  Swatch(String this.name, String this.url, String this.type);

  Swatch.fromMap(Map<String, Object> map) : this(map["name"], map["url"], map['type']);

  @override String toString() => "$name";

  bool added = false;
}


