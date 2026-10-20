import 'package:equatable/equatable.dart';

import '../../../../core/utils/geo_utils.dart';

enum ChatMessageStatus { sending, sent, failed }

// -------------------------------------------------------------
// رسالة بمحادثة (مع المشرف، مع فرد، أو مجموعة): نص أو موقع (أو الاتنين)
// [clientId]: رقم بيولّده التطبيق قبل الإرسال — بيربط الرسالة المؤقتة بنسختها من السيرفر (وما بتتكرر)
// [id]: رقم السيرفر (أو clientId لحد ما توصل)
// [senderName]/[senderPhotoUrl]: صاحب الرسالة (صورته بتطلع جنب الفقاعة — بالمجموعة كل واحد صورته)
// -------------------------------------------------------------
class ChatMessage extends Equatable {
  final String id;
  final String clientId;
  final String? conversationId;
  final bool fromMe;
  final String? senderName;
  final String? senderPhotoUrl;
  final String? text;
  final GeoPoint? location;
  final DateTime sentAt;
  final ChatMessageStatus status;

  const ChatMessage({
    required this.id,
    required this.clientId,
    required this.fromMe,
    required this.sentAt,
    this.conversationId,
    this.senderName,
    this.senderPhotoUrl,
    this.text,
    this.location,
    this.status = ChatMessageStatus.sent,
  });

  bool get isLocation => location != null;

  ChatMessage copyWith({String? id, ChatMessageStatus? status, DateTime? sentAt}) => ChatMessage(
    id: id ?? this.id,
    clientId: clientId,
    conversationId: conversationId,
    fromMe: fromMe,
    senderName: senderName,
    senderPhotoUrl: senderPhotoUrl,
    text: text,
    location: location,
    sentAt: sentAt ?? this.sentAt,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [id, clientId, conversationId, fromMe, senderName, senderPhotoUrl, text, location?.latitude, location?.longitude, sentAt, status];
}
