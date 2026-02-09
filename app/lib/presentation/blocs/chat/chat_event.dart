import 'package:equatable/equatable.dart';
import 'package:quotebot_vision/domain/entities/message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class LoadMessages extends ChatEvent {
  final String projectId;
  const LoadMessages(this.projectId);

  @override
  List<Object> get props => [projectId];
}

class SendMessage extends ChatEvent {
  final String projectId;
  final String content;
  final String senderId;
  final String senderName;
  final MessageType type;

  const SendMessage({
    required this.projectId,
    required this.content,
    required this.senderId,
    required this.senderName,
    this.type = MessageType.text,
  });

  @override
  List<Object> get props => [projectId, content, senderId, senderName, type];
}

class UpdateMessages extends ChatEvent {
  final List<Message> messages;
  const UpdateMessages(this.messages);

  @override
  List<Object> get props => [messages];
}
