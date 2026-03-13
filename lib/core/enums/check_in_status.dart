enum CheckInStatus {
  checkedIn('checked_in'),
  completed('completed');

  const CheckInStatus(this.value);
  final String value;

  static CheckInStatus fromString(String value) {
    return CheckInStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CheckInStatus.checkedIn,
    );
  }
}

