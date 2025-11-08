// lib/matching_service.dart
import 'isar_service.dart';
import 'test_result.dart';
import 'match_model.dart';

class MatchingService {
  final IsarService _isarService = IsarService();

  // This function runs the matching logic
  Future<void> findAndSaveMatches() async {
    final user = await _isarService
        .getCurrentUserProfile(); // Assuming one user for now
    final results = await _isarService.getAllTestResults();
    final sponsors = await _isarService
        .getAllSponsors(); // We'll need to add this method

    if (user == null) return;

    List<Match> newMatches = [];

    // --- Example Matching Logic ---
    // You can make this as complex as you need.
    for (final sponsor in sponsors) {
      if (sponsor.focusSport.toLowerCase() == user.sport?.toLowerCase()) {
        // Find a relevant test result
        final relevantResult = results.firstWhere(
          (r) => r.testTitle.toLowerCase().contains(user.sport!.toLowerCase()),
          orElse: () =>
              TestResult(testTitle: '', resultValue: '', date: DateTime.now()),
        );

        // Simple condition: if a relevant test was found
        if (relevantResult.testTitle.isNotEmpty) {
          final match = Match(
            sponsorName: sponsor.name,
            athleteName: user.name ?? 'Athlete',
            matchReason: 'Strong performance in ${user.sport}',
            dateMatched: DateTime.now(),
          );
          newMatches.add(match);
        }
      }
    }

    if (newMatches.isNotEmpty) {
      await _isarService.saveMatches(newMatches);
    }
  }
}
