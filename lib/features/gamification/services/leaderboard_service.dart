/// Represents a leaderboard entry ready for UI consumption.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.score,
    required this.rank,
  });

  final String userId;
  final String displayName;
  final int score;
  final int rank;
}

/// Manages in-memory leaderboard state.
class LeaderboardService {
  final Map<String, _LeaderboardParticipant> _participants =
      <String, _LeaderboardParticipant>{};

  /// Records score deltas and recomputes ranks.
  void updateScore({
    required String userId,
    required String displayName,
    required int delta,
  }) {
    final _LeaderboardParticipant participant =
        _participants.putIfAbsent(
          userId,
          () => _LeaderboardParticipant(
            userId: userId,
            displayName: displayName,
            score: 0,
          ),
        );
    participant.score += delta;
  }

  /// Returns the top N leaderboard entries.
  List<LeaderboardEntry> top({int limit = 10}) {
    final List<_LeaderboardParticipant> sorted = _participants.values.toList()
      ..sort(
        ( _LeaderboardParticipant a, _LeaderboardParticipant b) =>
            b.score.compareTo(a.score),
      );
    final List<LeaderboardEntry> entries = <LeaderboardEntry>[];
    for (int i = 0; i < sorted.length && i < limit; i++) {
      final _LeaderboardParticipant participant = sorted[i];
      entries.add(
        LeaderboardEntry(
          userId: participant.userId,
          displayName: participant.displayName,
          score: participant.score,
          rank: i + 1,
        ),
      );
    }
    return entries;
  }

  /// Clears all leaderboard participants (useful for tests/reset).
  void reset() => _participants.clear();
}

class _LeaderboardParticipant {
  _LeaderboardParticipant({
    required this.userId,
    required this.displayName,
    required this.score,
  });

  final String userId;
  final String displayName;
  int score;
}


