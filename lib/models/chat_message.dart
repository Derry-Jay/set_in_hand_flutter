class ChatMessage {
  int? messageId, userId, toUserId, status;
  String? message, readStatus, datetime, username, profilepicture;

  ChatMessage(
      this.messageId,
      this.userId,
      this.toUserId,
      this.message,
      this.status,
      this.readStatus,
      this.datetime,
      this.username,
      this.profilepicture);

  factory ChatMessage.fromMap(Map<String, dynamic> json) {
    return ChatMessage(
        json['messageId'] ?? 0,
        json['userId'] ?? 0,
        json['toUserId'] ?? 0,
        json['message'] ?? '',
        json['status'] ?? 0,
        json['readStatus'] ?? '',
        json['datetime'] ?? '',
        json['username'] ?? '',
        json['profilepicture'] ?? '');
  }
}