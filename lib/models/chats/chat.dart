class Chat {
  String displayName;
  String text;
  int timestamp;
  String uid;
  String messageId;
  bool read;

  Chat({
    required this.uid,
    required this.displayName,
    required this.text,
    required this.timestamp,
    required this.messageId,
    required this.read,
  });

  @override
  String toString() {
    return 'Chat{displayName: $displayName, text: $text, timestamp: $timestamp, uid: $uid, messageId: $messageId, read: $read}';
  }

  factory Chat.fromMap(Map<String, dynamic> data, String documentId) {
    return Chat(
      text: data.containsKey("text") ? data['text'] : '',
      displayName: data.containsKey("displayName") ? data['displayName'] : '',
      timestamp: data.containsKey("timestamp") ? data['timestamp'] : -1,
      uid: data.containsKey("uid") ? data['uid'] : "",
      messageId: documentId,
      read: data.containsKey("read") ? data['read'] : false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'displayName': displayName,
      'timestamp': timestamp,
      'uid': uid,
      'read': read,
    };
  }
}
