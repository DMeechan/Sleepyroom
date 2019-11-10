DateTime fromEpoch(int epoch) {
  return new DateTime.fromMillisecondsSinceEpoch(epoch);
}

int toEpoch(DateTime dateTime) {
  return dateTime != null ? dateTime.millisecondsSinceEpoch : null;
}
