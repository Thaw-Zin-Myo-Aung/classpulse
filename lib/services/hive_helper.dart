import 'package:classpulse/models/check_in_record.dart';
import 'package:hive/hive.dart';

class HiveHelper {
  static const String boxName = 'checkins';

  final Box<Map> _box;

  HiveHelper._(this._box);

  factory HiveHelper.instance() {
    final box = Hive.box<Map>(boxName);
    return HiveHelper._(box);
  }

  Future<void> saveRecord(CheckInRecord record) async {
    await _box.put(record.id, record.toJson());
  }

  Future<void> updateRecord(CheckInRecord record) async {
    await _box.put(record.id, record.toJson());
  }

  List<CheckInRecord> getAllRecords() {
    final items = _box.values
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .map(CheckInRecord.fromJson)
        .toList();

    items.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    return items;
  }
}
