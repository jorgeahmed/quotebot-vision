import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/project.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../widgets/message_bubble_widget.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_state.dart';

class ChatPage extends StatelessWidget {
  final Project project;

  const ChatPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatBloc(ChatRepositoryImpl())..add(LoadMessages(project.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(project.name),
          backgroundColor: const Color(0xFF6200EE),
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is ChatLoaded) {
                    final messages = state.messages;
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay mensajes aún.\n¡Inicia la conversación!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      );
                    }
                    return ListView.builder(
                      reverse: true, // Start from bottom
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        // Get current user ID from ProfileBloc
                        final profileState = context.read<ProfileBloc>().state;
                        String currentUserId = '';
                        if (profileState is ProfileLoaded) {
                          currentUserId = profileState.profile.userId;
                        }

                        final isMe = message.senderId == currentUserId;
                        return MessageBubbleWidget(
                            message: message, isMe: isMe);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            _MessageInputArea(projectId: project.id),
          ],
        ),
      ),
    );
  }
}

class _MessageInputArea extends StatefulWidget {
  final String projectId;

  const _MessageInputArea({required this.projectId});

  @override
  State<_MessageInputArea> createState() => _MessageInputAreaState();
}

class _MessageInputAreaState extends State<_MessageInputArea> {
  final _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final profileState = context.read<ProfileBloc>().state;
    String senderId = 'unknown-user-id';
    String senderName = 'Usuario';

    if (profileState is ProfileLoaded) {
      senderId = profileState.profile.userId;
      senderName = profileState.profile.name;
    }

    context.read<ChatBloc>().add(SendMessage(
          projectId: widget.projectId,
          content: text,
          senderId: senderId,
          senderName: senderName,
        ));

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: () {
                // Future: Implement image upload
              },
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF6200EE)),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
