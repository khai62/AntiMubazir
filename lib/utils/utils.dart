String getChatId(String userId1, String userId2) {
  if (userId1.hashCode <= userId2.hashCode) {
    return '$userId1-$userId2';
  } else {
    return '$userId2-$userId1';
  }
}
