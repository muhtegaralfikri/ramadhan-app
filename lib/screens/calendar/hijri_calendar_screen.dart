import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ramadan_app/constants/app_colors.dart';
import 'package:ramadan_app/services/hijri_service.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late HijriDate _currentHijriDate;
  late DateTime _selectedGregorianDate;
  late int _displayMonth;
  late int _displayYear;

  @override
  void initState() {
    super.initState();
    _selectedGregorianDate = DateTime.now();
    _currentHijriDate = HijriService.gregorianToHijri(_selectedGregorianDate);
    _displayMonth = _currentHijriDate.month;
    _displayYear = _currentHijriDate.year;
  }

  void _previousMonth() {
    setState(() {
      _displayMonth--;
      if (_displayMonth < 1) {
        _displayMonth = 12;
        _displayYear--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth++;
      if (_displayMonth > 12) {
        _displayMonth = 1;
        _displayYear++;
      }
    });
  }

  void _goToToday() {
    setState(() {
      _selectedGregorianDate = DateTime.now();
      _currentHijriDate = HijriService.gregorianToHijri(_selectedGregorianDate);
      _displayMonth = _currentHijriDate.month;
      _displayYear = _currentHijriDate.year;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTodayCard(),
                  const SizedBox(height: 24),
                  _buildMonthNavigation(),
                  const SizedBox(height: 16),
                  _buildCalendarGrid(),
                  const SizedBox(height: 24),
                  _buildUpcomingEvents(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF6A1B9A),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.white,
            ),
          ),
        ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Hero(
                      tag: 'hero_hijri_icon',
                      child: Icon(
                        Icons.calendar_month_rounded,
                        size: 40,
                        color: AppColors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 12),
                  Text(
                    'Kalender Hijriah',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Tahun ${_currentHijriDate.year} Hijriah',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayCard() {
    final todayHijri = HijriService.gregorianToHijri(DateTime.now());
    final events = HijriService.getEventsForDate(todayHijri);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Hari Ini',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${todayHijri.day}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${todayHijri.monthName} ${todayHijri.year} H',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${HijriService.dayNamesIndonesian[DateTime.now().weekday % 7]}, ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          if (events.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                events.first.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildMonthNavigation() {
    final monthName = HijriService.monthNamesIndonesian[_displayMonth - 1];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_left_rounded, color: Color(0xFF6A1B9A)),
          ),
        ),
        GestureDetector(
          onTap: _goToToday,
          child: Column(
            children: [
              Text(
                monthName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$_displayYear H',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6A1B9A)),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = HijriService.getDaysInHijriMonth(_displayYear, _displayMonth);
    final firstDayGregorian = HijriService.hijriToGregorian(_displayYear, _displayMonth, 1);
    final firstDayOfWeek = firstDayGregorian.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: HijriService.dayNamesIndonesian.map((day) {
              return SizedBox(
                width: 36,
                child: Text(
                  day.substring(0, 3),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: day == 'Jumat' ? const Color(0xFF6A1B9A) : AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Calendar days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: (daysInMonth + firstDayOfWeek),
            itemBuilder: (context, index) {
              if (index < firstDayOfWeek) {
                return const SizedBox();
              }
              
              final day = index - firstDayOfWeek + 1;
              final hijriDate = HijriDate(year: _displayYear, month: _displayMonth, day: day);
              final events = HijriService.getEventsForDate(hijriDate);
              final isToday = _currentHijriDate.year == _displayYear &&
                  _currentHijriDate.month == _displayMonth &&
                  _currentHijriDate.day == day;

              return GestureDetector(
                onTap: () {
                  if (events.isNotEmpty) {
                    _showEventDialog(hijriDate, events);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFF6A1B9A)
                        : events.isNotEmpty
                            ? const Color(0xFF6A1B9A).withValues(alpha: 0.1)
                            : null,
                    borderRadius: BorderRadius.circular(10),
                    border: events.isNotEmpty && !isToday
                        ? Border.all(color: const Color(0xFF6A1B9A).withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday || events.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                            color: isToday
                                ? Colors.white
                                : events.isNotEmpty
                                    ? const Color(0xFF6A1B9A)
                                    : AppColors.textPrimary,
                          ),
                        ),
                        if (events.isNotEmpty && !isToday)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF6A1B9A),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  void _showEventDialog(HijriDate date, List<IslamicEvent> events) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          HijriService.formatHijriDate(date),
          style: const TextStyle(fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: events.map((event) {
            return ListTile(
              leading: Icon(
                _getEventIcon(event.type),
                color: _getEventColor(event.type),
              ),
              title: Text(event.name),
              subtitle: Text(event.description),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.holiday:
        return Icons.celebration_rounded;
      case EventType.fastingDay:
        return Icons.restaurant_rounded;
      case EventType.specialNight:
        return Icons.nights_stay_rounded;
    }
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.holiday:
        return const Color(0xFF6A1B9A);
      case EventType.fastingDay:
        return const Color(0xFF2E7D32);
      case EventType.specialNight:
        return const Color(0xFF1565C0);
    }
  }

  Widget _buildUpcomingEvents() {
    final allEvents = HijriService.getIslamicEvents(_displayYear);
    final upcomingEvents = allEvents.where((e) {
      if (e.hijriMonth > _currentHijriDate.month) return true;
      if (e.hijriMonth == _currentHijriDate.month && e.hijriDay >= _currentHijriDate.day) return true;
      return false;
    }).take(5).toList();

    if (upcomingEvents.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event_rounded, color: Color(0xFF6A1B9A), size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hari Penting Mendatang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...upcomingEvents.map((event) => _buildEventCard(event)),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildEventCard(IslamicEvent event) {
    final monthName = HijriService.monthNamesIndonesian[event.hijriMonth - 1];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getEventColor(event.type).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getEventColor(event.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getEventIcon(event.type),
              color: _getEventColor(event.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${event.hijriDay} $monthName',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
