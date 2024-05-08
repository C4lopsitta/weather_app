import 'package:intl/intl.dart';

class GraphUtilities {
  static (int, int) getRangeSize(DateTime start, DateTime end) {
    //TODO)) Fix this (always return total days)
    if(start.isAfter(end)) return (0, 0);

    int days = _getDaysInRange(start, end);
    if(days < 20) return (days, 0);

    int months = _getMonthsInRange(start, end);
    if(months < 20) return (months, 1);

    return (_getYearsInRange(start, end), 2);
  }

  static String getHorizontalLabel(DateTime start, DateTime end, int type, double offset) {
    if(type == 0) { // day range
      if(end.month == start.month) return "${start.day + offset.round()}";
      else {
        DateTime showedDate = start.add(Duration(days: offset.round()));
        DateFormat formatter = DateFormat.Md();
        if(start.year != end.year) formatter = DateFormat.yMd();
        return formatter.format(showedDate);
      }
    }
    if(type == 1) { // month range
      DateTime showedDate = start.add(Duration(days: (29.8 * offset).round()));
      DateFormat formatter = DateFormat.Md();
      if(start.year != end.year) formatter = DateFormat.yMd();
      return formatter.format(showedDate);
    }
    if(type == 2) {
      DateFormat formatter = DateFormat.yM();
      DateTime showedDate = start.add(Duration(days: (365 * offset).round()));
      return formatter.format(showedDate);
    }
    return "";
  }

  static int getXGap(DateTime start, DateTime end) {
    int range = getRangeSize(start, end).$1;

    if(range < 24) return 1;
    if(range < 180) return 10;
    return 100;
  }

  static int _getDaysInRange(DateTime start, DateTime end) {
    Duration duration = end.difference(start);
    return duration.inDays;
  }

  static int _getMonthsInRange(DateTime start, DateTime end) {
    int startYear = start.year;
    int endYear = end.year;
    int startMonth = start.month;
    int endMonth = end.month;

    int totalMonths = 0;

    for(int year = startYear; year <= endYear; year++) {
      for(int i = (year == startYear) ? startMonth : 1; i <= ((year == endYear) ? endMonth : 12); i++) {
        totalMonths++;
      }
    }

    return totalMonths;
  }

  static int _getYearsInRange(DateTime start, DateTime end) {
    int startYear = start.year;
    int endYear = end.year;

    return endYear - startYear;
  }
}