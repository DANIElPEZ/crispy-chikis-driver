bool sanitizePhone(String phone) {
  phone=phone.trim();
  final RegExp regex = RegExp(r'^\+\d{1,3}\s\d{10}$');
  return regex.hasMatch(phone);
}

bool sanitizeOrderId(String id) {
  id=id.trim();
  final RegExp regex = RegExp(r'^\d{1,9}$');
  return regex.hasMatch(id);
}
