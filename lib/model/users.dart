library users;

class User {
  final String username;
  final String pin;
  final String email;

  User(String this.username, String this.pin, String this.email);

  User.fromMap(Map<String, Object> map) : this(map["username"], map["pin"], map["email"]);

  @override String toString() => "$username";

}


