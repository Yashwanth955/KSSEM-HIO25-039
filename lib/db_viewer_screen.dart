// lib/db_viewer_screen.dart
// Simple database viewer for test results.

import 'package:flutter/material.dart';
import 'isar_service.dart';
import 'test_result.dart';

class DbViewerScreen extends StatefulWidget {
  const DbViewerScreen({super.key});

  @override
  State<DbViewerScreen> createState() => _DbViewerScreenState();
}

class _DbViewerScreenState extends State<DbViewerScreen> {
  final _isar = IsarService();
  late Future<List<TestResult>> _futureResults;
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _futureResults = _isar.getAllTestResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DB: Test Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Reload',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Filter by test title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) =>
                  setState(() => _filter = val.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TestResult>>(
              future: _futureResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final results = snapshot.data ?? [];
                final filtered = _filter.isEmpty
                    ? results
                    : results
                          .where(
                            (r) => r.testTitle.toLowerCase().contains(_filter),
                          )
                          .toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('No results'));
                }
                filtered.sort((a, b) => b.date.compareTo(a.date));
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, i) {
                    final r = filtered[i];
                    return ListTile(
                      title: Text(r.testTitle),
                      subtitle: Text(
                        '${r.resultValue}  •  ${_formatDate(r.date)}',
                      ),
                      trailing: _buildTrendIcon(r, filtered, i),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  // Show simple trend icon relative to previous entry for same test
  Widget? _buildTrendIcon(TestResult current, List<TestResult> all, int index) {
    // Find previous same-test result (in already date-desc list after sort)
    for (var j = index + 1; j < all.length; j++) {
      final prev = all[j];
      if (prev.testTitle == current.testTitle) {
        final (curVal, _) = _parseValue(current.resultValue);
        final (prevVal, _) = _parseValue(prev.resultValue);
        if (curVal == null || prevVal == null) return null;
        if (curVal == prevVal) {
          return const Icon(Icons.horizontal_rule, color: Colors.grey);
        }
        final betterUp = _isHigherBetter(current.testTitle);
        final improved = betterUp ? curVal > prevVal : curVal < prevVal;
        return Icon(
          improved ? Icons.trending_up : Icons.trending_down,
          color: improved ? Colors.green : Colors.red,
        );
      }
    }
    return null;
  }

  (double? value, String unit) _parseValue(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return (null, '');
    final value = double.tryParse(parts.first);
    final unit = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    return (value, unit);
  }

  bool _isHigherBetter(String title) {
    final t = title.toLowerCase();
    const lowerBetter = [
      '30mts standing start',
      '4*10mts shuttle run',
      '800mts run',
      '1.6km run',
    ];
    if (lowerBetter.any((e) => t.contains(e))) return false;
    return true;
  }
}
