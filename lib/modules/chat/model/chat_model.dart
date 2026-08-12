import 'package:flutter/material.dart';

enum ChatTab { departments, direct }
enum SidePanelTab { members, files }

class ChatMember {
  final String id;
  final String name;
  final String role;
  final String department;
  final String? avatarUrl;
  final bool isAdmin;
  final bool isOnline;

  ChatMember({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    this.avatarUrl,
    this.isAdmin = false,
    this.isOnline = true,
  });
}

class ChatFile {
  final String id;
  final String fileName;
  final String uploaderName;
  final String? uploadDate;
  final String? fileSize;

  ChatFile({
    required this.id,
    required this.fileName,
    required this.uploaderName,
    this.uploadDate,
    this.fileSize,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String text;
  final String timestamp;
  final bool isMe;
  final bool isAi;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.text,
    required this.timestamp,
    this.isMe = false,
    this.isAi = false,
  });
}

class ChatChannel {
  final String id;
  final String name;
  final ChatTab type;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final int unreadCount;
  final String subtitle;
  final String description;
  final bool isMuted;
  final List<ChatMember> members;
  final List<ChatFile> files;
  final List<ChatMessage> messages;

  ChatChannel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.unreadCount = 0,
    required this.subtitle,
    required this.description,
    this.isMuted = false,
    required this.members,
    required this.files,
    required this.messages,
  });

  ChatChannel copyWith({
    String? id,
    String? name,
    ChatTab? type,
    IconData? icon,
    Color? iconColor,
    Color? iconBgColor,
    int? unreadCount,
    String? subtitle,
    String? description,
    bool? isMuted,
    List<ChatMember>? members,
    List<ChatFile>? files,
    List<ChatMessage>? messages,
  }) {
    return ChatChannel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBgColor: iconBgColor ?? this.iconBgColor,
      unreadCount: unreadCount ?? this.unreadCount,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      isMuted: isMuted ?? this.isMuted,
      members: members ?? this.members,
      files: files ?? this.files,
      messages: messages ?? this.messages,
    );
  }
}
