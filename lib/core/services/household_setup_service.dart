import 'package:hive/hive.dart';
import 'package:smartdolap/core/services/i_household_setup_service.dart';

/// Service to manage household setup skip state
class HouseholdSetupService implements IHouseholdSetupService {
  /// Creates a household setup service
  HouseholdSetupService(this._box);

  final Box<dynamic> _box;
  static const String _skipKey = 'household_setup_skipped';

  /// Checks if household setup has been skipped
  @override
  bool isHouseholdSetupSkipped() =>
      _box.get(_skipKey, defaultValue: false) as bool;

  /// Marks household setup as skipped
  @override
  Future<void> skipHouseholdSetup() async {
    await _box.put(_skipKey, true);
  }

  /// Resets household setup skip (for testing purposes)
  @override
  Future<void> resetHouseholdSetupSkip() async {
    await _box.put(_skipKey, false);
  }
}

