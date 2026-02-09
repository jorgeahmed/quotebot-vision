import 'package:equatable/equatable.dart';

enum MessageType { text, image, file }

class Message extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;

  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, senderId, senderName, content, timestamp, type, isRead];
}
