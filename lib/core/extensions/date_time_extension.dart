import 'package:intl/intl.dart';

extension DateFormatting on DateTime {
  String get yyyymmdd => DateFormat('yyyy-MM-dd').format(this);
}
