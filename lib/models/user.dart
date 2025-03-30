class UserModel {
  String? uid;
  String? name;
  String? email;
  String? phone;
  String? type; // 'provider' or 'searcher'
  String? profileImage;
  double? balance; // Provider balance in TND, nullable

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.phone,
    this.type,
    this.profileImage,
    this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      type: json['type'],
      profileImage: json['profileImage'],
      balance: json['balance'] != null
          ? json['balance'].toDouble()
          : 0.0, // Default to 0 if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'type': type,
      'profileImage': profileImage,
      'balance': balance ?? 0.0,
    };
  }
}
