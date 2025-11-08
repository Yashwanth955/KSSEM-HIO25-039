import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// NEW: Import the Isar service and TestResult model
import 'isar_service.dart';

class StreaksScreen extends StatefulWidget {
  const StreaksScreen({super.key});

  @override
  State<StreaksScreen> createState() => _StreaksScreenState();
}

class _StreaksScreenState extends State<StreaksScreen> {
  // --- UPDATED: State Variables ---
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // NEW: A Future to hold the events loaded from the database
  late final Future<Map<DateTime, List<String>>> _eventsFuture;
  final isarService = IsarService(); // Changed from HiveService

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // NEW: Load the events from Isar when the screen is first initialized
    _eventsFuture = _loadEventsFromDb();
  }

  // NEW: Method to fetch results from Isar and format them for the calendar
  Future<Map<DateTime, List<String>>> _loadEventsFromDb() async {
    final allResults = await isarService
        .getAllTestResults(); // Changed from hiveService
    final Map<DateTime, List<String>> events = {};

    for (final result in allResults) {
      // Use UTC to ignore time zones and only compare the date part
      final date = DateTime.utc(
        result.date.year,
        result.date.month,
        result.date.day,
      );
      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(result.testTitle);
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Consistency & Streaks',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      // NEW: Wrap the body in a FutureBuilder
      body: FutureBuilder<Map<DateTime, List<String>>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data.'));
          }

          final events = snapshot.data ?? {};

          List<String> getEventsForDay(DateTime day) {
            return events[DateTime.utc(day.year, day.month, day.day)] ?? [];
          }

          final selectedDayEvents = getEventsForDay(_selectedDay!);

          // The main UI is built here once the data is ready
          return Column(
            children: [
              _buildStreakCounter(),
              TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2026, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: getEventsForDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: _buildCalendarStyle(),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Tests on ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    Expanded(
                      child: selectedDayEvents.isEmpty
                          ? const Center(
                              child: Text('No tests were taken on this day.'),
                            )
                          : ListView.builder(
                              itemCount: selectedDayEvents.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const Icon(
                                    Icons.assignment_turned_in,
                                    color: Color(0xFF20D36A),
                                  ),
                                  title: Text(selectedDayEvents[index]),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStreakCounter() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light green background
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_fire_department, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            'Current Streak: 3 Days!', // This can also be calculated from the data later
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  CalendarStyle _buildCalendarStyle() {
    const primaryGreen = Color(0xFF20D36A);
    return CalendarStyle(
      markerDecoration: const BoxDecoration(
        color: primaryGreen,
        shape: BoxShape.circle,
      ),
      selectedDecoration: BoxDecoration(
        color: primaryGreen.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      todayDecoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}
