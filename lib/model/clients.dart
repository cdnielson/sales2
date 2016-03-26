library clients;

class Client {
  final String client_idx;
  String store_name;
  String last_name;
  String first_name;
  String address;
  String city;
  String state;
  String zip;
  String country;
  String phone;
  String fax;
  String email;

  Client(String this.client_idx,
      String this.store_name,
      String this.last_name,
      String this.first_name,
      String this.address,
      String this.city,
      String this.state,
      String this.zip,
      String this.country,
      String this.phone,
      String this.fax,
      String this.email);

  Client.fromMap(Map<String, Object> map) : this(
      map["client_idx"],
      map["store_name"],
      map["last_name"],
      map["first_name"],
      map["address"],
      map["city"],
      map["state"],
      map["zip"],
      map["country"],
      map["phone"],
      map["fax"],
      map["email"]);

  @override String toString() => "$store_name";
  bool selected = false;
}


