class Userdetials {
  String? name;
  String? email;
  String? profileImage;
  String? phonenumber;
  String? password;
  String? status;

  Userdetials(
      {this.name,
      this.email,
      this.profileImage,
      this.phonenumber,
      this.password,
      this.status});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'phonenumber': phonenumber,
      'password': password,
      'status': status,
    };
  }

  factory Userdetials.fromJson(Map<String, dynamic> json) {
    return Userdetials(
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      phonenumber: json['phonenumber'],
      password: json['password'],
      status: json['status'],
    );
  }
}
