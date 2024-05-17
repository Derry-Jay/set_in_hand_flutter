import 'reply.dart';
import '../helpers/helper.dart';

class Quantities {
  final Reply base;
  final bool completed;
  final int remaining, expected, location, box;
  Quantities(this.base, this.completed, this.remaining, this.expected,
      this.location, this.box);

  static Quantities emptyQuantity =
      Quantities(Reply.emptyReply, false, 0, 0, 0, 0);

  factory Quantities.fromMap(Map<String, dynamic> map) {
    try {
      return Quantities(
          Reply.fromMap(map),
          parseBool(map['pull_list_completed']?.toString() ?? '-1') &&
              (map['success'] ?? false),
          map['remaining_qty'] ?? 0,
          map['expected_qty'] ?? 0,
          map['location_qty'] ?? 0,
          map['individual_box'] ?? 0);
    } catch (e) {
      sendAppLog(e);

      return Quantities.emptyQuantity;
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'Is Complete: $completed, Remaining: $remaining, Expected: $expected, Location: $location, Per Box: $box, Success: ${base.success}, Message: ${base.message}';
  }
}
