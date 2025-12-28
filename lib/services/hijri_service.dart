/// Hijri (Islamic) Calendar Service
/// Uses the Umm al-Qura calendar algorithm
class HijriService {
  // Month names in Arabic and Indonesian
  static const List<String> monthNamesArabic = [
    'Muharram', 'Safar', 'Rabiul Awal', 'Rabiul Akhir',
    'Jumadil Awal', 'Jumadil Akhir', 'Rajab', 'Sya\'ban',
    'Ramadan', 'Syawal', 'Dzulqa\'dah', 'Dzulhijjah'
  ];

  static const List<String> monthNamesIndonesian = [
    'Muharram', 'Safar', 'Rabiul Awal', 'Rabiul Akhir',
    'Jumadil Awal', 'Jumadil Akhir', 'Rajab', 'Sya\'ban',
    'Ramadhan', 'Syawal', 'Dzulqa\'dah', 'Dzulhijjah'
  ];

  static const List<String> dayNamesIndonesian = [
    'Ahad', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];

  /// Convert Gregorian date to Hijri date
  static HijriDate gregorianToHijri(DateTime date) {
    // Julian Day Number
    int jd = _gregorianToJulian(date.year, date.month, date.day);
    return _julianToHijri(jd);
  }

  /// Convert Hijri date to Gregorian date
  static DateTime hijriToGregorian(int year, int month, int day) {
    int jd = _hijriToJulian(year, month, day);
    return _julianToGregorian(jd);
  }

  /// Get the number of days in a Hijri month
  static int getDaysInHijriMonth(int year, int month) {
    // Odd months have 30 days, even months have 29 days
    // The 12th month has 30 days in leap years
    if (month % 2 == 1) return 30;
    if (month == 12 && _isHijriLeapYear(year)) return 30;
    return 29;
  }

  /// Check if a Hijri year is a leap year
  static bool _isHijriLeapYear(int year) {
    return ((11 * year + 14) % 30) < 11;
  }

  /// Convert Gregorian to Julian Day Number
  static int _gregorianToJulian(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    int a = (year / 100).floor();
    int b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524;
  }

  /// Convert Julian Day Number to Hijri
  static HijriDate _julianToHijri(int jd) {
    int l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j = (((10985 - l) / 5316).floor()) * ((((50 * l) / 17719).floor())) +
        (((l / 5670).floor())) * ((((43 * l) / 15238).floor()));
    l = l - (((30 - j) / 15).floor()) * ((((17719 * j) / 50).floor())) -
        (((j / 16).floor())) * ((((15238 * j) / 43).floor())) + 29;
    int month = ((24 * l) / 709).floor();
    int day = l - ((709 * month) / 24).floor();
    int year = 30 * n + j - 30;
    
    return HijriDate(year: year, month: month, day: day);
  }

  /// Convert Hijri to Julian Day Number
  static int _hijriToJulian(int year, int month, int day) {
    return (((11 * year + 3) / 30).floor() +
        354 * year +
        30 * month -
        ((month - 1) / 2).floor() +
        day +
        1948440 -
        385);
  }

  /// Convert Julian Day Number to Gregorian
  static DateTime _julianToGregorian(int jd) {
    int l = jd + 68569;
    int n = ((4 * l) / 146097).floor();
    l = l - ((146097 * n + 3) / 4).floor();
    int i = ((4000 * (l + 1)) / 1461001).floor();
    l = l - ((1461 * i) / 4).floor() + 31;
    int j = ((80 * l) / 2447).floor();
    int day = l - ((2447 * j) / 80).floor();
    l = (j / 11).floor();
    int month = j + 2 - 12 * l;
    int year = 100 * (n - 49) + i + l;
    
    return DateTime(year, month, day);
  }

  /// Get important Islamic dates for a Hijri year
  static List<IslamicEvent> getIslamicEvents(int hijriYear) {
    return [
      // Muharram
      IslamicEvent(
        hijriMonth: 1, hijriDay: 1,
        name: 'Tahun Baru Hijriah',
        description: 'Awal tahun baru Islam $hijriYear H',
        type: EventType.holiday,
      ),
      IslamicEvent(
        hijriMonth: 1, hijriDay: 10,
        name: 'Asyura',
        description: 'Hari Asyura - Puasa sunah',
        type: EventType.fastingDay,
      ),
      // Rabiul Awal
      IslamicEvent(
        hijriMonth: 3, hijriDay: 12,
        name: 'Maulid Nabi',
        description: 'Peringatan kelahiran Nabi Muhammad SAW',
        type: EventType.holiday,
      ),
      // Rajab
      IslamicEvent(
        hijriMonth: 7, hijriDay: 27,
        name: 'Isra Mi\'raj',
        description: 'Peringatan Isra Mi\'raj Nabi Muhammad SAW',
        type: EventType.holiday,
      ),
      // Sya'ban
      IslamicEvent(
        hijriMonth: 8, hijriDay: 15,
        name: 'Nisfu Sya\'ban',
        description: 'Malam Nisfu Sya\'ban',
        type: EventType.specialNight,
      ),
      // Ramadan
      IslamicEvent(
        hijriMonth: 9, hijriDay: 1,
        name: 'Awal Ramadan',
        description: 'Hari pertama puasa Ramadan',
        type: EventType.holiday,
      ),
      IslamicEvent(
        hijriMonth: 9, hijriDay: 17,
        name: 'Nuzulul Quran',
        description: 'Peringatan turunnya Al-Quran',
        type: EventType.specialNight,
      ),
      IslamicEvent(
        hijriMonth: 9, hijriDay: 21,
        name: 'Lailatul Qadr (malam ganjil)',
        description: 'Malam kemuliaan - malam ganjil terakhir',
        type: EventType.specialNight,
      ),
      IslamicEvent(
        hijriMonth: 9, hijriDay: 27,
        name: 'Lailatul Qadr',
        description: 'Malam Lailatul Qadr',
        type: EventType.specialNight,
      ),
      // Syawal
      IslamicEvent(
        hijriMonth: 10, hijriDay: 1,
        name: 'Idul Fitri',
        description: 'Hari Raya Idul Fitri 1 $hijriYear H',
        type: EventType.holiday,
      ),
      IslamicEvent(
        hijriMonth: 10, hijriDay: 2,
        name: 'Idul Fitri',
        description: 'Hari Raya Idul Fitri 2 $hijriYear H',
        type: EventType.holiday,
      ),
      // Dzulhijjah
      IslamicEvent(
        hijriMonth: 12, hijriDay: 9,
        name: 'Wukuf di Arafah',
        description: 'Hari wukuf di Arafah - Puasa Arafah',
        type: EventType.fastingDay,
      ),
      IslamicEvent(
        hijriMonth: 12, hijriDay: 10,
        name: 'Idul Adha',
        description: 'Hari Raya Idul Adha $hijriYear H',
        type: EventType.holiday,
      ),
      IslamicEvent(
        hijriMonth: 12, hijriDay: 11,
        name: 'Hari Tasyrik',
        description: 'Hari Tasyrik 1',
        type: EventType.holiday,
      ),
      IslamicEvent(
        hijriMonth: 12, hijriDay: 12,
        name: 'Hari Tasyrik',
        description: 'Hari Tasyrik 2',
        type: EventType.holiday,
      ),
      IslamicEvent(
        hijriMonth: 12, hijriDay: 13,
        name: 'Hari Tasyrik',
        description: 'Hari Tasyrik 3',
        type: EventType.holiday,
      ),
    ];
  }

  /// Get events for a specific Hijri date
  static List<IslamicEvent> getEventsForDate(HijriDate date) {
    final allEvents = getIslamicEvents(date.year);
    return allEvents.where((e) => e.hijriMonth == date.month && e.hijriDay == date.day).toList();
  }

  /// Format Hijri date to string
  static String formatHijriDate(HijriDate date, {bool includeYear = true}) {
    final monthName = monthNamesIndonesian[date.month - 1];
    if (includeYear) {
      return '${date.day} $monthName ${date.year} H';
    }
    return '${date.day} $monthName';
  }
}

/// Hijri Date Model
class HijriDate {
  final int year;
  final int month;
  final int day;

  HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  String get monthName => HijriService.monthNamesIndonesian[month - 1];
  
  @override
  String toString() => HijriService.formatHijriDate(this);
}

/// Islamic Event Model
class IslamicEvent {
  final int hijriMonth;
  final int hijriDay;
  final String name;
  final String description;
  final EventType type;

  IslamicEvent({
    required this.hijriMonth,
    required this.hijriDay,
    required this.name,
    required this.description,
    required this.type,
  });
}

enum EventType {
  holiday,
  fastingDay,
  specialNight,
}
