import 'dart:io';

import 'package:flutter/material.dart';

import 'chats_colors.dart';

// -------------------------------------------------------------
// صورة شخص (أو مجموعة) بدايرة: من السيرفر [url] أو من الجهاز [file] (صورتي من ملفي الشخصي)
// بدونها (أو لو ما تحمّلت) دايرة رمادية بأيقونة شخص — [size]: القطر بعد التحجيم
// -------------------------------------------------------------
class ChatAvatar extends StatelessWidget {
  final String? url;
  final String? file;
  final double size;
  final bool group;

  const ChatAvatar({super.key, this.url, this.file, required this.size, this.group = false});

  @override
  Widget build(BuildContext context) {
    final empty = ColoredBox(
      color: ChatsColors.avatarPlaceholder,
      child: Center(
        child: Icon(group ? Icons.groups_rounded : Icons.person_rounded, size: size * 0.62, color: Colors.white),
      ),
    );
    final cache = (size * MediaQuery.devicePixelRatioOf(context)).round();
    Widget? image;
    if (file != null) {
      image = Image(
        image: ResizeImage(FileImage(File(file!)), width: cache),
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => empty,
      );
    } else if (url != null) {
      image = Image.network(
        url!,
        fit: BoxFit.cover,
        cacheWidth: cache,
        gaplessPlayback: true,
        loadingBuilder: (_, child, progress) => progress == null ? child : empty,
        errorBuilder: (_, _, _) => empty,
      );
    }
    return SizedBox.square(
      dimension: size,
      child: ClipOval(child: image ?? empty),
    );
  }
}
