class UserModel {
  String? uid;
  String? name;
  String? email;
  String? phone;
  String? type; // 'provider' or 'searcher'
  String? profileImage;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.phone,
    this.type,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      type: json['type'],
      profileImage: json['profileImage'],
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
    };
  }
}
