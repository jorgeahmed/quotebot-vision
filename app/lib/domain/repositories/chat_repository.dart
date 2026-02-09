import '../entities/message.dart';

abstract class ChatRepository {
  Stream<List<Message>> getMessages(String projectId);
  Future<void> sendMessage(String projectId, Message message);
}
