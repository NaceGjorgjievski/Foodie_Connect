class Comment {
  final String id;
  final String content;
  final String restaurantId;
  final String username;
  final DateTime timestamp;
  final String image;

  Comment({
    required this.id,
    required this.content,
    required this.restaurantId,
    required this.username,
    required this.timestamp,
    required this.image,
  });
}