class SayHiAppAccount {
  final String username;
  final String userId;
  String? authToken;
  String? picture;
  bool isLoggedIn;

  SayHiAppAccount({
    required this.username,
    required this.userId,
    this.authToken,
    this.picture,
    this.isLoggedIn = false,
  });

  // Convert Account object to a Map for saving in SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'userId': userId,
      'authToken': authToken,
      'isLoggedIn': isLoggedIn,
      'picture': picture,
    };
  }

  // Create an Account object from a Map
  factory SayHiAppAccount.fromMap(Map<String, dynamic> map) {
    return SayHiAppAccount(
      username: map['username'],
      userId: map['userId'],
      authToken: map['authToken'],
      picture: map['picture'],
      isLoggedIn: map['isLoggedIn'] ?? false,
    );
  }
}
