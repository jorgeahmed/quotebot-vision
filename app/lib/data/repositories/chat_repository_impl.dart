import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Message>> getMessages(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<void> sendMessage(String projectId, Message message) async {
    // We convert to model to get the JSON map
    // MessageModel.fromEntity or just construct it
    // Since Message is immutable base class, we cast it or creating model from it

    final messageModel = MessageModel(
      id: message
          .id, // ID is usually empty for new messages, but we set it or ignore it on add
      senderId: message.senderId,
      senderName: message.senderName,
      content: message.content,
      timestamp: message.timestamp,
      type: message.type,
      isRead: message.isRead,
    );

    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('messages')
        .add(messageModel.toJson());
  }
}
