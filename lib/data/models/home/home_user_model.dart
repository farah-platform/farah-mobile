class HomeUserModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String location;
  final String city;
  final int unreadNotificationsCount;

  HomeUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.location,
    required this.city,
    required this.unreadNotificationsCount,
  });

  factory HomeUserModel.fromJson(Map<String, dynamic> json) {
    return HomeUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      unreadNotificationsCount: json['unread_notifications_count'] ?? 0,
    );
  }
}
